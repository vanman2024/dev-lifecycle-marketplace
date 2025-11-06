# Automated Gating Example

Auto-approval rules and escalation patterns for release workflows.

## Auto-Approval Rules

### Rule 1: Docs-Only Changes

**Automatically approve development and security stages for documentation-only changes.**

```yaml
# .github/releases/approval-gates.yml
policies:
  auto_approve:
    enabled: true
    conditions:
      - name: docs_only
        files_pattern: "**/*.md"
        exclude_code: true
        stages: [development, security]
        notify: true
```

**Implementation:**

```bash
#!/bin/bash
# Check if changes are docs-only

CHANGED_FILES=$(git diff --name-only HEAD~1..HEAD)
NON_DOCS=$(echo "$CHANGED_FILES" | grep -v "\.md$" | wc -l)

if [ "$NON_DOCS" -eq 0 ]; then
  echo "Auto-approve: Docs only"
  bash scripts/generate-approval-audit.sh 1.2.1 approved \
    --auto-approved="development,security" \
    --reason="docs_only"
fi
```

### Rule 2: Dependency Patch Updates

**Auto-approve patch version dependency updates with passing tests.**

```yaml
auto_approve:
  conditions:
    - name: dependency_patch
      dependency_changes: true
      semver_type: patch
      tests_passing: true
      stages: [development]
```

### Rule 3: Automated Security Scans

**Auto-approve security stage if all scans pass.**

```yaml
auto_approve:
  conditions:
    - name: security_scans_pass
      sast_passing: true
      dependency_audit_clean: true
      no_secrets_detected: true
      vulnerability_count: 0
      stages: [security]
```

**GitHub Actions Implementation:**

```yaml
jobs:
  security-scans:
    runs-on: ubuntu-latest
    outputs:
      auto_approve: ${{ steps.evaluate.outputs.auto_approve }}
    steps:
      - name: Run security scans
        run: |
          npm audit --audit-level=high
          safety check
          trufflehog --regex --entropy=False .

      - name: Evaluate auto-approval
        id: evaluate
        run: |
          if [ "$?" -eq 0 ]; then
            echo "auto_approve=true" >> $GITHUB_OUTPUT
            echo "✅ Security scans passed - auto-approving"
          else
            echo "auto_approve=false" >> $GITHUB_OUTPUT
          fi

  auto-approve-security:
    needs: security-scans
    if: needs.security-scans.outputs.auto_approve == 'true'
    runs-on: ubuntu-latest
    steps:
      - name: Auto-approve security stage
        run: |
          bash scripts/generate-approval-audit.sh ${{ inputs.version }} approved \
            --stage=security \
            --auto-approved=true \
            --reason="security_scans_passed"
```

## Escalation Automation

### Escalation Rule 1: 24-Hour Timeout

**Automatically escalate to management after 24 hours.**

```yaml
policies:
  escalation:
    enabled: true
    grace_period_hours: 24
    escalate_to:
      - "@engineering-manager"
      - "@cto"
    notify_channels:
      - "urgent-releases"
```

**Automated Escalation Check:**

```yaml
# .github/workflows/escalation-check.yml
name: Approval Escalation Check

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  check-timeouts:
    runs-on: ubuntu-latest
    steps:
      - name: Find pending approvals
        run: |
          # Query GitHub issues with approval-required label
          PENDING_ISSUES=$(gh issue list \
            --label "release,approval-required" \
            --state open \
            --json number,createdAt)

          # Check each for timeout
          echo "$PENDING_ISSUES" | jq -c '.[]' | while read issue; do
            NUMBER=$(echo "$issue" | jq -r '.number')
            CREATED=$(echo "$issue" | jq -r '.createdAt')
            HOURS_AGO=$(( ($(date +%s) - $(date -d "$CREATED" +%s)) / 3600 ))

            if [ "$HOURS_AGO" -ge 24 ]; then
              echo "Escalating issue #$NUMBER (${HOURS_AGO}h old)"
              VERSION=$(gh issue view "$NUMBER" --json title --jq '.title' | grep -oP 'v\K[0-9.]+')
              bash scripts/escalate-approval.sh "$VERSION" all 24
            fi
          done
```

### Escalation Rule 2: Critical Security Findings

**Immediately escalate if critical vulnerabilities found.**

```yaml
escalation:
  immediate_escalation:
    - condition: critical_vulnerability_found
      severity: critical
      escalate_to: ["@cto", "@ciso"]
      block_release: true
```

### Escalation Rule 3: Failed CI/CD

**Escalate if CI/CD fails after approval granted.**

```yaml
escalation:
  post_approval_failures:
    - condition: ci_cd_failure
      escalate_to: ["@devops-lead", "@release-manager"]
      revert_approval: true
```

## Automated Rollback

### Rollback on Post-Release Failure

**Automatically rollback and revoke approval if deployment fails.**

```yaml
# .github/workflows/auto-rollback.yml
name: Auto-Rollback on Failure

on:
  workflow_run:
    workflows: ["Deploy to Production"]
    types: [completed]

jobs:
  check-deployment:
    if: github.event.workflow_run.conclusion == 'failure'
    runs-on: ubuntu-latest
    steps:
      - name: Trigger rollback
        run: |
          VERSION=$(git describe --tags --abbrev=0)
          echo "Deployment failed for $VERSION"

          # Rollback to previous version
          /versioning:rollback

          # Revoke approval
          bash scripts/generate-approval-audit.sh "$VERSION" rejected \
            --reason="deployment_failed" \
            --auto-rollback=true

      - name: Notify stakeholders
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        run: |
          bash scripts/notify-slack.sh approval-denied "$VERSION" \
            "🚨 DEPLOYMENT FAILED - Automatic rollback initiated\n\nVersion: $VERSION\nReason: CI/CD deployment failure\nStatus: Rolled back to previous version\n\n@release-manager @devops-lead - Immediate attention required."
```

## Smart Gating Patterns

### Pattern 1: Time-Based Auto-Approval

**Auto-approve off-hours releases with monitoring.**

```yaml
auto_approve:
  time_based:
    - name: off_hours_patches
      time_range: "18:00-08:00"  # 6 PM to 8 AM
      days: ["Saturday", "Sunday"]
      allowed_types: [patch]
      stages: [qa, release]
      conditions:
        - all_tests_passing: true
        - no_breaking_changes: true
      monitoring_required: true
```

### Pattern 2: Progressive Rollout Gates

**Auto-approve production deployment in stages.**

```yaml
auto_approve:
  progressive_rollout:
    - stage: canary
      percentage: 5
      auto_approve: true
      monitoring_duration: 1h

    - stage: staging_full
      percentage: 100
      auto_approve: true (if canary successful)
      monitoring_duration: 2h

    - stage: production_partial
      percentage: 25
      auto_approve: false
      required_approvals: [release_manager]

    - stage: production_full
      percentage: 100
      auto_approve: false
      required_approvals: [cto]
```

### Pattern 3: Conditional Auto-Merge

**Auto-merge PRs after approval and CI success.**

```yaml
# .github/workflows/auto-merge.yml
name: Auto-Merge on Approval

on:
  pull_request_review:
    types: [submitted]

jobs:
  auto-merge:
    if: github.event.review.state == 'approved'
    runs-on: ubuntu-latest
    steps:
      - name: Check CI status
        run: |
          gh pr checks ${{ github.event.pull_request.number }} --watch

      - name: Auto-merge if all checks pass
        run: |
          gh pr merge ${{ github.event.pull_request.number }} \
            --auto \
            --squash \
            --delete-branch
```

## Emergency Override

### Pattern: Fast-Track Critical Fixes

**Allow expedited approval for hotfixes.**

```yaml
emergency_override:
  enabled: true
  conditions:
    - severity: critical
    - security_patch: true
    - production_down: true
  requirements:
    required_approvals: 1  # Normally 6
    approvers: ["@cto", "@engineering-manager"]
    audit_required: true
    post_release_review: mandatory
```

**Usage:**

```bash
# Request emergency override
/versioning:approve-release 1.2.5 --emergency \
  --reason="Production outage - database connection failure" \
  --severity=critical

# Emergency approval workflow:
# 1. CTO approves immediately
# 2. Deployment proceeds
# 3. Post-release review scheduled within 24h
# 4. Full audit trail generated
```

## Complete Automation Example

### Fully Automated Patch Release

```yaml
# .github/workflows/auto-patch-release.yml
name: Automated Patch Release

on:
  push:
    branches: [main]
    paths:
      - '**/*.md'
      - 'docs/**'

jobs:
  auto-release:
    if: contains(github.event.head_commit.message, '[auto-release]')
    runs-on: ubuntu-latest
    steps:
      - name: Check conditions
        id: check
        run: |
          # Verify docs-only changes
          CHANGED=$(git diff --name-only HEAD~1..HEAD)
          NON_DOCS=$(echo "$CHANGED" | grep -v "\.md$" | wc -l)

          if [ "$NON_DOCS" -eq 0 ]; then
            echo "eligible=true" >> $GITHUB_OUTPUT
          fi

      - name: Auto-bump patch version
        if: steps.check.outputs.eligible == 'true'
        run: /versioning:bump patch

      - name: Auto-approve all stages
        run: |
          VERSION=$(cat VERSION | jq -r '.version')

          bash scripts/generate-approval-audit.sh "$VERSION" approved \
            --auto-approved="development,qa,security,release" \
            --reason="docs_only_auto_release" \
            --approved-by="github-actions-bot"

      - name: Push tags
        run: git push --tags

      - name: Notify completion
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        run: |
          bash scripts/notify-slack.sh approval-complete "$VERSION" \
            "✅ Automated patch release v$VERSION deployed\n\nType: Docs-only\nAuto-approved: All stages\nCI/CD: ✅ Passed\n\nNo manual approval required."
```

## Monitoring and Audit

### Track Auto-Approval Usage

```bash
# Generate auto-approval report
find .github/releases/approvals -name "*.json" | \
  xargs jq -r 'select(.metadata.auto_approved == true) | "\(.version) - \(.metadata.auto_approve_reason)"'

# Output:
# 1.2.1 - docs_only
# 1.2.2 - dependency_patch
# 1.2.3 - security_scans_passed
```

### Audit Auto-Approvals

All auto-approvals documented in approval records:

```json
{
  "version": "1.2.1",
  "final_decision": "approved",
  "metadata": {
    "auto_approved": true,
    "auto_approve_reason": "docs_only",
    "auto_approve_stages": ["development", "security"],
    "auto_approve_timestamp": "2025-01-15T10:00:00Z",
    "manual_approve_stages": ["qa", "release"]
  }
}
```

## Best Practices

1. **Never auto-approve major releases**: Require human review for breaking changes
2. **Monitor auto-approvals**: Regular audits of auto-approval usage
3. **Override capability**: Always allow manual override of auto-approval
4. **Clear audit trails**: Document why each auto-approval occurred
5. **Test automation**: Verify auto-approval rules in staging first

## Next Steps

- Review approval audit trails: See `approval-audit-trail.md`
- Configure environment protection: See `environment-protection-rules.md`
- Set up conditional approvals: See `conditional-approval.md`

# Approval Audit Trail Example

Complete audit trail documentation and compliance patterns.

## Audit Record Structure

### Full Audit Record Example

```json
{
  "version": "1.3.0",
  "requested_at": "2025-01-15T10:00:00Z",
  "completed_at": "2025-01-15T14:30:00Z",
  "final_decision": "approved",
  "metadata": {
    "git_commit": "abc123def456789012345678901234567890abcd",
    "git_branch": "main",
    "git_tag": "v1.3.0",
    "generated_by": "generate-approval-audit.sh",
    "generated_at": "2025-01-15T14:30:00Z",
    "workflow_type": "sequential",
    "release_type": "minor",
    "auto_approved": false
  },
  "release_info": {
    "changelog_url": "https://github.com/owner/repo/blob/v1.3.0/CHANGELOG.md",
    "release_notes_url": "https://github.com/owner/repo/releases/tag/v1.3.0",
    "pr_numbers": [123, 124, 125],
    "commits_included": 15,
    "files_changed": 42,
    "lines_added": 532,
    "lines_removed": 187
  },
  "approvals": [
    {
      "stage": "development",
      "approver": "tech-lead",
      "approver_email": "tech-lead@example.com",
      "decision": "approved",
      "timestamp": "2025-01-15T11:00:00Z",
      "duration_minutes": 60,
      "comments": "Code review complete. All tests passing. Architecture looks good.",
      "metadata": {
        "github_username": "tech-lead",
        "approval_method": "github_issue_comment",
        "ip_address": "203.0.113.42",
        "user_agent": "Mozilla/5.0..."
      }
    },
    {
      "stage": "development",
      "approver": "senior-dev",
      "approver_email": "senior-dev@example.com",
      "decision": "approved",
      "timestamp": "2025-01-15T11:30:00Z",
      "duration_minutes": 90,
      "comments": "Reviewed changes. LGTM. No concerns.",
      "metadata": {
        "github_username": "senior-dev",
        "approval_method": "github_issue_comment"
      }
    },
    {
      "stage": "qa",
      "approver": "qa-lead",
      "approver_email": "qa@example.com",
      "decision": "approved_with_conditions",
      "timestamp": "2025-01-15T13:00:00Z",
      "duration_minutes": 180,
      "comments": "All test suites passing. Minor UI issue #1234 logged but non-blocking.",
      "conditions": [
        "Monitor UI issue #1234 in production",
        "Verify performance metrics meet SLA",
        "Check error rates post-deployment"
      ],
      "metadata": {
        "github_username": "qa-lead",
        "approval_method": "github_issue_comment",
        "test_results": {
          "unit_tests": "pass",
          "integration_tests": "pass",
          "e2e_tests": "pass",
          "performance_tests": "pass",
          "accessibility_tests": "pass",
          "known_issues": ["#1234"]
        }
      }
    },
    {
      "stage": "security",
      "approver": "security-team-lead",
      "approver_email": "security@example.com",
      "decision": "approved",
      "timestamp": "2025-01-15T14:00:00Z",
      "duration_minutes": 240,
      "comments": "Security review complete. No vulnerabilities detected. Dependencies up to date.",
      "metadata": {
        "github_username": "security-team-lead",
        "approval_method": "github_issue_comment",
        "security_scans": {
          "dependency_audit": "pass",
          "secret_detection": "pass",
          "sast_scan": "pass",
          "dast_scan": "pass",
          "vulnerabilities_found": 0,
          "license_compliance": "pass"
        }
      }
    },
    {
      "stage": "release",
      "approver": "release-manager",
      "approver_email": "releases@example.com",
      "decision": "approved",
      "timestamp": "2025-01-15T14:20:00Z",
      "duration_minutes": 20,
      "comments": "All approvals obtained. Release checklist complete. Approved for production.",
      "metadata": {
        "github_username": "release-manager",
        "approval_method": "github_issue_comment",
        "checklist_verified": true
      }
    },
    {
      "stage": "release",
      "approver": "product-owner",
      "approver_email": "product@example.com",
      "decision": "approved",
      "timestamp": "2025-01-15T14:25:00Z",
      "duration_minutes": 25,
      "comments": "Feature requirements met. Documentation updated. Ready for release.",
      "metadata": {
        "github_username": "product-owner",
        "approval_method": "github_issue_comment",
        "requirements_verified": true
      }
    }
  ],
  "conditions": [
    "Monitor UI issue #1234 post-release",
    "Verify performance metrics meet SLA",
    "Check error rates post-deployment"
  ],
  "summary": {
    "total_approvals_required": 6,
    "total_approvals_received": 6,
    "approval_rate": "100%",
    "time_to_complete_hours": 4.5,
    "stages_completed": ["development", "qa", "security", "release"],
    "stages_auto_approved": [],
    "conditions_count": 3,
    "veto_exercised": false
  },
  "compliance": {
    "sox_compliant": true,
    "gdpr_compliant": true,
    "audit_trail_complete": true,
    "separation_of_duties": true,
    "approver_authorization_verified": true
  },
  "deployment": {
    "deployed": true,
    "deployed_at": "2025-01-15T15:00:00Z",
    "deployed_by": "github-actions",
    "deployment_url": "https://app.example.com",
    "rollback_available": true,
    "rollback_version": "v1.2.9"
  }
}
```

## Generating Audit Records

### Basic Audit Generation

```bash
# Generate approval audit after all approvals obtained
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/release-approval/scripts/generate-approval-audit.sh \
  1.3.0 \
  approved \
  .github/releases/approvals/v1.3.0.json
```

### Enhanced Audit with Metadata

```bash
# Generate with additional metadata
bash scripts/generate-approval-audit.sh 1.3.0 approved \
  --release-type="minor" \
  --workflow-type="sequential" \
  --pr-numbers="123,124,125" \
  --commits-included=15
```

## Viewing Audit Records

### Display Single Record

```bash
# View approval status with full audit details
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/release-approval/scripts/check-approval-status.sh 1.3.0
```

**Output:**
```
═══════════════════════════════════════════════════════
               APPROVAL RECORD: v1.3.0
═══════════════════════════════════════════════════════

📦 Version:      v1.3.0
📅 Requested:    2025-01-15T10:00:00Z
✅ Completed:    2025-01-15T14:30:00Z
🎯 Decision:     approved
📝 Approvals:    6

───────────────────────────────────────────────────────
                   APPROVAL DETAILS
───────────────────────────────────────────────────────

Stage:     development
Approver:  tech-lead (tech-lead@example.com)
Decision:  approved
Timestamp: 2025-01-15T11:00:00Z
Duration:  60 minutes
Comments:  Code review complete. All tests passing.
───────────────────────────────────────────────────────

[... additional approvals ...]

═══════════════════════════════════════════════════════
                  APPROVAL SUMMARY
═══════════════════════════════════════════════════════

✅ Status: APPROVED

🎉 All required approvals obtained!

Next steps:
  1. Push tags: git push --tags
  2. Monitor CI: gh run list
  3. Verify deployment
```

### List All Approval Records

```bash
# List all approval records chronologically
ls -lt .github/releases/approvals/

# Output:
# v1.3.0.json  2025-01-15 14:30
# v1.2.9.json  2025-01-10 16:45
# v1.2.8.json  2025-01-05 11:20
```

### Search Approval Records

```bash
# Find all approved releases
jq -r 'select(.final_decision == "approved") | .version' \
  .github/releases/approvals/*.json

# Find releases with conditions
jq -r 'select(.conditions | length > 0) | "\(.version): \(.conditions | join(", "))"' \
  .github/releases/approvals/*.json

# Find auto-approved releases
jq -r 'select(.metadata.auto_approved == true) | .version' \
  .github/releases/approvals/*.json
```

## Compliance Reports

### SOX Compliance Report

```bash
#!/bin/bash
# Generate SOX compliance report for audit period

AUDIT_START="2025-01-01"
AUDIT_END="2025-01-31"

echo "SOX Compliance Report"
echo "Period: $AUDIT_START to $AUDIT_END"
echo ""

for approval_file in .github/releases/approvals/v*.json; do
  VERSION=$(jq -r '.version' "$approval_file")
  COMPLETED=$(jq -r '.completed_at' "$approval_file")
  DECISION=$(jq -r '.final_decision' "$approval_file")

  # Check if within audit period
  if [[ "$COMPLETED" > "$AUDIT_START" && "$COMPLETED" < "$AUDIT_END" ]]; then
    echo "Version: $VERSION"
    echo "  Status: $DECISION"
    echo "  Completed: $COMPLETED"

    # Verify separation of duties
    APPROVERS=$(jq -r '.approvals[].approver' "$approval_file" | sort -u)
    DEPLOYER=$(jq -r '.deployment.deployed_by' "$approval_file")

    if echo "$APPROVERS" | grep -q "$DEPLOYER"; then
      echo "  ⚠️  SOX WARNING: Deployer was also approver"
    else
      echo "  ✅ SOX COMPLIANT: Separation of duties maintained"
    fi

    # Verify audit trail completeness
    AUDIT_COMPLETE=$(jq -r '.compliance.audit_trail_complete' "$approval_file")
    echo "  Audit Trail: $AUDIT_COMPLETE"
    echo ""
  fi
done
```

### Approval Velocity Report

```bash
# Calculate average approval time by stage
jq -r '.approvals[] | "\(.stage) \(.duration_minutes)"' \
  .github/releases/approvals/*.json | \
  awk '{sum[$1]+=$2; count[$1]++} END {for (stage in sum) print stage ": " sum[stage]/count[stage] " min avg"}'

# Output:
# development: 75 min avg
# qa: 150 min avg
# security: 180 min avg
# release: 22 min avg
```

### Rejection Analysis

```bash
# Analyze rejection reasons
jq -r 'select(.final_decision == "rejected") |
  "\(.version) - Rejected by \(.approvals[] | select(.decision == "rejected") | .approver): \(.comments)"' \
  .github/releases/approvals/*.json

# Output:
# v1.2.7 - Rejected by security-team-lead: Critical CVE found
# v1.2.5 - Rejected by qa-lead: Test failures in payment module
```

## Audit Trail Best Practices

### 1. Immutable Records

```bash
# Commit approval records immediately after generation
git add .github/releases/approvals/v1.3.0.json
git commit -m "docs(release): approval record for v1.3.0"

# Never modify committed approval records
# If changes needed, create new version and document update reason
```

### 2. Cryptographic Signatures

```bash
# Sign approval records with GPG
gpg --detach-sign --armor .github/releases/approvals/v1.3.0.json

# Verify signature
gpg --verify .github/releases/approvals/v1.3.0.json.asc
```

### 3. Centralized Logging

```bash
# Send approval events to centralized logging
log_approval_event() {
  local version="$1"
  local event="$2"
  local details="$3"

  curl -X POST "https://logs.example.com/api/events" \
    -H "Content-Type: application/json" \
    -d "{
      \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
      \"event_type\": \"release_approval\",
      \"version\": \"$version\",
      \"event\": \"$event\",
      \"details\": \"$details\"
    }"
}

# Log approval milestones
log_approval_event "1.3.0" "requested" "All stakeholders notified"
log_approval_event "1.3.0" "approved" "All approvals obtained"
log_approval_event "1.3.0" "deployed" "Production deployment complete"
```

### 4. Retention Policy

```yaml
# .github/releases/retention-policy.yml
retention:
  approval_records:
    minimum_retention: 7 years  # SOX compliance
    archive_after: 2 years
    backup_location: s3://company-audit-records/releases/
```

## Integration with External Systems

### Jira Integration

```bash
# Create Jira ticket for approval tracking
jira_ticket=$(curl -X POST "https://jira.example.com/rest/api/2/issue" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "REL"},
      "summary": "Release Approval: v1.3.0",
      "description": "Track approval workflow for release v1.3.0",
      "issuetype": {"name": "Release"}
    }
  }' | jq -r '.key')

# Link approval record to Jira ticket
jq --arg ticket "$jira_ticket" '.metadata.jira_ticket = $ticket' \
  .github/releases/approvals/v1.3.0.json > tmp && mv tmp .github/releases/approvals/v1.3.0.json
```

### ServiceNow Integration

```bash
# Create change request in ServiceNow
snow_cr=$(curl -X POST "https://instance.service-now.com/api/now/table/change_request" \
  -H "Content-Type: application/json" \
  -d '{
    "short_description": "Deploy v1.3.0 to production",
    "category": "Software",
    "priority": "3",
    "risk": "Low"
  }' | jq -r '.result.number')

# Update approval record with change request number
jq --arg cr "$snow_cr" '.metadata.servicenow_cr = $cr' \
  .github/releases/approvals/v1.3.0.json > tmp && mv tmp .github/releases/approvals/v1.3.0.json
```

## Audit Record Verification

### Verify Record Integrity

```bash
#!/bin/bash
# Verify approval record hasn't been tampered with

verify_approval_record() {
  local file="$1"

  # Check file exists
  if [ ! -f "$file" ]; then
    echo "❌ File not found: $file"
    return 1
  fi

  # Validate JSON structure
  if ! jq empty "$file" 2>/dev/null; then
    echo "❌ Invalid JSON in $file"
    return 1
  fi

  # Check required fields
  local required_fields=("version" "final_decision" "approvals" "metadata")
  for field in "${required_fields[@]}"; do
    if ! jq -e ".$field" "$file" > /dev/null; then
      echo "❌ Missing required field: $field"
      return 1
    fi
  done

  # Verify git commit exists
  local git_commit=$(jq -r '.metadata.git_commit' "$file")
  if ! git cat-file -e "$git_commit" 2>/dev/null; then
    echo "❌ Git commit not found: $git_commit"
    return 1
  fi

  echo "✅ Approval record verified: $file"
  return 0
}

# Verify all records
for file in .github/releases/approvals/*.json; do
  verify_approval_record "$file"
done
```

## Next Steps

- Setup automated gating: See `automated-gating.md`
- Configure Slack notifications: See `slack-integration-complete.md`
- Implement conditional approvals: See `conditional-approval.md`

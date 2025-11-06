# Basic Approval Workflow Example

This example demonstrates a simple sequential approval workflow for a release.

## Scenario

Release version `1.2.3` with sequential approval gates:
1. Development team reviews code
2. QA team validates testing
3. Security team assesses vulnerabilities
4. Release manager signs off

## Step-by-Step Workflow

### 1. Initialize Approval Configuration

```bash
# Setup approval gates (first time only)
bash plugins/versioning/skills/release-approval/scripts/setup-approval-gates.sh

# This creates:
# - .github/releases/approval-gates.yml (configuration)
# - .github/releases/approvals/ (audit records directory)
# - .github/workflows/release-approval.yml (GitHub Actions workflow)
```

### 2. Create Release Version

```bash
# Bump version and create tag
/versioning:bump minor

# Output:
# Version bumped: 1.1.0 → 1.2.0
# Tag created: v1.2.0
# CHANGELOG updated with commits
```

### 3. Request Approvals

```bash
# Start approval workflow
/versioning:approve-release 1.2.0

# Or trigger manually:
bash plugins/versioning/skills/release-approval/scripts/request-approval.sh 1.2.0 development github
```

**What happens:**
- Creates GitHub issue: "Release Approval: v1.2.0"
- Lists all approval stages and required approvers
- Mentions all stakeholders: @tech-lead @senior-dev @qa-lead @security-team-lead @release-manager

### 4. Development Team Approval

Approvers comment on the GitHub issue:

```
@tech-lead: /approve
All tests passing. Code review complete. Ready for QA.

@senior-dev: /approve
Reviewed changes. No concerns. LGTM.
```

**Status after development approval:**
- ✅ Development stage: Approved (2/2 required)
- ⏳ QA stage: Pending (depends on development)
- ⏳ Security stage: Pending
- ⏳ Release stage: Pending

### 5. QA Team Approval

```
@qa-lead: /approve-with-conditions
All test suites passing. Minor UI issue #1234 logged but non-blocking. Approved with condition to monitor post-release.
```

**Status after QA approval:**
- ✅ Development stage: Approved
- ✅ QA stage: Approved with conditions (1/1 required)
- ⏳ Security stage: Pending
- ⏳ Release stage: Pending (depends on all previous stages)

### 6. Security Team Approval

```
@security-team-lead: /approve
Security review complete. No vulnerabilities detected. Dependencies up to date.
```

**Status after security approval:**
- ✅ Development stage: Approved
- ✅ QA stage: Approved with conditions
- ✅ Security stage: Approved (1/1 required)
- ⏳ Release stage: Pending

### 7. Release Management Approval

```
@release-manager: /approve
All approvals obtained. Release checklist complete. Approved for production.
```

**Final status:**
- ✅ Development stage: Approved
- ✅ QA stage: Approved with conditions
- ✅ Security stage: Approved
- ✅ Release stage: Approved (1/2 required)
- ⏳ Waiting for product owner...

```
@product-owner: /approve
Feature requirements met. Documentation updated. Ready for release.
```

### 8. Generate Approval Audit Record

```bash
# Automatically generated after all approvals
bash plugins/versioning/skills/release-approval/scripts/generate-approval-audit.sh 1.2.0 approved

# Creates: .github/releases/approvals/v1.2.0.json
```

**Audit record includes:**
- Version: 1.2.0
- All approval decisions with timestamps
- Approver names and comments
- Conditions noted by approvers
- Final decision: approved
- Metadata: git commit, branch, generation time

### 9. Check Approval Status

```bash
# View comprehensive approval status
bash plugins/versioning/skills/release-approval/scripts/check-approval-status.sh 1.2.0
```

**Output:**
```
═══════════════════════════════════════════════════════
               APPROVAL RECORD: v1.2.0
═══════════════════════════════════════════════════════

📦 Version:      v1.2.0
📅 Requested:    2025-01-15T10:00:00Z
✅ Completed:    2025-01-15T14:30:00Z
🎯 Decision:     approved
📝 Approvals:    6

───────────────────────────────────────────────────────
                   APPROVAL DETAILS
───────────────────────────────────────────────────────

Stage:     development
Approver:  tech-lead
Decision:  approved
Timestamp: 2025-01-15T11:00:00Z
Comments:  All tests passing. Ready for QA.
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

### 10. Commit Approval Record

```bash
# Commit approval record to git
git add .github/releases/approvals/v1.2.0.json
git commit -m "docs(release): approval record for v1.2.0"
git push
```

### 11. Push Tags to Trigger Deployment

```bash
# Push tags to trigger CI/CD deployment
git push --tags

# Monitor deployment
gh run list --workflow=release.yml
```

## Timeline

| Time   | Stage          | Event                           |
|--------|----------------|---------------------------------|
| 10:00  | Initialization | Approval workflow started       |
| 10:05  | Development    | Approval requests sent          |
| 11:00  | Development    | Tech lead approves              |
| 11:15  | Development    | Senior dev approves             |
| 11:20  | QA             | QA approval requested           |
| 13:00  | QA             | QA lead approves (with conds)   |
| 13:05  | Security       | Security approval requested     |
| 14:00  | Security       | Security team lead approves     |
| 14:05  | Release        | Release approval requested      |
| 14:20  | Release        | Release manager approves        |
| 14:25  | Release        | Product owner approves          |
| 14:30  | Finalization   | Audit record generated          |
| 14:35  | Deployment     | Tags pushed, CI/CD triggered    |

**Total time: 4.5 hours**

## Approval Record

The generated approval record (`.github/releases/approvals/v1.2.0.json`):

```json
{
  "version": "1.2.0",
  "requested_at": "2025-01-15T10:00:00Z",
  "completed_at": "2025-01-15T14:30:00Z",
  "final_decision": "approved",
  "approvals": [
    {
      "stage": "development",
      "approver": "tech-lead",
      "decision": "approved",
      "timestamp": "2025-01-15T11:00:00Z",
      "comments": "All tests passing. Ready for QA."
    },
    {
      "stage": "qa",
      "approver": "qa-lead",
      "decision": "approved_with_conditions",
      "timestamp": "2025-01-15T13:00:00Z",
      "comments": "All tests passing. Minor UI issue #1234 logged.",
      "conditions": ["Monitor UI issue #1234 post-release"]
    }
  ],
  "conditions": ["Monitor UI issue #1234 post-release"],
  "summary": {
    "total_approvals_required": 6,
    "total_approvals_received": 6,
    "time_to_complete_hours": 4.5
  }
}
```

## Key Takeaways

1. **Sequential Dependency**: QA waits for development, release waits for all
2. **Audit Trail**: Every approval documented with timestamp and comments
3. **Conditions Tracking**: Conditions noted and carried through to final record
4. **Automation**: Scripts handle GitHub integration, Slack notifications, audit generation
5. **Transparency**: All stakeholders see approval progress in real-time

## Next Steps

- Try parallel approval workflow: See `parallel-approval-gates.md`
- Add Slack integration: See `slack-integration-complete.md`
- Implement auto-approval rules: See `automated-gating.md`

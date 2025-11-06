# Parallel Approval Gates Example

This example demonstrates parallel approval workflows where multiple stakeholders review simultaneously.

## Scenario

Release version `2.0.0` (major release) with parallel approval gates:
- Development, QA, and Security teams review **simultaneously**
- Release management approves only after **all three** complete
- Faster approval process for time-sensitive releases

## Configuration

Update `.github/releases/approval-gates.yml` for parallel approvals:

```yaml
approval_gates:
  - stage: development
    approvers: ["@tech-lead", "@senior-dev"]
    required: 2
    timeout_hours: 24
    depends_on: []  # No dependencies - can start immediately

  - stage: qa
    approvers: ["@qa-lead"]
    required: 1
    timeout_hours: 12
    depends_on: []  # No dependencies - parallel with development

  - stage: security
    approvers: ["@security-team-lead"]
    required: 1
    timeout_hours: 48
    veto_power: true
    depends_on: []  # No dependencies - parallel with others

  - stage: release
    approvers: ["@release-manager", "@product-owner"]
    required: 2
    timeout_hours: 12
    depends_on: ["development", "qa", "security"]  # Waits for ALL
```

## Workflow

### 1. Initialize Release

```bash
# Create major version (2.0.0)
/versioning:bump major

# Start parallel approval workflow
/versioning:approve-release 2.0.0
```

### 2. All Stages Triggered Simultaneously

**What happens at 10:00:**
- 🔔 Development team notified
- 🔔 QA team notified
- 🔔 Security team notified
- ⏸️  Release stage waits for all three

**GitHub Issue Created:**
```markdown
# Release Approval: v2.0.0

## 📋 Approval Status

### Development Team (Parallel)
- [ ] @tech-lead
- [ ] @senior-dev
Status: ⏳ Pending

### QA Team (Parallel)
- [ ] @qa-lead
Status: ⏳ Pending

### Security Team (Parallel)
- [ ] @security-team-lead
Status: ⏳ Pending

### Release Management (Sequential)
- [ ] @release-manager
- [ ] @product-owner
Status: ⏸️  Waiting for all previous stages
```

### 3. Parallel Approvals Come In

**Timeline:**

| Time  | Stage      | Event                    | Status |
|-------|------------|--------------------------|--------|
| 10:00 | All        | Approval requests sent   | Pending |
| 10:30 | QA         | QA lead approves (fast!) | ✅ |
| 11:15 | Development| Tech lead approves       | 1/2 ✅ |
| 11:45 | Development| Senior dev approves      | 2/2 ✅ |
| 12:30 | Security   | Security team approves   | ✅ |
| 12:31 | Release    | Release stage activated  | Pending |
| 13:00 | Release    | Release manager approves | 1/2 ✅ |
| 13:15 | Release    | Product owner approves   | 2/2 ✅ |

**Key observation**: QA finished first at 10:30, but release stage couldn't start until security (12:30) completed.

### 4. Approval Comments

**QA Lead (10:30 - fastest):**
```
@qa-lead: /approve
All automated tests passing. Manual regression testing complete. No issues found.
```

**Tech Lead (11:15):**
```
@tech-lead: /approve
Breaking changes documented. Migration guide included. Code review complete.
```

**Senior Dev (11:45):**
```
@senior-dev: /approve
Reviewed breaking changes and migration path. Approved.
```

**Security Team Lead (12:30 - slowest of parallel):**
```
@security-team-lead: /approve
Security audit complete. No vulnerabilities. Breaking changes reviewed for security implications. Approved.
```

**Release Manager (13:00):**
```
@release-manager: /approve
All parallel approvals obtained. Major version release checklist complete.
```

**Product Owner (13:15):**
```
@product-owner: /approve
Breaking changes communicated to stakeholders. Documentation updated. Ready for release.
```

### 5. Check Status During Parallel Approval

```bash
# Check status while approvals are coming in
bash plugins/versioning/skills/release-approval/scripts/check-approval-status.sh 2.0.0
```

**Output at 11:45 (midway through parallel approvals):**
```
═══════════════════════════════════════════════════════
              GITHUB APPROVAL ISSUE STATUS
═══════════════════════════════════════════════════════

🔖 Issue:        #45
📊 State:        open
💬 Comments:     3

───────────────────────────────────────────────────────
                  APPROVAL PROGRESS
───────────────────────────────────────────────────────

✅ QA:           Approved (1/1) - 10:30
✅ Development:  Approved (2/2) - 11:45
⏳ Security:     Pending (0/1) - In progress
⏸️  Release:     Waiting for: security

Estimated completion: Waiting for security review...
```

### 6. Final Audit Record

```json
{
  "version": "2.0.0",
  "requested_at": "2025-01-15T10:00:00Z",
  "completed_at": "2025-01-15T13:15:00Z",
  "final_decision": "approved",
  "workflow_type": "parallel",
  "approvals": [
    {
      "stage": "qa",
      "approver": "qa-lead",
      "decision": "approved",
      "timestamp": "2025-01-15T10:30:00Z",
      "duration_minutes": 30,
      "comments": "All automated tests passing."
    },
    {
      "stage": "development",
      "approver": "tech-lead",
      "decision": "approved",
      "timestamp": "2025-01-15T11:15:00Z",
      "duration_minutes": 75
    },
    {
      "stage": "development",
      "approver": "senior-dev",
      "decision": "approved",
      "timestamp": "2025-01-15T11:45:00Z",
      "duration_minutes": 105
    },
    {
      "stage": "security",
      "approver": "security-team-lead",
      "decision": "approved",
      "timestamp": "2025-01-15T12:30:00Z",
      "duration_minutes": 150,
      "comments": "Security audit complete. No vulnerabilities."
    },
    {
      "stage": "release",
      "approver": "release-manager",
      "decision": "approved",
      "timestamp": "2025-01-15T13:00:00Z"
    },
    {
      "stage": "release",
      "approver": "product-owner",
      "decision": "approved",
      "timestamp": "2025-01-15T13:15:00Z"
    }
  ],
  "summary": {
    "total_approvals_required": 6,
    "total_approvals_received": 6,
    "time_to_complete_hours": 3.25,
    "parallel_stages_completed_hours": 2.5,
    "bottleneck_stage": "security",
    "fastest_stage": "qa",
    "workflow_efficiency": "77%"
  }
}
```

## Benefits of Parallel Approval

### Time Savings

**Sequential workflow (from basic-approval-workflow.md):**
- Development: 1.5 hours
- QA: 2 hours (waits for dev)
- Security: 1 hour (waits for QA)
- Release: 0.5 hours
- **Total: 5 hours**

**Parallel workflow (this example):**
- Development: 1.75 hours
- QA: 0.5 hours (parallel)
- Security: 2.5 hours (parallel)
- Release: 0.5 hours (waits for all)
- **Total: 3.25 hours (35% faster!)**

### When to Use Parallel vs Sequential

**Use Parallel When:**
- ✅ Stages are independent (code review, testing, security)
- ✅ Time-sensitive releases
- ✅ Major versions with thorough review needed
- ✅ All reviewers available simultaneously

**Use Sequential When:**
- ❌ Stages have dependencies (QA needs dev approval first)
- ❌ Resources limited (one reviewer handles multiple stages)
- ❌ Incremental validation needed
- ❌ Patch releases with minimal changes

## Handling Delays in Parallel Workflow

### Scenario: Security Review Delayed

If security review takes longer than expected:

```bash
# Check status after 24 hours
bash plugins/versioning/skills/release-approval/scripts/check-approval-status.sh 2.0.0

# Escalate if needed
bash plugins/versioning/skills/release-approval/scripts/escalate-approval.sh 2.0.0 security 24
```

**Escalation notification sent:**
- 🔔 GitHub comment on approval issue
- 🔔 Slack alert to @security-manager, @engineering-manager
- 🔔 Email notification (if configured)

### Veto Power in Parallel Workflow

If security team rejects (veto power):

```
@security-team-lead: /reject
Critical vulnerability CVE-2024-1234 found in dependency. Must upgrade before release.
```

**Result:**
- ❌ Security stage: REJECTED (veto power)
- ❌ Final decision: REJECTED (even though dev and QA approved)
- 🚫 Release stage: BLOCKED

**Next steps:**
1. Address security concerns
2. Update dependencies
3. Re-run security scans
4. Request new approval: `/versioning:approve-release 2.0.0`

## GitHub Actions Workflow for Parallel Approvals

The workflow automatically handles parallel execution:

```yaml
jobs:
  request-approvals:
    strategy:
      matrix:
        stage: [development, qa, security]
    runs-on: ubuntu-latest
    steps:
      - name: Request ${{ matrix.stage }} approval
        run: |
          bash scripts/request-approval.sh 2.0.0 ${{ matrix.stage }} both

  wait-for-parallel-completion:
    needs: request-approvals
    runs-on: ubuntu-latest
    steps:
      - name: All parallel approvals complete
        run: echo "Development, QA, and Security approved!"

  request-release-approval:
    needs: wait-for-parallel-completion
    runs-on: ubuntu-latest
    steps:
      - name: Request release approval
        run: bash scripts/request-approval.sh 2.0.0 release both
```

## Key Takeaways

1. **Parallel = Faster**: 35% time savings for this example
2. **Bottleneck Awareness**: Slowest parallel stage determines timeline
3. **Veto Power**: Security can block release even if others approved
4. **Resource Efficiency**: Reviewers work simultaneously, not sequentially
5. **Best for Major Releases**: More scrutiny, faster turnaround

## Next Steps

- Implement conditional approvals: See `conditional-approval.md`
- Add Slack integration: See `slack-integration-complete.md`
- Automate low-risk releases: See `automated-gating.md`

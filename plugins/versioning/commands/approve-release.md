---
allowed-tools: Bash, Read, AskUserQuestion, Task
description: Multi-stakeholder approval workflow before release
argument-hint: [version]
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Orchestrate multi-stakeholder approval workflow before release including validation, stakeholder sign-off, and release confirmation

Core Principles:
- Validate release readiness comprehensively
- Collect approvals from key stakeholders
- Document approval decisions and rationale
- Provide clear go/no-go decision with audit trail
- Block release if critical issues found or approvals denied

## Available Skills

This command has access to the version-manager skill for version validation and release checking patterns.

---


## Phase 1: Parse Arguments and Load Version

Determine target version for approval:

Actions:
- Parse version from $ARGUMENTS (optional)
- If no version provided, read from VERSION file
- Validate version format matches semver: MAJOR.MINOR.PATCH
- Check git tag exists: `git tag -l v<version>`
- If tag doesn't exist, exit with error: "Tag v<version> not found. Run /versioning:bump first"
- Display: "Initiating approval workflow for version <version>"

## Phase 2: Validate Release Readiness

Invoke release-validator agent for comprehensive validation:

Actions:

Task(description="Validate release readiness", subagent_type="versioning:release-validator", prompt="You are the release-validator agent. Validate version $ARGUMENTS for completeness and correctness. Check: version consistency, conventional commits, build/test status, GitHub Actions configuration, package registry readiness. Return: critical issues, warnings, info, overall readiness status.")

- Receive validation report with critical issues, warnings, info, and overall readiness
- If critical issues found: Display report, exit with error message and fix guidance
- If warnings found: Display report, continue to approval (stakeholders decide)
- Display validation summary

## Phase 3: Collect Technical Lead Approval

Request approval from technical lead:

Actions:
- Display validation summary, version details (number, commits, features/fixes/breaking changes, build/test status)
- Ask: "Technical Lead: Approve release v<version> for production?"
- Options: Approve (ready), Approve with conditions (minor issues), Reject (technical issues)
- If rejected: Document reason, exit with error and guidance
- Store: technical_lead_approval

## Phase 4: Collect Product Owner Approval

Request approval from product owner:

Actions:
- Display feature summary (new features, bug fixes, breaking changes, documentation)
- Ask: "Product Owner: Approve release v<version> for production?"
- Options: Approve (meets requirements), Approve with conditions (needs docs), Reject (incomplete)
- If rejected: Document reason, exit with error and guidance
- Store: product_owner_approval

## Phase 5: Collect QA Approval

Request approval from QA lead:

Actions:
- Display test summary (unit/integration/e2e pass rates, known issues, coverage metrics)
- Ask: "QA Lead: Approve release v<version> for production?"
- Options: Approve (all passed), Approve with conditions (minor bugs ok), Reject (critical bugs)
- If rejected: Document reason, exit with error and guidance
- Store: qa_approval

## Phase 6: Document Approval Decisions

Create approval record for audit trail:

Actions:
- Create `.github/releases/approvals/` directory if not exists
- Generate approval JSON with version, timestamp, all approval statuses and notes, validation summary
- Write to `.github/releases/approvals/v<version>.json`
- Commit approval record: `git add .github/releases/approvals/v<version>.json && git commit -m "docs(release): approval record for v<version>"`

## Phase 7: Final Release Decision

Determine final go/no-go decision:

Actions:
- Evaluate approval status: All approved → APPROVED, Any conditional → APPROVED WITH CONDITIONS, Any rejected → REJECTED
- Display approval summary with all stakeholder decisions, validation results, and final decision
- If APPROVED or APPROVED WITH CONDITIONS:
  - Show push instructions: `git push --tags`
  - Show monitoring commands: `gh run list --workflow=version-management.yml`
  - List conditions to monitor if applicable
- If REJECTED:
  - Show rejection reasons from stakeholders
  - Provide guidance on addressing issues
  - Show re-approval command: `/versioning:approve-release <version>`
- Display approval record location: `.github/releases/approvals/v<version>.json`
- Exit with status: 0 for approved, 1 for rejected

## Error Handling

Handle failures gracefully:

- VERSION file missing → Exit with "Run /versioning:setup first"
- Git tag doesn't exist → Exit with "Run /versioning:bump <type> first"
- Validation fails → Display issues and exit
- Any approval rejected → Document and exit with guidance
- Git operations fail → Display error and rollback changes

Display error context and suggested fixes for each error type.

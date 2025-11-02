# Complete Sync Workflow Example

This document demonstrates a complete workflow for syncing specifications with implementation using the sync-patterns skill.

## Scenario

You've been working on implementing features for several weeks. Your specs directory contains multiple specification files, some completed, some in-progress, and some not yet started. You need to:

1. Understand current sync status
2. Identify completed work not marked in specs
3. Update spec status markers
4. Generate a comprehensive report

## Step-by-Step Workflow

### Step 1: Initial Assessment

First, compare one specification against the codebase to understand sync status:

```bash
bash plugins/iterate/skills/sync-patterns/scripts/compare-specs-vs-code.sh \
  specs/authentication.md \
  src/
```

**Example Output:**
```
=== Spec vs Code Comparison ===

Spec File: specs/authentication.md
Code Directory: src/

Summary:
  Total Requirements: 8
  Implemented: 6
  Pending: 2
  Coverage: 75%

=== Implemented Features ===
  ✓ User login with email and password
  ✓ Password hashing with bcrypt
  ✓ JWT token generation
  ✓ Token validation middleware
  ✓ Logout functionality
  ✓ Session management

=== Pending Features ===
  ○ Multi-factor authentication
  ○ OAuth integration with Google

⚠ Moderate coverage - some features pending
```

**Interpretation:**
- 75% of authentication features are implemented
- 6 out of 8 requirements have code evidence
- 2 features still need implementation
- Time to update the spec to reflect this progress

---

### Step 2: Find Unmarked Completed Tasks

Scan all specs to find tasks that are complete in code but not marked in specs:

```bash
bash plugins/iterate/skills/sync-patterns/scripts/find-completed-tasks.sh \
  specs/ \
  src/ \
  --verbose
```

**Example Output:**
```
=== Find Completed Tasks ===

Spec Directory: specs/
Code Directory: src/

Summary:
  Total Incomplete Tasks: 23
  Likely Completed: 7
  Min Evidence Score: 2

=== Tasks That Appear Completed ===

  ✓ Implement password reset flow
    Spec: specs/authentication.md
    Evidence Score: 4/5 (test implementation config docs)
    Found in:
      - src/auth/reset-password.ts
      - tests/auth/reset-password.test.ts
      - config/email-templates.json

  ✓ Add rate limiting to API endpoints
    Spec: specs/api.md
    Evidence Score: 3/5 (implementation config)
    Found in:
      - src/middleware/rate-limit.ts
      - config/rate-limits.json

  ✓ Create database migration for users table
    Spec: specs/database.md
    Evidence Score: 4/5 (implementation config docs)
    Found in:
      - migrations/001_create_users.sql
      - migrations/001_rollback.sql
      - docs/database-schema.md

... (4 more tasks)

=== Recommended Actions ===
  1. Review the tasks listed above
  2. Verify they are actually complete
  3. Update spec files to mark tasks as complete:
     Change: - [ ] Task
     To:     - [x] Task
```

**Interpretation:**
- 7 tasks are completed but not marked in specs
- Each has strong evidence (tests, implementation, configs)
- These need to be updated in spec files

---

### Step 3: Update Spec Status

For completed specifications, update the status:

```bash
bash plugins/iterate/skills/sync-patterns/scripts/update-spec-status.sh \
  specs/authentication.md \
  complete \
  --user="sync-analyzer"
```

**Example Output:**
```
✓ Successfully updated spec status

File: specs/authentication.md
Old Status: in-progress
New Status: complete
Updated By: sync-analyzer
Timestamp: 2025-11-02T18:45:00Z

Backup created: specs/authentication.md.bak
```

**What Changed in the File:**

Before:
```markdown
---
title: Authentication Feature
created: 2025-10-15
---

# Authentication Feature
```

After:
```markdown
---
title: Authentication Feature
created: 2025-10-15
status: complete
last_updated: 2025-11-02T18:45:00Z
updated_by: sync-analyzer
status_history:
  - status: complete, date: 2025-11-02T18:45:00Z, by: sync-analyzer
---

# Authentication Feature
```

---

### Step 4: Mark Individual Tasks Complete

For tasks within specs that are complete, manually update the checkboxes:

**Before:**
```markdown
## Requirements

- [ ] User login with email and password
- [ ] Password hashing with bcrypt
- [ ] JWT token generation
- [ ] Multi-factor authentication
```

**After:**
```markdown
## Requirements

- [x] User login with email and password
- [x] Password hashing with bcrypt
- [x] JWT token generation
- [ ] Multi-factor authentication
```

Or use a script to bulk update (custom implementation):

```bash
# Example: Mark specific task as complete
sed -i 's/- \[ \] User login with email/- [x] User login with email/' specs/authentication.md
```

---

### Step 5: Generate Comprehensive Report

Create a full sync report for the entire project:

```bash
bash plugins/iterate/skills/sync-patterns/scripts/generate-sync-report.sh \
  specs/ \
  sync-report-$(date +%Y-%m-%d).md \
  --code-dir=src/ \
  --include-files
```

**Generated Report (sync-report-2025-11-02.md):**

```markdown
# Sync Report: MyProject

**Generated:** 2025-11-02 18:50:00 UTC

## Summary

- **Total Specifications:** 12
- **Total Tasks:** 87
- **Completed:** 65 (75%)
- **In Progress:** 15
- **Pending:** 7

## Sync Status

```
Progress: [█████████████████████████.........................] 75%
```

## Completed Specifications

| Specification | Status |
|---------------|--------|
| Authentication | ✓ Complete |
| Database Schema | ✓ Complete |
| API Endpoints | ✓ Complete |
| User Management | ✓ Complete |

## In Progress

| Specification | Progress |
|---------------|----------|
| Payment Integration | 60% (6/10 tasks) |
| Notification System | 50% (5/10 tasks) |
| Admin Dashboard | 40% (4/10 tasks) |

## Pending

| Specification | Status |
|---------------|--------|
| Analytics Dashboard | Not started (0/8 tasks) |
| Email Templates | Not started (0/5 tasks) |

## Recommendations

⚠ Moderate sync status. Review in-progress items and complete them.

Priority actions:
1. Complete Payment Integration (4 tasks remaining)
2. Finish Notification System (5 tasks remaining)
3. Update Admin Dashboard documentation
```

---

### Step 6: Review and Share Report

**Actions after report generation:**

1. **Review discrepancies**
   - Check items marked complete but missing code
   - Check implemented features missing from specs

2. **Share with team**
   - Add to project README
   - Include in pull request
   - Present in status meeting

3. **Plan next steps**
   - Prioritize remaining work
   - Schedule next sync review
   - Update roadmap

---

## Automated Workflow (CI/CD Integration)

For continuous syncing, integrate into CI/CD pipeline:

```yaml
# .github/workflows/sync-check.yml
name: Spec Sync Check

on:
  pull_request:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9am

jobs:
  sync-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Find completed tasks
        run: |
          bash plugins/iterate/skills/sync-patterns/scripts/find-completed-tasks.sh \
            specs/ src/ --json > completed-tasks.json

      - name: Generate sync report
        run: |
          bash plugins/iterate/skills/sync-patterns/scripts/generate-sync-report.sh \
            specs/ sync-report.md --code-dir=src/

      - name: Post report as comment
        uses: actions/upload-artifact@v2
        with:
          name: sync-report
          path: sync-report.md
```

---

## Best Practices

### Regular Sync Schedule

**Recommended frequency:**
- **Daily:** For active features under development
- **Weekly:** For stable projects with moderate changes
- **Sprint/Release:** Before major milestones

### Update Discipline

**When to update specs:**
- ✓ Immediately after completing a feature
- ✓ Before creating a pull request
- ✓ During code review
- ✓ After merging significant changes

**What to update:**
- Mark completed tasks: `- [ ]` → `- [x]`
- Update spec status frontmatter
- Add implementation notes
- Document any deviations from original spec

### Team Workflow

**Assign sync responsibilities:**
- Developer: Update specs when completing features
- Tech Lead: Weekly sync review
- PM: Monthly comprehensive sync and planning

---

## Troubleshooting

### Issue: Script reports false positives

**Problem:** Tasks marked as complete but aren't actually done

**Solution:**
- Increase minimum evidence score: `--min-evidence 3`
- Review code manually before marking complete
- Ensure tests are comprehensive

### Issue: Can't find implementation

**Problem:** Feature is implemented but script doesn't find it

**Solution:**
- Check if keywords match between spec and code
- Ensure code uses meaningful names related to spec
- Manually verify and mark as complete

### Issue: Specs out of date

**Problem:** Many specs don't reflect current implementation

**Solution:**
1. Run `find-completed-tasks.sh` to identify completed work
2. Bulk update completed tasks
3. Review each spec individually
4. Consider archiving outdated specs

---

## Next Steps

After completing this workflow:

1. **Commit updated specs**
   ```bash
   git add specs/
   git commit -m "docs: Update spec sync status"
   git push
   ```

2. **Share sync report** with team

3. **Schedule next sync** (add to calendar)

4. **Plan work based on report** (prioritize pending items)

---

*This workflow ensures specifications stay synchronized with implementation, providing accurate project status and reducing documentation debt.*

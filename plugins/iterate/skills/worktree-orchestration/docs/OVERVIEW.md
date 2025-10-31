# Supervisor System Overview

The supervisor system provides agent monitoring and quality gates for multi-spec development.

## Purpose

Monitor agent progress, ensure compliance with specifications, and validate readiness for PR submission.

## Commands

- `/supervisor:start` - Pre-work verification (worktree setup, task assignments)
- `/supervisor:mid` - Mid-work progress monitoring (task completion, compliance)
- `/supervisor:end` - Pre-PR completion checks (all tasks done, tests pass)

## Workflow

```bash
# Before starting work
/supervisor:start 001

# During development (periodic checks)
/supervisor:mid 001

# Before creating PR
/supervisor:end 001
```

## Reports

All supervisor checks generate reports in `specs/XXX/reports/`:
- `supervisor-start-report.md`
- `supervisor-mid-report.md`
- `supervisor-end-report.md`

## Multi-Spec Support

All commands support multi-spec operations:

```bash
/supervisor:start --all              # Check all specs
/supervisor:mid 001,002,003         # Check specific specs
/supervisor:end --all               # Verify all complete
```

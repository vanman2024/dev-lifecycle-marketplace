---
description: Generate GitHub Actions workflow for test suites, avoiding duplication with existing CI pipelines
argument-hint: "[--force]"
---

---
**EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- The phases below are YOUR execution checklist
- YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- Complete ALL phases before considering this command done
- DON'T wait for "the command to complete" - YOU complete it by executing the phases
- DON'T treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 1, then Phase 2, etc.**

---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets in workflow files
- Use GitHub Secrets for sensitive values (${{ secrets.NAME }})
- Use environment variables for configuration

**Arguments**: $ARGUMENTS

Goal: Generate a GitHub Actions workflow that runs all detected test types, avoiding duplication with existing CI pipelines.

## Phase 1: Discovery

Goal: Read testing configuration and scan existing CI.

Actions:
- Read project testing config:
  @.claude/project.json

- If no `testing` key exists, invoke `test-framework-detector` agent first.

- Scan existing CI workflows:
  !{Glob .github/workflows/*.yml}
  !{Glob .github/workflows/*.yaml}

- For each existing workflow, check what test types it covers:
  - Does it run unit tests?
  - Does it run E2E tests?
  - Does it run API tests?
  - Does it run smoke tests?
  - Does it upload coverage?

Display discovery:
```
Existing CI Workflows
=====================
{workflow-name}.yml:
  - Unit tests: YES/NO
  - E2E tests: YES/NO
  - API tests: YES/NO
  - Coverage: YES/NO
```

## Phase 2: Gap Analysis

Goal: Determine which test types need CI coverage.

Actions:
- Compare detected test types (from project.json) against CI coverage
- Identify gaps: test types configured but not in CI
- If $ARGUMENTS contains `--force`, regenerate everything regardless of gaps

Display gap analysis:
```
CI Gap Analysis
===============
Test Type         Configured    In CI    Gap?
Unit              vitest        YES      -
Smoke             /api/health   NO       MISSING
API Contract      newman        NO       MISSING
E2E               playwright    YES      -
Coverage          v8            YES      -
```

## Phase 3: Generate Workflow

Goal: Create GitHub Actions workflow for missing test types.

Actions:
- Generate `.github/workflows/test-suite.yml` covering ONLY missing test types
- If `--force` flag, generate comprehensive workflow covering ALL types
- Use test commands from project.json testing key

Workflow structure:
```yaml
name: Test Suite

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  # Only include jobs for gaps
  unit-tests:    # if unit tests not in existing CI
  smoke-tests:   # if smoke tests not in existing CI
  api-tests:     # if API tests not in existing CI
  e2e-tests:     # if E2E tests not in existing CI
```

For each job, include:
- Proper Node/Python/Go setup
- Dependency installation
- Test execution using detected command
- Result artifact upload
- Coverage reporting (if applicable)

Important:
- Use `${{ secrets.* }}` for all sensitive values
- Add proper caching for dependencies
- Set timeouts to prevent hung jobs
- Use matrix strategy for multi-version testing if applicable

## Phase 4: Update Project Config

Goal: Update project.json with new CI workflow reference.

Actions:
- Add the new workflow path to `testing.ci_workflows` in project.json
- Do NOT remove existing workflow references

## Phase 5: Summary

Goal: Report what was generated.

Actions:
- Display generated workflow location and content summary
- List jobs included and why each was needed
- Note any existing workflows that were preserved

```
CI Workflow Generated
=====================
File: .github/workflows/test-suite.yml

Jobs Added:
  - smoke-tests: Health check + critical paths (was missing from CI)
  - api-contract-tests: Newman collection execution (was missing from CI)

Preserved Existing:
  - .github/workflows/test.yml (unit tests + E2E)

Next Steps:
  - Review: cat .github/workflows/test-suite.yml
  - Commit: git add .github/workflows/test-suite.yml
  - Push to trigger: git push
```

---
description: Run comprehensive test suite with auto-detection across unit, smoke, API contract, and E2E testing
argument-hint: [unit|smoke|api|e2e|all]
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

**Arguments**: $ARGUMENTS

Goal: Execute comprehensive testing across all layers with auto-detected frameworks and CI-awareness.

## Available Skills

- **test-framework-detection**: Detect test frameworks across all languages
- **newman-runner**: Run and analyze Newman API tests
- **playwright-e2e**: Playwright E2E testing patterns
- **smoke-testing**: Health endpoint and critical path testing
- **frontend-testing**: Frontend component/visual/a11y testing
- **api-contract-testing**: OpenAPI to Newman pipeline with auth injection

## Phase 1: Discovery

Goal: Read testing configuration and detect frameworks if needed.

Actions:
- Read project testing config:
  @.claude/project.json

- **If no `testing` key exists**: Invoke `test-framework-detector` agent to auto-detect:

  Launch the test-framework-detector agent to analyze the project and populate testing configuration.

  Provide the agent with:
  - Project path: current directory
  - Requirements: Detect all test frameworks, CI workflows, coverage tools, auth strategy
  - Deliverable: Updated `.claude/project.json` with `testing` key

  Wait for detection to complete, then re-read `.claude/project.json`.

- **If `testing` key exists**: Use existing configuration.

- Determine test scope from arguments:
  - Empty or "all": Run all configured test types
  - "unit": Unit tests only
  - "smoke": Smoke tests only
  - "api": API contract tests only (Newman)
  - "e2e": E2E tests only (Playwright)

Display discovery results:
```
Testing Configuration
=====================
Unit:     {framework} ({config})
Smoke:    {health_endpoint}
API:      {framework} ({collection_count} collections)
E2E:      {framework} ({config})
Coverage: {tool} (threshold: {threshold}%)
CI:       {workflow_count} workflows detected
Scope:    {requested_scope}
```

## Phase 2: Analysis

Goal: Analyze what will be tested and display plan.

Actions:
- For each test type in scope, verify prerequisites:
  - Unit: Test command exists and framework is installed
  - Smoke: Health endpoint is reachable or server needs starting
  - API: Newman installed and collections exist
  - E2E: Playwright installed and configured
- Check CI coverage: Note which test types are already running in CI
- Count available tests by type
- Create test-results directory:
  !{bash mkdir -p test-results}

Display analysis:
```
Test Execution Plan
===================
Will run:
  - Unit tests ({count} test files)
  - Smoke tests ({endpoint_count} endpoints)
  - API contract tests ({collection_count} collections)
  - E2E tests ({spec_count} specs)

CI Coverage:
  - Unit tests: covered by {workflow}
  - E2E tests: covered by {workflow}
  - API tests: NOT in CI (consider /testing:generate-ci)
```

## Phase 3: Execution

Goal: Invoke test-runner agent to execute all tests.

Actions:

Launch the test-runner agent to execute the test suite.

Provide the agent with:
- Scope: Test type from arguments ($ARGUMENTS), default "all"
- Testing config: The `testing` key from `.claude/project.json`
- Requirements:
  - Execute tests in pyramid order: unit -> smoke -> API -> E2E
  - Aggregate results to `test-results/summary.json`
  - Report failures with file/line references
  - Include coverage data if available
  - Note LLM eval recommendation if `ai_detected` is true
- Deliverables:
  - `test-results/summary.json` (aggregated results)
  - Individual reports per test type
  - Clear pass/fail status per type

## Phase 4: Reporting

Goal: Display comprehensive results from test execution.

Actions:
- Read `test-results/summary.json`
- Display results by type:
  ```
  Test Results
  ============

  Unit Tests:         {passed}/{total} passed    {duration}
  Smoke Tests:        {passed}/{total} passed    {duration}
  API Contract Tests: {passed}/{total} passed    {duration}
  E2E Tests:          {passed}/{total} passed    {duration}

  Overall: {total_passed}/{total_tests} ({pass_rate}%)
  Coverage: {coverage}% (threshold: {threshold}%)
  ```
- If any tests failed, show failure details
- If `ai_detected`, show LLM eval reminder

## Phase 5: Summary

Goal: Report final status and next steps.

Actions:
- Display overall status (PASS/FAIL)
- If PASS:
  ```
  All tests passed. Ready for deployment.
  Next steps:
    - Review coverage report: test-results/summary.json
    - Deploy: /deployment:deploy
  ```
- If FAIL:
  ```
  {failed_count} tests failed. Fix before proceeding.
  Next steps:
    - Fix unit failures: {test_command} --watch
    - Fix E2E failures: npx playwright test --ui
    - Re-run: /testing:test
  ```
- If no CI coverage for some test types:
  ```
  Missing CI coverage:
    - {test_type}: Run /testing:generate-ci to add to pipeline
  ```
- If AI detected:
  ```
  AI Framework Detected:
    - Unit/E2E tests cover deterministic behavior
    - For LLM output testing: /llm-evals:add promptfoo
  ```

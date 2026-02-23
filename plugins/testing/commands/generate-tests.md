---
description: Generate test suites automatically by detecting project stack and analyzing source code
argument-hint: "[project-path] [--type unit|e2e|api|all]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Task"]
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

Goal: Auto-detect the project's language and test framework, then generate comprehensive test suites using the appropriate generator agent.

## Phase 1: Discovery

Goal: Detect project stack and testing configuration.

Actions:
- Read project testing config:
  @.claude/project.json

- If no `testing` key exists, invoke `test-framework-detector` agent:

  Launch the test-framework-detector agent to auto-detect testing infrastructure.

  Wait for detection to complete, then re-read `.claude/project.json`.

- Parse arguments for:
  - Project path (default: current directory)
  - Test type filter: `--type unit`, `--type e2e`, `--type api`, or `--type all` (default)

- Detect primary language from project.json or by scanning:
  !{Glob **/*.{ts,tsx,js,jsx}}
  !{Glob **/*.py}
  !{Glob **/*.go}
  !{Glob **/*.rs}

- Check for existing test files:
  !{Glob **/*.test.{ts,tsx,js,jsx}}
  !{Glob **/*.spec.{ts,tsx,js,jsx}}
  !{Glob **/test_*.py}
  !{Glob **/*_test.go}

Display discovery:
```
Project Analysis
================
Language:       {language}
Framework:      {framework}
Test Framework: {test_framework}
Existing Tests: {test_count} files
Source Files:   {source_count} files
Coverage Gap:   ~{gap_percent}% uncovered
```

## Phase 2: Route to Generator

Goal: Route to the correct test generator agent based on detected stack.

Actions:
- Determine which generator agent to use:

  **Frontend React/Next.js** (detected via `next`, `react` in deps):
  -> `frontend-test-generator` agent
  -> Generates: component tests, visual regression, a11y, performance

  **General Node.js/TypeScript** (detected via `vitest`, `jest` without React frontend):
  -> `test-suite-generator` agent
  -> Generates: unit tests, integration tests, mock setup

  **Python/Go/Rust** (detected via pyproject.toml, go.mod, Cargo.toml):
  -> `test-generator` agent
  -> Generates: unit tests, integration tests per language conventions

  **Mixed/Monorepo** (multiple languages detected):
  -> Run multiple generators for each language stack

- Launch the selected agent(s):

  Provide the agent with:
  - Project path from arguments
  - Detected testing framework and config
  - Source files to generate tests for
  - Existing test files (to avoid duplication)
  - Coverage target from project.json (default: 80%)
  - Requirements:
    - Generate tests for all uncovered source files
    - Follow detected framework conventions
    - Create proper mocks for dependencies
    - Use Arrange-Act-Assert pattern
  - Deliverables:
    - Generated test files in correct locations
    - Updated test configuration if needed
    - Summary of generated tests

## Phase 3: Verification

Goal: Run generated tests to verify they pass.

Actions:
- Get test command from project.json: `testing.unit.command`
- Run tests:
  !{bash ${test_command}}

- If tests fail:
  - Analyze failures
  - Fix obvious issues (missing imports, mock setup)
  - Re-run until passing or report remaining issues

- Check coverage if available:
  !{bash ${test_command} -- --coverage}

Display verification:
```
Test Verification
=================
Tests Run:    {total}
Passed:       {passed}
Failed:       {failed}
Coverage:     {percent}% (target: {threshold}%)
```

## Phase 4: Summary

Goal: Report what was generated and next steps.

Actions:
- Display results:
```
Test Generation Complete
========================
Generator Used: {agent_name}
Files Created:  {file_count}
Tests Added:    {test_count}
Coverage:       {before}% -> {after}%

Files:
  {list of created test files}

Next Steps:
  - Review generated tests: {test_directory}
  - Run full suite: /testing:test
  - Add custom scenarios as needed
  - Generate CI pipeline: /testing:generate-ci
```

- If `ai_detected` in project.json:
```
AI Framework Detected:
  Generated tests cover deterministic behavior.
  For LLM output evaluation: /llm-evals:add promptfoo
```

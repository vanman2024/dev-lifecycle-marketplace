---
description: Execute comprehensive frontend testing workflow with component tests (Jest/Vitest + RTL), visual regression (Playwright), accessibility (axe-core), and performance (Lighthouse) tests
argument-hint: [project-path] [--setup-only|--test-only|--validate-only]
---

**Arguments**: $ARGUMENTS

Goal: Run comprehensive frontend testing workflow with support for setup, execution, and validation phases.

## Phase 1: Parse Arguments and Determine Mode

Actions:
- Parse $ARGUMENTS to extract:
  - Project path (default: current directory)
  - Phase flags: --setup-only, --test-only, --validate-only
  - If no flags: run all phases

Store as variables:
- $PROJECT_PATH: Project directory
- $PHASE: "setup", "test", "validate", or "all"

## Phase 2: Discovery

Goal: Detect project setup and existing tests

Actions:
- Change to project directory: `cd $PROJECT_PATH`
- Detect testing framework:
  ```bash
  if grep -q '"jest"' package.json; then
    TEST_FRAMEWORK="jest"
  elif grep -q '"vitest"' package.json; then
    TEST_FRAMEWORK="vitest"
  else
    TEST_FRAMEWORK="none"
  fi
  ```
- Check for existing test infrastructure:
  - Component test config (jest.config.js or vitest.config.ts)
  - Playwright config (playwright.visual.config.ts, playwright.a11y.config.ts)
  - Test directories (tests/unit, tests/visual, tests/a11y, tests/performance)
- Count existing tests by type:
  ```bash
  COMPONENT_TESTS=$(find . -name "*.spec.tsx" -o -name "*.test.tsx" | wc -l)
  VISUAL_TESTS=$(find tests/visual -name "*.spec.ts" 2>/dev/null | wc -l)
  A11Y_TESTS=$(find tests/a11y -name "*.spec.ts" 2>/dev/null | wc -l)
  PERF_TESTS=$(find tests/performance -name "*.spec.ts" 2>/dev/null | wc -l)
  ```

Display discovery results:
```
📊 Frontend Test Discovery
  Project: $PROJECT_PATH
  Framework: $TEST_FRAMEWORK
  Existing Tests:
    - Component: $COMPONENT_TESTS
    - Visual: $VISUAL_TESTS
    - Accessibility: $A11Y_TESTS
    - Performance: $PERF_TESTS
```

## Phase 3: Setup (if needed)

**Skip if:** $PHASE is "test" or "validate"

Goal: Initialize frontend testing infrastructure

Actions:
- If TEST_FRAMEWORK is "none" or test infrastructure is incomplete:
  - Run init script from frontend-testing skill:
    ```bash
    bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/testing/skills/frontend-testing/scripts/init-frontend-tests.sh $PROJECT_PATH
    ```
  - This installs:
    - Testing framework (Jest or Vitest)
    - React Testing Library
    - Playwright for visual/a11y
    - Lighthouse for performance
    - Test configuration files
    - Test utilities and helpers

- Verify setup completed successfully:
  ```bash
  test -f jest.config.js || test -f vitest.config.ts
  test -f playwright.visual.config.ts
  test -f playwright.a11y.config.ts
  ```

Display setup results:
```
✅ Frontend Testing Infrastructure Initialized
  - Testing framework: $TEST_FRAMEWORK
  - React Testing Library: installed
  - Playwright: installed
  - Configuration files: created
  - Test utilities: created
```

**Exit if:** $PHASE is "setup"

## Phase 4: Test Generation

**Skip if:** $PHASE is "validate"

Goal: Generate missing tests using frontend-test-generator agent

Actions:
- Identify components and pages without tests:
  ```bash
  # Find all React components
  find src -name "*.tsx" -o -name "*.jsx" | grep -v ".test." | grep -v ".spec."

  # Check which lack tests
  for component in $COMPONENTS; do
    test_file="${component%.tsx}.spec.tsx"
    if [ ! -f "$test_file" ]; then
      echo "Missing test: $component"
    fi
  done
  ```

- Invoke frontend-test-generator agent to create tests:

  Launch the frontend-test-generator agent to generate comprehensive test suites.

  Provide the agent with:
  - Project path: $PROJECT_PATH
  - Test types to generate: component, visual, accessibility, performance
  - Coverage threshold: 80%
  - Components without tests: [list from above]
  - Requirements:
    - Generate component tests for all untested components
    - Generate visual regression tests for all pages
    - Generate accessibility tests for interactive components
    - Generate performance tests for critical pages
    - Use frontend-testing skill templates
    - Save tests in correct directory structure
  - Deliverables:
    - Component tests in tests/unit/
    - Visual tests in tests/visual/
    - Accessibility tests in tests/a11y/
    - Performance tests in tests/performance/
    - JSON summary with tests_generated count and files_created list

Use Task tool to invoke agent:
```
Task(
  description="Generate frontend tests",
  subagent_type="testing:frontend-test-generator",
  prompt="Generate comprehensive frontend test suites for project at $PROJECT_PATH.

  Test types: component, visual, accessibility, performance
  Coverage target: 80%

  Review existing components and pages, identify untested areas, and generate:
  1. Component tests (Jest/Vitest + RTL) for all components
  2. Visual regression tests (Playwright) for all pages
  3. Accessibility tests (axe-core) for interactive components
  4. Performance tests (Lighthouse) for critical pages

  Use templates from Skill(testing:frontend-testing).

  Return JSON summary with tests_generated counts and files_created list."
)
```

Wait for agent to complete and parse JSON response.

Display generation results:
```
🎨 Frontend Tests Generated
  Component tests: $COMPONENT_COUNT
  Visual tests: $VISUAL_COUNT
  Accessibility tests: $A11Y_COUNT
  Performance tests: $PERF_COUNT

  Files created: $FILE_COUNT total
```

## Phase 5: Test Execution

**Skip if:** $PHASE is "setup" or "validate"

Goal: Run all frontend tests

Actions:
- **Run component tests:**
  ```bash
  bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/testing/skills/frontend-testing/scripts/run-component-tests.sh
  ```
  - Captures exit code
  - Stores results in test-results/component/

- **Run visual regression tests:**
  ```bash
  bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/testing/skills/frontend-testing/scripts/run-visual-regression.sh
  ```
  - Captures exit code
  - Stores results in test-results/visual/

- **Run accessibility tests:**
  ```bash
  bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/testing/skills/frontend-testing/scripts/run-accessibility-tests.sh
  ```
  - Captures exit code
  - Stores results in test-results/a11y/

- **Run performance tests:**
  ```bash
  bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/testing/skills/frontend-testing/scripts/run-performance-tests.sh http://localhost:3000
  ```
  - Captures exit code
  - Stores results in test-results/performance/

Aggregate results:
```
TOTAL_TESTS=$((COMPONENT_PASSED + VISUAL_PASSED + A11Y_PASSED + PERF_PASSED))
TOTAL_FAILED=$((COMPONENT_FAILED + VISUAL_FAILED + A11Y_FAILED + PERF_FAILED))
```

Display execution results:
```
🧪 Frontend Test Execution Complete

Component Tests:
  ✅ Passed: $COMPONENT_PASSED
  ❌ Failed: $COMPONENT_FAILED

Visual Regression:
  ✅ Passed: $VISUAL_PASSED
  ❌ Failed: $VISUAL_FAILED

Accessibility:
  ✅ Passed: $A11Y_PASSED
  ❌ Failed: $A11Y_FAILED

Performance:
  ✅ Passed: $PERF_PASSED
  ❌ Failed: $PERF_FAILED

Overall: $TOTAL_TESTS passed, $TOTAL_FAILED failed
```

**Exit if:** $PHASE is "test"

## Phase 6: Validation and Coverage Analysis

Goal: Analyze test coverage and quality

Actions:
- Generate comprehensive coverage report:
  ```bash
  bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/testing/skills/frontend-testing/scripts/generate-coverage-report.sh test-results/coverage
  ```
  - Aggregates coverage from all test types
  - Generates HTML report
  - Creates summary.md

- Read coverage summary:
  ```bash
  cat test-results/coverage/summary.md
  ```

- Identify gaps:
  - Components without tests
  - Pages without visual regression
  - Components without accessibility tests
  - Pages without performance tests

- Check coverage thresholds:
  - Component coverage >= 80%
  - Critical pages have visual tests
  - Interactive components have a11y tests
  - Critical pages have performance tests

Display validation results:
```
📊 Coverage Analysis

Component Coverage: $COVERAGE_PERCENT% (target: 80%)
Visual Coverage: $VISUAL_PAGES/$TOTAL_PAGES pages tested
Accessibility Coverage: $A11Y_COMPONENTS/$INTERACTIVE_COMPONENTS components tested
Performance Coverage: $PERF_PAGES/$CRITICAL_PAGES pages tested

Gaps Identified:
  - Untested components: [list]
  - Pages needing visual tests: [list]
  - Components needing a11y tests: [list]
  - Pages needing performance tests: [list]
```

## Phase 7: Summary and Next Steps

Actions:
- Display comprehensive summary:
  ```
  ✅ Frontend Testing Workflow Complete

  Phase Results:
    ✅ Setup: Infrastructure initialized
    ✅ Generation: $TESTS_GENERATED tests created
    ✅ Execution: $TOTAL_TESTS tests run
    ✅ Validation: Coverage analyzed

  Test Results:
    Component: $COMPONENT_PASSED/$COMPONENT_TOTAL passed
    Visual: $VISUAL_PASSED/$VISUAL_TOTAL passed
    Accessibility: $A11Y_PASSED/$A11Y_TOTAL passed
    Performance: $PERF_PASSED/$PERF_TOTAL passed

  Coverage:
    Component: $COVERAGE_PERCENT%
    Visual: $VISUAL_PAGES pages
    Accessibility: $A11Y_COMPONENTS components
    Performance: $PERF_PAGES pages

  Reports Generated:
    📁 test-results/component/index.html
    📁 test-results/visual/
    📁 test-results/a11y/
    📁 test-results/performance/
    📄 test-results/coverage/summary.md
  ```

- Provide next steps based on results:
  - If tests failed: "Fix failing tests before proceeding"
  - If coverage low: "Generate tests for untested areas"
  - If all passed: "Ready to commit tests to repository"

- Suggest follow-up commands:
  ```
  Next steps:
    1. Review reports: open test-results/coverage/summary.md
    2. Fix failures: npm test -- --watch
    3. Update snapshots: npm run test:visual -- --update-snapshots
    4. Commit tests: git add tests/ && git commit -m "test: Add frontend tests"
  ```

**Exit status:**
- 0 if all tests passed
- 1 if any tests failed
- 2 if coverage below threshold

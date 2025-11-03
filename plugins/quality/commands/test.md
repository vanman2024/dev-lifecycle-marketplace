---
description: Run comprehensive test suite (Newman API, Playwright E2E, security scans)
argument-hint: [test-type]
allowed-tools: Task, Read, Bash, Glob, Grep
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

Goal: Execute comprehensive testing across all layers with standardized frameworks (Newman, Playwright, security tools)

Core Principles:
- Standardized testing (Newman for APIs, Playwright for E2E)
- DigitalOcean webhook testing ($4-6/month)
- Comprehensive coverage
- Clear failure reporting

## Phase 1: Discovery
Goal: Detect available test configurations and frameworks

Actions:
- Load project context:
  @.claude/project.json
- Check for Newman/Postman collections:
  !{bash find . -name "*.postman_collection.json" 2>/dev/null | head -5}
- Check for Playwright configuration:
  !{bash test -f playwright.config.ts -o -f playwright.config.js && echo "✅ Playwright" || echo "❌ No Playwright"}
- Check Newman installed:
  !{bash which newman &>/dev/null && echo "✅ Newman installed" || echo "❌ Install: npm install -g newman"}
- Determine test scope from arguments:
  - Empty or "all": Run all available tests
  - "api": API tests only (Newman)
  - "e2e": E2E tests only (Playwright)
  - "unit": Unit tests only
  - "security": Security scans only

## Phase 2: Analysis
Goal: Analyze test coverage and identify gaps

Actions:
- Count available tests by type:
  - Postman collections: !{bash find . -name "*.postman_collection.json" 2>/dev/null | wc -l}
  - Playwright tests: !{bash find . -name "*.spec.ts" -o -name "*.spec.js" 2>/dev/null | wc -l}
  - Unit tests: !{bash find . -name "*.test.*" 2>/dev/null | wc -l}
- Check test results directory:
  !{bash mkdir -p test-results && echo "✅ Created test-results/"}
- Identify critical paths needing tests

## Phase 3: Planning
Goal: Prepare test execution strategy

Actions:
- Determine execution order:
  1. Unit tests (fastest feedback)
  2. API tests with Newman
  3. E2E tests with Playwright
  4. Security scans
- Allocate test result files:
  - Newman: test-results/newman-results.json
  - Playwright: test-results/playwright-report/
  - Security: test-results/security-report.json
- Plan failure handling and reporting

## Phase 4: Implementation
Goal: Invoke test-generator agent to execute tests

Actions:

Launch the test-generator agent to run comprehensive test suite.

Provide the agent with:
- Context: Test type from arguments ($ARGUMENTS)
- Available frameworks detected in Phase 1
- Test execution strategy from Phase 3
- Requirements:
  - Run Newman tests if Postman collections found
  - Run Playwright tests if configured
  - Run unit tests
  - Run security scans
  - Generate detailed reports in test-results/
  - Exit with non-zero code if any tests fail
- Deliverables:
  - test-results/summary.json (aggregated results)
  - Individual test reports per framework
  - Coverage reports if available
  - Clear pass/fail status

## Phase 5: Verification
Goal: Validate test execution and results

Actions:
- Check test results created:
  !{bash test -d test-results && ls -la test-results/}
- Count passed vs failed tests:
  !{bash grep -r "passed\|✓" test-results/ 2>/dev/null | wc -l}
  !{bash grep -r "failed\|✗" test-results/ 2>/dev/null | wc -l}
- Validate all critical tests executed
- Check for test failures requiring attention

## Phase 6: Summary
Goal: Report comprehensive test results

Actions:
- Display test execution summary:
  - Total tests run: X
  - Passed: Y
  - Failed: Z
  - Coverage: N%
- Show results by test type:
  - Unit tests: Pass/Fail
  - API tests (Newman): Pass/Fail
  - E2E tests (Playwright): Pass/Fail
  - Security scans: Pass/Fail
- Provide failure details if any tests failed
- Suggest next steps:
  - "Review detailed reports in test-results/"
  - "Fix failing tests before deployment"
  - "Run /quality:security for detailed security analysis"
  - "Run /quality:performance for performance benchmarks"
- Exit with appropriate status code for CI/CD integration

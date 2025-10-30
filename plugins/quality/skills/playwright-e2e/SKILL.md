---
name: Playwright E2E Testing
description: Playwright end-to-end testing patterns including page object models, test scenarios, visual regression, and CI/CD integration. Use when building E2E tests, testing web applications, automating browser interactions, implementing page objects, running Playwright tests, debugging E2E failures, or when user mentions Playwright, E2E, browser automation, page object model, POM, visual regression, or end-to-end testing.
---

# Playwright E2E Testing

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Provides comprehensive Playwright end-to-end testing patterns including:
- Page Object Model (POM) implementation
- Test scenario scaffolding
- Visual regression testing
- CI/CD integration workflows
- Debugging techniques
- Browser automation patterns

## Instructions

### 1. Initialize Playwright Project

Use `scripts/init-playwright.sh` to set up a new Playwright project:

```bash
bash scripts/init-playwright.sh [project-path]
```

This will:
- Install Playwright dependencies
- Create playwright.config.ts from template
- Set up test directory structure
- Install browsers
- Create initial test examples

### 2. Generate Page Object Models

Use `scripts/generate-pom.sh` to create Page Object Model classes:

```bash
bash scripts/generate-pom.sh <page-name> <url> [output-dir]
```

This will:
- Create page object class with base structure
- Add common locators and methods
- Generate TypeScript interface
- Include usage examples

### 3. Run Playwright Tests

Use `scripts/run-playwright.sh` to execute tests:

```bash
bash scripts/run-playwright.sh [test-pattern] [browser] [options]
```

Options:
- Test pattern: Specific test file or glob pattern
- Browser: chromium, firefox, webkit, or all
- Options: --headed, --debug, --trace, --ui

### 4. Debug Test Failures

Use `scripts/debug-playwright.sh` for debugging:

```bash
bash scripts/debug-playwright.sh <test-file>
```

This will:
- Run test in headed mode with slowMo
- Enable trace recording
- Open Playwright Inspector
- Generate debug screenshots

### 5. Visual Regression Testing

Use `scripts/run-visual-regression.sh` for visual testing:

```bash
bash scripts/run-visual-regression.sh [test-pattern] [update-snapshots]
```

This will:
- Run visual regression tests
- Compare against baseline snapshots
- Generate diff images for failures
- Update snapshots if requested

## Available Scripts

- **init-playwright.sh**: Initialize Playwright project with configuration
- **run-playwright.sh**: Execute Playwright tests with various options
- **generate-pom.sh**: Generate Page Object Model classes
- **debug-playwright.sh**: Run tests in debug mode with inspector
- **run-visual-regression.sh**: Execute visual regression tests

## Templates

### Configuration
- **playwright.config.ts**: Comprehensive Playwright configuration with multiple browsers, reporters, and settings

### Page Objects
- **page-object-basic.ts**: Basic Page Object Model template
- **page-object-advanced.ts**: Advanced POM with complex interactions and waiting strategies

### Test Scenarios
- **e2e-test-login.spec.ts**: Login flow E2E test with authentication
- **e2e-test-form.spec.ts**: Form submission and validation test
- **visual-regression.spec.ts**: Visual regression testing example

## Examples

- **basic-usage.md**: Simple Playwright setup and first test
- **page-object-pattern.md**: Implementing Page Object Model pattern
- **visual-regression-testing.md**: Setting up visual regression tests
- **ci-cd-integration.md**: Configuring Playwright in CI/CD pipelines
- **debugging-techniques.md**: Debugging failing E2E tests

## Page Object Model Pattern

### Structure
```typescript
class PageName {
  readonly page: Page;
  readonly locators: { /* selectors */ };

  constructor(page: Page) { /* ... */ }

  async navigateTo() { /* ... */ }
  async performAction() { /* ... */ }
  async verifyState() { /* ... */ }
}
```

### Benefits
- Separation of concerns (test logic vs page structure)
- Reusability across multiple tests
- Easier maintenance when UI changes
- Clear test readability

## Best Practices

### Test Organization
- Use Page Object Model for maintainability
- Group related tests in describe blocks
- Keep tests independent and isolated
- Use beforeEach for common setup

### Selectors
- Prefer data-testid attributes
- Use accessible roles when possible
- Avoid fragile CSS selectors
- Document selector strategies

### Waiting Strategies
- Use auto-waiting (built-in)
- Explicit waits for dynamic content
- waitForLoadState for navigation
- waitForSelector for element visibility

### Visual Regression
- Create stable baseline snapshots
- Use consistent viewport sizes
- Mask dynamic content (dates, random IDs)
- Update snapshots carefully

### CI/CD Integration
- Run in headless mode
- Parallelize tests across workers
- Generate HTML reports
- Upload trace files on failure
- Cache browser binaries

## Debugging Tips

### Playwright Inspector
- Set PWDEBUG=1 environment variable
- Use page.pause() in test code
- Step through actions
- Inspect element locators

### Trace Viewer
- Enable trace: 'on-first-retry'
- View network activity
- Inspect console logs
- Review screenshots and video

### Screenshots and Videos
- Take screenshots on failure
- Record videos for flaky tests
- Use fullPage screenshots
- Compare visual differences

## Requirements

- Node.js 18+ installed
- Playwright 1.40+ recommended
- TypeScript for type safety
- Test files use .spec.ts extension
- Page objects in separate files/directories
- Clear naming conventions for tests and page objects

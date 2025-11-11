---
name: Frontend Testing
description: Comprehensive frontend testing patterns including component tests (Jest/Vitest + RTL), visual regression (Playwright), accessibility (axe-core), and performance (Lighthouse) testing for React/Next.js applications. Use when building frontend tests, testing React components, implementing visual regression, running accessibility tests, performance testing, or when user mentions component testing, visual regression, a11y testing, React Testing Library, Jest, Vitest, Lighthouse, or frontend testing.
---

# Frontend Testing

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Provides comprehensive frontend testing patterns for React/Next.js applications including:
- Component testing with Jest/Vitest + React Testing Library
- Visual regression testing with Playwright
- Accessibility testing with axe-core
- Performance testing with Lighthouse
- Test infrastructure setup and configuration
- Coverage analysis and reporting

## Security Requirements

All code examples and templates in this skill follow strict security rules:

**CRITICAL:** Reference @docs/security/SECURITY-RULES.md

- Placeholders only, never real credentials
- Environment variable references in code
- `.gitignore` protection for secrets
- Setup documentation for key acquisition

## Instructions

### 1. Initialize Frontend Test Infrastructure

Use `scripts/init-frontend-tests.sh` to set up comprehensive frontend testing:

```bash
bash scripts/init-frontend-tests.sh [project-path]
```

This will:
- Detect testing framework (Jest or Vitest)
- Install React Testing Library dependencies
- Install Playwright for visual regression
- Install axe-core for accessibility testing
- Install Lighthouse for performance testing
- Create test configuration files
- Set up test utilities and helpers
- Create initial test examples

### 2. Run Component Tests

Use `scripts/run-component-tests.sh` to execute component tests:

```bash
bash scripts/run-component-tests.sh [test-pattern] [options]
```

Options:
- Test pattern: Specific test file or glob pattern
- Options: --coverage, --watch, --updateSnapshot

This will:
- Run Jest or Vitest tests
- Execute React Testing Library tests
- Generate coverage reports
- Report pass/fail status

### 3. Run Visual Regression Tests

Use `scripts/run-visual-regression.sh` for visual testing:

```bash
bash scripts/run-visual-regression.sh [test-pattern] [update-snapshots]
```

This will:
- Run Playwright visual regression tests
- Compare against baseline snapshots
- Generate diff images for failures
- Update snapshots if requested
- Mask dynamic content automatically

### 4. Run Accessibility Tests

Use `scripts/run-accessibility-tests.sh` for a11y testing:

```bash
bash scripts/run-accessibility-tests.sh [test-pattern]
```

This will:
- Run axe-core accessibility tests via Playwright
- Check ARIA attributes
- Validate keyboard navigation
- Test color contrast
- Report WCAG violations

### 5. Run Performance Tests

Use `scripts/run-performance-tests.sh` for performance testing:

```bash
bash scripts/run-performance-tests.sh [url] [options]
```

This will:
- Run Lighthouse audits
- Check Core Web Vitals (LCP, FID, CLS)
- Analyze bundle size
- Monitor render performance
- Generate performance reports

### 6. Generate Coverage Report

Use `scripts/generate-coverage-report.sh` to aggregate coverage:

```bash
bash scripts/generate-coverage-report.sh [output-dir]
```

This will:
- Aggregate coverage from all test types
- Generate HTML coverage report
- Calculate coverage percentages
- Identify untested files
- Report coverage by test type

## Available Scripts

- **init-frontend-tests.sh**: Initialize complete frontend testing infrastructure
- **run-component-tests.sh**: Execute Jest/Vitest component tests
- **run-visual-regression.sh**: Execute Playwright visual regression tests
- **run-accessibility-tests.sh**: Execute axe-core accessibility tests
- **run-performance-tests.sh**: Execute Lighthouse performance tests
- **generate-coverage-report.sh**: Aggregate coverage data and generate reports

## Templates

### Configuration Files
- **jest.config.js**: Jest configuration for React/Next.js
- **vitest.config.ts**: Vitest configuration for React/Next.js
- **test-utils.ts**: Shared test utilities and custom renderers
- **playwright.visual.config.ts**: Playwright config for visual regression
- **playwright.a11y.config.ts**: Playwright config for accessibility testing

### Test Templates
- **component-test.spec.tsx**: Component test template with RTL
- **visual-regression.spec.ts**: Visual regression test template
- **accessibility.spec.ts**: Accessibility test template
- **performance.spec.ts**: Performance test template with Lighthouse

### Utility Templates
- **setup-tests.ts**: Test setup and global mocks
- **test-helpers.ts**: Custom test helper functions
- **mock-factories.ts**: Mock data factories

## Examples

- **button-component-test.tsx**: Real component test for Button component
- **login-page-visual.spec.ts**: Real visual regression test for login page
- **form-accessibility.spec.ts**: Real accessibility test for form components
- **homepage-performance.spec.ts**: Real performance test for homepage

## Component Testing Patterns

### React Testing Library Pattern
```typescript
import { render, screen, userEvent } from '@testing-library/react';
import { Button } from './Button';

test('renders and handles click', async () => {
  const handleClick = jest.fn();
  render(<Button onClick={handleClick}>Click me</Button>);

  const button = screen.getByRole('button', { name: /click me/i });
  await userEvent.click(button);

  expect(handleClick).toHaveBeenCalledTimes(1);
});
```

### Testing Patterns
- **Rendering**: Use render() from RTL
- **Querying**: Prefer getByRole, getByText, getByLabelText
- **User Interaction**: Use userEvent for realistic interactions
- **Assertions**: Assert on visible behavior, not implementation
- **Async**: Use waitFor for async operations

## Visual Regression Testing Patterns

### Baseline Creation
```typescript
import { test, expect } from '@playwright/test';

test('homepage visual regression', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await page.waitForLoadState('networkidle');

  // Mask dynamic content
  await page.locator('.timestamp').evaluate(el => el.style.visibility = 'hidden');

  await expect(page).toHaveScreenshot('homepage.png');
});
```

### Best Practices
- Create stable baselines
- Use consistent viewport sizes
- Mask dynamic content (dates, random IDs, animations)
- Wait for network idle
- Test critical user paths

## Accessibility Testing Patterns

### axe-core Integration
```typescript
import { test, expect } from '@playwright/test';
import { injectAxe, checkA11y } from 'axe-playwright';

test('form accessibility', async ({ page }) => {
  await page.goto('http://localhost:3000/form');
  await injectAxe(page);

  await checkA11y(page, null, {
    detailedReport: true,
    detailedReportOptions: {
      html: true
    }
  });
});
```

### WCAG Compliance
- Check ARIA attributes
- Validate keyboard navigation (Tab, Enter, Escape)
- Test screen reader compatibility
- Verify color contrast
- Ensure focus management

## Performance Testing Patterns

### Lighthouse Integration
```typescript
import { test } from '@playwright/test';
import { playAudit } from 'playwright-lighthouse';

test('homepage performance', async ({ page }) => {
  await page.goto('http://localhost:3000');

  await playAudit({
    page,
    thresholds: {
      performance: 90,
      accessibility: 90,
      'best-practices': 90,
      seo: 90,
      'first-contentful-paint': 2000,
      'largest-contentful-paint': 3000,
      'cumulative-layout-shift': 0.1,
    },
    port: 9222,
  });
});
```

### Core Web Vitals
- **LCP**: Largest Contentful Paint < 2.5s
- **FID**: First Input Delay < 100ms
- **CLS**: Cumulative Layout Shift < 0.1
- **TTFB**: Time to First Byte < 800ms

## Test Organization

### Directory Structure
```
tests/
├── unit/                    # Component unit tests
│   ├── Button.spec.tsx
│   └── Form.spec.tsx
├── integration/             # Component integration tests
│   └── AuthFlow.spec.tsx
├── visual/                  # Visual regression tests
│   ├── homepage.spec.ts
│   └── dashboard.spec.ts
├── a11y/                   # Accessibility tests
│   ├── navigation.spec.ts
│   └── forms.spec.ts
├── performance/            # Performance tests
│   └── critical-pages.spec.ts
└── utils/                  # Test utilities
    ├── test-utils.ts
    ├── mock-factories.ts
    └── test-helpers.ts
```

## Coverage Targets

### Component Tests (Jest/Vitest + RTL)
- **Target**: 80%+ code coverage
- **Focus**: Business logic, user interactions, edge cases
- **Metrics**: Lines, branches, functions, statements

### Visual Regression Tests (Playwright)
- **Target**: All pages, critical components
- **Focus**: UI stability, design system compliance
- **Metrics**: Pages tested, components tested

### Accessibility Tests (axe-core)
- **Target**: All pages, interactive components
- **Focus**: WCAG 2.1 AA compliance
- **Metrics**: Violations found, compliance score

### Performance Tests (Lighthouse)
- **Target**: All pages, critical user flows
- **Focus**: Core Web Vitals, loading performance
- **Metrics**: Performance score, web vitals

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run Frontend Tests
  run: |
    npm run test:component -- --coverage
    npm run test:visual
    npm run test:a11y
    npm run test:performance

- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/coverage-final.json
```

### Test Execution Order
1. Component tests (fastest, run first)
2. Visual regression tests
3. Accessibility tests
4. Performance tests (slowest, run last)

## Debugging Tips

### Component Test Debugging
- Use `screen.debug()` to print DOM
- Use `screen.logTestingPlaygroundURL()` for selector help
- Run with `--watch` for iterative debugging
- Use `test.only` to focus on single test

### Visual Test Debugging
- Compare diff images in test-results/
- Update snapshots carefully
- Check for timing issues (waitForLoadState)
- Verify dynamic content is masked

### Accessibility Test Debugging
- Review detailed axe reports
- Use browser DevTools accessibility panel
- Test with actual screen readers
- Check keyboard navigation manually

### Performance Test Debugging
- Review Lighthouse HTML reports
- Check network waterfall
- Analyze bundle size
- Profile render performance

## Requirements

- Node.js 18+ installed
- React 18+ or Next.js 13+
- Jest 29+ or Vitest 1.0+ for component tests
- Playwright 1.40+ for visual/a11y tests
- @axe-core/playwright for accessibility
- playwright-lighthouse for performance
- @testing-library/react for component testing
- @testing-library/user-event for interactions

## Best Practices

### Component Testing
- Test user behavior, not implementation
- Use accessible queries (getByRole, getByLabelText)
- Avoid testing implementation details
- Keep tests independent and isolated
- Mock external dependencies

### Visual Regression
- Create stable baselines
- Mask dynamic content
- Use consistent viewport sizes
- Test critical UI states
- Update snapshots intentionally

### Accessibility
- Test with keyboard only
- Check ARIA attributes
- Validate focus management
- Test with screen readers
- Follow WCAG 2.1 AA guidelines

### Performance
- Test on realistic devices/connections
- Monitor Core Web Vitals
- Check bundle sizes
- Profile render performance
- Set realistic thresholds

## Common Patterns

### Testing Forms
```typescript
test('form submission', async () => {
  render(<ContactForm />);

  await userEvent.type(screen.getByLabelText(/name/i), 'John Doe');
  await userEvent.type(screen.getByLabelText(/email/i), 'john@example.com');
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));

  expect(await screen.findByText(/success/i)).toBeInTheDocument();
});
```

### Testing Async Data
```typescript
test('loads and displays data', async () => {
  render(<UserProfile userId="123" />);

  expect(screen.getByText(/loading/i)).toBeInTheDocument();

  const userName = await screen.findByText(/john doe/i);
  expect(userName).toBeInTheDocument();
});
```

### Testing Error States
```typescript
test('displays error message', async () => {
  server.use(
    http.get('/api/user', () => {
      return HttpResponse.json({ error: 'Not found' }, { status: 404 });
    })
  );

  render(<UserProfile userId="999" />);

  expect(await screen.findByText(/error/i)).toBeInTheDocument();
});
```

## Next Steps

1. Run `init-frontend-tests.sh` to set up infrastructure
2. Generate component tests for existing components
3. Create visual regression baselines
4. Run accessibility audits
5. Set up performance monitoring
6. Integrate with CI/CD pipeline
7. Monitor coverage and quality metrics

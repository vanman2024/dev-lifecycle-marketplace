# Basic Usage - Playwright E2E Testing

This guide walks through setting up and running your first Playwright end-to-end test.

## Prerequisites

- Node.js 18 or higher
- npm or yarn package manager
- A web application to test (local or remote)

## Installation

### Option 1: New Project

```bash
# Create new directory
mkdir my-e2e-tests
cd my-e2e-tests

# Initialize project using the skill
bash /path/to/scripts/init-playwright.sh .
```

### Option 2: Existing Project

```bash
# Install Playwright
npm install -D @playwright/test

# Install browsers
npx playwright install

# Create config file
cp /path/to/templates/playwright.config.ts .
```

## Project Structure

After initialization, your project should look like:

```
my-e2e-tests/
├── playwright.config.ts       # Configuration
├── tests/
│   ├── e2e/                   # E2E test files
│   │   └── example.spec.ts
│   ├── page-objects/          # Page Object Models
│   │   └── example.page.ts
│   ├── fixtures/              # Test fixtures
│   └── utils/                 # Utility functions
├── test-results/              # Test output (gitignored)
├── playwright-report/         # HTML report (gitignored)
└── package.json
```

## Writing Your First Test

Create `tests/e2e/first.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

test.describe('My First Test Suite', () => {
  test('should load homepage', async ({ page }) => {
    // Navigate to your application
    await page.goto('https://example.com');

    // Wait for page to load
    await page.waitForLoadState('networkidle');

    // Verify title
    await expect(page).toHaveTitle(/Example/);

    // Verify heading is visible
    const heading = page.locator('h1');
    await expect(heading).toBeVisible();
    await expect(heading).toHaveText('Example Domain');
  });

  test('should click a link', async ({ page }) => {
    await page.goto('https://example.com');

    // Find and click link
    const link = page.locator('a', { hasText: 'More information' });
    await link.click();

    // Verify navigation
    await expect(page).toHaveURL(/iana.org/);
  });
});
```

## Running Tests

### Run all tests

```bash
npm run test:e2e
# or
npx playwright test
```

### Run specific test file

```bash
npx playwright test tests/e2e/first.spec.ts
```

### Run tests in specific browser

```bash
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit
```

### Run tests in UI mode (interactive)

```bash
npm run test:e2e:ui
# or
npx playwright test --ui
```

### Run tests in headed mode (visible browser)

```bash
npx playwright test --headed
```

## Understanding Test Results

### Console Output

```
Running 2 tests using 2 workers

  ✓  first.spec.ts:3:3 › My First Test Suite › should load homepage (2.1s)
  ✓  first.spec.ts:14:3 › My First Test Suite › should click a link (1.8s)

  2 passed (4.2s)
```

### HTML Report

View detailed HTML report:

```bash
npx playwright show-report
```

The report includes:
- Test execution timeline
- Screenshots on failure
- Trace files for debugging
- Network activity
- Console logs

## Common Playwright Actions

### Navigation

```typescript
// Navigate to URL
await page.goto('https://example.com');

// Go back
await page.goBack();

// Go forward
await page.goForward();

// Reload page
await page.reload();
```

### Locators

```typescript
// By test ID (recommended)
page.locator('[data-testid="submit-button"]')

// By role and name
page.getByRole('button', { name: 'Submit' })

// By text
page.locator('text=Click here')

// By CSS selector
page.locator('.my-class')

// By XPath
page.locator('xpath=//button[@type="submit"]')

// Chaining locators
page.locator('form').locator('button')
```

### Interactions

```typescript
// Click
await page.locator('button').click();

// Fill input
await page.locator('input[name="email"]').fill('test@example.com');

// Type (with delays)
await page.locator('input').type('Hello World', { delay: 100 });

// Select option
await page.locator('select').selectOption('option-value');

// Check/uncheck checkbox
await page.locator('input[type="checkbox"]').check();
await page.locator('input[type="checkbox"]').uncheck();

// Hover
await page.locator('.menu-item').hover();

// Double click
await page.locator('.file').dblclick();

// Right click
await page.locator('.item').click({ button: 'right' });
```

### Assertions

```typescript
// Element visibility
await expect(page.locator('h1')).toBeVisible();
await expect(page.locator('.loading')).toBeHidden();

// Text content
await expect(page.locator('h1')).toHaveText('Welcome');
await expect(page.locator('p')).toContainText('Hello');

// Attribute values
await expect(page.locator('input')).toHaveAttribute('type', 'email');

// CSS class
await expect(page.locator('button')).toHaveClass(/active/);

// Enabled/disabled state
await expect(page.locator('button')).toBeEnabled();
await expect(page.locator('input')).toBeDisabled();

// Count
await expect(page.locator('li')).toHaveCount(5);

// URL and title
await expect(page).toHaveURL(/dashboard/);
await expect(page).toHaveTitle('Dashboard');
```

### Waiting

```typescript
// Wait for element
await page.locator('button').waitFor({ state: 'visible' });

// Wait for navigation
await page.waitForURL('**/dashboard');

// Wait for load state
await page.waitForLoadState('networkidle');

// Wait for timeout (use sparingly)
await page.waitForTimeout(1000);

// Wait for function
await page.waitForFunction(() => window.ready === true);
```

## Best Practices

1. **Use data-testid attributes**: Most reliable selector strategy
   ```html
   <button data-testid="submit-button">Submit</button>
   ```

2. **Write independent tests**: Each test should be able to run alone

3. **Use beforeEach for setup**: Common setup in beforeEach hook

4. **Avoid hard waits**: Use Playwright's auto-waiting instead of `waitForTimeout`

5. **Keep tests focused**: One test should verify one behavior

6. **Use descriptive test names**: Clear description of what is being tested

## Next Steps

- Learn about [Page Object Pattern](./page-object-pattern.md)
- Explore [Visual Regression Testing](./visual-regression-testing.md)
- Set up [CI/CD Integration](./ci-cd-integration.md)
- Master [Debugging Techniques](./debugging-techniques.md)

## Troubleshooting

### Tests are failing

```bash
# Run in debug mode
npx playwright test --debug

# Run with trace
npx playwright test --trace on
```

### Browsers not installed

```bash
npx playwright install
```

### Flaky tests

- Add explicit waits for dynamic content
- Use `waitForLoadState('networkidle')`
- Increase timeout for slow operations
- Check for race conditions

## Resources

- [Playwright Documentation](https://playwright.dev)
- [API Reference](https://playwright.dev/docs/api/class-playwright)
- [Best Practices](https://playwright.dev/docs/best-practices)

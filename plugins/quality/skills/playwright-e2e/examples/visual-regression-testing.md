# Visual Regression Testing - Playwright E2E Testing

Visual regression testing ensures your UI looks correct by comparing screenshots against baseline images, catching unintended visual changes.

## Setup

Visual regression testing is built into Playwright - no additional packages needed!

## Running Visual Regression Tests

Use the skill's script:

```bash
# Run visual regression tests
bash scripts/run-visual-regression.sh

# Update baseline snapshots
bash scripts/run-visual-regression.sh "*visual*.spec.ts" update
```

Or run directly:

```bash
# Run tests
npx playwright test visual-regression.spec.ts

# Update snapshots
npx playwright test visual-regression.spec.ts --update-snapshots
```

## Basic Screenshot Testing

### Full Page Screenshot

```typescript
import { test, expect } from '@playwright/test';

test('homepage should look correct', async ({ page }) => {
  await page.goto('/');

  // Compare full page screenshot
  await expect(page).toHaveScreenshot('homepage.png', {
    fullPage: true,
  });
});
```

### Element Screenshot

```typescript
test('header should look correct', async ({ page }) => {
  await page.goto('/');

  const header = page.locator('header');

  // Compare specific element
  await expect(header).toHaveScreenshot('header.png');
});
```

## Snapshot Management

### First Run - Creating Baselines

When you first run visual tests, Playwright creates baseline snapshots:

```bash
npx playwright test visual-regression.spec.ts
```

Snapshots are saved to `tests/e2e/__snapshots__/`:

```
tests/e2e/__snapshots__/
└── visual-regression.spec.ts-snapshots/
    ├── homepage-chromium.png
    ├── homepage-firefox.png
    └── homepage-webkit.png
```

### Subsequent Runs - Comparing

On subsequent runs, screenshots are compared against baselines:

```
✓ homepage should look correct (chromium)
✓ homepage should look correct (firefox)
✗ homepage should look correct (webkit) - Screenshot mismatch
```

### Updating Snapshots

When visual changes are intentional:

```bash
# Update all snapshots
npx playwright test --update-snapshots

# Update specific test
npx playwright test visual-regression.spec.ts --update-snapshots

# Update using skill script
bash scripts/run-visual-regression.sh "*visual*" update
```

## Advanced Configuration

### Threshold and Pixel Difference

Control how strict the comparison is:

```typescript
test('flexible comparison', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveScreenshot('page.png', {
    // Allow 20% pixel difference (0.0 - 1.0)
    threshold: 0.2,

    // Allow up to 100 pixels to differ
    maxDiffPixels: 100,
  });
});
```

### Viewport and Device

Test across different screen sizes:

```typescript
test.describe('responsive design', () => {
  const devices = [
    { name: 'mobile', width: 375, height: 667 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'desktop', width: 1920, height: 1080 },
  ];

  for (const device of devices) {
    test(`should look correct on ${device.name}`, async ({ page }) => {
      await page.setViewportSize({
        width: device.width,
        height: device.height,
      });

      await page.goto('/');

      await expect(page).toHaveScreenshot(`homepage-${device.name}.png`);
    });
  }
});
```

### Disabling Animations

For consistent screenshots:

```typescript
test('consistent screenshot without animations', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveScreenshot('page.png', {
    // Disable CSS animations and transitions
    animations: 'disabled',
  });
});
```

## Masking Dynamic Content

### Mask Elements

Hide elements that change frequently:

```typescript
test('mask dynamic content', async ({ page }) => {
  await page.goto('/dashboard');

  await expect(page).toHaveScreenshot('dashboard.png', {
    fullPage: true,
    mask: [
      // Mask elements by locator
      page.locator('[data-testid="timestamp"]'),
      page.locator('[data-testid="user-avatar"]'),
      page.locator('.random-id'),
    ],
  });
});
```

### Mask by CSS Selector

```typescript
test('mask multiple elements', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveScreenshot('page.png', {
    mask: [
      page.locator('.date'),
      page.locator('.time'),
      page.locator('[id^="dynamic-"]'), // IDs starting with "dynamic-"
    ],
  });
});
```

### CSS Masking with Pseudo-Element

Add custom CSS to mask areas:

```typescript
test('mask with custom CSS', async ({ page }) => {
  await page.goto('/');

  // Inject CSS to hide dynamic content
  await page.addStyleTag({
    content: `
      .timestamp,
      .random-value {
        visibility: hidden !important;
      }
    `,
  });

  await expect(page).toHaveScreenshot('page.png');
});
```

## Handling Different States

### Interactive States

Test hover, focus, and other states:

```typescript
test('button hover state', async ({ page }) => {
  await page.goto('/');

  const button = page.locator('[data-testid="primary-button"]');

  // Hover state
  await button.hover();
  await expect(button).toHaveScreenshot('button-hover.png');
});

test('input focus state', async ({ page }) => {
  await page.goto('/form');

  const input = page.locator('[data-testid="email-input"]');

  // Focus state
  await input.focus();
  await expect(input).toHaveScreenshot('input-focus.png');
});
```

### Error States

```typescript
test('form validation errors', async ({ page }) => {
  await page.goto('/form');

  // Trigger validation errors
  await page.locator('[data-testid="submit"]').click();

  // Screenshot error state
  await expect(page).toHaveScreenshot('form-errors.png', {
    fullPage: true,
  });
});
```

### Loading States

```typescript
test('loading state', async ({ page }) => {
  await page.goto('/dashboard');

  // Intercept request to delay it
  await page.route('**/api/data', async route => {
    await page.waitForTimeout(500);
    await route.continue();
  });

  // Click refresh
  await page.locator('[data-testid="refresh"]').click();

  // Wait for loading indicator
  await page.locator('[data-testid="loading"]').waitFor({ state: 'visible' });

  // Screenshot loading state
  await expect(page).toHaveScreenshot('loading.png');
});
```

## Cross-Browser Visual Testing

### Configure Multiple Browsers

In `playwright.config.ts`:

```typescript
export default defineConfig({
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
});
```

Each browser gets its own snapshot:

```
__snapshots__/
└── test.spec.ts-snapshots/
    ├── page-chromium.png
    ├── page-firefox.png
    └── page-webkit.png
```

### Browser-Specific Tests

```typescript
test.describe('chromium-only visual tests', () => {
  test.use({ browserName: 'chromium' });

  test('chromium-specific rendering', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveScreenshot('chromium-only.png');
  });
});
```

## Component Visual Testing

Test individual components:

```typescript
test.describe('component visual tests', () => {
  test('button variations', async ({ page }) => {
    await page.goto('/components/buttons');

    // Test primary button
    const primary = page.locator('[data-testid="button-primary"]');
    await expect(primary).toHaveScreenshot('button-primary.png');

    // Test secondary button
    const secondary = page.locator('[data-testid="button-secondary"]');
    await expect(secondary).toHaveScreenshot('button-secondary.png');

    // Test disabled button
    const disabled = page.locator('[data-testid="button-disabled"]');
    await expect(disabled).toHaveScreenshot('button-disabled.png');
  });

  test('modal dialog', async ({ page }) => {
    await page.goto('/components/modals');

    // Open modal
    await page.locator('[data-testid="open-modal"]').click();

    const modal = page.locator('[data-testid="modal"]');
    await modal.waitFor({ state: 'visible' });

    // Screenshot modal
    await expect(modal).toHaveScreenshot('modal.png');
  });
});
```

## Theme Testing

### Light and Dark Modes

```typescript
test.describe('theme visual tests', () => {
  test('light mode', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveScreenshot('homepage-light.png', {
      fullPage: true,
    });
  });

  test('dark mode', async ({ page }) => {
    // Emulate dark color scheme
    await page.emulateMedia({ colorScheme: 'dark' });

    await page.goto('/');
    await expect(page).toHaveScreenshot('homepage-dark.png', {
      fullPage: true,
    });
  });

  test('toggle theme', async ({ page }) => {
    await page.goto('/');

    // Toggle to dark mode
    await page.locator('[data-testid="theme-toggle"]').click();
    await page.waitForTimeout(500); // Wait for transition

    await expect(page).toHaveScreenshot('homepage-dark-toggled.png', {
      fullPage: true,
    });
  });
});
```

## Analyzing Visual Differences

### Review Diff Images

When tests fail, Playwright generates diff images:

```
test-results/
└── visual-regression-homepage/
    ├── homepage-actual.png    # Current screenshot
    ├── homepage-expected.png  # Baseline
    └── homepage-diff.png      # Highlighted differences
```

### HTML Report with Visual Diffs

View in HTML report:

```bash
npx playwright show-report
```

The report shows:
- Expected (baseline) image
- Actual (current) image
- Diff highlighting changes
- Pixel difference percentage

## CI/CD Integration

### Store Snapshots in Git

Commit snapshot directory:

```bash
git add tests/e2e/__snapshots__/
git commit -m "Update visual regression baselines"
```

### GitHub Actions Example

```yaml
name: Visual Regression Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run visual tests
        run: npx playwright test visual-regression.spec.ts

      - name: Upload diff images on failure
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: visual-diffs
          path: test-results/**/*-diff.png
```

### Update Snapshots in PR

If visual changes are intentional:

```bash
# Update snapshots locally
npx playwright test --update-snapshots

# Commit updated snapshots
git add tests/e2e/__snapshots__/
git commit -m "Update visual baselines for new design"
git push
```

## Best Practices

### 1. Stable Test Environment

Ensure consistent rendering:

```typescript
test.beforeEach(async ({ page }) => {
  // Set consistent viewport
  await page.setViewportSize({ width: 1280, height: 720 });

  // Wait for fonts to load
  await page.waitForLoadState('networkidle');

  // Wait for any animations to complete
  await page.waitForTimeout(100);
});
```

### 2. Mask Dynamic Content

Always mask elements that change:
- Timestamps
- User avatars
- Random IDs
- Live data
- Animations

### 3. Use Meaningful Names

```typescript
// Good - descriptive names
await expect(page).toHaveScreenshot('homepage-hero-section-desktop.png');
await expect(page).toHaveScreenshot('checkout-payment-form-error-state.png');

// Bad - unclear names
await expect(page).toHaveScreenshot('test1.png');
await expect(page).toHaveScreenshot('screenshot.png');
```

### 4. Organize Snapshots

Use subdirectories for organization:

```typescript
test('header', async ({ page }) => {
  await page.goto('/');
  const header = page.locator('header');
  await expect(header).toHaveScreenshot('components/header.png');
});
```

### 5. Review Changes Carefully

Before updating snapshots:
1. Review diff images
2. Verify changes are intentional
3. Check across all browsers
4. Update snapshots
5. Commit with descriptive message

## Troubleshooting

### Flaky Visual Tests

```typescript
// Add retries for flaky visual tests
test('potentially flaky', async ({ page }) => {
  test.slow(); // Give extra time

  await page.goto('/');

  // Wait for everything to stabilize
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(500);

  await expect(page).toHaveScreenshot('page.png', {
    animations: 'disabled',
    threshold: 0.2, // Be less strict
  });
});
```

### Font Rendering Differences

Use web fonts and wait for them:

```typescript
test('consistent fonts', async ({ page }) => {
  await page.goto('/');

  // Wait for fonts to load
  await page.evaluate(() => document.fonts.ready);

  await expect(page).toHaveScreenshot('page.png');
});
```

### CI vs Local Differences

Use consistent environment:

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Force same device scale factor
    deviceScaleFactor: 1,

    // Disable hardware acceleration in CI
    launchOptions: {
      args: process.env.CI ? ['--disable-gpu'] : [],
    },
  },
});
```

## Resources

- [Playwright Visual Comparisons](https://playwright.dev/docs/test-snapshots)
- [Screenshot API](https://playwright.dev/docs/api/class-page#page-screenshot)
- [Template: visual-regression.spec.ts](../templates/visual-regression.spec.ts)
- [Script: run-visual-regression.sh](../scripts/run-visual-regression.sh)

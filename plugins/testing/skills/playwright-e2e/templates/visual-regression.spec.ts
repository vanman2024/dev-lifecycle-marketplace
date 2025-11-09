import { test, expect } from '@playwright/test';

/**
 * Visual Regression Testing
 *
 * Tests visual appearance of pages and components using:
 * - Full page screenshots
 * - Component screenshots
 * - Multiple viewports
 * - Dynamic content masking
 */

test.describe('Visual Regression - Homepage', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('should match homepage screenshot', async ({ page }) => {
    // Wait for page to be fully loaded
    await page.waitForLoadState('networkidle');

    // Take full page screenshot and compare
    await expect(page).toHaveScreenshot('homepage.png', {
      fullPage: true,
    });
  });

  test('should match hero section', async ({ page }) => {
    const hero = page.locator('[data-testid="hero-section"]');
    await hero.waitFor({ state: 'visible' });

    // Screenshot specific component
    await expect(hero).toHaveScreenshot('hero-section.png');
  });

  test('should match navigation header', async ({ page }) => {
    const header = page.locator('header');

    // Screenshot with specific options
    await expect(header).toHaveScreenshot('header.png', {
      animations: 'disabled',
      threshold: 0.2,
    });
  });

  test('should match footer', async ({ page }) => {
    const footer = page.locator('footer');
    await footer.scrollIntoViewIfNeeded();

    await expect(footer).toHaveScreenshot('footer.png');
  });
});

test.describe('Visual Regression - Responsive Design', () => {
  const viewports = [
    { name: 'mobile', width: 375, height: 667 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'desktop', width: 1920, height: 1080 },
  ];

  for (const viewport of viewports) {
    test(`should match homepage on ${viewport.name}`, async ({ page }) => {
      // Set viewport size
      await page.setViewportSize({
        width: viewport.width,
        height: viewport.height,
      });

      await page.goto('/');
      await page.waitForLoadState('networkidle');

      // Take screenshot with viewport-specific name
      await expect(page).toHaveScreenshot(`homepage-${viewport.name}.png`, {
        fullPage: true,
      });
    });
  }
});

test.describe('Visual Regression - Components', () => {
  test('should match button variations', async ({ page }) => {
    await page.goto('/components/buttons');

    const buttonContainer = page.locator('[data-testid="button-showcase"]');
    await buttonContainer.waitFor({ state: 'visible' });

    // Screenshot all button variations
    await expect(buttonContainer).toHaveScreenshot('buttons.png');
  });

  test('should match form inputs', async ({ page }) => {
    await page.goto('/components/forms');

    const formContainer = page.locator('[data-testid="form-showcase"]');

    // Screenshot form components
    await expect(formContainer).toHaveScreenshot('form-inputs.png', {
      animations: 'disabled',
    });
  });

  test('should match modal dialog', async ({ page }) => {
    await page.goto('/components/modals');

    // Open modal
    await page.locator('[data-testid="open-modal"]').click();

    const modal = page.locator('[data-testid="modal"]');
    await modal.waitFor({ state: 'visible' });

    // Screenshot modal
    await expect(modal).toHaveScreenshot('modal.png');
  });

  test('should match dropdown menu', async ({ page }) => {
    await page.goto('/components/dropdowns');

    // Open dropdown
    await page.locator('[data-testid="dropdown-trigger"]').click();

    const dropdown = page.locator('[data-testid="dropdown-menu"]');
    await dropdown.waitFor({ state: 'visible' });

    // Screenshot dropdown
    await expect(dropdown).toHaveScreenshot('dropdown.png');
  });
});

test.describe('Visual Regression - Dark Mode', () => {
  test('should match homepage in dark mode', async ({ page }) => {
    await page.goto('/');

    // Enable dark mode
    await page.locator('[data-testid="theme-toggle"]').click();
    await page.waitForTimeout(500); // Wait for theme transition

    // Take screenshot
    await expect(page).toHaveScreenshot('homepage-dark.png', {
      fullPage: true,
    });
  });

  test('should match components in dark mode', async ({ page }) => {
    // Set dark mode preference
    await page.emulateMedia({ colorScheme: 'dark' });

    await page.goto('/components');
    await page.waitForLoadState('networkidle');

    await expect(page).toHaveScreenshot('components-dark.png', {
      fullPage: true,
    });
  });
});

test.describe('Visual Regression - Dynamic Content', () => {
  test('should mask dynamic content', async ({ page }) => {
    await page.goto('/dashboard');
    await page.waitForLoadState('networkidle');

    // Take screenshot with dynamic content masked
    await expect(page).toHaveScreenshot('dashboard.png', {
      fullPage: true,
      mask: [
        // Mask elements that change frequently
        page.locator('[data-testid="timestamp"]'),
        page.locator('[data-testid="user-avatar"]'),
        page.locator('[data-testid="random-id"]'),
      ],
    });
  });

  test('should mask date and time elements', async ({ page }) => {
    await page.goto('/reports');

    const report = page.locator('[data-testid="report-container"]');

    await expect(report).toHaveScreenshot('report.png', {
      mask: [
        page.locator('.date'),
        page.locator('.time'),
        page.locator('.timestamp'),
      ],
    });
  });

  test('should clip specific area', async ({ page }) => {
    await page.goto('/dashboard');

    // Screenshot only specific area
    const stats = page.locator('[data-testid="stats-section"]');

    await expect(stats).toHaveScreenshot('stats.png', {
      clip: {
        x: 0,
        y: 0,
        width: 800,
        height: 400,
      },
    });
  });
});

test.describe('Visual Regression - Interactions', () => {
  test('should match hover state', async ({ page }) => {
    await page.goto('/components/buttons');

    const button = page.locator('[data-testid="primary-button"]');

    // Hover over button
    await button.hover();
    await page.waitForTimeout(200); // Wait for hover animation

    // Screenshot hover state
    await expect(button).toHaveScreenshot('button-hover.png');
  });

  test('should match focus state', async ({ page }) => {
    await page.goto('/components/forms');

    const input = page.locator('[data-testid="text-input"]');

    // Focus input
    await input.focus();

    // Screenshot focus state
    await expect(input).toHaveScreenshot('input-focus.png');
  });

  test('should match error state', async ({ page }) => {
    await page.goto('/contact');

    // Submit form with errors
    await page.locator('[data-testid="submit-button"]').click();

    // Wait for error messages
    await page.locator('[data-testid="error-message"]').waitFor({ state: 'visible' });

    // Screenshot error state
    await expect(page).toHaveScreenshot('form-errors.png');
  });

  test('should match loading state', async ({ page }) => {
    await page.goto('/dashboard');

    // Trigger loading state
    await page.route('**/api/data', async route => {
      await page.waitForTimeout(1000); // Delay response
      await route.fulfill({ status: 200, body: '{}' });
    });

    await page.locator('[data-testid="refresh-button"]').click();

    // Screenshot loading state
    const loader = page.locator('[data-testid="loading-spinner"]');
    await loader.waitFor({ state: 'visible' });

    await expect(loader).toHaveScreenshot('loading-state.png');
  });
});

test.describe('Visual Regression - Custom Configurations', () => {
  test('should use custom threshold', async ({ page }) => {
    await page.goto('/');

    // Allow more pixel differences
    await expect(page).toHaveScreenshot('homepage-flexible.png', {
      threshold: 0.3, // 30% difference allowed
      maxDiffPixels: 100,
    });
  });

  test('should disable animations', async ({ page }) => {
    await page.goto('/animations');

    // Disable animations for consistent screenshots
    await expect(page).toHaveScreenshot('animations-page.png', {
      animations: 'disabled',
    });
  });

  test('should use custom scale', async ({ page }) => {
    await page.goto('/');

    // Take screenshot with custom device scale factor
    await expect(page).toHaveScreenshot('homepage-2x.png', {
      scale: 'device', // Use device pixel ratio
    });
  });
});

test.describe('Visual Regression - Comparison Helpers', () => {
  test('should update snapshots on demand', async ({ page }) => {
    // Run with --update-snapshots flag to update baseline
    await page.goto('/');

    await expect(page).toHaveScreenshot('baseline.png', {
      fullPage: true,
    });
  });

  test('should handle missing snapshots', async ({ page }) => {
    // First run will create snapshot
    // Subsequent runs will compare against it
    await page.goto('/new-feature');

    await expect(page).toHaveScreenshot('new-feature.png', {
      fullPage: true,
    });
  });
});

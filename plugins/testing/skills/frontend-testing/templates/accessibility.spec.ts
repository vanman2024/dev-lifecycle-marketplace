import { test, expect } from '@playwright/test'
import { injectAxe, checkA11y, getViolations } from 'axe-playwright'

test.describe('Accessibility Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/')
    await injectAxe(page)
  })

  test('homepage has no accessibility violations', async ({ page }) => {
    await checkA11y(page, null, {
      detailedReport: true,
      detailedReportOptions: { html: true },
    })
  })

  test('navigation is keyboard accessible', async ({ page }) => {
    // Test keyboard navigation
    await page.keyboard.press('Tab')
    const firstFocusable = await page.evaluate(() => document.activeElement?.tagName)
    expect(firstFocusable).toBeTruthy()

    // Continue tabbing through navigation
    for (let i = 0; i < 5; i++) {
      await page.keyboard.press('Tab')
    }

    // Press Enter on focused link
    await page.keyboard.press('Enter')
    await page.waitForLoadState('networkidle')

    // Verify navigation worked
    expect(page.url()).not.toContain('/')
  })

  test('form has proper labels and ARIA', async ({ page }) => {
    await page.goto('/contact')
    await injectAxe(page)

    // Check for label association
    const nameInput = page.locator('input[name="name"]')
    const label = await nameInput.getAttribute('aria-label') ||
                  await page.locator(`label[for="${await nameInput.getAttribute('id')}"]`).textContent()
    expect(label).toBeTruthy()

    // Check accessibility
    await checkA11y(page, 'form', {
      rules: {
        'label': { enabled: true },
        'aria-required-attr': { enabled: true },
      },
    })
  })

  test('images have alt text', async ({ page }) => {
    const images = await page.locator('img').all()

    for (const img of images) {
      const alt = await img.getAttribute('alt')
      const role = await img.getAttribute('role')

      // Either has alt text or is marked as decorative
      expect(alt !== null || role === 'presentation').toBeTruthy()
    }
  })

  test('color contrast meets WCAG AA', async ({ page }) => {
    await checkA11y(page, null, {
      rules: {
        'color-contrast': { enabled: true },
      },
    })
  })

  test('headings are in logical order', async ({ page }) => {
    const headings = await page.locator('h1, h2, h3, h4, h5, h6').allTextContents()

    // Check for h1 presence
    const h1Count = await page.locator('h1').count()
    expect(h1Count).toBeGreaterThan(0)
    expect(h1Count).toBeLessThanOrEqual(1)

    // Verify no heading levels are skipped
    await checkA11y(page, null, {
      rules: {
        'heading-order': { enabled: true },
      },
    })
  })

  test('interactive elements are focusable', async ({ page }) => {
    const buttons = await page.locator('button, a, input, select, textarea').all()

    for (const element of buttons) {
      await element.focus()
      const isFocused = await element.evaluate((el) => el === document.activeElement)
      expect(isFocused).toBeTruthy()
    }
  })
})

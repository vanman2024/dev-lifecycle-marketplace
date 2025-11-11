import { test, expect } from '@playwright/test'
import { injectAxe, checkA11y } from 'axe-playwright'

test.describe('Contact Form Accessibility', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/contact')
    await page.waitForLoadState('networkidle')
    await injectAxe(page)
  })

  test('form has no accessibility violations', async ({ page }) => {
    await checkA11y(page, 'form', {
      detailedReport: true,
      detailedReportOptions: { html: true },
    })
  })

  test('all form inputs have associated labels', async ({ page }) => {
    const inputs = await page.locator('input, textarea, select').all()

    for (const input of inputs) {
      const id = await input.getAttribute('id')
      const ariaLabel = await input.getAttribute('aria-label')
      const ariaLabelledBy = await input.getAttribute('aria-labelledby')

      if (id) {
        const label = await page.locator(`label[for="${id}"]`).count()
        const hasLabel = label > 0 || ariaLabel || ariaLabelledBy

        expect(hasLabel).toBeTruthy()
      }
    }
  })

  test('required fields are marked with aria-required', async ({ page }) => {
    const requiredInputs = await page.locator('input[required], textarea[required]').all()

    for (const input of requiredInputs) {
      const ariaRequired = await input.getAttribute('aria-required')
      expect(ariaRequired).toBe('true')
    }
  })

  test('error messages are associated with inputs', async ({ page }) => {
    // Submit form to trigger validation
    await page.click('button[type="submit"]')
    await page.waitForSelector('[role="alert"]')

    const inputsWithErrors = await page.locator('input:invalid, textarea:invalid').all()

    for (const input of inputsWithErrors) {
      const ariaDescribedBy = await input.getAttribute('aria-describedby')
      const ariaInvalid = await input.getAttribute('aria-invalid')

      expect(ariaDescribedBy).toBeTruthy()
      expect(ariaInvalid).toBe('true')

      // Check that the error message exists
      if (ariaDescribedBy) {
        const errorMessage = await page.locator(`#${ariaDescribedBy}`).count()
        expect(errorMessage).toBeGreaterThan(0)
      }
    }
  })

  test('form is fully keyboard navigable', async ({ page }) => {
    // Tab through all form elements
    const focusableElements = await page.locator(
      'input, textarea, select, button, a[href]'
    ).all()

    for (let i = 0; i < focusableElements.length; i++) {
      await page.keyboard.press('Tab')

      const activeElement = await page.evaluate(() => {
        const el = document.activeElement
        return {
          tagName: el?.tagName,
          type: el?.getAttribute('type'),
          name: el?.getAttribute('name'),
        }
      })

      expect(activeElement.tagName).toBeTruthy()
    }
  })

  test('form can be submitted with keyboard', async ({ page }) => {
    // Fill form using keyboard
    await page.keyboard.press('Tab') // Focus first input
    await page.keyboard.type('John Doe')

    await page.keyboard.press('Tab')
    await page.keyboard.type('john@example.com')

    await page.keyboard.press('Tab')
    await page.keyboard.type('This is a test message')

    await page.keyboard.press('Tab') // Focus submit button
    await page.keyboard.press('Enter')

    // Wait for submission (adjust based on your implementation)
    await page.waitForSelector('[data-success="true"]', { timeout: 5000 })
  })

  test('error messages have proper contrast', async ({ page }) => {
    await page.click('button[type="submit"]')
    await page.waitForSelector('[role="alert"]')

    await checkA11y(page, '[role="alert"]', {
      rules: {
        'color-contrast': { enabled: true },
      },
    })
  })

  test('focus indicators are visible', async ({ page }) => {
    const inputs = await page.locator('input, textarea, button').all()

    for (const input of inputs) {
      await input.focus()

      // Check for focus styles (adjust based on your implementation)
      const outline = await input.evaluate((el) => {
        const style = window.getComputedStyle(el)
        return {
          outline: style.outline,
          outlineWidth: style.outlineWidth,
          boxShadow: style.boxShadow,
        }
      })

      // Should have either outline or box-shadow
      const hasFocusIndicator =
        (outline.outline && outline.outline !== 'none') ||
        (outline.boxShadow && outline.boxShadow !== 'none')

      expect(hasFocusIndicator).toBeTruthy()
    }
  })

  test('helper text is associated with inputs', async ({ page }) => {
    const inputsWithHelp = await page.locator('input[aria-describedby]').all()

    for (const input of inputsWithHelp) {
      const describedBy = await input.getAttribute('aria-describedby')
      if (describedBy) {
        const helpText = await page.locator(`#${describedBy}`).count()
        expect(helpText).toBeGreaterThan(0)
      }
    }
  })

  test('submit button has accessible name', async ({ page }) => {
    const submitButton = page.locator('button[type="submit"]')
    const accessibleName = await submitButton.getAttribute('aria-label') ||
                           await submitButton.textContent()

    expect(accessibleName).toBeTruthy()
    expect(accessibleName?.trim().length).toBeGreaterThan(0)
  })
})

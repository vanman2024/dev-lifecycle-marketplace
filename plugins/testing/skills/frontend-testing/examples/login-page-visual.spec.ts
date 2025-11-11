import { test, expect } from '@playwright/test'
import { maskDynamicContent } from '../utils/test-helpers'

test.describe('Login Page Visual Regression', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login')
    await page.waitForLoadState('networkidle')
  })

  test('login page matches baseline', async ({ page }) => {
    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-page.png', {
      fullPage: true,
      maxDiffPixels: 100,
    })
  })

  test('login form with validation errors', async ({ page }) => {
    // Trigger validation errors
    await page.click('button[type="submit"]')
    await page.waitForSelector('.error-message')

    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-validation-errors.png')
  })

  test('login form with filled inputs', async ({ page }) => {
    // Fill in the form
    await page.fill('input[name="email"]', 'test@example.com')
    await page.fill('input[name="password"]', 'password123')

    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-filled-form.png')
  })

  test('login page mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 })
    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-mobile.png', {
      fullPage: true,
    })
  })

  test('login page tablet viewport', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 })
    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-tablet.png', {
      fullPage: true,
    })
  })

  test('forgot password link hover state', async ({ page }) => {
    await page.hover('a[href="/forgot-password"]')
    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-forgot-hover.png')
  })

  test('login button focus state', async ({ page }) => {
    await page.focus('button[type="submit"]')
    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-button-focus.png')
  })

  test('password input with show/hide toggle', async ({ page }) => {
    await page.fill('input[name="password"]', 'password123')
    await page.click('button[aria-label="Show password"]')
    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-password-visible.png')
  })

  test('login page dark mode', async ({ page }) => {
    // Toggle dark mode (adjust selector based on your implementation)
    await page.evaluate(() => {
      document.documentElement.classList.add('dark')
    })

    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-dark-mode.png', {
      fullPage: true,
    })
  })

  test('login success loading state', async ({ page }) => {
    await page.fill('input[name="email"]', 'test@example.com')
    await page.fill('input[name="password"]', 'password123')

    // Click and capture loading state immediately
    await page.click('button[type="submit"]')
    await page.waitForSelector('[data-loading="true"]', { timeout: 1000 })

    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('login-loading.png')
  })
})

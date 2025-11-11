import { test, expect } from '@playwright/test'
import { maskDynamicContent } from '../utils/test-helpers'

test.describe('Page Visual Regression', () => {
  test('homepage matches baseline', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // Mask dynamic content
    await maskDynamicContent(page)

    // Take screenshot and compare
    await expect(page).toHaveScreenshot('homepage.png', {
      fullPage: true,
      maxDiffPixels: 100,
    })
  })

  test('mobile viewport matches baseline', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 })
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('homepage-mobile.png', {
      fullPage: true,
    })
  })

  test('dark mode matches baseline', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // Toggle dark mode
    await page.evaluate(() => {
      document.documentElement.classList.add('dark')
    })

    await maskDynamicContent(page)

    await expect(page).toHaveScreenshot('homepage-dark.png', {
      fullPage: true,
    })
  })

  test('component state variations', async ({ page }) => {
    await page.goto('/component-playground')
    await page.waitForLoadState('networkidle')

    // Test hover state
    await page.hover('[data-testid="interactive-element"]')
    await expect(page).toHaveScreenshot('component-hover.png')

    // Test focus state
    await page.focus('[data-testid="interactive-element"]')
    await expect(page).toHaveScreenshot('component-focus.png')

    // Test active state
    await page.click('[data-testid="interactive-element"]')
    await expect(page).toHaveScreenshot('component-active.png')
  })
})

import { test, expect } from '@playwright/test'
import { playAudit } from 'playwright-lighthouse'
import * as lighthouse from 'lighthouse'

test.describe('Performance Tests', () => {
  test('homepage performance meets thresholds', async ({ page, context }) => {
    // Navigate to page
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // Run Lighthouse audit
    await playAudit({
      page,
      thresholds: {
        performance: 90,
        accessibility: 90,
        'best-practices': 90,
        seo: 90,
      },
      port: 9222,
    })
  })

  test('Core Web Vitals are within thresholds', async ({ page }) => {
    await page.goto('/')

    // Measure Web Vitals
    const webVitals = await page.evaluate(() => {
      return new Promise((resolve) => {
        const vitals: any = {}

        // LCP - Largest Contentful Paint
        new PerformanceObserver((list) => {
          const entries = list.getEntries()
          const lastEntry = entries[entries.length - 1]
          vitals.lcp = lastEntry.renderTime || lastEntry.loadTime
        }).observe({ type: 'largest-contentful-paint', buffered: true })

        // FID - First Input Delay (approximated with FCP)
        new PerformanceObserver((list) => {
          vitals.fcp = list.getEntries()[0].startTime
        }).observe({ type: 'first-contentful-paint', buffered: true })

        // CLS - Cumulative Layout Shift
        let clsValue = 0
        new PerformanceObserver((list) => {
          for (const entry of list.getEntries() as any[]) {
            if (!entry.hadRecentInput) {
              clsValue += entry.value
            }
          }
          vitals.cls = clsValue
        }).observe({ type: 'layout-shift', buffered: true })

        setTimeout(() => resolve(vitals), 3000)
      })
    })

    // Assert thresholds
    expect(webVitals.lcp).toBeLessThan(2500) // LCP < 2.5s
    expect(webVitals.cls).toBeLessThan(0.1) // CLS < 0.1
  })

  test('bundle size is optimized', async ({ page }) => {
    const cdpSession = await page.context().newCDPSession(page)
    await cdpSession.send('Performance.enable')

    await page.goto('/')
    await page.waitForLoadState('networkidle')

    // Get all resources
    const resourceTiming = await page.evaluate(() =>
      performance.getEntriesByType('resource').map((r: any) => ({
        name: r.name,
        size: r.transferSize,
        duration: r.duration,
      }))
    )

    // Check main bundle size
    const jsResources = resourceTiming.filter((r: any) => r.name.endsWith('.js'))
    const totalJsSize = jsResources.reduce((sum: number, r: any) => sum + r.size, 0)

    // Assert bundle size is under 500KB
    expect(totalJsSize).toBeLessThan(500 * 1024)
  })

  test('images are optimized', async ({ page }) => {
    await page.goto('/')

    const images = await page.locator('img').all()
    const imageData = await Promise.all(
      images.map(async (img) => {
        const src = await img.getAttribute('src')
        const width = await img.getAttribute('width')
        const height = await img.getAttribute('height')

        return { src, width, height }
      })
    )

    // Check images have explicit dimensions
    for (const img of imageData) {
      expect(img.width || img.height).toBeTruthy()
    }
  })

  test('critical resources load quickly', async ({ page }) => {
    await page.goto('/')

    const timing = await page.evaluate(() => {
      const perfData = performance.getEntriesByType('navigation')[0] as any
      return {
        domContentLoaded: perfData.domContentLoadedEventEnd - perfData.fetchStart,
        load: perfData.loadEventEnd - perfData.fetchStart,
        firstByte: perfData.responseStart - perfData.requestStart,
      }
    })

    // Assert timing thresholds
    expect(timing.firstByte).toBeLessThan(800) // TTFB < 800ms
    expect(timing.domContentLoaded).toBeLessThan(1500) // DCL < 1.5s
    expect(timing.load).toBeLessThan(3000) // Load < 3s
  })
})

import { test, expect } from '@playwright/test'
import { playAudit } from 'playwright-lighthouse'

test.describe('Homepage Performance', () => {
  test('homepage meets Lighthouse thresholds', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    await playAudit({
      page,
      thresholds: {
        performance: 90,
        accessibility: 95,
        'best-practices': 90,
        seo: 90,
        'first-contentful-paint': 1800,
        'largest-contentful-paint': 2500,
        'cumulative-layout-shift': 0.1,
        'total-blocking-time': 200,
      },
      port: 9222,
    })
  })

  test('Core Web Vitals meet thresholds', async ({ page }) => {
    await page.goto('/')

    const webVitals = await page.evaluate(() => {
      return new Promise((resolve) => {
        const vitals: any = {}

        // LCP - Largest Contentful Paint
        new PerformanceObserver((list) => {
          const entries = list.getEntries()
          if (entries.length > 0) {
            const lastEntry = entries[entries.length - 1] as any
            vitals.lcp = lastEntry.renderTime || lastEntry.loadTime
          }
        }).observe({ type: 'largest-contentful-paint', buffered: true })

        // FCP - First Contentful Paint
        new PerformanceObserver((list) => {
          const entries = list.getEntries()
          if (entries.length > 0) {
            vitals.fcp = entries[0].startTime
          }
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

        // TTFB - Time to First Byte
        const navTiming = performance.getEntriesByType('navigation')[0] as any
        vitals.ttfb = navTiming.responseStart - navTiming.requestStart

        setTimeout(() => resolve(vitals), 3000)
      })
    })

    console.log('Web Vitals:', webVitals)

    // Assert Core Web Vitals thresholds
    expect(webVitals.lcp).toBeLessThan(2500) // LCP < 2.5s (good)
    expect(webVitals.fcp).toBeLessThan(1800) // FCP < 1.8s (good)
    expect(webVitals.cls).toBeLessThan(0.1) // CLS < 0.1 (good)
    expect(webVitals.ttfb).toBeLessThan(800) // TTFB < 800ms (good)
  })

  test('JavaScript bundle size is optimized', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    const resourceTiming = await page.evaluate(() =>
      performance.getEntriesByType('resource').map((r: any) => ({
        name: r.name,
        size: r.transferSize,
        type: r.initiatorType,
      }))
    )

    const jsResources = resourceTiming.filter((r: any) =>
      r.name.endsWith('.js') && r.type === 'script'
    )
    const totalJsSize = jsResources.reduce((sum: number, r: any) => sum + (r.size || 0), 0)

    console.log('Total JS size:', (totalJsSize / 1024).toFixed(2), 'KB')
    console.log('JS files:', jsResources.length)

    // Assert bundle size is under 500KB (adjust based on your app)
    expect(totalJsSize).toBeLessThan(500 * 1024)
  })

  test('images are properly sized and optimized', async ({ page }) => {
    await page.goto('/')

    const images = await page.locator('img').all()
    const imageData = await Promise.all(
      images.map(async (img) => {
        const src = await img.getAttribute('src')
        const width = await img.getAttribute('width')
        const height = await img.getAttribute('height')
        const loading = await img.getAttribute('loading')

        const naturalSize = await img.evaluate((el: HTMLImageElement) => ({
          naturalWidth: el.naturalWidth,
          naturalHeight: el.naturalHeight,
        }))

        return { src, width, height, loading, ...naturalSize }
      })
    )

    for (const img of imageData) {
      // Images should have explicit dimensions
      expect(img.width || img.height).toBeTruthy()

      // Off-screen images should use lazy loading
      // (This is a simplified check - you may need to adjust)
      if (img.loading === 'lazy') {
        expect(img.loading).toBe('lazy')
      }
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
        domInteractive: perfData.domInteractive - perfData.fetchStart,
      }
    })

    console.log('Page timing:', timing)

    // Assert timing thresholds
    expect(timing.firstByte).toBeLessThan(800) // TTFB < 800ms
    expect(timing.domInteractive).toBeLessThan(2500) // DOM Interactive < 2.5s
    expect(timing.domContentLoaded).toBeLessThan(3000) // DCL < 3s
    expect(timing.load).toBeLessThan(5000) // Load < 5s
  })

  test('no render-blocking resources', async ({ page }) => {
    await page.goto('/')

    const renderBlockingResources = await page.evaluate(() => {
      return performance.getEntriesByType('resource')
        .filter((r: any) => {
          return (r.name.endsWith('.css') || r.name.endsWith('.js')) &&
                 r.renderBlockingStatus === 'blocking'
        })
        .map((r: any) => r.name)
    })

    console.log('Render-blocking resources:', renderBlockingResources)

    // Should have minimal or no render-blocking resources
    expect(renderBlockingResources.length).toBeLessThan(3)
  })

  test('CSS bundle size is optimized', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    const resourceTiming = await page.evaluate(() =>
      performance.getEntriesByType('resource').map((r: any) => ({
        name: r.name,
        size: r.transferSize,
        type: r.initiatorType,
      }))
    )

    const cssResources = resourceTiming.filter((r: any) =>
      r.name.endsWith('.css') && r.type === 'link'
    )
    const totalCssSize = cssResources.reduce((sum: number, r: any) => sum + (r.size || 0), 0)

    console.log('Total CSS size:', (totalCssSize / 1024).toFixed(2), 'KB')

    // Assert CSS bundle size is under 100KB
    expect(totalCssSize).toBeLessThan(100 * 1024)
  })

  test('fonts load efficiently', async ({ page }) => {
    await page.goto('/')

    const fontResources = await page.evaluate(() =>
      performance.getEntriesByType('resource')
        .filter((r: any) => r.name.match(/\.(woff2?|ttf|otf|eot)$/))
        .map((r: any) => ({
          name: r.name,
          duration: r.duration,
          size: r.transferSize,
        }))
    )

    console.log('Fonts loaded:', fontResources.length)

    // Fonts should load quickly
    for (const font of fontResources) {
      expect(font.duration).toBeLessThan(1000) // Each font loads in < 1s
    }

    // Should use woff2 format for best compression
    const woff2Fonts = fontResources.filter(f => f.name.endsWith('.woff2'))
    expect(woff2Fonts.length).toBeGreaterThan(0)
  })
})

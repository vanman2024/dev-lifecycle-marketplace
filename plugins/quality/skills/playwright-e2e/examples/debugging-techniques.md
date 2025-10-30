# Debugging Techniques - Playwright E2E Testing

Master debugging strategies to quickly identify and fix failing E2E tests.

## Quick Debug Script

Use the skill's debug script for instant debugging:

```bash
# Debug a specific test
bash scripts/debug-playwright.sh tests/e2e/login.spec.ts
```

This automatically:
- Opens Playwright Inspector
- Runs in headed mode
- Enables slow motion
- Records traces

## Playwright Inspector

### Enable Inspector

#### Method 1: Environment Variable

```bash
PWDEBUG=1 npx playwright test
```

#### Method 2: --debug Flag

```bash
npx playwright test --debug
```

#### Method 3: In Code

```typescript
test('debug this test', async ({ page }) => {
  await page.pause(); // Stops execution and opens inspector
  await page.goto('/');
});
```

### Inspector Features

- **Step through actions**: Execute code line by line
- **Pick locator**: Click elements to generate selectors
- **Edit selectors**: Test different selector strategies
- **Console**: Run commands in browser context
- **Timeline**: View action history

### Inspector Commands

```typescript
// Pause execution
await page.pause();

// Resume from pause
// (click "Resume" in Inspector)
```

## Trace Viewer

### Recording Traces

#### Enable in Config

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    trace: 'on-first-retry', // Record on retries
    // or
    trace: 'on', // Always record
    // or
    trace: 'retain-on-failure', // Keep only failed tests
  },
});
```

#### Enable via CLI

```bash
npx playwright test --trace on
```

#### Enable in Code

```typescript
test('with trace', async ({ page, context }) => {
  // Start tracing
  await context.tracing.start({
    screenshots: true,
    snapshots: true,
    sources: true,
  });

  // Test actions
  await page.goto('/');

  // Stop tracing
  await context.tracing.stop({ path: 'trace.zip' });
});
```

### Viewing Traces

```bash
# View trace file
npx playwright show-trace trace.zip

# View trace from test results
npx playwright show-trace test-results/trace.zip
```

### Trace Features

- **Timeline**: See every action in order
- **Screenshots**: Visual state at each step
- **Network**: All requests and responses
- **Console**: Browser console logs
- **Source**: Test code execution
- **DOM snapshots**: Page state at each action
- **Metadata**: Test info, duration, errors

## Running in Headed Mode

See the browser during test execution:

```bash
# Show browser window
npx playwright test --headed

# Slow motion (500ms delay between actions)
npx playwright test --headed --slow-mo=500
```

### In Code

```typescript
test.use({
  headless: false,
  slowMo: 500,
});

test('visual debugging', async ({ page }) => {
  // Browser will be visible
  await page.goto('/');
});
```

## UI Mode

Interactive test runner with time-travel debugging:

```bash
# Open UI mode
npx playwright test --ui

# Or use npm script
npm run test:e2e:ui
```

### UI Mode Features

- **Watch mode**: Auto-run tests on file changes
- **Time travel**: Step through test execution
- **Pick locator**: Generate selectors visually
- **Filter tests**: Run specific tests
- **View traces**: Built-in trace viewer
- **Console output**: See logs in real-time

## Screenshots

### Automatic Screenshots

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    screenshot: 'only-on-failure',
    // or
    screenshot: 'on', // Always capture
  },
});
```

### Manual Screenshots

```typescript
test('with screenshots', async ({ page }) => {
  await page.goto('/');

  // Full page screenshot
  await page.screenshot({ path: 'page.png', fullPage: true });

  // Element screenshot
  const element = page.locator('.header');
  await element.screenshot({ path: 'header.png' });

  // Screenshot to buffer
  const buffer = await page.screenshot();
});
```

### Screenshot on Failure

```typescript
test('auto screenshot on failure', async ({ page }, testInfo) => {
  try {
    await page.goto('/');
    await expect(page.locator('h1')).toHaveText('Wrong Title'); // Will fail
  } catch (error) {
    // Take screenshot on failure
    await page.screenshot({
      path: `screenshots/${testInfo.title}-failure.png`,
      fullPage: true,
    });
    throw error;
  }
});
```

## Video Recording

### Enable Video

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    video: 'on', // Always record
    // or
    video: 'retain-on-failure', // Keep only failed tests
    // or
    video: 'on-first-retry', // Record on retries
  },
});
```

### Video Location

Videos are saved in `test-results/`:

```
test-results/
└── test-login-chromium/
    └── video.webm
```

### Access Video Path

```typescript
test('with video', async ({ page }, testInfo) => {
  await page.goto('/');

  // Get video path after test
  const video = await page.video();
  const videoPath = await video?.path();
  console.log('Video saved to:', videoPath);
});
```

## Console Output

### Browser Console Logs

```typescript
test('capture console', async ({ page }) => {
  // Listen to console messages
  page.on('console', msg => {
    console.log(`Browser ${msg.type()}: ${msg.text()}`);
  });

  // Listen to page errors
  page.on('pageerror', error => {
    console.log(`Page error: ${error.message}`);
  });

  await page.goto('/');
});
```

### Verbose Output

```bash
# Show verbose logs
npx playwright test --debug

# Show all browser logs
DEBUG=pw:browser npx playwright test

# Show API logs
DEBUG=pw:api npx playwright test

# Show all logs
DEBUG=pw:* npx playwright test
```

## Network Debugging

### Capture Network Activity

```typescript
test('monitor network', async ({ page }) => {
  // Listen to all requests
  page.on('request', request => {
    console.log('Request:', request.url());
  });

  // Listen to all responses
  page.on('response', response => {
    console.log('Response:', response.url(), response.status());
  });

  // Listen to failed requests
  page.on('requestfailed', request => {
    console.log('Failed:', request.url(), request.failure()?.errorText);
  });

  await page.goto('/');
});
```

### Inspect Specific Requests

```typescript
test('inspect API calls', async ({ page }) => {
  // Wait for specific request
  const requestPromise = page.waitForRequest(
    request => request.url().includes('/api/users')
  );

  await page.goto('/users');

  const request = await requestPromise;
  console.log('Method:', request.method());
  console.log('Headers:', request.headers());
  console.log('Body:', request.postData());
});
```

### Inspect Responses

```typescript
test('check API response', async ({ page }) => {
  const response = await page.waitForResponse(
    response => response.url().includes('/api/data') && response.status() === 200
  );

  console.log('Response status:', response.status());
  console.log('Response headers:', response.headers());
  const body = await response.json();
  console.log('Response body:', body);
});
```

## Locator Debugging

### Test Locators

```bash
# Test locator in terminal
npx playwright test --debug
# Then in console: locator('button')
```

### In Code

```typescript
test('debug locators', async ({ page }) => {
  await page.goto('/');

  const button = page.locator('button');

  // Print locator info
  console.log('Locator:', button);
  console.log('Count:', await button.count());
  console.log('Visible:', await button.isVisible());

  // Get all matching elements
  const all = await button.all();
  console.log('Found elements:', all.length);
});
```

### Highlight Elements

```typescript
test('highlight element', async ({ page }) => {
  await page.goto('/');

  const element = page.locator('button');

  // Highlight element with red border
  await element.evaluate(el => {
    el.style.border = '3px solid red';
  });

  await page.waitForTimeout(2000); // Keep visible
});
```

## Common Debugging Patterns

### 1. Wait for Element

```typescript
test('wait strategies', async ({ page }) => {
  await page.goto('/');

  // Wait for element to be visible
  await page.locator('button').waitFor({ state: 'visible' });

  // Wait with timeout
  await page.locator('button').waitFor({
    state: 'visible',
    timeout: 10000,
  });

  // Wait for multiple states
  await page.waitForLoadState('networkidle');
  await page.waitForLoadState('domcontentloaded');
});
```

### 2. Check Element State

```typescript
test('element state', async ({ page }) => {
  await page.goto('/');

  const button = page.locator('button');

  console.log('Visible:', await button.isVisible());
  console.log('Enabled:', await button.isEnabled());
  console.log('Editable:', await button.isEditable());
  console.log('Checked:', await button.isChecked());
  console.log('Hidden:', await button.isHidden());
  console.log('Count:', await button.count());
});
```

### 3. Get Element Information

```typescript
test('element info', async ({ page }) => {
  await page.goto('/');

  const element = page.locator('button');

  console.log('Text:', await element.textContent());
  console.log('Inner text:', await element.innerText());
  console.log('HTML:', await element.innerHTML());
  console.log('Value:', await element.inputValue());
  console.log('Attribute:', await element.getAttribute('class'));
});
```

### 4. Execute JavaScript

```typescript
test('evaluate code', async ({ page }) => {
  await page.goto('/');

  // Execute in page context
  const title = await page.evaluate(() => document.title);
  console.log('Title:', title);

  // Execute with arguments
  const result = await page.evaluate(x => {
    console.log('Argument:', x);
    return x * 2;
  }, 5);
  console.log('Result:', result);

  // Execute on element
  const text = await page.locator('button').evaluate(el => el.textContent);
  console.log('Button text:', text);
});
```

## Test Fixtures for Debugging

### Custom Debug Fixture

```typescript
// fixtures/debug.fixture.ts
import { test as base } from '@playwright/test';

type DebugFixtures = {
  debug: {
    screenshot: (name: string) => Promise<void>;
    log: (message: string) => void;
    highlight: (selector: string) => Promise<void>;
  };
};

export const test = base.extend<DebugFixtures>({
  debug: async ({ page }, use) => {
    const helpers = {
      screenshot: async (name: string) => {
        await page.screenshot({ path: `debug-${name}.png` });
      },
      log: (message: string) => {
        console.log(`[DEBUG] ${message}`);
      },
      highlight: async (selector: string) => {
        await page.locator(selector).evaluate(el => {
          el.style.border = '3px solid red';
          el.scrollIntoView();
        });
        await page.waitForTimeout(1000);
      },
    };

    await use(helpers);
  },
});

// Use in tests
test('with debug helpers', async ({ page, debug }) => {
  await page.goto('/');

  debug.log('Starting test');
  await debug.screenshot('initial');
  await debug.highlight('button');
});
```

## Debugging Flaky Tests

### Add Test Timeout

```typescript
test('flaky test', async ({ page }) => {
  test.setTimeout(60000); // 60 second timeout

  await page.goto('/');
});
```

### Add Retries

```typescript
// playwright.config.ts
export default defineConfig({
  retries: 2, // Retry failed tests twice
});

// Or per test
test('flaky test', async ({ page }) => {
  test.fixme(); // Skip this test
  // or
  test.slow(); // Triple the timeout
});
```

### Diagnostic Mode

```typescript
test('diagnostic mode', async ({ page }) => {
  // Enable verbose logging
  page.on('console', msg => console.log('CONSOLE:', msg.text()));
  page.on('pageerror', err => console.log('ERROR:', err.message));
  page.on('request', req => console.log('REQUEST:', req.url()));
  page.on('response', res => console.log('RESPONSE:', res.url(), res.status()));

  await page.goto('/');
});
```

## Debugging Tips

### 1. Use data-testid

Most reliable selector strategy:

```html
<button data-testid="submit-button">Submit</button>
```

```typescript
await page.locator('[data-testid="submit-button"]').click();
```

### 2. Check Multiple States

```typescript
const button = page.locator('button');

// Debug all states
console.log({
  visible: await button.isVisible(),
  enabled: await button.isEnabled(),
  count: await button.count(),
  text: await button.textContent(),
});
```

### 3. Add Strategic Pauses

```typescript
// Pause to inspect state
await page.pause();

// Or wait to observe
await page.waitForTimeout(5000);
```

### 4. Use Soft Assertions

Continue test even after assertion fails:

```typescript
await expect.soft(page.locator('h1')).toHaveText('Expected');
await expect.soft(page.locator('p')).toBeVisible();
// Test continues even if assertions fail
```

### 5. Generate Test Code

Record actions and generate code:

```bash
npx playwright codegen https://example.com
```

## Troubleshooting Common Issues

### Element Not Found

```typescript
// Add explicit wait
await page.locator('button').waitFor({ state: 'visible' });

// Check if element exists
const count = await page.locator('button').count();
console.log('Found elements:', count);

// Try different selector
const button = page.getByRole('button', { name: 'Submit' });
```

### Timeout Errors

```typescript
// Increase timeout
test.setTimeout(60000);

// Or per action
await page.goto('/', { timeout: 30000 });
await page.locator('button').click({ timeout: 10000 });
```

### Flaky Waits

```typescript
// Use auto-waiting
await page.locator('button').click(); // Waits automatically

// Add explicit wait for stable state
await page.waitForLoadState('networkidle');

// Wait for specific condition
await page.waitForFunction(() => window.appReady === true);
```

## Resources

- [Playwright Debugging Guide](https://playwright.dev/docs/debug)
- [Trace Viewer](https://playwright.dev/docs/trace-viewer)
- [Inspector](https://playwright.dev/docs/inspector)
- [Script: debug-playwright.sh](../scripts/debug-playwright.sh)

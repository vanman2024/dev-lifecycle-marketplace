#!/bin/bash
# Initialize comprehensive frontend testing infrastructure

set -e

PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"

echo "🔧 Initializing Frontend Testing Infrastructure..."

# Detect package manager
if [ -f "pnpm-lock.yaml" ]; then
    PKG_MGR="pnpm"
elif [ -f "yarn.lock" ]; then
    PKG_MGR="yarn"
else
    PKG_MGR="npm"
fi

echo "📦 Package manager: $PKG_MGR"

# Detect testing framework
if grep -q '"jest"' package.json 2>/dev/null; then
    TEST_FRAMEWORK="jest"
elif grep -q '"vitest"' package.json 2>/dev/null; then
    TEST_FRAMEWORK="vitest"
else
    # Ask user which to install
    echo "❓ No testing framework detected. Which would you like to use?"
    echo "1) Jest (more mature, widely used)"
    echo "2) Vitest (faster, Vite-native)"
    read -p "Enter choice (1 or 2): " choice
    if [ "$choice" = "2" ]; then
        TEST_FRAMEWORK="vitest"
    else
        TEST_FRAMEWORK="jest"
    fi
fi

echo "🧪 Testing framework: $TEST_FRAMEWORK"

# Install core testing dependencies
echo "📥 Installing core testing dependencies..."

if [ "$TEST_FRAMEWORK" = "jest" ]; then
    $PKG_MGR install --save-dev \
        jest \
        @testing-library/react \
        @testing-library/jest-dom \
        @testing-library/user-event \
        jest-environment-jsdom \
        @types/jest
else
    $PKG_MGR install --save-dev \
        vitest \
        @testing-library/react \
        @testing-library/jest-dom \
        @testing-library/user-event \
        @vitest/ui \
        jsdom \
        @types/node
fi

# Install Playwright for visual regression and accessibility
echo "📥 Installing Playwright..."
$PKG_MGR install --save-dev \
    @playwright/test \
    @axe-core/playwright

# Install Playwright browsers
echo "🌐 Installing Playwright browsers..."
npx playwright install chromium

# Install performance testing
echo "📥 Installing Lighthouse for performance testing..."
$PKG_MGR install --save-dev \
    playwright-lighthouse \
    lighthouse

# Create test directory structure
echo "📁 Creating test directory structure..."
mkdir -p tests/{unit,integration,visual,a11y,performance,utils}

# Create configuration files
echo "⚙️  Creating configuration files..."

if [ "$TEST_FRAMEWORK" = "jest" ]; then
    # Create jest.config.js
    cat > jest.config.js <<'EOF'
const nextJest = require('next/jest')

const createJestConfig = nextJest({
  // Provide the path to your Next.js app to load next.config.js and .env files
  dir: './',
})

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/tests/utils/setup-tests.ts'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
    '!src/**/__tests__/**',
  ],
  coverageThresholds: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
}

module.exports = createJestConfig(customJestConfig)
EOF
else
    # Create vitest.config.ts
    cat > vitest.config.ts <<'EOF'
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./tests/utils/setup-tests.ts'],
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.{js,jsx,ts,tsx}'],
      exclude: [
        'src/**/*.d.ts',
        'src/**/*.stories.{js,jsx,ts,tsx}',
        'src/**/__tests__/**',
      ],
      thresholds: {
        branches: 70,
        functions: 70,
        lines: 70,
        statements: 70,
      },
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
EOF
fi

# Create Playwright configs
cat > playwright.visual.config.ts <<'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/visual',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
EOF

cat > playwright.a11y.config.ts <<'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/a11y',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
EOF

# Create test utilities
echo "🔧 Creating test utilities..."
cat > tests/utils/setup-tests.ts <<'EOF'
import '@testing-library/jest-dom'

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
})

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  disconnect() {}
  observe() {}
  takeRecords() {
    return []
  }
  unobserve() {}
}
EOF

cat > tests/utils/test-utils.ts <<'EOF'
import { ReactElement } from 'react'
import { render, RenderOptions } from '@testing-library/react'

// Custom render function with providers
export function renderWithProviders(
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) {
  return render(ui, { ...options })
}

// Re-export everything
export * from '@testing-library/react'
export { default as userEvent } from '@testing-library/user-event'
EOF

cat > tests/utils/test-helpers.ts <<'EOF'
export async function waitForLoadState(page: any, state: string = 'networkidle') {
  await page.waitForLoadState(state)
}

export async function maskDynamicContent(page: any) {
  // Mask timestamps
  await page.locator('.timestamp, [data-timestamp]').evaluateAll(
    (elements: Element[]) => elements.forEach(el => ((el as HTMLElement).style.visibility = 'hidden'))
  )

  // Mask random IDs
  await page.locator('[data-testid*="random"]').evaluateAll(
    (elements: Element[]) => elements.forEach(el => ((el as HTMLElement).style.visibility = 'hidden'))
  )

  // Mask animations
  await page.addStyleTag({
    content: '*, *::before, *::after { animation-duration: 0s !important; transition-duration: 0s !important; }',
  })
}
EOF

cat > tests/utils/mock-factories.ts <<'EOF'
export const createMockUser = (overrides = {}) => ({
  id: '123',
  name: 'Test User',
  email: 'test@example.com',
  ...overrides,
})

export const createMockPost = (overrides = {}) => ({
  id: '1',
  title: 'Test Post',
  content: 'Test content',
  author: createMockUser(),
  createdAt: '2025-01-01T00:00:00Z',
  ...overrides,
})
EOF

# Add test scripts to package.json
echo "📝 Adding test scripts to package.json..."
if [ "$TEST_FRAMEWORK" = "jest" ]; then
    npm pkg set scripts.test="jest"
    npm pkg set scripts.test:watch="jest --watch"
    npm pkg set scripts.test:coverage="jest --coverage"
else
    npm pkg set scripts.test="vitest run"
    npm pkg set scripts.test:watch="vitest"
    npm pkg set scripts.test:coverage="vitest run --coverage"
    npm pkg set scripts.test:ui="vitest --ui"
fi

npm pkg set scripts.test:visual="playwright test --config=playwright.visual.config.ts"
npm pkg set scripts.test:a11y="playwright test --config=playwright.a11y.config.ts"
npm pkg set scripts.test:performance="playwright test tests/performance"
npm pkg set scripts.test:all="npm run test:coverage && npm run test:visual && npm run test:a11y"

echo "✅ Frontend testing infrastructure initialized!"
echo ""
echo "📚 Next steps:"
echo "  1. Run component tests: npm test"
echo "  2. Run visual tests: npm run test:visual"
echo "  3. Run accessibility tests: npm run test:a11y"
echo "  4. Run performance tests: npm run test:performance"
echo "  5. Run all tests: npm run test:all"

#!/bin/bash
# init-playwright.sh - Initialize Playwright project with configuration
set -euo pipefail

PROJECT_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/templates"

echo "🎭 Initializing Playwright E2E Testing Project..."

# Navigate to project directory
cd "$PROJECT_PATH"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "📦 Creating package.json..."
    npm init -y
fi

# Install Playwright
echo "📦 Installing Playwright..."
npm install -D @playwright/test@latest

# Install browsers
echo "🌐 Installing Playwright browsers..."
npx playwright install

# Create test directory structure
echo "📁 Creating test directory structure..."
mkdir -p tests/e2e
mkdir -p tests/page-objects
mkdir -p tests/fixtures
mkdir -p tests/utils

# Copy playwright.config.ts template
if [ -f "$TEMPLATE_DIR/playwright.config.ts" ]; then
    echo "⚙️ Creating playwright.config.ts..."
    cp "$TEMPLATE_DIR/playwright.config.ts" playwright.config.ts
else
    echo "⚠️ Template not found, creating basic config..."
    cat > playwright.config.ts << 'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
});
EOF
fi

# Create example page object if template exists
if [ -f "$TEMPLATE_DIR/page-object-basic.ts" ]; then
    echo "📄 Creating example page object..."
    cp "$TEMPLATE_DIR/page-object-basic.ts" tests/page-objects/example.page.ts
fi

# Create example test if template exists
if [ -f "$TEMPLATE_DIR/e2e-test-login.spec.ts" ]; then
    echo "📝 Creating example test..."
    cp "$TEMPLATE_DIR/e2e-test-login.spec.ts" tests/e2e/example.spec.ts
fi

# Create .gitignore entries for Playwright
if [ -f ".gitignore" ]; then
    echo "📝 Updating .gitignore..."
    if ! grep -q "playwright" .gitignore; then
        cat >> .gitignore << 'EOF'

# Playwright
test-results/
playwright-report/
playwright/.cache/
EOF
    fi
else
    echo "📝 Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Playwright
test-results/
playwright-report/
playwright/.cache/
EOF
fi

# Add npm scripts to package.json
echo "📝 Adding test scripts to package.json..."
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts = pkg.scripts || {};
pkg.scripts['test:e2e'] = 'playwright test';
pkg.scripts['test:e2e:ui'] = 'playwright test --ui';
pkg.scripts['test:e2e:debug'] = 'playwright test --debug';
pkg.scripts['test:e2e:report'] = 'playwright show-report';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"

echo ""
echo "✅ Playwright initialization complete!"
echo ""
echo "Next steps:"
echo "  1. Update baseURL in playwright.config.ts"
echo "  2. Create page objects in tests/page-objects/"
echo "  3. Write tests in tests/e2e/"
echo "  4. Run tests: npm run test:e2e"
echo ""

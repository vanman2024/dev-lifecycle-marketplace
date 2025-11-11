#!/bin/bash
# Run performance tests with Lighthouse

set -e

URL="${1:-http://localhost:3000}"
OPTIONS="${2:-}"

echo "⚡ Running performance tests with Lighthouse..."
echo "🔗 Target URL: $URL"

# Check if playwright-lighthouse is installed
if ! npm list playwright-lighthouse &>/dev/null; then
    echo "❌ playwright-lighthouse not installed"
    echo "Run init-frontend-tests.sh first"
    exit 1
fi

# Create performance test directory if it doesn't exist
mkdir -p tests/performance

# Run Playwright tests in performance directory
if [ -d "tests/performance" ] && [ "$(ls -A tests/performance/*.spec.ts 2>/dev/null)" ]; then
    npx playwright test tests/performance $OPTIONS
    EXIT_CODE=$?
else
    echo "⚠️  No performance tests found in tests/performance/"
    echo "💡 Create performance tests using the performance.spec.ts template"
    EXIT_CODE=1
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All performance tests passed!"
    echo "📊 Performance metrics meet thresholds"
else
    echo "❌ Some performance tests failed"
    echo "📁 Check test-results/ for Lighthouse reports"
    echo ""
    echo "Common issues to check:"
    echo "  - Large bundle sizes"
    echo "  - Unoptimized images"
    echo "  - Render-blocking resources"
    echo "  - Poor Core Web Vitals (LCP, FID, CLS)"
    exit $EXIT_CODE
fi

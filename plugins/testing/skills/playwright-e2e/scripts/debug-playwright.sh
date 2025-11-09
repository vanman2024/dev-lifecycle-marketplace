#!/bin/bash
# debug-playwright.sh - Run tests in debug mode with inspector
set -euo pipefail

TEST_FILE="${1:-}"

if [ -z "$TEST_FILE" ]; then
    echo "❌ Error: Test file required"
    echo "Usage: $0 <test-file>"
    echo "Example: $0 tests/e2e/login.spec.ts"
    exit 1
fi

if [ ! -f "$TEST_FILE" ]; then
    echo "❌ Error: Test file not found: $TEST_FILE"
    exit 1
fi

echo "🎭 Running Playwright Test in Debug Mode..."
echo "📝 Test file: $TEST_FILE"
echo ""

# Check if Playwright is installed
if ! command -v npx &> /dev/null || ! npm list @playwright/test &> /dev/null; then
    echo "❌ Error: Playwright not installed"
    echo "Run: npm install -D @playwright/test"
    exit 1
fi

echo "🔍 Debug Features Enabled:"
echo "  - Playwright Inspector"
echo "  - Headed mode (visible browser)"
echo "  - Slow motion (500ms delays)"
echo "  - Trace recording"
echo ""
echo "💡 Debug Tips:"
echo "  - Click 'Step Over' to execute actions one at a time"
echo "  - Use 'Resume' to continue execution"
echo "  - Click on actions to see element selectors"
echo "  - Check the 'Console' tab for logs"
echo ""

# Create debug output directory
mkdir -p test-results/debug

# Run test in debug mode
PWDEBUG=1 npx playwright test "$TEST_FILE" \
    --headed \
    --project=chromium \
    --workers=1 \
    --max-failures=1 \
    --timeout=0 \
    --retries=0

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ Test passed in debug mode!"
else
    echo ""
    echo "❌ Test failed (exit code: $EXIT_CODE)"
    echo "📁 Check test-results/ directory for screenshots and traces"
fi

echo ""
echo "📊 View trace: npx playwright show-trace test-results/[trace-file].zip"

exit $EXIT_CODE

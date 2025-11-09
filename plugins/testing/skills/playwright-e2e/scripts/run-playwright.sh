#!/bin/bash
# run-playwright.sh - Execute Playwright tests with various options
set -euo pipefail

# Default values
TEST_PATTERN="${1:-}"
BROWSER="${2:-chromium}"
EXTRA_ARGS="${@:3}"

echo "🎭 Running Playwright Tests..."

# Check if Playwright is installed
if ! command -v npx &> /dev/null || ! npm list @playwright/test &> /dev/null; then
    echo "❌ Error: Playwright not installed"
    echo "Run: npm install -D @playwright/test"
    exit 1
fi

# Build the command
CMD="npx playwright test"

# Add test pattern if provided
if [ -n "$TEST_PATTERN" ]; then
    CMD="$CMD $TEST_PATTERN"
fi

# Add browser project filter
if [ "$BROWSER" != "all" ]; then
    CMD="$CMD --project=$BROWSER"
fi

# Add extra arguments
if [ -n "$EXTRA_ARGS" ]; then
    CMD="$CMD $EXTRA_ARGS"
fi

echo "📝 Command: $CMD"
echo ""

# Execute tests
eval $CMD

# Check exit code
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
    echo "📊 View HTML report: npx playwright show-report"
else
    echo ""
    echo "❌ Some tests failed (exit code: $EXIT_CODE)"
    echo "🔍 Debug: npx playwright test --debug"
    echo "📊 View report: npx playwright show-report"
fi

exit $EXIT_CODE

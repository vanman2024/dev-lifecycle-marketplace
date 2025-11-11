#!/bin/bash
# Run visual regression tests with Playwright

set -e

TEST_PATTERN="${1:-}"
UPDATE_SNAPSHOTS="${2:-false}"

if [ ! -f "playwright.visual.config.ts" ]; then
    echo "❌ Playwright visual config not found"
    echo "Run init-frontend-tests.sh first"
    exit 1
fi

echo "📸 Running visual regression tests..."

if [ "$UPDATE_SNAPSHOTS" = "true" ] || [ "$UPDATE_SNAPSHOTS" = "--update-snapshots" ]; then
    echo "⚠️  Updating snapshots..."
    if [ -n "$TEST_PATTERN" ]; then
        npx playwright test "$TEST_PATTERN" --config=playwright.visual.config.ts --update-snapshots
    else
        npx playwright test --config=playwright.visual.config.ts --update-snapshots
    fi
else
    if [ -n "$TEST_PATTERN" ]; then
        npx playwright test "$TEST_PATTERN" --config=playwright.visual.config.ts
    else
        npx playwright test --config=playwright.visual.config.ts
    fi
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All visual regression tests passed!"
else
    echo "❌ Some visual regression tests failed"
    echo "📁 Check test-results/ for diff images"
    echo "💡 To update snapshots: $0 \"$TEST_PATTERN\" --update-snapshots"
    exit $EXIT_CODE
fi

#!/bin/bash
# Run accessibility tests with axe-core

set -e

TEST_PATTERN="${1:-}"

if [ ! -f "playwright.a11y.config.ts" ]; then
    echo "❌ Playwright accessibility config not found"
    echo "Run init-frontend-tests.sh first"
    exit 1
fi

echo "♿ Running accessibility tests with axe-core..."

if [ -n "$TEST_PATTERN" ]; then
    npx playwright test "$TEST_PATTERN" --config=playwright.a11y.config.ts
else
    npx playwright test --config=playwright.a11y.config.ts
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All accessibility tests passed!"
    echo "♿ No WCAG violations found"
else
    echo "❌ Accessibility violations found"
    echo "📁 Check test-results/ for detailed reports"
    echo ""
    echo "Common violations to check:"
    echo "  - Missing alt text on images"
    echo "  - Missing form labels"
    echo "  - Insufficient color contrast"
    echo "  - Missing ARIA attributes"
    echo "  - Keyboard navigation issues"
    exit $EXIT_CODE
fi

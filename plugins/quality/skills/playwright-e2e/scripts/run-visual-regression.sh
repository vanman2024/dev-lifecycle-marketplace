#!/bin/bash
# run-visual-regression.sh - Execute visual regression tests
set -euo pipefail

TEST_PATTERN="${1:-*visual*.spec.ts}"
UPDATE_SNAPSHOTS="${2:-false}"

echo "🎭 Running Visual Regression Tests..."

# Check if Playwright is installed
if ! command -v npx &> /dev/null || ! npm list @playwright/test &> /dev/null; then
    echo "❌ Error: Playwright not installed"
    echo "Run: npm install -D @playwright/test"
    exit 1
fi

# Build command
CMD="npx playwright test $TEST_PATTERN"

# Add update snapshots flag if requested
if [ "$UPDATE_SNAPSHOTS" == "true" ] || [ "$UPDATE_SNAPSHOTS" == "update" ]; then
    echo "📸 Updating baseline snapshots..."
    CMD="$CMD --update-snapshots"
else
    echo "🔍 Comparing against baseline snapshots..."
fi

echo "📝 Command: $CMD"
echo ""

# Create snapshots directory if it doesn't exist
mkdir -p tests/e2e/__snapshots__

# Execute tests
eval $CMD

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All visual regression tests passed!"
    if [ "$UPDATE_SNAPSHOTS" == "true" ] || [ "$UPDATE_SNAPSHOTS" == "update" ]; then
        echo "📸 Baseline snapshots updated successfully"
        echo "⚠️  Remember to commit the updated snapshots to version control"
    fi
else
    echo ""
    echo "❌ Visual regression tests failed!"
    echo ""
    echo "🔍 Analyzing failures:"

    # Check for diff images
    DIFF_COUNT=$(find test-results -name "*-diff.png" 2>/dev/null | wc -l)

    if [ $DIFF_COUNT -gt 0 ]; then
        echo "  - Found $DIFF_COUNT visual difference(s)"
        echo "  - Diff images saved in test-results/"
        echo ""
        echo "📊 View differences:"
        find test-results -name "*-diff.png" | while read -r file; do
            echo "  - $file"
        done
    fi

    echo ""
    echo "💡 Next steps:"
    echo "  1. Review diff images in test-results/"
    echo "  2. Check if changes are intentional"
    echo "  3. If changes are correct, update snapshots:"
    echo "     bash $0 $TEST_PATTERN update"
    echo "  4. View HTML report: npx playwright show-report"
fi

echo ""
echo "📁 Snapshot location: tests/e2e/__snapshots__/"

exit $EXIT_CODE

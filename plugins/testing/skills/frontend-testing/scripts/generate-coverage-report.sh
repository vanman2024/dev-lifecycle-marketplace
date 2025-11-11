#!/bin/bash
# Generate comprehensive coverage report

set -e

OUTPUT_DIR="${1:-test-results/coverage}"

echo "📊 Generating comprehensive coverage report..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run component tests with coverage
echo "🧪 Running component tests with coverage..."
if [ -f "jest.config.js" ] || [ -f "jest.config.ts" ]; then
    npx jest --coverage --coverageDirectory="$OUTPUT_DIR/component"
elif [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ]; then
    npx vitest run --coverage --coverage.reportsDirectory="$OUTPUT_DIR/component"
else
    echo "⚠️  No testing framework found, skipping component coverage"
fi

# Count visual regression tests
echo "📸 Counting visual regression tests..."
if [ -d "tests/visual" ]; then
    VISUAL_TESTS=$(find tests/visual -name "*.spec.ts" -o -name "*.spec.js" | wc -l)
    echo "Visual regression tests: $VISUAL_TESTS" > "$OUTPUT_DIR/visual-summary.txt"
else
    echo "Visual regression tests: 0" > "$OUTPUT_DIR/visual-summary.txt"
fi

# Count accessibility tests
echo "♿ Counting accessibility tests..."
if [ -d "tests/a11y" ]; then
    A11Y_TESTS=$(find tests/a11y -name "*.spec.ts" -o -name "*.spec.js" | wc -l)
    echo "Accessibility tests: $A11Y_TESTS" > "$OUTPUT_DIR/a11y-summary.txt"
else
    echo "Accessibility tests: 0" > "$OUTPUT_DIR/a11y-summary.txt"
fi

# Count performance tests
echo "⚡ Counting performance tests..."
if [ -d "tests/performance" ]; then
    PERF_TESTS=$(find tests/performance -name "*.spec.ts" -o -name "*.spec.js" | wc -l)
    echo "Performance tests: $PERF_TESTS" > "$OUTPUT_DIR/performance-summary.txt"
else
    echo "Performance tests: 0" > "$OUTPUT_DIR/performance-summary.txt"
fi

# Generate combined summary
echo "📝 Generating combined summary..."
cat > "$OUTPUT_DIR/summary.md" <<EOF
# Frontend Test Coverage Summary

Generated: $(date)

## Component Test Coverage

$(if [ -f "$OUTPUT_DIR/component/coverage-summary.json" ]; then
    cat "$OUTPUT_DIR/component/coverage-summary.json"
else
    echo "No component coverage data available"
fi)

## Visual Regression Tests

$(cat "$OUTPUT_DIR/visual-summary.txt")

## Accessibility Tests

$(cat "$OUTPUT_DIR/a11y-summary.txt")

## Performance Tests

$(cat "$OUTPUT_DIR/performance-summary.txt")

## Coverage by Type

- **Component Tests**: See $OUTPUT_DIR/component/index.html
- **Visual Tests**: $VISUAL_TESTS test files
- **Accessibility Tests**: $A11Y_TESTS test files
- **Performance Tests**: $PERF_TESTS test files

## Recommendations

1. Maintain >80% component test coverage
2. Add visual regression for all pages
3. Add accessibility tests for interactive components
4. Add performance tests for critical pages
EOF

echo "✅ Coverage report generated!"
echo "📁 Report location: $OUTPUT_DIR/"
echo "🌐 View HTML report: $OUTPUT_DIR/component/index.html"
echo "📄 View summary: $OUTPUT_DIR/summary.md"

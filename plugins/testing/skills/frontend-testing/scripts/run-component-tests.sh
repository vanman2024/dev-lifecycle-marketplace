#!/bin/bash
# Run component tests (Jest or Vitest)

set -e

TEST_PATTERN="${1:-}"
OPTIONS="${2:-}"

# Detect testing framework
if [ -f "jest.config.js" ] || [ -f "jest.config.ts" ]; then
    TEST_FRAMEWORK="jest"
elif [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ]; then
    TEST_FRAMEWORK="vitest"
else
    echo "❌ No testing framework configuration found"
    echo "Run init-frontend-tests.sh first"
    exit 1
fi

echo "🧪 Running component tests with $TEST_FRAMEWORK..."

if [ "$TEST_FRAMEWORK" = "jest" ]; then
    if [ -n "$TEST_PATTERN" ]; then
        npx jest "$TEST_PATTERN" $OPTIONS
    else
        npx jest $OPTIONS
    fi
else
    if [ -n "$TEST_PATTERN" ]; then
        npx vitest run "$TEST_PATTERN" $OPTIONS
    else
        npx vitest run $OPTIONS
    fi
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All component tests passed!"
else
    echo "❌ Some component tests failed"
    exit $EXIT_CODE
fi

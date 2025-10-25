#!/usr/bin/env bash
set -euo pipefail

# Analyze code for performance issues
# Returns: Performance bottlenecks found

TARGET="${1:-.}"

echo "Analyzing performance in: $TARGET"

# Check for nested loops (O(n²))
NESTED_LOOPS=$(grep -rn "for.*for\|while.*while" "$TARGET" \
  --include="*.js" --include="*.ts" --include="*.py" \
  --exclude-dir=node_modules --exclude-dir=venv \
  2>/dev/null || true)

if [ -n "$NESTED_LOOPS" ]; then
  echo "⚠️ Potential O(n²) nested loops found:"
  echo "$NESTED_LOOPS"
fi

# Check for console.log/print statements
DEBUG_STMTS=$(grep -rn "console\.log\|print(" "$TARGET" \
  --include="*.js" --include="*.ts" --include="*.py" \
  --exclude-dir=node_modules --exclude-dir=venv \
  2>/dev/null | wc -l)

if [ "$DEBUG_STMTS" -gt 0 ]; then
  echo "⚠️ Found $DEBUG_STMTS debug statements (console.log/print)"
fi

echo "Performance analysis complete"

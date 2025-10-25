#!/usr/bin/env bash
set -euo pipefail

# Check function complexity (simple cyclomatic complexity estimate)

TARGET_FILE="${1:-}"

if [ -z "$TARGET_FILE" ]; then
    echo "Usage: $0 <file-path>"
    exit 1
fi

echo "Checking complexity for: $TARGET_FILE"
echo ""

# Simple complexity estimate based on control flow keywords
grep -nE "(if|for|while|switch|case|\&\&|\|\|)" "$TARGET_FILE" | while read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    echo "Line $line_num: $(echo "$line" | cut -d: -f2-)"
done | head -20

echo ""
total_complexity=$(grep -cE "(if|for|while|switch|case|\&\&|\|\|)" "$TARGET_FILE" || echo "0")
echo "Total complexity indicators: $total_complexity"

if [ "$total_complexity" -gt 50 ]; then
    echo "⚠️  High complexity - consider refactoring"
elif [ "$total_complexity" -gt 20 ]; then
    echo "⚠️  Moderate complexity - review functions"
else
    echo "✅ Acceptable complexity"
fi

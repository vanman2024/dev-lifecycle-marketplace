#!/usr/bin/env bash
set -euo pipefail

# Detect duplicate code patterns

TARGET_DIR="${1:-.}"

echo "Scanning for duplicate code in: $TARGET_DIR"
echo ""

# Find duplicate lines across files
find "$TARGET_DIR" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" \) | while read -r file; do
    # Skip node_modules and other common exclusions
    if echo "$file" | grep -qE "(node_modules|\.git|__pycache__|\.pyc)"; then
        continue
    fi

    # Look for lines longer than 40 chars (likely not trivial)
    awk 'length($0) > 40 { print }' "$file" | sort | uniq -d | while read -r line; do
        if [ -n "$line" ]; then
            echo "Duplicate found:"
            echo "  Line: ${line:0:80}"
            grep -n "$line" "$file" | head -3
            echo ""
        fi
    done
done

echo "✅ Duplicate detection complete"

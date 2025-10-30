#!/bin/bash
# extract-components.sh - Extracts architecture components from document

set -e

ARCH_FILE="${1:-ARCHITECTURE.md}"

if [ ! -f "$ARCH_FILE" ]; then
    echo "❌ Architecture file not found: $ARCH_FILE"
    exit 1
fi

echo "Extracting components from $ARCH_FILE..."

# Find all ### Component sections
grep -E '^### .+' "$ARCH_FILE" | sed 's/^### //' | sort -u

echo "✅ Component extraction complete"

#!/bin/bash
# extract-tasks.sh - Extracts task list from specification

set -e

SPEC_FILE="${1:-spec.md}"
OUTPUT_FILE="${2:-tasks.md}"

if [ ! -f "$SPEC_FILE" ]; then
    echo "❌ Spec file not found: $SPEC_FILE"
    exit 1
fi

echo "Extracting tasks from $SPEC_FILE..."

# Extract all checkbox items
grep -E '^\s*-\s+\[[ x]\]' "$SPEC_FILE" > "$OUTPUT_FILE" 2>/dev/null || echo "# Tasks" > "$OUTPUT_FILE"

echo "✅ Tasks extracted to $OUTPUT_FILE"
cat "$OUTPUT_FILE"

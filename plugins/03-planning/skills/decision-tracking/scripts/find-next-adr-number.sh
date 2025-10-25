#!/bin/bash
# find-next-adr-number.sh - Finds the next available ADR number

set -e

ADR_DIR="${1:-docs/decisions}"

mkdir -p "$ADR_DIR"

# Find highest ADR number
HIGHEST=$(find "$ADR_DIR" -name "ADR-*.md" 2>/dev/null | \
    sed 's/.*ADR-\([0-9]*\).*/\1/' | \
    sort -n | \
    tail -1)

if [ -z "$HIGHEST" ]; then
    NEXT="0001"
else
    NEXT=$(printf "%04d" $((10#$HIGHEST + 1)))
fi

echo "$NEXT"

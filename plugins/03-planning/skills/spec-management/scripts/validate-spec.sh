#!/bin/bash
# validate-spec.sh - Validates specification document structure

set -e

SPEC_FILE="${1:-spec.md}"

if [ ! -f "$SPEC_FILE" ]; then
    echo "❌ Spec file not found: $SPEC_FILE"
    exit 1
fi

echo "Validating spec: $SPEC_FILE"

# Required sections
REQUIRED_SECTIONS=(
    "Overview"
    "Requirements"
    "Acceptance Criteria"
)

MISSING_SECTIONS=()

for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -q "^## $section" "$SPEC_FILE"; then
        MISSING_SECTIONS+=("$section")
    fi
done

if [ ${#MISSING_SECTIONS[@]} -gt 0 ]; then
    echo "❌ Missing required sections:"
    for section in "${MISSING_SECTIONS[@]}"; do
        echo "  - $section"
    done
    exit 1
fi

echo "✅ Spec validation passed"

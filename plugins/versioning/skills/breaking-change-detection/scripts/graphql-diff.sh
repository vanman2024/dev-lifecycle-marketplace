#!/usr/bin/env bash
# Script: graphql-diff.sh
# Purpose: Compare GraphQL schemas and detect breaking changes
# Usage: bash graphql-diff.sh <old-schema.graphql> <new-schema.graphql> [--output report.md]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

OLD_SCHEMA="${1:?Usage: $0 <old-schema.graphql> <new-schema.graphql> [--output report.md]}"
NEW_SCHEMA="${2:?Usage: $0 <old-schema.graphql> <new-schema.graphql> [--output report.md]}"
OUTPUT_FILE=""

# Parse optional output argument
shift 2
while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 2
            ;;
    esac
done

# Check input files exist
[[ ! -f "$OLD_SCHEMA" ]] && { echo "Error: Old schema not found: $OLD_SCHEMA"; exit 2; }
[[ ! -f "$NEW_SCHEMA" ]] && { echo "Error: New schema not found: $NEW_SCHEMA"; exit 2; }

echo "🔍 Analyzing GraphQL schemas..."
echo "   Old: $OLD_SCHEMA"
echo "   New: $NEW_SCHEMA"
echo ""

# Initialize breaking changes counter
BREAKING_COUNT=0
NON_BREAKING_COUNT=0

# Output buffer
REPORT=""

# Helper function to add to report
add_to_report() {
    REPORT+="$1\n"
}

# Extract type definitions
echo "📊 Checking for removed types..."
OLD_TYPES=$(grep -E "^type [A-Z]" "$OLD_SCHEMA" | awk '{print $2}' | sort || echo "")
NEW_TYPES=$(grep -E "^type [A-Z]" "$NEW_SCHEMA" | awk '{print $2}' | sort || echo "")

REMOVED_TYPES=$(comm -23 <(echo "$OLD_TYPES") <(echo "$NEW_TYPES"))

if [[ -n "$REMOVED_TYPES" ]]; then
    echo -e "${RED}❌ BREAKING: Removed types detected${NC}"
    while IFS= read -r type; do
        [[ -z "$type" ]] && continue
        echo "   - $type"
        add_to_report "### ❌ BREAKING: Removed Type\n**Type:** \`$type\`\n**Impact:** Queries using this type will fail\n"
        ((BREAKING_COUNT++))
    done <<< "$REMOVED_TYPES"
else
    echo -e "${GREEN}✅ No removed types${NC}"
fi

echo ""

# Check for field removals in existing types
echo "📊 Checking for removed fields..."

for type in $OLD_TYPES; do
    # Check if type still exists
    if echo "$NEW_TYPES" | grep -q "^${type}$"; then
        # Extract fields for this type
        OLD_FIELDS=$(sed -n "/^type ${type}/,/^}/p" "$OLD_SCHEMA" | \
            grep -E "^[[:space:]]+[a-z]" | \
            awk '{print $1}' | \
            sed 's/:$//' | \
            sort || echo "")

        NEW_FIELDS=$(sed -n "/^type ${type}/,/^}/p" "$NEW_SCHEMA" | \
            grep -E "^[[:space:]]+[a-z]" | \
            awk '{print $1}' | \
            sed 's/:$//' | \
            sort || echo "")

        REMOVED_FIELDS=$(comm -23 <(echo "$OLD_FIELDS") <(echo "$NEW_FIELDS"))

        if [[ -n "$REMOVED_FIELDS" ]]; then
            echo -e "${RED}❌ BREAKING: Removed fields in type '$type'${NC}"
            while IFS= read -r field; do
                [[ -z "$field" ]] && continue
                echo "   - $field"
                add_to_report "### ❌ BREAKING: Removed Field\n**Type:** \`$type\`\n**Field:** \`$field\`\n**Impact:** Queries selecting this field will fail\n"
                ((BREAKING_COUNT++))
            done <<< "$REMOVED_FIELDS"
        fi

        # Check for added non-nullable fields (breaking)
        ADDED_FIELDS=$(comm -13 <(echo "$OLD_FIELDS") <(echo "$NEW_FIELDS"))

        if [[ -n "$ADDED_FIELDS" ]]; then
            while IFS= read -r field; do
                [[ -z "$field" ]] && continue

                # Check if field is non-nullable (ends with !)
                FIELD_DEF=$(sed -n "/^type ${type}/,/^}/p" "$NEW_SCHEMA" | grep -E "^[[:space:]]+${field}:" || echo "")

                if echo "$FIELD_DEF" | grep -q "!"; then
                    echo -e "${YELLOW}⚠️  WARNING: Added non-nullable field in '$type': $field${NC}"
                    add_to_report "### ⚠️ WARNING: Added Non-Nullable Field\n**Type:** \`$type\`\n**Field:** \`$field\`\n**Impact:** May require client updates if field is queried\n"
                    ((NON_BREAKING_COUNT++))
                else
                    echo -e "${GREEN}✅ Added nullable field in '$type': $field${NC}"
                    ((NON_BREAKING_COUNT++))
                fi
            done <<< "$ADDED_FIELDS"
        fi
    fi
done

echo ""

# Check for enum value removals
echo "📊 Checking for removed enum values..."
OLD_ENUMS=$(grep -E "^enum [A-Z]" "$OLD_SCHEMA" | awk '{print $2}' | sort || echo "")
NEW_ENUMS=$(grep -E "^enum [A-Z]" "$NEW_SCHEMA" | awk '{print $2}' | sort || echo "")

for enum in $OLD_ENUMS; do
    if echo "$NEW_ENUMS" | grep -q "^${enum}$"; then
        OLD_VALUES=$(sed -n "/^enum ${enum}/,/^}/p" "$OLD_SCHEMA" | \
            grep -E "^[[:space:]]+[A-Z]" | \
            awk '{print $1}' | \
            sort || echo "")

        NEW_VALUES=$(sed -n "/^enum ${enum}/,/^}/p" "$NEW_SCHEMA" | \
            grep -E "^[[:space:]]+[A-Z]" | \
            awk '{print $1}' | \
            sort || echo "")

        REMOVED_VALUES=$(comm -23 <(echo "$OLD_VALUES") <(echo "$NEW_VALUES"))

        if [[ -n "$REMOVED_VALUES" ]]; then
            echo -e "${RED}❌ BREAKING: Removed enum values in '$enum'${NC}"
            while IFS= read -r value; do
                [[ -z "$value" ]] && continue
                echo "   - $value"
                add_to_report "### ❌ BREAKING: Removed Enum Value\n**Enum:** \`$enum\`\n**Value:** \`$value\`\n**Impact:** Queries using this value will fail validation\n"
                ((BREAKING_COUNT++))
            done <<< "$REMOVED_VALUES"
        fi
    fi
done

# Check for removed enums
REMOVED_ENUMS=$(comm -23 <(echo "$OLD_ENUMS") <(echo "$NEW_ENUMS"))

if [[ -n "$REMOVED_ENUMS" ]]; then
    echo -e "${RED}❌ BREAKING: Removed enums detected${NC}"
    while IFS= read -r enum; do
        [[ -z "$enum" ]] && continue
        echo "   - $enum"
        add_to_report "### ❌ BREAKING: Removed Enum\n**Enum:** \`$enum\`\n**Impact:** All references to this enum will fail\n"
        ((BREAKING_COUNT++))
    done <<< "$REMOVED_ENUMS"
fi

echo ""

# Check for interface changes
echo "📊 Checking for interface modifications..."
OLD_INTERFACES=$(grep -E "^interface [A-Z]" "$OLD_SCHEMA" | awk '{print $2}' | sort || echo "")
NEW_INTERFACES=$(grep -E "^interface [A-Z]" "$NEW_SCHEMA" | awk '{print $2}' | sort || echo "")

REMOVED_INTERFACES=$(comm -23 <(echo "$OLD_INTERFACES") <(echo "$NEW_INTERFACES"))

if [[ -n "$REMOVED_INTERFACES" ]]; then
    echo -e "${RED}❌ BREAKING: Removed interfaces detected${NC}"
    while IFS= read -r interface; do
        [[ -z "$interface" ]] && continue
        echo "   - $interface"
        add_to_report "### ❌ BREAKING: Removed Interface\n**Interface:** \`$interface\`\n**Impact:** Types implementing this interface and queries using it will fail\n"
        ((BREAKING_COUNT++))
    done <<< "$REMOVED_INTERFACES"
fi

echo ""

# Summary
echo "================================"
echo "📋 Summary"
echo "================================"
echo -e "${RED}Breaking changes: $BREAKING_COUNT${NC}"
echo -e "${YELLOW}Non-breaking changes: $NON_BREAKING_COUNT${NC}"
echo ""

# Generate report if output file specified
if [[ -n "$OUTPUT_FILE" ]]; then
    {
        echo "# GraphQL Schema Breaking Change Report"
        echo ""
        echo "**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo "**Old Schema:** $OLD_SCHEMA"
        echo "**New Schema:** $NEW_SCHEMA"
        echo ""
        echo "## Summary"
        echo ""
        echo "- **Breaking Changes:** $BREAKING_COUNT"
        echo "- **Non-Breaking Changes:** $NON_BREAKING_COUNT"
        echo ""
        if [[ $BREAKING_COUNT -gt 0 ]]; then
            echo "⚠️ **RECOMMENDATION:** This schema change requires a **MAJOR version bump** (e.g., v2.0.0)"
        else
            echo "✅ **RECOMMENDATION:** This schema change requires a **MINOR version bump** (e.g., v1.1.0)"
        fi
        echo ""
        echo "## Detected Changes"
        echo ""
        echo -e "$REPORT"
        echo ""
        echo "## Migration Considerations"
        echo ""
        echo "For GraphQL schema changes:"
        echo ""
        echo "1. **Field Removals:** Update all client queries to remove references"
        echo "2. **Type Removals:** Refactor queries using fragments or inline fragments"
        echo "3. **Enum Changes:** Update hardcoded enum values in client code"
        echo "4. **Non-Nullable Fields:** Ensure clients can handle new required fields"
        echo ""
    } > "$OUTPUT_FILE"

    echo "📄 Report written to: $OUTPUT_FILE"
    echo ""
fi

# Exit with appropriate code
if [[ $BREAKING_COUNT -gt 0 ]]; then
    echo "❌ Breaking changes detected - MAJOR version bump required"
    exit 1
else
    echo "✅ No breaking changes detected"
    exit 0
fi

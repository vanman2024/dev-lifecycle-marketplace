#!/usr/bin/env bash
# Script: schema-compare.sh
# Purpose: Compare database schemas and detect breaking changes
# Usage: bash schema-compare.sh <old-schema.sql> <new-schema.sql> [--output report.md]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

OLD_SCHEMA="${1:?Usage: $0 <old-schema.sql> <new-schema.sql> [--output report.md]}"
NEW_SCHEMA="${2:?Usage: $0 <old-schema.sql> <new-schema.sql> [--output report.md]}"
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

echo "🔍 Analyzing database schemas..."
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

# Extract table names
echo "📊 Checking for dropped tables..."
OLD_TABLES=$(grep -i "CREATE TABLE" "$OLD_SCHEMA" | sed -E 's/.*CREATE TABLE[^a-zA-Z_]*([a-zA-Z_][a-zA-Z0-9_]*).*/\1/' | sort || echo "")
NEW_TABLES=$(grep -i "CREATE TABLE" "$NEW_SCHEMA" | sed -E 's/.*CREATE TABLE[^a-zA-Z_]*([a-zA-Z_][a-zA-Z0-9_]*).*/\1/' | sort || echo "")

DROPPED_TABLES=$(comm -23 <(echo "$OLD_TABLES") <(echo "$NEW_TABLES"))

if [[ -n "$DROPPED_TABLES" ]]; then
    echo -e "${RED}❌ BREAKING: Dropped tables detected${NC}"
    while IFS= read -r table; do
        [[ -z "$table" ]] && continue
        echo "   - $table"
        add_to_report "### ❌ BREAKING: Dropped Table\n**Table:** \`$table\`\n**Impact:** All queries referencing this table will fail\n**Migration Required:** Export data before dropping, update application code\n"
        ((BREAKING_COUNT++))
    done <<< "$DROPPED_TABLES"
else
    echo -e "${GREEN}✅ No dropped tables${NC}"
fi

echo ""

# Check for added tables (non-breaking)
ADDED_TABLES=$(comm -13 <(echo "$OLD_TABLES") <(echo "$NEW_TABLES"))

if [[ -n "$ADDED_TABLES" ]]; then
    echo -e "${GREEN}✅ Added tables (non-breaking)${NC}"
    while IFS= read -r table; do
        [[ -z "$table" ]] && continue
        echo "   - $table"
        ((NON_BREAKING_COUNT++))
    done <<< "$ADDED_TABLES"
fi

echo ""

# Check for column changes in existing tables
echo "📊 Checking for column modifications..."

for table in $OLD_TABLES; do
    # Check if table still exists
    if echo "$NEW_TABLES" | grep -q "^${table}$"; then
        # Extract columns for this table from old schema
        OLD_COLS=$(sed -n "/CREATE TABLE.*${table}/,/);/p" "$OLD_SCHEMA" | \
            grep -E "^[[:space:]]*[a-zA-Z_]" | \
            grep -v "PRIMARY KEY" | \
            grep -v "FOREIGN KEY" | \
            grep -v "UNIQUE" | \
            grep -v "CHECK" | \
            sed 's/,$//' | \
            awk '{print $1}' | \
            sort || echo "")

        NEW_COLS=$(sed -n "/CREATE TABLE.*${table}/,/);/p" "$NEW_SCHEMA" | \
            grep -E "^[[:space:]]*[a-zA-Z_]" | \
            grep -v "PRIMARY KEY" | \
            grep -v "FOREIGN KEY" | \
            grep -v "UNIQUE" | \
            grep -v "CHECK" | \
            sed 's/,$//' | \
            awk '{print $1}' | \
            sort || echo "")

        # Check for removed columns
        REMOVED_COLS=$(comm -23 <(echo "$OLD_COLS") <(echo "$NEW_COLS"))

        if [[ -n "$REMOVED_COLS" ]]; then
            echo -e "${RED}❌ BREAKING: Removed columns in table '$table'${NC}"
            while IFS= read -r col; do
                [[ -z "$col" ]] && continue
                echo "   - $col"
                add_to_report "### ❌ BREAKING: Removed Column\n**Table:** \`$table\`\n**Column:** \`$col\`\n**Impact:** SELECT queries referencing this column will fail\n**Migration Required:** Update all queries, remove column references in code\n"
                ((BREAKING_COUNT++))
            done <<< "$REMOVED_COLS"
        fi

        # Check for added columns (non-breaking if nullable)
        ADDED_COLS=$(comm -13 <(echo "$OLD_COLS") <(echo "$NEW_COLS"))

        if [[ -n "$ADDED_COLS" ]]; then
            while IFS= read -r col; do
                [[ -z "$col" ]] && continue

                # Check if column is NOT NULL
                COL_DEF=$(sed -n "/CREATE TABLE.*${table}/,/);/p" "$NEW_SCHEMA" | grep -E "^[[:space:]]*${col}" || echo "")

                if echo "$COL_DEF" | grep -qi "NOT NULL"; then
                    # Check if has default value
                    if echo "$COL_DEF" | grep -qi "DEFAULT"; then
                        echo -e "${GREEN}✅ Added NOT NULL column with DEFAULT in '$table': $col${NC}"
                        ((NON_BREAKING_COUNT++))
                    else
                        echo -e "${RED}❌ BREAKING: Added NOT NULL column without DEFAULT in '$table': $col${NC}"
                        add_to_report "### ❌ BREAKING: Added NOT NULL Column Without Default\n**Table:** \`$table\`\n**Column:** \`$col\`\n**Impact:** INSERT statements without this column will fail\n**Migration Required:** Add DEFAULT value or make column nullable\n"
                        ((BREAKING_COUNT++))
                    fi
                else
                    echo -e "${GREEN}✅ Added nullable column in '$table': $col${NC}"
                    ((NON_BREAKING_COUNT++))
                fi
            done <<< "$ADDED_COLS"
        fi
    fi
done

echo ""

# Check for constraint changes
echo "📊 Checking for constraint modifications..."

# Check for removed foreign keys
OLD_FKS=$(grep -i "FOREIGN KEY" "$OLD_SCHEMA" | sed 's/[[:space:]]*$//' | sort || echo "")
NEW_FKS=$(grep -i "FOREIGN KEY" "$NEW_SCHEMA" | sed 's/[[:space:]]*$//' | sort || echo "")

FK_COUNT_OLD=$(echo "$OLD_FKS" | grep -c "FOREIGN KEY" || echo "0")
FK_COUNT_NEW=$(echo "$NEW_FKS" | grep -c "FOREIGN KEY" || echo "0")

if [[ $FK_COUNT_NEW -lt $FK_COUNT_OLD ]]; then
    echo -e "${RED}❌ BREAKING: Foreign key constraints removed${NC}"
    echo "   Old count: $FK_COUNT_OLD"
    echo "   New count: $FK_COUNT_NEW"
    add_to_report "### ❌ BREAKING: Foreign Key Constraints Removed\n**Impact:** Referential integrity may be violated\n**Migration Required:** Review data consistency, update application validation logic\n"
    ((BREAKING_COUNT++))
fi

# Check for removed unique constraints
OLD_UNIQUE=$(grep -i "UNIQUE" "$OLD_SCHEMA" | sed 's/[[:space:]]*$//' | sort || echo "")
NEW_UNIQUE=$(grep -i "UNIQUE" "$NEW_SCHEMA" | sed 's/[[:space:]]*$//' | sort || echo "")

UNIQUE_COUNT_OLD=$(echo "$OLD_UNIQUE" | grep -c "UNIQUE" || echo "0")
UNIQUE_COUNT_NEW=$(echo "$NEW_UNIQUE" | grep -c "UNIQUE" || echo "0")

if [[ $UNIQUE_COUNT_NEW -lt $UNIQUE_COUNT_OLD ]]; then
    echo -e "${YELLOW}⚠️  WARNING: Unique constraints removed (potentially breaking)${NC}"
    echo "   Old count: $UNIQUE_COUNT_OLD"
    echo "   New count: $UNIQUE_COUNT_NEW"
    add_to_report "### ⚠️ WARNING: Unique Constraints Removed\n**Impact:** Duplicate values now allowed, may cause data inconsistencies\n**Migration Required:** Review application logic that relies on uniqueness\n"
    ((BREAKING_COUNT++))
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
        echo "# Database Schema Breaking Change Report"
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
            echo ""
            echo "**CRITICAL:** Ensure data migration scripts are prepared before deployment."
        else
            echo "✅ **RECOMMENDATION:** This schema change requires a **MINOR version bump** (e.g., v1.1.0)"
        fi
        echo ""
        echo "## Detected Changes"
        echo ""
        echo -e "$REPORT"
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

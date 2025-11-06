#!/usr/bin/env bash
# Script: openapi-diff.sh
# Purpose: Compare two OpenAPI specifications and detect breaking changes
# Usage: bash openapi-diff.sh <old-spec.yaml> <new-spec.yaml> [--output report.md]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

OLD_SPEC="${1:?Usage: $0 <old-spec> <new-spec> [--output report.md]}"
NEW_SPEC="${2:?Usage: $0 <old-spec> <new-spec> [--output report.md]}"
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

# Check dependencies
command -v jq >/dev/null 2>&1 || { echo "Error: jq is required but not installed."; exit 2; }
command -v yq >/dev/null 2>&1 || { echo "Error: yq is required but not installed."; exit 2; }

# Check input files exist
[[ ! -f "$OLD_SPEC" ]] && { echo "Error: Old spec not found: $OLD_SPEC"; exit 2; }
[[ ! -f "$NEW_SPEC" ]] && { echo "Error: New spec not found: $NEW_SPEC"; exit 2; }

echo "🔍 Analyzing OpenAPI specifications..."
echo "   Old: $OLD_SPEC"
echo "   New: $NEW_SPEC"
echo ""

# Convert YAML to JSON for easier parsing
OLD_JSON=$(mktemp)
NEW_JSON=$(mktemp)
trap "rm -f $OLD_JSON $NEW_JSON" EXIT

yq -o json "$OLD_SPEC" > "$OLD_JSON" 2>/dev/null || { echo "Error: Failed to parse old spec"; exit 3; }
yq -o json "$NEW_SPEC" > "$NEW_JSON" 2>/dev/null || { echo "Error: Failed to parse new spec"; exit 3; }

# Initialize breaking changes counter
BREAKING_COUNT=0
NON_BREAKING_COUNT=0

# Output buffer
REPORT=""

# Helper function to add to report
add_to_report() {
    REPORT+="$1\n"
}

# Check for removed paths (endpoints)
echo "📊 Checking for removed endpoints..."
OLD_PATHS=$(jq -r '.paths | keys[]' "$OLD_JSON" 2>/dev/null | sort)
NEW_PATHS=$(jq -r '.paths | keys[]' "$NEW_JSON" 2>/dev/null | sort)

REMOVED_PATHS=$(comm -23 <(echo "$OLD_PATHS") <(echo "$NEW_PATHS"))

if [[ -n "$REMOVED_PATHS" ]]; then
    echo -e "${RED}❌ BREAKING: Removed endpoints detected${NC}"
    while IFS= read -r path; do
        echo "   - $path"
        add_to_report "### ❌ BREAKING: Removed Endpoint\n**Path:** \`$path\`\n**Impact:** Clients calling this endpoint will receive 404 errors\n"
        ((BREAKING_COUNT++))
    done <<< "$REMOVED_PATHS"
else
    echo -e "${GREEN}✅ No removed endpoints${NC}"
fi

echo ""

# Check for changed HTTP methods
echo "📊 Checking for changed HTTP methods..."
for path in $NEW_PATHS; do
    # Get methods for this path in old spec
    OLD_METHODS=$(jq -r --arg path "$path" '.paths[$path] | keys[]' "$OLD_JSON" 2>/dev/null | grep -v '^parameters$' | sort || echo "")
    NEW_METHODS=$(jq -r --arg path "$path" '.paths[$path] | keys[]' "$NEW_JSON" 2>/dev/null | grep -v '^parameters$' | sort || echo "")

    if [[ -n "$OLD_METHODS" ]] && [[ -n "$NEW_METHODS" ]]; then
        REMOVED_METHODS=$(comm -23 <(echo "$OLD_METHODS") <(echo "$NEW_METHODS"))

        if [[ -n "$REMOVED_METHODS" ]]; then
            echo -e "${RED}❌ BREAKING: Removed methods on $path${NC}"
            while IFS= read -r method; do
                echo "   - $method"
                add_to_report "### ❌ BREAKING: Removed HTTP Method\n**Path:** \`$path\`\n**Method:** \`${method^^}\`\n**Impact:** Clients using this method will receive 405 Method Not Allowed\n"
                ((BREAKING_COUNT++))
            done <<< "$REMOVED_METHODS"
        fi
    fi
done

echo ""

# Check for required parameters added
echo "📊 Checking for new required parameters..."
for path in $NEW_PATHS; do
    NEW_METHODS=$(jq -r --arg path "$path" '.paths[$path] | keys[]' "$NEW_JSON" 2>/dev/null | grep -v '^parameters$' || echo "")

    for method in $NEW_METHODS; do
        # Check if path existed in old spec
        OLD_PATH_EXISTS=$(jq --arg path "$path" --arg method "$method" '.paths[$path][$method] // empty' "$OLD_JSON" 2>/dev/null)

        if [[ -n "$OLD_PATH_EXISTS" ]]; then
            # Get required parameters in new spec
            NEW_REQUIRED=$(jq -r --arg path "$path" --arg method "$method" \
                '.paths[$path][$method].parameters[]? | select(.required == true) | .name' \
                "$NEW_JSON" 2>/dev/null | sort || echo "")

            OLD_REQUIRED=$(jq -r --arg path "$path" --arg method "$method" \
                '.paths[$path][$method].parameters[]? | select(.required == true) | .name' \
                "$OLD_JSON" 2>/dev/null | sort || echo "")

            ADDED_REQUIRED=$(comm -13 <(echo "$OLD_REQUIRED") <(echo "$NEW_REQUIRED"))

            if [[ -n "$ADDED_REQUIRED" ]]; then
                echo -e "${RED}❌ BREAKING: Added required parameters on ${method^^} $path${NC}"
                while IFS= read -r param; do
                    echo "   - $param"
                    add_to_report "### ❌ BREAKING: Added Required Parameter\n**Path:** \`$path\`\n**Method:** \`${method^^}\`\n**Parameter:** \`$param\`\n**Impact:** Existing clients not providing this parameter will receive 400 errors\n"
                    ((BREAKING_COUNT++))
                done <<< "$ADDED_REQUIRED"
            fi
        fi
    done
done

echo ""

# Check for response schema changes (simplified)
echo "📊 Checking for response schema changes..."
for path in $NEW_PATHS; do
    NEW_METHODS=$(jq -r --arg path "$path" '.paths[$path] | keys[]' "$NEW_JSON" 2>/dev/null | grep -v '^parameters$' || echo "")

    for method in $NEW_METHODS; do
        OLD_PATH_EXISTS=$(jq --arg path "$path" --arg method "$method" '.paths[$path][$method] // empty' "$OLD_JSON" 2>/dev/null)

        if [[ -n "$OLD_PATH_EXISTS" ]]; then
            # Check if response structure changed
            OLD_RESPONSES=$(jq -c --arg path "$path" --arg method "$method" \
                '.paths[$path][$method].responses // {}' "$OLD_JSON" 2>/dev/null || echo "{}")
            NEW_RESPONSES=$(jq -c --arg path "$path" --arg method "$method" \
                '.paths[$path][$method].responses // {}' "$NEW_JSON" 2>/dev/null || echo "{}")

            if [[ "$OLD_RESPONSES" != "$NEW_RESPONSES" ]]; then
                # Check if 2xx responses were removed
                OLD_SUCCESS=$(echo "$OLD_RESPONSES" | jq -r 'keys[]' 2>/dev/null | grep '^2' || echo "")
                NEW_SUCCESS=$(echo "$NEW_RESPONSES" | jq -r 'keys[]' 2>/dev/null | grep '^2' || echo "")

                REMOVED_SUCCESS=$(comm -23 <(echo "$OLD_SUCCESS") <(echo "$NEW_SUCCESS"))

                if [[ -n "$REMOVED_SUCCESS" ]]; then
                    echo -e "${RED}❌ BREAKING: Removed success responses on ${method^^} $path${NC}"
                    while IFS= read -r code; do
                        echo "   - HTTP $code"
                        add_to_report "### ❌ BREAKING: Removed Success Response\n**Path:** \`$path\`\n**Method:** \`${method^^}\`\n**Status Code:** \`$code\`\n**Impact:** Client response handling may break\n"
                        ((BREAKING_COUNT++))
                    done <<< "$REMOVED_SUCCESS"
                else
                    # Non-breaking change
                    echo -e "${YELLOW}⚠️  NON-BREAKING: Response schema modified on ${method^^} $path${NC}"
                    ((NON_BREAKING_COUNT++))
                fi
            fi
        fi
    done
done

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
        echo "# OpenAPI Breaking Change Report"
        echo ""
        echo "**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo "**Old Spec:** $OLD_SPEC"
        echo "**New Spec:** $NEW_SPEC"
        echo ""
        echo "## Summary"
        echo ""
        echo "- **Breaking Changes:** $BREAKING_COUNT"
        echo "- **Non-Breaking Changes:** $NON_BREAKING_COUNT"
        echo ""
        if [[ $BREAKING_COUNT -gt 0 ]]; then
            echo "⚠️ **RECOMMENDATION:** This API change requires a **MAJOR version bump** (e.g., v2.0.0)"
        else
            echo "✅ **RECOMMENDATION:** This API change requires a **MINOR version bump** (e.g., v1.1.0)"
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

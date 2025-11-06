#!/usr/bin/env bash
# Script: analyze-breaking.sh
# Purpose: Orchestrator script that runs all breaking change detection tools
# Usage: bash analyze-breaking.sh [--old-api spec.yaml] [--new-api spec.yaml] [--old-schema schema.sql] [--new-schema schema.sql] [--output report.md]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Arguments
OLD_API=""
NEW_API=""
OLD_SCHEMA=""
NEW_SCHEMA=""
OUTPUT_FILE="breaking-changes-report.md"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --old-api)
            OLD_API="$2"
            shift 2
            ;;
        --new-api)
            NEW_API="$2"
            shift 2
            ;;
        --old-schema)
            OLD_SCHEMA="$2"
            shift 2
            ;;
        --new-schema)
            NEW_SCHEMA="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --old-api FILE       Old OpenAPI specification"
            echo "  --new-api FILE       New OpenAPI specification"
            echo "  --old-schema FILE    Old database schema"
            echo "  --new-schema FILE    New database schema"
            echo "  --output FILE        Output report file (default: breaking-changes-report.md)"
            exit 2
            ;;
    esac
done

# Validate at least one comparison is requested
if [[ -z "$OLD_API" ]] && [[ -z "$OLD_SCHEMA" ]]; then
    echo "Error: At least one comparison type must be specified (API or schema)"
    exit 2
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}       Breaking Change Analysis                     ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📅 Analysis Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo ""

# Initialize counters
TOTAL_BREAKING=0
TOTAL_NON_BREAKING=0
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0

# Temporary files for individual reports
API_REPORT=$(mktemp)
SCHEMA_REPORT=$(mktemp)
trap "rm -f $API_REPORT $SCHEMA_REPORT" EXIT

# Run API comparison if specified
if [[ -n "$OLD_API" ]] && [[ -n "$NEW_API" ]]; then
    echo -e "${BLUE}━━━ API Analysis ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ ! -f "$OLD_API" ]] || [[ ! -f "$NEW_API" ]]; then
        echo -e "${RED}❌ Error: API specification files not found${NC}"
        exit 2
    fi

    # Run openapi-diff script
    if bash "$SCRIPT_DIR/openapi-diff.sh" "$OLD_API" "$NEW_API" --output "$API_REPORT"; then
        echo -e "${GREEN}✅ API analysis complete - no breaking changes${NC}"
    else
        API_EXIT_CODE=$?
        if [[ $API_EXIT_CODE -eq 1 ]]; then
            echo -e "${RED}⚠️  API analysis complete - breaking changes detected${NC}"
            # Count breaking changes from report
            API_BREAKING=$(grep -c "❌ BREAKING" "$API_REPORT" || echo "0")
            TOTAL_BREAKING=$((TOTAL_BREAKING + API_BREAKING))

            # Count critical (removed endpoints)
            CRITICAL_API=$(grep -c "Removed Endpoint\|Removed HTTP Method" "$API_REPORT" || echo "0")
            CRITICAL_COUNT=$((CRITICAL_COUNT + CRITICAL_API))

            # Count high severity (required params)
            HIGH_API=$(grep -c "Added Required Parameter\|Removed Success Response" "$API_REPORT" || echo "0")
            HIGH_COUNT=$((HIGH_COUNT + HIGH_API))
        else
            echo -e "${RED}❌ API analysis failed with error code $API_EXIT_CODE${NC}"
            exit $API_EXIT_CODE
        fi
    fi

    echo ""
fi

# Run schema comparison if specified
if [[ -n "$OLD_SCHEMA" ]] && [[ -n "$NEW_SCHEMA" ]]; then
    echo -e "${BLUE}━━━ Database Schema Analysis ━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ ! -f "$OLD_SCHEMA" ]] || [[ ! -f "$NEW_SCHEMA" ]]; then
        echo -e "${RED}❌ Error: Schema files not found${NC}"
        exit 2
    fi

    # Run schema-compare script
    if bash "$SCRIPT_DIR/schema-compare.sh" "$OLD_SCHEMA" "$NEW_SCHEMA" --output "$SCHEMA_REPORT"; then
        echo -e "${GREEN}✅ Schema analysis complete - no breaking changes${NC}"
    else
        SCHEMA_EXIT_CODE=$?
        if [[ $SCHEMA_EXIT_CODE -eq 1 ]]; then
            echo -e "${RED}⚠️  Schema analysis complete - breaking changes detected${NC}"
            # Count breaking changes from report
            SCHEMA_BREAKING=$(grep -c "❌ BREAKING" "$SCHEMA_REPORT" || echo "0")
            TOTAL_BREAKING=$((TOTAL_BREAKING + SCHEMA_BREAKING))

            # Count critical (dropped tables)
            CRITICAL_SCHEMA=$(grep -c "Dropped Table" "$SCHEMA_REPORT" || echo "0")
            CRITICAL_COUNT=$((CRITICAL_COUNT + CRITICAL_SCHEMA))

            # Count high severity (removed columns, NOT NULL additions)
            HIGH_SCHEMA=$(grep -c "Removed Column\|Added NOT NULL Column Without Default" "$SCHEMA_REPORT" || echo "0")
            HIGH_COUNT=$((HIGH_COUNT + HIGH_SCHEMA))

            # Count medium severity (constraint changes)
            MEDIUM_SCHEMA=$(grep -c "Foreign Key Constraints Removed\|Unique Constraints Removed" "$SCHEMA_REPORT" || echo "0")
            MEDIUM_COUNT=$((MEDIUM_COUNT + MEDIUM_SCHEMA))
        else
            echo -e "${RED}❌ Schema analysis failed with error code $SCHEMA_EXIT_CODE${NC}"
            exit $SCHEMA_EXIT_CODE
        fi
    fi

    echo ""
fi

# Generate comprehensive report
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}       Generating Comprehensive Report              ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

{
    echo "# Comprehensive Breaking Change Analysis Report"
    echo ""
    echo "**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo ""

    # Executive Summary
    echo "## Executive Summary"
    echo ""
    echo "| Metric | Count |"
    echo "|--------|-------|"
    echo "| **Total Breaking Changes** | $TOTAL_BREAKING |"
    echo "| **Critical Severity** | $CRITICAL_COUNT |"
    echo "| **High Severity** | $HIGH_COUNT |"
    echo "| **Medium Severity** | $MEDIUM_COUNT |"
    echo ""

    # Severity breakdown
    if [[ $TOTAL_BREAKING -gt 0 ]]; then
        echo "### Severity Classification"
        echo ""
        echo "- 🔴 **CRITICAL** ($CRITICAL_COUNT): Immediate user impact, functionality broken"
        echo "- 🟠 **HIGH** ($HIGH_COUNT): Requires code changes, runtime errors likely"
        echo "- 🟡 **MEDIUM** ($MEDIUM_COUNT): Behavior changes, potential data issues"
        echo ""
    fi

    # Recommendation
    echo "## Recommendation"
    echo ""
    if [[ $CRITICAL_COUNT -gt 0 ]] || [[ $HIGH_COUNT -gt 0 ]]; then
        echo "⚠️ **MAJOR VERSION BUMP REQUIRED** (e.g., v2.0.0)"
        echo ""
        echo "**Rationale:** Critical or high-severity breaking changes detected that will cause existing clients to fail."
        echo ""
        echo "**Action Items:**"
        echo "1. ✅ Create comprehensive migration guide"
        echo "2. ✅ Notify all API consumers well in advance"
        echo "3. ✅ Consider deprecation period before removing old version"
        echo "4. ✅ Prepare data migration scripts if needed"
        echo "5. ✅ Update all documentation and examples"
    elif [[ $TOTAL_BREAKING -gt 0 ]]; then
        echo "⚠️ **MAJOR VERSION BUMP RECOMMENDED** (e.g., v2.0.0)"
        echo ""
        echo "**Rationale:** Breaking changes detected that may affect some users."
    else
        echo "✅ **MINOR VERSION BUMP** (e.g., v1.1.0)"
        echo ""
        echo "**Rationale:** No breaking changes detected. Changes are backward compatible."
    fi
    echo ""

    # Include API report if exists
    if [[ -f "$API_REPORT" ]] && [[ -s "$API_REPORT" ]]; then
        echo "---"
        echo ""
        echo "# API Changes"
        echo ""
        cat "$API_REPORT"
        echo ""
    fi

    # Include schema report if exists
    if [[ -f "$SCHEMA_REPORT" ]] && [[ -s "$SCHEMA_REPORT" ]]; then
        echo "---"
        echo ""
        echo "# Database Schema Changes"
        echo ""
        cat "$SCHEMA_REPORT"
        echo ""
    fi

    # Migration guide template
    if [[ $TOTAL_BREAKING -gt 0 ]]; then
        echo "---"
        echo ""
        echo "# Migration Guide Template"
        echo ""
        echo "Use this template to create your migration guide:"
        echo ""
        echo "## Overview"
        echo ""
        echo "Version [NEW_VERSION] introduces breaking changes that require action from API consumers."
        echo ""
        echo "## Timeline"
        echo ""
        echo "- **Announcement Date:** [DATE]"
        echo "- **Deprecation Period:** [DURATION]"
        echo "- **Migration Deadline:** [DATE]"
        echo "- **Old Version Sunset:** [DATE]"
        echo ""
        echo "## Breaking Changes"
        echo ""
        echo "[List each breaking change with before/after examples]"
        echo ""
        echo "## Migration Steps"
        echo ""
        echo "1. [Step-by-step instructions]"
        echo "2. [Include code examples]"
        echo "3. [Highlight common pitfalls]"
        echo ""
        echo "## Support Resources"
        echo ""
        echo "- Documentation: [URL]"
        echo "- Migration Examples: [URL]"
        echo "- Support Contact: [EMAIL/SLACK]"
        echo ""
    fi

} > "$OUTPUT_FILE"

echo "📄 Report written to: $OUTPUT_FILE"
echo ""

# Print summary
echo "================================"
echo "📋 Final Summary"
echo "================================"
echo -e "Breaking changes: ${RED}$TOTAL_BREAKING${NC}"
echo -e "  - Critical: ${RED}$CRITICAL_COUNT${NC}"
echo -e "  - High: ${YELLOW}$HIGH_COUNT${NC}"
echo -e "  - Medium: ${YELLOW}$MEDIUM_COUNT${NC}"
echo ""

if [[ $TOTAL_BREAKING -gt 0 ]]; then
    echo -e "${RED}❌ Breaking changes detected - MAJOR version bump required${NC}"
    echo ""
    echo "📖 Next steps:"
    echo "   1. Review report: $OUTPUT_FILE"
    echo "   2. Create migration guide for users"
    echo "   3. Announce breaking changes in advance"
    echo "   4. Update version to next major (e.g., 2.0.0)"
    exit 1
else
    echo -e "${GREEN}✅ No breaking changes detected${NC}"
    exit 0
fi

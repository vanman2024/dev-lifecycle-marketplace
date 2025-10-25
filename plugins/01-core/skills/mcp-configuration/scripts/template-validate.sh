#!/usr/bin/env bash
# Script: validate-{{THING}}.sh
# Purpose: Validate {{THING}} - pattern-based checks (NO AI needed)
# Plugin: {{PLUGIN_NAME}}
# Skill: {{SKILL_NAME}}
# Usage: ./validate-{{THING}}.sh <path-to-thing>

set -euo pipefail

# Configuration
TARGET="${1:-}"
REPORT_FILE="/tmp/validate-{{THING}}-report.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validate inputs
if [[ -z "$TARGET" ]]; then
    echo -e "${RED}ERROR: Missing required argument${NC}"
    echo "Usage: $0 <path-to-thing>"
    exit 1
fi

if [[ ! -e "$TARGET" ]]; then
    echo -e "${RED}ERROR: Target not found: $TARGET${NC}"
    exit 1
fi

# Initialize report
echo "Validation Report for: $TARGET" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"

ISSUES_FOUND=0

# ============================================
# VALIDATION CHECKS (Pattern Recognition)
# ============================================

echo -e "${YELLOW}[INFO] Running validation checks...${NC}"

# TODO: Add your validation checks here
# Example checks:

# Check 1: File structure
# if [[ ! -f "$TARGET/required-file.txt" ]]; then
#     echo "ISSUE: Missing required-file.txt" >> "$REPORT_FILE"
#     ((ISSUES_FOUND++))
# fi

# Check 2: Naming conventions
# if [[ ! "$TARGET" =~ ^[a-z-]+$ ]]; then
#     echo "ISSUE: Invalid naming - use lowercase with hyphens" >> "$REPORT_FILE"
#     ((ISSUES_FOUND++))
# fi

# Check 3: JSON validity
# if [[ -f "$TARGET/config.json" ]]; then
#     if ! jq empty "$TARGET/config.json" 2>/dev/null; then
#         echo "ISSUE: Invalid JSON in config.json" >> "$REPORT_FILE"
#         ((ISSUES_FOUND++))
#     fi
# fi

# Check 4: Required fields
# if [[ -f "$TARGET/config.json" ]]; then
#     if ! jq -e '.name' "$TARGET/config.json" >/dev/null 2>&1; then
#         echo "ISSUE: Missing required field 'name' in config.json" >> "$REPORT_FILE"
#         ((ISSUES_FOUND++))
#     fi
# fi

# ============================================
# REPORT RESULTS
# ============================================

echo "---" >> "$REPORT_FILE"
echo "Total Issues: $ISSUES_FOUND" >> "$REPORT_FILE"

if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}✅ Validation passed - no issues found${NC}"
    cat "$REPORT_FILE"
    exit 0
else
    echo -e "${RED}❌ Validation failed - $ISSUES_FOUND issue(s) found${NC}"
    cat "$REPORT_FILE"
    echo ""
    echo -e "${YELLOW}Run fix script to auto-correct:${NC}"
    echo "  bash $(dirname "$0")/fix-{{THING}}.sh $TARGET"
    exit 1
fi

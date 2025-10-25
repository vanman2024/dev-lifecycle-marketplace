#!/usr/bin/env bash
# Script: fix-{{THING}}.sh
# Purpose: Auto-fix common {{THING}} issues - deterministic fixes (NO AI needed)
# Plugin: {{PLUGIN_NAME}}
# Skill: {{SKILL_NAME}}
# Usage: ./fix-{{THING}}.sh <path-to-thing>

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

# Check for validation report
if [[ ! -f "$REPORT_FILE" ]]; then
    echo -e "${YELLOW}WARNING: No validation report found at $REPORT_FILE${NC}"
    echo "Run validation first:"
    echo "  bash $(dirname "$0")/validate-{{THING}}.sh $TARGET"
    exit 1
fi

FIXES_APPLIED=0

# ============================================
# AUTO-FIX PATTERNS (Deterministic)
# ============================================

echo -e "${YELLOW}[INFO] Applying auto-fixes...${NC}"

# TODO: Add your fix patterns here
# Example fixes:

# Fix 1: Create missing files
# if grep -q "Missing required-file.txt" "$REPORT_FILE"; then
#     echo -e "${YELLOW}[FIX] Creating required-file.txt${NC}"
#     touch "$TARGET/required-file.txt"
#     ((FIXES_APPLIED++))
# fi

# Fix 2: Rename to match conventions
# if grep -q "Invalid naming" "$REPORT_FILE"; then
#     BASENAME=$(basename "$TARGET")
#     FIXED_NAME=$(echo "$BASENAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
#     if [[ "$BASENAME" != "$FIXED_NAME" ]]; then
#         echo -e "${YELLOW}[FIX] Renaming $BASENAME → $FIXED_NAME${NC}"
#         mv "$TARGET" "$(dirname "$TARGET")/$FIXED_NAME"
#         TARGET="$(dirname "$TARGET")/$FIXED_NAME"
#         ((FIXES_APPLIED++))
#     fi
# fi

# Fix 3: Add missing JSON fields
# if grep -q "Missing required field 'name'" "$REPORT_FILE"; then
#     if [[ -f "$TARGET/config.json" ]]; then
#         echo -e "${YELLOW}[FIX] Adding default 'name' field to config.json${NC}"
#         jq '.name = "default-name"' "$TARGET/config.json" > "$TARGET/config.json.tmp"
#         mv "$TARGET/config.json.tmp" "$TARGET/config.json"
#         ((FIXES_APPLIED++))
#     fi
# fi

# Fix 4: Run formatters
# if [[ -f "$TARGET/package.json" ]]; then
#     echo -e "${YELLOW}[FIX] Running prettier...${NC}"
#     npx prettier --write "$TARGET/**/*.{js,ts,jsx,tsx}" 2>/dev/null || true
#     ((FIXES_APPLIED++))
# fi

# ============================================
# REPORT RESULTS
# ============================================

if [[ $FIXES_APPLIED -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  No automatic fixes applied${NC}"
    echo "Manual intervention may be required for remaining issues."
    exit 1
else
    echo -e "${GREEN}✅ Applied $FIXES_APPLIED fix(es)${NC}"
    echo ""
    echo -e "${YELLOW}Re-running validation...${NC}"
    bash "$(dirname "$0")/validate-{{THING}}.sh" "$TARGET"
fi

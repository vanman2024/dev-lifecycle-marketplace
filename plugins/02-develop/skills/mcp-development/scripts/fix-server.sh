#!/usr/bin/env bash
# Script: fix-server.sh
# Purpose: Auto-fix common MCP server issues - deterministic fixes (NO AI needed)
# Plugin: develop
# Skill: mcp-development
# Usage: ./fix-server.sh <path-to-server>

set -euo pipefail

# Configuration
TARGET="${1:-}"
REPORT_FILE="/tmp/validate-mcp-server-report.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validate inputs
if [[ -z "$TARGET" ]]; then
    echo -e "${RED}ERROR: Missing required argument${NC}"
    echo "Usage: $0 <path-to-server>"
    exit 1
fi

if [[ ! -d "$TARGET" ]]; then
    echo -e "${RED}ERROR: Server directory not found: $TARGET${NC}"
    exit 1
fi

# Check for validation report
if [[ ! -f "$REPORT_FILE" ]]; then
    echo -e "${YELLOW}WARNING: No validation report found at $REPORT_FILE${NC}"
    echo "Run validation first:"
    echo "  bash $(dirname "$0")/validate-server.sh $TARGET"
    exit 1
fi

FIXES_APPLIED=0

# ============================================
# AUTO-FIX PATTERNS (Deterministic)
# ============================================

echo -e "${YELLOW}[INFO] Applying auto-fixes to MCP server...${NC}"

# Fix 1: Create missing requirements.txt if pyproject.toml also missing
if grep -q "Missing dependency file" "$REPORT_FILE"; then
    if [[ ! -f "$TARGET/requirements.txt" ]] && [[ ! -f "$TARGET/pyproject.toml" ]]; then
        echo -e "${YELLOW}[FIX] Creating requirements.txt${NC}"
        echo "fastmcp>=0.2.0" > "$TARGET/requirements.txt"
        ((FIXES_APPLIED++))
    fi
fi

# Fix 2: Add FastMCP to existing requirements.txt
if grep -q "FastMCP not listed in requirements.txt" "$REPORT_FILE"; then
    if [[ -f "$TARGET/requirements.txt" ]]; then
        echo -e "${YELLOW}[FIX] Adding fastmcp to requirements.txt${NC}"
        echo "fastmcp>=0.2.0" >> "$TARGET/requirements.txt"
        ((FIXES_APPLIED++))
    fi
fi

# Fix 3: Create README.md if missing
if grep -q "Missing README.md" "$REPORT_FILE"; then
    if [[ ! -f "$TARGET/README.md" ]]; then
        SERVER_NAME=$(basename "$TARGET")
        echo -e "${YELLOW}[FIX] Creating README.md${NC}"
        cat > "$TARGET/README.md" << EOF
# $SERVER_NAME

MCP server built with FastMCP.

## Installation

\`\`\`bash
pip install -e .
\`\`\`

## Usage

\`\`\`bash
python -m $SERVER_NAME
\`\`\`

## Tools

TODO: Document available tools

## Resources

TODO: Document available resources

## Configuration

TODO: Document configuration options
EOF
        ((FIXES_APPLIED++))
    fi
fi

# Fix 4: Add missing FastMCP import (if server.py exists but missing import)
SERVER_FILE=""
if [[ -f "$TARGET/server.py" ]]; then
    SERVER_FILE="$TARGET/server.py"
elif [[ -f "$TARGET/__main__.py" ]]; then
    SERVER_FILE="$TARGET/__main__.py"
fi

if [[ -n "$SERVER_FILE" ]] && grep -q "Missing FastMCP import" "$REPORT_FILE"; then
    if ! grep -q "from mcp.server.fastmcp import FastMCP" "$SERVER_FILE"; then
        echo -e "${YELLOW}[FIX] Adding FastMCP import to $SERVER_FILE${NC}"
        # Add import at the top after any existing imports
        sed -i '1i from mcp.server.fastmcp import FastMCP' "$SERVER_FILE"
        ((FIXES_APPLIED++))
    fi
fi

# ============================================
# REPORT RESULTS
# ============================================

if [[ $FIXES_APPLIED -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  No automatic fixes applied${NC}"
    echo "Manual intervention may be required for remaining issues."
    echo "Issues that need manual fixing:"
    grep "ISSUE:" "$REPORT_FILE" || true
    exit 1
else
    echo -e "${GREEN}✅ Applied $FIXES_APPLIED fix(es)${NC}"
    echo ""
    echo -e "${YELLOW}Re-running validation...${NC}"
    bash "$(dirname "$0")/validate-server.sh" "$TARGET"
fi

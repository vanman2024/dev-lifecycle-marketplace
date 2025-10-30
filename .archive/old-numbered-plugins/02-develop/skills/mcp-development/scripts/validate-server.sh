#!/usr/bin/env bash
# Script: validate-server.sh
# Purpose: Validate MCP server structure - pattern-based checks (NO AI needed)
# Plugin: develop
# Skill: mcp-development
# Usage: ./validate-server.sh <path-to-server>

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

# Initialize report
echo "MCP Server Validation Report" > "$REPORT_FILE"
echo "Server: $TARGET" >> "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"

ISSUES_FOUND=0

# ============================================
# VALIDATION CHECKS (Pattern Recognition)
# ============================================

echo -e "${YELLOW}[INFO] Validating MCP server structure...${NC}"

# Check 1: Server entry point exists
if [[ ! -f "$TARGET/server.py" ]] && [[ ! -f "$TARGET/__main__.py" ]]; then
    echo "ISSUE: Missing server entry point (server.py or __main__.py)" >> "$REPORT_FILE"
    ((ISSUES_FOUND++))
fi

# Check 2: FastMCP import in server file
SERVER_FILE=""
if [[ -f "$TARGET/server.py" ]]; then
    SERVER_FILE="$TARGET/server.py"
elif [[ -f "$TARGET/__main__.py" ]]; then
    SERVER_FILE="$TARGET/__main__.py"
fi

if [[ -n "$SERVER_FILE" ]]; then
    if ! grep -q "from mcp.server.fastmcp import FastMCP" "$SERVER_FILE" 2>/dev/null; then
        echo "ISSUE: Missing FastMCP import in $SERVER_FILE" >> "$REPORT_FILE"
        ((ISSUES_FOUND++))
    fi

    # Check 3: MCP instance creation
    if ! grep -q "mcp = FastMCP(" "$SERVER_FILE" 2>/dev/null; then
        echo "ISSUE: Missing FastMCP instance creation in $SERVER_FILE" >> "$REPORT_FILE"
        ((ISSUES_FOUND++))
    fi

    # Check 4: Server run call
    if ! grep -q "mcp.run()" "$SERVER_FILE" 2>/dev/null; then
        echo "ISSUE: Missing mcp.run() call in $SERVER_FILE" >> "$REPORT_FILE"
        ((ISSUES_FOUND++))
    fi
fi

# Check 5: pyproject.toml or requirements.txt
if [[ ! -f "$TARGET/pyproject.toml" ]] && [[ ! -f "$TARGET/requirements.txt" ]]; then
    echo "ISSUE: Missing dependency file (pyproject.toml or requirements.txt)" >> "$REPORT_FILE"
    ((ISSUES_FOUND++))
fi

# Check 6: FastMCP in dependencies
if [[ -f "$TARGET/pyproject.toml" ]]; then
    if ! grep -q "fastmcp" "$TARGET/pyproject.toml" 2>/dev/null; then
        echo "ISSUE: FastMCP not listed in pyproject.toml dependencies" >> "$REPORT_FILE"
        ((ISSUES_FOUND++))
    fi
elif [[ -f "$TARGET/requirements.txt" ]]; then
    if ! grep -q "fastmcp" "$TARGET/requirements.txt" 2>/dev/null; then
        echo "ISSUE: FastMCP not listed in requirements.txt" >> "$REPORT_FILE"
        ((ISSUES_FOUND++))
    fi
fi

# Check 7: README.md exists
if [[ ! -f "$TARGET/README.md" ]]; then
    echo "WARNING: Missing README.md documentation" >> "$REPORT_FILE"
    ((ISSUES_FOUND++))
fi

# ============================================
# REPORT RESULTS
# ============================================

echo "---" >> "$REPORT_FILE"
echo "Total Issues: $ISSUES_FOUND" >> "$REPORT_FILE"

if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}✅ Validation passed - MCP server structure is valid${NC}"
    cat "$REPORT_FILE"
    exit 0
else
    echo -e "${RED}❌ Validation failed - $ISSUES_FOUND issue(s) found${NC}"
    cat "$REPORT_FILE"
    echo ""
    echo -e "${YELLOW}Run fix script to auto-correct:${NC}"
    echo "  bash $(dirname "$0")/fix-server.sh $TARGET"
    exit 1
fi

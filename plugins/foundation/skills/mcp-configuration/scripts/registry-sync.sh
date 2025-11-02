#!/usr/bin/env bash
# Script: registry-sync.sh
# Purpose: Sync registry to target format(s) - orchestrates transform scripts
# Plugin: foundation
# Skill: mcp-configuration
# Usage: ./registry-sync.sh <claude|vscode|both> [server-name...]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY_DIR="${HOME}/.claude/mcp-registry"
SERVERS_FILE="${REGISTRY_DIR}/servers.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================
# PARSE ARGUMENTS
# ============================================

FORMAT="${1:-}"
shift || true

if [[ -z "$FORMAT" ]]; then
    echo "Usage: $0 <claude|vscode|both> [server-name...]"
    echo ""
    echo "Formats:"
    echo "  claude  - Sync to .mcp.json (Claude Code format)"
    echo "  vscode  - Sync to .vscode/mcp.json (VS Code format)"
    echo "  both    - Sync to both formats"
    echo ""
    echo "Examples:"
    echo "  $0 claude              # Sync all servers to .mcp.json"
    echo "  $0 vscode filesystem   # Sync only filesystem server to VS Code"
    echo "  $0 both                # Sync all servers to both formats"
    echo ""
    exit 1
fi

# Validate registry exists
if [[ ! -f "$SERVERS_FILE" ]]; then
    echo -e "${RED}[ERROR] Registry not initialized${NC}"
    echo "Run: /foundation:mcp-registry init"
    exit 1
fi

# Validate format
if [[ ! "$FORMAT" =~ ^(claude|vscode|both)$ ]]; then
    echo -e "${RED}[ERROR] Invalid format: $FORMAT${NC}"
    echo "Valid formats: claude, vscode, both"
    exit 1
fi

echo -e "${BLUE}[INFO] Syncing registry to format: $FORMAT${NC}"
echo ""

# ============================================
# RUN TRANSFORMS
# ============================================

SUCCESS=true

if [[ "$FORMAT" == "claude" ]] || [[ "$FORMAT" == "both" ]]; then
    echo -e "${BLUE}[TRANSFORM] Claude Code format (.mcp.json)${NC}"
    if bash "${SCRIPT_DIR}/transform-claude.sh" "$@"; then
        echo -e "${GREEN}✅ Claude Code sync complete${NC}"
    else
        echo -e "${RED}❌ Claude Code sync failed${NC}"
        SUCCESS=false
    fi
    echo ""
fi

if [[ "$FORMAT" == "vscode" ]] || [[ "$FORMAT" == "both" ]]; then
    echo -e "${BLUE}[TRANSFORM] VS Code format (.vscode/mcp.json)${NC}"
    if bash "${SCRIPT_DIR}/transform-vscode.sh" "$@"; then
        echo -e "${GREEN}✅ VS Code sync complete${NC}"
    else
        echo -e "${RED}❌ VS Code sync failed${NC}"
        SUCCESS=false
    fi
    echo ""
fi

# ============================================
# REPORT RESULTS
# ============================================

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ "$SUCCESS" == "true" ]]; then
    echo -e "${GREEN}✅ Registry Sync Complete${NC}"
else
    echo -e "${RED}⚠️  Registry Sync Completed with Errors${NC}"
fi
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ "$FORMAT" == "claude" ]] || [[ "$FORMAT" == "both" ]]; then
    echo "Claude Code config: .mcp.json"
fi

if [[ "$FORMAT" == "vscode" ]] || [[ "$FORMAT" == "both" ]]; then
    echo "VS Code config: .vscode/mcp.json"
fi

echo ""
echo "Registry source: $SERVERS_FILE"
echo ""

if [[ "$SUCCESS" == "true" ]]; then
    exit 0
else
    exit 1
fi

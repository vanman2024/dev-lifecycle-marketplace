#!/usr/bin/env bash
# Script: add-mcp-keys-to-bashrc.sh
# Purpose: Add MCP key placeholders to .bashrc
# Plugin: 01-core
# Skill: environment-setup

set -euo pipefail

BASHRC="$HOME/.bashrc"
TEMPLATE="$(dirname "$0")/../templates/mcp-keys-bashrc.txt"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Adding MCP Key Placeholders to .bashrc${NC}"
echo ""

# Check if MCP keys section already exists
if grep -q "# MCP SERVER KEYS" "$BASHRC"; then
    echo -e "${YELLOW}⚠️  MCP keys section already exists in .bashrc${NC}"
    echo ""
    echo "To update, manually edit:"
    echo "  nano ~/.bashrc"
    echo ""
    echo "Or remove the old section and run this script again."
    exit 0
fi

# Add MCP keys section
echo "" >> "$BASHRC"
cat "$TEMPLATE" >> "$BASHRC"

echo -e "${GREEN}✅ Added MCP key placeholders to .bashrc${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. Edit your .bashrc to add your actual API keys:"
echo "   nano ~/.bashrc"
echo ""
echo "2. Scroll to the bottom and find the MCP SERVER KEYS section"
echo ""
echo "3. Replace placeholders with your actual keys:"
echo "   - MCP_GITHUB_TOKEN=ghp_xxxxx"
echo "   - MCP_POSTMAN_KEY=PMAK_xxxxx"
echo "   - MCP_FIGMA_TOKEN=figd_xxxxx"
echo "   etc."
echo ""
echo "4. Save and reload:"
echo "   source ~/.bashrc"
echo ""
echo -e "${YELLOW}⚠️  Security:${NC}"
echo "  - .bashrc is NOT committed to git"
echo "  - These keys work across ALL projects"
echo "  - Project-specific keys go in .env (per project)"
echo ""

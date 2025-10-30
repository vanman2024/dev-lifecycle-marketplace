#!/usr/bin/env bash
# Script: check-mcp-keys.sh
# Purpose: Validate which MCP server keys are set in environment
# Plugin: 01-core
# Skill: environment-setup

set -euo pipefail

# Source bashrc to get MCP keys if not already in environment
if [[ -f "$HOME/.bashrc" ]]; then
    # Extract and source only the MCP keys section to avoid side effects
    source <(grep -A 30 "# MCP SERVER KEYS" "$HOME/.bashrc" | grep "^export MCP_" || true)
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Array of expected MCP keys with their descriptions
declare -A MCP_KEYS=(
    ["MCP_GITHUB_TOKEN"]="GitHub Personal Access Token"
    ["MCP_POSTMAN_KEY"]="Postman API Key"
    ["MCP_FIGMA_TOKEN"]="Figma Access Token"
    ["MCP_SUPABASE_URL"]="Supabase Project URL"
    ["MCP_SUPABASE_KEY"]="Supabase Service Key"
    ["MCP_AIRTABLE_TOKEN"]="Airtable Personal Access Token"
)

echo -e "${BLUE}MCP Server Keys Validation${NC}"
echo ""

# Track status
KEYS_SET=0
KEYS_MISSING=0
KEYS_PLACEHOLDER=0

echo -e "${BLUE}Checking environment variables...${NC}"
echo ""

# Check each key
for KEY in "${!MCP_KEYS[@]}"; do
    VALUE="${!KEY:-}"
    DESCRIPTION="${MCP_KEYS[$KEY]}"

    if [[ -z "$VALUE" ]]; then
        # Key not set at all
        echo -e "${RED}✗${NC} $KEY - Not set"
        echo "  Description: $DESCRIPTION"
        KEYS_MISSING=$((KEYS_MISSING + 1))
    elif [[ "$VALUE" =~ YOUR_.*_HERE|YOUR_PROJECT ]]; then
        # Key is placeholder
        echo -e "${YELLOW}⚠${NC} $KEY - Placeholder value detected"
        echo "  Description: $DESCRIPTION"
        echo "  Current: $VALUE"
        KEYS_PLACEHOLDER=$((KEYS_PLACEHOLDER + 1))
    else
        # Key is set with real value
        MASKED_VALUE="${VALUE:0:10}...${VALUE: -4}"
        echo -e "${GREEN}✓${NC} $KEY - Set"
        echo "  Description: $DESCRIPTION"
        echo "  Value: $MASKED_VALUE"
        KEYS_SET=$((KEYS_SET + 1))
    fi
    echo ""
done

# Summary
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Keys configured: $KEYS_SET${NC}"
echo -e "${YELLOW}⚠ Placeholder values: $KEYS_PLACEHOLDER${NC}"
echo -e "${RED}✗ Keys missing: $KEYS_MISSING${NC}"
echo ""

# Provide guidance based on status
if [[ $KEYS_PLACEHOLDER -gt 0 ]] || [[ $KEYS_MISSING -gt 0 ]]; then
    echo -e "${YELLOW}Next Steps:${NC}"
    echo ""
    echo "1. Edit your .bashrc to add real API keys:"
    echo "   nano ~/.bashrc"
    echo ""
    echo "2. Scroll to the 'MCP SERVER KEYS' section"
    echo ""
    echo "3. Replace placeholder values with actual keys:"

    if [[ "${MCP_GITHUB_TOKEN:-}" =~ YOUR_.*_HERE ]]; then
        echo "   - GitHub: https://github.com/settings/tokens"
    fi
    if [[ "${MCP_POSTMAN_KEY:-}" =~ YOUR_.*_HERE ]]; then
        echo "   - Postman: https://postman.co/settings/me/api-keys"
    fi
    if [[ "${MCP_FIGMA_TOKEN:-}" =~ YOUR_.*_HERE ]]; then
        echo "   - Figma: https://www.figma.com/developers/api#access-tokens"
    fi
    if [[ "${MCP_SUPABASE_URL:-}" =~ YOUR_.*_HERE ]] || [[ "${MCP_SUPABASE_KEY:-}" =~ YOUR_.*_HERE ]]; then
        echo "   - Supabase: https://supabase.com/dashboard/project/_/settings/api"
    fi
    if [[ "${MCP_AIRTABLE_TOKEN:-}" =~ YOUR_.*_HERE ]]; then
        echo "   - Airtable: https://airtable.com/create/tokens"
    fi

    echo ""
    echo "4. Reload your shell configuration:"
    echo "   source ~/.bashrc"
    echo ""
    echo "5. Run this check again:"
    echo "   /01-core:mcp-keys-check"
    echo ""
else
    echo -e "${GREEN}All MCP server keys are configured!${NC}"
    echo ""
    echo "Your MCP servers should be able to authenticate properly."
fi

# Exit with appropriate code
if [[ $KEYS_SET -eq ${#MCP_KEYS[@]} ]]; then
    exit 0  # All keys set
elif [[ $KEYS_SET -gt 0 ]]; then
    exit 1  # Some keys set
else
    exit 2  # No keys set
fi

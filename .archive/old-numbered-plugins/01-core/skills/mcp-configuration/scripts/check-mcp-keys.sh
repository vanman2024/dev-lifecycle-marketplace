#!/usr/bin/env bash
# Script: check-mcp-keys.sh
# Purpose: Check which MCP server API keys are configured in environment
# Plugin: 01-core
# Skill: mcp-configuration

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Common MCP environment variables to check
KEYS=(
    "CONTEXT7_API_KEY"
    "GITHUB_TOKEN"
    "FIGMA_ACCESS_TOKEN"
    "SUPABASE_URL"
    "SUPABASE_SERVICE_KEY"
    "POSTMAN_API_KEY"
    "AIRTABLE_TOKEN"
    "BROWSERBASE_API_KEY"
    "BROWSERBASE_PROJECT_ID"
    "SLACK_BOT_TOKEN"
    "SLACK_TEAM_ID"
    "NOTION_API_KEY"
)

# Placeholder patterns that indicate unconfigured keys
PLACEHOLDERS=(
    "YOUR_"
    "PMAK_YOUR"
    "ghp_YOUR"
    "figd_YOUR"
    "patYOUR"
)

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}MCP API Keys Status${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

CONFIGURED=0
PLACEHOLDER=0
MISSING=0

for key in "${KEYS[@]}"; do
    value="${!key:-}"

    if [[ -z "$value" ]]; then
        echo -e "${RED}✗${NC} $key - ${RED}Missing${NC}"
        MISSING=$((MISSING + 1))
    else
        # Check if it's a placeholder
        is_placeholder=false
        for pattern in "${PLACEHOLDERS[@]}"; do
            if [[ "$value" == *"$pattern"* ]]; then
                is_placeholder=true
                break
            fi
        done

        if $is_placeholder; then
            echo -e "${YELLOW}⚠${NC} $key - ${YELLOW}Placeholder (needs replacement)${NC}"
            PLACEHOLDER=$((PLACEHOLDER + 1))
        else
            # Mask the value for security
            masked="${value:0:4}...${value: -4}"
            echo -e "${GREEN}✓${NC} $key - ${GREEN}Configured${NC} ($masked)"
            CONFIGURED=$((CONFIGURED + 1))
        fi
    fi
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Configured:${NC} $CONFIGURED"
echo -e "${YELLOW}Placeholder:${NC} $PLACEHOLDER"
echo -e "${RED}Missing:${NC} $MISSING"
echo ""

if [[ $PLACEHOLDER -gt 0 || $MISSING -gt 0 ]]; then
    echo -e "${YELLOW}⚠ Next Steps:${NC}"
    echo "1. Edit your shell config (~/.bashrc or ~/.zshrc)"
    echo "2. Add/update the missing or placeholder keys:"
    echo "   export KEY_NAME=\"your-actual-key\""
    echo "3. Reload: source ~/.bashrc"
    echo ""
fi

exit 0

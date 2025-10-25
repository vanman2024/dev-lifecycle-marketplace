#!/usr/bin/env bash
# Script: validate-permissions.sh
# Purpose: Validate slash command permission exists in settings.local.json
# Plugin: 01-core
# Skill: mcp-configuration
# Usage: ./validate-permissions.sh <plugin-name> <command-name>

set -euo pipefail

# Configuration
PLUGIN_NAME="${1:-}"
COMMAND_NAME="${2:-}"
SETTINGS_FILE=".claude/settings.local.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Validate inputs
if [[ -z "$PLUGIN_NAME" ]] || [[ -z "$COMMAND_NAME" ]]; then
    echo "Usage: $0 <plugin-name> <command-name>"
    echo "Example: $0 core mcp-setup"
    exit 1
fi

# Check if settings file exists
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo -e "${RED}[ERROR] Settings file not found: $SETTINGS_FILE${NC}"
    echo ""
    echo "Create it with:"
    echo "  bash plugins/01-core/skills/mcp-configuration/scripts/update-permissions.sh $PLUGIN_NAME $COMMAND_NAME"
    exit 1
fi

# Build permission string
PERMISSION="SlashCommand(/$PLUGIN_NAME:$COMMAND_NAME:*)"

# Check if permission exists
if jq -e --arg perm "$PERMISSION" '.permissions.allow | index($perm)' "$SETTINGS_FILE" > /dev/null; then
    echo -e "${GREEN}✅ Permission exists: $PERMISSION${NC}"
    exit 0
else
    echo -e "${RED}❌ Permission missing: $PERMISSION${NC}"
    echo ""
    echo "Add it with:"
    echo "  bash plugins/01-core/skills/mcp-configuration/scripts/update-permissions.sh $PLUGIN_NAME $COMMAND_NAME"
    exit 1
fi

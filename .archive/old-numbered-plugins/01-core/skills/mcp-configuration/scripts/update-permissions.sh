#!/usr/bin/env bash
# Script: update-permissions.sh
# Purpose: Add slash command permission to settings.local.json
# Plugin: 01-core
# Skill: mcp-configuration
# Usage: ./update-permissions.sh <plugin-name> <command-name>

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
    echo -e "${YELLOW}[WARN] Settings file not found, creating: $SETTINGS_FILE${NC}"
    mkdir -p .claude
    echo '{"permissions":{"allow":[],"deny":[],"ask":[]}}' > "$SETTINGS_FILE"
fi

# Build permission string
PERMISSION="SlashCommand(/$PLUGIN_NAME:$COMMAND_NAME:*)"

# Check if permission already exists
if grep -q "\"$PERMISSION\"" "$SETTINGS_FILE"; then
    echo -e "${YELLOW}[INFO] Permission already exists: $PERMISSION${NC}"
    exit 0
fi

# Add permission
echo -e "${GREEN}[INFO] Adding permission: $PERMISSION${NC}"

# Backup settings
cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup-$(date +%Y%m%d_%H%M%S)"

# Add permission to allow array
tmp_file=$(mktemp)
jq --arg perm "$PERMISSION" \
    '.permissions.allow += [$perm] | .permissions.allow |= unique | .permissions.allow |= sort' \
    "$SETTINGS_FILE" > "$tmp_file"
mv "$tmp_file" "$SETTINGS_FILE"

echo -e "${GREEN}✅ Permission added to $SETTINGS_FILE${NC}"
echo ""
echo "Permission: $PERMISSION"

exit 0

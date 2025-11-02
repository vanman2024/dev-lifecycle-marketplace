#!/usr/bin/env bash
# Script: transform-claude.sh
# Purpose: Transform registry to Claude Code format (.mcp.json) - mechanical conversion (NO AI)
# Plugin: foundation
# Skill: mcp-configuration
# Usage: ./transform-claude.sh [server-name...]

set -euo pipefail

# Configuration
REGISTRY_DIR="${HOME}/.claude/mcp-registry"
SERVERS_FILE="${REGISTRY_DIR}/servers.json"
TARGET_FILE=".mcp.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Validate registry exists
if [[ ! -f "$SERVERS_FILE" ]]; then
    echo -e "${RED}[ERROR] Registry not initialized${NC}"
    echo "Run: /foundation:mcp-registry init"
    exit 1
fi

# Create target file if needed
if [[ ! -f "$TARGET_FILE" ]]; then
    echo -e "${YELLOW}[INFO] Creating $TARGET_FILE${NC}"
    echo '{"mcpServers":{}}' > "$TARGET_FILE"
fi

echo -e "${BLUE}[INFO] Transforming registry to Claude Code format${NC}"
echo "Target: $TARGET_FILE"
echo ""

# ============================================
# GET SERVERS TO ADD
# ============================================

# If specific servers provided, use them; otherwise use all
if [[ $# -gt 0 ]]; then
    SERVERS_TO_ADD=("$@")
else
    mapfile -t SERVERS_TO_ADD < <(jq -r '.servers | keys[]' "$SERVERS_FILE")
fi

# Filter out marketplace servers
FILTERED_SERVERS=()
for server_name in "${SERVERS_TO_ADD[@]}"; do
    is_marketplace=$(jq -r ".servers[\"$server_name\"].marketplace // false" "$SERVERS_FILE")
    if [[ "$is_marketplace" == "true" ]]; then
        echo -e "${YELLOW}[SKIP] $server_name (marketplace server - already in VS Code)${NC}"
        continue
    fi
    FILTERED_SERVERS+=("$server_name")
done

echo "Servers to add: ${#FILTERED_SERVERS[@]}"
echo ""

# ============================================
# TRANSFORM EACH SERVER
# ============================================

# Read existing file (Claude Code uses "mcpServers")
existing_servers=$(jq '.mcpServers // {}' "$TARGET_FILE" 2>/dev/null || echo '{}')

SERVERS_ADDED=0

for server_name in "${FILTERED_SERVERS[@]}"; do
    echo -e "${BLUE}[TRANSFORM] $server_name${NC}"

    # Get server definition from registry
    if ! server_def=$(jq ".servers[\"$server_name\"]" "$SERVERS_FILE" 2>/dev/null); then
        echo -e "${YELLOW}  ⚠️  Not found in registry, skipping${NC}"
        continue
    fi

    # Check if null
    if [[ "$server_def" == "null" ]]; then
        echo -e "${YELLOW}  ⚠️  Not found in registry, skipping${NC}"
        continue
    fi

    transport=$(echo "$server_def" | jq -r '.transport')

    # Transform based on transport type
    transformed="{}"

    case $transport in
        stdio)
            command=$(echo "$server_def" | jq -r '.command')
            args=$(echo "$server_def" | jq '.args // []')
            env=$(echo "$server_def" | jq '.env // {}')

            transformed=$(jq -n \
                --arg cmd "$command" \
                --argjson args "$args" \
                --argjson env "$env" \
                '{command: $cmd, args: $args} + (if ($env | length) > 0 then {env: $env} else {} end)')
            ;;

        http-local)
            # For http-local, Claude Code uses type: http
            url=$(echo "$server_def" | jq -r '.url')
            env=$(echo "$server_def" | jq '.env // {}')

            transformed=$(jq -n \
                --arg url "$url" \
                --argjson env "$env" \
                '{type: "http", url: $url} + (if ($env | length) > 0 then {env: $env} else {} end)')
            echo -e "${YELLOW}  ⚠️  http-local - requires manual server start at $url${NC}"
            ;;

        http-remote)
            url=$(echo "$server_def" | jq -r '.url')
            env=$(echo "$server_def" | jq '.env // {}')

            transformed=$(jq -n \
                --arg url "$url" \
                --argjson env "$env" \
                '{type: "http", url: $url} + (if ($env | length) > 0 then {env: $env} else {} end)')
            ;;

        http-remote-auth)
            # Claude Code doesn't directly support http-remote-auth in .mcp.json
            # Skip these for Claude format - they work better in VS Code
            echo -e "${YELLOW}  ⚠️  http-remote-auth not supported in Claude format - use VS Code instead${NC}"
            continue
            ;;

        *)
            echo -e "${YELLOW}  ⚠️  Unknown transport type: $transport${NC}"
            continue
            ;;
    esac

    # Add to existing servers
    existing_servers=$(echo "$existing_servers" | jq \
        --arg key "$server_name" \
        --argjson val "$transformed" \
        '. + {($key): $val}')

    SERVERS_ADDED=$((SERVERS_ADDED + 1))
    echo -e "${GREEN}  ✅ Transformed ($transport)${NC}"
done

# ============================================
# UPDATE TARGET FILE
# ============================================

# Update file (Claude Code uses "mcpServers" key)
jq --argjson servers "$existing_servers" \
    '.mcpServers = $servers' \
    "$TARGET_FILE" > "${TARGET_FILE}.tmp"

mv "${TARGET_FILE}.tmp" "$TARGET_FILE"

# ============================================
# REPORT RESULTS
# ============================================

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Transform Complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Tool: Claude Code CLI"
echo "Servers added: $SERVERS_ADDED"
echo "Target file: $TARGET_FILE"
echo ""

# Show result
echo "Updated configuration:"
jq '.mcpServers' "$TARGET_FILE"

echo ""

exit 0

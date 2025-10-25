#!/usr/bin/env bash
# Script: transform-vscode.sh
# Purpose: Transform registry to VS Code format (.vscode/mcp.json) - mechanical conversion (NO AI)
# Plugin: 01-core
# Skill: mcp-configuration
# Usage: ./transform-vscode.sh [server-name...]

set -euo pipefail

# Configuration
REGISTRY_DIR="${HOME}/.claude/mcp-registry"
SERVERS_FILE="${REGISTRY_DIR}/servers.json"
TARGET_FILE=".vscode/mcp.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Validate registry exists
if [[ ! -f "$SERVERS_FILE" ]]; then
    echo -e "${RED}[ERROR] Registry not initialized${NC}"
    echo "Run: bash plugins/01-core/skills/mcp-configuration/scripts/registry-init.sh"
    exit 1
fi

# Create .vscode directory if needed
if [[ ! -d ".vscode" ]]; then
    echo -e "${YELLOW}[INFO] Creating .vscode directory${NC}"
    mkdir -p .vscode
fi

# Create target file if needed
if [[ ! -f "$TARGET_FILE" ]]; then
    echo -e "${YELLOW}[INFO] Creating $TARGET_FILE${NC}"
    echo '{"servers":{}}' > "$TARGET_FILE"
fi

echo -e "${BLUE}[INFO] Transforming registry to VS Code format${NC}"
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

echo "Servers to add: ${#SERVERS_TO_ADD[@]}"
echo ""

# ============================================
# TRANSFORM EACH SERVER
# ============================================

# Read existing file (VS Code uses "servers" not "mcpServers")
existing_servers=$(jq '.servers // {}' "$TARGET_FILE" 2>/dev/null || echo '{}')

SERVERS_ADDED=0

for server_name in "${SERVERS_TO_ADD[@]}"; do
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
            url=$(echo "$server_def" | jq -r '.url')
            env=$(echo "$server_def" | jq '.env // {}')

            transformed=$(jq -n \
                --arg url "$url" \
                --argjson env "$env" \
                '{url: $url} + (if ($env | length) > 0 then {env: $env} else {} end)')
            ;;

        http-remote)
            httpUrl=$(echo "$server_def" | jq -r '.httpUrl')

            transformed=$(jq -n \
                --arg url "$httpUrl" \
                '{httpUrl: $url, trust: true}')
            ;;

        http-remote-auth)
            httpUrl=$(echo "$server_def" | jq -r '.httpUrl')
            headers=$(echo "$server_def" | jq '.headers // {}')

            transformed=$(jq -n \
                --arg url "$httpUrl" \
                --argjson headers "$headers" \
                '{httpUrl: $url, trust: true, headers: $headers}')
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

# Backup original
backup_file=".vscode/mcp.json.backup-$(date +%Y%m%d_%H%M%S)"
cp "$TARGET_FILE" "$backup_file"

# Update file (VS Code uses "servers" key)
jq --argjson servers "$existing_servers" \
    '.servers = $servers' \
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
echo "Tool: VS Code"
echo "Servers added: $SERVERS_ADDED"
echo "Target file: $TARGET_FILE"
echo "Backup: $backup_file"
echo ""

# Show result
echo "Updated configuration:"
jq '.servers' "$TARGET_FILE"

echo ""

exit 0

#!/usr/bin/env bash
# Script: transform-json.sh
# Purpose: Transform registry to JSON format (Gemini/Qwen/Claude Code) - mechanical conversion (NO AI)
# Plugin: 01-core
# Skill: mcp-configuration
# Usage: ./transform-json.sh <tool> [server-name...]

set -euo pipefail

# Configuration
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

TOOL="${1:-}"
shift || true

if [[ ! "$TOOL" =~ ^(gemini|qwen|claude-code|project)$ ]]; then
    echo "Usage: $0 <tool> [server-name...]"
    echo ""
    echo "Tools:"
    echo "  gemini       - Transform to ~/.gemini/settings.json"
    echo "  qwen         - Transform to ~/.qwen/settings.json"
    echo "  claude-code  - Transform to current project .mcp.json"
    echo "  project      - Same as claude-code"
    echo ""
    echo "Examples:"
    echo "  $0 gemini                    # Add all servers"
    echo "  $0 gemini figma-mcp github   # Add specific servers"
    echo "  $0 project figma-mcp         # Add to current project"
    echo ""
    exit 1
fi

# Determine target file based on tool
case $TOOL in
    gemini)
        TARGET_FILE="${HOME}/.gemini/settings.json"
        ;;
    qwen)
        TARGET_FILE="${HOME}/.qwen/settings.json"
        ;;
    claude-code|project)
        TARGET_FILE=".mcp.json"
        ;;
esac

# Validate registry exists
if [[ ! -f "$SERVERS_FILE" ]]; then
    echo -e "${RED}[ERROR] Registry not initialized${NC}"
    echo "Run: bash plugins/01-core/skills/mcp-configuration/scripts/registry-init.sh"
    exit 1
fi

# Validate target file exists
if [[ ! -f "$TARGET_FILE" ]]; then
    echo -e "${YELLOW}[WARN] Target file not found: $TARGET_FILE${NC}"

    if [[ "$TOOL" =~ ^(claude-code|project)$ ]]; then
        echo "Creating .mcp.json..."
        echo '{"mcpServers":{}}' > "$TARGET_FILE"
    else
        echo -e "${RED}[ERROR] Cannot create $TARGET_FILE automatically${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}[INFO] Transforming registry to $TOOL format${NC}"
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

# Read existing file
existing_servers=$(jq '.mcpServers // {}' "$TARGET_FILE" 2>/dev/null || echo '{}')

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

        http-local|http-remote|http-remote-auth)
            echo -e "${YELLOW}  ⚠️  HTTP transport not supported in Claude Code .mcp.json${NC}"
            echo -e "${YELLOW}     Claude Code only supports stdio transport (command/args)${NC}"
            echo -e "${YELLOW}     Skipping server: $server_name${NC}"
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

# No backup created

# Update file
if [[ "$TOOL" =~ ^(gemini|qwen)$ ]]; then
    # Merge with existing settings
    jq --argjson servers "$existing_servers" \
        '.mcpServers = $servers' \
        "$TARGET_FILE" > "${TARGET_FILE}.tmp"
else
    # Just update mcpServers
    jq --argjson servers "$existing_servers" \
        '.mcpServers = $servers' \
        "$TARGET_FILE" > "${TARGET_FILE}.tmp"
fi

mv "${TARGET_FILE}.tmp" "$TARGET_FILE"

# ============================================
# REPORT RESULTS
# ============================================

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Transform Complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Tool: $TOOL"
echo "Servers added: $SERVERS_ADDED"
echo "Target file: $TARGET_FILE"
echo ""

# Show result
echo "Updated configuration:"
jq '.mcpServers' "$TARGET_FILE"

echo ""

exit 0

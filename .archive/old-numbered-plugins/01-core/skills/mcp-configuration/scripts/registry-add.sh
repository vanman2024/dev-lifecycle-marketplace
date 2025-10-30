#!/usr/bin/env bash
# Script: registry-add.sh
# Purpose: Add MCP server to registry - supports all transport types (MECHANICAL)
# Plugin: 01-core
# Skill: mcp-configuration
# Usage: ./registry-add.sh <server-name> --transport <type> [options]

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

SERVER_NAME="${1:-}"
shift || true

if [[ -z "$SERVER_NAME" ]]; then
    echo "Usage: $0 <server-name> --transport <stdio|http-local|http-remote|http-remote-auth> [options]"
    echo ""
    echo "Examples:"
    echo ""
    echo "  # stdio server"
    echo "  $0 filesystem --transport stdio --command npx --args '-y,@modelcontextprotocol/server-filesystem,/home'"
    echo ""
    echo "  # http-local server"
    echo "  $0 figma-mcp --transport http-local --path /Projects/Mcp-Servers/figma-mcp --command 'python src/server.py' --url http://localhost:8031"
    echo ""
    echo "  # http-remote server"
    echo "  $0 api-mcp --transport http-remote --url https://api.example.com/mcp/"
    echo ""
    echo "  # http-remote-auth server"
    echo "  $0 github --transport http-remote-auth --url https://api.githubcopilot.com/mcp/ --header 'Authorization: Bearer \${GITHUB_TOKEN}'"
    echo ""
    exit 1
fi

# Validate registry exists
if [[ ! -f "$SERVERS_FILE" ]]; then
    echo -e "${RED}[ERROR] Registry not initialized${NC}"
    echo "Run: bash plugins/01-core/skills/mcp-configuration/scripts/registry-init.sh"
    exit 1
fi

# Parse options
TRANSPORT=""
COMMAND=""
ARGS=""
SERVER_PATH=""
URL=""
HEADERS="{}"
ENV_VARS="{}"
DESCRIPTION=""
DISPLAY_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --transport)
            TRANSPORT="$2"
            shift 2
            ;;
        --command)
            COMMAND="$2"
            shift 2
            ;;
        --args)
            ARGS="$2"
            shift 2
            ;;
        --path)
            SERVER_PATH="$2"
            shift 2
            ;;
        --url)
            URL="$2"
            shift 2
            ;;
        --header)
            # Parse header as "Key: Value"
            IFS=':' read -r header_key header_value <<< "$2"
            header_key="${header_key## }"
            header_key="${header_key%% }"
            header_value="${header_value## }"
            header_value="${header_value%% }"
            HEADERS=$(echo "$HEADERS" | jq --arg k "$header_key" --arg v "$header_value" '. + {($k): $v}')
            shift 2
            ;;
        --env)
            # Parse env as "KEY=value"
            IFS='=' read -r env_key env_value <<< "$2"
            ENV_VARS=$(echo "$ENV_VARS" | jq --arg k "$env_key" --arg v "$env_value" '. + {($k): $v}')
            shift 2
            ;;
        --description)
            DESCRIPTION="$2"
            shift 2
            ;;
        --name)
            DISPLAY_NAME="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}[ERROR] Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Validate transport type
if [[ -z "$TRANSPORT" ]]; then
    echo -e "${RED}[ERROR] --transport is required${NC}"
    exit 1
fi

if [[ ! "$TRANSPORT" =~ ^(stdio|http-local|http-remote|http-remote-auth)$ ]]; then
    echo -e "${RED}[ERROR] Invalid transport type: $TRANSPORT${NC}"
    echo "Valid types: stdio, http-local, http-remote, http-remote-auth"
    exit 1
fi

# Set defaults
if [[ -z "$DISPLAY_NAME" ]]; then
    DISPLAY_NAME="$SERVER_NAME MCP Server"
fi

if [[ -z "$DESCRIPTION" ]]; then
    DESCRIPTION="Manually added $TRANSPORT server"
fi

echo -e "${BLUE}[INFO] Adding server to registry: $SERVER_NAME${NC}"
echo ""

# ============================================
# BUILD SERVER DEFINITION
# ============================================

server_def=$(jq -n \
    --arg name "$DISPLAY_NAME" \
    --arg desc "$DESCRIPTION" \
    --arg transport "$TRANSPORT" \
    '{
        name: $name,
        description: $desc,
        transport: $transport
    }')

# Add transport-specific fields
case $TRANSPORT in
    stdio)
        if [[ -z "$COMMAND" ]]; then
            echo -e "${RED}[ERROR] --command is required for stdio transport${NC}"
            exit 1
        fi

        # Convert comma-separated args to JSON array
        args_array="[]"
        if [[ -n "$ARGS" ]]; then
            args_array=$(echo "$ARGS" | jq -R 'split(",") | map(gsub("^\\s+|\\s+$";""))')
        fi

        server_def=$(echo "$server_def" | jq \
            --arg cmd "$COMMAND" \
            --argjson args "$args_array" \
            '. + {command: $cmd, args: $args}')
        ;;

    http-local)
        if [[ -z "$URL" ]]; then
            echo -e "${RED}[ERROR] --url is required for http-local transport${NC}"
            exit 1
        fi

        server_def=$(echo "$server_def" | jq --arg url "$URL" '. + {url: $url}')

        if [[ -n "$SERVER_PATH" ]]; then
            server_def=$(echo "$server_def" | jq --arg path "$SERVER_PATH" '. + {path: $path}')
        fi

        if [[ -n "$COMMAND" ]]; then
            server_def=$(echo "$server_def" | jq --arg cmd "$COMMAND" '. + {command: $cmd}')
        fi
        ;;

    http-remote)
        if [[ -z "$URL" ]]; then
            echo -e "${RED}[ERROR] --url is required for http-remote transport${NC}"
            exit 1
        fi

        server_def=$(echo "$server_def" | jq --arg url "$URL" '. + {httpUrl: $url}')
        ;;

    http-remote-auth)
        if [[ -z "$URL" ]]; then
            echo -e "${RED}[ERROR] --url is required for http-remote-auth transport${NC}"
            exit 1
        fi

        if [[ "$HEADERS" == "{}" ]]; then
            echo -e "${RED}[ERROR] --header is required for http-remote-auth transport${NC}"
            exit 1
        fi

        server_def=$(echo "$server_def" | jq \
            --arg url "$URL" \
            --argjson headers "$HEADERS" \
            '. + {httpUrl: $url, headers: $headers}')
        ;;
esac

# Add env vars if provided
if [[ "$ENV_VARS" != "{}" ]]; then
    server_def=$(echo "$server_def" | jq --argjson env "$ENV_VARS" '. + {env: $env}')
fi

# ============================================
# ADD TO REGISTRY
# ============================================

# Check if server already exists
if jq -e ".servers[\"$SERVER_NAME\"]" "$SERVERS_FILE" > /dev/null 2>&1; then
    echo -e "${YELLOW}[WARN] Server '$SERVER_NAME' already exists in registry${NC}"
    echo "Do you want to overwrite? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
fi

# Backup registry
backup_file="${REGISTRY_DIR}/backups/servers-$(date +%Y%m%d_%H%M%S).json"
mkdir -p "${REGISTRY_DIR}/backups"
cp "$SERVERS_FILE" "$backup_file"

# Add server to registry
tmp_file=$(mktemp)
jq --arg key "$SERVER_NAME" --argjson def "$server_def" \
    '.servers[$key] = $def' \
    "$SERVERS_FILE" > "$tmp_file"
mv "$tmp_file" "$SERVERS_FILE"

# ============================================
# REPORT RESULTS
# ============================================

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Server Added to Registry${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Server: $SERVER_NAME"
echo "Transport: $TRANSPORT"
echo "Registry: $SERVERS_FILE"
echo "Backup: $backup_file"
echo ""

# Show server definition
echo "Server definition:"
jq ".servers[\"$SERVER_NAME\"]" "$SERVERS_FILE"

echo ""
echo "Next steps:"
echo "  1. Add server to your project:"
echo "     /core:mcp-add $SERVER_NAME"
echo ""
echo "  2. List all servers:"
echo "     bash plugins/01-core/skills/mcp-configuration/scripts/registry-list.sh"
echo ""

exit 0

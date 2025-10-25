#!/usr/bin/env bash
# Script: registry-scan.sh
# Purpose: Scan directory for MCP servers and add to registry - detection (MECHANICAL)
# Plugin: 01-core
# Skill: mcp-configuration
# Usage: ./registry-scan.sh <servers-directory>

set -euo pipefail

# Configuration
SCAN_DIR="${1:-/home/gotime2022/Projects/Mcp-Servers}"
REGISTRY_DIR="${HOME}/.claude/mcp-registry"
SERVERS_FILE="${REGISTRY_DIR}/servers.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Validate inputs
if [[ ! -d "$SCAN_DIR" ]]; then
    echo -e "${RED}[ERROR] Directory not found: $SCAN_DIR${NC}"
    exit 1
fi

if [[ ! -f "$SERVERS_FILE" ]]; then
    echo -e "${RED}[ERROR] Registry not initialized${NC}"
    echo "Run: bash plugins/01-core/skills/mcp-configuration/scripts/registry-init.sh"
    exit 1
fi

echo -e "${BLUE}[INFO] Scanning for MCP servers in: $SCAN_DIR${NC}"
echo ""

SERVERS_FOUND=0
SERVERS_ADDED=0

# ============================================
# SCAN FOR SERVER DIRECTORIES
# ============================================

# Find all directories ending in -mcp or -http-mcp
while IFS= read -r server_dir; do
    ((SERVERS_FOUND++))

    server_path="$SCAN_DIR/$server_dir"
    server_name=$(echo "$server_dir" | sed 's/-http-mcp$//' | sed 's/-mcp$//')

    echo -e "${BLUE}[SCAN] Found: $server_dir${NC}"

    # ============================================
    # DETECT TRANSPORT TYPE
    # ============================================

    transport="unknown"
    command_to_run=""
    port=""

    # Look for server entry point
    if [[ -f "$server_path/src/server.py" ]]; then
        command_to_run="python src/server.py"
        transport="http-local"
    elif [[ -f "$server_path/server.py" ]]; then
        command_to_run="python server.py"
        transport="http-local"
    elif [[ -f "$server_path/src/__main__.py" ]]; then
        command_to_run="python -m src"
        transport="http-local"
    elif [[ -f "$server_path/index.js" ]]; then
        command_to_run="node index.js"
        transport="http-local"
    fi

    # Detect port from config files
    if [[ -f "$server_path/config/server.json" ]]; then
        port=$(jq -r '.port // empty' "$server_path/config/server.json" 2>/dev/null || echo "")
    elif [[ -f "$server_path/configs/server.json" ]]; then
        port=$(jq -r '.port // empty' "$server_path/configs/server.json" 2>/dev/null || echo "")
    elif [[ -f "$server_path/.env.example" ]]; then
        port=$(grep -oP 'PORT=\K\d+' "$server_path/.env.example" 2>/dev/null | head -1 || echo "")
    fi

    # Default port if not found
    if [[ -z "$port" ]]; then
        port="8030"
    fi

    # ============================================
    # EXTRACT ENVIRONMENT VARIABLES
    # ============================================

    env_vars="{}"
    if [[ -f "$server_path/.env.example" ]]; then
        # Extract env var names (not values)
        env_vars=$(grep -oP '^[A-Z_]+(?==)' "$server_path/.env.example" 2>/dev/null | \
            jq -R -s 'split("\n") | map(select(length > 0)) | map({(.): "${" + . + "}"}) | add // {}' || echo "{}")
    fi

    # ============================================
    # ADD TO REGISTRY
    # ============================================

    if [[ "$transport" != "unknown" ]]; then
        # Create server definition
        server_def=$(jq -n \
            --arg name "$server_name MCP Server" \
            --arg desc "Auto-detected from $server_dir" \
            --arg transport "$transport" \
            --arg path "$server_path" \
            --arg command "$command_to_run" \
            --arg url "http://localhost:$port" \
            --argjson env "$env_vars" \
            '{
                name: $name,
                description: $desc,
                transport: $transport,
                path: $path,
                command: $command,
                url: $url,
                env: $env
            }')

        # Add to registry
        tmp_file=$(mktemp)
        jq --arg key "$server_name" --argjson def "$server_def" \
            '.servers[$key] = $def' \
            "$SERVERS_FILE" > "$tmp_file"
        mv "$tmp_file" "$SERVERS_FILE"

        ((SERVERS_ADDED++))
        echo -e "${GREEN}  ✅ Added: $server_name (http-local, port $port)${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Skipped: Could not detect transport type${NC}"
    fi

    echo ""

done < <(ls -1 "$SCAN_DIR" | grep -E '\-mcp$|\-http\-mcp$')

# ============================================
# REPORT RESULTS
# ============================================

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Scan Complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Servers found: $SERVERS_FOUND"
echo "Servers added to registry: $SERVERS_ADDED"
echo "Registry location: $SERVERS_FILE"
echo ""
echo "Next steps:"
echo "  1. Review registry:"
echo "     cat $SERVERS_FILE"
echo ""
echo "  2. List all servers:"
echo "     bash plugins/01-core/skills/mcp-configuration/scripts/registry-list.sh"
echo ""
echo "  3. Add server to project:"
echo "     /core:mcp-add <server-name>"
echo ""

exit 0

#!/usr/bin/env bash
# Script: registry-list.sh
# Purpose: List all MCP servers in registry - display (MECHANICAL)
# Plugin: 01-core
# Skill: mcp-configuration
# Usage: ./registry-list.sh [--filter <transport-type>]

set -euo pipefail

# Configuration
REGISTRY_DIR="${HOME}/.claude/mcp-registry"
SERVERS_FILE="${REGISTRY_DIR}/servers.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Parse arguments
FILTER=""
if [[ "${1:-}" == "--filter" ]]; then
    FILTER="${2:-}"
fi

# Validate registry exists
if [[ ! -f "$SERVERS_FILE" ]]; then
    echo -e "${RED}[ERROR] Registry not initialized${NC}"
    echo "Run: bash plugins/01-core/skills/mcp-configuration/scripts/registry-init.sh"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}MCP Server Registry${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Count servers
total_servers=$(jq '.servers | length' "$SERVERS_FILE")
echo -e "${CYAN}Total servers: $total_servers${NC}"
echo -e "${GRAY}Registry: $SERVERS_FILE${NC}"
echo ""

# Get all server names
server_names=$(jq -r '.servers | keys[]' "$SERVERS_FILE" | sort)

if [[ -z "$server_names" ]]; then
    echo -e "${YELLOW}No servers in registry${NC}"
    echo ""
    echo "Add servers:"
    echo "  1. Scan existing servers:"
    echo "     bash plugins/01-core/skills/mcp-configuration/scripts/registry-scan.sh /Projects/Mcp-Servers"
    echo ""
    echo "  2. Manually add server:"
    echo "     bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh <name> --transport <type> [options]"
    echo ""
    exit 0
fi

# Print header
printf "${CYAN}%-30s %-20s %-50s${NC}\n" "SERVER" "TRANSPORT" "DETAILS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# List each server
while IFS= read -r server_name; do
    # Get server details
    transport=$(jq -r ".servers[\"$server_name\"].transport" "$SERVERS_FILE")

    # Skip if filter doesn't match
    if [[ -n "$FILTER" && "$transport" != "$FILTER" ]]; then
        continue
    fi

    # Get transport-specific details
    details=""
    case $transport in
        stdio)
            command=$(jq -r ".servers[\"$server_name\"].command" "$SERVERS_FILE")
            details="command: $command"
            ;;
        http-local)
            url=$(jq -r ".servers[\"$server_name\"].url" "$SERVERS_FILE")
            details="$url"
            ;;
        http-remote)
            url=$(jq -r ".servers[\"$server_name\"].httpUrl" "$SERVERS_FILE")
            details="$url"
            ;;
        http-remote-auth)
            url=$(jq -r ".servers[\"$server_name\"].httpUrl" "$SERVERS_FILE")
            details="$url (authenticated)"
            ;;
        *)
            details="unknown"
            ;;
    esac

    # Determine color based on transport type
    color=""
    case $transport in
        stdio) color="${GREEN}" ;;
        http-local) color="${YELLOW}" ;;
        http-remote) color="${BLUE}" ;;
        http-remote-auth) color="${CYAN}" ;;
        *) color="${GRAY}" ;;
    esac

    # Print server row
    printf "${color}%-30s${NC} %-20s %-50s\n" "$server_name" "$transport" "$details"

done <<< "$server_names"

echo ""
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show transport type legend
echo "Transport Types:"
echo -e "  ${GREEN}stdio${NC}             - Local subprocess (command + args)"
echo -e "  ${YELLOW}http-local${NC}        - HTTP on localhost (you start it)"
echo -e "  ${BLUE}http-remote${NC}       - Remote HTTP (plain URL)"
echo -e "  ${CYAN}http-remote-auth${NC}  - Remote HTTP with authentication"
echo ""

# Show filtering option
if [[ -z "$FILTER" ]]; then
    echo "Filter by type:"
    echo "  bash $0 --filter stdio"
    echo "  bash $0 --filter http-local"
    echo ""
fi

# Show usage
echo "Next steps:"
echo "  1. View server details:"
echo "     jq '.servers[\"<server-name>\"]' $SERVERS_FILE"
echo ""
echo "  2. Add server to project:"
echo "     /core:mcp-add <server-name>"
echo ""

exit 0

#!/usr/bin/env bash
# Script: transform-toml.sh
# Purpose: Transform registry to TOML format (Codex) - mechanical conversion (NO AI)
# Plugin: 01-core
# Skill: mcp-configuration
# Usage: ./transform-toml.sh [server-name...]

set -euo pipefail

# Configuration
REGISTRY_DIR="${HOME}/.claude/mcp-registry"
SERVERS_FILE="${REGISTRY_DIR}/servers.json"
TARGET_FILE="${HOME}/.codex/config.toml"

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

# Validate target file exists
if [[ ! -f "$TARGET_FILE" ]]; then
    echo -e "${RED}[ERROR] Codex config not found: $TARGET_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}[INFO] Transforming registry to Codex TOML format${NC}"
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
# BACKUP ORIGINAL
# ============================================

backup_dir="${HOME}/.codex/backups"
mkdir -p "$backup_dir"
backup_file="$backup_dir/config-$(date +%Y%m%d_%H%M%S).toml"
cp "$TARGET_FILE" "$backup_file"
echo -e "${GREEN}✅ Backed up to: $backup_file${NC}"
echo ""

# ============================================
# GENERATE TOML SECTIONS
# ============================================

toml_sections=""

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

    # Build TOML section
    toml_section=""

    case $transport in
        stdio)
            command=$(echo "$server_def" | jq -r '.command')
            args=$(echo "$server_def" | jq -r '.args // [] | @json')

            toml_section="[mcp_servers.${server_name}]
command = \"$command\"
args = $args
"
            ;;

        http-local)
            url=$(echo "$server_def" | jq -r '.url')

            toml_section="[mcp_servers.${server_name}]
url = \"$url\"
"
            ;;

        http-remote|http-remote-auth)
            httpUrl=$(echo "$server_def" | jq -r '.httpUrl')

            toml_section="[mcp_servers.${server_name}]
url = \"$httpUrl\"
"

            # Add headers if present
            if [[ "$transport" == "http-remote-auth" ]]; then
                headers=$(echo "$server_def" | jq -r '.headers // {}')
                if [[ "$headers" != "{}" ]]; then
                    # Convert headers to TOML inline table format
                    headers_toml=$(echo "$headers" | jq -r 'to_entries | map("\(.key) = \"\(.value)\"") | join(", ")')
                    toml_section+="headers = { $headers_toml }
"
                fi
            fi
            ;;

        *)
            echo -e "${YELLOW}  ⚠️  Unknown transport type: $transport${NC}"
            continue
            ;;
    esac

    # Add env vars if present
    env_vars=$(echo "$server_def" | jq -r '.env // {}')
    if [[ "$env_vars" != "{}" ]]; then
        env_toml=$(echo "$env_vars" | jq -r 'to_entries | map("\(.key) = \"\(.value)\"") | join(", ")')
        toml_section+="env = { $env_toml }
"
    fi

    toml_sections+="
$toml_section"

    echo -e "${GREEN}  ✅ Transformed ($transport)${NC}"
done

# ============================================
# UPDATE CONFIG FILE
# ============================================

# Check if [mcp_servers] section exists
if grep -q '^\[mcp_servers\.' "$TARGET_FILE"; then
    echo -e "${YELLOW}[WARN] Existing MCP servers found in config${NC}"
    echo "Appending new servers..."

    # Append to end of file
    echo "$toml_sections" >> "$TARGET_FILE"
else
    echo "Adding new MCP servers section..."

    # Add section to end of file
    echo "" >> "$TARGET_FILE"
    echo "# MCP Servers (auto-generated from registry)" >> "$TARGET_FILE"
    echo "$toml_sections" >> "$TARGET_FILE"
fi

# ============================================
# REPORT RESULTS
# ============================================

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Transform Complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Tool: Codex"
echo "Servers added: ${#SERVERS_TO_ADD[@]}"
echo "Target file: $TARGET_FILE"
echo "Backup: $backup_file"
echo ""
echo "Note: Review the config file to ensure proper TOML formatting"
echo "      cat $TARGET_FILE"
echo ""

exit 0

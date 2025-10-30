#!/usr/bin/env bash
# Script: list-servers.sh
# Purpose: List all MCP servers in the global registry
# Subsystem: mcp
# Called by: /mcp:list slash command
# Outputs: JSON array of server definitions

set -euo pipefail

# --- Configuration ---
REGISTRY_FILE="${1:-$HOME/$([ -f "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/config" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/config" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-config" -type d -path "*/skills/*" -name "config" 2>/dev/null | head -1)/mcp-servers-registry.json" ] && echo "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/config" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/config" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-config" -type d -path "*/skills/*" -name "config" 2>/dev/null | head -1)/mcp-servers-registry.json" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-core/skills/*/config" -name "mcp-servers-registry.json" -type f 2>/dev/null | head -1)}"
OUTPUT_FILE="${2:-/tmp/mcp-servers-list.json}"

# --- Main Logic ---
if [[ ! -f "$REGISTRY_FILE" ]]; then
    echo "[ERROR] Registry file not found: $REGISTRY_FILE" >&2
    exit 1
fi

echo "[INFO] Reading MCP server registry: $REGISTRY_FILE"

# Extract all servers with their metadata
jq 'to_entries | map({
    name: .key,
    description: .value.description,
    variants: (.value.variants | keys),
    has_local: (if .value.variants.local then true else false end),
    has_remote: (if .value.variants.remote then true else false end)
}) | sort_by(.name)' "$REGISTRY_FILE" > "$OUTPUT_FILE"

SERVER_COUNT=$(jq 'length' "$OUTPUT_FILE")

echo "✅ Found $SERVER_COUNT servers in registry"
echo "📄 Output saved to: $OUTPUT_FILE"
exit 0

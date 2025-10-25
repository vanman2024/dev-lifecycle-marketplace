#!/usr/bin/env bash
# Script: validate-config.sh
# Purpose: Validate MCP configuration file syntax and required fields
# Subsystem: mcp
# Called by: /mcp:add, /mcp:update slash commands
# Outputs: Validation report with errors/warnings

set -euo pipefail

# --- Configuration ---
CONFIG_FILE="${1:-.mcp.json}"
OUTPUT_FILE="${2:-/tmp/mcp-config-validation.json}"

# --- Main Logic ---
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

echo "[INFO] Validating MCP config file: $CONFIG_FILE"

# Check JSON syntax
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    echo "[ERROR] Invalid JSON syntax in $CONFIG_FILE" >&2
    cat > "$OUTPUT_FILE" <<EOF
{
  "valid": false,
  "errors": ["Invalid JSON syntax"],
  "warnings": []
}
EOF
    exit 1
fi

# Validate required fields
ERRORS=()
WARNINGS=()

# Check for mcpServers key
if ! jq -e '.mcpServers' "$CONFIG_FILE" >/dev/null 2>&1; then
    ERRORS+=("Missing required key: mcpServers")
fi

# Check each server has required fields
MISSING_COMMAND=$(jq -r '.mcpServers | to_entries[] | select(.value.command == null or .value.command == "") | .key' "$CONFIG_FILE" 2>/dev/null || true)
if [[ -n "$MISSING_COMMAND" ]]; then
    ERRORS+=("Server '$MISSING_COMMAND' missing required field: command")
fi

# Check for hardcoded API keys (should use environment variables)
HARDCODED_KEYS=$(grep -E '(sk-[a-zA-Z0-9]{20,}|MCP_[A-Z_]+_API_KEY": "[^$])' "$CONFIG_FILE" || true)
if [[ -n "$HARDCODED_KEYS" ]]; then
    WARNINGS+=("Possible hardcoded API keys detected - should use environment variables")
fi

# Build validation report
ERRORS_JSON=$(printf '%s\n' "${ERRORS[@]}" | jq -R . | jq -s .)
WARNINGS_JSON=$(printf '%s\n' "${WARNINGS[@]}" | jq -R . | jq -s .)

cat > "$OUTPUT_FILE" <<EOF
{
  "valid": $([ ${#ERRORS[@]} -eq 0 ] && echo "true" || echo "false"),
  "errors": $ERRORS_JSON,
  "warnings": $WARNINGS_JSON,
  "file": "$CONFIG_FILE"
}
EOF

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo "❌ Validation failed with ${#ERRORS[@]} error(s)"
    exit 1
else
    echo "✅ Config file is valid"
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo "⚠️  ${#WARNINGS[@]} warning(s) found"
    fi
fi

exit 0

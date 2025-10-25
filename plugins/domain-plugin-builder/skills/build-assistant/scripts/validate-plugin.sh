#!/usr/bin/env bash
# Script: validate-plugin.sh
# Purpose: Validate plugin directory compliance with Claude Code standards
# Subsystem: build-system
# Called by: /build:plugin command after generation
# Outputs: Validation report to stdout

set -euo pipefail

PLUGIN_DIR="${1:?Usage: $0 <plugin-directory>}"

echo "[INFO] Validating plugin directory: $PLUGIN_DIR"

# Check directory exists
if [[ ! -d "$PLUGIN_DIR" ]]; then
    echo "❌ ERROR: Directory not found: $PLUGIN_DIR"
    exit 1
fi

# Check .claude-plugin directory exists
if [[ ! -d "$PLUGIN_DIR/.claude-plugin" ]]; then
    echo "❌ ERROR: Missing .claude-plugin directory"
    exit 1
fi

# Check plugin.json exists
if [[ ! -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]]; then
    echo "❌ ERROR: Missing plugin.json manifest"
    exit 1
fi

# Validate JSON syntax
if ! python3 -m json.tool "$PLUGIN_DIR/.claude-plugin/plugin.json" > /dev/null 2>&1; then
    echo "❌ ERROR: Invalid JSON in plugin.json"
    exit 1
fi

# Check required fields in plugin.json
REQUIRED_FIELDS=("name")
for field in "${REQUIRED_FIELDS[@]}"; do
    if ! grep -q "\"$field\":" "$PLUGIN_DIR/.claude-plugin/plugin.json"; then
        echo "❌ ERROR: Missing required field: $field"
        exit 1
    fi
done

# Check component directories are at root (not inside .claude-plugin)
if [[ -d "$PLUGIN_DIR/.claude-plugin/commands" ]] || \
   [[ -d "$PLUGIN_DIR/.claude-plugin/skills" ]] || \
   [[ -d "$PLUGIN_DIR/.claude-plugin/hooks" ]]; then
    echo "❌ ERROR: Component directories must be at plugin root, not inside .claude-plugin/"
    exit 1
fi

echo "✅ Plugin validation passed"
exit 0

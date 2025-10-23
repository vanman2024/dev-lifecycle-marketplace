---
allowed-tools: Task, Bash
description: Manage MCP servers (add, remove, update, registry)
argument-hint: <action> [server-name] [options]
---

User input: $ARGUMENTS

**Manage MCP Servers**

Add, remove, update, and manage MCP server registry.

## Usage

```bash
# Add MCP server(s)
/mcp:manage add github memory
/mcp:manage add playwright local
/mcp:manage add postman remote vscode

# Remove MCP server
/mcp:manage remove github

# Update MCP keys in configs
/mcp:manage update github
/mcp:manage update github all

# Registry operations
/mcp:manage registry list
/mcp:manage registry add server-name local
/mcp:manage registry remove server-name
/mcp:manage registry update
```

## Implementation

Execute the following bash script:

```bash
#!/usr/bin/env bash
set -euo pipefail

ACTION="$1"
shift || true

PROJECT_MCP=".mcp.json"
PLUGIN_DIR="$HOME/.claude/marketplaces/multiagent-dev/plugins"

# Ensure project .mcp.json exists
if [[ ! -f "$PROJECT_MCP" ]]; then
    echo '{"mcpServers": {}}' > "$PROJECT_MCP"
fi

case "$ACTION" in
  add)
    # Add MCP servers from plugin(s)
    SERVERS=("$@")

    if [[ ${#SERVERS[@]} -eq 0 ]]; then
        echo "❌ Usage: /mcp:manage add <plugin-name> [plugin-name...]"
        exit 1
    fi

    for PLUGIN in "${SERVERS[@]}"; do
        PLUGIN_MCP="$PLUGIN_DIR/$PLUGIN/.mcp.json"

        if [[ ! -f "$PLUGIN_MCP" ]]; then
            echo "⚠️  Plugin $PLUGIN has no .mcp.json, skipping"
            continue
        fi

        echo "📦 Merging MCPs from plugin: $PLUGIN"

        # Merge plugin MCPs into project .mcp.json
        jq -s '.[0].mcpServers + .[1].mcpServers | {mcpServers: .}' \
            "$PROJECT_MCP" "$PLUGIN_MCP" > "$PROJECT_MCP.tmp"
        mv "$PROJECT_MCP.tmp" "$PROJECT_MCP"

        echo "✅ Added MCPs from $PLUGIN"
    done

    echo ""
    echo "Current MCP servers:"
    jq -r '.mcpServers | keys[]' "$PROJECT_MCP" | sed 's/^/  - /'
    ;;

  remove)
    # Remove MCP server from project config
    SERVER_NAME="$1"

    if [[ -z "${SERVER_NAME:-}" ]]; then
        echo "❌ Usage: /mcp:manage remove <server-name>"
        exit 1
    fi

    jq "del(.mcpServers.\"$SERVER_NAME\")" "$PROJECT_MCP" > "$PROJECT_MCP.tmp"
    mv "$PROJECT_MCP.tmp" "$PROJECT_MCP"

    echo "✅ Removed MCP server: $SERVER_NAME"
    ;;

  list)
    # List current project MCP servers
    echo "📋 MCP Servers in project:"
    jq -r '.mcpServers | to_entries[] | "  - \(.key)"' "$PROJECT_MCP"
    ;;

  *)
    echo "❌ Unknown action: $ACTION"
    echo "Valid actions: add, remove, list"
    exit 1
    ;;
esac
```

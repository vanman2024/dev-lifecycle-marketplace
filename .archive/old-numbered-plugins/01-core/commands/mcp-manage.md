---
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion, WebFetch
description: Comprehensive MCP server management (add, remove, list, setup, clear)
argument-hint: <action> [server-name...]
---

**Arguments**: $ARGUMENTS

**Comprehensive MCP Server Management**

Manage MCP servers across registry, project (.mcp.json), and VS Code (.vscode/mcp.json).

## Usage

```bash
# Add new server (fetches latest config from GitHub)
/01-core:mcp-manage add context7

# Add server from registry to project
/01-core:mcp-manage install figma-mcp

# Remove server from project
/01-core:mcp-manage remove figma-mcp

# List servers in current project
/01-core:mcp-manage list

# List all available servers in registry
/01-core:mcp-manage registry

# Setup registry (first time)
/01-core:mcp-manage setup

# Clear all MCP servers
/01-core:mcp-manage clear

# Check API keys status
/01-core:mcp-manage keys
```

## Implementation

Parse action from $ARGUMENTS:

### Action: add

Add a NEW MCP server by fetching latest configuration from GitHub/npm:

1. Parse server name from arguments
2. WebFetch the server's GitHub repository or npm page to get latest config
3. AskUserQuestion: "Which transport type?" (stdio, http-local, http-remote)
4. If stdio: AskUserQuestion for command, args, and environment variables needed
5. If http: AskUserQuestion for URL and any required headers/auth
6. Add to registry using registry-add.sh script
7. AskUserQuestion: "Add to current project .mcp.json?" (yes/no)
8. If yes, run install action

Example workflow:
- User runs: `/01-core:mcp-manage add context7`
- WebFetch: `https://github.com/upstash/context7`
- Extract configuration details from README
- Prompt user for transport type
- Prompt for API key if needed
- Add to registry
- Optionally install to project

### Action: install

Install server(s) from registry to current project:

1. Check if server exists in VS Code marketplace list (Read vscode-marketplace-servers.json)
2. AskUserQuestion: "Install to which config?"
   - .mcp.json (Claude Code)
   - .vscode/mcp.json (VS Code)
   - Both
3. If installing to .vscode/mcp.json AND server is in marketplace list:
   - Skip with message: "✅ {server} already available through VS Code marketplace"
4. Otherwise run transform script:

```bash
bash plugins/01-core/skills/mcp-configuration/scripts/transform-json.sh project $SERVER_NAMES
```

### Action: remove

Remove server from project:

```bash
#!/usr/bin/env bash
set -euo pipefail

SERVER_NAME="$2"

if [[ -z "${SERVER_NAME:-}" ]]; then
    echo "❌ Usage: /01-core:mcp-manage remove <server-name>"
    exit 1
fi

# Remove from .mcp.json if exists
if [[ -f ".mcp.json" ]]; then
    jq "del(.mcpServers.\"$SERVER_NAME\")" .mcp.json > .mcp.json.tmp
    mv .mcp.json.tmp .mcp.json
    echo "✅ Removed from .mcp.json"
fi

# Remove from .vscode/mcp.json if exists
if [[ -f ".vscode/mcp.json" ]]; then
    jq "del(.servers.\"$SERVER_NAME\")" .vscode/mcp.json > .vscode/mcp.json.tmp
    mv .vscode/mcp.json.tmp .vscode/mcp.json
    echo "✅ Removed from .vscode/mcp.json"
fi

echo ""
echo "Remaining servers in .mcp.json:"
jq -r '.mcpServers | keys[]' .mcp.json 2>/dev/null | sed 's/^/  - /' || echo "  (none)"
```

### Action: list

List servers in current project:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "📋 MCP Servers Configuration:"
echo ""

if [[ -f ".mcp.json" ]]; then
    echo "Claude Code (.mcp.json):"
    jq -r '.mcpServers | to_entries[] | "  ✓ \(.key) (\(.value.command // .value.url))"' .mcp.json
    echo ""
fi

if [[ -f ".vscode/mcp.json" ]]; then
    echo "VS Code (.vscode/mcp.json):"
    jq -r '.servers | to_entries[] | "  ✓ \(.key) (\(.value.command // .value.url))"' .vscode/mcp.json
    echo ""
fi

if [[ ! -f ".mcp.json" && ! -f ".vscode/mcp.json" ]]; then
    echo "  No MCP servers configured in this project"
fi
```

### Action: registry

Show all available servers in registry:

```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-list.sh
```

### Action: setup

Initialize MCP registry (first-time setup):

```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-init.sh
```

### Action: clear

Clear all MCP servers from project:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🗑️  Clearing all MCP servers from project..."
echo ""

SERVERS_CLEARED=0

if [[ -f ".mcp.json" ]]; then
    COUNT=$(jq '.mcpServers | length' .mcp.json)
    echo '{"mcpServers":{}}' > .mcp.json
    echo "✅ Cleared $COUNT servers from .mcp.json"
    SERVERS_CLEARED=$((SERVERS_CLEARED + COUNT))
fi

if [[ -f ".vscode/mcp.json" ]]; then
    COUNT=$(jq '.servers | length' .vscode/mcp.json)
    echo '{"servers":{}}' > .vscode/mcp.json
    echo "✅ Cleared $COUNT servers from .vscode/mcp.json"
    SERVERS_CLEARED=$((SERVERS_CLEARED + COUNT))
fi

echo ""
echo "🎉 Cleared $SERVERS_CLEARED total MCP servers"
echo "💡 Restart VS Code/Claude Code to apply changes"
```

### Action: keys

Check which MCP API keys are configured:

```bash
bash plugins/01-core/skills/mcp-configuration/scripts/check-mcp-keys.sh
```

Shows:
- Keys that are properly configured (masked values)
- Keys with placeholder values that need replacement
- Missing keys
- Summary statistics

## Examples

```bash
# First time setup
/01-core:mcp-manage setup

# Add new server by fetching from GitHub
/01-core:mcp-manage add @upstash/context7-mcp

# Install existing registry server to project
/01-core:mcp-manage install filesystem

# View what's configured
/01-core:mcp-manage list

# Remove from project
/01-core:mcp-manage remove context7

# Clear everything
/01-core:mcp-manage clear
```

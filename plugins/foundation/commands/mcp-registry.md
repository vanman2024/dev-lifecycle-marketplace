---
description: Manage universal MCP server registry (init, add, list, search, remove)
argument-hint: <action> [server-name] [options]
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here` or `${ENV_VAR}` format
- Environment variables for all sensitive values
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Manage the universal MCP server registry that serves as single source of truth for all MCP server configurations

Core Principles:
- Registry is at ~/.claude/mcp-registry/servers.json
- Single source of truth for all formats (Claude Code, VS Code, Gemini, Qwen, Codex)
- Use /foundation:mcp-sync to convert registry to specific formats
- Support init, add, remove, list, search operations

## Available Skills

This command has access to foundation plugin skills:

- **mcp-configuration**: MCP server configuration templates, API key handling, registry management scripts
- **mcp-server-config**: .mcp.json management and server configuration

To use a skill: `!{skill skill-name}`

---

## Phase 1: Parse Action

Goal: Parse action and check registry state

Actions:
- Parse $ARGUMENTS for action: init, add, remove, list, search
- Extract server name and options if provided
- Check if registry exists: `!{bash test -f ~/.claude/mcp-registry/servers.json && echo "exists" || echo "not found"}`
- If action missing, use AskUserQuestion:
  - "What would you like to do?"
  - Options: init, add, list, search, remove

## Phase 2: Execute Action

Goal: Execute the appropriate registry operation

### For 'init' action:

Create new MCP server registry:

```bash
!{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-init.sh}
```

Report:
- Registry location: ~/.claude/mcp-registry/servers.json
- Next steps: Use 'add' to register servers

### For 'add' action:

Gather server details via AskUserQuestion if not in $ARGUMENTS:
- Server name (e.g., "context7", "github")
- Transport type: stdio, http-local, http-remote, http-remote-auth
- Command (stdio): e.g., "npx", "python"
- Args (stdio): comma-separated
- URL (http): endpoint URL
- Environment variables: KEY=${ENV_VAR} format
- Description: what the server provides

Execute add script based on transport:

**STDIO Transport:**
```bash
!{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-add.sh $SERVER_NAME \
  --transport stdio \
  --command $COMMAND \
  --args "$ARGS" \
  --env "$ENV_VARS"}
```

**HTTP Remote Transport:**
```bash
!{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-add.sh $SERVER_NAME \
  --transport http-remote \
  --url "$URL"}
```

**HTTP Remote Auth:**
```bash
!{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-add.sh $SERVER_NAME \
  --transport http-remote-auth \
  --url "$URL" \
  --header "Authorization: Bearer \${TOKEN_VAR}"}
```

Confirm server added: `!{bash jq ".servers[\"$SERVER_NAME\"]" ~/.claude/mcp-registry/servers.json}`

### For 'list' action:

List all servers in registry:

```bash
!{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-list.sh}
```

Display format:
- Server name
- Transport type
- Description
- Scope (global/project)

### For 'search' action:

Search for servers by keyword:

```bash
!{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-search.sh "$SEARCH_QUERY"}
```

Searches in:
- Server name
- Description
- Transport type

### For 'remove' action:

Confirm server name from $ARGUMENTS or AskUserQuestion

Remove server:

```bash
!{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-remove.sh "$SERVER_NAME"}
```

Confirm removal: "Removed $SERVER_NAME from registry"

## Phase 3: Summary

Goal: Report results and next steps

Actions:
- Display action completion status
- For 'init': "Registry initialized. Add servers with '/foundation:mcp-registry add'"
- For 'add': "Added $SERVER_NAME. Sync to format with '/foundation:mcp-sync'"
- For 'list': Display server count and suggest sync
- For 'search': Display results count
- For 'remove': "Removed $SERVER_NAME. Sync to update active configs."

Next steps:
- Use /foundation:mcp-sync to convert registry to target format (.mcp.json or .vscode/mcp.json)
- Verify sync: Check active configuration file
- Test server: Use server tools in Claude Code or VS Code

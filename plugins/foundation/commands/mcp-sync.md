---
description: Sync universal MCP registry to target format (.mcp.json or .vscode/mcp.json)
argument-hint: <claude|vscode|both> [server-name...]
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders or environment variable references: `${ENV_VAR}`
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Convert universal MCP server registry to Claude Code (.mcp.json) or VS Code (.vscode/mcp.json) format on demand

Core Principles:
- Registry is single source of truth (~/.claude/mcp-registry/servers.json)
- Support selective sync (specific servers) or full sync (all servers)
- Create backups before modifying configs
- Validate registry exists before syncing

## Available Skills

This command has access to foundation plugin skills:

- **mcp-configuration**: MCP server configuration templates, registry sync scripts
- **mcp-server-config**: .mcp.json management

To use a skill: `!{skill skill-name}`

---

## Phase 1: Validate Registry

Goal: Parse arguments and validate registry exists

Actions:
- Parse $ARGUMENTS for format: claude, vscode, or both
- Extract optional server names for selective sync
- Check if registry exists: `!{bash test -f ~/.claude/mcp-registry/servers.json && echo "exists" || echo "not found"}`
- If registry doesn't exist:
  - Display: "Registry not found. Run '/foundation:mcp-registry init' first."
  - Exit with helpful message
- Display current registry contents: `!{bash jq '.servers | keys' ~/.claude/mcp-registry/servers.json}`

## Phase 2: Validate Format

Goal: Verify format and server names are valid

Actions:
- Validate format is one of: claude, vscode, both
- If invalid or missing, use AskUserQuestion:
  - "Which format would you like to sync to?"
  - Options: Claude Code (.mcp.json), VS Code (.vscode/mcp.json), Both formats
- If specific servers provided, verify they exist in registry:
  - `!{bash jq -r ".servers | has(\"$SERVER_NAME\")" ~/.claude/mcp-registry/servers.json}`
  - Warn if server not found

## Phase 3: Execute Sync

Goal: Run registry-sync.sh script to perform transformation

Actions:
- Execute sync script with format and optional servers:

**Sync all servers:**
```bash
!{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-sync.sh $FORMAT}
```

**Sync specific servers:**
```bash
!{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/registry-sync.sh $FORMAT $SERVER1 $SERVER2 $SERVER3}
```

Script will:
- Read from ~/.claude/mcp-registry/servers.json
- Transform to target format (Claude Code or VS Code)
- Create backups of existing configs
- Update .mcp.json and/or .vscode/mcp.json with selected servers

## Phase 4: Verify Sync

Goal: Confirm sync completed successfully

Actions:
- For Claude Code format:
  - Check .mcp.json was updated: `!{bash test -f .mcp.json && echo "✓ Updated" || echo "✗ Missing"}`
  - Display server count: `!{bash jq '.mcpServers | keys | length' .mcp.json`}
  - List synced servers: `!{bash jq -r '.mcpServers | keys[]' .mcp.json}`

- For VS Code format:
  - Check .vscode/mcp.json was updated: `!{bash test -f .vscode/mcp.json && echo "✓ Updated" || echo "✗ Missing"}`
  - Display server count: `!{bash jq '.mcpServers | keys | length' .vscode/mcp.json}`
  - List synced servers: `!{bash jq -r '.mcpServers | keys[]' .vscode/mcp.json}`

- Confirm backup created: `!{bash ls -lt ~/.claude/mcp-registry/backups/ | head -5}`

## Phase 5: Summary

Goal: Report sync results and next steps

Actions:
- Display sync summary:
  - Format(s) updated: Claude Code, VS Code, or both
  - Server count: Total servers synced
  - Selective sync: If specific servers, list them
  - Backup location: ~/.claude/mcp-registry/backups/

- Provide next steps based on format:
  - **Claude Code**: Restart Claude Code to load new MCP servers
  - **VS Code**: Reload VS Code window (Cmd/Ctrl+Shift+P → "Reload Window")
  - **Both**: Restart both editors

- Document environment variables:
  - List all ${ENV_VAR} references found in synced servers
  - Provide Doppler setup command if variables detected:
    - "Add to Doppler: doppler secrets set VAR_NAME=value --config dev"

- Success indicators:
  - "✓ Synced {count} servers to {format}"
  - "✓ Backups created"
  - "✓ Configuration files updated"

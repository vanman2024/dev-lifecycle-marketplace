---
description: Sync universal MCP registry to target format (.mcp.json or .vscode/mcp.json)
argument-hint: <claude|vscode|both> [server-name...]
allowed-tools: Bash, Read, Write, Grep
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Convert universal MCP server registry to Claude Code (.mcp.json) or VS Code (.vscode/mcp.json) format on demand

Core Principles:
- Registry is single source of truth (~/.claude/mcp-registry/servers.json)
- Support selective sync (specific servers) or full sync (all servers)
- Create backups before modifying configs
- Validate registry exists before syncing

## Phase 1: Discovery

Goal: Parse arguments and validate registry exists

Actions:
- Parse $ARGUMENTS for format: claude, vscode, or both
- Extract optional server names for selective sync
- Check if registry exists at ~/.claude/mcp-registry/servers.json
- If registry doesn't exist:
  - Inform user they need to initialize it first
  - Provide command: /foundation:mcp-registry init
  - Exit with helpful message
- Display current registry contents: !{jq '.servers | keys' ~/.claude/mcp-registry/servers.json}

## Phase 2: Validation

Goal: Verify format and server names are valid

Actions:
- Validate format is one of: claude, vscode, both
- If invalid or missing, use AskUserQuestion:
  - "Which format would you like to sync to?"
  - Options: Claude Code (.mcp.json), VS Code (.vscode/mcp.json), Both formats
- If specific servers provided, verify they exist in registry:
  - !{jq -r ".servers | has(\"$SERVER_NAME\")" ~/.claude/mcp-registry/servers.json}
  - Warn if server not found

## Phase 3: Execution

Goal: Run registry-sync.sh script to perform transformation

Actions:
- Execute sync script with format and optional servers:
  - !{bash plugins/foundation/skills/mcp-configuration/scripts/registry-sync.sh $FORMAT $SERVERS}
- Script will:
  - Read from ~/.claude/mcp-registry/servers.json
  - Transform to target format(s)
  - Create backups of existing configs
  - Update .mcp.json and/or .vscode/mcp.json
- Capture output and display to user

Example commands:
```bash
# Sync all servers to Claude Code format
!{bash plugins/foundation/skills/mcp-configuration/scripts/registry-sync.sh claude}

# Sync specific servers to VS Code format
!{bash plugins/foundation/skills/mcp-configuration/scripts/registry-sync.sh vscode context7 filesystem}

# Sync all servers to both formats
!{bash plugins/foundation/skills/mcp-configuration/scripts/registry-sync.sh both}
```

## Phase 4: Verification

Goal: Confirm sync completed successfully and show results

Actions:
- Check if target files were created/updated:
  - For claude: Check .mcp.json exists and is valid JSON
  - For vscode: Check .vscode/mcp.json exists and is valid JSON
- Display synced server count
- Show which servers were added
- Display file locations

For claude format:
```bash
!{jq '.mcpServers | keys' .mcp.json 2>/dev/null || echo "Failed to sync"}
```

For vscode format:
```bash
!{jq '.servers | keys' .vscode/mcp.json 2>/dev/null || echo "Failed to sync"}
```

## Phase 5: Summary

Goal: Provide clear feedback on sync operation

Actions:
- Report success or failure
- Show sync details:
  - Format(s) synced to
  - Number of servers synced
  - Target file locations
  - Backup file locations
- Provide next steps:
  - "Claude Code config updated at: .mcp.json"
  - "VS Code config updated at: .vscode/mcp.json"
  - "Restart Claude Code or VS Code to load new servers"
- If sync failed, provide troubleshooting:
  - Check registry file exists
  - Validate JSON format
  - Check file permissions
  - Review error messages from script

## Error Handling

Common issues:
1. Registry not initialized
   - Solution: Run /foundation:mcp-registry init

2. Invalid format specified
   - Solution: Use claude, vscode, or both

3. Server not found in registry
   - Solution: Run /foundation:mcp-registry list to see available servers
   - Add missing server: /foundation:mcp-registry add <server-name>

4. Permission denied
   - Solution: Check file permissions on .mcp.json or .vscode/mcp.json
   - Run: chmod 644 .mcp.json

5. Invalid JSON in registry
   - Solution: Validate registry with: jq . ~/.claude/mcp-registry/servers.json
   - Fix JSON syntax errors

## Technical Notes

**Format Differences**:
- Claude Code (.mcp.json):
  - Root key: `mcpServers`
  - Supports: stdio, http-local, http-remote
  - Environment variables: `${VAR}`

- VS Code (.vscode/mcp.json):
  - Root key: `servers`
  - Supports: stdio, http-local, http-remote, http-remote-auth
  - Can use direct values or `${VAR}`
  - Supports `httpUrl` with `trust: true`

**Marketplace Servers**:
- Servers with `"marketplace": true` are skipped for Claude sync
- These are pre-installed in VS Code (github-copilot, playwright, etc.)
- Listed in ~/.claude/mcp-registry/marketplace.json for reference

**Transport Types**:
1. stdio - Local subprocess (most common)
2. http-local - HTTP server you start manually
3. http-remote - Remote HTTP API
4. http-remote-auth - Remote HTTP with authentication (VS Code only)

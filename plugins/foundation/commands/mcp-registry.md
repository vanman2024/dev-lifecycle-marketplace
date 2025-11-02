---
description: Manage universal MCP server registry (init, add, list, search, remove)
argument-hint: <action> [server-name] [options]
allowed-tools: Bash, Read, Write, Grep, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Manage the universal MCP server registry that serves as single source of truth for all MCP server configurations

Core Principles:
- Registry is at ~/.claude/mcp-registry/servers.json
- Single source of truth for all formats (Claude Code, VS Code, Gemini, Qwen, Codex)
- Use /foundation:mcp-sync to convert registry to specific formats
- Support init, add, remove, list, search operations

## Phase 1: Discovery

Goal: Parse action and check registry state

Actions:
- Parse $ARGUMENTS for action: init, add, remove, list, search
- Check if registry exists: !{test -f ~/.claude/mcp-registry/servers.json && echo "exists" || echo "not found"}
- If action is missing or unclear, use AskUserQuestion:
  - "What would you like to do with the MCP registry?"
  - Options:
    - init: Initialize new registry
    - add: Add server to registry
    - list: List all servers
    - search: Search for servers
    - remove: Remove server from registry

## Phase 2: Action Routing

Goal: Execute the appropriate registry operation

### ACTION: init

Initialize registry if it doesn't exist

```bash
!{bash plugins/foundation/skills/mcp-configuration/scripts/registry-init.sh}
```

Script will:
- Create ~/.claude/mcp-registry/ directory
- Create servers.json with empty structure
- Create README.md with documentation
- Create backups/ directory
- Provide next steps

### ACTION: add

Add new server to registry

Steps:
1. Ask user for server details via AskUserQuestion:
   - Server name (e.g., "context7", "filesystem")
   - Transport type: stdio, http-local, http-remote, http-remote-auth
   - Command (for stdio): e.g., "npx", "python"
   - Args (for stdio): comma-separated, e.g., "-y,@upstash/context7-mcp"
   - URL (for http): e.g., "https://api.example.com/mcp/"
   - Environment variables (optional): KEY=value format

2. Execute add script:
```bash
# stdio example
!{bash plugins/foundation/skills/mcp-configuration/scripts/registry-add.sh context7 \
  --transport stdio \
  --command npx \
  --args "-y,@upstash/context7-mcp" \
  --env "CONTEXT7_API_KEY=\${CONTEXT7_API_KEY}"}

# http-remote example
!{bash plugins/foundation/skills/mcp-configuration/scripts/registry-add.sh api-server \
  --transport http-remote \
  --url "https://api.example.com/mcp/"}

# http-remote-auth example
!{bash plugins/foundation/skills/mcp-configuration/scripts/registry-add.sh github \
  --transport http-remote-auth \
  --url "https://api.githubcopilot.com/mcp/" \
  --header "Authorization: Bearer \${GITHUB_TOKEN}"}
```

3. Confirm server was added:
```bash
!{jq ".servers[\"$SERVER_NAME\"]" ~/.claude/mcp-registry/servers.json}
```

### ACTION: list

List all servers in registry

```bash
!{bash plugins/foundation/skills/mcp-configuration/scripts/registry-list.sh}
```

Or inline:
```bash
!{jq -r '.servers | to_entries[] | "\(.key) - \(.value.transport) - \(.value.description)"' ~/.claude/mcp-registry/servers.json}
```

Display format:
- Server name
- Transport type
- Description
- Scope (global/project)
- Marketplace status

### ACTION: search

Search for servers by keyword

Steps:
1. Get search query from $ARGUMENTS or ask user
2. Search in server names and descriptions:
```bash
!{jq -r --arg query "$SEARCH_TERM" '.servers | to_entries[] | select(.key | contains($query) or .value.description | contains($query)) | "\(.key) - \(.value.description)"' ~/.claude/mcp-registry/servers.json}
```

### ACTION: remove

Remove server from registry

Steps:
1. Confirm server exists:
```bash
!{jq ".servers | has(\"$SERVER_NAME\")" ~/.claude/mcp-registry/servers.json}
```

2. Ask for confirmation via AskUserQuestion:
   - "Are you sure you want to remove $SERVER_NAME from the registry?"
   - Options: Yes, No

3. If confirmed, remove server:
```bash
!{jq "del(.servers[\"$SERVER_NAME\"])" ~/.claude/mcp-registry/servers.json > /tmp/registry.json && mv /tmp/registry.json ~/.claude/mcp-registry/servers.json}
```

4. Create backup:
```bash
!{cp ~/.claude/mcp-registry/servers.json ~/.claude/mcp-registry/backups/servers-$(date +%Y%m%d_%H%M%S).json}
```

## Phase 3: Verification

Goal: Confirm operation completed successfully

Actions based on action:

**For init**:
- Verify registry directory exists
- Verify servers.json has valid structure
- Display registry location

**For add**:
- Verify server appears in registry: !{jq ".servers | has(\"$SERVER_NAME\")" ~/.claude/mcp-registry/servers.json}
- Display server definition
- Provide next step: Use /foundation:mcp-sync to add to project

**For list**:
- Count servers: !{jq '.servers | length' ~/.claude/mcp-registry/servers.json}
- Display formatted list
- Show registry location

**For search**:
- Display matching servers
- Show count of matches
- Suggest using /foundation:mcp-registry list for all servers

**For remove**:
- Verify server no longer in registry
- Display backup location
- Confirm removal

## Phase 4: Summary

Goal: Provide clear feedback and next steps

Actions:
- Report operation success/failure
- Provide relevant next steps:

**After init**:
- "Registry initialized at ~/.claude/mcp-registry/"
- "Add servers with: /foundation:mcp-registry add <server-name>"
- "List servers with: /foundation:mcp-registry list"

**After add**:
- "Server added to registry: $SERVER_NAME"
- "Sync to project with: /foundation:mcp-sync claude" (or vscode/both)
- "View all servers: /foundation:mcp-registry list"

**After list**:
- "Found X servers in registry"
- "Add to project with: /foundation:mcp-sync <format>"
- "Search servers with: /foundation:mcp-registry search <keyword>"

**After search**:
- "Found X matching servers"
- "Add to project with: /foundation:mcp-sync <format> <server-name>"

**After remove**:
- "Server removed from registry: $SERVER_NAME"
- "Backup created at: ~/.claude/mcp-registry/backups/"
- "Update project configs with: /foundation:mcp-sync <format>"

## Error Handling

Common issues:

1. **Registry not initialized**
   - Solution: Run /foundation:mcp-registry init

2. **Server already exists (for add)**
   - Ask if user wants to overwrite
   - Create backup before overwriting

3. **Server not found (for remove/search)**
   - List available servers
   - Suggest /foundation:mcp-registry list

4. **Invalid transport type**
   - Valid types: stdio, http-local, http-remote, http-remote-auth
   - Provide examples for each

5. **Missing required fields**
   - For stdio: command and args required
   - For http: url required
   - For http-remote-auth: url and headers required

6. **Invalid JSON in registry**
   - Restore from backup: ~/.claude/mcp-registry/backups/
   - Validate with: jq . ~/.claude/mcp-registry/servers.json

## Technical Notes

**Registry Structure**:
```json
{
  "_meta": {
    "version": "1.0.0",
    "description": "Universal MCP Server Registry",
    "transport_types": ["stdio", "http-local", "http-remote", "http-remote-auth"]
  },
  "servers": {
    "server-name": {
      "name": "Display Name",
      "description": "What this server does",
      "transport": "stdio|http-local|http-remote|http-remote-auth",
      "scope": "global|project",
      "marketplace": false,
      "command": "...",
      "args": [...],
      "env": {...}
    }
  }
}
```

**Scope Guidance**:
- **global**: Utility servers used across all projects (filesystem, memory, sequential-thinking)
- **project**: Project-specific servers (custom APIs, project-specific tools)

**Marketplace Servers**:
- Mark with `"marketplace": true` if pre-installed in VS Code
- These are skipped during Claude sync
- Reference only - no need to install manually

**Environment Variables**:
- Always use `${VAR}` syntax in registry
- Actual values stored in project .env files
- Use plugins/foundation/skills/mcp-configuration/templates/.env.example as reference

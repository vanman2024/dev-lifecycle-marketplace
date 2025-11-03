---
description: Add, install, remove, list MCP servers and manage API keys
argument-hint: <action> [server-name] [options]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
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

Goal: Comprehensive MCP ecosystem management - add, install, remove, list MCP servers, and manage API keys for the development lifecycle

**RECOMMENDED WORKFLOW** (v2.1+):
For better management across multiple formats (Claude Code, VS Code, etc.), consider using the registry-based workflow:
1. Add servers to universal registry: `/foundation:mcp-registry add <server-name>`
2. Sync registry to project: `/foundation:mcp-sync claude` (or vscode/both)
3. Manage API keys: Use `plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh`

This command continues to support direct .mcp.json management for backward compatibility and quick operations.

Core Principles:
- Detect don't assume - check existing .mcp.json configuration
- Validate before executing - ensure server names and configurations are valid
- Provide clear feedback - show what was added, installed, or removed
- Support all MCP operations - add, install, remove, list, clear, keys
- For multi-format support, use registry workflow (see above)

## Phase 1: Discovery

Goal: Understand the requested action and current MCP configuration

Actions:
- Parse $ARGUMENTS to determine the action (add, install, remove, list, clear, keys)
- **IMPORTANT**: Always use the .mcp.json file in the CURRENT WORKING DIRECTORY
- Check if ./.mcp.json exists in current directory
- If it doesn't exist, create it with empty mcpServers object
- Load current MCP configuration from ./.mcp.json
- Example: @.mcp.json
- Check for existing API keys in common locations:
  - !{bash grep -h "API_KEY\|API-KEY\|_KEY" ~/.bashrc ~/.zshrc ~/.profile 2>/dev/null | grep -v "^#" || echo "No keys found"}
  - !{bash test -f .env && grep "API_KEY" .env || echo "No .env file"}
- Report found keys to avoid duplicates

## Phase 2: Validation

Goal: Verify the action is valid and gather required information

Actions:
- If action is unclear or missing, use AskUserQuestion to ask:
  - What would you like to do? (add, install, remove, list, clear, keys)
  - For add/install: Which MCP server?
  - For remove: Which MCP server to remove?
  - For keys: Which server needs API key configuration?
- Validate server name format (no special characters)
- Check if server already exists (for add) or doesn't exist (for remove)

## Phase 3: Execution

Goal: Perform the MCP management operation

Actions based on action type:

**For 'add' action:**
- **CRITICAL**: Add new MCP server to ./.mcp.json in CURRENT WORKING DIRECTORY
- Never use ~/.mcp.json or any other location
- Use mcp-configuration skill for server templates
- Example: !{bash cat ./.mcp.json}
- Update ./.mcp.json with new server entry
- Report success with full path to modified file

**For 'install' action:**
- Install MCP server package if needed
- Configure server in .mcp.json
- Set up required environment variables
- Example: !{bash npm install @server/package || pip install server-package}
- Verify installation successful

**For 'remove' action:**
- Remove server from .mcp.json
- Clean up associated configuration
- Example: Edit .mcp.json to remove server entry
- Report removal

**For 'list' action:**
- Display all configured MCP servers
- Show server status (installed, configured, running)
- Example: !{bash cat .mcp.json | grep mcpServers -A 50}
- Format output nicely

**For 'clear' action:**
- Remove all MCP server configurations
- Backup current .mcp.json first
- Example: !{bash cp .mcp.json .mcp.json.backup}
- Clear mcpServers section
- Report cleared servers

**For 'keys' action:**
- Check for existing API keys first:
  - !{bash grep "CONTEXT7_API_KEY\|OPENAI_API_KEY\|ANTHROPIC_API_KEY" ~/.bashrc ~/.zshrc ~/.profile .env 2>/dev/null}
- If key exists, report location and value status (set/placeholder)
- If key doesn't exist, guide user through configuration:
  - Ask where to store: .bashrc, .zshrc, .profile, or .env
  - Add key with placeholder value
  - Update .mcp.json with environment variable references
- Example: !{bash echo 'export SERVER_API_KEY="your_key_here"' >> ~/.bashrc}
- Report key configured and remind to update placeholder

## Phase 4: Summary

Goal: Report what was accomplished and next steps

Actions:
- Display summary of action taken:
  - For add: "Added MCP server: {name}"
  - For install: "Installed and configured MCP server: {name}"
  - For remove: "Removed MCP server: {name}"
  - For list: "Found {count} configured MCP servers"
  - For clear: "Cleared {count} MCP servers (backup: .mcp.json.backup)"
  - For keys: "Configured API keys for: {name}"
- Show current MCP server count
- Suggest next steps:
  - After add: "Run installation or configure API keys if needed"
  - After install: "Server ready to use"
  - After keys: "Restart Claude Code to apply changes"

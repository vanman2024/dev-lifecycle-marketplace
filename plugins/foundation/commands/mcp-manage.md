---
description: Add, install, remove, list MCP servers and manage API keys
argument-hint: <action> [server-name] [options]
allowed-tools: Read(*), Write(*), Edit(*), Bash(*), Glob(*), Grep(*), AskUserQuestion(*)
---

**Arguments**: $ARGUMENTS

Goal: Comprehensive MCP ecosystem management - add, install, remove, list MCP servers, and manage API keys for the development lifecycle

Core Principles:
- Detect don't assume - check existing .mcp.json configuration
- Validate before executing - ensure server names and configurations are valid
- Provide clear feedback - show what was added, installed, or removed
- Support all MCP operations - add, install, remove, list, clear, keys

## Phase 1: Discovery

Goal: Understand the requested action and current MCP configuration

Actions:
- Parse $ARGUMENTS to determine the action (add, install, remove, list, clear, keys)
- Detect MCP configuration file location:
  - Project-level: ./.mcp.json
  - Global: ~/.mcp.json
- Load current MCP configuration if exists
- Example: @.mcp.json

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
- Add new MCP server to .mcp.json configuration
- Use mcp-configuration skill for server templates
- Example: !{bash cat .mcp.json}
- Update .mcp.json with new server entry
- Report success

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
- Guide user through API key configuration
- Add keys to .env or environment
- Update .mcp.json with environment variable references
- Example: Edit .env to add API_KEY=value
- Report key configured

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

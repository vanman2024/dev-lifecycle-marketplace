---
allowed-tools: Bash, Read, Edit
description: Setup MCP server API keys and configuration
argument-hint: none
---

Interactive wizard to configure API keys for MCP servers. Adds keys to shell config (~/.bashrc or ~/.zshrc) safely.

**Steps:**

1. Detect shell config file (~/.zshrc if exists, else ~/.bashrc)
2. Create backup of shell config with timestamp
3. Check if MCP section already exists, prompt to update if yes
4. Prompt user for common API keys:
   - GITHUB_PERSONAL_ACCESS_TOKEN
   - POSTMAN_API_KEY
   - Other server-specific keys
5. Add/update export statements in shell config under "# MCP Server Configuration" section
6. Validate keys are set correctly by sourcing config
7. Display success message and remind to run `source ~/.bashrc` or restart terminal
8. Show next steps: `/mcp:list` to see servers, `/mcp:add <server>` to enable

**Example:** `/mcp:setup`

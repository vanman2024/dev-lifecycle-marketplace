---
allowed-tools: Read, Write
description: Clear all MCP servers for maximum context
argument-hint: none
---

Remove all MCP servers from both `.mcp.json` and `.vscode/mcp.json` to maximize context window.

**Steps:**

1. Check if `.mcp.json` exists and count current servers
2. Check if `.vscode/mcp.json` exists and count current servers
3. If both are already empty, display "Already empty" and exit
4. Replace `.mcp.json` content with `{"mcpServers": {}}`
5. Replace `.vscode/mcp.json` content with `{"servers": {}}`
6. Display success message: "Cleared X servers - Maximum context available (0 tokens from MCP)"
7. Remind user to restart Claude/VS Code

**Example:** `/mcp:clear`

# Basic MCP Configuration Setup

This guide walks through setting up your first MCP server configuration from scratch.

## Prerequisites

- Claude Code installed
- Basic understanding of MCP (Model Context Protocol)
- Command-line access

## Step 1: Initialize Configuration

First, create a new `.mcp.json` configuration file:

```bash
bash plugins/foundation/skills/mcp-configuration/scripts/init-mcp-config.sh
```

This creates a minimal configuration structure:

```json
{
  "mcpServers": {}
}
```

## Step 2: Add Your First MCP Server

### Example: Filesystem Server

Add the standard filesystem server to access local files:

```bash
bash plugins/foundation/skills/mcp-configuration/scripts/add-mcp-server.sh \
  --name filesystem \
  --type stdio \
  --command npx \
  --args "@modelcontextprotocol/server-filesystem /home/user/projects"
```

### What This Does

- **name**: Unique identifier for this server (`filesystem`)
- **type**: Communication protocol (`stdio` for local processes)
- **command**: Program to execute (`npx` - Node.js package runner)
- **args**: Arguments passed to the command (package name + directory path)

### Result

Your `.mcp.json` now looks like:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "@modelcontextprotocol/server-filesystem",
        "/home/user/projects"
      ]
    }
  }
}
```

## Step 3: Validate Configuration

Before using the configuration, validate it:

```bash
bash plugins/foundation/skills/mcp-configuration/scripts/validate-mcp-config.sh .mcp.json
```

Expected output:

```
=== JSON Syntax ===
✓ Valid JSON syntax

=== Configuration Structure ===
✓ mcpServers object present
✓ mcpServers is an object
Found 1 MCP server(s)

=== Server Configurations ===
Validating server: filesystem
✓ Valid type: stdio
✓ Command: npx
✓ Command found in PATH: /usr/bin/npx
✓ Args array with 2 element(s)

=== Security Checks ===
✓ No obvious hardcoded secrets found

=== Validation Summary ===
Configuration: .mcp.json
Servers: 1
Errors: 0
Warnings: 0

✓ Configuration is valid!
```

## Step 4: Restart Claude Code

For changes to take effect:

1. Exit Claude Code completely
2. Restart Claude Code
3. The new MCP server will be loaded automatically

## Step 5: Test the Server

In Claude Code, you can now:

- Read files from `/home/user/projects`
- List directories within that path
- Perform file operations through the filesystem MCP server

## Common Server Types to Add

### Python FastMCP Server

```bash
bash plugins/foundation/skills/mcp-configuration/scripts/add-mcp-server.sh \
  --name my-python-server \
  --type stdio \
  --command python3 \
  --args "-m fastmcp run my_server"
```

### TypeScript/Node Server

```bash
bash plugins/foundation/skills/mcp-configuration/scripts/add-mcp-server.sh \
  --name my-node-server \
  --type stdio \
  --command node \
  --args "dist/index.js"
```

### HTTP API Server

```bash
bash plugins/foundation/skills/mcp-configuration/scripts/add-mcp-server.sh \
  --name api-server \
  --type http \
  --url "https://api.example.com"
```

## Troubleshooting

### Server Not Loading

1. **Check configuration syntax:**
   ```bash
   bash scripts/validate-mcp-config.sh .mcp.json
   ```

2. **Verify command exists:**
   ```bash
   which npx
   which python3
   which node
   ```

3. **Check Claude Code logs:**
   - Look for error messages related to MCP server loading

### Command Not Found

If the validation shows "Command not found":

- Use absolute paths: `/usr/bin/python3` instead of `python3`
- Or add the command to your `PATH` environment variable

### Permission Issues

Ensure the MCP server script/binary is executable:

```bash
chmod +x /path/to/server/script
```

## Next Steps

- [API Key Management](./api-key-management.md) - Secure API keys
- [Multiple Servers](./multiple-servers.md) - Manage multiple MCP servers
- [Production Config](./production-config.md) - Production-ready setups

## Related Scripts

- `init-mcp-config.sh` - Initialize configuration
- `add-mcp-server.sh` - Add servers
- `validate-mcp-config.sh` - Validate configuration
- `manage-api-keys.sh` - Manage API keys
- `install-mcp-server.sh` - Install server packages

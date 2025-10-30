# Managing Multiple MCP Servers

This guide explains how to configure and manage multiple MCP servers in a single Claude Code instance.

## Why Multiple Servers?

Different servers provide different capabilities:

- **Filesystem**: Local file access
- **Database**: Query databases
- **API**: External API integration
- **Custom Tools**: Domain-specific functionality

## Adding Multiple Servers

### Method 1: Add Servers One by One

```bash
# Add filesystem server
bash plugins/foundation/skills/mcp-configuration/scripts/add-mcp-server.sh \
  --name filesystem \
  --type stdio \
  --command npx \
  --args "@modelcontextprotocol/server-filesystem /home/user/projects"

# Add Python server
bash plugins/foundation/skills/mcp-configuration/scripts/add-mcp-server.sh \
  --name python-tools \
  --type stdio \
  --command python3 \
  --args "-m my_mcp_server"

# Add HTTP API
bash plugins/foundation/skills/mcp-configuration/scripts/add-mcp-server.sh \
  --name api-gateway \
  --type http \
  --url "https://api.example.com"
```

### Method 2: Use Multi-Server Template

```bash
# Read template
cat plugins/foundation/skills/mcp-configuration/templates/multi-server-config.json

# Copy to your .mcp.json
cp plugins/foundation/skills/mcp-configuration/templates/multi-server-config.json .mcp.json

# Customize paths and configurations
# Edit .mcp.json with your specific settings
```

## Example: Complete Multi-Server Setup

### Scenario: Full-Stack Development Environment

You need:
1. File system access
2. Database queries
3. External API integration
4. Slack notifications

### Step 1: Set Up API Keys

```bash
# Database
bash scripts/manage-api-keys.sh --action add --key-name DATABASE_URL

# External API
bash scripts/manage-api-keys.sh --action add --key-name EXTERNAL_API_KEY

# Slack
bash scripts/manage-api-keys.sh --action add --key-name SLACK_BOT_TOKEN
bash scripts/manage-api-keys.sh --action add --key-name SLACK_SIGNING_SECRET
```

### Step 2: Add Each Server

```bash
# 1. Filesystem server
bash scripts/add-mcp-server.sh \
  --name filesystem \
  --type stdio \
  --command npx \
  --args "@modelcontextprotocol/server-filesystem /home/user/projects"

# 2. Database server
bash scripts/add-mcp-server.sh \
  --name database \
  --type stdio \
  --command python3 \
  --args "-m db_mcp_server" \
  --env-var DATABASE_URL='${DATABASE_URL}'

# 3. External API
bash scripts/add-mcp-server.sh \
  --name external-api \
  --type http \
  --url "https://api.external.com" \
  --env-var API_KEY='${EXTERNAL_API_KEY}'

# 4. Slack integration
bash scripts/add-mcp-server.sh \
  --name slack \
  --type stdio \
  --command python3 \
  --args "-m slack_mcp_server" \
  --env-var SLACK_BOT_TOKEN='${SLACK_BOT_TOKEN}' \
  --env-var SLACK_SIGNING_SECRET='${SLACK_SIGNING_SECRET}'
```

### Step 3: Validate Configuration

```bash
bash scripts/validate-mcp-config.sh .mcp.json
```

### Result: .mcp.json

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
    },
    "database": {
      "type": "stdio",
      "command": "python3",
      "args": ["-m", "db_mcp_server"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    },
    "external-api": {
      "type": "http",
      "url": "https://api.external.com",
      "headers": {
        "Authorization": "Bearer ${EXTERNAL_API_KEY}"
      },
      "env": {
        "EXTERNAL_API_KEY": "${EXTERNAL_API_KEY}"
      }
    },
    "slack": {
      "type": "stdio",
      "command": "python3",
      "args": ["-m", "slack_mcp_server"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
        "SLACK_SIGNING_SECRET": "${SLACK_SIGNING_SECRET}"
      }
    }
  }
}
```

## Server Organization Strategies

### By Function

Group servers by their purpose:

```json
{
  "mcpServers": {
    "local-filesystem": { ... },
    "local-database": { ... },
    "cloud-storage-s3": { ... },
    "cloud-database-postgres": { ... },
    "api-openai": { ... },
    "api-anthropic": { ... },
    "integration-slack": { ... },
    "integration-github": { ... }
  }
}
```

### By Environment

Separate development vs production:

**Development (.mcp.dev.json):**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "./dev-files"]
    },
    "database": {
      "env": {
        "DATABASE_URL": "${DEV_DATABASE_URL}"
      }
    }
  }
}
```

**Production (.mcp.prod.json):**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "/var/app/files"]
    },
    "database": {
      "env": {
        "DATABASE_URL": "${PROD_DATABASE_URL}"
      }
    }
  }
}
```

### By Team

Different configurations for different team members:

```bash
# Alice (frontend developer)
.mcp.alice.json - filesystem, frontend tools

# Bob (backend developer)
.mcp.bob.json - database, API servers

# Charlie (DevOps)
.mcp.charlie.json - all servers + deployment tools
```

## Server Priority and Loading Order

Servers are loaded in the order they appear in `.mcp.json`:

```json
{
  "mcpServers": {
    "critical-server": { ... },      // Loads first
    "important-server": { ... },      // Loads second
    "optional-server": { ... }        // Loads last
  }
}
```

To ensure critical servers load first:

1. Place them at the top of the `mcpServers` object
2. Test loading order after configuration changes

## Performance Considerations

### Server Startup Time

Each server adds startup overhead:

- **stdio servers**: ~100-500ms per server
- **HTTP servers**: Depends on network latency

### Optimization Tips

1. **Only include needed servers:**
   ```bash
   # Remove unused server
   # Edit .mcp.json and delete server entry
   bash scripts/validate-mcp-config.sh .mcp.json
   ```

2. **Use working directories:**
   ```json
   {
     "server-name": {
       "workingDirectory": "/path/to/fast/disk"
     }
   }
   ```

3. **Lazy loading pattern:**
   - Start with essential servers
   - Add specialized servers when needed

## Debugging Multiple Servers

### Check Which Servers Are Running

In Claude Code logs, look for:

```
[MCP] Loading server: filesystem
[MCP] Server started: filesystem
[MCP] Loading server: database
[MCP] Server started: database
```

### Test Each Server Individually

Temporarily disable all but one server:

```json
{
  "mcpServers": {
    "filesystem": { ... }
    // "database": { ... },  // Commented out
    // "api": { ... }        // Commented out
  }
}
```

Restart Claude Code and test the one server.

### Validate All Servers

```bash
bash scripts/validate-mcp-config.sh .mcp.json
```

Look for server-specific errors in the validation output.

## Common Multi-Server Patterns

### Pattern 1: Local + Remote

```json
{
  "mcpServers": {
    "local-files": {
      "type": "stdio",
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "./"]
    },
    "remote-api": {
      "type": "http",
      "url": "https://api.example.com"
    }
  }
}
```

### Pattern 2: Multiple Languages

```json
{
  "mcpServers": {
    "python-tools": {
      "type": "stdio",
      "command": "python3",
      "args": ["-m", "python_mcp_server"]
    },
    "node-tools": {
      "type": "stdio",
      "command": "node",
      "args": ["dist/node-server.js"]
    },
    "go-tools": {
      "type": "stdio",
      "command": "./bin/go-mcp-server"
    }
  }
}
```

### Pattern 3: Microservices Architecture

```json
{
  "mcpServers": {
    "auth-service": {
      "type": "http",
      "url": "http://localhost:3001"
    },
    "data-service": {
      "type": "http",
      "url": "http://localhost:3002"
    },
    "notification-service": {
      "type": "http",
      "url": "http://localhost:3003"
    }
  }
}
```

## Managing Server Lifecycle

### Adding a Server at Runtime

1. Edit `.mcp.json`
2. Add new server configuration
3. Validate: `bash scripts/validate-mcp-config.sh .mcp.json`
4. Restart Claude Code

### Removing a Server

1. Edit `.mcp.json`
2. Delete server entry
3. Remove associated API keys (if no longer needed):
   ```bash
   bash scripts/manage-api-keys.sh --action remove --key-name OLD_KEY
   ```
4. Restart Claude Code

### Updating a Server

1. Locate server in `.mcp.json`
2. Modify configuration (command, args, env, etc.)
3. Validate changes
4. Restart Claude Code

## Troubleshooting Multiple Servers

### One Server Prevents Others from Loading

If a server fails to start, subsequent servers might not load:

1. Check logs for the failing server
2. Fix or temporarily disable it
3. Restart Claude Code

### Conflicting Server Names

Server names must be unique:

```json
{
  "mcpServers": {
    "api": { ... },          // ✅ OK
    "api": { ... }           // ❌ Duplicate - second one ignored
  }
}
```

Use descriptive, unique names:

```json
{
  "mcpServers": {
    "api-openai": { ... },   // ✅ OK
    "api-anthropic": { ... } // ✅ OK
  }
}
```

### Server Not Responding

Test servers individually:

```bash
# For stdio servers
python3 -m server_module

# For HTTP servers
curl https://api.example.com/health
```

## Next Steps

- [Troubleshooting](./troubleshooting.md) - Debug server issues
- [Production Config](./production-config.md) - Production deployments
- [API Key Management](./api-key-management.md) - Secure API keys

## Related Scripts

- `add-mcp-server.sh` - Add servers
- `validate-mcp-config.sh` - Validate configuration
- `manage-api-keys.sh` - Manage API keys

# MCP Configuration Troubleshooting Guide

This guide covers common issues when configuring MCP servers and their solutions.

## Quick Diagnostic Checklist

Before diving into specific issues, run these checks:

```bash
# 1. Validate configuration
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/validate-mcp-config.sh .mcp.json

# 2. Validate API keys
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh --action validate

# 3. Check file permissions
ls -la .mcp.json .env

# 4. Verify commands exist
which python3
which node
which npx
```

## Common Issues and Solutions

### Issue 1: Configuration File Not Found

**Symptoms:**
```
Error: Configuration file not found: .mcp.json
```

**Solution:**

```bash
# Initialize configuration
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/init-mcp-config.sh

# Or specify custom path
bash scripts/init-mcp-config.sh /path/to/.mcp.json
```

**Prevention:**
- Keep `.mcp.json` in project root or `~/.claude/` directory
- Use absolute paths when specifying config location

---

### Issue 2: Invalid JSON Syntax

**Symptoms:**
```
[ERROR] Invalid JSON syntax
```

**Common Causes:**
1. Missing comma between objects
2. Trailing comma after last item
3. Unescaped quotes in strings
4. Comments (JSON doesn't support comments)

**Solution:**

```bash
# Use validation to find the error
bash scripts/validate-mcp-config.sh .mcp.json

# Or use jq to pretty-print and find errors
jq . .mcp.json
```

**Example Fixes:**

❌ **Wrong:**
```json
{
  "mcpServers": {
    "server1": { "type": "stdio" }
    "server2": { "type": "http" }  // Missing comma
  }
}
```

✅ **Correct:**
```json
{
  "mcpServers": {
    "server1": { "type": "stdio" },
    "server2": { "type": "http" }
  }
}
```

---

### Issue 3: Command Not Found

**Symptoms:**
```
[WARN] Command not found in PATH: python
```

**Diagnosis:**

```bash
# Check if command exists
which python3
which python
which node

# Check PATH
echo $PATH
```

**Solutions:**

1. **Use absolute path:**
   ```json
   {
     "server": {
       "command": "/usr/bin/python3"
     }
   }
   ```

2. **Install missing command:**
   ```bash
   # Python
   apt-get install python3

   # Node.js
   apt-get install nodejs npm
   ```

3. **Add to PATH:**
   ```bash
   export PATH="/usr/local/bin:$PATH"
   ```

---

### Issue 4: Server Type Invalid

**Symptoms:**
```
[ERROR] Invalid type: stdi (must be stdio, http, or sse)
```

**Valid Types:**
- `stdio` - Local process communication
- `http` - Remote HTTP servers
- `sse` - Server-sent events

**Solution:**

Check for typos:

❌ Wrong: `"type": "stdi"`
✅ Correct: `"type": "stdio"`

---

### Issue 5: Missing Required Fields

**Symptoms:**
```
[ERROR] Missing required field for stdio: command
[ERROR] Missing required field for http: url
```

**Solution:**

Ensure all required fields are present:

**For stdio servers:**
```json
{
  "server-name": {
    "type": "stdio",
    "command": "python3",    // Required
    "args": ["-m", "server"]  // Optional but recommended
  }
}
```

**For HTTP servers:**
```json
{
  "server-name": {
    "type": "http",
    "url": "https://api.example.com"  // Required
  }
}
```

---

### Issue 6: Environment Variable Not Found

**Symptoms:**
```
Error loading server: Environment variable API_KEY not found
```

**Diagnosis:**

```bash
# Check if variable is in .env
cat .env | grep API_KEY

# List all configured keys
bash scripts/manage-api-keys.sh --action list
```

**Solutions:**

1. **Add missing variable:**
   ```bash
   bash scripts/manage-api-keys.sh --action add --key-name API_KEY
   ```

2. **Check variable name matches:**
   - In `.env`: `API_KEY=sk-xxxxx`
   - In `.mcp.json`: `"${API_KEY}"`
   - Names must match exactly (case-sensitive)

3. **Verify .env location:**
   - Should be in same directory as `.mcp.json` or parent directory
   - Check file permissions: `chmod 600 .env`

---

### Issue 7: API Key Not Loading

**Symptoms:**
- Server starts but authentication fails
- "Unauthorized" or "Invalid API Key" errors

**Diagnosis:**

```bash
# Validate .env file
bash scripts/manage-api-keys.sh --action validate

# Check variable substitution
cat .mcp.json | grep '\${'
```

**Common Mistakes:**

❌ **Wrong:**
```json
{
  "env": {
    "API_KEY": "$API_KEY"  // Missing curly braces
  }
}
```

✅ **Correct:**
```json
{
  "env": {
    "API_KEY": "${API_KEY}"  // Correct syntax
  }
}
```

**Solution:**

Ensure proper syntax:
1. In `.env`: `API_KEY=value` (no spaces around `=`)
2. In `.mcp.json`: `"${API_KEY}"` (with `${}`)
3. Restart Claude Code after changes

---

### Issue 8: Server Won't Start

**Symptoms:**
- Server listed in config but not working
- No error messages in logs

**Diagnosis Steps:**

1. **Test command manually:**
   ```bash
   # For Python servers
   python3 -m server_module

   # For Node servers
   node dist/index.js

   # For npx servers
   npx @modelcontextprotocol/server-filesystem /path
   ```

2. **Check command output:**
   - Does it start without errors?
   - Does it require additional setup?

3. **Verify paths:**
   ```bash
   # Check if file exists
   ls -la /path/to/server/script

   # Check if directory exists
   ls -la /path/to/working/directory
   ```

**Solutions:**

1. **Install dependencies:**
   ```bash
   # Python
   pip3 install -r requirements.txt

   # Node.js
   npm install
   ```

2. **Set working directory:**
   ```json
   {
     "server": {
       "workingDirectory": "/path/to/project"
     }
   }
   ```

3. **Check permissions:**
   ```bash
   chmod +x /path/to/server/script
   ```

---

### Issue 9: Multiple Servers Conflicting

**Symptoms:**
- Some servers don't load
- Duplicate server names

**Solution:**

Ensure unique server names:

❌ **Wrong:**
```json
{
  "mcpServers": {
    "api": { ... },
    "api": { ... }  // Duplicate name
  }
}
```

✅ **Correct:**
```json
{
  "mcpServers": {
    "api-openai": { ... },
    "api-anthropic": { ... }
  }
}
```

---

### Issue 10: Configuration Changes Not Taking Effect

**Symptoms:**
- Modified `.mcp.json` but changes not reflected
- New servers not loading

**Solution:**

**Always restart Claude Code after configuration changes:**

1. Exit Claude Code completely
2. Restart Claude Code
3. Wait for all servers to load

**Verify changes took effect:**

Check Claude Code logs for:
```
[MCP] Loading server: new-server
[MCP] Server started: new-server
```

---

### Issue 11: Permission Denied

**Symptoms:**
```
Error: EACCES: permission denied, open '.mcp.json'
Error: EACCES: permission denied, open '.env'
```

**Solution:**

```bash
# Fix .mcp.json permissions
chmod 644 .mcp.json

# Fix .env permissions (more restrictive)
chmod 600 .env

# Fix script permissions
chmod +x scripts/*.sh
```

---

### Issue 12: Server Timeout

**Symptoms:**
- Server takes too long to start
- Timeout errors in logs

**Solutions:**

1. **Increase timeout (if supported by Claude Code):**
   - Check Claude Code documentation for timeout settings

2. **Optimize server startup:**
   ```json
   {
     "server": {
       "workingDirectory": "/fast/disk/path",
       "env": {
         "PYTHON_OPTIMIZE": "1"
       }
     }
   }
   ```

3. **Reduce server complexity:**
   - Lazy load heavy dependencies
   - Cache initialization data

---

### Issue 13: jq Not Installed

**Symptoms:**
```
[WARN] jq not found, using manual JSON manipulation
```

**Solution:**

Install jq for better JSON handling:

```bash
# Ubuntu/Debian
apt-get install jq

# macOS
brew install jq

# Verify installation
which jq
jq --version
```

---

### Issue 14: .gitignore Issues

**Symptoms:**
- `.env` file committed to git
- API keys exposed in repository

**Solution:**

```bash
# Add .env to .gitignore
echo ".env" >> .gitignore

# Remove from git history (if already committed)
git rm --cached .env
git commit -m "Remove .env from repository"

# Rotate compromised keys immediately
bash scripts/manage-api-keys.sh --action add --key-name API_KEY --force
```

---

## Diagnostic Tools

### Validate Everything

Run all validations:

```bash
# Configuration structure
bash scripts/validate-mcp-config.sh .mcp.json

# API keys
bash scripts/manage-api-keys.sh --action validate

# List servers
cat .mcp.json | jq '.mcpServers | keys'

# List API keys
bash scripts/manage-api-keys.sh --action list
```

### Check Dependencies

```bash
# Required tools
which python3 || echo "Python not found"
which node || echo "Node.js not found"
which npx || echo "npx not found"
which jq || echo "jq not found"

# Python packages
pip3 list | grep fastmcp
pip3 list | grep mcp

# npm packages
npm list -g --depth=0 | grep mcp
```

### Test Individual Servers

Create a minimal test configuration:

```json
{
  "mcpServers": {
    "test-server": {
      "type": "stdio",
      "command": "python3",
      "args": ["-c", "print('Server OK')"]
    }
  }
}
```

Save as `.mcp.test.json` and test.

---

## Getting Help

### What to Include in Bug Reports

When asking for help, provide:

1. **Configuration validation output:**
   ```bash
   bash scripts/validate-mcp-config.sh .mcp.json > validation-output.txt
   ```

2. **Sanitized configuration:**
   ```bash
   # Remove sensitive data
   jq '.mcpServers[] | .env = "REDACTED"' .mcp.json
   ```

3. **Environment information:**
   ```bash
   echo "OS: $(uname -a)"
   echo "Python: $(python3 --version)"
   echo "Node: $(node --version)"
   echo "npm: $(npm --version)"
   ```

4. **Error messages:**
   - Copy full error messages from Claude Code logs
   - Include stack traces if available

### Useful Commands

```bash
# Full diagnostic
bash scripts/validate-mcp-config.sh .mcp.json
bash scripts/manage-api-keys.sh --action validate
which python3 node npx jq
ls -la .mcp.json .env

# Test server commands
python3 -m server_module --help
node dist/index.js --help
```

---

## Prevention Tips

1. **Always validate before restarting:**
   ```bash
   bash scripts/validate-mcp-config.sh .mcp.json && \
   echo "Config OK - safe to restart Claude Code"
   ```

2. **Keep backups:**
   ```bash
   cp .mcp.json .mcp.json.backup
   cp .env .env.backup
   ```

3. **Use version control:**
   ```bash
   git add .mcp.json
   git commit -m "Update MCP configuration"
   # Note: .env should NOT be in git
   ```

4. **Document your setup:**
   - Keep notes on why each server is configured
   - Document any custom settings

---

## Next Steps

- [Basic Setup](./basic-setup.md) - Start from scratch
- [API Key Management](./api-key-management.md) - Secure API keys
- [Multiple Servers](./multiple-servers.md) - Manage multiple servers
- [Production Config](./production-config.md) - Production deployments

## Related Scripts

- `validate-mcp-config.sh` - Validate configuration
- `manage-api-keys.sh` - Manage API keys
- `add-mcp-server.sh` - Add servers
- `init-mcp-config.sh` - Initialize configuration

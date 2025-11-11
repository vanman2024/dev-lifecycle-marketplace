# API Key Management for MCP Servers

This guide covers secure API key handling for MCP servers that require authentication.

## Why API Key Management Matters

- **Security**: Keep secrets out of version control
- **Portability**: Easy configuration across environments
- **Best Practice**: Separate configuration from credentials

## The .env File Approach

MCP supports environment variable substitution using `.env` files:

1. Store API keys in `.env` (never committed)
2. Reference keys in `.mcp.json` using `${VAR_NAME}` syntax
3. Claude Code loads variables at runtime

## Step 1: Add API Key to .env

### Interactive Method (Recommended)

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh \
  --action add \
  --key-name OPENAI_API_KEY
```

You'll be prompted to enter the key value (input is hidden):

```
Enter value for OPENAI_API_KEY (input hidden): [type key here]
[INFO] ✓ API key added: OPENAI_API_KEY
```

### Non-Interactive Method

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh \
  --action add \
  --key-name OPENAI_API_KEY \
  --key-value "sk-xxxxxxxxxxxxxxxxxxxxx"
```

### What This Does

1. Creates/updates `.env` file with secure permissions (600)
2. Adds the key: `OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx`
3. Ensures `.env` is in `.gitignore`

## Step 2: Reference API Key in .mcp.json

### Method 1: During Server Addition

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/add-mcp-server.sh \
  --name openai-server \
  --type http \
  --url "https://api.openai.com" \
  --env-var API_KEY='${OPENAI_API_KEY}'
```

### Method 2: Manual Configuration

Edit `.mcp.json`:

```json
{
  "mcpServers": {
    "openai-server": {
      "type": "http",
      "url": "https://api.openai.com",
      "headers": {
        "Authorization": "Bearer ${OPENAI_API_KEY}"
      },
      "env": {
        "OPENAI_API_KEY": "${OPENAI_API_KEY}"
      }
    }
  }
}
```

## Step 3: Verify Setup

### List All API Keys

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh \
  --action list
```

Output:

```
[INFO] API keys in .env:

  OPENAI_API_KEY = sk-x***
  ANTHROPIC_API_KEY = sk-a***
  SLACK_BOT_TOKEN = xoxb***
```

### Validate .env File

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh \
  --action validate
```

Checks:

- ✅ Valid format for each line
- ✅ Secure file permissions (600)
- ✅ .env is in .gitignore
- ✅ No syntax errors

## Common API Key Patterns

### OpenAI API

```bash
# Add key
bash scripts/manage-api-keys.sh --action add --key-name OPENAI_API_KEY

# Configure server
bash scripts/add-mcp-server.sh \
  --name openai \
  --type http \
  --url "https://api.openai.com/v1" \
  --env-var OPENAI_API_KEY='${OPENAI_API_KEY}'
```

### Anthropic API

```bash
# Add key
bash scripts/manage-api-keys.sh --action add --key-name ANTHROPIC_API_KEY

# Configure in .mcp.json
{
  "anthropic-server": {
    "type": "http",
    "url": "https://api.anthropic.com/v1",
    "headers": {
      "x-api-key": "${ANTHROPIC_API_KEY}",
      "anthropic-version": "2023-06-01"
    }
  }
}
```

### Database Connection String

```bash
# Add connection string
bash scripts/manage-api-keys.sh \
  --action add \
  --key-name DATABASE_URL \
  --key-value "postgresql://user:pass@localhost:5432/db"

# Use in server
{
  "database": {
    "type": "stdio",
    "command": "python3",
    "args": ["-m", "db_mcp_server"],
    "env": {
      "DATABASE_URL": "${DATABASE_URL}"
    }
  }
}
```

### Multiple Keys for One Server

```bash
# Add multiple keys
bash scripts/manage-api-keys.sh --action add --key-name AWS_ACCESS_KEY_ID
bash scripts/manage-api-keys.sh --action add --key-name AWS_SECRET_ACCESS_KEY
bash scripts/manage-api-keys.sh --action add --key-name AWS_REGION

# Configure server with all keys
{
  "aws-server": {
    "type": "stdio",
    "command": "python3",
    "args": ["-m", "aws_mcp_server"],
    "env": {
      "AWS_ACCESS_KEY_ID": "${AWS_ACCESS_KEY_ID}",
      "AWS_SECRET_ACCESS_KEY": "${AWS_SECRET_ACCESS_KEY}",
      "AWS_REGION": "${AWS_REGION}"
    }
  }
}
```

## Removing API Keys

When you no longer need a key:

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh \
  --action remove \
  --key-name OLD_API_KEY
```

Or force removal without confirmation:

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh \
  --action remove \
  --key-name OLD_API_KEY \
  --force
```

## .env File Structure

Your `.env` file should look like:

```bash
# OpenAI Configuration
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
OPENAI_ORG_ID=org-xxxxxxxxxxxxxxxxxxxxx

# Anthropic Configuration
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxx

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb

# Slack
SLACK_BOT_TOKEN=xoxb-xxxxxxxxxxxxxxxxxxxxx
SLACK_SIGNING_SECRET=xxxxxxxxxxxxxxxxxxxxx

# AWS
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxx
AWS_REGION=us-east-1
```

## Security Best Practices

### 1. Never Commit .env Files

Ensure `.env` is in `.gitignore`:

```bash
echo ".env" >> .gitignore
```

The `manage-api-keys.sh` script does this automatically.

### 2. Use Secure File Permissions

```bash
chmod 600 .env
```

Only the file owner can read/write.

### 3. Rotate Keys Regularly

Update keys periodically:

```bash
bash scripts/manage-api-keys.sh --action add --key-name API_KEY --force
```

The `--force` flag overwrites existing keys.

### 4. Use Different Keys per Environment

Development:
```bash
# .env.development
OPENAI_API_KEY=sk-dev-xxxxx
```

Production:
```bash
# .env.production
OPENAI_API_KEY=sk-prod-xxxxx
```

### 5. Audit Your Keys

```bash
# List all configured keys
bash scripts/manage-api-keys.sh --action list

# Validate configuration
bash scripts/manage-api-keys.sh --action validate
```

## Production Considerations

### Environment Variables

In production, use system environment variables instead of .env:

```bash
export OPENAI_API_KEY=sk-xxxxx
export ANTHROPIC_API_KEY=sk-ant-xxxxx
```

### Secrets Management

For enterprise deployments, consider:

- **AWS Secrets Manager**: Store secrets in AWS
- **HashiCorp Vault**: Centralized secrets management
- **Azure Key Vault**: Azure secrets storage
- **Kubernetes Secrets**: For K8s deployments

### CI/CD Integration

In CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Configure MCP
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
  run: |
    bash scripts/add-mcp-server.sh ...
```

## Troubleshooting

### Key Not Found Error

If Claude Code can't find your API key:

1. **Verify .env location:**
   ```bash
   ls -la .env
   ```

2. **Check variable name matches:**
   - In `.env`: `OPENAI_API_KEY=...`
   - In `.mcp.json`: `"${OPENAI_API_KEY}"`

3. **Validate .env format:**
   ```bash
   bash scripts/manage-api-keys.sh --action validate
   ```

### Permission Denied

```bash
chmod 600 .env
```

### Keys Not Loading

Restart Claude Code after modifying `.env` or `.mcp.json`.

## Next Steps

- [Multiple Servers](./multiple-servers.md) - Manage multiple servers with different keys
- [Production Config](./production-config.md) - Production-ready configurations
- [Troubleshooting](./troubleshooting.md) - Common issues and solutions

## Related Scripts

- `manage-api-keys.sh` - Add, list, remove, validate keys
- `add-mcp-server.sh` - Add servers with environment variables
- `validate-mcp-config.sh` - Validate entire configuration

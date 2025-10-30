# Production MCP Configuration Guide

This guide covers best practices for deploying MCP configurations in production environments.

## Production vs Development

Key differences between development and production configurations:

| Aspect | Development | Production |
|--------|-------------|------------|
| API Keys | `.env` file | Environment variables |
| Logging | Debug level | Info/Error only |
| Error Handling | Verbose | User-friendly |
| Monitoring | Optional | Required |
| Security | Relaxed | Strict |
| Performance | Not critical | Optimized |

## Production Checklist

Before deploying to production:

- [ ] All API keys secured in environment variables
- [ ] `.env` files excluded from deployment
- [ ] Configuration validated
- [ ] Error handling implemented
- [ ] Logging configured
- [ ] Monitoring enabled
- [ ] Backup strategy in place
- [ ] Rollback plan documented

## Environment-Based Configuration

### Directory Structure

```
project/
├── .mcp.json              # Symlink to active config
├── .mcp.development.json  # Development config
├── .mcp.staging.json      # Staging config
├── .mcp.production.json   # Production config
├── .env.development       # Dev API keys (gitignored)
├── .env.staging          # Staging API keys (gitignored)
└── scripts/
    └── switch-env.sh      # Switch between environments
```

### Development Configuration

`.mcp.development.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "@modelcontextprotocol/server-filesystem",
        "./dev-files"
      ],
      "env": {
        "LOG_LEVEL": "debug"
      }
    },
    "database": {
      "type": "stdio",
      "command": "python3",
      "args": ["-m", "db_mcp_server"],
      "env": {
        "DATABASE_URL": "${DEV_DATABASE_URL}",
        "LOG_LEVEL": "debug",
        "ENABLE_QUERY_LOGGING": "true"
      }
    },
    "api": {
      "type": "http",
      "url": "http://localhost:3000",
      "env": {
        "API_KEY": "${DEV_API_KEY}"
      }
    }
  }
}
```

### Production Configuration

`.mcp.production.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "/usr/bin/npx",
      "args": [
        "@modelcontextprotocol/server-filesystem",
        "/var/app/files"
      ],
      "env": {
        "LOG_LEVEL": "error",
        "NODE_ENV": "production"
      },
      "workingDirectory": "/var/app"
    },
    "database": {
      "type": "stdio",
      "command": "/usr/bin/python3",
      "args": ["-m", "db_mcp_server"],
      "env": {
        "DATABASE_URL": "${PROD_DATABASE_URL}",
        "LOG_LEVEL": "info",
        "ENABLE_QUERY_LOGGING": "false",
        "CONNECTION_POOL_SIZE": "20",
        "CONNECTION_TIMEOUT": "30000"
      },
      "workingDirectory": "/var/app"
    },
    "api": {
      "type": "http",
      "url": "https://api.production.com",
      "headers": {
        "User-Agent": "ClaudeCode/1.0"
      },
      "env": {
        "API_KEY": "${PROD_API_KEY}",
        "TIMEOUT": "10000",
        "RETRY_ATTEMPTS": "3"
      }
    }
  }
}
```

### Staging Configuration

`.mcp.staging.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "/usr/bin/npx",
      "args": [
        "@modelcontextprotocol/server-filesystem",
        "/var/staging/files"
      ],
      "env": {
        "LOG_LEVEL": "info"
      }
    },
    "database": {
      "type": "stdio",
      "command": "/usr/bin/python3",
      "args": ["-m", "db_mcp_server"],
      "env": {
        "DATABASE_URL": "${STAGING_DATABASE_URL}",
        "LOG_LEVEL": "info",
        "ENABLE_QUERY_LOGGING": "true"
      }
    },
    "api": {
      "type": "http",
      "url": "https://api.staging.com",
      "env": {
        "API_KEY": "${STAGING_API_KEY}"
      }
    }
  }
}
```

## Environment Variable Management

### Local Development (.env)

```bash
# .env.development
DEV_DATABASE_URL=postgresql://localhost:5432/dev_db
DEV_API_KEY=dev-key-12345
LOG_LEVEL=debug
```

### Production (System Environment)

**Don't use .env files in production!** Use system environment variables:

#### Docker

```dockerfile
# Dockerfile
FROM node:18

# Set environment variables
ENV PROD_DATABASE_URL=postgresql://prod-server:5432/prod_db
ENV LOG_LEVEL=error

# Or use docker-compose
```

```yaml
# docker-compose.yml
services:
  claude-code:
    environment:
      - PROD_DATABASE_URL=${PROD_DATABASE_URL}
      - PROD_API_KEY=${PROD_API_KEY}
```

#### Kubernetes

```yaml
# deployment.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mcp-secrets
type: Opaque
data:
  api-key: <base64-encoded-key>
  database-url: <base64-encoded-url>

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: claude-code
spec:
  template:
    spec:
      containers:
      - name: claude-code
        env:
        - name: PROD_API_KEY
          valueFrom:
            secretKeyRef:
              name: mcp-secrets
              key: api-key
        - name: PROD_DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: mcp-secrets
              key: database-url
```

#### Systemd Service

```ini
# /etc/systemd/system/claude-code.service
[Service]
Environment="PROD_DATABASE_URL=postgresql://prod:5432/db"
Environment="PROD_API_KEY=prod-key-xxxxx"
Environment="LOG_LEVEL=info"
```

#### AWS (Environment Variables)

Use AWS Systems Manager Parameter Store or Secrets Manager:

```bash
# Store secret
aws secretsmanager create-secret \
  --name /mcp/prod/api-key \
  --secret-string "prod-key-xxxxx"

# Retrieve in application
export PROD_API_KEY=$(aws secretsmanager get-secret-value \
  --secret-id /mcp/prod/api-key \
  --query SecretString \
  --output text)
```

## Security Best Practices

### 1. API Key Rotation

Implement regular key rotation:

```bash
#!/bin/bash
# rotate-keys.sh

# 1. Generate new API key from provider
NEW_KEY="new-api-key-xxxxx"

# 2. Update environment variable
export PROD_API_KEY="$NEW_KEY"

# 3. Update secrets manager
aws secretsmanager update-secret \
  --secret-id /mcp/prod/api-key \
  --secret-string "$NEW_KEY"

# 4. Restart service
systemctl restart claude-code

# 5. Verify new key works

# 6. Revoke old key at provider
```

### 2. Least Privilege Access

Restrict file system access:

```json
{
  "filesystem": {
    "type": "stdio",
    "command": "npx",
    "args": [
      "@modelcontextprotocol/server-filesystem",
      "/var/app/files"  // Limited to specific directory
    ]
  }
}
```

### 3. Network Security

For HTTP servers, use HTTPS and authentication:

```json
{
  "api": {
    "type": "http",
    "url": "https://api.production.com",  // HTTPS only
    "headers": {
      "Authorization": "Bearer ${PROD_API_KEY}",
      "X-Client-Id": "claude-code-prod"
    }
  }
}
```

### 4. Audit Logging

Enable comprehensive logging:

```json
{
  "database": {
    "env": {
      "LOG_LEVEL": "info",
      "AUDIT_LOG_PATH": "/var/log/mcp/audit.log",
      "LOG_FORMAT": "json"
    }
  }
}
```

## Monitoring and Observability

### Health Checks

Implement health check endpoints:

```python
# Python MCP server
from fastmcp import FastMCP

mcp = FastMCP()

@mcp.tool()
def health_check() -> dict:
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    }
```

### Metrics Collection

Track server metrics:

```json
{
  "database": {
    "env": {
      "ENABLE_METRICS": "true",
      "METRICS_PORT": "9090",
      "METRICS_PATH": "/metrics"
    }
  }
}
```

### Log Aggregation

Send logs to centralized service:

```json
{
  "api": {
    "env": {
      "LOG_DESTINATION": "syslog://logs.company.com:514",
      "LOG_FORMAT": "json"
    }
  }
}
```

## Performance Optimization

### 1. Connection Pooling

```json
{
  "database": {
    "env": {
      "CONNECTION_POOL_SIZE": "20",
      "CONNECTION_POOL_TIMEOUT": "30000",
      "CONNECTION_IDLE_TIMEOUT": "600000"
    }
  }
}
```

### 2. Caching

```json
{
  "api": {
    "env": {
      "ENABLE_CACHE": "true",
      "CACHE_TTL": "3600",
      "CACHE_SIZE": "100MB"
    }
  }
}
```

### 3. Working Directory on Fast Disk

```json
{
  "filesystem": {
    "workingDirectory": "/mnt/fast-ssd/app"
  }
}
```

## Deployment Strategies

### Blue-Green Deployment

Maintain two production environments:

```bash
# Deploy to green (inactive)
./deploy.sh green

# Test green environment
./test.sh green

# Switch traffic to green
ln -sf .mcp.production.green.json .mcp.json
systemctl restart claude-code

# If issues, rollback to blue
ln -sf .mcp.production.blue.json .mcp.json
systemctl restart claude-code
```

### Canary Deployment

Gradually roll out changes:

```bash
# Deploy to 10% of instances
./deploy.sh --canary 10

# Monitor metrics
./monitor.sh --canary

# Increase to 50%
./deploy.sh --canary 50

# Full rollout
./deploy.sh --full
```

## Disaster Recovery

### Backup Strategy

```bash
#!/bin/bash
# backup-mcp-config.sh

BACKUP_DIR="/backups/mcp"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup configuration
cp .mcp.production.json "$BACKUP_DIR/.mcp.$TIMESTAMP.json"

# Backup environment variables (encrypted)
env | grep -E "PROD_|API_|DATABASE_" | \
  gpg --encrypt > "$BACKUP_DIR/env.$TIMESTAMP.gpg"

# Keep last 30 days of backups
find "$BACKUP_DIR" -mtime +30 -delete
```

### Rollback Procedure

```bash
#!/bin/bash
# rollback-mcp-config.sh

BACKUP_FILE="$1"

# Validate backup
bash scripts/validate-mcp-config.sh "$BACKUP_FILE"

# If valid, restore
if [ $? -eq 0 ]; then
    cp "$BACKUP_FILE" .mcp.json
    systemctl restart claude-code
    echo "Rollback complete"
else
    echo "Backup file invalid, rollback aborted"
    exit 1
fi
```

## Validation Before Deployment

Always validate before deploying:

```bash
#!/bin/bash
# pre-deploy-validation.sh

echo "=== Pre-deployment Validation ==="

# 1. Validate configuration
echo "Validating .mcp.production.json..."
bash scripts/validate-mcp-config.sh .mcp.production.json
if [ $? -ne 0 ]; then
    echo "Configuration validation failed"
    exit 1
fi

# 2. Check required environment variables
echo "Checking environment variables..."
REQUIRED_VARS=(
    "PROD_DATABASE_URL"
    "PROD_API_KEY"
)

for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo "Missing required variable: $VAR"
        exit 1
    fi
done

# 3. Test database connection
echo "Testing database connection..."
python3 -c "import psycopg2; psycopg2.connect('${PROD_DATABASE_URL}')"

# 4. Test API endpoint
echo "Testing API endpoint..."
curl -f "https://api.production.com/health" || exit 1

echo "=== All validations passed ==="
```

## Production Configuration Template

Here's a complete production-ready template:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "/usr/bin/npx",
      "args": [
        "@modelcontextprotocol/server-filesystem",
        "/var/app/files"
      ],
      "env": {
        "NODE_ENV": "production",
        "LOG_LEVEL": "error",
        "ENABLE_METRICS": "true"
      },
      "workingDirectory": "/var/app"
    },
    "database": {
      "type": "stdio",
      "command": "/usr/bin/python3",
      "args": ["-m", "db_mcp_server"],
      "env": {
        "DATABASE_URL": "${PROD_DATABASE_URL}",
        "LOG_LEVEL": "info",
        "CONNECTION_POOL_SIZE": "20",
        "CONNECTION_TIMEOUT": "30000",
        "ENABLE_METRICS": "true",
        "METRICS_PORT": "9090"
      },
      "workingDirectory": "/var/app"
    },
    "cache": {
      "type": "stdio",
      "command": "/usr/bin/python3",
      "args": ["-m", "redis_mcp_server"],
      "env": {
        "REDIS_URL": "${PROD_REDIS_URL}",
        "REDIS_POOL_SIZE": "10",
        "LOG_LEVEL": "info"
      }
    },
    "api": {
      "type": "http",
      "url": "https://api.production.com",
      "headers": {
        "User-Agent": "ClaudeCode/1.0",
        "X-Environment": "production"
      },
      "env": {
        "API_KEY": "${PROD_API_KEY}",
        "TIMEOUT": "10000",
        "RETRY_ATTEMPTS": "3",
        "RETRY_BACKOFF": "exponential"
      }
    }
  }
}
```

## Next Steps

- [Basic Setup](./basic-setup.md) - Start from scratch
- [API Key Management](./api-key-management.md) - Secure API keys
- [Multiple Servers](./multiple-servers.md) - Manage multiple servers
- [Troubleshooting](./troubleshooting.md) - Common issues

## Related Scripts

- `validate-mcp-config.sh` - Validate configuration
- `manage-api-keys.sh` - Manage API keys
- `add-mcp-server.sh` - Add servers

# Multi-Environment Deployment Strategy

This example demonstrates managing deployments across multiple environments (development, staging, production).

## Environment Overview

| Environment | Branch | Platform | URL | Auto-Deploy |
|-------------|--------|----------|-----|-------------|
| Development | feature/* | Vercel Preview | preview-*.vercel.app | Yes |
| Staging | develop | Vercel | staging.my-app.com | Yes |
| Production | main | Vercel | my-app.com | Manual |

## Directory Structure

```
project/
├── .env.development
├── .env.staging
├── .env.production
├── .env.example
├── vercel.json
└── scripts/
    └── deploy-env.sh
```

## Environment Configuration Files

### .env.development

```bash
NODE_ENV=development
DATABASE_URL=postgresql://localhost:5432/myapp_dev
API_URL=http://localhost:8080
DEBUG=true
LOG_LEVEL=debug
```

### .env.staging

```bash
NODE_ENV=staging
DATABASE_URL=postgresql://staging-db.example.com:5432/myapp_staging
API_URL=https://api-staging.my-app.com
DEBUG=false
LOG_LEVEL=info
SENTRY_ENVIRONMENT=staging
```

### .env.production

```bash
NODE_ENV=production
DATABASE_URL=postgresql://prod-db.example.com:5432/myapp_prod
API_URL=https://api.my-app.com
DEBUG=false
LOG_LEVEL=warn
SENTRY_ENVIRONMENT=production
```

## Vercel Environment Configuration

Configure environment-specific settings in `vercel.json`:

```json
{
  "name": "my-app",
  "version": 2,
  "env": {
    "NODE_ENV": "production"
  },
  "build": {
    "env": {
      "NEXT_PUBLIC_ENV": "production"
    }
  }
}
```

## Deployment Scripts

### deploy-env.sh - Environment-Specific Deployment

```bash
#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-staging}"
SKILLS_DIR="plugins/deployment/skills/deployment-scripts/scripts"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Deploying to: $ENVIRONMENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Select environment file
ENV_FILE=".env.$ENVIRONMENT"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: Environment file not found: $ENV_FILE"
    exit 1
fi

# Load environment
set -a
source "$ENV_FILE"
set +a

# Step 1: Authentication
echo ""
echo "Step 1: Verifying authentication..."
bash "$SKILLS_DIR/check-auth.sh" vercel || exit 1

# Step 2: Validate environment
echo ""
echo "Step 2: Validating environment variables..."
bash "$SKILLS_DIR/validate-env.sh" "$ENV_FILE" || exit 1

# Step 3: Validate build
echo ""
echo "Step 3: Validating build..."
bash "$SKILLS_DIR/validate-build.sh" . || exit 1

# Step 4: Deploy based on environment
echo ""
echo "Step 4: Deploying to $ENVIRONMENT..."

case "$ENVIRONMENT" in
    production)
        # Production requires manual confirmation
        read -p "Deploy to PRODUCTION? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            echo "Deployment cancelled"
            exit 0
        fi
        bash "$SKILLS_DIR/vercel-deploy.sh" production
        DEPLOY_URL="https://my-app.com"
        ;;
    staging)
        bash "$SKILLS_DIR/vercel-deploy.sh" preview
        DEPLOY_URL="https://staging.my-app.com"
        ;;
    development)
        bash "$SKILLS_DIR/vercel-deploy.sh" development
        DEPLOY_URL="https://dev.my-app.com"
        ;;
    *)
        echo "Unknown environment: $ENVIRONMENT"
        exit 1
        ;;
esac

# Step 5: Health check
echo ""
echo "Step 5: Running health check..."
bash "$SKILLS_DIR/health-check.sh" "$DEPLOY_URL"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Deployment to $ENVIRONMENT complete!"
echo "URL: $DEPLOY_URL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

## Usage Examples

### Deploy to Staging

```bash
# Deploy to staging environment
bash scripts/deploy-env.sh staging
```

### Deploy to Production

```bash
# Deploy to production (requires confirmation)
bash scripts/deploy-env.sh production
```

### Deploy to Development

```bash
# Deploy to development
bash scripts/deploy-env.sh development
```

## Using the Universal Deployment Helper

The `deploy-helper.sh` script supports multi-environment deployments:

```bash
# Deploy to staging
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
  --platform vercel \
  --env staging

# Deploy to production
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
  --platform vercel \
  --env production

# Dry run (show what would be deployed)
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
  --platform vercel \
  --env production \
  --dry-run
```

## Environment-Specific Vercel Configuration

Use Vercel's environment-specific configuration:

```json
{
  "git": {
    "deploymentEnabled": {
      "main": true,
      "develop": true
    }
  },
  "github": {
    "autoAlias": true,
    "silent": false,
    "autoJobCancelation": true
  },
  "env": {
    "DATABASE_URL": {
      "production": "@database-url-prod",
      "preview": "@database-url-staging",
      "development": "@database-url-dev"
    }
  }
}
```

## Managing Secrets per Environment

### Add Secrets via Vercel CLI

```bash
# Production secrets
vercel secrets add database-url-prod "postgresql://prod-db..."
vercel secrets add api-key-prod "sk_live_..."

# Staging secrets
vercel secrets add database-url-staging "postgresql://staging-db..."
vercel secrets add api-key-staging "sk_test_..."

# Development secrets
vercel secrets add database-url-dev "postgresql://localhost:5432/dev"
vercel secrets add api-key-dev "sk_test_dev_..."
```

### Link Secrets to Environments

```bash
# Link production secret
vercel env add DATABASE_URL production
# Select @database-url-prod

# Link staging secret
vercel env add DATABASE_URL preview
# Select @database-url-staging

# Link development secret
vercel env add DATABASE_URL development
# Select @database-url-dev
```

## Automated Environment Deployment

### GitHub Actions Multi-Environment

```yaml
name: Multi-Environment Deploy

on:
  push:
    branches:
      - main        # Production
      - develop     # Staging
  pull_request:     # Preview

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Determine environment
        id: env
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "environment=production" >> $GITHUB_OUTPUT
            echo "url=https://my-app.com" >> $GITHUB_OUTPUT
          elif [[ "${{ github.ref }}" == "refs/heads/develop" ]]; then
            echo "environment=staging" >> $GITHUB_OUTPUT
            echo "url=https://staging.my-app.com" >> $GITHUB_OUTPUT
          else
            echo "environment=preview" >> $GITHUB_OUTPUT
            echo "url=preview" >> $GITHUB_OUTPUT
          fi

      - name: Deploy
        run: |
          bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
            --platform vercel \
            --env ${{ steps.env.outputs.environment }}
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}

      - name: Health check
        run: |
          bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh \
            ${{ steps.env.outputs.url }}
```

## Environment Promotion Workflow

Promote deployments from one environment to another:

```bash
#!/usr/bin/env bash
# promote.sh - Promote deployment from staging to production

set -euo pipefail

echo "Promoting staging to production..."

# 1. Verify staging is healthy
echo "Checking staging health..."
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh \
  https://staging.my-app.com || exit 1

# 2. Run production validation
echo "Validating production config..."
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh \
  .env.production || exit 1

# 3. Deploy to production
echo "Deploying to production..."
bash scripts/deploy-env.sh production

# 4. Verify production
echo "Verifying production deployment..."
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh \
  https://my-app.com || {
    echo "Production health check failed - consider rollback"
    exit 1
  }

echo "Promotion complete!"
```

## Best Practices

1. **Never commit `.env.*` files** - Use `.env.example` as template
2. **Use different databases per environment** - Prevent data corruption
3. **Test in staging before production** - Always validate in staging first
4. **Automate staging, manual production** - Require human approval for production
5. **Monitor each environment separately** - Use environment tags in monitoring tools
6. **Use feature flags** - Enable gradual rollouts across environments
7. **Document environment differences** - Keep a changelog of environment-specific configs

## Rollback Strategy

If a production deployment fails, rollback:

```bash
# Rollback production to previous deployment
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/rollback-deployment.sh vercel
```

## Next Steps

- Implement feature flags for gradual rollouts
- Set up environment-specific monitoring and alerts
- Create smoke test suites for each environment
- Document environment promotion procedures

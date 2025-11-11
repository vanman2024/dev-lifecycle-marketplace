# Basic Deployment Example

This example demonstrates a simple deployment workflow using the deployment-scripts skill.

## Scenario

Deploy a Node.js application to Vercel production environment.

## Prerequisites

- Vercel CLI installed: `npm i -g vercel`
- Vercel account created
- Project ready for deployment
- Environment variables configured

## Step-by-Step Workflow

### 1. Authentication Check

First, verify you're authenticated with Vercel:

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh vercel
```

**Expected Output:**
```
ℹ Checking Vercel authentication...
✓ Authenticated as: your-username
```

If not authenticated, run:
```bash
vercel login
```

### 2. Environment Validation

Validate your production environment variables:

```bash
# Create production env file
cp .env.example .env.production

# Edit with your actual values
nano .env.production

# Validate
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production
```

**Expected Output:**
```
ℹ Validating environment file: .env.production

ℹ Checking required variables...

✓ NODE_ENV is set
✓ DATABASE_URL is set
✓ DATABASE_URL has valid URL format
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ All validations passed
```

### 3. Build Validation

Run pre-deployment checks:

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .
```

**Expected Output:**
```
ℹ Running build validation for: /path/to/project
✓ Node.js project detected
✓ node_modules directory exists
✓ Lock file found
✓ Environment configuration OK
✓ Working directory clean
...
✓ Build validation passed with no errors or warnings
```

### 4. Deploy to Vercel

Deploy to production:

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/vercel-deploy.sh production
```

**Expected Output:**
```
ℹ Deploying to Vercel (production)
ℹ Loading environment from: .env.production
ℹ Production deployment
✓ Found vercel.json configuration
✓ Project already linked to Vercel

ℹ Starting deployment...
🔍  Inspect: https://vercel.com/...
✓ Deployment successful!
```

### 5. Health Check

Verify deployment is healthy:

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh https://my-app.vercel.app
```

**Expected Output:**
```
ℹ Running health checks for: https://my-app.vercel.app

Check 1: Basic connectivity
✓ HTTP 200 - Site is reachable
✓ HTTP status is OK (200)

Check 2: Response time
✓ Response time: 0.234s

Check 3: SSL certificate
✓ SSL certificate is valid
...
✓ All critical checks passed!
```

## Complete Script

You can combine all steps into a single deployment script:

```bash
#!/usr/bin/env bash

set -euo pipefail

SKILLS_DIR="plugins/deployment/skills/deployment-scripts/scripts"

# Check authentication
echo "Step 1: Checking authentication..."
bash "$SKILLS_DIR/check-auth.sh" vercel || exit 1

# Validate environment
echo "Step 2: Validating environment..."
bash "$SKILLS_DIR/validate-env.sh" .env.production || exit 1

# Validate build
echo "Step 3: Validating build..."
bash "$SKILLS_DIR/validate-build.sh" . || exit 1

# Deploy
echo "Step 4: Deploying..."
bash "$SKILLS_DIR/vercel-deploy.sh" production || exit 1

# Health check
echo "Step 5: Running health check..."
bash "$SKILLS_DIR/health-check.sh" https://my-app.vercel.app || exit 1

echo "Deployment complete!"
```

## Integration with Commands

In a deployment command (`/deploy`), use the scripts like this:

```markdown
# In commands/deploy.md

---
allowed-tools: Bash, Read
description: Deploy application to production
---

# Deploy Command

## Goal
Deploy the application to the specified platform with full validation.

## Actions

### Phase 1: Pre-deployment Validation
Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh vercel
Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production
Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .

### Phase 2: Deploy
Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/vercel-deploy.sh production

### Phase 3: Post-deployment
Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh https://my-app.vercel.app
```

## Troubleshooting

### Authentication Failed

```bash
✗ Not authenticated with Vercel
ℹ Run: vercel login
```

**Solution:** Run `vercel login` and follow the prompts.

### Environment Validation Failed

```bash
✗ DATABASE_URL is not set or empty
```

**Solution:** Check your `.env.production` file and ensure all required variables are set.

### Build Validation Warnings

```bash
⚠ node_modules not found - run npm install
```

**Solution:** Run `npm install` before deploying.

### Deployment Failed

```bash
✗ Deployment failed
```

**Solution:** Check the error output, verify your `vercel.json` configuration, and ensure all build steps pass locally.

## Next Steps

- Set up automated deployments with CI/CD (see [cicd-integration.md](./cicd-integration.md))
- Configure multiple environments (see [multi-environment.md](./multi-environment.md))
- Learn about rollback procedures (see [troubleshooting.md](./troubleshooting.md))

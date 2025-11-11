---
name: cicd-setup
description: Automated CI/CD pipeline setup using GitHub Actions with automatic secret configuration via GitHub CLI. Generates platform-specific workflows (Vercel, DigitalOcean, Railway) and configures repository secrets automatically. Use when setting up continuous deployment, configuring GitHub Actions, automating deployments, or when user mentions CI/CD, GitHub Actions, automated deployment, or pipeline setup.
allowed-tools: Bash, Read, Write, Edit
---

# CI/CD Auto-Setup Skill

This skill provides **fully automated** CI/CD pipeline setup for any deployment platform using GitHub Actions and the GitHub CLI (`gh`) to configure secrets automatically.

## Overview

**Core Philosophy**: CI/CD setup should be **one command** - no manual secret configuration, no copy-pasting tokens, no visiting GitHub web UI.

**Key Features**:
- Automatic GitHub Actions workflow generation
- Automatic secret configuration using `gh` CLI
- Platform-specific templates (Vercel, DigitalOcean, Railway, Netlify, Cloudflare)
- Project ID extraction and configuration
- Validation and testing workflows
- Zero manual steps required

## Supported Platforms

- **Vercel**: Next.js, React, Vue, static sites
- **DigitalOcean App Platform**: Containerized apps, databases
- **DigitalOcean Droplets**: Custom servers, APIs
- **Railway**: Full-stack applications, databases
- **Netlify**: Static sites, serverless functions
- **Cloudflare Pages**: Static sites, edge functions

## Available Scripts

### 1. Complete CI/CD Setup

**Script**: `scripts/setup-cicd.sh <platform> [project-path]`

**Purpose**: One-command CI/CD setup - detects project, extracts IDs, configures secrets, generates workflow

**Actions**:
- Detects platform type (Vercel, DigitalOcean, etc.)
- Extracts platform-specific project IDs automatically
- Configures GitHub repository secrets via `gh` CLI
- Generates platform-specific GitHub Actions workflow
- Creates `.github/workflows/deploy.yml`
- Validates workflow syntax
- Commits and pushes workflow file
- Provides test instructions

**Usage**:
```bash
# Auto-detect platform and set up CI/CD
./scripts/setup-cicd.sh auto

# Set up Vercel CI/CD
./scripts/setup-cicd.sh vercel

# Set up DigitalOcean App Platform CI/CD
./scripts/setup-cicd.sh digitalocean-app

# Set up DigitalOcean Droplet CI/CD
./scripts/setup-cicd.sh digitalocean-droplet

# Set up with custom path
./scripts/setup-cicd.sh vercel /path/to/project

# Dry run (show what would be configured)
DRY_RUN=true ./scripts/setup-cicd.sh vercel
```

**Required Environment Variables** (must be set before running):
- **Vercel**: `VERCEL_TOKEN`
- **DigitalOcean**: `DIGITALOCEAN_ACCESS_TOKEN`
- **Railway**: `RAILWAY_TOKEN`
- **Netlify**: `NETLIFY_AUTH_TOKEN`
- **Cloudflare**: `CLOUDFLARE_API_TOKEN`

**Exit Codes**:
- `0`: CI/CD setup successful
- `1`: Setup failed
- `2`: Missing prerequisites (gh CLI, platform CLI, tokens)

### 2. Configure GitHub Secrets

**Script**: `scripts/configure-github-secrets.sh <platform> <project-path>`

**Purpose**: Automatically configure GitHub repository secrets using `gh` CLI

**Actions**:
- Verifies `gh` CLI is authenticated
- Extracts platform-specific project IDs
- Sets repository secrets via `gh secret set`
- Validates secrets were configured correctly
- Lists configured secrets

**Usage**:
```bash
# Configure Vercel secrets
./scripts/configure-github-secrets.sh vercel .

# Configure DigitalOcean secrets
./scripts/configure-github-secrets.sh digitalocean /path/to/app

# List current secrets
gh secret list

# Verify secret was set
gh secret list | grep VERCEL_TOKEN
```

**Secrets Configured by Platform**:

**Vercel**:
- `VERCEL_TOKEN` - From environment variable
- `VERCEL_ORG_ID` - Extracted from `.vercel/project.json`
- `VERCEL_PROJECT_ID` - Extracted from `.vercel/project.json`

**DigitalOcean App Platform**:
- `DIGITALOCEAN_ACCESS_TOKEN` - From environment variable
- `DO_APP_ID` - Extracted from app spec or doctl
- `DO_APP_NAME` - From project configuration

**DigitalOcean Droplets**:
- `DIGITALOCEAN_ACCESS_TOKEN` - From environment variable
- `DROPLET_ID` - From deployment metadata
- `SSH_PRIVATE_KEY` - From `~/.ssh/id_rsa` or specified path

**Railway**:
- `RAILWAY_TOKEN` - From environment variable
- `RAILWAY_PROJECT_ID` - Extracted from `railway.json`
- `RAILWAY_SERVICE_ID` - From railway status

**Exit Codes**:
- `0`: Secrets configured successfully
- `1`: Configuration failed
- `2`: Missing gh CLI or not authenticated

### 3. Extract Platform IDs

**Script**: `scripts/extract-platform-ids.sh <platform> <project-path>`

**Purpose**: Extract platform-specific project IDs automatically

**Actions**:
- Links project to platform if not already linked
- Extracts IDs from configuration files
- Falls back to CLI queries if files missing
- Outputs JSON with all IDs

**Usage**:
```bash
# Extract Vercel IDs
./scripts/extract-platform-ids.sh vercel .

# Extract DigitalOcean App IDs
./scripts/extract-platform-ids.sh digitalocean-app /path/to/app

# Save to file
./scripts/extract-platform-ids.sh vercel . > project-ids.json
```

**Output Format**:
```json
{
  "platform": "vercel",
  "orgId": "team_abc123",
  "projectId": "prj_xyz789",
  "projectName": "my-app",
  "extracted_from": ".vercel/project.json",
  "timestamp": "2025-01-02T12:34:56Z"
}
```

**Exit Codes**:
- `0`: IDs extracted successfully
- `1`: Extraction failed
- `2`: Platform not linked

### 4. Generate Workflow Template

**Script**: `scripts/generate-workflow.sh <platform> <output-path>`

**Purpose**: Generate platform-specific GitHub Actions workflow

**Actions**:
- Selects appropriate template for platform
- Customizes with project-specific settings
- Adds validation, testing, deployment steps
- Configures environment-specific triggers
- Writes workflow to `.github/workflows/deploy.yml`

**Usage**:
```bash
# Generate Vercel workflow
./scripts/generate-workflow.sh vercel .github/workflows/deploy.yml

# Generate DigitalOcean App Platform workflow
./scripts/generate-workflow.sh digitalocean-app .github/workflows/deploy.yml

# Preview without writing
DRY_RUN=true ./scripts/generate-workflow.sh vercel -
```

**Exit Codes**:
- `0`: Workflow generated successfully
- `1`: Generation failed

### 5. Validate CI/CD Setup

**Script**: `scripts/validate-cicd.sh [project-path]`

**Purpose**: Validate complete CI/CD setup is correct

**Checks**:
- GitHub repository exists and is accessible
- `gh` CLI is authenticated
- Workflow file exists and is valid YAML
- Required secrets are configured
- Platform CLI is authenticated
- Project is linked to platform
- All required environment variables present

**Usage**:
```bash
# Validate current directory
./scripts/validate-cicd.sh

# Validate specific path
./scripts/validate-cicd.sh /path/to/project

# Detailed validation report
VERBOSE=true ./scripts/validate-cicd.sh
```

**Exit Codes**:
- `0`: All validations passed
- `1`: One or more validations failed

## Workflow Templates

### Vercel Workflow Template

**File**: `templates/vercel-workflow.yml`

**Features**:
- Multi-environment support (preview/production)
- Automatic deployment on PR and merge
- Build caching for faster deploys
- Health check validation
- Deployment status comments on PRs

**Triggers**:
- Push to `main` → Production deployment
- Pull request → Preview deployment
- Manual workflow dispatch

### DigitalOcean App Platform Workflow

**File**: `templates/digitalocean-app-workflow.yml`

**Features**:
- Container build and push
- App Platform deployment via doctl
- Database migration support
- Health check validation
- Rollback capability

**Triggers**:
- Push to `main` → Production deployment
- Push to `develop` → Staging deployment

### DigitalOcean Droplet Workflow

**File**: `templates/digitalocean-droplet-workflow.yml`

**Features**:
- SSH-based deployment
- Systemd service management
- Zero-downtime deployments
- Automated backups before deploy
- Health check validation

**Triggers**:
- Push to `main` → Production deployment
- Manual workflow dispatch

## End-to-End Workflow

### Initial Setup (One Time)

```bash
# 1. Ensure prerequisites
gh auth status  # Must be authenticated
vercel whoami   # Must be logged in
echo $VERCEL_TOKEN  # Must be set

# 2. Run complete CI/CD setup
cd /path/to/your/project
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/cicd-setup/scripts/setup-cicd.sh vercel

# 3. Validate setup
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/cicd-setup/scripts/validate-cicd.sh

# 4. Test deployment
git add .github/workflows/deploy.yml
git commit -m "ci: Add automated deployment workflow"
git push origin main
```

**That's it!** CI/CD is now fully configured and automated.

### How It Works

1. **Extract IDs**: Script extracts `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` from `.vercel/project.json`
2. **Configure Secrets**: Uses `gh secret set` to configure:
   - `VERCEL_TOKEN` (from environment)
   - `VERCEL_ORG_ID` (extracted)
   - `VERCEL_PROJECT_ID` (extracted)
3. **Generate Workflow**: Creates `.github/workflows/deploy.yml` from template
4. **Validate**: Checks all pieces are in place
5. **Commit & Push**: Adds workflow to repo
6. **Automatic Deployments**: GitHub Actions now handles all deployments

### Subsequent Deployments

```bash
# Every push to main deploys automatically
git add .
git commit -m "feat: New feature"
git push origin main
# → GitHub Actions automatically builds and deploys to production

# Pull requests create preview deployments
git checkout -b feature-branch
git push origin feature-branch
# Create PR → GitHub Actions deploys preview
```

## GitHub CLI Commands Reference

```bash
# Authentication
gh auth login
gh auth status

# Secret Management
gh secret set SECRET_NAME
gh secret set SECRET_NAME < secret.txt
gh secret set SECRET_NAME --body "value"
gh secret list
gh secret remove SECRET_NAME

# Repository Info
gh repo view
gh repo view --json owner,name

# Workflow Management
gh workflow list
gh workflow run deploy.yml
gh workflow view deploy.yml
gh run list
gh run watch
```

## Platform-Specific Details

### Vercel

**Prerequisites**:
```bash
npm install -g vercel
vercel login
export VERCEL_TOKEN="your_token_here"
```

**Project Linking**:
```bash
cd /path/to/project
vercel link  # Creates .vercel/project.json
```

**IDs Location**: `.vercel/project.json`
```json
{
  "orgId": "team_abc123",
  "projectId": "prj_xyz789"
}
```

**Secrets Configured**:
- `VERCEL_TOKEN`: Authentication token
- `VERCEL_ORG_ID`: Organization/team ID
- `VERCEL_PROJECT_ID`: Project ID

**Workflow Features**:
- Preview deployments on PRs
- Production deployments on main
- Automatic PR comments with preview URLs
- Build caching
- Health checks

### DigitalOcean App Platform

**Prerequisites**:
```bash
# Install doctl
brew install doctl  # macOS
# OR
wget https://github.com/digitalocean/doctl/releases/download/v1.94.0/doctl-1.94.0-linux-amd64.tar.gz
tar xf doctl-1.94.0-linux-amd64.tar.gz
sudo mv doctl /usr/local/bin

# Authenticate
doctl auth init
export DIGITALOCEAN_ACCESS_TOKEN="your_token_here"
```

**App Creation**:
```bash
doctl apps create --spec app-spec.yml
doctl apps list  # Get app ID
```

**Secrets Configured**:
- `DIGITALOCEAN_ACCESS_TOKEN`: API token
- `DO_APP_ID`: Application ID
- `DO_APP_NAME`: Application name

**Workflow Features**:
- Multi-environment support
- Database migration support
- Health check validation
- Automatic rollback on failure

### DigitalOcean Droplets

**Prerequisites**:
```bash
doctl auth init
export DIGITALOCEAN_ACCESS_TOKEN="your_token_here"

# Set up SSH key
ssh-keygen -t ed25519 -C "deploy@myapp"
doctl compute ssh-key import deploy-key --public-key-file ~/.ssh/id_ed25519.pub
```

**Secrets Configured**:
- `DIGITALOCEAN_ACCESS_TOKEN`: API token
- `DROPLET_ID`: Droplet ID
- `SSH_PRIVATE_KEY`: SSH private key for deployment

**Workflow Features**:
- SSH-based deployment
- Zero-downtime deployments
- Systemd service management
- Pre-deployment backups

## Security Best Practices

### Secret Management

1. **Never Commit Secrets**: Use `.gitignore` for sensitive files
2. **Use GitHub Secrets**: All secrets stored encrypted in GitHub
3. **Rotate Regularly**: Update tokens every 90 days
4. **Least Privilege**: Use tokens with minimal required permissions
5. **Audit Access**: Review secret access logs regularly

### Workflow Security

1. **Pin Actions Versions**: Use specific versions, not `@latest`
2. **Review Third-Party Actions**: Audit all external actions
3. **Limit Permissions**: Use minimal GITHUB_TOKEN permissions
4. **Protected Branches**: Require reviews for production
5. **Environment Protection**: Use GitHub environments with approvals

## Troubleshooting

### gh CLI Not Authenticated

```bash
# Check authentication
gh auth status

# Login
gh auth login

# Use token
gh auth login --with-token < token.txt
```

### Secret Not Found

```bash
# List secrets
gh secret list

# Verify in specific repo
gh secret list --repo owner/repo

# Set manually
gh secret set SECRET_NAME --body "value"
```

### Workflow Not Triggering

```bash
# Check workflow file syntax
gh workflow view deploy.yml

# Check recent runs
gh run list --workflow=deploy.yml

# View run details
gh run view RUN_ID
```

### Platform IDs Not Extracted

```bash
# Vercel: Ensure project is linked
vercel link

# DigitalOcean: Ensure app exists
doctl apps list

# Check extraction script
bash scripts/extract-platform-ids.sh vercel . --verbose
```

## Cost Optimization

### GitHub Actions Minutes

**Free Tier**:
- Public repos: Unlimited
- Private repos: 2,000 minutes/month

**Tips**:
- Cache dependencies (`actions/cache`)
- Skip unnecessary steps
- Use self-hosted runners for heavy workloads

### Platform Costs

**Vercel**:
- Hobby: Free (100GB bandwidth/month)
- Pro: $20/month (1TB bandwidth)

**DigitalOcean**:
- App Platform: $5-12/month
- Droplets: $4-6/month

**Railway**:
- Free: $5 credit/month
- Hobby: $5/month

## Integration with Dev Lifecycle

This skill integrates with:
- `/deployment:prepare` - Validates prerequisites before CI/CD setup
- `/deployment:deploy` - Uses CI/CD for automated deployments
- `/deployment:validate` - Validates CI/CD pipeline configuration
- `/foundation:hooks-setup` - Integrates with git hooks for local validation

## Examples

See `examples/` directory for:
- `vercel-setup.md` - Complete Vercel CI/CD setup walkthrough
- `digitalocean-setup.md` - DigitalOcean App Platform setup
- `multi-environment.md` - Staging + production environments
- `monorepo-setup.md` - Monorepo deployment strategies

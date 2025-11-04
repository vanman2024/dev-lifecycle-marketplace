# CI/CD Auto-Setup Skill

**One-command CI/CD pipeline setup for any deployment platform.**

## Quick Start

```bash
# Navigate to your project
cd /path/to/your-project

# Run CI/CD setup (auto-detects platform)
bash plugins/deployment/skills/cicd-setup/scripts/setup-cicd.sh auto

# Or specify platform explicitly
bash plugins/deployment/skills/cicd-setup/scripts/setup-cicd.sh vercel
```

**That's it!** CI/CD is now fully configured with:
- ✅ GitHub Actions workflow generated
- ✅ GitHub secrets configured automatically via `gh` CLI
- ✅ Platform project IDs extracted and configured
- ✅ Automatic deployments on every push

## What This Skill Does

### Automation Features

1. **Zero Manual Configuration**: Uses `gh` CLI to set secrets automatically
2. **ID Extraction**: Extracts platform-specific project IDs from config files
3. **Workflow Generation**: Creates platform-optimized GitHub Actions workflows
4. **Validation**: Ensures all prerequisites are met
5. **Git Integration**: Commits and pushes workflow automatically

### Supported Platforms

- **Vercel**: Next.js, React, Vue, static sites
- **DigitalOcean App Platform**: Containerized applications
- **DigitalOcean Droplets**: Custom servers, APIs
- **Railway**: Full-stack applications
- **Netlify**: Static sites, serverless functions
- **Cloudflare Pages**: Static sites, edge functions

## Prerequisites

```bash
# 1. GitHub CLI (authenticated)
gh auth status

# 2. Platform CLI (installed and authenticated)
vercel whoami  # For Vercel
doctl account get  # For DigitalOcean
railway whoami  # For Railway

# 3. Platform token in environment
export VERCEL_TOKEN="your_token_here"
export DIGITALOCEAN_ACCESS_TOKEN="your_token_here"
export RAILWAY_TOKEN="your_token_here"

# 4. Git repository with remote
git remote -v
```

## Available Scripts

### 1. Complete Setup (Recommended)

```bash
./scripts/setup-cicd.sh <platform> [project-path]

# Examples
./scripts/setup-cicd.sh auto  # Auto-detect platform
./scripts/setup-cicd.sh vercel  # Vercel explicitly
./scripts/setup-cicd.sh digitalocean-app  # DO App Platform
./scripts/setup-cicd.sh railway /path/to/project  # Custom path
```

### 2. Extract Platform IDs Only

```bash
./scripts/extract-platform-ids.sh <platform> <project-path>

# Example
./scripts/extract-platform-ids.sh vercel .
# Output: JSON with orgId, projectId, etc.
```

### 3. Configure Secrets Only

```bash
./scripts/configure-github-secrets.sh <platform> <project-path>

# Example
./scripts/configure-github-secrets.sh vercel .
# Configures VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID
```

### 4. Generate Workflow Only

```bash
./scripts/generate-workflow.sh <platform> <output-path>

# Example
./scripts/generate-workflow.sh vercel .github/workflows/deploy.yml
```

## Vercel Example

```bash
# Setup
cd /path/to/nextjs-app
export VERCEL_TOKEN="Sgp8jcYhPGvomgwlYp31lTzj"
bash scripts/setup-cicd.sh vercel

# Result
# ✅ .vercel/project.json → Extracts orgId and projectId
# ✅ GitHub Secrets: VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID
# ✅ .github/workflows/deploy.yml → Auto-generated
# ✅ git push → Workflow committed and pushed

# Now every push deploys automatically!
git push origin main  # → Auto-deploys to production
```

## DigitalOcean Example

```bash
# Setup
cd /path/to/app
export DIGITALOCEAN_ACCESS_TOKEN="dop_v1_..."
bash scripts/setup-cicd.sh digitalocean-app

# Result
# ✅ Extracts DO app ID via doctl
# ✅ GitHub Secrets: DIGITALOCEAN_ACCESS_TOKEN, DO_APP_ID
# ✅ .github/workflows/deploy.yml → Auto-generated
# ✅ Automatic deployments on push
```

## How It Works

### Phase 1: Prerequisites Check
- Verifies `gh` CLI installed and authenticated
- Checks platform CLI (vercel, doctl, railway)
- Validates platform tokens in environment
- Confirms git repository exists

### Phase 2: Platform Detection
- Auto-detects platform from config files
- Falls back to user-specified platform
- Validates platform is supported

### Phase 3: ID Extraction
- Links project to platform if needed
- Extracts IDs from config files:
  - Vercel: `.vercel/project.json`
  - Railway: `railway.json`
  - DigitalOcean: `doctl` CLI queries
- Outputs JSON with all required IDs

### Phase 4: Secret Configuration
- Uses `gh secret set` to configure secrets
- Secrets configured per platform:
  - **Vercel**: VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID
  - **DigitalOcean**: DIGITALOCEAN_ACCESS_TOKEN, DO_APP_ID
  - **Railway**: RAILWAY_TOKEN, RAILWAY_PROJECT_ID
- Validates secrets were set correctly

### Phase 5: Workflow Generation
- Selects platform-specific template
- Generates `.github/workflows/deploy.yml`
- Includes build, deploy, health check steps
- Configures preview and production environments

### Phase 6: Git Integration
- Commits workflow file
- Pushes to remote repository
- GitHub Actions immediately available

## Workflow Features

### Preview Deployments
- Triggered on pull requests
- Deploys to preview environment
- Comments on PR with preview URL
- Automatic cleanup after merge

### Production Deployments
- Triggered on push to `main`
- Deploys to production environment
- Runs health checks
- Automatic rollback on failure (platform-specific)

### Build Optimization
- Caches dependencies (`actions/cache`)
- Parallel job execution
- Minimal runtime overhead

## Troubleshooting

### "gh CLI not authenticated"
```bash
gh auth login
gh auth status
```

### "Platform CLI not installed"
```bash
# Vercel
npm install -g vercel

# DigitalOcean
brew install doctl  # macOS
# OR wget + install (Linux)

# Railway
npm install -g @railway/cli
```

### "Project not linked"
```bash
# Vercel
vercel link

# Railway
railway link

# Rerun setup after linking
bash scripts/setup-cicd.sh auto
```

### "Secrets not found"
```bash
# List secrets
gh secret list

# Set manually if needed
echo "your_token" | gh secret set SECRET_NAME

# Verify
gh secret list | grep SECRET_NAME
```

## Integration with Deployment Commands

This skill is automatically used by:

- `/deployment:deploy` - Uses CI/CD for automated deployments
- `/deployment:prepare` - Validates CI/CD prerequisites
- `/deployment:validate` - Checks CI/CD pipeline health

## Security

- ✅ All secrets stored encrypted in GitHub
- ✅ Never commits secrets to git
- ✅ Uses GitHub Actions GITHUB_TOKEN with minimal permissions
- ✅ Supports GitHub Environments with protection rules
- ✅ Validates workflow syntax before committing

## Cost

### GitHub Actions
- **Public repos**: Unlimited minutes (free)
- **Private repos**: 2,000 minutes/month (free)
- **Additional**: $0.008/minute

### Platforms
- **Vercel Hobby**: Free (100GB bandwidth)
- **DigitalOcean App**: $5-12/month
- **Railway**: $5 credit/month free

## Examples

See `examples/` directory:
- `vercel-setup.md` - Complete Vercel walkthrough
- `digitalocean-setup.md` - DigitalOcean App Platform
- `multi-environment.md` - Staging + production

## Documentation

- `SKILL.md` - Complete skill documentation
- `scripts/` - All automation scripts
- `templates/` - GitHub Actions workflow templates
- `examples/` - Real-world usage examples

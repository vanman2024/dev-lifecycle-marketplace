# Vercel CI/CD Setup Example

This example shows the **complete end-to-end workflow** for setting up automated CI/CD for a Vercel project using a single command.

## Prerequisites

Before starting, ensure you have:

```bash
# 1. GitHub CLI installed and authenticated
gh auth status

# 2. Vercel CLI installed and authenticated
vercel whoami

# 3. Vercel token in environment
echo $VERCEL_TOKEN
# Should output: Sgp8jcYhPGvomgwlYp31lTzj (or your token)

# 4. Git repository initialized
git status
```

## One-Command Setup

```bash
cd /path/to/your-vercel-project

# Run the complete CI/CD setup
bash /home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/cicd-setup/scripts/setup-cicd.sh vercel
```

**That's it!** The script will:

1. ✅ Check all prerequisites (gh, vercel, git, tokens)
2. ✅ Extract Vercel project IDs from `.vercel/project.json`
3. ✅ Configure GitHub secrets automatically:
   - `VERCEL_TOKEN`
   - `VERCEL_ORG_ID`
   - `VERCEL_PROJECT_ID`
4. ✅ Generate `.github/workflows/deploy.yml`
5. ✅ Commit and push the workflow
6. ✅ CI/CD is now fully automated!

## What Happens Next

### Every Push to Main → Production Deployment

```bash
# Make changes
git add .
git commit -m "feat: Add new feature"
git push origin main

# GitHub Actions automatically:
# 1. Checks out code
# 2. Installs dependencies
# 3. Builds project
# 4. Deploys to Vercel production
# 5. Runs health check

# Monitor deployment
gh run watch
```

### Every Pull Request → Preview Deployment

```bash
# Create feature branch
git checkout -b feature/new-feature
git add .
git commit -m "feat: New feature"
git push origin feature/new-feature

# Create PR
gh pr create --fill

# GitHub Actions automatically:
# 1. Builds project
# 2. Deploys preview to Vercel
# 3. Comments on PR with preview URL
```

## Manual Steps (What the Script Automates)

If you want to understand what's happening under the hood:

### Step 1: Link Vercel Project

```bash
cd /path/to/project
vercel link --yes

# This creates .vercel/project.json with:
# {
#   "orgId": "team_abc123",
#   "projectId": "prj_xyz789"
# }
```

### Step 2: Configure GitHub Secrets

```bash
# The script does this automatically via:
echo "$VERCEL_TOKEN" | gh secret set VERCEL_TOKEN
echo "$ORG_ID" | gh secret set VERCEL_ORG_ID
echo "$PROJECT_ID" | gh secret set VERCEL_PROJECT_ID

# Verify secrets were set
gh secret list
```

### Step 3: Create Workflow File

```bash
# The script copies the template to:
mkdir -p .github/workflows
cp templates/vercel-workflow.yml .github/workflows/deploy.yml
```

### Step 4: Commit and Push

```bash
git add .github/workflows/deploy.yml
git commit -m "ci: Add automated deployment workflow"
git push origin main
```

## Troubleshooting

### "Project not linked to Vercel"

```bash
# Link manually
vercel link --yes

# Then rerun setup
bash scripts/setup-cicd.sh vercel
```

### "GitHub CLI not authenticated"

```bash
# Login to GitHub
gh auth login

# Verify
gh auth status
```

### "VERCEL_TOKEN not set"

```bash
# Add to .bashrc
echo 'export VERCEL_TOKEN="your_token_here"' >> ~/.bashrc
source ~/.bashrc

# Verify
echo $VERCEL_TOKEN
```

### Team Selection Issues

If you have a Vercel team and want to force personal account:

```bash
# Set VERCEL_SCOPE to your username
export VERCEL_SCOPE="your-username"

# Then rerun setup
bash scripts/setup-cicd.sh vercel
```

## Monitoring Deployments

```bash
# Watch current deployment
gh run watch

# List recent deployments
gh run list --workflow=deploy.yml

# View specific run
gh run view RUN_ID

# View logs
gh run view RUN_ID --log
```

## Rollback

If a deployment fails:

```bash
# GitHub Actions will auto-fail
# Vercel keeps previous deployment active

# Manual rollback via Vercel
vercel rollback

# Or via /deployment:rollback command
/deployment:rollback
```

## Cost

**GitHub Actions**:
- Public repos: ✅ Free unlimited
- Private repos: ✅ 2,000 minutes/month free

**Vercel**:
- Hobby: ✅ Free (100GB bandwidth)
- Pro: $20/month (1TB bandwidth)

## Example Output

```
═══════════════════════════════════════════════
  CI/CD Auto-Setup
═══════════════════════════════════════════════

Platform: vercel
Project Path: /path/to/my-app
Dry Run: false

═══════════════════════════════════════════════
  Phase 1: Prerequisites Check
═══════════════════════════════════════════════

→ Checking GitHub CLI (gh)...
✓ GitHub CLI installed: gh version 2.40.0

→ Checking GitHub authentication...
✓ GitHub CLI authenticated

→ Checking git repository...
✓ Git repository detected
✓ GitHub repository: my-username/my-app

═══════════════════════════════════════════════
  Phase 2: Platform Configuration
═══════════════════════════════════════════════

✓ Using specified platform: vercel

═══════════════════════════════════════════════
  Phase 3: Platform CLI Verification
═══════════════════════════════════════════════

→ Checking Vercel CLI...
✓ Vercel CLI installed: Vercel CLI 48.8.0
✓ VERCEL_TOKEN is set

═══════════════════════════════════════════════
  Phase 4: Extract Platform IDs
═══════════════════════════════════════════════

→ Running platform ID extraction...
✓ Platform IDs extracted successfully
{
  "platform": "vercel",
  "orgId": "team_abc123",
  "projectId": "prj_xyz789",
  "projectName": "my-app",
  "extracted_from": ".vercel/project.json",
  "timestamp": "2025-01-02T12:34:56Z"
}

═══════════════════════════════════════════════
  Phase 5: Configure GitHub Secrets
═══════════════════════════════════════════════

→ Configuring repository secrets via GitHub CLI...
✓ Set VERCEL_TOKEN
✓ Set VERCEL_ORG_ID: team_abc123
✓ Set VERCEL_PROJECT_ID: prj_xyz789

═══════════════════════════════════════════════
  Phase 6: Generate GitHub Actions Workflow
═══════════════════════════════════════════════

→ Generating workflow file: .github/workflows/deploy.yml
✓ Workflow generated successfully

═══════════════════════════════════════════════
  Phase 7: Validate CI/CD Setup
═══════════════════════════════════════════════

→ Validating workflow file syntax...
✓ Workflow YAML is valid

→ Listing configured secrets...
VERCEL_TOKEN
VERCEL_ORG_ID
VERCEL_PROJECT_ID

═══════════════════════════════════════════════
  Phase 8: Commit Workflow
═══════════════════════════════════════════════

→ Committing workflow file...
✓ Workflow committed

→ Pushing to remote...
✓ Workflow pushed to GitHub

═══════════════════════════════════════════════
  CI/CD Setup Complete! 🎉
═══════════════════════════════════════════════

Platform: vercel
Repository: my-username/my-app
Workflow: .github/workflows/deploy.yml

✓ GitHub Secrets Configured:
  - VERCEL_TOKEN
  - VERCEL_ORG_ID
  - VERCEL_PROJECT_ID

✓ Next Steps:
  1. Push code to trigger deployment:
     git push origin main

  2. Monitor deployment:
     gh run watch

  3. View deployment logs:
     gh run view

  4. Create pull request for preview deployment:
     gh pr create --fill

✓ Deployment will now happen automatically on every push!
```

## Summary

**Before**: Manual deployment with `vercel --prod`
**After**: Fully automated CI/CD pipeline

- ✅ No manual secret configuration
- ✅ No copy-pasting tokens
- ✅ No visiting GitHub web UI
- ✅ One command setup
- ✅ Automatic deployments forever

**Time saved**: ~15-20 minutes per project setup
**Ongoing**: Zero manual deployments needed

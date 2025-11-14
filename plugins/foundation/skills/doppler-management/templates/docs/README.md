# Doppler Secret Management Documentation

**Last Updated:** 2025-11-12
**Project:** Red AI 2

---

## Overview

This directory contains all documentation for Doppler secret management integration with Red AI 2.

Doppler replaces `.env` files with centralized, encrypted secret management across all environments.

---

## Quick Links

### 📚 Documentation

| Document | Description | When to Use |
|----------|-------------|-------------|
| **[environment-setup.md](./environment-setup.md)** | Multi-environment `.env` configuration guide | Setting up dev/staging/prod environments |
| **[integration-guide.md](./integration-guide.md)** | Complete Doppler integration guide | Local development, CI/CD, team workflows |
| **[github-integration.md](./github-integration.md)** | GitHub App integration setup | Automating secret sync to GitHub Actions |

### 🛠️ Scripts (Located in `scripts/doppler/`)

| Script | Description | Command |
|--------|-------------|---------|
| **migrate-to-doppler.sh** | Migrate `.env` files to Doppler | `scripts/doppler/migrate-to-doppler.sh` |
| **run-with-doppler.sh** | Run commands with Doppler secrets | `scripts/doppler/run-with-doppler.sh [command]` |
| **setup-doppler-github.sh** | Interactive GitHub integration setup | `scripts/doppler/setup-doppler-github.sh` |

---

## Setup Status

### ✅ Completed

- [x] Doppler CLI installed (`v3.75.1`)
- [x] Doppler project created (`redai2`)
- [x] Environments configured (`dev`, `stg`, `prd`)
- [x] Local configuration set to `dev`
- [x] Migration scripts created
- [x] Documentation organized

### ⚠️ Pending Actions

- [ ] **Edit `migrate-to-doppler.sh`** with real secrets (REQUIRED)
- [ ] **Run migration:** `./migrate-to-doppler.sh`
- [ ] **Install GitHub App:** `./setup-doppler-github.sh`
- [ ] **Verify secrets sync** to GitHub
- [ ] **Test local development** with Doppler
- [ ] **Update GitHub Actions workflows**
- [ ] **Clean up old `.env.*` files**

---

## Quick Start Guide

### 1. Migrate Secrets to Doppler

```bash
# Edit migration script with your actual secrets
nano migrate-to-doppler.sh

# Run migration
./migrate-to-doppler.sh

# Verify
doppler secrets --project redai2 --config dev
```

### 2. Setup GitHub Integration

```bash
# Run interactive setup
./setup-doppler-github.sh

# This will guide you through:
# 1. Installing Doppler GitHub App
# 2. Configuring sync mappings
# 3. Creating GitHub Environments
# 4. Verifying secret sync
```

### 3. Test Local Development

```bash
# Backend
./run-with-doppler.sh uvicorn api.main:app --reload

# Scripts
./run-with-doppler.sh python backend/scripts/setup_file_search.py

# Frontend (when package.json exists)
./run-with-doppler.sh npm run dev
```

---

## Environment Configuration

### Current Environments

| Environment | Doppler Config | Purpose | GitHub Environment |
|-------------|----------------|---------|-------------------|
| **Development** | `dev` | Local testing | `development` |
| **Staging** | `stg` | Pre-production | `staging` |
| **Production** | `prd` | Live system | `production` |

### Environment Variables by Category

#### Google APIs (Required)
- `GOOGLE_API_KEY`
- `GOOGLE_FILE_SEARCH_STORE_ID`

#### Supabase Database (Required)
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_KEY`

#### Application Settings (Required)
- `ENVIRONMENT`
- `PORT`
- `DEBUG`

#### Batch Processing (Required)
- `BATCH_API_MODEL`
- `BATCH_API_TEMPERATURE`
- `BATCH_API_POLL_INTERVAL`

#### Optional (Future)
- `OPENAI_API_KEY`
- `STRIPE_SECRET_KEY`
- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_WEBHOOK_SECRET`

---

## Workflow Examples

### Local Development

```bash
# Development (default)
./run-with-doppler.sh uvicorn api.main:app --reload

# Staging
DOPPLER_CONFIG=stg ./run-with-doppler.sh uvicorn api.main:app

# Production (careful!)
DOPPLER_CONFIG=prd ./run-with-doppler.sh uvicorn api.main:app
```

### GitHub Actions (After Integration)

**.github/workflows/deploy.yml:**
```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging  # Uses Doppler stg secrets

    steps:
      - uses: actions/checkout@v3

      - name: Run tests
        env:
          GOOGLE_API_KEY: ${{ secrets.GOOGLE_API_KEY }}
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
        run: pytest backend/tests/

  deploy-production:
    runs-on: ubuntu-latest
    environment: production  # Uses Doppler prd secrets
    needs: [deploy-staging]

    steps:
      - uses: actions/checkout@v3

      - name: Deploy
        env:
          SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_SERVICE_KEY }}
        run: ./deploy.sh
```

---

## Key Features

### ✅ Centralized Secret Management
- All secrets in one place (Doppler Dashboard)
- No more scattered `.env` files
- Single source of truth

### ✅ Multi-Environment Support
- Separate configs for dev, staging, production
- Easy environment switching
- Environment-specific values

### ✅ Automatic GitHub Sync
- Secrets auto-sync to GitHub Actions
- Update once, deploys everywhere
- No manual GitHub Secrets management

### ✅ Team Collaboration
- Share access with team members
- Role-based access control
- Audit logs for all changes

### ✅ Security
- Encrypted storage
- Access controls
- Secret rotation tracking
- Audit trail

---

## Common Tasks

### Adding a New Secret

**Via Doppler CLI:**
```bash
# Add to development
doppler secrets set NEW_SECRET="dev_value" --project redai2 --config dev

# Add to staging
doppler secrets set NEW_SECRET="stg_value" --project redai2 --config stg

# Add to production
doppler secrets set NEW_SECRET="prd_value" --project redai2 --config prd
```

**Via Dashboard:**
1. Go to: https://dashboard.doppler.com/workplace/projects/redai2
2. Select config (dev/stg/prd)
3. Click "Add Secret"
4. Enter key and value
5. Auto-syncs to GitHub (~1 minute)

### Updating a Secret

```bash
# Update in Doppler
doppler secrets set GOOGLE_API_KEY="new_key" --project redai2 --config prd

# Automatically syncs to GitHub
# Next workflow run uses new value
```

### Viewing Secrets

```bash
# List all secrets (masked)
doppler secrets --project redai2 --config dev

# Show plain values (careful!)
doppler secrets --project redai2 --config dev --plain

# Get specific secret
doppler secrets get GOOGLE_API_KEY --project redai2 --config dev --plain
```

### Rotating Secrets

**Recommended Schedule:**
- Google API Keys: Every 90 days
- Supabase Service Keys: Every 90 days
- Database Passwords: Every 180 days
- Stripe Keys: Every 180 days

**Process:**
1. Generate new key in service (Google, Supabase, etc.)
2. Update in Doppler
3. Test in staging
4. Update production
5. Revoke old key after 24-48 hours

---

## Troubleshooting

### Issue: Secrets not loading locally

**Check Doppler is running:**
```bash
# Wrong - secrets won't load
uvicorn api.main:app --reload

# Correct - Doppler injects secrets
doppler run -- uvicorn api.main:app --reload
# OR
./run-with-doppler.sh uvicorn api.main:app --reload
```

### Issue: GitHub Actions can't access secrets

**Check environment name:**
```yaml
jobs:
  deploy:
    environment: staging  # Must match GitHub Environment name
```

**Verify sync status:**
1. Doppler Dashboard → Projects → redai2 → Integrations → GitHub
2. Check sync status for each config
3. Look for error messages

### Issue: How to force re-sync

**Manual trigger:**
1. Doppler Dashboard → Projects → redai2 → Integrations → GitHub
2. Click "..." next to sync mapping
3. Click "Re-sync Now"

---

## Security Best Practices

### Access Control
- **Developers:** Read-only access to `dev`
- **QA Team:** Read-only access to `stg`
- **DevOps/SRE:** Full access to all environments

### Secret Rotation
- Schedule regular rotation reminders
- Use calendar events for 90-day/180-day rotations
- Test in staging before production

### Service Tokens
- One token per service (GitHub Actions, DigitalOcean, Vercel)
- Name tokens clearly
- Rotate every 90 days
- Revoke immediately if compromised

### GitHub Protection Rules
- Enable "Required reviewers" for production
- Add approval wait timer (5 minutes)
- Limit who can approve deployments

---

## Dashboard Links

- **Doppler Dashboard:** https://dashboard.doppler.com/workplace/projects/redai2
- **GitHub Repository:** https://github.com/vanman2024/redai2
- **GitHub Environments:** https://github.com/vanman2024/redai2/settings/environments
- **GitHub Secrets:** https://github.com/vanman2024/redai2/settings/secrets/actions

---

## Support Resources

- **Doppler Documentation:** https://docs.doppler.com
- **Doppler CLI Reference:** https://docs.doppler.com/docs/cli
- **GitHub Actions Integration:** https://docs.doppler.com/docs/github-actions
- **Doppler Support:** https://doppler.com/support

---

## Migration Checklist

Use this when migrating from `.env` files to Doppler:

### Phase 1: Preparation
- [x] Doppler CLI installed
- [x] Doppler project created
- [x] Environments configured
- [x] Migration script created
- [x] Documentation organized

### Phase 2: Migration
- [ ] Edit `migrate-to-doppler.sh` with real secrets
- [ ] Run migration script
- [ ] Verify secrets in Doppler Dashboard
- [ ] Test local development

### Phase 3: GitHub Integration
- [ ] Run `./setup-doppler-github.sh`
- [ ] Install Doppler GitHub App
- [ ] Configure sync mappings
- [ ] Create GitHub Environments
- [ ] Verify secrets in GitHub UI

### Phase 4: Testing
- [ ] Test local backend with Doppler
- [ ] Test GitHub Actions workflow
- [ ] Verify staging deployment
- [ ] Test production deployment

### Phase 5: Cleanup
- [ ] Clean up old `.env.*` files
- [ ] Update team documentation
- [ ] Schedule secret rotation reminders
- [ ] Configure access controls
- [ ] Enable production protection rules

---

**Last Updated:** 2025-11-12
**Maintained by:** Claude Code
**Status:** Ready for migration

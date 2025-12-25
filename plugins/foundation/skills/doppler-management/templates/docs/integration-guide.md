# Red AI 2 - Doppler Integration Guide

**Last Updated:** 2025-11-12
**Purpose:** Complete guide for using Doppler secret management with Red AI 2

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Migration from .env Files](#migration-from-env-files)
3. [Local Development](#local-development)
4. [Framework Integration](#framework-integration)
5. [CI/CD Integration](#cicd-integration)
6. [Team Workflows](#team-workflows)
7. [Security Best Practices](#security-best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Quick Start

### What is Doppler?

Doppler is a centralized secret management platform that replaces `.env` files with:
- ✅ Encrypted cloud storage for secrets
- ✅ Multi-environment support (dev, staging, production)
- ✅ Team collaboration with access controls
- ✅ Audit logs for secret changes
- ✅ Automatic secret injection into applications

### Current Setup Status

✅ **Doppler Project Created:** `redai2`
✅ **Environments Configured:**
- `dev` - Development (local testing)
- `stg` - Staging (pre-production)
- `prd` - Production (live system)

✅ **Local Configuration:** Defaults to `dev` environment

---

## Migration from .env Files

### Step 1: Edit Migration Script

The migration script contains **placeholders only**. You must update it with your actual secrets:

```bash
# Open the migration script
nano migrate-to-doppler.sh
```

**Replace placeholders with real values:**

```bash
# Before (placeholder):
GOOGLE_API_KEY="your_google_api_key_here"

# After (your actual key):
GOOGLE_API_KEY="your_google_api_key_here"
```

**⚠️ Security:**
- Never commit `migrate-to-doppler.sh` with real secrets
- Add to `.gitignore` after editing (already included)
- Delete after migration completes

### Step 2: Run Migration

```bash
# Make executable (if not already)
chmod +x migrate-to-doppler.sh

# Run migration
./migrate-to-doppler.sh
```

The script will:
1. Verify Doppler authentication
2. Confirm you've updated placeholders
3. Upload secrets to all environments (dev, stg, prd)
4. Display verification commands

### Step 3: Verify Migration

```bash
# Check development secrets
doppler secrets --project redai2 --config dev

# Check staging secrets
doppler secrets --project redai2 --config stg

# Check production secrets
doppler secrets --project redai2 --config prd
```

**Note:** Secret values are masked by default. Use `--plain` to see actual values (careful in shared terminals).

### Step 4: Clean Up Old .env Files

After verifying migration:

```bash
# Safely move to trash (recoverable)
trash-put .env.development .env.staging .env.production

# Keep .env.example for reference
# Keep current .env if you want a backup
```

---

## Local Development

### Method 1: Run Wrapper Script (Recommended)

Use the provided wrapper for convenience:

```bash
# Backend (FastAPI)
./run-with-doppler.sh uvicorn api.main:app --reload

# Frontend (Next.js - when package.json exists)
./run-with-doppler.sh npm run dev

# Python Scripts
./run-with-doppler.sh python backend/scripts/setup_file_search.py

# Any command
./run-with-doppler.sh your-command-here
```

### Method 2: Direct Doppler Run

```bash
# Explicitly specify project and config
doppler run --project redai2 --config dev -- uvicorn api.main:app --reload

# Use configured defaults (project + config)
doppler run -- uvicorn api.main:app --reload
```

### Method 3: Export to .env (Not Recommended)

If you need a local `.env` file for IDE integration:

```bash
# Export current environment
doppler secrets download --project redai2 --config dev --no-file --format env > .env

# ⚠️ Warning: This defeats the purpose of Doppler
# Only use for IDE compatibility if necessary
```

### Switching Environments

```bash
# Development (default)
./run-with-doppler.sh your-command

# Staging
DOPPLER_CONFIG=stg ./run-with-doppler.sh your-command

# Production (be careful!)
DOPPLER_CONFIG=prd ./run-with-doppler.sh your-command
```

---

## Framework Integration

### FastAPI Backend

#### Development Server

```bash
# With wrapper
./run-with-doppler.sh uvicorn api.main:app --reload --port 8000

# Direct Doppler
doppler run -- uvicorn api.main:app --reload --port 8000
```

#### Reading Secrets in Code

No changes needed! Doppler injects secrets as environment variables:

```python
# backend/api/main.py
import os
from fastapi import FastAPI

app = FastAPI()

# Secrets automatically available via os.getenv
google_api_key = os.getenv("GOOGLE_API_KEY")
supabase_url = os.getenv("SUPABASE_URL")
environment = os.getenv("ENVIRONMENT")
```

#### Production Deployment (DigitalOcean)

```bash
# Generate service token for production
doppler configs tokens create prd-digitalocean --project redai2 --config prd

# Copy the token (starts with dp.st.prd...)
# Add to DigitalOcean App Platform:
# Settings → Environment Variables
# DOPPLER_TOKEN = dp.st.prd.xxxxx

# Update startup command in App Platform:
# doppler run -- uvicorn api.main:app --host 0.0.0.0 --port 8000
```

---

### Next.js Frontend

#### Development Server

```bash
# With wrapper
./run-with-doppler.sh npm run dev

# Direct Doppler
doppler run -- npm run dev
```

#### Environment Variables

Doppler injects secrets, but Next.js requires `NEXT_PUBLIC_` prefix for client-side vars:

**In Doppler Dashboard:**
```bash
# Server-side (backend API calls)
SUPABASE_SERVICE_KEY=your_service_key_here

# Client-side (browser accessible)
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
```

**In Code:**
```typescript
// Server-side (API routes, server components)
const serviceKey = process.env.SUPABASE_SERVICE_KEY

// Client-side (browser)
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
```

#### Production Deployment (Vercel)

```bash
# Generate service token for production frontend
doppler configs tokens create prd-vercel-frontend --project redai2 --config prd

# Add to Vercel:
# Project Settings → Environment Variables → Production
# DOPPLER_TOKEN = dp.st.prd.xxxxx

# Update build command in vercel.json or Vercel dashboard:
# doppler run -- npm run build
```

---

### Python Scripts

```bash
# Database setup
./run-with-doppler.sh python backend/scripts/setup_database.py

# File Search setup
./run-with-doppler.sh python backend/scripts/setup_file_search.py

# Batch processing
./run-with-doppler.sh python backend/scripts/batch_questions.py
```

---

## CI/CD Integration

### GitHub Actions

Create service tokens for CI/CD:

```bash
# Development token
doppler configs tokens create github-actions-dev --project redai2 --config dev

# Staging token
doppler configs tokens create github-actions-stg --project redai2 --config stg

# Production token
doppler configs tokens create github-actions-prd --project redai2 --config prd
```

**Add to GitHub Secrets:**
1. Go to: Repository → Settings → Secrets and variables → Actions
2. Add secrets:
   - `DOPPLER_TOKEN_DEV` = (dev token)
   - `DOPPLER_TOKEN_STG` = (stg token)
   - `DOPPLER_TOKEN_PRD` = (prd token)

**Update `.github/workflows/deploy.yml`:**

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Doppler CLI
        run: |
          curl -Ls https://cli.doppler.com/install.sh | sh

      - name: Run tests with Doppler
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN_STG }}
        run: |
          doppler run -- pytest backend/tests/

      - name: Deploy to staging
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN_STG }}
        run: |
          doppler run -- ./deploy-staging.sh
```

---

### DigitalOcean App Platform

**Option 1: Service Token (Recommended)**

1. Generate token:
   ```bash
   doppler configs tokens create prd-digitalocean --project redai2 --config prd
   ```

2. Add to App Platform:
   - Settings → Environment Variables
   - `DOPPLER_TOKEN` = (token value)

3. Update startup command:
   ```bash
   doppler run -- uvicorn api.main:app --host 0.0.0.0 --port 8000
   ```

**Option 2: Manual Sync (Not Recommended)**

Manually copy secrets to DigitalOcean environment variables. Must update manually when secrets change.

---

### Vercel

**Option 1: Doppler Integration (Best)**

1. Install Doppler Vercel integration:
   - https://www.doppler.com/integrations/vercel

2. Connect your Vercel project to Doppler

3. Select configs:
   - Preview → `stg`
   - Production → `prd`

**Option 2: Service Token**

1. Generate token:
   ```bash
   doppler configs tokens create prd-vercel --project redai2 --config prd
   ```

2. Add to Vercel:
   - Project Settings → Environment Variables → Production
   - `DOPPLER_TOKEN` = (token value)

3. Update build command:
   ```bash
   doppler run -- npm run build
   ```

---

## Team Workflows

### Sharing Access with Team Members

#### 1. Invite Team to Doppler Workspace

```bash
# Via Dashboard
# https://dashboard.doppler.com/workplace/team
# Click "Invite Member" → Enter email
```

#### 2. Assign Project Access

- **Developers:** Read access to `dev`, no access to `prd`
- **DevOps:** Read/Write access to all environments
- **Backend Team:** Full access to backend secrets
- **Frontend Team:** Read-only access to public keys

#### 3. Team Member Setup

Each team member:

```bash
# Install Doppler CLI
curl -Ls https://cli.doppler.com/install.sh | sh

# Login
doppler login

# Setup local project
cd /path/to/redai2
doppler setup --project redai2 --config dev

# Start working
./run-with-doppler.sh uvicorn api.main:app --reload
```

### Adding New Secrets

**Via CLI:**
```bash
# Add to development
doppler secrets set NEW_API_KEY="value_here" --project redai2 --config dev

# Add to all environments
doppler secrets set NEW_API_KEY="dev_value" --project redai2 --config dev
doppler secrets set NEW_API_KEY="stg_value" --project redai2 --config stg
doppler secrets set NEW_API_KEY="prd_value" --project redai2 --config prd
```

**Via Dashboard:**
1. Go to: https://dashboard.doppler.com/workplace/projects/redai2
2. Select environment (dev, stg, prd)
3. Click "Add Secret"
4. Enter key and value

### Secret Change Notifications

Doppler provides:
- **Audit Logs:** Who changed what and when
- **Webhooks:** Notify Slack when secrets change
- **Change Detection:** Apps can reload on secret updates

---

## Security Best Practices

### Access Controls

**Principle of Least Privilege:**
- Developers: Read-only access to `dev`
- Staging access: Limited to QA team
- Production access: Only DevOps/SRE team

### Secret Rotation

**Recommended Schedule:**
```bash
# Google API Keys
Every 90 days

# Supabase Service Keys
Every 90 days

# Database Passwords
Every 180 days

# Stripe Keys (if enabled)
Every 180 days
```

**Rotation Process:**
1. Generate new key in service (Google, Supabase, etc.)
2. Update in Doppler
3. Test in staging first
4. Update production
5. Revoke old key after 24-48 hours

### Service Tokens

**Best Practices:**
- One token per service (CI/CD, DigitalOcean, Vercel)
- Name tokens clearly: `prd-digitalocean`, `stg-github-actions`
- Rotate tokens every 90 days
- Revoke tokens immediately if compromised

### Audit Logs

**Review regularly:**
```bash
# Via Dashboard
# https://dashboard.doppler.com/workplace/projects/redai2/activity
```

**Monitor for:**
- Unexpected secret changes
- Access from unknown IPs
- Token generation by unauthorized users
- Failed authentication attempts

---

## Troubleshooting

### Issue: "Doppler not authenticated"

**Solution:**
```bash
doppler login
```

Follow browser prompts to authenticate.

---

### Issue: "Config not found"

**Error:**
```
Doppler Error: Config not found
```

**Solution:**
```bash
# Check configured values
doppler setup --project redai2 --config dev --no-interactive

# Verify project exists
doppler projects

# Verify config exists
doppler environments --project redai2
```

---

### Issue: "Secrets not loading in application"

**Check 1: Verify Doppler is running**
```bash
# Wrong: Secrets won't load
uvicorn api.main:app --reload

# Correct: Doppler injects secrets
doppler run -- uvicorn api.main:app --reload
```

**Check 2: Verify secrets exist**
```bash
doppler secrets --project redai2 --config dev
```

**Check 3: Test secret injection**
```bash
doppler run -- env | grep GOOGLE_API_KEY
```

---

### Issue: "Service token not working in CI/CD"

**Verify token:**
```bash
# Test token locally
DOPPLER_TOKEN=dp.st.dev.xxxxx doppler secrets
```

**Check token permissions:**
- Token must have read access to specified config
- Token must not be expired
- Token must match environment (dev/stg/prd)

---

### Issue: "How do I see actual secret values?"

**CLI:**
```bash
# Show plain values (be careful in shared terminals!)
doppler secrets --project redai2 --config dev --plain

# Show specific secret
doppler secrets get GOOGLE_API_KEY --project redai2 --config dev --plain
```

**Dashboard:**
1. Go to project config
2. Click "Reveal" next to secret name
3. Copy value

---

## Migration Checklist

Use this checklist when migrating to Doppler:

- [ ] Edit `migrate-to-doppler.sh` with real secrets
- [ ] Run migration: `./migrate-to-doppler.sh`
- [ ] Verify secrets in dev: `doppler secrets --project redai2 --config dev`
- [ ] Verify secrets in staging: `doppler secrets --project redai2 --config stg`
- [ ] Verify secrets in production: `doppler secrets --project redai2 --config prd`
- [ ] Test local development: `./run-with-doppler.sh uvicorn api.main:app --reload`
- [ ] Test backend connects to Supabase
- [ ] Test Google File Search API works
- [ ] Update deployment configurations (DigitalOcean, Vercel)
- [ ] Setup CI/CD service tokens
- [ ] Invite team members to Doppler workspace
- [ ] Configure access controls
- [ ] Clean up old .env files: `trash-put .env.development .env.staging .env.production`
- [ ] Update documentation
- [ ] Schedule secret rotation reminders

---

## Additional Resources

- **Doppler Dashboard:** https://dashboard.doppler.com/workplace/projects/redai2
- **Doppler Docs:** https://docs.doppler.com
- **CLI Reference:** https://docs.doppler.com/docs/cli
- **Integrations:** https://www.doppler.com/integrations
- **Support:** https://doppler.com/support

---

**Last Updated:** 2025-11-12
**Next Review:** After production deployment

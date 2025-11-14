# Red AI 2 - Doppler GitHub Integration Setup

**Last Updated:** 2025-11-12
**Purpose:** Step-by-step guide to connect Doppler directly to GitHub

---

## Why Use Direct GitHub Integration?

✅ **Automatic secret sync** - Update in Doppler, auto-updates in GitHub
✅ **No token management** - No service tokens to rotate
✅ **Single source of truth** - Doppler manages all environments
✅ **Better visibility** - Secrets appear in GitHub Secrets UI
✅ **GitHub Environments** - Works with deployment protection rules

---

## Setup Instructions

### Step 1: Install Doppler GitHub Integration

1. **Go to Doppler Dashboard:**
   ```
   https://dashboard.doppler.com/workplace/projects/redai2/integrations
   ```

2. **Click "GitHub" in the integrations list**

3. **Click "Install Integration"**

4. **Authorize Doppler GitHub App:**
   - GitHub will ask for repository access
   - Choose: "Only select repositories"
   - Select: `your-username/redai2`
   - Click "Install & Authorize"

---

### Step 2: Configure Sync Mappings

After authorization, configure which Doppler configs sync to which GitHub environments:

#### Development Environment
```
Doppler Project: redai2
Doppler Config:  dev
GitHub Repo:     your-username/redai2
GitHub Environment: development (or leave blank for repository-level)
Sync Enabled:    ✓
```

#### Staging Environment
```
Doppler Project: redai2
Doppler Config:  stg
GitHub Repo:     your-username/redai2
GitHub Environment: staging
Sync Enabled:    ✓
```

#### Production Environment
```
Doppler Project: redai2
Doppler Config:  prd
GitHub Repo:     your-username/redai2
GitHub Environment: production
Sync Enabled:    ✓
```

**Click "Save" for each mapping**

---

### Step 3: Create GitHub Environments (If Not Exists)

If you don't have GitHub Environments set up:

1. Go to your repository: `https://github.com/your-username/redai2`
2. Click **Settings** → **Environments**
3. Click **New environment**
4. Create three environments:
   - `development`
   - `staging`
   - `production`

**For production environment:**
- Enable "Required reviewers" (optional but recommended)
- Add yourself as reviewer
- This prevents accidental production deployments

---

### Step 4: Verify Sync

1. **Go to GitHub repository:**
   ```
   https://github.com/your-username/redai2/settings/secrets/actions
   ```

2. **Check "Environment secrets" tab**

3. **You should see secrets synced from Doppler:**
   - `GOOGLE_API_KEY`
   - `GOOGLE_FILE_SEARCH_STORE_ID`
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_KEY`
   - `ENVIRONMENT`
   - `PORT`
   - `DEBUG`
   - `BATCH_API_MODEL`
   - `BATCH_API_TEMPERATURE`
   - `BATCH_API_POLL_INTERVAL`

**Note:** Secret values are masked in GitHub UI (security feature)

---

### Step 5: Test with GitHub Actions

Create a simple workflow to test secret access:

**.github/workflows/test-secrets.yml:**
```yaml
name: Test Doppler Secrets

on:
  workflow_dispatch:  # Manual trigger for testing

jobs:
  test-dev:
    runs-on: ubuntu-latest
    environment: development  # Uses Doppler dev config

    steps:
      - name: Verify secrets are loaded
        run: |
          echo "Environment: ${{ secrets.ENVIRONMENT }}"
          echo "Port: ${{ secrets.PORT }}"
          echo "Google API Key exists: ${{ secrets.GOOGLE_API_KEY != '' }}"
          echo "Supabase URL: ${{ secrets.SUPABASE_URL }}"

  test-staging:
    runs-on: ubuntu-latest
    environment: staging  # Uses Doppler stg config

    steps:
      - name: Verify secrets are loaded
        run: |
          echo "Environment: ${{ secrets.ENVIRONMENT }}"
          echo "Staging secrets loaded successfully"

  test-prod:
    runs-on: ubuntu-latest
    environment: production  # Uses Doppler prd config
    needs: [test-dev, test-staging]  # Run after others pass

    steps:
      - name: Verify secrets are loaded
        run: |
          echo "Environment: ${{ secrets.ENVIRONMENT }}"
          echo "Production secrets loaded successfully"
```

**Run the workflow:**
1. Go to: Actions → Test Doppler Secrets → Run workflow
2. Check output to verify secrets are loaded

---

## Using Secrets in GitHub Actions

### Basic Usage

```yaml
name: Deploy Backend

on:
  push:
    branches: [main]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging  # Loads Doppler stg secrets

    steps:
      - uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.12'

      - name: Run tests
        env:
          GOOGLE_API_KEY: ${{ secrets.GOOGLE_API_KEY }}
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_SERVICE_KEY }}
        run: |
          cd backend
          pip install -r requirements.txt
          pytest tests/

      - name: Deploy to DigitalOcean
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}  # If using service token approach
        run: |
          ./deploy-staging.sh
```

---

### Multi-Environment Workflow

```yaml
name: Full Deployment Pipeline

on:
  push:
    branches: [main]

jobs:
  test-dev:
    runs-on: ubuntu-latest
    environment: development

    steps:
      - uses: actions/checkout@v3

      - name: Run unit tests
        env:
          GOOGLE_API_KEY: ${{ secrets.GOOGLE_API_KEY }}
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
        run: pytest backend/tests/unit/

  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    needs: [test-dev]

    steps:
      - uses: actions/checkout@v3

      - name: Deploy to staging
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_SERVICE_KEY }}
        run: |
          echo "Deploying to staging..."
          ./deploy-staging.sh

      - name: Run integration tests
        run: pytest backend/tests/integration/

  deploy-production:
    runs-on: ubuntu-latest
    environment: production  # Requires approval if configured
    needs: [deploy-staging]

    steps:
      - uses: actions/checkout@v3

      - name: Deploy to production
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_SERVICE_KEY }}
          GOOGLE_API_KEY: ${{ secrets.GOOGLE_API_KEY }}
        run: |
          echo "Deploying to production..."
          ./deploy-production.sh
```

---

## Managing Secrets After Integration

### Adding New Secrets

**Option 1: Via Doppler Dashboard (Recommended)**
```
1. Go to: https://dashboard.doppler.com/workplace/projects/redai2
2. Select config: dev, stg, or prd
3. Click "Add Secret"
4. Enter key and value
5. Doppler automatically syncs to GitHub
```

**Option 2: Via Doppler CLI**
```bash
# Add to development
doppler secrets set NEW_API_KEY="dev_value" --project redai2 --config dev

# Add to staging
doppler secrets set NEW_API_KEY="stg_value" --project redai2 --config stg

# Add to production
doppler secrets set NEW_API_KEY="prd_value" --project redai2 --config prd

# Doppler syncs to GitHub automatically (within ~1 minute)
```

---

### Updating Secrets

**Just update in Doppler:**
```bash
doppler secrets set GOOGLE_API_KEY="new_key_value" --project redai2 --config prd
```

**Doppler automatically:**
1. Syncs to GitHub Secrets (within 1 minute)
2. Next workflow run uses new value
3. No manual GitHub Secrets update needed

---

### Removing Secrets

**Delete in Doppler:**
```bash
doppler secrets delete OLD_API_KEY --project redai2 --config dev
```

**Doppler removes from GitHub automatically**

---

## Troubleshooting

### Issue: Secrets Not Syncing to GitHub

**Check sync status:**
```
1. Go to Doppler Dashboard
2. Navigate to: Projects → redai2 → Integrations → GitHub
3. Check "Sync Status" for each config
4. Look for error messages
```

**Common fixes:**
- Re-authorize Doppler GitHub App
- Check repository access permissions
- Verify GitHub Environment names match exactly

---

### Issue: Workflow Can't Access Secrets

**Check 1: Environment name matches**
```yaml
# Workflow must specify environment
jobs:
  deploy:
    environment: staging  # Must match Doppler sync mapping
```

**Check 2: Secret exists in GitHub**
```
Go to: Repository → Settings → Secrets → Actions → staging
Verify secret is listed
```

**Check 3: Permissions**
```yaml
# Add to workflow if needed
permissions:
  contents: read
  id-token: write
```

---

### Issue: How to Manually Trigger Sync

**Force re-sync:**
```
1. Doppler Dashboard → Projects → redai2 → Integrations → GitHub
2. Click "..." next to sync mapping
3. Click "Re-sync Now"
```

---

## Security Best Practices

### Environment Protection Rules

**For production environment:**
```
1. GitHub: Repository → Settings → Environments → production
2. Enable "Required reviewers"
3. Add DevOps team members
4. Enable "Wait timer" (optional: 5 minutes)
```

**Benefits:**
- Manual approval required for production deployments
- Prevents accidental production pushes
- Audit trail of who approved deployments

---

### Secret Access Logs

**Doppler provides audit logs:**
```
Dashboard → Projects → redai2 → Activity
```

**GitHub provides deployment logs:**
```
Repository → Environments → production → Deployments
```

---

### Least Privilege Access

**Doppler side:**
- Only sync necessary secrets to GitHub
- Use separate configs for dev/stg/prd
- Limit team member access in Doppler

**GitHub side:**
- Use GitHub Environments (not repository-level secrets)
- Enable required reviewers for production
- Use `GITHUB_TOKEN` instead of personal tokens when possible

---

## Migration from Service Tokens

If you're currently using service tokens (Option 2 from integration guide):

### Step 1: Set up GitHub Integration (above)

### Step 2: Update Workflows

**Before (Service Token):**
```yaml
- name: Install Doppler CLI
  run: curl -Ls https://cli.doppler.com/install.sh | sh

- name: Run with Doppler
  env:
    DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN_STG }}
  run: doppler run -- pytest tests/
```

**After (GitHub Integration):**
```yaml
- name: Run tests
  env:
    GOOGLE_API_KEY: ${{ secrets.GOOGLE_API_KEY }}
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  run: pytest tests/
```

### Step 3: Remove Old Tokens

```bash
# Revoke service tokens in Doppler
doppler configs tokens revoke <token-name> --project redai2 --config stg

# Remove from GitHub Secrets
# Repository → Settings → Secrets → Actions → Delete DOPPLER_TOKEN_*
```

---

## Summary

✅ **Direct GitHub Integration Benefits:**
- Automatic secret sync
- No token management
- Better visibility
- Single source of truth

✅ **Setup Complete When:**
- [x] Doppler GitHub App installed
- [x] Sync mappings configured (dev, stg, prd)
- [x] GitHub Environments created
- [x] Secrets visible in GitHub UI
- [x] Test workflow passes

✅ **Next Steps:**
- Add secrets to Doppler (they sync automatically)
- Update workflows to use `environment:` key
- Enable production environment protection rules
- Test deployments to each environment

---

**Dashboard Links:**
- Doppler Integrations: https://dashboard.doppler.com/workplace/projects/redai2/integrations
- GitHub Environments: https://github.com/your-username/redai2/settings/environments
- GitHub Secrets: https://github.com/your-username/redai2/settings/secrets/actions

**Support:**
- Doppler GitHub Integration Docs: https://docs.doppler.com/docs/github-actions
- GitHub Environments Docs: https://docs.github.com/en/actions/deployment/targeting-different-environments

# Red AI 2 - Environment Setup Guide

**Last Updated:** 2025-01-12
**Purpose:** Multi-environment configuration and deployment guide

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Environment Files Overview](#environment-files-overview)
3. [Setup Instructions by Environment](#setup-instructions-by-environment)
4. [Service Configuration](#service-configuration)
5. [Security Best Practices](#security-best-practices)
6. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Step 1: Choose Your Environment

```bash
# Development (local testing)
cp .env.development .env

# Staging (pre-production testing)
cp .env.staging .env

# Production (live system)
cp .env.production .env
```

### Step 2: Configure Required Services

**Priority 1 - Immediate Setup:**
- ✅ Google API (already configured in production)
- ⚠️ Supabase Database (needs configuration)
- ✅ FastAPI Settings (already configured)

**Optional - Future Enhancements:**
- OpenAI API (for multi-modal features)
- Stripe (for payment processing)

### Step 3: Update Credentials

Edit `.env` and replace placeholders with your actual credentials (see [Service Configuration](#service-configuration) below).

---

## Environment Files Overview

### Available Environment Files

| File | Purpose | Debug | Commit to Git |
|------|---------|-------|---------------|
| `.env` | **Active configuration** (current environment) | Varies | ❌ Never |
| `.env.example` | Template with placeholders | - | ✅ Safe |
| `.env.development` | Local development setup | ✅ Enabled | ❌ Never |
| `.env.staging` | Pre-production testing | ❌ Disabled | ❌ Never |
| `.env.production` | Live production system | ❌ Disabled | ❌ Never |

### Environment Variables by Category

#### **Core Application Settings** (Required)
```bash
ENVIRONMENT=development          # development | staging | production
DEBUG=true                      # true for dev, false for staging/prod
PORT=8000                       # FastAPI server port
```

#### **Google APIs** (Required - RAG & Batch Processing)
```bash
GOOGLE_API_KEY=...              # Google AI Studio API key
GOOGLE_FILE_SEARCH_STORE_ID=... # File Search store identifier
```

#### **Supabase Database** (Required - Data Persistence)
```bash
SUPABASE_URL=...                # Supabase project URL
SUPABASE_ANON_KEY=...           # Public anonymous key
SUPABASE_SERVICE_KEY=...        # Service role key (admin access)
```

#### **Batch Processing** (Required - Question Generation)
```bash
BATCH_API_MODEL=gemini-2.5-flash  # Gemini model for batch jobs
BATCH_API_TEMPERATURE=0.7         # Creativity vs consistency
BATCH_API_POLL_INTERVAL=60        # Status check interval (seconds)
```

#### **OpenAI API** (Optional - Future Features)
```bash
# OPENAI_API_KEY=...            # For gpt-4o, Whisper (commented out)
```

#### **Stripe Payments** (Optional - Not Yet Implemented)
```bash
# STRIPE_SECRET_KEY=...         # Server-side key
# STRIPE_PUBLISHABLE_KEY=...    # Client-side key
# STRIPE_WEBHOOK_SECRET=...     # Webhook verification
```

---

## Setup Instructions by Environment

### Development Environment

**Purpose:** Local development and testing

#### 1. Create Development .env

```bash
cp .env.development .env
```

#### 2. Configure Google APIs

```bash
# Option A: Use production credentials (easiest)
GOOGLE_API_KEY=your_google_api_key_here
GOOGLE_FILE_SEARCH_STORE_ID=fileSearchStores/redsealtrainingmaterials-9597tyk1dblp

# Option B: Create separate dev File Search store
# Run: python backend/scripts/setup_file_search.py
# Then copy the new store ID
```

#### 3. Configure Supabase (Development Project)

**Recommended:** Create a separate development project

1. Go to https://app.supabase.com
2. Click "New Project"
3. Name: `redai2-dev`
4. Choose a strong database password
5. Select region (closest to you)
6. Navigate to: Settings → API
7. Copy credentials:

```bash
SUPABASE_URL=https://your-dev-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 4. Run Database Migrations

```bash
# Apply schema to development database
cd supabase
supabase db push --project-ref <your-dev-project-ref>
```

#### 5. Verify Setup

```bash
# Start FastAPI backend
cd backend
uvicorn api.main:app --reload --port 8000

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/questions/1
```

---

### Staging Environment

**Purpose:** Pre-production testing with beta users

#### 1. Create Staging .env

```bash
cp .env.staging .env
```

#### 2. Configure Google APIs

```bash
# Option A: Use production credentials
# (Same as development if using shared quota)

# Option B: Create separate staging File Search store
# Recommended for isolated testing
```

#### 3. Configure Supabase (Staging Project)

**IMPORTANT:** Must be separate from production

1. Create new project: `redai2-staging`
2. Copy credentials to `.env`
3. Apply migrations:

```bash
cd supabase
supabase db push --project-ref <your-staging-project-ref>
```

#### 4. Configure Deployment Platform

**Vercel (Frontend)**
```bash
vercel env add NEXT_PUBLIC_SUPABASE_URL
# Paste staging Supabase URL

vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
# Paste staging anon key
```

**DigitalOcean (Backend)**
```bash
# Add environment variables in App Platform:
# Settings → Environment Variables → Edit
# Add all variables from .env.staging
```

---

### Production Environment

**Purpose:** Live system serving real users

#### 1. Create Production .env

```bash
cp .env.production .env
```

#### 2. Configure Google APIs (Production)

```bash
# Use existing production credentials
GOOGLE_API_KEY=your_google_api_key_here
GOOGLE_FILE_SEARCH_STORE_ID=fileSearchStores/redsealtrainingmaterials-9597tyk1dblp

# ⚠️ Enable quota monitoring at:
# https://console.cloud.google.com/apis/api/generativelanguage.googleapis.com/quotas
```

#### 3. Configure Supabase (Production Project)

**CRITICAL:** Must be separate from dev/staging

1. Create production project: `redai2-production`
2. Choose **Pro Plan** ($25/month) for:
   - 8 GB database
   - 250 GB bandwidth
   - Daily backups
   - Point-in-time recovery
3. Copy production credentials to `.env.production`
4. Apply migrations:

```bash
cd supabase
supabase db push --project-ref <your-production-project-ref>
```

#### 4. Security Checklist

- [ ] Disable DEBUG mode (`DEBUG=false`)
- [ ] Use strong database password (20+ characters)
- [ ] Enable Supabase RLS policies
- [ ] Set up database backups (daily)
- [ ] Configure monitoring alerts
- [ ] Rotate API keys every 90 days
- [ ] Store secrets in deployment platform (never commit)
- [ ] Enable HTTPS only
- [ ] Set up error tracking (Sentry)

#### 5. Deploy to Production

**Backend (DigitalOcean App Platform)**
```bash
# Add environment variables in console
# OR use doctl CLI:
doctl apps create-deployment <app-id> \
  --env GOOGLE_API_KEY=... \
  --env SUPABASE_URL=... \
  # (add all variables)
```

**Frontend (Vercel)**
```bash
# Deploy with production environment
vercel --prod

# Or configure in Vercel dashboard:
# Settings → Environment Variables → Production
```

---

## Service Configuration

### Google File Search API

**Get API Key:**
1. Go to https://aistudio.google.com/app/apikey
2. Click "Create API Key"
3. Choose existing Google Cloud project or create new one
4. Copy key to `.env`

**Create File Search Store:**
```bash
cd backend/scripts
python setup_file_search.py

# Output will include store ID:
# GOOGLE_FILE_SEARCH_STORE_ID=fileSearchStores/your-store-id
```

**Production Configuration:**
- ✅ Store ID: `fileSearchStores/redsealtrainingmaterials-9597tyk1dblp`
- ✅ Content: 23.3 MB of Red Seal training manuals
- ✅ Cost: $0.063/student/month

---

### Supabase Database

**Create Project:**
1. Go to https://app.supabase.com
2. Click "New Project"
3. Fill in:
   - **Organization:** Your organization
   - **Name:** `redai2-{environment}` (e.g., `redai2-production`)
   - **Database Password:** Use strong password (20+ characters)
   - **Region:** Choose closest to your users
4. Wait for project to provision (~2 minutes)

**Get Credentials:**
1. Navigate to: Settings → API
2. Copy to `.env`:
   - **Project URL** → `SUPABASE_URL`
   - **anon/public key** → `SUPABASE_ANON_KEY`
   - **service_role key** → `SUPABASE_SERVICE_KEY`

**Apply Database Schema:**
```bash
# Install Supabase CLI (if not already installed)
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
cd supabase
supabase link --project-ref <your-project-ref>

# Apply migrations
supabase db push

# Verify schema
supabase db diff
```

**Database Schema Overview:**
- `users` - User accounts and profiles
- `trades` - Trade certifications (Red Seal)
- `chapters` - Training material chapters
- `questions` - Practice questions
- `user_progress` - Learning progress tracking
- `user_answers` - Answer history
- `batch_jobs` - Batch processing tracking

**Cost Estimate:**
- **Free Tier:** $0/month (up to 500 MB database, 2 GB bandwidth)
- **Pro Plan:** $25/month (8 GB database, 250 GB bandwidth)
- **Per Student:** ~$0.083/student/month (300 students on Pro plan)

---

### OpenAI API (Optional)

**When to Enable:**
- Adding multi-modal chat (text, image, audio)
- Voice transcription with Whisper
- Image-based equipment identification questions

**Get API Key:**
1. Go to https://platform.openai.com
2. Sign up / Log in
3. Navigate to: API Keys
4. Click "Create new secret key"
5. Copy key to `.env`

**Configuration:**
```bash
OPENAI_API_KEY=sk-proj-...
```

**Estimated Cost:**
- gpt-4o: $2.50/1M input tokens, $10/1M output tokens
- Whisper: $0.006/minute
- **Per Student:** ~$1.10/student/month (10 queries/week)

---

### Stripe Payments (Optional)

**When to Enable:**
- Launching paid subscriptions ($29/month)
- Processing credit card payments
- Managing billing cycles

**Get API Keys:**
1. Go to https://stripe.com
2. Sign up / Log in
3. Navigate to: Developers → API Keys
4. **Test Mode** (for dev/staging):
   - Copy "Publishable key" → `STRIPE_PUBLISHABLE_KEY`
   - Copy "Secret key" → `STRIPE_SECRET_KEY`
5. **Live Mode** (for production):
   - Activate your account
   - Copy "Publishable key" → `STRIPE_PUBLISHABLE_KEY`
   - Copy "Secret key" → `STRIPE_SECRET_KEY`

**Webhook Configuration:**
1. Navigate to: Developers → Webhooks
2. Click "Add endpoint"
3. URL: `https://your-domain.com/api/webhooks/stripe`
4. Select events:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Copy "Signing secret" → `STRIPE_WEBHOOK_SECRET`

**Cost:**
- 2.9% + $0.30 per transaction
- Monthly subscription ($29): $1.14 fee per student

---

## Security Best Practices

### Never Commit Secrets

**Protected Files (in .gitignore):**
```
.env
.env.*
!.env.example
```

**How to Verify:**
```bash
# Check if .env is ignored
git check-ignore .env
# Should output: .env

# Verify no secrets in git history
git log --all --full-history -- .env
# Should be empty
```

### API Key Rotation Schedule

| Service | Rotation Frequency | Priority |
|---------|-------------------|----------|
| Google API Keys | Every 90 days | High |
| Supabase Service Key | Every 90 days | Critical |
| Stripe Keys | Every 180 days | Medium |
| Supabase Anon Key | Every 180 days | Low |

### Secret Storage Best Practices

**❌ Never Do:**
- Hardcode keys in source code
- Commit `.env` files to version control
- Share keys via email/Slack
- Store in client-side JavaScript
- Log API keys to console

**✅ Always Do:**
- Read from environment variables: `os.getenv("KEY_NAME")`
- Use deployment platform secrets (Vercel, DigitalOcean)
- Store in `.env` files (git-ignored)
- Use placeholders in `.env.example`
- Rotate keys regularly

**Deployment Platform Secret Storage:**

**Vercel:**
```bash
vercel env add SUPABASE_SERVICE_KEY production
# Paste key securely
```

**DigitalOcean:**
```bash
# App Platform → Settings → Environment Variables
# Mark "Encrypted" checkbox for sensitive values
```

**Local Development:**
```bash
# .env file (git-ignored)
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Troubleshooting

### Common Issues

#### Issue: "Missing environment variable GOOGLE_API_KEY"

**Solution:**
```bash
# Verify .env file exists
ls -la .env

# Check file contents (don't paste output publicly!)
cat .env | grep GOOGLE_API_KEY

# If missing, copy from template
cp .env.development .env

# Update with your actual key
nano .env
```

---

#### Issue: "Supabase connection failed"

**Symptoms:**
```
Error: connect ECONNREFUSED
```

**Solution:**
```bash
# 1. Verify credentials are correct
cat .env | grep SUPABASE

# 2. Test connection manually
curl https://your-project.supabase.co/rest/v1/ \
  -H "apikey: your-anon-key"

# 3. Check Supabase project status
# Visit: https://app.supabase.com/project/_/settings/general

# 4. Verify RLS policies allow access
# Visit: https://app.supabase.com/project/_/auth/policies
```

---

#### Issue: "Invalid Google API key"

**Symptoms:**
```
Error: API key not valid. Please pass a valid API key.
```

**Solution:**
```bash
# 1. Verify API key format (should start with "AIza")
cat .env | grep GOOGLE_API_KEY

# 2. Check API is enabled
# Visit: https://console.cloud.google.com/apis/library
# Search: "Generative Language API"
# Status should be: "Enabled"

# 3. Check quota limits
# Visit: https://console.cloud.google.com/apis/api/generativelanguage.googleapis.com/quotas

# 4. Regenerate API key if needed
# Visit: https://aistudio.google.com/app/apikey
```

---

#### Issue: "CORS error in browser"

**Symptoms:**
```
Access to fetch at 'http://localhost:8000/api/...' has been blocked by CORS policy
```

**Solution:**
```bash
# Backend: Verify CORS middleware in api/main.py
# Should include:
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Frontend: Verify API URL in .env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

---

#### Issue: "Database migrations not applied"

**Symptoms:**
```
Error: relation "users" does not exist
```

**Solution:**
```bash
# 1. Check migration status
cd supabase
supabase db diff

# 2. Apply pending migrations
supabase db push

# 3. Verify tables exist
supabase db remote ls

# 4. If needed, reset and reapply
supabase db reset
```

---

### Environment-Specific Debugging

#### Development
```bash
# Enable verbose logging
export DEBUG=true

# Start with reload
uvicorn api.main:app --reload --log-level debug
```

#### Staging
```bash
# Check deployment logs
vercel logs <deployment-url>
doctl apps logs <app-id> --follow
```

#### Production
```bash
# Monitor error rates
# Sentry: https://sentry.io/organizations/your-org/issues/

# Check database performance
# Supabase: https://app.supabase.com/project/_/database/query-performance

# Monitor API quotas
# Google Cloud: https://console.cloud.google.com/apis/dashboard
```

---

## Next Steps

### Immediate Actions

1. **Set up Supabase:**
   - [ ] Create development project
   - [ ] Apply database migrations
   - [ ] Update `.env` with credentials
   - [ ] Test connection

2. **Verify Environment:**
   - [ ] Start backend: `uvicorn api.main:app --reload`
   - [ ] Test health: `curl http://localhost:8000/health`
   - [ ] Test API: `curl http://localhost:8000/api/v1/questions/1`

3. **Review Documentation:**
   - [ ] Read `docs/architecture/ai.md` for AI integration details
   - [ ] Read `docs/ROADMAP.md` for feature priorities
   - [ ] Check `docs/WORKING-STATUS.md` for current project state

### Optional Enhancements

- **OpenAI Integration:** Enable multi-modal chat features
- **Stripe Payments:** Set up subscription billing
- **Monitoring:** Configure Sentry error tracking
- **Analytics:** Add usage tracking
- **Backups:** Schedule automated database backups

---

## Support & Resources

- **Architecture Documentation:** `docs/architecture/`
- **Working Status Report:** `docs/WORKING-STATUS.md`
- **Roadmap:** `docs/ROADMAP.md`
- **Security Rules:** `docs/security/SECURITY-RULES.md`

---

**Last Updated:** 2025-01-12
**Next Review:** Before production deployment

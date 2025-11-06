# BUILD-GUIDE.md - AI SaaS Application Example

> Real-world example showing how to use the BUILD-GUIDE pattern for a typical AI-powered SaaS application

## Project: AI-Powered Content Generator SaaS

**Tech Stack**: Next.js 15 + FastAPI + Supabase + Vercel AI SDK + Mem0
**Target**: B2B SaaS with AI content generation, user subscriptions, and memory

---

## Phase 0: Environment Setup

```bash
/foundation:detect
/foundation:env-check --fix
/foundation:github-init ai-content-saas --private
/foundation:hooks-setup
/foundation:doppler-setup ai-content-saas
```

**Validation**:
- [x] Tech stack detected in `.claude/project.json`
- [x] Node.js 18+, Python 3.9+, git, gh CLI installed
- [x] GitHub repo created: `myorg/ai-content-saas`
- [x] Git hooks active (pre-commit checks secrets)
- [x] Doppler configured for secret management

---

## Phase 1: Database & Auth

```bash
/supabase:init
/supabase:add-auth
/supabase:setup-pgvector
/supabase:add-rls
/supabase:create-schema "subscription management"
/supabase:validate-setup
```

**Custom Schema** (not plugin-built):
- `subscriptions` table (tier, status, billing)
- `credits` table (usage tracking)
- `generated_content` table (output history)

**Validation**:
- [x] Supabase project created
- [x] Google OAuth + Email/Password enabled
- [x] pgvector extension for AI embeddings
- [x] RLS policies for user data isolation
- [x] Custom tables created with migrations

---

## Phase 2: Backend API

```bash
/fastapi-backend:init
/fastapi-backend:integrate-supabase
/fastapi-backend:add-auth
/fastapi-backend:add-endpoint "content generation"
/fastapi-backend:setup-database
```

**Custom Endpoints** (unique business logic):
- `POST /api/generate` - AI content generation with credit deduction
- `POST /api/subscription/upgrade` - Stripe webhook handler
- `GET /api/usage/stats` - User credit consumption analytics

**Validation**:
- [x] FastAPI running on http://localhost:8000
- [x] Supabase connection verified
- [x] Auth middleware protecting routes
- [x] Custom endpoints implemented and tested

---

## Phase 3: Frontend Application

```bash
/nextjs-frontend:init
/nextjs-frontend:integrate-supabase
/nextjs-frontend:integrate-ai-sdk
/nextjs-frontend:search-components button card input
/nextjs-frontend:add-component button card input dialog
/nextjs-frontend:add-page dashboard
/nextjs-frontend:add-page generate
/nextjs-frontend:add-page settings
```

**Custom Pages**:
- `/pricing` - Subscription tiers with Stripe checkout
- `/history` - Generated content history with search
- `/analytics` - Usage dashboard with charts

**Validation**:
- [x] Next.js running on http://localhost:3000
- [x] Supabase auth flow working (login/logout/signup)
- [x] UI components styled with shadcn/ui
- [x] API calls to FastAPI backend successful

---

## Phase 4: AI Features

```bash
# Memory Layer
/mem0:init-platform
/mem0:add-user-memory
/mem0:add-conversation-memory

# LLM Integration
/vercel-ai-sdk:add-provider openai
/vercel-ai-sdk:add-streaming
/vercel-ai-sdk:add-tools
/vercel-ai-sdk:add-chat

# OpenRouter for model selection
/openrouter:init
/openrouter:add-vercel-ai-sdk
/openrouter:add-model-routing
```

**Custom AI Logic**:
- Credit-based token tracking
- Model selection based on subscription tier
- Content caching and deduplication
- Prompt templates for content types

**Validation**:
- [x] AI streaming responses work in UI
- [x] Mem0 remembers user preferences
- [x] Credit deduction on generation
- [x] Multiple LLM providers available

---

## Phase 5: Payment Integration

```bash
/payments:init stripe
/payments:add-checkout
/payments:add-subscriptions
/payments:add-webhooks
```

**Subscription Tiers**:
- Starter: $29/mo, 50k credits/mo, GPT-3.5
- Pro: $99/mo, 200k credits/mo, GPT-4
- Enterprise: Custom, unlimited, all models

**Custom Payment Logic**:
- Credit allocation on subscription start
- Overage billing for credit exhaustion
- Team subscription management
- Usage-based invoicing

**Validation**:
- [x] Stripe checkout flow functional
- [x] Subscription creation in database
- [x] Webhook handlers working
- [x] Credits allocated correctly

---

## Phase 6: Feature Implementation (Specs)

This app has 3 custom features requiring specs:

### Feature 001: Content Templates
**Spec**: `specs/features/001-content-templates/`
```bash
/iterate:tasks spec-001
```
- Custom template builder UI
- Template variable system
- Template versioning
- Template marketplace (future)

### Feature 002: Brand Voice
**Spec**: `specs/features/002-brand-voice/`
```bash
/iterate:tasks spec-002
```
- Brand voice training from examples
- Voice consistency scoring
- Multi-brand support for agencies
- Voice A/B testing

### Feature 003: Collaboration
**Spec**: `specs/features/003-team-collaboration/`
```bash
/iterate:tasks spec-003
```
- Team workspace creation
- Role-based permissions
- Content review workflow
- Approval system

---

## Phase 7: Testing & Quality

```bash
/quality:test
/quality:security
/quality:performance
```

**Test Coverage**:
- Newman API tests: 85% coverage
- Playwright E2E: Critical user flows
- Security: No vulnerabilities detected
- Performance: <500ms API response time

**Validation**:
- [x] All tests passing
- [x] No exposed secrets
- [x] Load tested for 100 concurrent users
- [x] Error handling tested

---

## Phase 8: Deployment

```bash
/deployment:prepare
/deployment:setup-cicd vercel
/deployment:deploy

# Post-deployment
/deployment:setup-monitoring sentry
/deployment:capture-baseline
```

**Deployed To**:
- Frontend: Vercel (https://ai-content-saas.vercel.app)
- Backend: Railway (https://api-ai-content-saas.railway.app)
- Database: Supabase Cloud

**Monitoring**:
- Sentry for error tracking
- Vercel Analytics for frontend metrics
- Custom analytics dashboard for usage

**Validation**:
- [x] Production deployed and accessible
- [x] SSL certificates active
- [x] Environment variables configured
- [x] Health checks passing
- [x] Monitoring active

---

## Phase 9: Versioning & Release

```bash
/versioning:setup
/versioning:bump minor
/versioning:generate-release-notes v1.0.0
```

**v1.0.0 Release**:
- AI content generation with GPT-3.5/4
- User authentication and subscriptions
- Mem0 memory for personalization
- Content templates system
- Brand voice consistency
- Team collaboration features

---

## Maintenance

### Weekly
```bash
/quality:security              # Check for vulnerabilities
/iterate:sync                  # Update specs with changes
```

### Monthly
```bash
/versioning:bump patch         # Bug fixes and improvements
/deployment:validate           # Health check production
```

### Per Feature
```bash
/planning:add-feature "new feature name"
/iterate:tasks spec-XXX
/quality:test
/deployment:deploy
```

---

**Result**: Full-stack AI SaaS built in ~2 weeks using:
- **80% plugins** (infrastructure, auth, AI, payments)
- **20% custom code** (business logic, templates, brand voice)
- **0% hardcoded secrets** (all via Doppler/env)

This demonstrates the BUILD-GUIDE pattern scales from simple apps to complex B2B SaaS.

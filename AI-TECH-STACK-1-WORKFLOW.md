# AI Tech Stack 1 - Complete Development Workflow

**Auto-generated from Airtable** | Last Updated: 2025-11-11

## Stack Overview

**Description**: Vercel AI SDK with OpenRouter for multi-provider model access and remote HTTP MCP servers. Uses Next.js for frontend chat, FastAPI for backend APIs. Best for: cost-optimized interactive chat with tool calling. Works with: OpenRouter, remote MCP. NOT compatible with: Claude Agent SDK sub-agents.

**Tech Stack Components**:
- **Frontend**: Next.js (App Router, React Server Components)
- **Backend**: FastAPI (Python async API)
- **Database**: Supabase (PostgreSQL + Auth + Storage + Realtime)
- **AI Framework**: Vercel AI SDK + OpenRouter (multi-provider model access)
- **Memory**: Mem0 Platform (conversational memory)
- **Payments**: Stripe (optional)
- **Auth**: Supabase Auth

**Use Cases**: Customer Support Chatbots, Personal Assistant Agents, E-commerce Recommendations, Sales/Marketing Automation, Education/Tutoring, Translation Services

---

## Prerequisites

Before starting, ensure you have:
- Node.js 18+ and pnpm installed
- Python 3.11+ installed
- GitHub account and `gh` CLI installed
- Required API keys:
  - `ANTHROPIC_API_KEY`
  - `OPENROUTER_API_KEY`
  - `SUPABASE_URL` and `SUPABASE_ANON_KEY`
  - `MEM0_API_KEY`
  - `STRIPE_SECRET_KEY` (if using payments)

---

## Phase 1: Foundation & Project Initialization (15-20 minutes)

### 1.1 Initial Setup (Dev Lifecycle)

```bash
# Detect and validate environment
/foundation:env-check

# Initialize project structure
cd ~/Projects
mkdir my-ai-app && cd my-ai-app

# Initialize git
git init
```

### 1.2 Tech Stack Initialization (Tech-Specific Plugins)

```bash
# Initialize Next.js frontend with design system
/nextjs-frontend:init

# Initialize FastAPI backend
/fastapi-backend:init

# Initialize Supabase with database setup
/supabase:init

# Initialize Vercel AI SDK with OpenRouter
/vercel-ai-sdk:new-app

# Configure OpenRouter for multi-model access
/openrouter:init

# Initialize Mem0 Platform for memory
/mem0:init-platform
```

### 1.3 Environment Configuration (Dev Lifecycle)

```bash
# Set up environment variables
/foundation:env-vars setup

# Configure required secrets:
# - OPENROUTER_API_KEY
# - SUPABASE_URL
# - SUPABASE_ANON_KEY
# - MEM0_API_KEY
```

### 1.4 GitHub Repository Setup (Dev Lifecycle)

```bash
# Initialize GitHub repo with templates
/foundation:github-init my-ai-app --private

# This sets up:
# - Branch protection
# - Issue templates
# - PR templates
# - Security scanning
```

---

## Phase 2: Planning & Architecture (20-30 minutes)

### 2.1 Requirements Gathering (Dev Lifecycle)

```bash
# Interactive wizard for comprehensive requirements
/planning:wizard

# Or create individual feature specs
/planning:add-feature "AI chat interface with streaming responses"
/planning:add-feature "User authentication and profiles"
/planning:add-feature "Conversation history with Mem0"
```

### 2.2 Architecture Design (Dev Lifecycle)

```bash
# Create system architecture
/planning:architecture create chat-architecture

# Document key decisions
/planning:decide "Use OpenRouter for cost-optimized multi-model access"
/planning:decide "Use Mem0 Platform for managed conversation memory"
/planning:decide "Deploy frontend to Vercel, backend to Railway"
```

### 2.3 Database Schema Design (Tech-Specific)

```bash
# Create database schema for chat app
/supabase:create-schema chat

# Example tables:
# - users (managed by Supabase Auth)
# - conversations
# - messages
# - user_preferences
```

---

## Phase 3: Database & Auth Setup (15-20 minutes)

### 3.1 Deploy Database Schema (Tech-Specific)

```bash
# Deploy migrations to Supabase
/supabase:deploy-migration

# Generate TypeScript types
/supabase:generate-types
```

### 3.2 Configure Row Level Security (Tech-Specific)

```bash
# Add RLS policies for data security
/supabase:add-rls

# Ensures:
# - Users can only see their own conversations
# - Proper access control
# - Data isolation
```

### 3.3 Set Up Authentication (Tech-Specific)

```bash
# Integrate Supabase Auth into Next.js
/supabase:add-auth

# Configure auth providers:
# - Email/Password
# - Google OAuth (optional)
# - GitHub OAuth (optional)
```

---

## Phase 4: Core Implementation (Variable - depends on features)

### 4.1 For Each Feature

```bash
# Example: Building the chat interface

# Step 1: Create feature spec (if not done in Phase 2)
/planning:add-feature "Real-time chat with AI streaming"

# Step 2: Layer the tasks for parallel execution
/iterate:tasks F001

# This creates: specs/F001/layered-tasks.md
# L0: Infrastructure (AI provider setup, streaming config)
# L1: Core components (ChatWindow, MessageList, InputBox)
# L2: Features (streaming UI, conversation persistence)
# L3: Integration (wire everything together)
```

### 4.2 Build Layer by Layer

#### L0: Infrastructure Layer

```bash
# Configure AI providers
/vercel-ai-sdk:add-provider openrouter

# Set up model routing
/openrouter:add-model-routing

# Configure Mem0 memory
/mem0:add-conversation-memory
```

#### L1: Core Components Layer

```bash
# Frontend components (can run in parallel)
/nextjs-frontend:add-component ChatWindow
/nextjs-frontend:add-component MessageList
/nextjs-frontend:add-component InputBox

# Backend API endpoints (can run in parallel)
/fastapi-backend:add-endpoint "POST /api/chat"
/fastapi-backend:add-endpoint "GET /api/conversations"
/fastapi-backend:add-endpoint "GET /api/conversations/{id}/messages"
```

#### L2: Features Layer

```bash
# Add streaming support
/vercel-ai-sdk:add-streaming

# Integrate Supabase for data persistence
/nextjs-frontend:integrate-supabase
/fastapi-backend:setup-database

# Add realtime updates
/supabase:add-realtime
```

#### L3: Integration Layer

```bash
# Wire everything together
/nextjs-frontend:add-page chat

# Sync implementation with specs
/iterate:sync F001
```

### 4.3 Additional Features (Optional)

```bash
# Payments integration
/payments:init
/payments:add-subscriptions

# Advanced AI features
/vercel-ai-sdk:add-tools        # Tool calling
/vercel-ai-sdk:add-ui-features  # Generative UI
```

---

## Phase 5: Quality Assurance (30-45 minutes)

### 5.1 Code Validation (Dev Lifecycle)

```bash
# Validate implementation against specs
/quality:validate-code F001

# This checks:
# - All spec requirements implemented
# - Security best practices followed
# - No hardcoded secrets
# - Proper error handling
```

### 5.2 Testing (Dev Lifecycle)

```bash
# Generate and run comprehensive tests
/testing:generate-tests

# Run full test suite
/quality:test

# Includes:
# - Frontend component tests (Jest + React Testing Library)
# - API tests (Newman/Postman)
# - E2E tests (Playwright)
# - Visual regression tests
```

### 5.3 Security Scanning (Dev Lifecycle)

```bash
# Run security scans
/security:security

# Checks:
# - Dependency vulnerabilities
# - Secret detection
# - OWASP compliance
# - RLS policy validation
```

### 5.4 Performance Analysis (Dev Lifecycle)

```bash
# Analyze performance
/quality:performance

# Measures:
# - Page load times
# - API response times
# - Database query performance
# - Bundle sizes
```

---

## Phase 6: Deployment (20-30 minutes)

### 6.1 Pre-Deployment Preparation (Dev Lifecycle)

```bash
# Run pre-flight checks
/deployment:prepare

# Validates:
# - Environment variables set
# - Build succeeds
# - Tests pass
# - No security issues
```

### 6.2 CI/CD Setup (Dev Lifecycle)

```bash
# Configure GitHub Actions for automated deployment
/deployment:setup-cicd

# Sets up:
# - Automated testing on PR
# - Automated deployment on merge
# - Environment-specific deployments
```

### 6.3 Deploy to Production (Dev Lifecycle)

```bash
# Auto-detects platforms and deploys
/deployment:deploy

# Deploys:
# - Frontend → Vercel (Next.js optimized)
# - Backend → Railway (FastAPI with auto-scaling)
# - Database → Supabase (already deployed)
```

### 6.4 Post-Deployment Validation (Dev Lifecycle)

```bash
# Validate deployment health
/deployment:validate <deployment-url>

# Checks:
# - URLs accessible
# - Health endpoints responding
# - Database connections working
# - API endpoints functional
```

### 6.5 Monitoring Setup (Dev Lifecycle)

```bash
# Set up production monitoring
/deployment:setup-monitoring sentry

# Configures:
# - Error tracking (Sentry)
# - Performance monitoring
# - Real-time alerts
# - Log aggregation
```

---

## Phase 7: Versioning & Release (15-20 minutes)

### 7.1 Version Management (Dev Lifecycle)

```bash
# Set up semantic versioning
/versioning:setup typescript

# Analyze for breaking changes
/versioning:analyze-breaking

# Bump version and create tag
/versioning:bump minor

# Generate release notes
/versioning:generate-release-notes
```

### 7.2 Deployment Tracking (Dev Lifecycle)

```bash
# Record deployment
/versioning:record-deployment production https://my-ai-app.vercel.app
```

---

## Phase 8: Iteration & Maintenance

### 8.1 Feature Enhancements (Dev Lifecycle)

```bash
# Enhance existing features
/iterate:enhance chat-interface

# This will:
# 1. Analyze current implementation
# 2. Identify enhancement opportunities
# 3. Layer tasks for parallel execution
# 4. Guide systematic improvements
```

### 8.2 Code Refactoring (Dev Lifecycle)

```bash
# Refactor for quality
/iterate:refactor src/components/ChatWindow.tsx

# Improves:
# - Code structure
# - Maintainability
# - Performance
# - Without changing functionality
```

### 8.3 Feedback Integration (Dev Lifecycle)

```bash
# Adjust based on user feedback
/iterate:adjust "Users want darker theme option"

# Makes targeted changes based on requirements
```

---

## Complete Command Reference

### Foundation Phase
- `/foundation:env-check` - Validate environment
- `/foundation:env-vars setup` - Configure environment variables
- `/foundation:github-init` - Initialize GitHub repository
- `/nextjs-frontend:init` - Set up Next.js with design system
- `/fastapi-backend:init` - Set up FastAPI backend
- `/supabase:init` - Set up Supabase
- `/vercel-ai-sdk:new-app` - Initialize Vercel AI SDK
- `/openrouter:init` - Configure OpenRouter
- `/mem0:init-platform` - Set up Mem0 Platform

### Planning Phase
- `/planning:wizard` - Interactive requirements gathering
- `/planning:add-feature` - Create feature specifications
- `/planning:architecture` - Design system architecture
- `/planning:decide` - Document architecture decisions
- `/supabase:create-schema` - Design database schema

### Database Phase
- `/supabase:deploy-migration` - Deploy database schema
- `/supabase:generate-types` - Generate TypeScript types
- `/supabase:add-rls` - Configure Row Level Security
- `/supabase:add-auth` - Set up authentication

### Implementation Phase
- `/iterate:tasks` - Layer tasks for parallel execution
- `/vercel-ai-sdk:add-provider` - Configure AI provider
- `/openrouter:add-model-routing` - Set up model routing
- `/mem0:add-conversation-memory` - Add memory layer
- `/nextjs-frontend:add-component` - Create React components
- `/nextjs-frontend:add-page` - Create Next.js pages
- `/fastapi-backend:add-endpoint` - Create API endpoints
- `/vercel-ai-sdk:add-streaming` - Enable streaming responses
- `/supabase:add-realtime` - Add realtime features
- `/iterate:sync` - Sync implementation with specs

### Quality Phase
- `/quality:validate-code` - Validate implementation
- `/testing:generate-tests` - Generate test suites
- `/quality:test` - Run comprehensive tests
- `/security:security` - Security scanning
- `/quality:performance` - Performance analysis

### Deployment Phase
- `/deployment:prepare` - Pre-flight checks
- `/deployment:setup-cicd` - Configure CI/CD
- `/deployment:deploy` - Deploy to production
- `/deployment:validate` - Validate deployment
- `/deployment:setup-monitoring` - Set up monitoring

### Versioning Phase
- `/versioning:setup` - Initialize versioning
- `/versioning:analyze-breaking` - Check breaking changes
- `/versioning:bump` - Increment version
- `/versioning:generate-release-notes` - Create release notes
- `/versioning:record-deployment` - Track deployments

### Iteration Phase
- `/iterate:enhance` - Enhance features
- `/iterate:refactor` - Refactor code
- `/iterate:adjust` - Adjust based on feedback

---

## Estimated Timeline

| Phase | Time | Parallel? |
|-------|------|-----------|
| Foundation | 15-20 min | Partially |
| Planning | 20-30 min | Yes |
| Database Setup | 15-20 min | No |
| Implementation (per feature) | 30-60 min | Yes (within layers) |
| Quality | 30-45 min | Yes |
| Deployment | 20-30 min | No |
| Versioning | 15-20 min | No |

**Total for MVP**: 2-3 hours (with 2-3 core features)

---

## Critical Rules

### 🚨 ALWAYS: Spec → Layer → Build

**NEVER build features randomly!**

```bash
# ❌ WRONG
/nextjs-frontend:add-component Button  # Random creation = technical debt

# ✅ CORRECT
/planning:add-feature "Improved button system"
/iterate:tasks F001
# Build layer by layer following layered-tasks.md
```

### 🚨 ALWAYS: Layer Before Building

**Every feature must be layered first:**

1. Is this new or modification?
2. Quick layer the tasks → `/iterate:tasks F00X` (⚡ <2 minutes)
3. Build layer by layer (L0 → L1 → L2 → L3)
4. Sync after each layer → `/iterate:sync F00X`

### 🚨 ALWAYS: Validate Before Deployment

**Never deploy without validation:**

```bash
/quality:validate-code F001
/quality:test
/security:security
# Only then:
/deployment:deploy
```

---

## Tech Stack Integration Points

### When to Use Tech-Specific Commands

**Foundation Phase**: Init commands (setup frameworks)
**Planning Phase**: Schema design (database structure)
**Implementation Phase**: Features (components, endpoints, integrations)
**Quality Phase**: Tech-specific tests (component tests, API tests)
**Deployment Phase**: Platform-specific deployment (Vercel, Railway)

### When to Use Dev Lifecycle Commands

**Always**: Use dev lifecycle commands to orchestrate the process
**Planning**: Specs, architecture, decisions
**Iteration**: Task layering, syncing, refactoring
**Quality**: Validation, testing, security scanning
**Deployment**: Platform detection, CI/CD, monitoring
**Versioning**: Version bumps, release notes, deployment tracking

---

## Next Steps

1. **Start Your Project**:
   ```bash
   cd ~/Projects
   mkdir my-ai-app && cd my-ai-app
   /foundation:env-check
   ```

2. **Follow This Workflow**: Execute commands in order, phase by phase

3. **Layer Every Feature**: Always use `/iterate:tasks` before building

4. **Validate Frequently**: Run `/iterate:sync` after each layer

5. **Deploy Confidently**: Follow the complete deployment phase

---

**This workflow was auto-generated from Airtable on 2025-11-11**

To regenerate with latest Airtable data:
```bash
/lifecycle:generate-workflow "AI Tech Stack 1"
```

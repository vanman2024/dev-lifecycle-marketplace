# Complete Dev Lifecycle Command Reference

This document shows ALL commands from the dev-lifecycle-marketplace in execution order.
Open multiple terminals and run sections as needed.

## 🎯 How This Works

**Dev Lifecycle (tech-agnostic)** + **Tech Stack Plugins (tech-specific)** = Complete Application

This workflow shows:
1. **Dev lifecycle commands** (foundation, planning, iterate, quality, deployment)
2. **🔧 Tech Stack Integration Points** - Where to run tech-specific plugin commands
3. **How they work together** - Dev lifecycle orchestrates, tech plugins implement

**Example:** AI Tech Stack 1 (Next.js + FastAPI + Supabase + Vercel AI SDK + OpenRouter)
- Foundation creates structure → Next.js/FastAPI plugins init frameworks
- Planning designs architecture → Supabase plugin creates schema
- Planning creates specs → Next.js/FastAPI plugins build features
- Quality validates → Test plugins run tests
- Deployment ships → Deployment plugin deploys to platforms

**The dev lifecycle doesn't care WHAT you build with, only HOW you build it.**

---

## PHASE 1: FOUNDATION - Project Initialization

**Purpose:** Set up project structure, environment, and base configuration

### Commands:

```bash
# 1.1 Detect existing project or start fresh
/foundation:detect [project-path]

# 1.2 Initialize/fix project structure
/foundation:init-structure [project-path]
# Creates: backend/, frontend/, docs/, scripts/, tests/

# 1.3 Validate structure compliance
/foundation:validate-structure [project-path]
# Returns: Compliance score (0-100%)

# 1.4 Detect tech stack from codebase
/foundation:detect [project-path]
# Analyzes: package.json, requirements.txt, configs
# Populates: .claude/project.json

# 1.5 Check environment prerequisites
/foundation:env-check [--fix]
# Verifies: Node, Python, Docker, platform CLIs

# 1.6 Manage environment variables
/foundation:env-vars list
/foundation:env-vars check
/foundation:env-vars add KEY VALUE

# 1.7 Setup MCP servers (optional)
/foundation:mcp-manage add <server-name>
/foundation:mcp-manage install <server-name>

# 1.8 Initialize GitHub repository (optional)
/foundation:github-init [repo-name] [--public|--private]
```

**Outputs:**
- Standardized directory structure
- .claude/project.json with tech stack info
- .gitignore, .env.example files
- Git repository initialized

---

## 🔧 TECH STACK INTEGRATION POINT #1: Framework Setup

**After PHASE 1 foundation is complete, initialize your tech-specific frameworks.**

**Tech Stack Example:** AI Tech Stack 1 (Next.js + FastAPI + Supabase + Vercel AI SDK + OpenRouter)

### Frontend Setup:
```bash
/nextjs-frontend:init
# Installs: Next.js 14, TypeScript, Tailwind, shadcn/ui
# Creates: app/, components/, hooks/, utils/
# Configures: tsconfig.json, tailwind.config.js, next.config.js
```

### Backend Setup (if applicable):
```bash
/fastapi-backend:init
# Installs: FastAPI, Uvicorn, Pydantic
# Creates: src/, routes/, models/, services/
# Configures: main.py, requirements.txt
```

### Database Setup (if applicable):
```bash
/supabase:init
# Links: Existing Supabase project OR creates new
# Generates: TypeScript types from database schema
# Creates: supabase/ directory with migrations
```

### AI Framework Setup (if applicable):
```bash
# For Vercel AI SDK projects:
/vercel-ai-sdk:new-ai-app
# OR add to existing Next.js project:
/nextjs-frontend:integrate-ai-sdk

# For OpenRouter multi-provider access:
/openrouter:init

# For memory layer:
/mem0:init
/mem0:add-user-memory
```

**This integration happens BEFORE planning, so planning knows what tech stack to optimize for.**

---

## PHASE 2: PLANNING - Define Requirements & Architecture

**Purpose:** Capture requirements, break down features, design system architecture

### Commands:

```bash
# 2.1 Interactive requirements gathering
/planning:wizard [--auto-continue]
# Multimodal input: text, images, docs, URLs
# Generates: Comprehensive requirements doc

# 2.2 Create project from massive description (bulk)
/planning:init-project "<full project description>"
# Breaks down into: F001, F002, F003... features
# Parallel spec generation

# 2.3 Add individual features (incremental)
/planning:add-feature "<feature description>"
# Creates: specs/F00X/spec.md, tasks.md, ADR

# 2.4 Analyze existing specs (if project has specs/)
/planning:analyze-project
# Returns: Completeness %, quality issues, gaps

# 2.5 Update existing features
/planning:update-feature F001 "<changes>"
# Updates: spec, tasks, roadmap, architecture

# 2.6 Create/manage specifications
/planning:spec create "<feature-name>"
/planning:spec list
/planning:spec validate F001

# 2.7 Design system architecture
/planning:architecture design
/planning:architecture validate
# Creates: docs/architecture/ with Mermaid diagrams

# 2.8 Document technical decisions
/planning:decide "<decision-title>"
# Creates: docs/architecture/decisions/ADR-XXX.md

# 2.9 Create project roadmap
/planning:roadmap [timeframe]
# Creates: docs/ROADMAP.md with Gantt chart

# 2.10 Clarify ambiguous requirements
/planning:clarify [spec-name or topic]
# Interactive Q&A to resolve uncertainty

# 2.11 Capture development notes
/planning:notes [note-topic]
# Journal-style development notes

# 2.12 View documentation relationships
/planning:view-docs
# Launches: Visual documentation registry viewer

# 2.13 Sync documentation to memory
/planning:doc-sync [project-name]
# Uses Mem0 to track relationships
```

**Outputs:**
- specs/F00X/ directories with spec.md, tasks.md
- docs/architecture/ with system design
- docs/architecture/decisions/ with ADRs
- docs/ROADMAP.md with timeline
- Mem0 memory storage of relationships

---

## 🔧 TECH STACK INTEGRATION POINT #2: Database Schema Design

**After planning architecture, design and deploy your database schema.**

### Database Schema (for database-backed projects):
```bash
# Create database schema based on architecture docs
/supabase:create-schema
# Uses: supabase-architect agent
# Analyzes: docs/architecture/ to design tables
# Creates: supabase/migrations/YYYYMMDDHHMMSS_*.sql
# Optimizes: Indexes, relationships, RLS policies

# Validate schema before applying
/supabase:validate-schema
# Checks: SQL syntax, naming conventions, security

# Apply migrations to database
/supabase:deploy-migration
# Applies: Migrations to Supabase project
# Generates: TypeScript types from schema
# Output: types/supabase.ts
```

### Add Authentication (if applicable):
```bash
/supabase:add-auth
# Configures: Email/password, OAuth providers
# Creates: Auth tables, RLS policies

# For Next.js integration:
/nextjs-frontend:integrate-supabase
# Installs: @supabase/auth-helpers-nextjs
# Creates: lib/supabase/client.ts, middleware.ts
```

### Add AI Capabilities (if applicable):
```bash
# Setup pgvector for embeddings
/supabase:setup-pgvector
# Enables: pgvector extension
# Creates: Embeddings tables with vector columns

# Setup AI features
/supabase:setup-ai
# Configures: Vector search, hybrid search
# Creates: Functions for similarity search
```

**Database is now ready. Planning commands read from this schema for implementation planning.**

---

## 🔧 TECH STACK INTEGRATION POINT #3: Build Core Features

**Between planning and task layering, build your core features using tech-specific plugins.**

### Frontend Components & Pages:
```bash
# Add pages based on architecture
/nextjs-frontend:add-page dashboard
/nextjs-frontend:add-page profile
/nextjs-frontend:add-page chat

# Add reusable components
/nextjs-frontend:add-component Button
/nextjs-frontend:add-component Card
/nextjs-frontend:add-component ChatMessage

# Search for shadcn/ui components
/nextjs-frontend:search-components "dialog"
# Then add them based on search results
```

### Backend API Endpoints:
```bash
# Add REST API endpoints
/fastapi-backend:add-endpoint "GET /api/users"
/fastapi-backend:add-endpoint "POST /api/chat"
/fastapi-backend:add-endpoint "GET /api/conversations"

# Add authentication
/fastapi-backend:add-auth
# Configures: JWT, OAuth, API keys

# Setup database integration
/fastapi-backend:setup-database
# Configures: SQLAlchemy, async connections
```

### AI Features:
```bash
# Add chat functionality with streaming
/nextjs-frontend:integrate-ai-sdk
# OR
/vercel-ai-sdk:add-chat
# Installs: AI SDK, configures streaming

# Add AI provider integration
/vercel-ai-sdk:add-provider openrouter
# OR
/openrouter:add-vercel-ai-sdk

# Add AI tools/functions
/vercel-ai-sdk:add-tools
# Creates: Tool definitions for function calling
```

### RAG Pipeline (if applicable):
```bash
/rag-pipeline:init
/rag-pipeline:build-ingestion
/rag-pipeline:build-retrieval
/rag-pipeline:add-vector-db
```

### Memory Layer (if applicable):
```bash
/mem0:init-platform
# OR
/mem0:init-oss
# Configures: User memory, conversation memory
```

**Features are now built. Task layering will analyze what's already implemented.**

---

## PHASE 3: ITERATE - Task Management & Adjustments

**Purpose:** Layer tasks, sync specs with code, refactor, enhance

## 🚨 CRITICAL RULE: ALWAYS LAYER BEFORE BUILDING

**NEVER** build features without this process:

1. **Decide: Is this a new feature or modification?**
   - New feature? → `/planning:add-feature`
   - Modify existing? → `/iterate:adjust` or `/iterate:enhance`

2. **Layer the tasks** → `/iterate:tasks F00X`
   - Creates layered-tasks.md with dependencies
   - L0 (infrastructure) → L1 (core) → L2 (features) → L3 (integration)

3. **Build layer by layer**
   - Follow layered-tasks.md order
   - Complete L0 before L1, L1 before L2, etc.

4. **Sync after each layer** → `/iterate:sync F00X`

**Example - User says "Frontend needs improvement":**

```bash
# ❌ WRONG - Just start building
/nextjs-frontend:add-component Button  # Creates mess!

# ✅ CORRECT - Spec → Layer → Build
/planning:add-feature "Improve frontend UX with design system"
# Creates: specs/F00X/spec.md, tasks.md

/iterate:tasks F00X
# Creates: specs/F00X/layered-tasks.md
# L0: Setup Tailwind theme, design tokens
# L1: Core components (Button, Card, Input)
# L2: Composite components (ChatWindow, Sidebar)
# L3: Apply to all pages, wire together

# NOW build layer by layer:
# L0 first:
/nextjs-frontend:add-component ThemeProvider

# L1 second:
/nextjs-frontend:add-component Button
/nextjs-frontend:add-component Card

# L2 third:
/nextjs-frontend:add-component ChatWindow

# L3 fourth:
/nextjs-frontend:add-page chat  # Uses all components
```

**This prevents:**
- Random component creation
- Missing dependencies
- Unorganized code
- Technical debt

**This ensures:**
- Structured development
- Proper dependencies
- Reusable components
- Clean architecture

### Commands:

```bash
# 3.1 Layer tasks for parallel execution
/iterate:tasks F001
# Analyzes: tasks.md dependencies
# Creates: specs/F001/layered-tasks.md
# Layers: L0 (infrastructure) → L3 (integration)
# Assigns: Complexity ratings, agent assignments

# 3.2 Sync specs with implementation
/iterate:sync [feature-area]
# Compares: Specs vs actual code
# Updates: Task completion status, docs

# 3.3 Refactor code for quality
/iterate:refactor <file-or-directory>
# Improves: Structure, maintainability
# No functionality changes

# 3.4 Enhance existing features
/iterate:enhance <feature-name>
# Adds: Improvements, optimizations

# 3.5 Adjust based on feedback
/iterate:adjust "<feedback-or-requirements>"
# Makes: Targeted code changes
```

**Outputs:**
- specs/F00X/layered-tasks.md with execution strategy
- Updated task completion status
- Refactored code
- Enhanced features

---

## PHASE 4: QUALITY - Testing & Validation

**Purpose:** Generate tests, validate code, scan security

### Commands:

```bash
# 4.1 Generate comprehensive test suites
/testing:generate-tests [project-path]
# Reads: package.json for test config
# Generates: Jest, RTL, Playwright tests
# Based on: Project structure, detected frameworks

# 4.2 Run all tests
/quality:test [test-type]
# test-type: newman, playwright, all
# Runs: API tests (Newman), E2E tests (Playwright)
# Outputs: Test results, coverage

# 4.3 Validate code against spec
/quality:validate-code F001 [--generate-tests]
# Reviews: Implementation vs requirements
# Checks: Security rules, test coverage
# Generates: Test recommendations

# 4.4 Validate task completion
/quality:validate-tasks F001
# Verifies: Tasks marked complete have actual work
# Checks: Git commits, file changes

# 4.5 Performance analysis
/quality:performance [analysis-type]
# Analyzes: Bottlenecks, optimization opportunities

# 4.6 Run security scans
/security:security [scan-type]
# Scans: Vulnerabilities, secrets, dependencies
# Checks: npm audit, safety, OWASP compliance

# 4.7 Setup git hooks for security
/security:hooks-setup [project-path]
# Installs: Pre-commit hooks, secret scanning
# Creates: GitHub Actions security workflow
```

**Outputs:**
- Complete test suites in proper directories
- Test results and coverage reports
- Code validation reports
- Security scan results
- Git hooks installed

---

## PHASE 5: VERSIONING - Release Management (Optional)

**Purpose:** Manage versions, changelogs, releases

### Commands:

```bash
# 5.1 Setup versioning system
/versioning:setup [python|typescript|javascript]
# Creates: Version files, templates

# 5.2 Get version info
/versioning:info [status|validate|history]
# Shows: Current version, validation, history

# 5.3 Analyze breaking changes
/versioning:analyze-breaking [--from=tag] [--detailed]
# Detects: API/schema breaking changes
# Recommends: Version bump type

# 5.4 Bump version
/versioning:bump [major|minor|patch] [--dry-run]
# Updates: Version files, creates changelog
# Creates: Git tag

# 5.5 Create pre-release versions
/versioning:prerelease [alpha|beta|rc] [--dry-run]
# Creates: Pre-release versions

# 5.6 Generate release notes
/versioning:generate-release-notes [version] [--output=FILE]
# AI-powered: User-friendly release notes
# Includes: Migration guides

# 5.7 Approval workflow
/versioning:approve-release [version]
# Multi-stakeholder: Approval gates

# 5.8 Record deployment
/versioning:record-deployment <environment> <url> [--version=X.Y.Z]
# Tracks: Version → environment → URL

# 5.9 Rollback version
/versioning:rollback [version]
# Removes: Tags, restores previous version
```

**Outputs:**
- Version tags
- CHANGELOG.md
- Release notes
- Deployment history

---

## PHASE 6: DEPLOYMENT - Ship to Production

**Purpose:** Deploy to platforms, setup CI/CD, validate deployments

### Commands:

```bash
# 6.1 Prepare project for deployment
/deployment:prepare [project-path]
# Checks: Dependencies, build tools, auth
# Links: To deployment platform
# Validates: Environment variables

# 6.2 Setup CI/CD pipeline
/deployment:setup-cicd [platform] [project-path]
# Platforms: vercel, digitalocean, railway
# Configures: GitHub secrets via gh CLI
# Generates: GitHub Actions workflow
# Commits: .github/workflows/deploy.yml

# 6.3 Complete deployment orchestration
/deployment:deploy [project-path]
# Runs: prepare → setup-cicd → deploy → validate
# Full automation: Zero to deployed with CI/CD

# 6.4 Validate deployment
/deployment:validate <deployment-url>
# Health checks: URL, endpoints, SSL, performance

# 6.5 Canary deployment
/deployment:canary-deploy [deployment-target]
# Progressive: Traffic rollout
# Monitoring: Auto-rollback on errors

# 6.6 Blue-green deployment
/deployment:blue-green-deploy [project-path]
# Zero-downtime: Parallel environment swap

# 6.7 Setup automated rollback
/deployment:rollback-automated $ARGUMENTS
# Monitoring: Error thresholds
# Automatic: Rollback triggers

# 6.8 Manual rollback
/deployment:rollback [deployment-id-or-version]
# Platform-specific: Rollback procedures

# 6.9 Setup monitoring
/deployment:setup-monitoring [monitoring-platform]
# Platforms: sentry, datadog
# Integration: Error tracking, APM, alerts

# 6.10 Setup feature flags
/deployment:feature-flags-setup [launchdarkly|flagsmith|split]
# Integration: Feature flag services
# SDK setup: LaunchDarkly, Flagsmith

# 6.11 Verify feature flags
/deployment:verify-feature-flags [project-path]
# Pre-deployment: Flag validation

# 6.12 Capture performance baseline
/deployment:capture-baseline <deployment-url>
# Baselines: Lighthouse, API latency
# Monitoring: Regression detection
```

**Outputs:**
- Live deployment URL
- GitHub Actions CI/CD workflow
- Monitoring dashboards
- Deployment health reports
- Automated rollback configured

---

## PHASE 7: SUPERVISOR - Multi-Agent Coordination (Advanced)

**Purpose:** Orchestrate parallel development with git worktrees

### Commands:

```bash
# 7.1 Initialize worktrees for parallel work
/supervisor:init <spec-name> | --all | --bulk
# Creates: Git worktrees per agent
# Based on: layered-tasks.md assignments

# 7.2 Verify agent setup
/supervisor:start <spec-name>
# Checks: Worktree readiness
# Validates: Task assignments, git state

# 7.3 Monitor progress during development
/supervisor:mid <spec-name> [--test]
# Tracks: Agent progress, completion %
# Identifies: Stuck/blocked agents
# Optional: Run tests in worktrees

# 7.4 Validate completion before PR
/supervisor:end <spec-name>
# Validates: All tasks complete
# Checks: Tests pass, no uncommitted work
# Generates: PR commands
```

**Outputs:**
- Git worktrees for parallel development
- Progress monitoring
- PR generation commands

---

## WORKFLOW EXECUTION STRATEGIES

### Strategy 1: Sequential (Single Terminal)
Run commands one at a time in order:
```
Terminal 1:
  PHASE 1 → PHASE 2 → PHASE 3 → PHASE 4 → PHASE 5 → PHASE 6
```

### Strategy 2: Parallel Phases (Multiple Terminals)
Open 6 terminals, one per phase:
```
Terminal 1: PHASE 1 (Foundation)
Terminal 2: PHASE 2 (Planning)
Terminal 3: PHASE 3 (Iterate)
Terminal 4: PHASE 4 (Quality)
Terminal 5: PHASE 5 (Versioning)
Terminal 6: PHASE 6 (Deployment)
```
Run next phase when previous completes.

### Strategy 3: Parallel Within Phase (Power Users)
Within a phase, run independent commands in parallel:
```
# During PHASE 2 (Planning):
Terminal 1: /planning:add-feature "auth"
Terminal 2: /planning:add-feature "dashboard"
Terminal 3: /planning:add-feature "api"
Terminal 4: /planning:architecture design
```

### Strategy 4: Feature-Based (Focused Development)
Complete all phases for one feature before moving to next:
```
Feature F001:
  /planning:add-feature → /iterate:tasks → /quality:validate-code → /deployment:deploy

Feature F002:
  /planning:add-feature → /iterate:tasks → /quality:validate-code → /deployment:deploy
```

---

## COMMAND OUTPUTS & DEPENDENCIES

### Foundation Output → Planning Input
- `.claude/project.json` (tech stack) → Used by planning to recommend patterns
- Directory structure → Planning knows where to create specs/

### Planning Output → Iterate Input
- `specs/F00X/tasks.md` → Iterate layers these tasks
- Architecture docs → Iterate uses for refactoring context

### Planning Output → Quality Input
- `specs/F00X/spec.md` → Quality validates against this
- Architecture docs → Quality checks compliance

### Quality Output → Deployment Input
- Test results → Deployment requires passing tests
- Coverage reports → Deployment health metrics

### All Phases → Versioning Input
- Git commits → Versioning generates changelogs
- Breaking changes → Versioning recommends version bump

---

## MINIMAL WORKFLOW (MVP)

**If you want the absolute minimum to get something deployed:**

```bash
# 1. Structure
/foundation:init-structure

# 2. Requirements
/planning:add-feature "MVP feature"

# 3. Tasks
/iterate:tasks F001

# 4. [BUILD THE CODE MANUALLY OR WITH TECH-SPECIFIC PLUGINS]

# 5. Test
/quality:test

# 6. Deploy
/deployment:deploy
```

---

## COMPLETE WORKFLOW (Full Lifecycle)

**For production-ready, well-documented projects:**

```bash
# FOUNDATION
/foundation:init-structure
/foundation:detect
/foundation:env-check
/foundation:github-init

# PLANNING
/planning:wizard
/planning:init-project "<description>"
/planning:architecture design
/planning:decide "Key decisions"
/planning:roadmap

# ITERATE
/iterate:tasks F001
/iterate:tasks F002

# [IMPLEMENTATION WITH TECH-SPECIFIC PLUGINS]

# QUALITY
/testing:generate-tests
/quality:test
/quality:validate-code F001
/security:security

# VERSIONING
/versioning:setup
/versioning:bump minor

# DEPLOYMENT
/deployment:prepare
/deployment:setup-cicd
/deployment:deploy
/deployment:validate <url>
/deployment:setup-monitoring
```

---

## NOTES

- **Tech-agnostic:** These commands work for ANY project type
- **Tech-specific plugins:** Use nextjs-frontend, fastapi-backend, etc. for actual code generation
- **No automation between commands:** Each command runs independently
- **Context carries forward:** Later commands read outputs from earlier commands
- **Parallel execution:** Many commands can run simultaneously if they don't depend on each other
- **Idempotent:** Most commands can be re-run safely

---

## TECH-SPECIFIC PLUGINS (Not Part of Dev Lifecycle)

These are separate plugins that handle specific frameworks:

### Next.js Frontend
```bash
/nextjs-frontend:init
/nextjs-frontend:add-page <page-name>
/nextjs-frontend:add-component <component-name>
/nextjs-frontend:integrate-supabase
/nextjs-frontend:integrate-ai-sdk
```

### FastAPI Backend
```bash
/fastapi-backend:init
/fastapi-backend:add-endpoint "<endpoint>"
/fastapi-backend:setup-database
/fastapi-backend:add-auth
```

### Supabase
```bash
/supabase:init
/supabase:create-schema
/supabase:deploy-migration
/supabase:add-auth
/supabase:add-rls
```

### FastMCP
```bash
/fastmcp:new-server <server-name>
/fastmcp:add-components [component-type]
/fastmcp:test
```

### RAG Pipeline
```bash
/rag-pipeline:init
/rag-pipeline:build-ingestion
/rag-pipeline:build-retrieval
```

### Mem0
```bash
/mem0:init
/mem0:add-user-memory
/mem0:add-conversation-memory
```

---

**This document is your command reference. Open multiple terminals and execute sections as needed!**

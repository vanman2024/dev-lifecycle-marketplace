# AI Tech Stack 1 - Complete Development Workflow

**Auto-generated from Airtable** | Last Updated: 2025-11-11

## Stack Overview

**Description**: Vercel AI SDK with OpenRouter for multi-provider model access and remote HTTP MCP servers. Uses Next.js for frontend chat, FastAPI for backend APIs. Best for: cost-optimized interactive chat with tool calling. Works with: OpenRouter, remote MCP. NOT compatible with: Claude Agent SDK sub-agents.

**Use Cases**: Customer Support Chatbots, Personal Assistant Agents, E-commerce Recommendations, Sales/Marketing Automation, Education/Tutoring, Translation Services

---

## Prerequisites

Before starting, ensure you have:
- Node.js 18+ and pnpm installed
- Python 3.11+ installed
- GitHub account and `gh` CLI installed
- Required API keys (see environment setup)

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
# Initialize git worktrees for parallel agent execution based on layered tasks
/supervisor:/supervisor:init

# Create ALL project specs in one shot from massive description using parallel agents
/planning:/planning:init-project

# Initialize complete AI backend with Mem0, PostgreSQL, and async SQLAlchemy
/fastapi-backend:/fastapi-backend:init-ai-app

# Initialize FastAPI project with modern async/await setup, dependencies, and configuration
/fastapi-backend:/fastapi-backend:init

# Configure deployment for FastAPI (Docker, Railway, DigitalOcean)
/fastapi-backend:/fastapi-backend:setup-deployment

# Configure async SQLAlchemy with PostgreSQL/Supabase
/fastapi-backend:/fastapi-backend:setup-database

# Initialize Next.js 15 App Router project with AI SDK, Supabase, and shadcn/ui
/nextjs-frontend:/nextjs-frontend:init

# Install standardized git hooks (secret scanning, commit message validation, security checks)
/security:hooks-setup

# Initialize Mem0 (Platform, OSS, or MCP) - intelligent router that asks deployment mode and routes to appropriate init command
/mem0:/mem0:init

# Setup Mem0 with OpenMemory MCP server for local-first AI memory
/mem0:/mem0:init-mcp

# Setup hosted Mem0 Platform with API keys and quick configuration
/mem0:/mem0:init-platform

# Setup self-hosted Mem0 OSS with Supabase backend and pgvector
/mem0:/mem0:init-oss

# Setup semantic versioning with validation and templates for Python and TypeScript projects
/versioning:/versioning:setup

# Complete AI application setup - chains schema creation, pgvector setup, auth, realtime, and type generation for a full-stack AI app
/supabase:/supabase:init-ai-app

# Initialize Supabase in your project - sets up MCP configuration, creates .env, and prepares project for Supabase integration
/supabase:/supabase:init

# Complete AI setup - pgvector, embeddings, schemas, RLS, validation (parallel multi-agent)
/supabase:/supabase:setup-ai

# Configure pgvector for vector search - enables extension, creates embedding tables, sets up HNSW/IVFFlat indexes
/supabase:/supabase:setup-pgvector

# Validate Supabase setup - MCP connectivity, configuration, security, schema (parallel validation)
/supabase:/supabase:validate-setup

# Observability integration (Sentry, DataDog, alerts)
/deployment:/deployment:setup-monitoring

# Automatically configure CI/CD pipeline with GitHub Actions and secrets for any deployment platform (Vercel, DigitalOcean, Railway). Uses gh CLI to auto-configure repository secrets and generates platform-specific workflows.
/deployment:/deployment:setup-cicd

# Initialize feature flag infrastructure (LaunchDarkly/Flagsmith)
/deployment:/deployment:feature-flags-setup

# Complete GitHub repository initialization with gh CLI - creates repo, configures settings, branch protection, templates, and integrates with hooks-setup and CI/CD
/foundation:/foundation:github-init

# Setup Doppler secret management for scalable environment variable handling
/foundation:/foundation:doppler-setup

# Install standardized git hooks (secret scanning, commit message validation, security checks) and GitHub Actions security workflow
/foundation:/foundation:hooks-setup

# Initialize OpenRouter SDK with API key configuration, model selection, and framework integration setup
/openrouter:/openrouter:init

```

---

## Complete Command Reference

### supervisor

- `/supervisor:/supervisor:end` - Validate completion and generate PR commands before creating pull requests
- `/supervisor:/supervisor:init` - Initialize git worktrees for parallel agent execution based on layered tasks
- `/supervisor:/supervisor:start` - Verify agent setup and worktree readiness before work begins
- `/supervisor:/supervisor:mid` - Monitor agent progress and task completion during development

### planning

- `/planning:/planning:doc-sync` - Sync documentation relationships to Mem0 for intelligent tracking
- `/planning:/planning:init-project` - Create ALL project specs in one shot from massive description using parallel agents
- `/planning:/planning:wizard` - Interactive multimodal wizard for comprehensive requirements gathering and spec generation
- `/planning:/planning:clarify` - Gather clarification on ambiguous requirements, specs, or tasks through structured questions. Helps resolve uncertainty before implementation.
- `/planning:/planning:notes` - Capture technical notes and development journal
- `/planning:/planning:add-spec` - [DEPRECATED] Use /planning:add-feature instead - adds spec with similarity checking and complete planning sync
- `/planning:/planning:decide` - Create Architecture Decision Records (ADRs)
- `/planning:/planning:analyze-project` - Analyze existing project specs for completeness and identify gaps
- `/planning:/planning:architecture` - Design and document system architecture
- `/planning:/planning:spec` - Create, list, and validate specifications in specs/ directory
- `/planning:/planning:roadmap` - Create development roadmap and timeline
- `/planning:/planning:view-docs` - Launch visual documentation registry viewer
- `/planning:/planning:update-feature` - Update existing feature across roadmap, specs, and architecture docs when requirements change
- `/planning:/planning:add-feature` - Add complete feature with roadmap, spec, ADR, and architecture updates - keeps all planning docs in sync
- `/planning:/planning:consolidate-docs` - Consolidate auto-generated documentation into proper locations (specs, architecture, ADRs, contracts)

### fastapi-backend

- `/fastapi-backend:/fastapi-backend:add-testing` - Generate pytest test suite with fixtures for FastAPI endpoints
- `/fastapi-backend:/fastapi-backend:init-ai-app` - Initialize complete AI backend with Mem0, PostgreSQL, and async SQLAlchemy
- `/fastapi-backend:/fastapi-backend:validate-api` - Validate API schema, endpoints, and security
- `/fastapi-backend:/fastapi-backend:integrate-mem0` - Add Mem0 memory layer to FastAPI endpoints with user context and conversation history
- `/fastapi-backend:/fastapi-backend:init` - Initialize FastAPI project with modern async/await setup, dependencies, and configuration
- `/fastapi-backend:/fastapi-backend:add-endpoint` - Generate new API endpoint with validation and documentation
- `/fastapi-backend:/fastapi-backend:setup-deployment` - Configure deployment for FastAPI (Docker, Railway, DigitalOcean)
- `/fastapi-backend:/fastapi-backend:setup-database` - Configure async SQLAlchemy with PostgreSQL/Supabase
- `/fastapi-backend:/fastapi-backend:search-examples` - Search and add FastAPI examples/patterns to your project
- `/fastapi-backend:/fastapi-backend:add-auth` - Integrate authentication (JWT, OAuth2, Supabase) into FastAPI project

### nextjs-frontend

- `/nextjs-frontend:/nextjs-frontend:search-components` - Search and add shadcn/ui components from component library
- `/nextjs-frontend:/nextjs-frontend:add-page` - Add new page to Next.js application with App Router conventions
- `/nextjs-frontend:/nextjs-frontend:init` - Initialize Next.js 15 App Router project with AI SDK, Supabase, and shadcn/ui
- `/nextjs-frontend:/nextjs-frontend:integrate-ai-sdk` - Integrate Vercel AI SDK for streaming AI responses
- `/nextjs-frontend:/nextjs-frontend:add-component` - Add component with shadcn/ui integration and TypeScript
- `/nextjs-frontend:/nextjs-frontend:integrate-supabase` - Integrate Supabase client, auth, and database into Next.js project
- `/nextjs-frontend:/nextjs-frontend:enforce-design-system` - Enforce design system consistency across Next.js components
- `/nextjs-frontend:/nextjs-frontend:scaffold-app` - Scaffold complete Next.js application with sidebar, header, footer, and navigation from architecture docs using shadcn application blocks

### iterate

- `/iterate:/iterate:enhance` - Enhance existing features - add improvements and optimizations to existing features
- `/iterate:/iterate:sync` - Sync specs with implementation - update specs, tasks, and docs to match current code state
- `/iterate:/iterate:refactor` - Refactor code for quality - improve code structure and maintainability without changing functionality
- `/iterate:/iterate:adjust` - Adjust implementation based on feedback - make targeted changes based on user feedback or requirements

### security

- `/security:hooks-setup` - Install standardized git hooks (secret scanning, commit message validation, security checks)
- `/security:security` - Run comprehensive security scans (vulnerability detection, secret scanning, dependency auditing)

### mem0

- `/mem0:/mem0:test` - Test Mem0 functionality end-to-end (setup, operations, performance, security)
- `/mem0:/mem0:init` - Initialize Mem0 (Platform, OSS, or MCP) - intelligent router that asks deployment mode and routes to appropriate init command
- `/mem0:/mem0:init-mcp` - Setup Mem0 with OpenMemory MCP server for local-first AI memory
- `/mem0:/mem0:add-user-memory` - Add user preference and profile memory tracking across conversations
- `/mem0:/mem0:configure` - Configure Mem0 settings (memory types, retention, embeddings, rerankers, webhooks)
- `/mem0:/mem0:migrate-to-supabase` - Migrate from Mem0 Platform to Open Source with Supabase backend
- `/mem0:/mem0:add-graph-memory` - Enable graph memory for tracking relationships between memories and entities
- `/mem0:/mem0:init-platform` - Setup hosted Mem0 Platform with API keys and quick configuration
- `/mem0:/mem0:init-oss` - Setup self-hosted Mem0 OSS with Supabase backend and pgvector
- `/mem0:/mem0:add-conversation-memory` - Add conversation memory tracking to existing chat/AI application

### versioning

- `/versioning:/versioning:prerelease` - Create pre-release versions (alpha, beta, RC)
- `/versioning:/versioning:approve-release` - Multi-stakeholder approval workflow before release
- `/versioning:/versioning:record-deployment` - Track deployment history (version → environment → URL)
- `/versioning:/versioning:setup` - Setup semantic versioning with validation and templates for Python and TypeScript projects
- `/versioning:/versioning:rollback` - Rollback to previous version by removing tag and resetting files
- `/versioning:/versioning:bump` - Increment semantic version and create git tag with changelog
- `/versioning:/versioning:info` - Display version information and validate configuration
- `/versioning:/versioning:analyze-breaking` - Detect breaking changes and recommend version bump
- `/versioning:/versioning:generate-release-notes` - AI-powered release notes with migration guides and breaking change analysis

### vercel-ai-sdk

- `/vercel-ai-sdk:/vercel-ai-sdk:add-streaming` - Add text streaming capability to existing Vercel AI SDK project
- `/vercel-ai-sdk:/vercel-ai-sdk:add-tools` - Add tool/function calling capability to existing Vercel AI SDK project
- `/vercel-ai-sdk:/vercel-ai-sdk:new-ai-app` - Create and setup a new Vercel AI SDK application
- `/vercel-ai-sdk:/vercel-ai-sdk:add-chat` - Add chat UI with message persistence to existing Vercel AI SDK project
- `/vercel-ai-sdk:/vercel-ai-sdk:add-advanced` - Add advanced features to Vercel AI SDK app including AI agents with workflows, MCP tools, image generation, transcription, and speech synthesis
- `/vercel-ai-sdk:/vercel-ai-sdk:add-ui-features` - Add advanced UI features to Vercel AI SDK app including generative UI, useObject, useCompletion, message persistence, and attachments
- `/vercel-ai-sdk:/vercel-ai-sdk:new-app` - Create initial Vercel AI SDK project scaffold with basic setup
- `/vercel-ai-sdk:/vercel-ai-sdk:add-production` - Add production features to Vercel AI SDK app including telemetry, rate limiting, error handling, testing, and middleware
- `/vercel-ai-sdk:/vercel-ai-sdk:add-provider` - Add another AI provider to existing Vercel AI SDK project
- `/vercel-ai-sdk:/vercel-ai-sdk:add-data-features` - Add data features to Vercel AI SDK app including embeddings generation, RAG with vector databases, and structured data generation

### quality

- `/quality:/quality:test` - Run comprehensive test suite (Newman API, Playwright E2E, security scans)
- `/quality:/quality:validate-tasks` - Validate task completion status against actual implementation
- `/quality:/quality:performance` - Analyze performance and identify bottlenecks
- `/quality:/quality:security` - Run security scans and vulnerability checks
- `/quality:/quality:validate-code` - Review implementation code quality, security, and test coverage

### supabase

- `/supabase:/supabase:init-ai-app` - Complete AI application setup - chains schema creation, pgvector setup, auth, realtime, and type generation for a full-stack AI app
- `/supabase:/supabase:add-storage` - Configure Supabase Storage - creates buckets, sets up RLS policies for file access
- `/supabase:/supabase:init` - Initialize Supabase in your project - sets up MCP configuration, creates .env, and prepares project for Supabase integration
- `/supabase:/supabase:create-schema` - Generate database schema for AI applications - creates tables, relationships, indexes based on app type
- `/supabase:/supabase:add-ui-components` - Install Supabase UI components - adds auth, realtime, file upload React components
- `/supabase:/supabase:setup-ai` - Complete AI setup - pgvector, embeddings, schemas, RLS, validation (parallel multi-agent)
- `/supabase:/supabase:setup-pgvector` - Configure pgvector for vector search - enables extension, creates embedding tables, sets up HNSW/IVFFlat indexes
- `/supabase:/supabase:validate-schema` - Validate database schema integrity - checks constraints, indexes, naming conventions
- `/supabase:/supabase:add-auth` - Add authentication - OAuth providers, email auth, RLS policies with parallel validation
- `/supabase:/supabase:generate-types` - Generate TypeScript types from database schema
- `/supabase:/supabase:add-rls` - Add Row Level Security policies - generates and applies RLS policies for tables
- `/supabase:/supabase:validate-setup` - Validate Supabase setup - MCP connectivity, configuration, security, schema (parallel validation)
- `/supabase:/supabase:test-rls` - Test RLS policy enforcement - validates Row Level Security policies work correctly
- `/supabase:/supabase:test-e2e` - Run end-to-end tests - parallel test execution across database, auth, realtime, AI features
- `/supabase:/supabase:add-realtime` - Setup Supabase Realtime - enables realtime on tables, configures subscriptions, presence, broadcast
- `/supabase:/supabase:deploy-migration` - Deploy database migration - applies migration files safely with rollback capability

### deployment

- `/deployment:/deployment:deploy` - Complete deployment orchestrator - prepares project, configures CI/CD with GitHub Actions and secrets, deploys, and validates. Runs prepare → setup-cicd → deploy → validate in sequence for full automation.
- `/deployment:/deployment:prepare` - Prepare project for deployment with pre-flight checks (dependencies, build tools, authentication, environment variables)
- `/deployment:/deployment:rollback` - Rollback to previous deployment version with platform-specific rollback procedures
- `/deployment:/deployment:verify-feature-flags` - Pre-deployment feature flag validation and verification
- `/deployment:/deployment:setup-monitoring` - Observability integration (Sentry, DataDog, alerts)
- `/deployment:/deployment:canary-deploy` - Progressive traffic rollout with auto-rollback monitoring
- `/deployment:/deployment:rollback-automated` - Setup automated rollback triggers on error thresholds
- `/deployment:/deployment:capture-baseline` - Capture performance baselines (Lighthouse, API latency) for deployment monitoring
- `/deployment:/deployment:setup-cicd` - Automatically configure CI/CD pipeline with GitHub Actions and secrets for any deployment platform (Vercel, DigitalOcean, Railway). Uses gh CLI to auto-configure repository secrets and generates platform-specific workflows.
- `/deployment:/deployment:validate` - Validate deployment health with comprehensive checks (URL accessibility, health endpoints, environment variables)
- `/deployment:/deployment:blue-green-deploy` - Zero-downtime parallel environment swap deployment
- `/deployment:/deployment:feature-flags-setup` - Initialize feature flag infrastructure (LaunchDarkly/Flagsmith)

### foundation

- `/foundation:/foundation:mcp-sync` - Sync universal MCP registry to target format (.mcp.json or .vscode/mcp.json)
- `/foundation:/foundation:env-check` - Verify required tools are installed for detected tech stack
- `/foundation:/foundation:detect` - Detect project tech stack and populate .claude/project.json
- `/foundation:/foundation:github-init` - Complete GitHub repository initialization with gh CLI - creates repo, configures settings, branch protection, templates, and integrates with hooks-setup and CI/CD
- `/foundation:/foundation:env-vars` - Manage environment variables for project configuration
- `/foundation:/foundation:mcp-manage` - Add, install, remove, list MCP servers and manage API keys
- `/foundation:/foundation:doppler-setup` - Setup Doppler secret management for scalable environment variable handling
- `/foundation:/foundation:mcp-registry` - Manage universal MCP server registry (init, add, list, search, remove)
- `/foundation:/foundation:use-pnpm` - Convert Node.js project from npm to pnpm for faster worktree dependency installs
- `/foundation:/foundation:hooks-setup` - Install standardized git hooks (secret scanning, commit message validation, security checks) and GitHub Actions security workflow
- `/foundation:/foundation:generate-workflow` - Query Airtable for tech stack and generate complete workflow document

### stripe

- No commands

### openrouter

- `/openrouter:/openrouter:add-model-routing` - Configure intelligent model routing and cost optimization with fallback strategies
- `/openrouter:/openrouter:add-vercel-ai-sdk` - Add Vercel AI SDK integration with OpenRouter provider for streaming, chat, and tool calling
- `/openrouter:/openrouter:init` - Initialize OpenRouter SDK with API key configuration, model selection, and framework integration setup
- `/openrouter:/openrouter:configure` - Configure OpenRouter settings, API keys, and preferences
- `/openrouter:/openrouter:add-langchain` - Add LangChain integration with OpenRouter for chains, agents, and RAG

### testing

- `/testing:test` - Run comprehensive test suite (Newman API, Playwright E2E, security scans)
- `/testing:generate-tests` - Generate complete test suites automatically by reading package.json and analyzing project structure

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

---

**This workflow was auto-generated from Airtable on 2025-11-11**

To regenerate with latest Airtable data:
```bash
/foundation:generate-workflow "AI Tech Stack 1"
```

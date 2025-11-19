# Dev Lifecycle Workflow

This document shows the **core workflow** for building projects using the dev-lifecycle-marketplace.

## Overview

**Core Workflow** = Sequential steps to go from idea to implementation
**Supporting Operations** = Testing, versioning, deployment (run as needed)

---

## CORE WORKFLOW (Sequential)

### Step 1: Architecture & Planning

**Goal:** Gather requirements, create architecture docs, extract configuration

```bash
# 1a. Run the planning wizard
/planning:wizard
# Creates:
# - docs/architecture/*.md (8 files: README, backend, frontend, data, ai, infrastructure, security, integrations)
# - docs/adr/*.md (architectural decisions)
# - docs/ROADMAP.md

# 1b. Extract configuration from architecture
/planning:extract-config
# Creates:
# - .claude/project.json (tech stack + infrastructure)
# - features.json (features with build order)
```

**Output:** Architecture documentation and configuration files ready for spec generation.

---

### Step 2: Infrastructure Specs

**Goal:** Generate specs for system-level components (auth, caching, monitoring, etc.)

```bash
# 2a. (Optional) If project.json missing infrastructure, extract from existing specs
/foundation:extract-infrastructure
# Reads specs/features/ and populates project.json infrastructure section

# 2b. Generate infrastructure specs
/foundation:generate-infrastructure-specs
# Reads: .claude/project.json infrastructure section
# Creates:
# - specs/infrastructure/001-authentication/
# - specs/infrastructure/002-database/
# - specs/infrastructure/003-caching/
# - specs/infrastructure/004-monitoring/
# - etc.
# Each contains: spec.md, setup.md, tasks.md
```

**Output:** Complete infrastructure specifications with setup instructions.

---

### Step 3: Feature Specs

**Goal:** Generate specs for user-facing features

```bash
/planning:init-project
# Reads:
# - features.json (created by extract-config)
# - .claude/project.json
# Creates:
# - specs/features/F001-*/
# - specs/features/F002-*/
# - etc.
# Each contains: spec.md, tasks.md
```

**Output:** Complete feature specifications ready for implementation.

---

### Step 4: Implementation

**Goal:** Build infrastructure and features following the specs

```bash
# 4a. Build infrastructure first (in order)
# Follow specs/infrastructure/001-*/tasks.md
# Then specs/infrastructure/002-*/tasks.md
# etc.

# 4b. Build features (in build_order from features.json)
# Features with build_order: 1 first (can be parallel)
# Then build_order: 2, 3, 4, 5

# 4c. Use tech-specific plugins for actual code
/nextjs-frontend:init
/fastapi-backend:init
/supabase:init
# etc.

# 4d. Layer tasks before building each feature
/iterate:tasks F001
# Creates layered-tasks.md with:
# L0: Infrastructure dependencies
# L1: Core components
# L2: Feature components
# L3: Integration

# 4e. Sync after completing each layer
/iterate:sync F001
```

**Output:** Working implementation matching the specs.

---

## SUPPORTING OPERATIONS (Run as Needed)

These are not sequential phases - run them when appropriate.

### Testing

Run after building anything to validate it works.

```bash
# Generate test suites
/testing:generate-tests

# Run tests
/testing:test [newman|playwright|all]

# Frontend-specific tests
/testing:test-frontend
```

### Quality

Run to validate code quality and security.

```bash
# Validate implementation against spec
/quality:validate-code F001

# Check task completion
/quality:validate-tasks F001

# Performance analysis
/quality:performance

# Security scans
/security:security
/security:hooks-setup
```

### Versioning

Run before releases to manage versions.

```bash
# Setup versioning
/versioning:setup [python|typescript]

# Bump version
/versioning:bump [major|minor|patch]

# Generate release notes
/versioning:generate-release-notes
```

### Deployment

Run when ready to ship to production.

```bash
# Prepare for deployment
/deployment:prepare

# Setup CI/CD
/deployment:setup-cicd [vercel|digitalocean|railway]

# Deploy
/deployment:deploy

# Validate deployment
/deployment:validate <url>

# Setup monitoring
/deployment:setup-monitoring [sentry|datadog]
```

---

## GREENFIELD VS BROWNFIELD

### Greenfield (No Code Yet)

```bash
/planning:wizard                           # Step 1a
/planning:extract-config                   # Step 1b
/foundation:generate-infrastructure-specs  # Step 2
/planning:init-project                     # Step 3
# Then implement (Step 4)
```

### Brownfield (Code Already Exists)

```bash
/foundation:detect                         # Detect existing tech stack
/foundation:extract-infrastructure         # Extract infra from existing specs
/foundation:generate-infrastructure-specs  # Generate infra specs
/planning:wizard                           # (Optional) Plan new features
/planning:extract-config                   # Extract config
/planning:init-project                     # Generate feature specs
/iterate:sync                              # Sync specs with existing code
```

---

## ADDING TO EXISTING PROJECTS

### Add New Infrastructure Component

```bash
/foundation:add-infrastructure webhooks "Stripe webhook handling"
# Updates project.json and creates specs/infrastructure/00X-webhooks/
```

### Add New Feature

```bash
/planning:add-feature "User dashboard with analytics"
# Creates specs/features/F00X-user-dashboard/
# Then:
/iterate:tasks F00X
# Build following layered-tasks.md
```

### Update Existing Feature

```bash
/planning:update-feature F001 "Add export functionality"
# Updates existing spec and tasks
```

---

## MINIMAL WORKFLOW (Quick Start)

For getting something deployed fast:

```bash
/planning:wizard                           # Plan it
/planning:extract-config                   # Config files
/planning:init-project                     # Feature specs
# Build it manually or with tech plugins
/testing:test                              # Test it
/deployment:deploy                         # Ship it
```

---

## TECH-SPECIFIC PLUGINS

The dev lifecycle orchestrates HOW you build. Tech plugins handle WHAT you build with:

### Frontend
```bash
/nextjs-frontend:init
/nextjs-frontend:add-page <name>
/nextjs-frontend:add-component <name>
```

### Backend
```bash
/fastapi-backend:init
/fastapi-backend:add-endpoint "<endpoint>"
```

### Database
```bash
/supabase:init
/supabase:create-schema
/supabase:deploy-migration
```

### AI
```bash
/vercel-ai-sdk:new-ai-app
/mem0:init
/rag-pipeline:init
```

---

## KEY POINTS

1. **Infrastructure before features** - Always build system components first
2. **Specs before code** - Never build without a spec
3. **Build order matters** - Follow features.json build_order
4. **Layer tasks** - Run /iterate:tasks before implementing each feature
5. **Test continuously** - Run tests after each layer
6. **Supporting ops are flexible** - Use when needed, not as rigid phases

---

## REFERENCE DOCUMENTS

- `~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/docs/INFRASTRUCTURE-VS-FEATURES.md` - Classification guide
- `~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/docs/WORKFLOW-ORDER.md` - Detailed greenfield/brownfield explanation

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
/implementation:execute 001-authentication
/implementation:execute 002-database
/implementation:execute 003-caching
# etc. - follow specs/infrastructure/ order

# 4b. Build features (in build_order from features.json)
/implementation:execute F001
/implementation:execute F002
# Features with same build_order can run in parallel

# 4c. Check progress
/implementation:status F001
# Shows: completed tasks, current progress, next actions

# 4d. Resume if interrupted
/implementation:continue F001

# 4e. Execute specific layer only (if needed)
/implementation:execute-layer F001 L0
# Useful for targeted execution and testing
```

**Output:** Working implementation matching the specs.

**Note:** The implementation plugin automatically:
- Discovers available commands from enabled tech plugins
- Maps tasks to appropriate commands (nextjs-frontend, fastapi-backend, etc.)
- Executes sequentially with progress tracking
- Handles layer-by-layer execution (L0 → L1 → L2 → L3)

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

### Iterate (Changes to Existing Code)

Run when modifying existing features, not for initial implementation.

```bash
# Enhance existing feature
/iterate:enhance <feature-name>
# Adds improvements and optimizations

# Refactor for quality
/iterate:refactor <file-or-directory>
# Improves structure without changing functionality

# Adjust based on feedback
/iterate:adjust "<feedback>"
# Makes targeted changes based on user requirements
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

# Then execute:
/implementation:execute F00X
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
4. **Use implementation plugin** - /implementation:execute handles the building
5. **Test after implementation** - Validate what you built
6. **Iterate for changes only** - enhance/refactor/adjust existing code

---

## REFERENCE DOCUMENTS

- `~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/docs/INFRASTRUCTURE-VS-FEATURES.md` - Classification guide
- `~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/docs/WORKFLOW-ORDER.md` - Detailed greenfield/brownfield explanation

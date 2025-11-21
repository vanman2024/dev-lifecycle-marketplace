---
description: Extract project.json, features.json, application-design.json, and website-design.json from architecture docs
argument-hint: none
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

---

**Arguments**: None required

Goal: Extract comprehensive project.json, features.json, application-design.json, and website-design.json from all generated architecture documentation with full context.

Core Principles:
- Read ALL architecture docs before generating config
- Cross-reference for completeness and consistency
- Extract tech stack from multiple sources (backend.md, frontend.md, data.md, ai.md, infrastructure.md)
- Extract features from ROADMAP.md and architecture analysis
- Extract application pages (Next.js) and website pages (Astro) from frontend.md
- Generate comprehensive configuration files ready for init-project

Phase 1: Validate Architecture Exists
Goal: Ensure all required architecture files exist before extraction

Actions:
- Create todo list tracking extraction phases
- Check for required architecture files:
  - docs/architecture/README.md
  - docs/architecture/backend.md
  - docs/architecture/frontend.md
  - docs/architecture/data.md
  - docs/architecture/ai.md
  - docs/architecture/infrastructure.md
  - docs/architecture/security.md
  - docs/architecture/integrations.md
  - docs/architecture/application-pages.md
  - docs/architecture/website-pages.md
  - docs/ROADMAP.md
- If any files missing, display error and exit:
  ```
  ❌ Missing architecture files. Run /planning:wizard first to generate architecture documentation.
  
  Missing files:
  - docs/architecture/backend.md
  - docs/ROADMAP.md
  ```
- Update todos

Phase 2: Read All Architecture Documentation
Goal: Load complete context from all architecture files

Actions:
- Read all 10 architecture files into memory:
  - README.md (system overview, project description)
  - backend.md (backend framework, API design, MCP servers)
  - frontend.md (frontend framework, UI libraries, component patterns)
  - data.md (database type, schema, relationships)
  - ai.md (AI SDKs, providers, memory systems, MCP integrations)
  - infrastructure.md (deployment targets, containerization, CI/CD)
  - security.md (authentication, authorization, secrets management)
  - integrations.md (external services, webhooks, APIs)
  - application-pages.md (interactive app pages: dashboard, settings, chat, admin, auth)
  - website-pages.md (static/marketing pages: landing, pricing, about, blog, docs)
- Read ROADMAP.md (features, milestones, timeline)
- Read docs/FINAL-APPROVAL.md if exists (validation results)
- Store content for cross-referencing
- Update todos

Phase 3: Extract Tech Stack (project.json)
Goal: Generate comprehensive .claude/project.json from architecture docs

Actions:
- Extract project name from README.md
- Extract framework from backend.md and frontend.md:
  - Backend: FastAPI, Django, Express, Go, Rust, etc.
  - Frontend: Next.js, React, Vue, Svelte, etc.
- Extract languages from all docs (TypeScript, Python, Go, Rust, etc.)
- Extract AI stack from ai.md:
  - SDKs: Vercel AI SDK, Claude Agent SDK, LangChain, etc.
  - Providers: Anthropic, OpenAI, Google, etc.
  - Memory: Mem0, custom implementations
  - MCP servers: List from ai.md and backend.md
- Extract database from data.md:
  - Type: PostgreSQL, MongoDB, MySQL, etc.
  - Provider: Supabase, raw, cloud-hosted
  - ORM: Prisma, SQLAlchemy, Drizzle, etc.
  - Extensions: pgvector, etc.
- Extract testing frameworks from architecture docs
- Extract deployment targets from infrastructure.md:
  - Frontend: Vercel, Netlify, Cloudflare Pages
  - Backend: Railway, DigitalOcean, AWS
  - MCP: FastMCP Cloud, self-hosted
- Extract infrastructure components from infrastructure.md:
  - Authentication (Clerk, Supabase Auth, Auth0, NextAuth)
  - Caching (Redis, Memcached, in-memory)
  - Monitoring (Sentry, DataDog, New Relic)
  - Error handling (Sentry, custom)
  - Rate limiting (express-rate-limit, Redis-based)
  - CI/CD (GitHub Actions, GitLab CI)
- Cross-reference all sources for consistency
- Update todos

Phase 4: Generate project.json
Goal: Write comprehensive .claude/project.json

Actions:
- Create .claude/ directory if not exists
- Generate project.json with structure:
  ```json
  {
    "name": "project-name",
    "framework": "Next.js 15",
    "languages": ["TypeScript", "Python"],
    "ai_stack": {
      "sdks": ["Vercel AI SDK", "Claude Agent SDK"],
      "providers": ["Anthropic", "OpenAI"],
      "memory": "Mem0",
      "mcp_servers": ["supabase", "playwright", "context7"]
    },
    "database": {
      "type": "PostgreSQL",
      "provider": "Supabase",
      "orm": "Prisma",
      "extensions": ["pgvector"]
    },
    "testing": {
      "unit": "Jest",
      "e2e": "Playwright",
      "api": "Supertest"
    },
    "deployment": {
      "frontend": "Vercel",
      "backend": "Railway",
      "mcp": "FastMCP Cloud"
    },
    "infrastructure": {
      "authentication": {
        "provider": "Clerk",
        "features": ["JWT validation", "Session management"],
        "integration": "Supabase RLS sync"
      },
      "caching": {
        "provider": "Redis",
        "strategy": "query caching",
        "use_cases": ["API responses", "embeddings"]
      },
      "monitoring": {
        "provider": "Sentry",
        "features": ["error tracking", "performance monitoring"]
      },
      "error_handling": {
        "provider": "Sentry",
        "features": ["error aggregation", "alert rules"]
      },
      "rate_limiting": {
        "provider": "express-rate-limit",
        "strategy": "sliding window"
      },
      "ci_cd": {
        "platform": "GitHub Actions",
        "workflows": ["test", "deploy", "security-scan"]
      }
    },
    "extracted_at": "2025-01-XX",
    "extracted_from": "architecture docs via /planning:extract-config"
  }
  ```
- Write to .claude/project.json
- Validate JSON syntax
- Update todos

Phase 5: Extract Features (features.json)
Goal: Generate comprehensive features.json from ROADMAP.md and architecture

Actions:
- Parse ROADMAP.md for feature list:
  - Feature names and descriptions
  - Priority levels (P0, P1, P2)
  - Dependencies between features
  - Estimated effort
- Cross-reference with architecture docs for feature details:
  - ai.md for AI-related features
  - frontend.md for UI features
  - backend.md for API features
  - data.md for data features
- Extract shared context from architecture:
  - Tech stack references
  - Common dependencies
  - Infrastructure requirements
- **CRITICAL: Analyze feature dependencies and determine build order**:
  - Infrastructure must come first (always dependency for features)
  - Foundation features before dependent features
  - Core services before UI features
  - Data models before features using them
  - API endpoints before frontend consuming them
- Number features sequentially (F001, F002, etc.)
- **Order features by build_order (not just priority)**
- Group features by priority AND dependencies
- Update todos

Phase 6: Generate features.json
Goal: Write comprehensive features.json with dependency-based ordering

Actions:
- Generate features.json with structure:
  ```json
  {
    "features": [
      {
        "id": "F001",
        "name": "Feature Name",
        "description": "Detailed description from ROADMAP and architecture",
        "priority": "P0",
        "status": "not_started",
        "estimated_effort": "3-5 days",
        "build_order": 1,
        "dependencies": ["infrastructure"],
        "blocks": ["F003", "F005"],
        "architecture_refs": [
          "docs/architecture/ai.md#rag-system",
          "docs/architecture/backend.md#api-endpoints"
        ]
      }
    ],
    "build_order_explanation": {
      "1": "Foundation features (no feature dependencies, only infrastructure)",
      "2": "Core services (depend on foundation)",
      "3": "Secondary features (depend on core services)",
      "4": "UI features (depend on backend/core services)",
      "5": "Integration features (depend on multiple features)"
    },
    "shared_context": {
      "tech_stack": "Next.js 15 + FastAPI + Supabase",
      "ai_stack": "Claude Agent SDK + Vercel AI SDK",
      "authentication": "Clerk with Supabase RLS",
      "deployment": "Vercel (frontend) + Railway (backend)"
    },
    "extracted_at": "2025-01-XX",
    "extracted_from": "ROADMAP.md + architecture docs via /planning:extract-config"
  }
  ```
- **CRITICAL: Features MUST be ordered by build_order in the array**
  - Feature with build_order: 1 comes first
  - Features with same build_order can be built in parallel
  - This ensures /planning:init-project creates specs in correct order
- Write to features.json
- Validate JSON syntax
- Update todos

Phase 7: Extract Application Pages (application-design.json)
Goal: Generate application-design.json from application-pages.md

Actions:
- Parse application-pages.md for all application pages:
  * Dashboard pages (main dashboard, analytics, reports)
  * Settings pages (user settings, preferences, profile)
  * Chat/AI pages (chat interface, AI generation)
  * Admin pages (user management, system config)
  * Auth pages (login, signup, password reset)
- Detect page characteristics:
  * Route paths (/ dashboard, /settings, /chat)
  * Route groups ((app), (auth), (admin))
  * Layouts (dashboard_layout, auth_layout, minimal_layout)
  * Rendering strategy (server | client | hybrid)
  * Components needed (sidebar, header, forms, tables)
  * Data sources (supabase, API endpoints)
  * AI features (chat streaming, generation)
- Number pages sequentially (A001, A002, etc.)
- Determine dependencies and phases
- Update todos

Phase 8: Generate application-design.json
Goal: Write comprehensive application-design.json for Next.js application pages

Actions:
- Generate application-design.json using schema template
- Include all application pages with full details
- Add layout definitions (dashboard, auth, minimal)
- Reference design-system.md for UI enforcement
- Write to application-design.json
- Validate JSON syntax
- Update todos

Phase 9: Extract Website Pages (website-design.json)
Goal: Generate website-design.json from website-pages.md

Actions:
- Parse website-pages.md for all marketing/content pages:
  * Landing pages (main landing, product pages)
  * Marketing pages (pricing, about, features)
  * Blog pages (blog index, post template)
  * Documentation pages (docs structure)
- Detect page characteristics:
  * Route paths (/, /pricing, /about, /blog)
  * Sections (hero, features, pricing, testimonials, CTA, FAQ)
  * Content type (static | collection | CMS)
  * AI features (content generation, image generation, SEO)
  * SEO requirements (meta tags, structured data, OG images)
- Number pages sequentially (W001, W002, etc.)
- Determine dependencies and phases
- Update todos

Phase 10: Generate website-design.json
Goal: Write comprehensive website-design.json for Astro marketing/content pages

Actions:
- Generate website-design.json using schema template
- Include all website pages with full details
- Add content collections (blog posts, docs)
- Add CMS integration if specified
- Add AI generation capabilities
- Write to website-design.json
- Validate JSON syntax
- Update todos

Phase 11: Validation
Goal: Verify extracted configuration is complete and consistent

Actions:
- Validate project.json:
  - All required fields present
  - Tech stack consistent across architecture docs
  - Infrastructure section matches infrastructure.md
  - No placeholder values (all real detections)
- Validate features.json:
  - All features from ROADMAP included
  - Feature descriptions are comprehensive
  - Dependencies correctly identified
  - Priority levels assigned
  - Architecture references valid
  - **CRITICAL: Build order is correct**:
    - Features ordered by build_order field
    - No circular dependencies
    - Dependencies have lower build_order than dependents
    - Features with same build_order can be built in parallel
- Validate application-design.json:
  - All application pages from frontend.md included
  - Page routes are valid Next.js App Router routes
  - Route groups are correct
  - Layouts match design-system.md
  - Dependencies correctly identified
  - Phase ordering is correct
- Validate website-design.json:
  - All marketing/content pages from frontend.md included
  - Page routes are valid Astro routes
  - Sections match marketing page patterns
  - Content collections properly defined
  - AI generation capabilities specified
  - SEO requirements complete
- Check for inconsistencies between files
- Display validation results including:
  - Feature build order summary (X features at order 1, Y at order 2, etc.)
  - Application pages summary (X pages, Y layouts)
  - Website pages summary (X pages, Y with AI generation)
  - Dependency graph validation
- Update todos

Phase 12: Summary
Goal: Display results and next steps

Actions:
- Display completion message:
  ```
  ✅ Configuration Extraction Complete!

  Generated Files:
  - .claude/project.json (tech stack and infrastructure)
  - features.json (feature breakdown with build order)
  - application-design.json (Next.js application pages)
  - website-design.json (Astro marketing/content pages)

  Feature Build Order:
  - Build Order 1: X features (foundation - can build in parallel)
  - Build Order 2: Y features (core services - can build in parallel)
  - Build Order 3: Z features (secondary - can build in parallel)
  - Build Order 4: N features (UI - can build in parallel)
  - Build Order 5: M features (integration - can build in parallel)

  Application Pages (Next.js):
  - Phase 0: X pages (can build in parallel)
  - Phase 1: Y pages (can build in parallel)
  - Phase 2: Z pages (can build in parallel)
  - Total Layouts: N

  Website Pages (Astro):
  - Phase 0: X pages (can build in parallel)
  - Phase 1: Y pages (can build in parallel)
  - Phase 2: Z pages (can build in parallel)
  - AI Content Generation: N pages
  - AI Image Generation: M pages

  Extracted From:
  - docs/architecture/README.md
  - docs/architecture/backend.md
  - docs/architecture/frontend.md (component patterns)
  - docs/architecture/data.md
  - docs/architecture/ai.md
  - docs/architecture/infrastructure.md
  - docs/architecture/security.md
  - docs/architecture/integrations.md
  - docs/architecture/application-pages.md (app page inventory)
  - docs/architecture/website-pages.md (marketing page inventory)
  - docs/ROADMAP.md

  Next Steps:
  1. Run /planning:init-project to generate feature specs (creates specs in build order)
  2. Run /foundation:generate-infrastructure-specs to generate infrastructure specs
  3. Build application pages: /implementation:execute --application
  4. Build website pages: /implementation:execute --website
  5. Build features in order (build_order: 1 → 2 → 3 → 4 → 5)
  6. Features with same build_order can be built in parallel
  ```
- Mark all todos completed

---
description: Extract project.json and features.json from architecture docs - reads all architecture files with full context and generates configuration files
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

Goal: Extract comprehensive project.json and features.json from all generated architecture documentation with full context.

Core Principles:
- Read ALL architecture docs before generating config
- Cross-reference for completeness and consistency
- Extract tech stack from multiple sources (backend.md, frontend.md, data.md, ai.md, infrastructure.md)
- Extract features from ROADMAP.md and architecture analysis
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
- Read all 8 architecture files into memory:
  - README.md (system overview, project description)
  - backend.md (backend framework, API design, MCP servers)
  - frontend.md (frontend framework, UI libraries, pages/components)
  - data.md (database type, schema, relationships)
  - ai.md (AI SDKs, providers, memory systems, MCP integrations)
  - infrastructure.md (deployment targets, containerization, CI/CD)
  - security.md (authentication, authorization, secrets management)
  - integrations.md (external services, webhooks, APIs)
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
- Number features sequentially (F001, F002, etc.)
- Group features by priority and dependencies
- Update todos

Phase 6: Generate features.json
Goal: Write comprehensive features.json

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
        "dependencies": ["infrastructure"],
        "architecture_refs": [
          "docs/architecture/ai.md#rag-system",
          "docs/architecture/backend.md#api-endpoints"
        ]
      }
    ],
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
- Write to features.json
- Validate JSON syntax
- Update todos

Phase 7: Validation
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
- Check for inconsistencies between files
- Display validation results
- Update todos

Phase 8: Summary
Goal: Display results and next steps

Actions:
- Display completion message:
  ```
  ✅ Configuration Extraction Complete!
  
  Generated Files:
  - .claude/project.json (tech stack and infrastructure)
  - features.json (feature breakdown with priorities)
  
  Extracted From:
  - docs/architecture/README.md
  - docs/architecture/backend.md
  - docs/architecture/frontend.md
  - docs/architecture/data.md
  - docs/architecture/ai.md
  - docs/architecture/infrastructure.md
  - docs/architecture/security.md
  - docs/architecture/integrations.md
  - docs/ROADMAP.md
  
  Next Steps:
  1. Run /planning:init-project to generate feature specs from features.json
  2. Run /foundation:generate-infrastructure-specs to generate infrastructure specs from project.json
  3. Begin implementation following the specs
  ```
- Mark all todos completed

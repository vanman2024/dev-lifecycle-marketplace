---
description: Extract infrastructure components from existing specs into project.json - analyzes specs/features/ to populate project.json infrastructure section
argument-hint: [project-path]
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

---

**Arguments**: $ARGUMENTS (optional project path, defaults to current directory)

Goal: Analyze existing specs to identify infrastructure components and populate .claude/project.json infrastructure section. This is the REVERSE of /foundation:generate-infrastructure-specs.

## Flow

```
BEFORE: specs/features/ has mixed content, project.json has NO infrastructure section
AFTER: project.json has infrastructure section populated from spec analysis

Then you can run:
/foundation:generate-infrastructure-specs → creates specs/infrastructure/ from project.json
```

## Required Reference Document

**CRITICAL**: Read the infrastructure vs features classification guide:
`@~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/docs/INFRASTRUCTURE-VS-FEATURES.md`

This document defines:
- What counts as infrastructure (system-level, not user-facing)
- What counts as features (user-facing, provides direct value)
- Decision tree for classification
- Examples of each category

Phase 1: Load Classification Guide
Goal: Read the infrastructure vs features reference document

Actions:
- Create todo list tracking phases
- Read the classification guide from the marketplace:
  `/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/docs/INFRASTRUCTURE-VS-FEATURES.md`
- Understand the decision tree:
  - Is this visible to users? No → Infrastructure
  - Does this provide direct user value? No → Infrastructure
  - Would users pay specifically for this? No → Infrastructure
  - Is this in marketing copy? No → Infrastructure
- Note infrastructure component types:
  - Authentication, Database, Caching, Monitoring, Error Handling
  - Rate Limiting, Backup, CI/CD, Email, Storage, Queue, Search, Analytics, Payments
- Update todos

Phase 2: Scan Existing Specs
Goal: Find all specs and read their content

Actions:
- Determine project path
- List all specs in specs/features/: `ls specs/features/`
- For each spec directory, read:
  - spec.md (main requirements)
  - Look for provider names, system components, integration details
- Also check if specs/infrastructure/ exists (may have some already)
- Update todos

Phase 3: Classify Each Spec
Goal: Determine which specs are infrastructure vs features

Actions:
- For each spec, apply the decision tree from the classification guide:
  
  **Infrastructure indicators**:
  - Spec focuses on: setup, configuration, integration, system-level
  - Provider/service setup: Clerk, Redis, Sentry, SendGrid, S3, etc.
  - No direct user interaction described
  - Technical plumbing, not user value
  
  **Feature indicators**:
  - Spec describes: user interaction, user value, user-facing UI
  - User stories with "As a user, I want..."
  - Would appear in marketing materials
  
- Create classification list:
  ```
  INFRASTRUCTURE (will add to project.json):
  - F016-user-authentication → authentication (Clerk)
  - F017-redis-caching → caching (Redis)
  - F025-sentry-error-tracking → monitoring (Sentry)
  - F026-backup-system → backup
  - F027-rate-limiting → rate_limiting
  
  FEATURES (keep as features):
  - F001-google-file-search-rag
  - F002-claude-agent-sdk-study-partner
  - F007-progress-tracking-dashboard
  ```
- Display classification for user confirmation
- Update todos

Phase 4: Extract Infrastructure Details
Goal: Parse spec content to extract provider details

Actions:
- For each infrastructure spec identified, extract:
  - **Provider**: What service/tool (Clerk, Redis, Sentry, etc.)
  - **Features**: What capabilities (JWT validation, caching strategy, etc.)
  - **Integration**: How it connects to other components
  - **Configuration**: Environment variables, API keys needed
  
- Build infrastructure object for each:
  ```json
  "authentication": {
    "provider": "Clerk",
    "backend_sdk": "@clerk/clerk-sdk-node",
    "frontend_sdk": "@clerk/nextjs",
    "features": ["JWT validation", "Session management", "OAuth"],
    "integration": "Supabase RLS sync via clerk_user_id"
  }
  ```
- Update todos

Phase 5: Update project.json
Goal: Add infrastructure section to project.json

Actions:
- Read current .claude/project.json
- Add or update infrastructure section with all extracted components
- Structure:
  ```json
  {
    "name": "project-name",
    "framework": "...",
    "infrastructure": {
      "authentication": { ... },
      "caching": { ... },
      "monitoring": { ... },
      "error_handling": { ... },
      "rate_limiting": { ... },
      "webhooks": { ... },
      "email": { ... },
      // ... all extracted components
    }
  }
  ```
- Write updated project.json
- Update todos

Phase 6: Summary
Goal: Display results and next steps

Actions:
- Display completion message:
  ```
  ✅ Infrastructure Extracted to project.json!

  Added Infrastructure Components:
  - authentication: Clerk
  - caching: Redis
  - monitoring: Sentry
  - error_handling: Sentry
  - rate_limiting: express-rate-limit
  - webhooks: Stripe
  
  Source Specs Analyzed:
  - specs/features/F016-user-authentication/
  - specs/features/F017-redis-caching/
  - specs/features/F025-sentry-error-tracking/
  ...

  Next Steps:
  1. Review .claude/project.json infrastructure section
  2. Run /foundation:generate-infrastructure-specs to create proper infrastructure specs
  3. The old feature specs (F016, F017, etc.) can be archived after infrastructure specs are generated
  4. Update features.json to remove infrastructure items
  ```
- Mark all todos completed

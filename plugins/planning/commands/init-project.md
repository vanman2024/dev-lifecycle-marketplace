---
description: Create ALL project specs in one shot from massive description using parallel agents
argument-hint: <project-description>
allowed-tools: Task, Read, Write, Bash, Grep, Glob, Skill
---
## Available Skills

This commands has access to the following skills from the planning plugin:

- **architecture-patterns**: Architecture design templates, mermaid diagrams, documentation patterns, and validation tools. Use when designing system architecture, creating architecture documentation, generating mermaid diagrams, documenting component relationships, designing data flows, planning deployments, creating API architectures, or when user mentions architecture diagrams, system design, mermaid, architecture documentation, or component design.
- **decision-tracking**: Architecture Decision Records (ADR) templates, sequential numbering, decision documentation patterns, and decision history management. Use when creating ADRs, documenting architectural decisions, tracking decision rationale, managing decision lifecycle, superseding decisions, searching decision history, or when user mentions ADR, architecture decision, decision record, decision tracking, or decision documentation.
- **spec-management**: Templates, scripts, and examples for managing feature specifications in specs/ directory. Use when creating feature specs, listing specifications, validating spec completeness, updating spec status, searching spec content, organizing project requirements, tracking feature development, managing technical documentation, or when user mentions spec management, feature specifications, requirements docs, spec validation, or specification organization.

**To use a skill:**
```
!{skill skill-name}
```

Use skills when you need:
- Domain-specific templates and examples
- Validation scripts and automation
- Best practices and patterns
- Configuration generators

Skills provide pre-built resources to accelerate your work.

---



## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Rapidly generate complete project specifications from a massive project description by breaking it into features and generating specs in parallel

Core Principles:
- Break down complexity with feature-analyzer
- Generate specs in parallel for speed
- Use structured JSON to coordinate agents
- Consolidate results into project-specs.json
- Provide comprehensive summary with paths

Phase 1: Verify Architecture Documentation
Goal: Check for architecture docs created by /planning:architecture, /planning:decide, /planning:roadmap

Actions:
- Check if architecture docs exist: !{bash test -d docs/architecture && echo "✅ Found" || echo "⚠️ Missing"}
- If docs/architecture/ exists:
  - List architecture files: !{bash ls -1 docs/architecture/*.md 2>/dev/null | wc -l}
  - List ADR files: !{bash ls -1 docs/adr/*.md 2>/dev/null | wc -l}
  - Verify ROADMAP: !{bash test -f docs/ROADMAP.md && echo "✅ Found" || echo "⚠️ Missing"}
  - Architecture files will be passed directly to agents via @ references:
    - @docs/architecture/frontend.md
    - @docs/architecture/backend.md
    - @docs/architecture/data.md
    - @docs/architecture/ai.md
    - @docs/architecture/infrastructure.md
    - @docs/architecture/security.md
    - @docs/architecture/integrations.md
    - @docs/adr/*.md
    - @docs/ROADMAP.md
- If not exists:
  - Note: Will use $ARGUMENTS only (architecture docs recommended)
- No temporary files needed

Phase 2: Parse Project Description
Goal: Save the project description and validate input

Actions:
- Parse $ARGUMENTS to extract project description
- Save description to temporary file for analysis
- Example: !{bash echo "$ARGUMENTS" > /tmp/project-description.txt}
- Verify description is substantial (>100 words) OR architecture docs exist
- Count words: !{bash wc -w < /tmp/project-description.txt}

Phase 3: Feature Analysis
Goal: Break massive description into discrete features with dependencies

Actions:

Task(description="Analyze architecture and break into features", subagent_type="planning:feature-analyzer", prompt="You are the feature-analyzer agent.

INPUT SOURCES:

Architecture Documentation (read directly from source):
@docs/architecture/frontend.md
@docs/architecture/backend.md
@docs/architecture/data.md
@docs/architecture/ai.md
@docs/architecture/infrastructure.md
@docs/architecture/security.md
@docs/architecture/integrations.md
@docs/adr/*.md
@docs/ROADMAP.md

Project Description: $ARGUMENTS

YOUR TASK:
Break this into AS MANY focused features as needed. NO ARTIFICIAL LIMITS.

CRITICAL: Each feature should be:
- Implementable in 2-3 days (if >3 days, SPLIT IT)
- Result in 200-300 line specs (NOT 647!)
- Have 15-25 tasks (NOT 45!)
- Single responsibility
- Reference architecture docs for details (don't duplicate)

SIZING RULE: If a feature needs >3 days or >25 tasks, it's TOO LARGE - split it.

Example: DON'T create large features like 'User Authentication'
Instead, create focused features:
- Feature 1: Basic Auth (email/password) - 2 days, 18 tasks
- Feature 2: OAuth Integration - 2 days, 15 tasks
- Feature 3: MFA - 1 day, 12 tasks
- Feature 4: Password Reset - 1 day, 10 tasks

The project might have 10 features, 50 features, or 200 features - THAT'S OK.
What matters: Each feature is small, focused, and implementable in 2-3 days.

Deliverable: JSON output with:
- features array (AS MANY AS NEEDED - no artificial limit):
  - number, name, shortName, focus
  - dependencies (feature numbers this depends on)
  - estimatedDays (2-3 typical, MAX 3)
  - complexity (low/medium/high)
  - architectureReferences (which docs/architecture/*.md sections to reference)
- sharedContext (techStack, userTypes, dataEntities, integrations)

Save JSON to: /tmp/feature-breakdown.json")

Wait for feature-analyzer to complete and generate JSON.

Phase 4: Load Feature Breakdown
Goal: Parse the feature breakdown JSON for parallel spec generation

Actions:
- Load the generated JSON: @/tmp/feature-breakdown.json
- Extract feature list from JSON
- Count total features: !{bash jq '.features | length' /tmp/feature-breakdown.json}
- Display feature list for user visibility
- Example: !{bash jq -r '.features[] | "\(.number) - \(.name): \(.focus)"' /tmp/feature-breakdown.json}

Phase 5: Parallel Spec Generation
Goal: Spawn N spec-writer agents (one per feature) to run simultaneously

Actions:

Read feature breakdown JSON and launch one spec-writer agent per feature:

For each feature in the JSON, launch a parallel Task:

Task(description="Generate spec for feature 001", subagent_type="planning:spec-writer", prompt="You are the spec-writer agent. Create complete specifications (spec.md, plan.md, tasks.md) for this feature.

Architecture Documentation (read directly from source):
@docs/architecture/frontend.md
@docs/architecture/backend.md
@docs/architecture/data.md
@docs/architecture/ai.md
@docs/architecture/infrastructure.md
@docs/architecture/security.md
@docs/architecture/integrations.md
@docs/adr/*.md
@docs/ROADMAP.md

Full Project Context:
$ARGUMENTS

Your Feature Assignment:
- Feature: Extract from JSON /tmp/feature-breakdown.json feature 001
- Focus: Extract focus from JSON
- Dependencies: Extract dependencies from JSON
- Integrations: Extract integrations from JSON
- Shared Context: Extract sharedContext from JSON

Deliverable: Three files in specs/{number}-{name}/ directory:
- spec.md (user requirements, tech-agnostic)
- plan.md (technical design with database schema, API contracts)
- tasks.md (implementation tasks, 5 phases, numbered)")

Task(description="Generate spec for feature 002", subagent_type="planning:spec-writer", prompt="You are the spec-writer agent. Create complete specifications (spec.md, plan.md, tasks.md) for this feature.

Architecture Documentation (read directly from source):
@docs/architecture/frontend.md
@docs/architecture/backend.md
@docs/architecture/data.md
@docs/architecture/ai.md
@docs/architecture/infrastructure.md
@docs/architecture/security.md
@docs/architecture/integrations.md
@docs/adr/*.md
@docs/ROADMAP.md

Full Project Context:
$ARGUMENTS

Your Feature Assignment:
- Feature: Extract from JSON /tmp/feature-breakdown.json feature 002
- Focus: Extract focus from JSON
- Dependencies: Extract dependencies from JSON
- Integrations: Extract integrations from JSON
- Shared Context: Extract sharedContext from JSON

Deliverable: Three files in specs/{number}-{name}/ directory:
- spec.md (user requirements, tech-agnostic)
- plan.md (technical design with database schema, API contracts)
- tasks.md (implementation tasks, 5 phases, numbered)")

Continue launching Task() calls for ALL features in parallel (one Task per feature).

NOTE: In actual execution, the command orchestrator will read the JSON and dynamically create N Task() calls based on feature count.

Wait for ALL spec-writer agents to complete before proceeding.

Phase 6: Project Overview
Goal: Create high-level project overview (000-project-overview) with build phases and dependency graph

Actions:
- Create overview directory: !{bash mkdir -p specs/000-project-overview}
- Load template:
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/spec-management/templates/project-overview-template.md
- Parse feature analysis JSON for:
  - Project name and description
  - All features with buildPhase, dependencies, sharedEntities
  - Shared context (tech stack, user types, data entities, entity ownership)
- Generate README.md with populated template:
  - **Features table** with build phase column, dependencies, status
  - **Tech stack** from sharedContext
  - **User types** from sharedContext
  - **Data Architecture** showing entity ownership (who owns what)
  - **Build Order & Phases** grouped by phase (1=Foundation, 2=Core, 3=Integration)
  - **Dependency graph** (mermaid) showing all feature relationships
  - **Critical path** (longest dependency chain)
  - **Parallel work opportunities** (which can build simultaneously)
  - **Integration map** (how features connect)
- Write: specs/000-project-overview/README.md
- This file provides the bird's-eye view of entire project

Phase 7: Consolidation
Goal: Generate consolidated project-specs.json from all specs

Actions:
- Run consolidation script to generate JSON output
- Example: !{bash bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/spec-management/scripts/consolidate-specs.sh}
- Verify JSON was created: !{bash test -f .planning/project-specs.json && echo "Generated" || echo "Missing"}
- Count total specs created: !{bash ls -1 specs/*/spec.md 2>/dev/null | wc -l}

Phase 8: Summary
Goal: Provide comprehensive results with paths and next steps

Actions:
- Display feature count and spec locations
- Show project-specs.json location
- List all created spec directories: !{bash ls -1d specs/*/ 2>/dev/null}
- Display summary:
  - Total features analyzed
  - Total specs created (spec.md, plan.md, tasks.md per feature)
  - JSON consolidation location: .planning/project-specs.json
  - Next steps: Review specs, run /planning:validate-specs

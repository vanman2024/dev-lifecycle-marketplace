---
description: Interactive multimodal wizard for comprehensive requirements gathering and spec generation
argument-hint: [--auto-continue]
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


**Arguments**: $ARGUMENTS

Goal: Conduct interactive wizard to gather requirements, process multimodal inputs, generate architecture docs, and create feature specs ready for implementation.

Core Principles:
- Multimodal first: Accept files, images, URLs, and text
- Progressive disclosure: Ask targeted questions based on inputs
- Comprehensive planning: Generate architecture before specs
- Automation: Script creates structure, agents fill content
- Infrastructure via plugins: No infra specs (plugins handle that)

Phase 1: Welcome and Initial Context
Goal: Gather project description and multimodal inputs

Actions:
- Display welcome message
- Create todo list tracking workflow phases
- Ask user for project description and file uploads:
  - "What would you like to build?"
  - "Upload any files (wireframes, docs, code, URLs) to help me understand:"
    - Screenshots/wireframes (PNG, JPG)
    - Requirements docs (PDF, Word, Markdown)
    - Existing code (zip, GitHub URL)
    - Competitor sites (URLs)
- Store initial description in `.wizard/initial-request.md`
- If user provides file paths or URLs, process them next phase

Phase 2: Process Multimodal Inputs (if provided)
Goal: Extract requirements from uploaded materials

Actions:
- If user provided files/images/URLs, invoke requirements-processor:

Task(description="Process uploaded inputs", subagent_type="planning:requirements-processor", prompt="You are the requirements-processor agent. Process all uploaded files, images, and URLs provided by the user.

Inputs to process: $USER_PROVIDED_FILES_AND_URLS

Extract:
- Features and capabilities
- User stories and workflows
- Technical constraints
- Integration requirements
- Data entities
- UI components

Return structured JSON with:
- extracted.features
- extracted.user_stories
- extracted.technical_constraints
- extracted.integrations
- extracted.data_entities
- confidence scores

Deliverable: Complete extraction report in JSON format")

- Save extracted data to `.wizard/extracted-requirements.json`
- Update todos

Phase 3: Structured Q&A Rounds
Goal: Gather additional context through targeted questions

Actions:
- Conduct 6-8 rounds using AskUserQuestion covering:
  - Project type and users
  - Core features (MVP vs. future)
  - Technical stack and integrations
  - Constraints (timeline, budget, team)
  - Success metrics and KPIs
- Save all Q&A to `docs/requirements/YYYY-MM-DD-project/02-wizard-qa.md`
- Update todos

Phase 4: Generate Architecture (BATCHED PARALLEL)
Goal: Create architecture docs using batched parallel agents for speed and UI stability

⚠️ CONSTRAINT: Maximum 10-12 agents per batch (UI breaks with >10)

Actions:
**Batch 1 (6 agents)**: Launch architecture + ADRs + roadmap
- Launch IN PARALLEL (one message, multiple Task calls):
  Task 1: Generate README.md + backend.md (system overview, Claude Agent SDK, MCP)
  Task 2: Generate data.md + ai.md (Supabase schema, AI architecture)
  Task 3: Generate security.md + integrations.md (auth, API keys, external services)
  Task 4: Generate infrastructure.md + frontend.md (deployment, optional dashboard)
  Task 5: Generate ADRs (decision-documenter agent)
  Task 6: Generate ROADMAP.md (roadmap-planner agent)

- Each agent receives same context:
  - Wizard requirements: docs/requirements/
  - Extracted data: .wizard/extracted-requirements.json
  - Q&A: docs/requirements/*/02-wizard-qa.md

- Agents work simultaneously (6 agents, UI-safe batch size)
- Verify all 8 architecture files + ADRs + roadmap created
- Update todos

Phase 4.5: Validate Architecture (CTO Review)
Goal: Multi-tier validation of generated architecture

Actions:
- Launch validator agents IN PARALLEL:

  Task 1: Technical validator (checks completeness, diagrams, security)
  Task 2: Cost validator (verifies budget constraints, estimates costs)
  Task 3: Timeline validator (confirms 1-3 month aggressive timeline feasible)

- Each validator outputs: validation-report-[type].md
- Launch CTO-level review agent:

  Task: CTO reviewer reads all architecture + validation reports
  - Identifies gaps, inconsistencies, risks
  - Provides executive summary
  - Outputs: docs/architecture/CTO-REVIEW.md

- If critical issues found: Display and ask user to proceed or regenerate
- Update todos

Phase 5: Create project.json and features.json
Goal: Generate project configuration and features registry from architecture docs

Actions:
**Step 1: Create .claude/project.json**
- Extract tech stack from architecture documents:
  - Framework: @docs/architecture/frontend.md (Next.js, React, Vue, etc.)
  - Backend: @docs/architecture/backend.md (FastAPI, Django, Express, etc.)
  - Database: @docs/architecture/data.md (PostgreSQL, Supabase, MongoDB, etc.)
  - AI Stack: @docs/architecture/ai.md (Vercel AI SDK, Claude Agent SDK, etc.)
  - Infrastructure: @docs/architecture/infrastructure.md (Auth, caching, monitoring, etc.)

- Generate project.json structure:
  ```json
  {
    "name": "project-name",
    "description": "from initial requirements",
    "frameworks": {
      "frontend": { "primary": "detected", "version": "detected", "language": "TypeScript" },
      "backend": { "primary": "detected", "version": "detected", "language": "Python" }
    },
    "ai_stack": {
      "sdks": ["detected from ai.md"],
      "providers": ["detected from ai.md"],
      "memory": "detected",
      "mcp_servers": []
    },
    "database": {
      "type": "detected",
      "provider": "detected",
      "orm": "detected"
    },
    "infrastructure": {
      "authentication": { "provider": "detected", "features": [] },
      "caching": { "provider": "detected", "strategy": "" },
      "monitoring": { "provider": "detected", "features": [] },
      "error_handling": { "provider": "detected" },
      "ci_cd": { "platform": "detected", "workflows": [] }
    },
    "detected_at": "current-date"
  }
  ```

- Write: !{bash cat > .claude/project.json <<'EOF' ... EOF}
- Verify: !{bash test -f .claude/project.json && echo "✅ Created" || echo "❌ Failed"}

**Step 2: Create features.json**
- Read feature-breakdown.json from Phase 4: @/tmp/feature-breakdown.json
- Transform to features.json format:
  ```json
  {
    "project": "project-name",
    "generated_at": "timestamp",
    "description": "from requirements",
    "source_documents": {
      "architecture": ["list of architecture docs"],
      "adr": ["list of ADRs"],
      "roadmap": "docs/ROADMAP.md"
    },
    "features": [
      {
        "id": "F001",
        "name": "feature name",
        "description": "from feature-breakdown",
        "priority": "P0/P1/P2",
        "phase": "MVP/Beta/Post-MVP",
        "complexity": "Simple/Moderate/Complex",
        "estimated_days": 2-3,
        "dependencies": ["other feature IDs"],
        "adr_references": []
      }
    ],
    "shared_context": {
      "tech_stack": ["from architecture"],
      "user_types": ["from requirements"],
      "data_entities": ["from data.md"]
    }
  }
  ```

- Write: !{bash cat > features.json <<'EOF' ... EOF}
- Verify: !{bash test -f features.json && jq '.features | length' features.json}

- Display completion:
  - "✅ Created .claude/project.json with detected tech stack"
  - "✅ Created features.json with [X] features"
  - "📋 Architecture planning complete!"
  - "Next step: Run /planning:init-project to generate feature specs"
  - "Then: Run /foundation:generate-infrastructure-specs for infrastructure specs"

- Update todos

Phase 6: Final Architecture Validation
Goal: Validate architecture planning is complete and ready for spec generation

Actions:
- Launch CTO reviewer for architecture approval:

  Task: CTO reviewer reads architecture planning package
  - All 8 architecture files (frontend.md, backend.md, data.md, ai.md, infrastructure.md, security.md, integrations.md, README.md)
  - All ADRs and ROADMAP.md
  - project.json (tech stack configuration)
  - features.json (feature breakdown)
  - Previous validation reports (if any warnings)
  - Wizard requirements and Q&A

  CTO validates:
  - Architecture is complete and coherent
  - Tech stack choices are appropriate
  - Features are well-defined and scoped
  - Infrastructure components identified
  - Security considerations documented
  - Plan is ready for spec generation

  Output: docs/FINAL-APPROVAL.md
  - Status: APPROVED | APPROVED_WITH_CHANGES | REJECTED
  - Executive summary of architecture plan
  - Critical issues (blockers)
  - Warnings (should fix before spec generation)
  - Recommendations (optional)
  - Go/no-go decision for proceeding to spec generation

- If REJECTED: Display issues and ask user to regenerate architecture
- If APPROVED_WITH_CHANGES: Display warnings and ask user to proceed or fix
- If APPROVED: Continue to finalization
- Update todos

Phase 7: Finalization
Goal: Complete wizard and prepare for spec generation

Actions:
- Update ROADMAP.md with final approval status
- Create summary report:
  - Features defined: X
  - Total estimated time: Y days
  - Architecture docs created:
    * docs/architecture/README.md
    * docs/architecture/backend.md
    * docs/architecture/frontend.md
    * docs/architecture/data.md
    * docs/architecture/ai.md
    * docs/architecture/infrastructure.md
    * docs/architecture/security.md
    * docs/architecture/integrations.md
  - ADRs: Z decisions documented
  - project.json: Created with tech stack
  - features.json: Created with feature breakdown
  - Approval status: APPROVED (from Phase 6)
  - Next steps: Run /planning:init-project to generate feature specs

- Save summary to `.wizard/completion-summary.md`
- Mark all todos complete

Phase 8: Summary
Goal: Display results and next steps

Actions:
- Display completion message:
  ```
  ✅ Architecture Planning Complete!

  Created Architecture Documentation:
  - docs/requirements/ (wizard Q&A inputs)
  - docs/architecture/README.md (system overview)
  - docs/architecture/backend.md (backend architecture)
  - docs/architecture/frontend.md (frontend architecture)
  - docs/architecture/data.md (database schema)
  - docs/architecture/ai.md (AI stack architecture)
  - docs/architecture/infrastructure.md (infrastructure components)
  - docs/architecture/security.md (security architecture)
  - docs/architecture/integrations.md (external integrations)
  - docs/adr/*.md (architectural decision records)
  - docs/ROADMAP.md (project roadmap)

  Created Configuration Files:
  - .claude/project.json (tech stack from architecture docs)
  - features.json (X features from breakdown)

  Next Steps:
  1. Review docs/FINAL-APPROVAL.md for validation results
  2. Run /planning:init-project to generate feature specs
  3. Run /foundation:generate-infrastructure-specs for infrastructure specs
  4. Begin implementation following the specs
  ```

- Update todos to completed

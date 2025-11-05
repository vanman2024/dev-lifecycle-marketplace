---
description: Interactive multimodal wizard for comprehensive requirements gathering and spec generation
argument-hint: [--auto-continue]
allowed-tools: Task, Read, Write, Bash(*), AskUserQuestion, TodoWrite
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

Phase 5: Generate Feature Specs (BATCHED PARALLEL)
Goal: Generate all feature specs using batched parallel execution

Actions:
**Batch 1 (10 agents)**: Launch feature specs 001-010
- Launch IN PARALLEL (one message, 10 Task calls):
  Task 1-10: feature-spec-writer agents for features 001-010

**Batch 2 (10 agents)**: Launch feature specs 011-020
- Launch IN PARALLEL (one message, 10 Task calls):
  Task 1-10: feature-spec-writer agents for features 011-020

- Each agent receives:
  - feature-breakdown.json entry for their feature
  - Architecture docs: docs/architecture/
  - ADRs: docs/adr/
  - Roadmap: docs/ROADMAP.md
  - Shared context from wizard requirements

- Total features: 20 (adjust based on actual feature count)
- Batch size: 10 agents (UI-safe)
- Expected time: 2-3 minutes per batch
- Verify: !{bash test -d specs/features && ls -d specs/features/*/ | wc -l}
- Update todos

Phase 6: Final Plan Validation (Complete Review)
Goal: Validate entire planning package before implementation

Actions:
- Launch CTO reviewer for final approval:

  Task: CTO reviewer reads complete planning package
  - All 8 architecture files
  - All ADRs and ROADMAP.md
  - All feature specs (specs/features/*/spec.md)
  - All tasks files (specs/features/*/tasks.md)
  - Previous validation reports (if any warnings)
  - Wizard requirements and Q&A

  CTO validates:
  - Specs align with architecture
  - Features are implementable
  - Dependencies properly mapped
  - No conflicts between specs
  - Plan is production-ready

  Output: docs/FINAL-APPROVAL.md
  - Status: APPROVED | APPROVED_WITH_CHANGES | REJECTED
  - Executive summary of complete plan
  - Critical issues (blockers)
  - Warnings (should fix)
  - Recommendations (optional)
  - Final go/no-go decision

- If REJECTED: Display issues and ask user to regenerate specs
- If APPROVED_WITH_CHANGES: Display warnings and ask user to proceed or fix
- If APPROVED: Continue to finalization
- Update todos

Phase 7: Finalization
Goal: Complete wizard and prepare for implementation

Actions:
- Update ROADMAP.md with final approval status
- Create summary report:
  - Features created: X
  - Total estimated time: Y days
  - Infrastructure: Handled by [plugin-name] Phase 0-2
  - Approval status: APPROVED (from Phase 6)
  - Next steps: Run /supervisor:init --all to create worktrees

- Save summary to `.wizard/completion-summary.md`
- Mark all todos complete

Phase 8: Summary
Goal: Display results and next steps

Actions:
- Display: Requirements in docs/requirements/, Architecture in docs/architecture/, ROADMAP.md created
- Display: X features created in specs/features/
- Display: Infrastructure handled by plugin (no infra specs)
- Display: Final approval status from CTO review
- Next steps: Review FINAL-APPROVAL.md, run /ai-tech-stack-1:build-full-stack-phase-0, then /supervisor:init --all
- If --auto-continue flag provided, automatically proceed to Phase 0

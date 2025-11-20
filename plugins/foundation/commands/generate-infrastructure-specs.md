---
description: Generate infrastructure specs from project.json infrastructure section
argument-hint: [project-path]
allowed-tools: Read(*), Write, Bash(*), Glob, Grep, TodoWrite, Task
---

**Arguments**: $ARGUMENTS

Goal: Generate infrastructure specifications from project.json in parallel (3-5 at a time), creating specs/infrastructure/ directories with phase-aware dependency ordering.

## Required Reference Document

**CRITICAL**: Read the infrastructure vs features classification guide:
`@~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/docs/INFRASTRUCTURE-VS-FEATURES.md`

This document defines what counts as infrastructure vs features and must be referenced when generating specs.

Core Principles:
- Read project.json as source of truth for infrastructure needs
- Generate specs ONLY for infrastructure components without specs
- **Process items by phase order** (Phase 0 first, then Phase 1, etc.)
- Process 3-5 infrastructure components at a time (batching)
- Include phase, depends_on, and blocks in generated spec frontmatter
- Mirror /planning:init-project pattern for consistency
- Reference INFRASTRUCTURE-VS-FEATURES.md for classification guidance

## Phase-Aware Generation

Infrastructure items are generated in dependency order:
- **Phase 0**: Items with no infrastructure dependencies (auth, sentry, indexing)
- **Phase 1**: Items that depend only on Phase 0 (error handling, celery, storage)
- **Phase 2**: Items that depend on Phase 0/1 (webhooks, payments, notifications)
- **Phase 3**: Items that depend on Phase 0/1/2 (subscriptions, reports)
- **Phase 4**: High-dependency items (voice AI, admin, ads)
- **Phase 5**: Final integration (health checks)

Phase 0: Check Existing Project Data
Goal: Verify project.json exists and contains infrastructure section

Actions:
- Create todo list using TodoWrite

- **CRITICAL: Read schema templates for consistent structure:**
  - Read project.json schema: @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-detection/templates/project-json-schema.json
  - Read features.json schema: @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/spec-management/templates/features-json-schema.json
  - These schemas define the exact structure for infrastructure phases
  - All generated specs MUST follow these schemas

- Determine project path (use $ARGUMENTS if provided, otherwise current directory)
- Check for project.json: !{bash test -f .claude/project.json && echo "✅ EXISTS" || echo "⚠️ MISSING"}
- If missing: Display error "Run /foundation:detect first to create project.json" and exit
- Read project.json: @.claude/project.json
- Extract infrastructure section
- Display: "Found [X] infrastructure components"

Phase 1: Create Phase Directory Structure
Goal: Set up phase-based folder organization

Actions:
- Create phase directories:
  !{bash mkdir -p specs/infrastructure/phase-0}
  !{bash mkdir -p specs/infrastructure/phase-1}
  !{bash mkdir -p specs/infrastructure/phase-2}
  !{bash mkdir -p specs/infrastructure/phase-3}
  !{bash mkdir -p specs/infrastructure/phase-4}
  !{bash mkdir -p specs/infrastructure/phase-5}
- Display: "Created phase directory structure"

Phase 2: Check Existing Infrastructure Specs
Goal: Determine which infrastructure components already have specs

Actions:
- List existing specs across all phase folders: !{bash find specs/infrastructure -name "spec.md" -type f 2>/dev/null | wc -l}
- Compare project.json infrastructure vs existing specs
- Filter to components WITHOUT specs
- Display: "Found [Y] components needing specs"
- If all have specs: Display "All infrastructure specs already exist" and exit

Phase 3: Prepare Infrastructure List
Goal: Extract infrastructure components that need specs, grouped by phase

Actions:
- Parse project.json infrastructure section
- Group components by their `phase` field (0-5)
- Create list of components needing specs, sorted by phase
- Batch size: 3-5 components at a time
- Number of batches: ceil(total / 5)
- Display: "Will generate [Y] specs in [Z] batches (Phase 0 first, then 1, 2, etc.)"

Phase 4: Parallel Infrastructure Spec Generation (Batch 1)
Goal: Generate first 3-5 infrastructure specs in parallel

Actions:
- Select first 3-5 components from list (prioritizing lower phases)
- Display: "Batch 1: Generating specs for [component1, component2, ...]"

For each component in BATCH 1, launch parallel infrastructure-writer agent:

Task(description="Generate infrastructure spec for authentication", subagent_type="foundation:infrastructure-writer", prompt="You are the infrastructure-writer agent. Create complete infrastructure specification for this component.

Component Data from project.json:
- Component ID: {id}
- Component name: {name}
- Phase: {phase}
- depends_on: {depends_on}
- blocks: {blocks}
- Configuration: Extract settings from project.json
- Tech stack: Extract from project.json

Your Task:
Create infrastructure spec in the PHASE FOLDER:

Directory: specs/infrastructure/phase-{phase}/{number}-{component-name}/
Files:
- spec.md: Infrastructure requirements with YAML frontmatter (id, phase, depends_on, blocks)
- setup.md: Setup instructions, environment variables, service configuration
- tasks.md: Implementation tasks (5 phases, numbered)

Requirements:
- Place spec in correct phase folder based on phase field
- Include YAML frontmatter with id, phase, depends_on, blocks
- Tech-agnostic where possible
- Reference project.json for specific tech choices
- Include security considerations
- Keep spec focused (200-300 lines)

Deliverable: Complete infrastructure spec directory in phase folder")

**Launch 3-5 Task() calls in parallel for each component in batch 1**

Phase 5: Wait and Validate Batch 1
Goal: Ensure all batch 1 specs generated successfully

Actions:
- Wait for all parallel Task() completions
- Validate each generated spec exists in correct phase folder
- Check file structure (spec.md, setup.md, tasks.md)
- Display: "Batch 1 complete: [X] specs generated"

Phase 6: Continue Additional Batches (if needed)
Goal: Generate remaining infrastructure specs in batches

Actions:
- If more components remain: Repeat Phase 4-5 for Batch 2, Batch 3, etc.
- Process 3-5 at a time until all components have specs
- Display progress after each batch

Phase 7: Summary
Goal: Report what was generated

Actions:
- Mark all todos complete
- Count total infrastructure specs created per phase folder
- Display:

  **✅ Generated: [N] infrastructure specs**

  **Directory Structure:**
  ```
  specs/infrastructure/
  ├── phase-0/  ([X] items - Core Foundation)
  │   ├── 001-authentication/
  │   ├── 003-sentry-error-tracking/
  │   └── ...
  ├── phase-1/  ([X] items - First Dependencies)
  │   ├── 009-error-handling/
  │   └── ...
  ├── phase-2/  ([X] items)
  ├── phase-3/  ([X] items)
  ├── phase-4/  ([X] items)
  └── phase-5/  ([X] items - Final Integration)
  ```

  **Build Order:** Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5

  **Next Steps:**
  1. Review infrastructure specs
  2. Run /foundation:generate-workflow for infrastructure workflow
  3. Implement infrastructure by phase using /implementation:execute

  **Difference from Feature Specs:**
  - /foundation:generate-infrastructure-specs = Infrastructure (from project.json)
  - /planning:init-project = Features (from features.json)

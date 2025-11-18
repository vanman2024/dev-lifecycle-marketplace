---
description: Generate infrastructure specs from project.json infrastructure section
argument-hint: [project-path]
allowed-tools: Read(*), Write, Bash(*), Glob, Grep, TodoWrite, Task
---

**Arguments**: $ARGUMENTS

Goal: Generate infrastructure specifications from project.json in parallel (3-5 at a time), creating specs/infrastructure/ directories similar to how /planning:init-project creates feature specs.

Core Principles:
- Read project.json as source of truth for infrastructure needs
- Generate specs ONLY for infrastructure components without specs
- Process 3-5 infrastructure components at a time (batching)
- Mirror /planning:init-project pattern for consistency

Phase 0: Check Existing Project Data
Goal: Verify project.json exists and contains infrastructure section

Actions:
- Create todo list using TodoWrite
- Determine project path (use $ARGUMENTS if provided, otherwise current directory)
- Check for project.json: !{bash test -f .claude/project.json && echo "✅ EXISTS" || echo "⚠️ MISSING"}
- If missing: Display error "Run /foundation:detect first to create project.json" and exit
- Read project.json: @.claude/project.json
- Extract infrastructure section
- Display: "Found [X] infrastructure components"

Phase 1: Check Existing Infrastructure Specs
Goal: Determine which infrastructure components already have specs

Actions:
- Check if specs/infrastructure/ exists: !{bash test -d specs/infrastructure && echo "✅ EXISTS" || echo "⚠️ MISSING"}
- If exists, list existing specs: !{bash ls -d specs/infrastructure/*/ 2>/dev/null}
- Compare project.json infrastructure vs existing specs
- Filter to components WITHOUT specs
- Display: "Found [Y] components needing specs"
- If all have specs: Display "All infrastructure specs already exist" and exit

Phase 2: Prepare Infrastructure List
Goal: Extract infrastructure components that need specs

Actions:
- Parse project.json infrastructure section
- Extract components (auth, caching, monitoring, errorHandling, rateLimiting, backup, etc.)
- Create list of components needing specs
- Batch size: 3-5 components at a time
- Number of batches: ceil(total / 5)
- Display: "Will generate [Y] specs in [Z] batches"

Phase 3: Parallel Infrastructure Spec Generation (Batch 1)
Goal: Generate first 3-5 infrastructure specs in parallel

Actions:
- Select first 3-5 components from list
- Display: "Batch 1: Generating specs for [component1, component2, ...]"

For each component in BATCH 1, launch parallel infrastructure-writer agent:

Task(description="Generate infrastructure spec for authentication", subagent_type="foundation:infrastructure-writer", prompt="You are the infrastructure-writer agent. Create complete infrastructure specification for this component.

Component Data from project.json:
- Component type: Extract from infrastructure section
- Configuration: Extract settings from project.json
- Tech stack: Extract from project.json

Your Task:
Create infrastructure spec following this structure:

Directory: specs/infrastructure/{number}-{component-name}/
Files:
- spec.md: Infrastructure requirements, configuration, dependencies
- setup.md: Setup instructions, environment variables, service configuration
- tasks.md: Implementation tasks (5 phases, numbered)

Requirements:
- Tech-agnostic where possible
- Reference project.json for specific tech choices
- Include security considerations
- Provide clear setup instructions
- Keep spec focused (200-300 lines)

Deliverable: Complete infrastructure spec directory")

**Launch 3-5 Task() calls in parallel for each component in batch 1**

Phase 4: Wait and Validate Batch 1
Goal: Ensure all batch 1 specs generated successfully

Actions:
- Wait for all parallel Task() completions
- Validate each generated spec exists
- Check file structure (spec.md, setup.md, tasks.md)
- Display: "Batch 1 complete: [X] specs generated"

Phase 5: Continue Additional Batches (if needed)
Goal: Generate remaining infrastructure specs in batches

Actions:
- If more components remain: Repeat Phase 3-4 for Batch 2, Batch 3, etc.
- Process 3-5 at a time until all components have specs
- Display progress after each batch

Phase 6: Summary
Goal: Report what was generated

Actions:
- Mark all todos complete
- Count total infrastructure specs created
- Display:

  **✅ Generated: [N] infrastructure specs**

  **Location:** specs/infrastructure/

  **Components:**
  - 001-authentication/
  - 002-redis-caching/
  - 003-error-handling/
  - etc.

  **Next Steps:**
  1. Review infrastructure specs
  2. Run /foundation:generate-workflow for infrastructure workflow
  3. Implement infrastructure using /implementation:execute

  **Difference from Feature Specs:**
  - /foundation:generate-infrastructure-specs = Infrastructure (from project.json)
  - /planning:init-project = Features (from features.json)

---
description: Generate feature implementation workflow from features.json and specs
argument-hint: [project-path]
allowed-tools: Read(*), Write, Bash(*), Glob, Grep, TodoWrite, mcp__airtable__search_records, mcp__airtable__get_record
---

**Arguments**: $ARGUMENTS

Goal: Generate ongoing feature implementation workflow from features.json and specs/ directory. This workflow guides feature-by-feature implementation with tech-stack-aware commands.

Core Principles:
- Features.json is source of truth for planned features
- Specs provide detailed requirements
- Workflow includes feature-specific commands
- Separate from foundation infrastructure workflow

Phase 1: Discovery
Goal: Read features.json and specs/ to understand what needs to be built

Actions:
- Create todo list using TodoWrite
- Determine project path (use $ARGUMENTS if provided, otherwise current directory)
- Check if features.json exists:
  !{bash test -f features.json && echo "exists" || echo "missing"}
- If missing: Display error and exit
- Read features.json:
  @features.json
- Extract all feature IDs, names, status, priority, dependencies
- Count features by status (planned, in-progress, complete)

Phase 2: Load Specifications
Goal: Read detailed specs for each feature

Actions:
- List all spec directories:
  !{bash ls -d specs/features/[0-9][0-9][0-9]-*/ 2>/dev/null}
- For each feature in features.json:
  - Check if spec directory exists
  - If exists: Read spec.md and tasks.md
  - Extract: Requirements, tech stack components used, implementation notes
  - Store per-feature context

Phase 3: Fetch Available Commands from Airtable
Goal: Query tech stack in Airtable to get ALL available commands for implementation

Actions:
- Read .claude/project.json to get tech stack name
  @.claude/project.json
- Extract tech_stack_name from project.json
- Use Airtable MCP to search for tech stack:
  * Search Tech Stacks table for matching stack name
  * Get stack record ID
- For EACH lifecycle phase (Planning, Iteration, Quality, Testing, Deployment):
  * Get linked plugin record from tech stack
  * Get all command records linked to that plugin
  * Extract command names, descriptions, argument hints
  * Store in AVAILABLE_COMMANDS map organized by plugin
- Result: Complete list of implementation commands available for this tech stack
- Display: "Found [N] commands across [M] plugins"

Phase 4: Generate Workflow Document
Goal: Create FEATURE-IMPLEMENTATION-WORKFLOW.md with feature-specific commands

Actions:
- Determine workflow filename: FEATURE-IMPLEMENTATION-WORKFLOW.md
- For each feature (ordered by priority and dependencies):
  * Create section: Feature [ID]: [Name]
  * Add status, priority, dependencies, spec path
  * Extract requirements from spec.md
  * Match requirements to AVAILABLE_COMMANDS from Phase 3:
    - If feature needs database → Use /supabase:* commands
    - If feature needs auth → Use /clerk:* commands
    - If feature needs memory → Use /mem0:* commands
    - If feature needs backend → Use /fastapi-backend:* commands
    - If feature needs frontend → Use /nextjs-frontend:* commands
  * Layer commands by phase:
    - Setup: /iterate:tasks [ID]
    - Implementation: Matched commands from AVAILABLE_COMMANDS
    - Validation: /quality:validate-code [ID], /testing:test, /iterate:sync [ID]
- Include summary: Total features, status breakdown, available commands
- Write workflow document to FEATURE-IMPLEMENTATION-WORKFLOW.md

Phase 5: Summary
Goal: Report what was generated

Actions:
- Mark all todos complete
- Display:
  **✅ Generated: FEATURE-IMPLEMENTATION-WORKFLOW.md**

  **Contents:**
  - [N] features documented
  - [X] complete, [Y] in-progress, [Z] planned
  - Tech-stack-aware commands for each feature

  **Next Steps:**
  1. Review workflow document
  2. Follow feature-by-feature implementation commands
  3. Update features.json status as you progress
  4. Re-run this command when adding new features

  **Difference from Foundation Workflow:**
  - `/foundation:generate-workflow` = Infrastructure setup (one-time)
  - `/planning:generate-feature-workflow` = Feature implementation (ongoing)

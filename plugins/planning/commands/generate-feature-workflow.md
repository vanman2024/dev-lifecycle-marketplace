---
description: Generate feature implementation workflow from features.json and specs
argument-hint: [project-path]
allowed-tools: Read(*), Write, Bash(*), Glob, Grep, TodoWrite, mcp__airtable__search_records, mcp__airtable__get_record
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
- Navigate to planning skill directory:
  !{cd ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/feature-workflow-generation}
- Execute Python script to query Airtable:
  !{python3 scripts/generate-feature-workflow.py}
- Script returns JSON with:
  * tech_stack: Tech stack name from project.json
  * features: Array of features from features.json with spec content
  * available_commands: All commands available for the tech stack
  * plugins: Plugin details organized by lifecycle phase
- Parse JSON output and extract:
  * AVAILABLE_COMMANDS: Map of commands organized by plugin
  * FEATURES_DATA: Features with spec content
  * TECH_STACK_NAME: Tech stack being used
- Handle errors:
  * If "error" in JSON: Display error message and exit
  * If missing features.json: Suggest running /planning:add-feature
  * If missing project.json: Suggest running /foundation:detect
  * If Airtable fails: Fall back to filesystem-based command discovery
- Display: "Found [N] commands across [M] plugins for [TECH_STACK_NAME]"

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

---
description: Generate feature implementation workflow from features.json and specs
argument-hint: [project-path] [--feature <id>|--priority <P0|P1|P2>|--status <status>|--split]
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

**Flags**:
- `--feature <id>`: Generate workflow for specific feature only (e.g., F001)
- `--priority <level>`: Filter by priority (P0, P1, P2)
- `--status <status>`: Filter by status (planned, in-progress, completed)
- `--split`: Generate separate files per feature (F001-WORKFLOW.md, F002-WORKFLOW.md, etc.)
- Default (no flags): All features in one FEATURE-IMPLEMENTATION-WORKFLOW.md

Phase 0.5: Parse Flags
Goal: Parse command arguments and determine filtering scope

Actions:
- Create todo list using TodoWrite
- Parse $ARGUMENTS for flags:
  * Extract `--feature <id>`: FEATURE_FILTER="<id>"/null
  * Extract `--priority <level>`: PRIORITY_FILTER="<level>"/null
  * Extract `--status <status>`: STATUS_FILTER="<status>"/null
  * Extract `--split`: SPLIT_MODE=true/false
  * Extract remaining as PROJECT_PATH (if provided)
- Store parsed values:
  * FEATURE_FILTER (string or null)
  * PRIORITY_FILTER (string or null)
  * STATUS_FILTER (string or null)
  * SPLIT_MODE (boolean)
  * PROJECT_PATH (string or current directory)
- Display: "Scope: {All features|Feature: <id>|Priority: <level>|Status: <status>} {Split mode: {yes|no}}"

Phase 1: Discovery
Goal: Read features.json and specs/ to understand what needs to be built

Actions:
- Change to PROJECT_PATH directory (from Phase 0.5)
- Check if features.json exists:
  !{bash test -f features.json && echo "exists" || echo "missing"}
- If missing: Display error and exit
- Read features.json:
  @features.json
- Extract all feature IDs, names, status, priority, dependencies
- **Apply filters** (from Phase 0.5):
  * If FEATURE_FILTER set: Only include matching feature ID
  * If PRIORITY_FILTER set: Only include matching priority (P0, P1, P2)
  * If STATUS_FILTER set: Only include matching status
  * Store filtered features in FILTERED_FEATURES array
- Count filtered features: Display "Found {N} features matching criteria"
- If no features match filters: Display error and exit

Phase 2: Load Specifications
Goal: Read detailed specs for each filtered feature

Actions:
- List all spec directories:
  !{bash ls -d specs/features/[0-9][0-9][0-9]-*/ 2>/dev/null}
- **For each feature in FILTERED_FEATURES** (not all features):
  - Check if spec directory exists
  - If exists: Read spec.md and tasks.md
  - Extract: Requirements, tech stack components used, implementation notes
  - Store per-feature context
- Display: "Loaded {N} specifications for filtered features"

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
Goal: Create feature workflow document(s) based on SPLIT_MODE

Actions:
- Determine workflow file strategy:
  * If SPLIT_MODE=true: Generate separate files per feature ({FEATURE_ID}-WORKFLOW.md)
  * If SPLIT_MODE=false: Single file (FEATURE-IMPLEMENTATION-WORKFLOW.md)
  * If FEATURE_FILTER set: Single file ({FEATURE_ID}-WORKFLOW.md)

- **If SPLIT_MODE=true**:
  - For each feature in FILTERED_FEATURES:
    * Create file: {FEATURE_ID}-WORKFLOW.md
    * Generate workflow for THAT feature only
    * Include: Feature header, requirements, matched commands, validation
  - Write each file separately
  - Track created files in CREATED_FILES array

- **If SPLIT_MODE=false** (default):
  - Create single file: FEATURE-IMPLEMENTATION-WORKFLOW.md
  - For each feature in FILTERED_FEATURES (ordered by priority and dependencies):
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
  - Write workflow document

- Display: "Generated {N} workflow file(s)"

Phase 5: Summary
Goal: Report what was generated

Actions:
- Mark all todos complete
- Display summary based on what was generated:

**If SPLIT_MODE=true**:
  ```
  **✅ Generated {N} workflow files:**
  {List each file created}

  **Filtering:**
  - Feature filter: {FEATURE_FILTER or "None"}
  - Priority filter: {PRIORITY_FILTER or "None"}
  - Status filter: {STATUS_FILTER or "None"}

  **Contents per file:**
  - 1 feature documented
  - Tech-stack-aware commands
  - Implementation steps
  ```

**If SPLIT_MODE=false**:
  ```
  **✅ Generated: FEATURE-IMPLEMENTATION-WORKFLOW.md**

  **Filtering:**
  - Feature filter: {FEATURE_FILTER or "None"}
  - Priority filter: {PRIORITY_FILTER or "None"}
  - Status filter: {STATUS_FILTER or "None"}

  **Contents:**
  - [N] features documented
  - [X] complete, [Y] in-progress, [Z] planned
  - Tech-stack-aware commands for each feature
  ```

**Always display**:
  ```
  **Next Steps:**
  1. Review workflow document(s)
  2. Follow feature-by-feature implementation commands
  3. Update features.json status as you progress
  4. Re-run this command when adding new features

  **Difference from Foundation Workflow:**
  - `/foundation:generate-workflow` = Infrastructure setup (one-time)
  - `/planning:generate-feature-workflow` = Feature implementation (ongoing)

  **Examples:**
  - /planning:generate-feature-workflow --feature F001
  - /planning:generate-feature-workflow --priority P0
  - /planning:generate-feature-workflow --status in-progress
  - /planning:generate-feature-workflow --split
  ```

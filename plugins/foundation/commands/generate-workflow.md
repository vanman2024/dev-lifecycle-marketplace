---
description: Generate infrastructure setup workflow (foundation, planning docs, database) from tech stack
argument-hint: <tech-stack-name> [--full|--summary|--phase <name>]
allowed-tools: Read, Write, Bash, Skill, mcp__airtable
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


**Arguments**: $ARGUMENTS (optional - auto-detects if not provided)

Goal: Generate INFRASTRUCTURE setup workflow for project initialization. This covers foundation, planning documentation, and database setup ONLY.

**Scope Clarification**:
- **This command** (`/foundation:generate-workflow`): Infrastructure setup (one-time)
  * Foundation (init, detect, env setup)
  * Planning docs (architecture, ADRs, specs structure)
  * Database & Auth (Supabase, RLS policies)

- **For feature implementation**: Use `/planning:generate-feature-workflow` instead
  * Feature-by-feature workflows from features.json
  * Implementation commands matched to requirements
  * Quality and testing validation steps

**Flags**:
- `--full`: Include all 6 phases (Foundation → Implementation → Quality → Testing → Deployment → Iteration)
- `--summary`: Phases only, no command details (~50 lines)
- `--phase <name>`: Generate specific phase only (Foundation|Planning|Database|Implementation|Quality|Testing|Deployment)
- Default (no flag): Infrastructure only (Foundation, Planning, Database)

Phase 1: Load Knowledge
Goal: Load workflow generation patterns and phasing knowledge

Actions:
- Load skill: !{skill workflow-generation}
- Display: "✅ Loaded workflow generation knowledge"
- This provides patterns for:
  * Phase organization
  * Command classification
  * Dependency management
  * Project context reading
  * Completion detection

Phase 2: Detect or Select Tech Stack
Goal: Determine which tech stack this project uses

Actions:
- If $ARGUMENTS provided:
  - Use specified stack name directly
  - Store: STACK_NAME="$ARGUMENTS"
  - Skip to Phase 3

- If NO $ARGUMENTS (auto-detect mode):
  - Scan current directory for tech indicators:
    !{bash test -f package.json && grep -q "next" package.json && echo "nextjs:detected" || true}
    !{bash test -f requirements.txt && grep -q "fastapi" requirements.txt && echo "fastapi:detected" || true}
    !{bash test -d supabase && echo "supabase:detected" || true}
    !{bash grep -r "vercel.*ai" package.json 2>/dev/null && echo "vercel-ai-sdk:detected" || true}

  - Query ALL tech stacks from Airtable:
    !{Use mcp__airtable to list all records from Tech Stacks table tblG07GusbRMJ9h1I}

  - Match detected frameworks to tech stack components
  - Select best match (highest score)
  - Display: "Auto-detected: [Stack Name] (X% match based on your files)"
  - Ask user to confirm or choose different stack

- Store selected tech stack name as STACK_NAME

Phase 2.5: Parse Flags and Determine Scope
Goal: Parse command flags to determine what to include in workflow

Actions:
- Parse $ARGUMENTS for flags:
  * Extract `--full` flag: FULL_MODE=true/false
  * Extract `--summary` flag: SUMMARY_MODE=true/false
  * Extract `--phase <name>` flag: PHASE_FILTER="<name>"/null
  * Extract remaining as STACK_NAME (if not already set from Phase 2)

- Determine workflow scope:
  * If `--full`: INCLUDE_PHASES=["Foundation", "Planning", "Database", "Implementation", "Quality", "Testing", "Deployment", "Iteration"]
  * If `--phase <name>`: INCLUDE_PHASES=[<name>]
  * If `--summary`: INCLUDE_PHASES=All, SUMMARY_MODE=true
  * **Default** (no flags): INCLUDE_PHASES=["Foundation", "Planning", "Database"]

- Store flags:
  * FULL_MODE (boolean)
  * SUMMARY_MODE (boolean)
  * PHASE_FILTER (string or null)
  * INCLUDE_PHASES (array)

- Display: "Scope: {Infrastructure only|Full workflow|Summary|Phase: <name>}"

Phase 3: Get Raw Data from Airtable
Goal: Query Airtable and validate commands

Actions:
- Display: "Querying Airtable for commands..."
- Run Python script: !{bash python3 ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/workflow-generation/scripts/generate-workflow-doc.py "$STACK_NAME"}
- Parse JSON output
- Store in memory:
  * tech_stack info (name, description, use cases)
  * plugins array (with commands, agents, skills)
  * validation warnings

- If validation warnings exist:
  - Display: "⚠️  Validation Warnings:"
  - List each warning
  - Explain: "These are informational - workflow will still be generated"

- Display: "✅ Retrieved data for {N} plugins with {M} total commands"

Phase 4: Read Project Context (Intelligence)
Goal: Understand current project state and architecture

Actions:
- Display: "Reading project context..."

- **MUST READ**: .claude/project.json
  !{Read .claude/project.json}
  - Extract: tech stack, frameworks, architecture pattern, deployment targets
  - This drives ALL subsequent decisions

- **IF EXISTS**: docs/architecture/
  !{bash ls docs/architecture/*.md 2>/dev/null || echo "No architecture docs found"}
  - If found: Read key architecture files
  - Extract: system design, component relationships, data flows

- **IF EXISTS**: docs/adr/
  !{bash ls docs/adr/*.md 2>/dev/null || echo "No ADRs found"}
  - If found: Read recent ADRs (last 5)
  - Extract: key architecture decisions, rationale, patterns

- **IF EXISTS**: features.json (PRIORITY - read this first!)
  !{bash test -f features.json && echo "features.json:exists" || echo "features.json:missing"}
  - If found: Read features.json
  - Extract: All features, their status, priorities, dependencies
  - Use this for Feature Status section in workflow

- **IF EXISTS**: specs/
  !{bash ls specs/*/spec.md 2>/dev/null || echo "No specs found"}
  - If found: Count specs, list feature names
  - Extract: what features exist, current state

- **Detect current state** (file existence):
  !{bash test -f package.json && echo "package.json:exists" || echo "package.json:missing"}
  !{bash test -f requirements.txt && echo "requirements.txt:exists" || echo "requirements.txt:missing"}
  !{bash test -d supabase && echo "supabase:exists" || echo "supabase:missing"}
  !{bash test -d specs && echo "specs:exists" || echo "specs:missing"}
  !{bash test -d docs/architecture && echo "architecture:exists" || echo "architecture:missing"}
  !{bash test -f docs/ROADMAP.md && echo "roadmap:exists" || echo "roadmap:missing"}
  !{bash test -f .env && echo "env:exists" || echo "env:missing"}

- Display: "✅ Project context loaded"

Phase 4.5: Preserve Existing Progress (CRITICAL)
Goal: Read existing workflow file and preserve manual checkmarks

Actions:
- Determine expected workflow filename:
  * Use project name from project.json if available
  * Otherwise: Use tech stack name
  * Format: PROJECT-NAME-WORKFLOW.md
  * Store as: WORKFLOW_FILE

- Check if workflow file exists:
  !{bash test -f "$WORKFLOW_FILE" && echo "exists" || echo "missing"}

- **If exists** (REGENERATION mode):
  - Display: "📖 Reading existing workflow to preserve progress..."
  - Read existing workflow file: @{WORKFLOW_FILE}

  - Parse for command checkmarks:
    * Look for lines with command format: `- [✅/🔄/□] /plugin:command`
    * Extract: command name + status emoji
    * Store in memory map: PRESERVED_STATUS["/plugin:command"] = "✅" or "🔄" or "□"
    * Count preserved items

  - Parse for feature checkmarks (if Feature Status section exists):
    * Look for lines with feature format: `- [✅/🔄/□] F001: Feature Name`
    * Extract: feature ID + status emoji
    * Store: PRESERVED_FEATURES["F001"] = "✅" or "🔄" or "□"

  - Display: "✅ Preserved {N} command statuses and {M} feature statuses"

- **If missing** (FIRST-TIME mode):
  - Display: "📝 First-time generation (no existing workflow to preserve)"
  - Initialize empty: PRESERVED_STATUS = {}
  - Initialize empty: PRESERVED_FEATURES = {}

Phase 5: Organize Commands (Claude's Intelligence)
Goal: Apply skill knowledge to organize commands into phases

Actions:
- Using workflow-generation skill patterns:

  **Categorize each command** into phases:
  - Foundation: init, setup, detect, validate, env, structure keywords
  - Planning: wizard, spec, architecture, decide, roadmap keywords
  - Database: create-schema, add-rls, add-auth, deploy-migration keywords
  - Implementation: add, create, integrate, build keywords
  - Quality: validate-code, code-reviewer, task-validator keywords
  - Testing: test, playwright, newman keywords
  - Deployment: deploy, prepare, cicd, monitor keywords
  - Iteration: enhance, refactor, adjust, sync keywords

  **Apply INCLUDE_PHASES filter** (from Phase 2.5):
  - Only include commands in phases listed in INCLUDE_PHASES
  - If INCLUDE_PHASES=["Foundation", "Planning", "Database"]: Skip Implementation, Quality, Testing, Deployment, Iteration commands
  - If PHASE_FILTER set: Only include commands from that specific phase
  - Display: "Filtered to {N} phases: {INCLUDE_PHASES}"

  **Determine completion status** for each command (PRESERVES EXISTING):
  - **FIRST**: Check PRESERVED_STATUS map (from Phase 4.5)
    * If command exists in PRESERVED_STATUS: USE that status (user's manual tracking)
    * This preserves checkmarks from previous workflow
  - **SECOND**: If NOT in PRESERVED_STATUS (new command): Auto-detect
    * ✅ = File evidence suggests complete
    * 🔄 = Partial implementation detected
    * □ = Not yet done
  - **Priority**: Manual checkmarks > Auto-detection

  **Apply dependency rules**:
  - Foundation always first (no dependencies)
  - Planning requires foundation
  - Implementation requires planning
  - Quality requires (partial) implementation
  - Deployment requires quality
  - Iteration throughout

  **Include project context**:
  - Add tech stack summary from project.json
  - Include relevant ADR summaries
  - Add architecture highlights
  - Include business metrics if present in docs

- Display: "✅ Commands organized into {N} phases"

Phase 6: Generate Workflow Document
Goal: Create final project-aware workflow markdown

Actions:
- Determine output filename:
  * Use project name from project.json if available
  * Otherwise: Use tech stack name
  * If PHASE_FILTER set: Format as PROJECT-NAME-{PHASE_FILTER}-WORKFLOW.md
  * If default (infrastructure): Format as PROJECT-NAME-INFRASTRUCTURE-WORKFLOW.md
  * If --full: Format as PROJECT-NAME-FULL-WORKFLOW.md
  * If --summary: Format as PROJECT-NAME-SUMMARY.md

- Determine workflow title based on scope:
  * Infrastructure only: "Infrastructure Setup Workflow"
  * Full workflow: "Full-Stack Development Workflow"
  * Summary: "Workflow Summary"
  * Specific phase: "{Phase Name} Workflow"

- Generate workflow with sections:

  **1. Project Overview** (skip if SUMMARY_MODE):
  ```markdown
  # {Project Name} - {Workflow Title}

  **Auto-generated**: {Date}
  **Tech Stack**: {From project.json}
  **Scope**: {Infrastructure only|Full workflow|{Phase name}|Summary}
  **Project Phase**: {From project state detection}

  ---

  ## Tech Stack Overview
  {From project.json and Airtable}

  ## Architecture Overview
  {From docs/architecture/ and ADRs}

  ## Progress Legend
  - ✅ = Completed (auto-detected from your files)
  - □ = Not started / To do
  - 🔄 = In progress (partial implementation detected)

  ## Workflow Separation
  - This workflow: Infrastructure setup (one-time)
  - For features: Use /planning:generate-feature-workflow
  ```

  **2. Phased Commands** (Respecting INCLUDE_PHASES):

  **If SUMMARY_MODE**: Only show phase headers with command counts:
  ```markdown
  ## Phase 1: Foundation & Project Setup (N commands)
  ## Phase 2: Planning & Architecture (M commands)
  ## Phase 3: Database & Auth (K commands)
  ```

  **If NOT SUMMARY_MODE**: Include full command details
  ```markdown
  ## Phase 1: Foundation & Project Setup
  {Foundation commands IF "Foundation" in INCLUDE_PHASES}

  ## Phase 2: Planning & Architecture
  {Planning commands IF "Planning" in INCLUDE_PHASES}

  ## Phase 3: Database & Auth
  {Database commands IF "Database" in INCLUDE_PHASES}

  ## Phase 4: Implementation
  {Implementation commands IF "Implementation" in INCLUDE_PHASES}

  ## Phase 5: Quality
  {Quality commands IF "Quality" in INCLUDE_PHASES}

  ## Phase 6: Testing
  {Testing commands IF "Testing" in INCLUDE_PHASES}

  ## Phase 7: Deployment
  {Deployment commands IF "Deployment" in INCLUDE_PHASES}

  ## Phase 8: Iteration & Enhancement
  {Iteration commands IF "Iteration" in INCLUDE_PHASES}
  ```

  **2.5. Feature Status** (NEW - if features.json exists):
  ```markdown
  ## Feature Implementation Status

  {Read features.json if it exists}
  {For each feature, determine status:}
  - **FIRST**: Check PRESERVED_FEATURES["F{id}"] (from Phase 4.5)
    * If exists: Use preserved status emoji
  - **SECOND**: If NOT preserved: Use status from features.json
  - **THIRD**: If no features.json: Auto-detect from file existence

  {Display:}
  - {status emoji} F{id}: {name} ({priority})
    - Status: {from PRESERVED_FEATURES or features.json}
    - Completion: {auto-detect from file existence}

  Example:
  - ✅ F001: Google File Search RAG (P0)
    - Status: completed
    - Files: backend/services/file_search.py ✓
  - 🔄 F002: Claude Agent SDK (P0)
    - Status: in-progress
    - Files: backend/claude_agent/ (partial)
  - □ F003: Intelligent Routing (P1)
    - Status: not-started
  ```

  **3. Project-Specific Context**:
  ```markdown
  ## Current Project Status Summary
  {What's done, what's in progress, what's next}

  ## Key Architecture Decisions
  {Relevant ADR summaries}

  ## Business Metrics
  {If found in docs}
  ```

  **4. Footer**:
  ```markdown
  ---

  **Regenerate this workflow:**
  ```bash
  /foundation:generate-workflow "{STACK_NAME}"
  ```
  ```

- Write to: {OUTPUT_FILE}

Phase 7: Summary
Goal: Report results to user

Actions:
- Display: ""
- Display: "✅ Workflow generated successfully!"
- Display: ""
- Display: "📄 File: {OUTPUT_FILE}"
- Display: ""
- If PRESERVED_STATUS was loaded (regeneration mode):
  - Display: "🔄 Mode: REGENERATED (preserved {N} existing checkmarks)"
  - Display: "   - {P} commands kept their status from previous workflow"
  - Display: "   - {Q} new commands added from Airtable"
- If first-time generation:
  - Display: "📝 Mode: FIRST-TIME GENERATION"
- Display: ""
- Display: "📊 Stats:"
- Display: "   - {N} total phases"
- Display: "   - {M} total commands"
- Display: "   - {X} completed ✅"
- Display: "   - {Y} in progress 🔄"
- Display: "   - {Z} to do □"
- Display: ""
- Display: "View with: cat {OUTPUT_FILE}"
- Display: ""
- Display: "🔄 Execute phases in separate terminals for parallel work!"
- Display: "   Terminal 1: Run Phase 1 commands"
- Display: "   Terminal 2: Run Phase 2 commands"
- Display: "   etc."
- Display: ""

**Error Handling:**
- Tech stack not found → list available stacks from Airtable
- Airtable connection fails → show troubleshooting steps
- Plugin mapping incomplete → warn and continue
- No project.json found → warn but continue with defaults
- Python script fails → show error and suggest fixes

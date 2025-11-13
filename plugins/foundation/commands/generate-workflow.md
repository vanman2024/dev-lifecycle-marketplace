---
description: Query Airtable for tech stack and generate complete workflow document
argument-hint: <tech-stack-name>
allowed-tools: Read, Write, Bash, mcp__airtable
---

**Arguments**: $ARGUMENTS

Goal: Generate comprehensive workflow document from Airtable tech stack configuration showing ALL commands (dev lifecycle + tech-specific) in execution order.

Phase 1: Query Airtable
Goal: Get tech stack and plugin data

Actions:
- Validate $ARGUMENTS provided (show usage if empty)
- Query Airtable base `appHbSB7WhT1TxEQb`:
  - Tech Stacks table `tblG07GusbRMJ9h1I` with filter: `FIND("$ARGUMENTS", {Stack Name})`
  - Plugins table `tblVEI2x2xArVx9ID` with maxRecords=50
- Extract tech stack record with all plugin IDs
- Build mapping: Record ID → Plugin Name

Phase 2: Detect Current State
Goal: Scan current directory to see what's already been done

Actions:
- Detect completed setup:
  !{bash test -f .claude/project.json && echo "foundation-init:done" || echo "foundation-init:todo"}
  !{bash test -f package.json && echo "nextjs-init:done" || echo "nextjs-init:todo"}
  !{bash test -f requirements.txt && echo "fastapi-init:done" || echo "fastapi-init:todo"}
  !{bash test -d supabase && echo "supabase-init:done" || echo "supabase-init:todo"}
  !{bash test -d specs && echo "planning-wizard:done" || echo "planning-wizard:todo"}
  !{bash test -d docs/architecture && echo "architecture:done" || echo "architecture:todo"}
  !{bash test -f docs/ROADMAP.md && echo "roadmap:done" || echo "roadmap:todo"}
  !{bash test -d supabase/migrations && echo "schema-deployed:done" || echo "schema-deployed:todo"}
  !{bash test -f .env && echo "env-configured:done" || echo "env-configured:todo"}

- Store detection results for Phase 3

Phase 3: Generate Workflow with Smart Checkboxes
Goal: Create workflow markdown from Airtable with auto-detected completion status

Actions:
- Execute workflow generation script with detection data:
  !{bash python3 ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/workflow-generation/scripts/generate-workflow-doc.py "$ARGUMENTS" --detect-state}

- Script process:
  1. Queries Airtable Web API for tech stack record
  2. Gets all plugin IDs and maps to plugin names
  3. For each plugin: queries commands, agents, skills via API
  4. **NEW**: Reads detection results from Phase 2
  5. **NEW**: Marks commands as ✅ or □ based on detected state
  6. Generates complete workflow markdown with 8 phases:
     - Foundation & Init (dev lifecycle + tech stack setup)
     - Planning (specs, architecture, database design)
     - Database & Auth (schema, RLS, auth providers)
     - Implementation (layered: L0→L1→L2→L3)
     - Quality (validation, testing, security)
     - Deployment (prepare, CI/CD, deploy, validate)
     - Versioning (setup, bump, release notes)
     - Iteration (enhance, refactor, adjust)

- Output: `~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/$SAFE_FILENAME-WORKFLOW.md`
- Format: Uses ✅ for completed, □ for todo based on file detection

Phase 4: Summary
Goal: Report results

Actions:
- Display file path, size, command counts
- Show completed vs remaining commands based on detection
- Show viewing command
- Explain:
  - "✅ = Already done (auto-detected from your files)"
  - "□ = Still to do"
  - "You can manually edit checkboxes too: change □ to ✅ or vice versa"
  - "Regenerate anytime: /foundation:generate-workflow \"$ARGUMENTS\""

**Error Handling:**
- Tech stack not found → list available stacks
- Airtable connection fails → show troubleshooting
- Plugin mapping incomplete → warn and continue

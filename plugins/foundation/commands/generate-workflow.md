---
description: Query Airtable for tech stack and generate complete workflow document
argument-hint: <tech-stack-name>
allowed-tools: Read, Write, Bash, mcp__airtable
---

**Arguments**: $ARGUMENTS (optional - auto-detects if not provided)

Goal: Auto-detect or use specified tech stack, then generate comprehensive workflow document with smart checkboxes showing what's done vs. todo.

Phase 1: Detect or Select Tech Stack
Goal: Determine which tech stack this project uses

Actions:
- If $ARGUMENTS provided:
  - Use specified stack name directly
  - Skip to Phase 2

- If NO $ARGUMENTS (auto-detect mode):
  - Scan current directory for tech indicators:
    !{bash test -f package.json && grep -q "next" package.json && echo "nextjs:detected"}
    !{bash test -f requirements.txt && grep -q "fastapi" requirements.txt && echo "fastapi:detected"}
    !{bash test -d supabase && echo "supabase:detected"}
    !{bash grep -r "vercel.*ai" package.json 2>/dev/null && echo "vercel-ai-sdk:detected"}
    !{bash grep -r "openrouter" package.json 2>/dev/null && echo "openrouter:detected"}
    !{bash grep -r "mem0" package.json requirements.txt 2>/dev/null && echo "mem0:detected"}

  - Query ALL tech stacks from Airtable:
    !{Use mcp__airtable to list all records from Tech Stacks table tblG07GusbRMJ9h1I}

  - Match detected frameworks to tech stack components:
    - Compare detected: [nextjs, fastapi, supabase, vercel-ai-sdk, openrouter, mem0]
    - Against each tech stack's component list
    - Calculate match score (% of components that match)

  - Select best match (highest score)
  - Display: "Auto-detected: AI Tech Stack 1 (95% match based on your files)"
  - Ask user to confirm or choose different stack

- Store selected tech stack name for Phase 2

Phase 1B: Query Airtable
Goal: Get tech stack and plugin data

Actions:
- Query Airtable base `appHbSB7WhT1TxEQb`:
  - Tech Stacks table `tblG07GusbRMJ9h1I` with filter: `FIND("{selected_stack}", {Stack Name})`
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

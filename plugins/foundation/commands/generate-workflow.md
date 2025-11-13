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

Phase 2: Generate Workflow
Goal: Create workflow markdown from Airtable using Web API (not MCP - avoids context overflow)

Actions:
- Execute workflow generation script (uses Airtable REST API):
  !{bash python3 ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/workflow-generation/scripts/generate-workflow-doc.py "$ARGUMENTS"}

- Script process:
  1. Queries Airtable Web API for tech stack record
  2. Gets all plugin IDs and maps to plugin names
  3. For each plugin: queries commands, agents, skills via API
  4. Generates complete workflow markdown with 8 phases:
     - Foundation & Init (dev lifecycle + tech stack setup)
     - Planning (specs, architecture, database design)
     - Database & Auth (schema, RLS, auth providers)
     - Implementation (layered: L0→L1→L2→L3)
     - Quality (validation, testing, security)
     - Deployment (prepare, CI/CD, deploy, validate)
     - Versioning (setup, bump, release notes)
     - Iteration (enhance, refactor, adjust)

- Output: `~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/$SAFE_FILENAME-WORKFLOW.md`

Phase 3: Summary
Goal: Report results

Actions:
- Display file path, size, command counts
- Show viewing command
- Explain regeneration: `/lifecycle:generate-workflow "$ARGUMENTS"`

**Error Handling:**
- Tech stack not found → list available stacks
- Airtable connection fails → show troubleshooting
- Plugin mapping incomplete → warn and continue

---
description: Interactive tech stack selector that queries Airtable and helps user choose the right stack
argument-hint: [optional-search-term]
allowed-tools: Task, Read, Bash, AskUserQuestion, mcp__airtable
---

**Arguments**: $ARGUMENTS

Goal: Help user select the most appropriate tech stack for their project by analyzing planning output and providing intelligent recommendations from Airtable.

Core Principles:
- **Planning First**: Read specs/ and planning output to understand requirements
- Auto-detect tech stack from project requirements
- Query Airtable to get latest tech stack definitions
- Provide intelligent recommendations based on requirements
- Store selection in .claude/project.json for foundation to use

Phase 1: Analyze Planning Output (REQUIRED)
Goal: Read planning output to understand project requirements

Actions:
- Check if planning has been completed:
  !{bash test -d specs/ && echo "Planning complete" || echo "Planning missing"}
- If planning missing:
  - STOP and display error: "⚠️  Run /planning:wizard first to gather requirements"
  - Explain: "Foundation needs planning output to suggest the right tech stack"
  - Exit command
- If planning exists, read requirements from:
  - specs/ directory (all feature specs)
  - .wizard/initial-request.md (if exists)
  - architecture/ directory (if exists)
- Extract mentioned frameworks and technologies:
  - Frontend frameworks (Next.js, React, Vue, etc.)
  - Backend frameworks (FastAPI, Express, Django, etc.)
  - Databases (Supabase, PostgreSQL, MongoDB, etc.)
  - AI frameworks (Vercel AI SDK, LangChain, etc.)
- Build requirements profile for matching

Phase 2: Query and Match Tech Stacks
Goal: Get tech stacks from Airtable and match against requirements

Actions:
- Query Airtable Tech Stacks table:
  Use mcp__airtable__list_records tool with base appHbSB7WhT1TxEQb and table tblG07GusbRMJ9h1I
- Extract key information for each stack
- Filter out deprecated stacks
- **Auto-match** against requirements profile from Phase 1:
  - Score each stack based on framework matches
  - Higher score = better match
  - Sort by match score

Phase 3: Present Intelligent Recommendations
Goal: Show user the best matches based on their requirements

Actions:
- Display top 3 recommended stacks with match scores:
  - "Based on your planning specs, here are the best matches:"
  - Show each with confidence percentage (e.g., "AI Tech Stack 1 - 95% match")
  - Highlight which frameworks matched
- If $ARGUMENTS provided, also filter by search term
- Use AskUserQuestion to present options:
  - Question: "Which tech stack best matches your project?"
  - Options: Top 3 recommended stacks from Phase 2
  - For each option, show:
    - Stack name + match score
    - Matched frameworks (Next.js ✓, Supabase ✓, etc.)
    - One-line description
    - Best for: use cases
- Allow "See all stacks" option for manual selection
- Capture user's selection

Phase 4: Display Stack Details
Goal: Show complete information about selected stack

Actions:
- Query Airtable for full stack details including all framework/plugin components, development lifecycle plugins, prerequisites
- Display formatted output showing:
  - Stack name and description
  - Tech stack components (Frontend, Backend, Database, AI Framework, Memory, Payments)
  - Development lifecycle plugins included
  - Use cases
  - Prerequisites

Phase 5: Store Selection
Goal: Save tech stack selection to project configuration

Actions:
- Create or update .claude/project.json with tech_stack, tech_stack_id, and selected_date fields
- Confirm storage

Phase 6: Summary
Goal: Provide next steps

Actions:
- Display what was accomplished:
  - Tech stack selected based on planning requirements
  - Configuration saved to .claude/project.json
  - Ready for foundation initialization
- Show correct workflow order:
  1. ✅ Planning complete (specs/ created)
  2. ✅ Tech stack selected (you are here)
  3. Next: /foundation:init-with-stack (initialize project structure)
  4. Then: /foundation:generate-workflow (get complete workflow)
  5. Then: Start building following Spec → Layer → Build pattern
- Emphasize this is the correct layering: Planning → Foundation → Implementation

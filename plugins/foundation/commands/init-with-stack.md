---
description: Initialize project with auto-detected or user-selected tech stack from Airtable
argument-hint: [tech-stack-name]
allowed-tools: Task, Read, Write, Bash, AskUserQuestion, mcp__airtable
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

Goal: Initialize a new project with the appropriate tech stack by either auto-detecting from description, using saved selection, or prompting user to choose.

Core Principles:
- Detect don't assume - check for existing .claude/project.json first
- Auto-detect when possible from project description
- Fall back to interactive selection if ambiguous
- Generate complete workflow after selection

Phase 1: Detect Existing Stack Selection
Goal: Check if tech stack already selected

Actions:
- Check for .claude/project.json:
  !{bash test -f .claude/project.json && echo "exists" || echo "missing"}
- If exists, read tech stack selection:
  !{Read .claude/project.json}
- If tech_stack field found, use that stack (skip to Phase 4)
- If not found or missing, continue to Phase 2

Phase 2: Determine Tech Stack
Goal: Figure out which tech stack to use

Actions:
- **Option A: $ARGUMENTS provided (explicit stack name)**
  - Use $ARGUMENTS as tech stack name
  - Query Airtable to verify it exists
  - If not found, show error and suggest /foundation:select-stack

- **Option B: No $ARGUMENTS, no existing selection**
  - Invoke /foundation:select-stack to help user choose
  - Wait for selection to be saved to .claude/project.json
  - Read selected stack from project.json

- **Option C: Auto-detect from project description (future enhancement)**
  - Analyze project files (README.md, package.json, etc.)
  - Match descriptions against Airtable stack descriptions
  - If confident match (>80%), propose it to user
  - If uncertain, fall back to Option B

Phase 3: Validate Tech Stack Selection
Goal: Ensure selected stack exists in Airtable

Actions:
- Query Airtable Tech Stacks table for the selected stack:
  Use mcp__airtable__list_records with filter: {Stack Name}="[selected-stack]"
- If not found:
  - Error: "Tech stack '[selected-stack]' not found in Airtable"
  - List available stacks
  - Recommend: /foundation:select-stack
  - EXIT
- If found, extract stack record ID for Phase 4

Phase 4: Generate Workflow Document
Goal: Create complete workflow for this tech stack

Actions:
- Call the workflow generation script:
  !{bash python3 ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/workflow-generation/scripts/generate-workflow-doc.py "[Stack Name]"}
- This generates: /path/to/[stack-name]-WORKFLOW.md with:
  - All phases (Foundation, Planning, Database, Implementation, Quality, Deployment, Versioning, Iteration)
  - All commands for each plugin
  - Complete reference documentation
- Store workflow path in .claude/project.json

Phase 5: Initialize Project Structure
Goal: Set up standardized project structure

Actions:
- Create .claude/ directory: !{bash mkdir -p .claude}
- Update or create .claude/project.json with tech_stack, tech_stack_id, workflow_path, initialized_date, and frameworks fields
- Create .gitignore protecting .env files and sensitive data if it doesn't exist

Phase 6: Environment Setup Preparation
Goal: Prepare environment configuration templates

Actions:
- Create .env.example with placeholders for all required keys:
  Based on tech stack components, include placeholders for:
  - ANTHROPIC_API_KEY=your_anthropic_key_here
  - OPENAI_API_KEY=your_openai_key_here (if OpenAI in stack)
  - SUPABASE_URL=https://your-project.supabase.co (if Supabase in stack)
  - SUPABASE_ANON_KEY=your_supabase_anon_key_here
  - MEM0_API_KEY=your_mem0_key_here (if Mem0 in stack)
  - OPENROUTER_API_KEY=your_openrouter_key_here (if OpenRouter in stack)
  - STRIPE_SECRET_KEY=your_stripe_key_here (if Stripe in stack)
- **SECURITY: NEVER hardcode actual API keys - always use placeholders!**
- Add .env.example to git (safe to commit)
- Ensure .env is in .gitignore (never commit)

Phase 7: Summary
Goal: Show what was initialized and next steps

Actions:
- Display initialization summary showing:
  - Project initialized with selected stack
  - Created files: .claude/project.json, .env.example, .gitignore, workflow.md
  - Tech stack components
  - Workflow document location
- Show next steps in order:
  1. Set up environment variables: /foundation:env-vars setup
  2. Verify environment: /foundation:env-check
  3. Initialize GitHub: /foundation:github-init
  4. Start building features following Spec → Layer → Build pattern
- Reference the generated workflow document for complete guidance

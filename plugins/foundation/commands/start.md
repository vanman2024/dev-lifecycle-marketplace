---
description: Single entry point that guides you through complete project initialization from planning to implementation
argument-hint: [project-name]
allowed-tools: Read, Write, Bash, SlashCommand, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Provide a single entry point for new projects that orchestrates the complete initialization workflow in the correct order, ensuring users know exactly what to do and when.

Core Principles:
- Single entry point for all new projects
- Step-by-step guided workflow
- Correct layering: Planning → Foundation → Implementation
- Clear progress tracking
- No confusion about what to run next

Phase 1: Welcome and Setup
Goal: Welcome user and create project directory

Actions:
- Display: "🚀 Project Initialization - 4 Steps: Planning → Tech Stack → Initialize → Build"
- If $ARGUMENTS: Create directory !{bash mkdir -p "$ARGUMENTS" && cd "$ARGUMENTS"}
- If no $ARGUMENTS: Use current directory
- Start workflow

Phase 2: Planning (Layer 0)
Goal: Gather requirements and create specs

Actions:
- Display: "Step 1/4: Planning & Requirements"
- Invoke: SlashCommand(/planning:wizard)
- Display: "✅ Planning complete - specs/ and architecture/ created"

Phase 3: Tech Stack Selection (Layer 1)
Goal: Select tech stack based on planning output

Actions:
- Display: "Step 2/4: Tech Stack Selection"
- Invoke: SlashCommand(/foundation:select-stack)
- Read selection: !{Read .claude/project.json}
- Display: "✅ Tech stack selected and saved"

Phase 4: Project Initialization (Layer 2)
Goal: Initialize project structure and generate complete workflow

Actions:
- Display: "Step 3/4: Project Initialization"
- Invoke: SlashCommand(/foundation:init-with-stack)
- Display: "✅ Project initialized - structure created"
- Read tech stack name: !{Read .claude/project.json}
- Display: "Step 3.5/4: Generating Complete Command Reference"
- Invoke: SlashCommand(/foundation:generate-workflow "[tech-stack-name]")
- Display: "✅ Workflow document generated with ALL commands from Airtable"

Phase 5: Complete and Next Steps
Goal: Show final summary and guide user on what to do next

Actions:
- Display: "Step 4/4: Ready to Build! 🎉"
- List workflow file: !{bash ls *-WORKFLOW.md 2>/dev/null | head -1}
- Display summary showing:
  - Project structure created (specs/, architecture/, .claude/)
  - Workflow document with ALL commands for your tech stack
  - Commands pulled from Airtable based on selected stack
  - Complete reference: [workflow-file] shows EVERY available command
  - Next steps in order:
    1. /foundation:env-vars setup
    2. /foundation:env-check
    3. /foundation:github-init
    4. /iterate:tasks F001
    5. Follow Spec → Layer → Build pattern
- Important: "View complete command list: cat [workflow-file]"

Phase 6: Summary
Goal: Confirm successful initialization

Actions:
- Display: "✅ Complete! Planning docs, tech stack selected, structure created, workflow ready. Start building: /iterate:tasks F001 🚀"

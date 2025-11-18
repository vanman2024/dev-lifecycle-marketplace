---
description: Execute all layered tasks sequentially (L0→L3)
argument-hint: <spec-name>
allowed-tools: Read, Write, Bash, Glob, Grep, SlashCommand, TodoWrite
---

**Arguments**: $ARGUMENTS

Goal: Execute complete implementation workflow by reading layered-tasks.md, mapping tasks to tech-specific commands, and executing layer by layer with progress tracking.

Core Principles:
- Read layered-tasks.md for execution plan
- Map tasks to tech-specific commands based on project.json
- Execute L0 → L1 → L2 → L3 sequentially
- Auto-sync with /iterate:sync after each layer
- Track progress in .claude/execution/<spec>.json
- Pause on mapping failures

Phase 1: Discovery & Setup
Goal: Load spec, validate, and initialize tracking

Actions:
- Create todos: Discovery, L0, Sync L0, L1, Sync L1, L2, Sync L2, L3, Final Sync
- Parse $ARGUMENTS to extract spec name
- Validate: !{bash test -d specs/$ARGUMENTS && echo "exists" || echo "missing"}
- If missing: Error "Spec not found. Run /planning:add-feature" and exit
- Read: @specs/$ARGUMENTS/layered-tasks.md and @.claude/project.json
- Extract tech stack for command mapping
- Initialize tracking: !{bash mkdir -p .claude/execution}
- Create .claude/execution/$ARGUMENTS.json with layers status
- Display: "Found [X] tasks across [Y] layers"

Phase 2: Execute L0 & Sync
Goal: Execute infrastructure tasks and validate

Actions:
- Extract L0 tasks from layered-tasks.md
- Map tasks to commands (database→apply_migration, auth→clerk:init, AI→add-provider, etc.)
- If mapping fails: Ask user for command, pause
- Execute each task via SlashCommand, update L0.tasks in tracking
- Display: "L0 Progress: [X/Y]"
- Mark L0.status = "complete"
- Sync: !{bash /iterate:sync $ARGUMENTS}
- Update todo: L0 complete

Phase 3: Execute L1 & Sync
Goal: Execute core services and validate

Actions:
- Extract L1 tasks from layered-tasks.md
- Map: component→add-component, endpoint→add-endpoint, table→apply_migration
- Execute via SlashCommand, update L1.tasks
- Display: "L1 Progress: [X/Y]"
- Mark L1.status = "complete"
- Sync: !{bash /iterate:sync $ARGUMENTS}
- Update todo: L1 complete

Phase 4: Execute L2 & Sync
Goal: Execute features and validate

Actions:
- Extract L2 tasks from layered-tasks.md
- Map: streaming→add-streaming, pages→add-page, integration→integrate-supabase
- Execute via SlashCommand, update L2.tasks
- Display: "L2 Progress: [X/Y]"
- Mark L2.status = "complete"
- Sync: !{bash /iterate:sync $ARGUMENTS}
- Update todo: L2 complete

Phase 5: Execute L3 & Final Sync
Goal: Execute integration, validate, and summarize

Actions:
- Extract L3 tasks from layered-tasks.md
- Map: wire→add-component, connect→Edit, test→npm run test, config→Edit .env.local
- Execute via SlashCommand, update L3.tasks
- Display: "L3 Progress: [X/Y]"
- Mark L3.status = "complete"
- Final sync: !{bash /iterate:sync $ARGUMENTS}
- Update: completed_at timestamp
- Mark all todos complete
- Display summary:
  * Feature: $ARGUMENTS
  * Status: All layers complete (L0→L3)
  * Total tasks: [X]
  * Execution time: [Y] min
  * Log: .claude/execution/$ARGUMENTS.json
- Next steps: /quality:validate-code $ARGUMENTS, /testing:test

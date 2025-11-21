---
description: Execute feature/infrastructure implementation with parallel agents and automatic task tracking
argument-hint: [spec-id | --phase-X | --infrastructure | --features] [natural language hints]
allowed-tools: Read, Write, Bash(*), Grep, Glob, Task, TodoWrite
---

**Arguments**: $ARGUMENTS

Goal: Execute implementation by spawning domain agents in parallel waves with automatic task tracking.

## Modes

**Spec-based:**
- `I001`, `F001` - Execute single infrastructure/feature spec
- `phase-0/001-auth` - Execute by path

**Phase-based:**
- `--phase-0`, `--phase-1` - Execute all items in that phase
- `--infrastructure` - Execute all infrastructure phases (0 → 1 → 2)
- `--features` - Execute all features

**Natural Language Hints (append to any mode):**
- "use clerk agents in parallel" - Spawn all clerk agents at once
- "run domain agents directly" - Skip slash commands, use agents
- "sequential" - Run one at a time instead of parallel

## Execution

### Phase 1: Parse Arguments and Determine Mode
Goal: Understand scope and execution strategy

Actions:
- Create todo list for tracking
- Parse $ARGUMENTS:
  * `I001`, `F001` → MODE = "single-spec"
  * `phase-0/XXX` path → MODE = "single-spec" (extract spec ID)
  * `--phase-0`, `--phase-1`, `--phase-2` → MODE = "phase"
  * `--infrastructure` → MODE = "all-infrastructure"
  * `--features` → MODE = "all-features"
  * `--all` → MODE = "full"
  * Empty → MODE = "auto-continue"
- Extract natural language hints:
  * "parallel" / "agents" → STRATEGY = "parallel-agents"
  * "sequential" → STRATEGY = "sequential"
  * "clerk" / "supabase" / etc. → DOMAIN_HINT
- Display: "Mode: [MODE], Strategy: [STRATEGY]"

### Phase 2: Load Context
Goal: Read project configuration and current status

Actions:
- Read project context:
  * !{cat .claude/project.json 2>/dev/null || echo "{}"}
  * !{cat features.json 2>/dev/null || echo "{}"}
- Identify target specs based on MODE:
  * single-spec: Find the specific spec directory
  * phase: Find all specs in that phase directory
  * all-infrastructure: List all specs in specs/infrastructure/
  * all-features: List all specs in specs/features/
- For each target spec:
  * Check current status (pending, in_progress, completed)
  * Skip if already completed
  * Validate dependencies are met
- Display: "Found X specs to execute"

### Phase 3: Load Tasks
Goal: Read and parse task lists from specs

Actions:
- For each target spec:
  * Find spec directory:
    !{find specs -type d -name "*$SPEC_ID*" | head -1}
  * Read tasks.md: @$SPEC_DIR/tasks.md
  * Parse tasks - identify:
    - Task descriptions
    - Checkbox status ([ ] vs [x])
    - Layer/dependency info (L0, L1, L2, L3)
    - Domain hints (clerk, supabase, redis, etc.)
  * Count: total, completed, remaining
- Display task summary:
  ```
  Spec: I001 - Authentication
  Total: 12 tasks
  Completed: 5 (L0-L1)
  Remaining: 7 (L2-L3)
  Domain: clerk
  ```

### Phase 4: Map Tasks to Agents
Goal: Determine which agents to spawn for remaining tasks

Actions:
- Analyze remaining tasks for domain keywords:
  * "clerk" / "auth" / "oauth" → clerk:* agents
  * "supabase" / "database" / "schema" → supabase:* agents
  * "component" / "UI" / "frontend" → nextjs-frontend:* agents
  * "endpoint" / "API" / "backend" → fastapi-backend:* agents
  * "redis" / "cache" → redis:* agents
- Group tasks by domain and layer
- Create agent mapping:
  ```
  L2 Tasks (parallel):
  - Task 5: OAuth config → clerk:clerk-oauth-specialist
  - Task 6: API service → clerk:clerk-api-builder
  - Task 7: Frontend client → clerk:clerk-nextjs-app-router-agent

  L3 Tasks (after L2):
  - Task 8: Migration UI → nextjs-frontend:component-builder-agent
  - Task 9: Validate → clerk:clerk-validator
  ```
- If DOMAIN_HINT provided, prioritize those agents

### Phase 5: Execute Agents in Parallel Waves
Goal: Spawn agents by layer, validate, and track progress

Actions:
- Initialize tracking:
  * !{mkdir -p .claude/execution}
  * Create execution log: .claude/execution/$SPEC_ID.json
- For each LAYER (L0 → L1 → L2 → L3):
  * Get all tasks in this layer
  * Get mapped agents for these tasks
  * **SPAWN ALL AGENTS IN PARALLEL** (single message with multiple Task calls):
    ```
    Task(subagent_type="clerk:clerk-oauth-specialist", prompt="...")
    Task(subagent_type="clerk:clerk-api-builder", prompt="...")
    Task(subagent_type="clerk:clerk-nextjs-app-router-agent", prompt="...")
    ```
  * Wait for ALL agents to complete
  * **VALIDATE each task:**
    - Check if expected files were created
    - Check for errors in agent output
    - Verify task requirements met
  * **UPDATE tasks.md checkboxes:**
    - For each completed task: Change `- [ ]` to `- [x]`
    - !{sed -i 's/- \[ \] Task X/- [x] Task X/' $SPEC_DIR/tasks.md}
  * **UPDATE execution log:**
    - Add completed tasks with timestamps
    - Record any failures
  * Display layer progress:
    ```
    ✅ Layer 2 Complete (3/3 tasks)
    - [x] Task 5: OAuth config
    - [x] Task 6: API service
    - [x] Task 7: Frontend client
    ```
  * Proceed to next layer

### Phase 6: Final Validation
Goal: Verify all tasks completed before marking spec done

Actions:
- Re-read tasks.md
- Count checkboxes:
  * CHECKED = count of `- [x]`
  * UNCHECKED = count of `- [ ]`
- If UNCHECKED > 0:
  * Display: "⚠️ $UNCHECKED tasks not completed"
  * List uncompleted tasks
  * Set status = "partial"
  * **DO NOT mark spec as completed**
- If UNCHECKED = 0:
  * All tasks verified complete
  * Set status = "completed"
- Update execution log with final status

### Phase 7: Update Project Status
Goal: Update project.json and features.json

Actions:
- If status = "completed":
  * Update infrastructure item in project.json:
    !{jq '.infrastructure[] | select(.id == "$SPEC_ID") .status = "completed"' .claude/project.json}
  * Or update feature in features.json
  * Record completion timestamp
- If status = "partial":
  * Update status to "in_progress"
  * Note remaining tasks
- Commit execution log:
  * !{git add .claude/execution/$SPEC_ID.json $SPEC_DIR/tasks.md}
  * !{git commit -m "implementation: Update $SPEC_ID progress"}

### Phase 8: Summary
Goal: Display comprehensive results

Actions:
- Display summary:
  ```
  🎉 Execution Complete: $SPEC_NAME

  📊 Results:
  - Total tasks: $TOTAL
  - Completed: $COMPLETED ✅
  - Failed: $FAILED ❌
  - Manual: $MANUAL ⚠️
  - Success rate: XX%

  📁 Execution log: .claude/execution/$SPEC_ID.json
  📝 Tasks file: $SPEC_DIR/tasks.md

  ✅ All checkboxes verified
  ```
- If status = "completed", suggest next steps:
  * /quality:validate-code $SPEC_ID
  * /testing:test $SPEC_ID
  * /deployment:prepare (if all infrastructure done)
- If status = "partial", suggest:
  * Re-run: /implementation:execute $SPEC_ID
  * Check failures in execution log
- Mark todo complete

## Important Notes

**Parallel Agent Execution:**
Agents within the same layer run in parallel. Send ALL Task() calls in a single message.

**Task Checkbox Tracking:**
After each agent completes, immediately update tasks.md checkboxes. Never mark a spec complete without verifying all checkboxes are checked.

**Natural Language Flexibility:**
Users can provide hints like "use all clerk agents" or "run sequentially". Parse these from $ARGUMENTS and adjust execution accordingly.

**Validation Before Completion:**
Always re-read tasks.md and verify checkbox counts before marking any spec as completed. If validation fails, report the gap.

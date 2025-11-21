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

### Phase 2: Load Context and Initialize Tracking
Goal: Read project configuration and initialize single execution log

Actions:
- Read project context:
  * !{cat .claude/project.json 2>/dev/null || echo "{}"}
  * !{cat features.json 2>/dev/null || echo "{}"}
- Initialize SINGLE execution log file:
  * !{mkdir -p .claude/execution}
  * If .claude/execution/execution.json exists, read it
  * Otherwise create new structure:
    !{echo '{"session":"'$(date -Iseconds)'","specs":{},"overall":{"total_specs":0,"completed":0,"in_progress":0,"pending":0}}' > .claude/execution/execution.json}
- Identify target specs based on MODE:
  * single-spec: Find the specific spec directory
  * phase: Find all specs in that phase directory
  * all-infrastructure: List all specs in specs/infrastructure/
  * all-features: List all specs in specs/features/
- For each target spec:
  * Check current status from execution.json
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
  * Update execution.json with spec entry:
    !{jq '.specs["'$SPEC_ID'"] = {"status":"pending","tasks_total":'$TOTAL',"tasks_completed":'$DONE',"remaining":'$REMAINING'}' .claude/execution/execution.json > tmp && mv tmp .claude/execution/execution.json}
- Display task summary for each spec

### Phase 4: Map Tasks to Agents
Goal: Determine which agents to spawn for remaining tasks

Actions:
- Analyze remaining tasks for domain keywords:
  * "clerk" / "auth" / "oauth" → clerk:* agents
  * "supabase" / "database" / "schema" → supabase:* agents
  * "component" / "UI" / "frontend" → nextjs-frontend:* agents
  * "endpoint" / "API" / "backend" → fastapi-backend:* agents
  * "redis" / "cache" → redis:* agents
  * "rag" / "vector" / "embedding" → rag-pipeline:* agents
  * "sentry" / "error" / "monitoring" → deployment:observability-integrator
- Group tasks by domain and layer
- Create agent mapping and store in execution.json:
  !{jq '.specs["'$SPEC_ID'"].agents_mapped = ["agent1", "agent2"]' .claude/execution/execution.json > tmp && mv tmp .claude/execution/execution.json}
- If DOMAIN_HINT provided, prioritize those agents

### Phase 5: Execute Agents in Parallel Waves
Goal: Spawn agents by layer, validate, and track progress in single execution.json

Actions:
- Update spec status to in_progress:
  !{jq '.specs["'$SPEC_ID'"].status = "in_progress" | .specs["'$SPEC_ID'"].started_at = "'$(date -Iseconds)'"' .claude/execution/execution.json > tmp && mv tmp .claude/execution/execution.json}
- For each LAYER (L0 → L1 → L2 → L3):
  * Get all tasks in this layer
  * Get mapped agents for these tasks
  * **SPAWN ALL AGENTS IN PARALLEL** (single message with multiple Task calls)
  * Wait for ALL agents to complete
  * **VALIDATE each task:**
    - Check if expected files were created
    - Check for errors in agent output
    - Verify task requirements met
  * **UPDATE tasks.md checkboxes:**
    - For each completed task: Change `- [ ]` to `- [x]`
    - !{sed -i 's/- \[ \] Task X/- [x] Task X/' $SPEC_DIR/tasks.md}
  * **UPDATE execution.json** (single file, not per-spec):
    !{jq '.specs["'$SPEC_ID'"].tasks_completed = '$NEW_COUNT' | .specs["'$SPEC_ID'"].last_updated = "'$(date -Iseconds)'"' .claude/execution/execution.json > tmp && mv tmp .claude/execution/execution.json}
  * Display layer progress
  * Proceed to next layer

### Phase 6: Final Validation
Goal: Verify all tasks completed before marking spec done

Actions:
- Re-read tasks.md
- Count checkboxes:
  * CHECKED = count of `- [x]`
  * UNCHECKED = count of `- [ ]`
- If UNCHECKED > 0:
  * Display: "Warning: $UNCHECKED tasks not completed"
  * List uncompleted tasks
  * Update execution.json: status = "partial"
  * **DO NOT mark spec as completed**
- If UNCHECKED = 0:
  * All tasks verified complete
  * Update execution.json: status = "completed", completed_at = timestamp
- Update overall counts in execution.json:
  !{jq '.overall.completed = ([.specs[] | select(.status == "completed")] | length) | .overall.in_progress = ([.specs[] | select(.status == "in_progress")] | length) | .overall.pending = ([.specs[] | select(.status == "pending")] | length) | .overall.total_specs = (.specs | length)' .claude/execution/execution.json > tmp && mv tmp .claude/execution/execution.json}

### Phase 7: Update Project Status
Goal: Update project.json and features.json

Actions:
- If status = "completed":
  * Update infrastructure item in project.json
  * Or update feature in features.json
  * Record completion timestamp
- If status = "partial":
  * Update status to "in_progress"
  * Note remaining tasks
- Commit changes:
  * !{git add .claude/execution/execution.json $SPEC_DIR/tasks.md}
  * !{git commit -m "implementation: Update progress - $SPEC_ID"}

### Phase 8: Summary
Goal: Display comprehensive results from single execution.json

Actions:
- Read execution.json and display summary:
  !{cat .claude/execution/execution.json | jq '.'}
- Display per-spec status table
- Show overall totals from execution.json
- If status = "completed", suggest next steps:
  * /quality:validate-code $SPEC_ID
  * /testing:test $SPEC_ID
  * /deployment:prepare (if all infrastructure done)
- If status = "partial", suggest:
  * Re-run: /implementation:execute $SPEC_ID
  * Run: /implementation:check-tasks to see remaining
- Mark todo complete

## Important Notes

**Single Execution Log:**
All progress tracked in ONE file: .claude/execution/execution.json
This file contains all specs, their status, task counts, and timestamps.
Never create per-spec JSON files.

**Parallel Agent Execution:**
Agents within the same layer run in parallel. Send ALL Task() calls in a single message.

**Task Checkbox Tracking:**
After each agent completes, immediately update tasks.md checkboxes and execution.json.
Never mark a spec complete without verifying all checkboxes are checked.

**Natural Language Flexibility:**
Users can provide hints like "use all clerk agents" or "run sequentially".
Parse these from $ARGUMENTS and adjust execution accordingly.

---
description: Execute feature implementation by discovering commands and executing tasks
argument-hint: <spec-id>
allowed-tools: Read, Write, Bash(*), Glob, Grep, SlashCommand, TodoWrite
---

**Arguments**: $ARGUMENTS

Goal: Execute complete feature implementation by reading spec.md and tasks.md, discovering available commands from enabled plugins, intelligently mapping tasks to commands, and executing sequentially with progress tracking.

Core Principles:
- Read spec.md for feature context and requirements
- Read tasks.md for task list to execute
- Discover available commands from .claude/settings.json
- Map tasks to commands based on keywords and tech stack
- Execute tasks sequentially with progress tracking
- Auto-sync with /iterate:sync after execution
- Track progress in .claude/execution/<spec>.json

Phase 0: Discovery & Context Loading
Goal: Load spec files, discover available commands, and prepare for execution

Actions:
- Create todos: Load Context, Discover Commands, Execute Tasks, Sync & Validate
- Parse $ARGUMENTS to extract spec ID (e.g., "F001", "infrastructure/001-auth")
- Validate spec exists: !{bash test -d specs/$ARGUMENTS && echo "exists" || echo "missing"}
- If missing: Error "Spec not found at specs/$ARGUMENTS. Run /planning:add-feature first" and exit
- Read spec context:
  * @specs/$ARGUMENTS/spec.md (feature description, requirements, user stories)
  * @specs/$ARGUMENTS/tasks.md (task list to execute)
  * @.claude/project.json (tech stack for intelligent command mapping)
  * @.claude/settings.json (enabled plugins and available commands)
- Display feature summary:
  * Feature: [Name from spec.md]
  * Spec ID: $ARGUMENTS
  * Tasks: [X tasks found in tasks.md]
- Discover available commands:
  * Parse enabledPlugins from settings.json
  * List plugins: display "[Y] plugins enabled"
  * Display: "Command discovery complete - ready for task mapping"
- Check execution history:
  * !{bash mkdir -p .claude/execution}
  * Check if .claude/execution/$ARGUMENTS.json exists
  * If exists: @.claude/execution/$ARGUMENTS.json (read previous execution history)
  * Display previously executed commands: "[X] commands already run"
  * Mark completed tasks to skip: "Resuming from last checkpoint"
  * If not exists: Create new .claude/execution/$ARGUMENTS.json
  * Track: spec_id, started_at, tasks: [], executed_commands: [], status: "in_progress"

Phase 1: Intelligent Task Mapping
Goal: Map each task from tasks.md to appropriate commands from enabled plugins

Actions:
- Extract tasks from tasks.md (parse markdown checklist format)
- For each task:
  * Analyze task description for keywords
  * Extract action type (create, setup, configure, deploy, test, etc.)
  * Extract subject (component, endpoint, schema, auth, deployment, etc.)
  * Match to tech stack from project.json
  * Score available commands by relevance:
    - Keyword matching (component → add-component, endpoint → add-endpoint)
    - Tech stack alignment (Next.js → nextjs-frontend:*, FastAPI → fastapi-backend:*)
    - Plugin capabilities (auth → supabase:add-auth OR clerk:add-auth based on project.json)
  * Select highest-scoring command (confidence-based)
  * If confidence < 60%: Ask user "Which command for task: [description]?"
  * Display mapping: "Task: [description] → Command: /plugin:command-name [args]"
- Create execution plan with all mappings
- Display execution plan:
  * Total tasks: [X]
  * Mapped commands: [list of unique commands]
  * Estimated time: [Y] minutes
- Ask user: "Execute plan? (y/n)" - If no, exit gracefully

Phase 2: Sequential Task Execution
Goal: Execute all tasks sequentially with progress tracking

Actions:
- Update todo: Mark "Execute Tasks" as in_progress
- For each task in execution plan:
  * Check execution history: if command already in executed_commands array, skip
  * If already executed: Display "⏭️  Skipping: [command] (already run)" and continue
  * If not executed: Display "Executing task [X/Y]: [task description]"
  * Display: "Command: [/plugin:command args]"
  * Execute via SlashCommand tool
  * Capture result and any errors
  * Update .claude/execution/$ARGUMENTS.json:
    - Add task to tasks array
    - Add command to executed_commands array (deduplicated)
    - Mark task.status = "complete" or "failed"
    - Record task.command, task.output, task.timestamp
  * If execution fails:
    - Display error: "Task failed: [error message]"
    - Ask user: "Continue with remaining tasks? (y/n)"
    - If no: Mark execution as "partial", save state, exit
  * Display progress: "Progress: [X/Y] tasks complete"
- All tasks complete: Display "✅ All tasks executed successfully"
- Update execution tracking:
  * Mark status = "complete"
  * Record completed_at timestamp
  * Save final .claude/execution/$ARGUMENTS.json

Phase 3: Sync and Validation
Goal: Sync implementation with specs and provide summary

Actions:
- Run sync: Execute /iterate:sync $ARGUMENTS
- Display sync results
- Generate execution summary:
  * Feature: $ARGUMENTS
  * Status: [complete|partial|failed]
  * Tasks executed: [X/Y]
  * Duration: [start to end time]
  * Commands used: [unique command count]
  * Log file: .claude/execution/$ARGUMENTS.json
- Display next steps:
  * Validate code: /quality:validate-code $ARGUMENTS
  * Run tests: /testing:test $ARGUMENTS
  * Deploy: /deployment:deploy
- Mark all todos complete
- Success message: "🎉 Feature implementation complete!"

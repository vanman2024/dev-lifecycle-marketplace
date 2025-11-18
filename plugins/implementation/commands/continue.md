---
description: Resume execution after pause or failure
argument-hint: <spec-name>
allowed-tools: Read, Write, Bash, SlashCommand
---

**Arguments**: $ARGUMENTS

Goal: Resume implementation execution from last saved checkpoint.

Core Principles:
- Load checkpoint state to understand where to resume
- Handle failures gracefully with clear error messages
- Continue from exact point of interruption
- Update status as execution progresses

Phase 1: Load Checkpoint
Goal: Read execution status and find resumption point

Actions:
- Parse $ARGUMENTS for spec name
- Set SPEC_NAME variable from first argument
- Check status file exists: !{bash test -f .claude/execution/$SPEC_NAME.json && echo "exists" || echo "missing"}
- If missing: Display "No execution to resume for $SPEC_NAME. Run /implementation:execute $SPEC_NAME to start fresh."
- Read status file: @.claude/execution/$SPEC_NAME.json
- Identify current state:
  * Last completed layer
  * Current incomplete layer
  * Failed tasks (if any)
  * Next task to execute
  * Total progress percentage

Phase 2: Determine Resumption Strategy
Goal: Decide how to proceed based on checkpoint state

Actions:
- If status shows "failed" state:
  * Display error details from checkpoint
  * Ask user: "The previous execution failed. Have you fixed the issue? (yes/no)"
  * If yes: Mark failed task as ready for retry
  * If no: Display "Please fix the issue before continuing" and exit
- If status shows "paused" state:
  * Display "Resuming from paused state at Layer X, Task Y"
  * Identify next pending task in current layer
- If status shows "completed":
  * Display "Execution already complete for $SPEC_NAME"
  * Show summary and exit
- If no clear next task:
  * Display "Unable to determine resumption point. Run /implementation:execute $SPEC_NAME to restart."

Phase 3: Resume Execution
Goal: Continue from checkpoint with same layer-by-layer approach

Actions:
- Load layered tasks: @specs/$SPEC_NAME/layered-tasks.md
- Load project context: @.claude/project.json
- Resume execution at identified resumption point:
  * If retrying failed task: Re-execute that specific task
  * If continuing layer: Execute remaining tasks in current layer
  * If starting new layer: Execute all tasks in next layer
- Follow same execution pattern as /implementation:execute:
  * Execute tasks in dependency order
  * Update status after each task completion
  * Write progress to .claude/execution/$SPEC_NAME.json
  * Handle errors and pause points
- Continue until layer completes or error occurs
- If all layers complete: Mark status as "completed"

Phase 4: Summary
Goal: Report resumption results and current state

Actions:
- Display execution summary:
  * Resumed from: Layer X, Task Y
  * Tasks completed this session: N
  * Current status: Complete | In Progress | Failed
  * Overall progress: X% complete
- If execution complete:
  * Display "All layers executed successfully"
  * Next steps: "/quality:validate-code $SPEC_NAME to verify implementation"
- If execution incomplete:
  * Display "Execution paused or failed"
  * Next steps: "/implementation:continue $SPEC_NAME to resume after fixing issues"
- If execution failed:
  * Display error details
  * Next steps: "Fix the issue and run /implementation:continue $SPEC_NAME"

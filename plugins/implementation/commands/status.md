---
description: Show execution progress and current state
argument-hint: <spec-name>
allowed-tools: Read, Bash(*)
---

**Arguments**: $ARGUMENTS

Goal: Display comprehensive execution status including completed tasks, current progress, and next recommended actions.

Core Principles:
- Show clear visual progress indicators
- Provide actionable next steps
- Display current execution state
- Surface errors and blockers prominently

Phase 1: Load Status
Goal: Read execution tracking file and validate spec exists

Actions:
- Parse $ARGUMENTS for spec name
- Check if execution status exists: !{bash SPEC_NAME="$ARGUMENTS"; test -f .claude/execution/$SPEC_NAME.json && echo "exists" || echo "missing"}
- If missing, display: "No execution started for $SPEC_NAME. Run /implementation:execute $SPEC_NAME to begin."
- Read status file: @.claude/execution/$SPEC_NAME.json
- Read layered tasks for context: @specs/$SPEC_NAME/layered-tasks.md

Phase 2: Calculate Progress
Goal: Analyze completion metrics across all layers

Actions:
- Count total tasks across all layers (L0, L1, L2, L3)
- Count completed tasks (status: "completed")
- Count in-progress tasks (status: "in_progress")
- Count failed tasks (status: "failed")
- Count pending tasks (status: "pending")
- Calculate percentage: (completed / total) * 100
- Identify current layer based on first non-complete layer
- Find next pending task in current layer

Phase 3: Display Status
Goal: Present comprehensive formatted status report

Actions:
- Display feature header with spec name and title
- Show layer-by-layer progress:
  - Layer 0 (Infrastructure): [✅ Complete | 🔄 In Progress | ⏳ Pending] (X/Y tasks)
  - Layer 1 (Core Services): [✅ Complete | 🔄 In Progress | ⏳ Pending] (X/Y tasks)
  - Layer 2 (Features): [✅ Complete | 🔄 In Progress | ⏳ Pending] (X/Y tasks)
  - Layer 3 (Integration): [✅ Complete | 🔄 In Progress | ⏳ Pending] (X/Y tasks)
- Show overall progress bar: [████████░░] 80%
- Display currently executing tasks with:
  - Task description
  - Assigned agent
  - Complexity level
  - Progress percentage if available
- If failed tasks exist, show error details with task ID and error message
- List next 3 pending tasks in queue

Phase 4: Recommendations
Goal: Provide actionable next steps based on current state

Actions:
- If all tasks complete (100%):
  - Recommend: /iterate:sync $SPEC_NAME to validate implementation
  - Recommend: /quality:validate-code $SPEC_NAME to verify quality
- If execution in progress (1-99%):
  - Recommend: /implementation:continue $SPEC_NAME to resume execution
  - Show estimated tasks remaining in current layer
- If execution not started (0%):
  - Recommend: /implementation:execute $SPEC_NAME to begin
- If failed tasks exist:
  - Show error details
  - Recommend: Review errors and fix issues before continuing
  - Suggest: /implementation:continue $SPEC_NAME --retry-failed
- Display time statistics:
  - Execution started: [timestamp]
  - Last updated: [timestamp]
  - Estimated completion: [based on average task time]

Phase 5: Summary
Goal: Recap status and provide context

Actions:
- Display summary line:
  - "$SPEC_NAME: [X/Y] tasks complete ([Z]% done)"
- Show current bottlenecks if any (tasks waiting on dependencies)
- Provide link to detailed logs: .claude/execution/$SPEC_NAME.json
- Remind user to commit completed work periodically

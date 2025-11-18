---
description: Execute specific layer only
argument-hint: <spec-name> <layer>
allowed-tools: Read, Write, Bash(*), SlashCommand
---

**Arguments**: $ARGUMENTS

Goal: Execute a single layer (L0, L1, L2, or L3) from layered-tasks.md for targeted execution and testing.

Core Principles:
- Parse arguments carefully to extract spec name and layer
- Validate layer designation before execution
- Execute only tasks in the specified layer
- Update execution status for tracking
- Provide clear feedback on progress

Phase 1: Parse Arguments
Goal: Extract spec name and layer from arguments

Actions:
- Parse $ARGUMENTS for spec name and layer
- Expected format: "spec-name layer" (e.g., "F001 L1")
- Extract SPEC_NAME (e.g., F001) and LAYER (e.g., L1)
- If arguments are missing or malformed:
  - Display error: "Usage: /implementation:execute-layer <spec-name> <layer>"
  - Display example: "/implementation:execute-layer F001 L1"
  - Exit

Phase 2: Validate Layer
Goal: Ensure layer is valid

Actions:
- Check if LAYER is one of: L0, L1, L2, L3
- If invalid:
  - Display error: "Invalid layer: $LAYER. Must be L0, L1, L2, or L3"
  - Exit
- Display: "Executing layer $LAYER for spec $SPEC_NAME"

Phase 3: Load Context
Goal: Read execution plan and current status

Actions:
- Read layered tasks: @specs/$SPEC_NAME/layered-tasks.md
- If file doesn't exist:
  - Display error: "Layered tasks not found for $SPEC_NAME"
  - Suggest: "Run /iterate:tasks $SPEC_NAME to create layered tasks first"
  - Exit
- Read project context: @.claude/project.json
- Check for existing execution status: @.claude/execution/$SPEC_NAME.json (if exists)
- Extract all tasks for specified layer from layered-tasks.md
- Display: "Found X tasks in $LAYER"

Phase 4: Execute Layer Tasks
Goal: Run all tasks in the specified layer

Actions:
- For each task in the specified layer:
  - Parse task description to determine action required
  - Map task to appropriate tech-specific command based on project.json
  - Execute via SlashCommand tool
  - Display progress: "Task X/Y: [task description]"
  - Track completion status
- If any task fails:
  - Log failure details
  - Continue with remaining tasks
  - Mark layer as partially complete
- If all tasks succeed:
  - Mark layer as complete
  - Display: "✅ $LAYER complete ($TASK_COUNT/$TASK_COUNT tasks)"

Phase 5: Update Status
Goal: Update execution tracking file

Actions:
- Create or update .claude/execution/$SPEC_NAME.json
- Record:
  - Layer completed: $LAYER
  - Timestamp: current date/time
  - Tasks executed: count
  - Status: complete or partial
- Display: "📊 Status updated in .claude/execution/$SPEC_NAME.json"

Phase 6: Summary
Goal: Report execution results

Actions:
- Display summary:
  - Spec: $SPEC_NAME
  - Layer: $LAYER
  - Tasks executed: $TASK_COUNT
  - Status: complete/partial/failed
  - Next layer: (if applicable, e.g., "L2" if L1 was executed)
- Suggest next steps:
  - If layer complete: "Run /implementation:execute-layer $SPEC_NAME $NEXT_LAYER"
  - If layer partial: "Review failures and retry /implementation:execute-layer $SPEC_NAME $LAYER"
  - If all layers complete: "Run /iterate:sync $SPEC_NAME to validate implementation"

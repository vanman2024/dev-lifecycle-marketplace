---
description: Check outstanding tasks across specs - shows completion status and remaining work
argument-hint: [spec-id | --all | --infrastructure | --features]
allowed-tools: Read, Grep, Glob, Task, TodoWrite
---

**Arguments**: $ARGUMENTS

Goal: Display task completion status across one or more specs. For 3+ specs, spawn agents in parallel.

## Modes

- I001, F001 - Check single spec
- --all - Check all specs
- --infrastructure - Check all infrastructure specs
- --features - Check all feature specs
- (empty) - Check all in-progress specs

## Execution

### Phase 1: Determine Scope
Goal: Identify which specs to check

Actions:
- Parse $ARGUMENTS to determine mode
- Find all target spec directories:
  !{find specs -name "tasks.md" -type f | head -20}
- Count target specs
- Display: "Found N specs to check"

### Phase 2: Execute Check

**For 1-2 specs:** Check directly inline

- For each spec, find tasks.md and count checkboxes:
  !{grep -c "^- \[ \]" $SPEC_DIR/tasks.md}
  !{grep -c "^- \[x\]" $SPEC_DIR/tasks.md}
- Extract remaining task descriptions:
  !{grep "^- \[ \]" $SPEC_DIR/tasks.md}
- Display results inline

**For 3+ specs:** Spawn progress-tracker agents in parallel

- Create one Task() call per spec, send ALL in single message
- Use subagent_type="implementation:progress-tracker"
- Each agent reads tasks.md, counts checkboxes, returns JSON with spec_id, total, completed, remaining, remaining_tasks
- Wait for ALL agents to complete
- Aggregate results

### Phase 3: Display Summary
Goal: Show consolidated status

Actions:
- Display per-spec status as table showing: Spec ID, Name, Total, Done, Remaining
- Show overall totals: X tasks, Y done (Z%), W remaining
- For single spec, list all remaining tasks with descriptions
- Suggest next action: /implementation:execute SPEC_ID to continue work

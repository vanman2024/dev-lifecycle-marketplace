---
description: Add infrastructure component to project.json and generate spec
argument-hint: <component-type> "<description>"
allowed-tools: Read, Bash, Task, TodoWrite, Edit
---

**Arguments**: $ARGUMENTS

Goal: Add infrastructure component with proper analysis and spec generation.

Phase 1: Parse Arguments
Goal: Extract component type and description

Actions:
- Create todo list: Parse, Assess, Analyze, Generate, Sync, Summary
- Parse $ARGUMENTS: `<component-type> "<description>"`
- Extract COMPONENT_TYPE (first word)
- Extract DESCRIPTION (quoted text)
- Convert type to snake_case if needed
- Display: "Adding infrastructure: [COMPONENT_TYPE]"
- Update todos

Phase 2: Initial Assessment
Goal: Understand current state and determine next ID

Actions:
- **Read schema templates:**
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-detection/templates/project-json-schema.json
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/spec-management/templates/features-json-schema.json

- **Read project.json:**
  - @.claude/project.json
  - Find highest infrastructure ID (e.g., I042)
  - Calculate next ID (I043)
  - Note existing infrastructure for context

- **Read features.json:**
  - @features.json
  - Note features that might need this infrastructure

- **Check for duplicates:**
  - Does similar infrastructure already exist?
  - If yes: Ask user to confirm or update existing

- Display: "Next ID: I[XXX], Found [N] existing infrastructure items"
- Update todos

Phase 3: Launch Infrastructure Writer Agent
Goal: Deep analysis and spec generation

Actions:
- Launch infrastructure-writer agent:

```
Task(
  description="Analyze and create infrastructure I[XXX]",
  subagent_type="foundation:infrastructure-writer",
  prompt="Create infrastructure component I[XXX]: [COMPONENT_TYPE]

  Description: [DESCRIPTION]

  Context provided:
  - Next ID: I[XXX]
  - Existing infrastructure count: [N]

  Your tasks:
  1. Analyze what this component depends on (look at description keywords)
  2. Calculate phase: phase = max(dependency phases) + 1, or 0 if no deps
  3. Determine what features/infrastructure this blocks
  4. Generate spec files:
     - specs/infrastructure/phase-[N]/[number]-[name]/spec.md
     - specs/infrastructure/phase-[N]/[number]-[name]/tasks.md

  Return JSON:
  {
    'id': 'I0XX',
    'name': 'component-name',
    'phase': N,
    'depends_on': ['I001', 'I010'],
    'blocks': ['F040', 'I050'],
    'spec_path': 'specs/infrastructure/phase-N/...',
    'files_created': ['spec.md', 'tasks.md']
  }"
)
```

- Parse agent response
- Store results for next phases
- Update todos

Phase 4: Update project.json
Goal: Add component to infrastructure section

Actions:
- Read .claude/project.json
- Add new infrastructure entry using agent's analysis:
  ```json
  {
    "id": "[from agent]",
    "name": "[COMPONENT_TYPE]",
    "description": "[DESCRIPTION]",
    "priority": "high",
    "phase": [from agent],
    "depends_on": [from agent],
    "blocks": [from agent]
  }
  ```
- Write updated project.json
- Display: "✅ Added I[XXX] to project.json (Phase [N])"
- Update todos

Phase 5: Sync features.json
Goal: Update features that depend on this infrastructure

Actions:
- Read features.json
- For features in agent's "blocks" list:
  - Add I[XXX] to their infrastructure_dependencies
  - Recalculate infrastructure_phase if needed
  - Display: "Updated F[XXX] with I[XXX] dependency"
- Write updated features.json
- Display: "✅ Synced [N] features"
- Update todos

Phase 6: Summary
Goal: Report results and next steps

Actions:
- Mark all todos complete
- Display:
  ```
  ✅ Infrastructure Component Added: I[XXX]

  Component: [COMPONENT_TYPE]
  Phase: [N]
  Depends on: [list]
  Blocks: [list]

  Files Created:
  - [spec_path]/spec.md
  - [spec_path]/tasks.md

  Features Updated: [list or "None"]

  Next Steps:
  - Review spec in [spec_path]/
  - Run /implementation:execute I[XXX] to build it
  ```

---
description: Add infrastructure component to project.json and generate spec
argument-hint: <component-type> "<description>"
allowed-tools: Read, Bash, Task, TodoWrite
---

**Arguments**: $ARGUMENTS

Goal: Add infrastructure component by delegating to infrastructure-writer agent for deep analysis.

Phase 1: Parse Arguments
Goal: Extract component type and description

Actions:
- Create todo: "Add infrastructure component"
- Parse $ARGUMENTS: `<component-type> "<description>"`
- Extract COMPONENT_TYPE (first word)
- Extract DESCRIPTION (quoted text)
- Display: "Adding infrastructure: [COMPONENT_TYPE]"

Phase 2: Launch Infrastructure Writer Agent
Goal: Delegate analysis and creation to agent with full context

Actions:
- Launch infrastructure-writer agent:

```
Task(
  description="Add infrastructure [COMPONENT_TYPE]",
  subagent_type="foundation:infrastructure-writer",
  prompt="Add new infrastructure component to project.

  Component Type: [COMPONENT_TYPE]
  Description: [DESCRIPTION]

  Read schema templates first:
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-detection/templates/project-json-schema.json
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/spec-management/templates/features-json-schema.json

  CRITICAL - Full Analysis Required:
  1. Read ENTIRE .claude/project.json - understand ALL infrastructure items
  2. Read ENTIRE features.json - understand ALL features and their dependencies
  3. Analyze the full dependency graph
  4. Determine where this component ACTUALLY fits:
     - What existing infrastructure does it depend on?
     - What features will need this?
     - What phase should it be in based on dependencies?
  5. Look for related infrastructure that might also be dependencies
  6. Check if similar infrastructure already exists

  Then:
  1. Calculate correct phase from dependency analysis
  2. Update project.json with new component (correct ID, phase, depends_on, blocks)
  3. Create spec in specs/infrastructure/phase-[N]/[number]-[name]/
     - spec.md - requirements and design
     - tasks.md - implementation tasks
  4. Update features.json - add this to infrastructure_dependencies of affected features
  5. Recalculate feature phases if needed

  Return summary:
  - Component ID and name
  - Phase and why
  - Dependencies (what it depends on)
  - Blocks (what depends on it)
  - Features updated
  - Files created"
)
```

Phase 3: Display Results
Goal: Show what was created

Actions:
- Display agent's summary
- Mark todo complete
- Next steps:
  * Review spec in specs/infrastructure/phase-[N]/
  * Run /implementation:execute I[XXX] to build it

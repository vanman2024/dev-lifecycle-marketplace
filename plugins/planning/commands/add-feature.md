---
description: Add complete feature with roadmap, spec, ADR, and architecture updates
argument-hint: <feature-description> OR --doc=<path/to/document.md>
allowed-tools: Read, Bash, Task, TodoWrite, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Add a new feature with complete planning documentation. Delegates to feature-analyzer agent for heavy lifting.

Phase 1: Parse Input
Goal: Determine input mode and basic context

Actions:
- Create todo: "Add feature to project"
- Parse $ARGUMENTS:
  * If contains "--doc=": MODE = "document", extract DOC_PATH
  * Otherwise: MODE = "text", DESCRIPTION = $ARGUMENTS
- If MODE = "document":
  * Validate file exists: !{bash test -f "$DOC_PATH" && echo "exists" || echo "missing"}
  * If missing: Error and exit
- Display: "Mode: [MODE]"

Phase 2: Launch Feature Analyzer
Goal: Analyze context and determine what to create

Actions:
- Launch feature-analyzer agent:

```
Task(
  description="Analyze feature and context",
  subagent_type="planning:feature-analyzer",
  prompt="Analyze this feature request and project context.

  Input Mode: [MODE]
  Description: $ARGUMENTS
  Document Path: [DOC_PATH if applicable]

  Read schema templates:
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-detection/templates/project-json-schema.json
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/spec-management/templates/features-json-schema.json

  Analyze:
  1. Read .claude/project.json for tech stack and infrastructure
  2. Read features.json for existing features
  3. Check for similar existing specs (>70% similarity → redirect to update-feature)
  4. Identify infrastructure dependencies (I0XX IDs)
  5. Calculate feature phase from dependencies
  6. Determine if ADR needed (new tech/architecture)
  7. Determine priority (P0/P1/P2)

  Return JSON:
  {
    'next_number': 'F0XX',
    'name': 'feature-name',
    'phase': N,
    'priority': 'P0/P1/P2',
    'infrastructure_dependencies': ['I001', 'I010'],
    'feature_dependencies': ['F001'],
    'needs_adr': true/false,
    'needs_architecture_update': true/false,
    'similar_spec': null or 'F0XX',
    'description': 'extracted description'
  }"
)
```

- Parse agent response
- If similar_spec found:
  * Display: "Found similar spec [similar_spec]. Redirecting to update-feature."
  * Exit - user should run /planning:update-feature instead

Phase 3: Update features.json
Goal: Add feature entry before generating docs

Actions:
- Read features.json (or create if missing)
- Add feature entry with:
  * id, name, description, status: "planned"
  * priority, phase, infrastructure_dependencies, dependencies
  * created date
- Update phases summary array
- Write features.json
- Display: "✅ Added F[NUMBER] to features.json (Phase [PHASE])"

Phase 4: Generate Documentation in Parallel
Goal: Create all docs simultaneously

Actions:
- Launch ALL applicable agents in ONE message:

```
Task(
  description="Generate feature spec",
  subagent_type="planning:feature-spec-writer",
  prompt="Create spec for F[NUMBER]: [DESCRIPTION].
  Phase: [PHASE]. Priority: [PRIORITY].
  Infrastructure deps: [IDS]. Feature deps: [IDS].
  Create: specs/phase-[PHASE]/F[NUMBER]-[slug]/spec.md and tasks.md"
)

Task(
  description="Update roadmap",
  subagent_type="planning:roadmap-planner",
  prompt="Add F[NUMBER] to ROADMAP.md: [DESCRIPTION].
  Priority: [PRIORITY]. Phase: [PHASE]. Dependencies: [list]."
)
```

- IF needs_adr:
```
Task(
  description="Create ADR",
  subagent_type="planning:decision-documenter",
  prompt="Create ADR for F[NUMBER]: [DESCRIPTION].
  Document decision, alternatives, consequences."
)
```

- IF needs_architecture_update:
```
Task(
  description="Update architecture",
  subagent_type="planning:architecture-designer",
  prompt="Update docs/architecture/ for F[NUMBER]: [DESCRIPTION]."
)
```

Phase 5: Summary
Goal: Report results and next steps

Actions:
- Mark todo complete
- Display: "✅ Created:"
  * Spec: specs/phase-[PHASE]/F[NUMBER]-[slug]/
  * Roadmap: Updated
  * ADR: (if created)
  * Architecture: (if updated)
- Next steps:
  * Review spec in specs/phase-[PHASE]/F[NUMBER]-[slug]/
  * Run /implementation:execute F[NUMBER] to build the feature
  * Or run /implementation:execute to auto-continue



---
description: Add complete feature with roadmap, spec, ADR, and architecture updates
argument-hint: <feature-description> OR --plan=<name> OR --doc=<path>
allowed-tools: Read, Bash, Task, TodoWrite, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Add a new feature with complete planning documentation. First analyzes if request should be an enhancement to existing feature, then delegates appropriately.

Phase 1: Parse Input
Goal: Determine input mode and basic context

Actions:
- Create todo: "Add feature to project"
- Parse $ARGUMENTS:
  * If contains "--plan=": MODE = "plan", extract PLAN_NAME
    - Look for plan in ~/.claude/plans/
    - Try exact match: ~/.claude/plans/[PLAN_NAME].md
    - Try partial match: ~/.claude/plans/*[PLAN_NAME]*.md
    - Set DOC_PATH to found plan
  * If contains "--doc=": MODE = "document", extract DOC_PATH
  * If contains "--force-new": SKIP_ENHANCEMENT_CHECK = true
  * If empty or not provided: MODE = "auto-detect"
    - Find most recent plan: !{bash ls -t ~/.claude/plans/*.md 2>/dev/null | head -5}
    - If plan modified within last 2 hours, use AskUserQuestion:
      "Use recent plan '[filename]' created [time ago]?" with options: Yes, No
    - If Yes: Set DOC_PATH to that plan
    - If No: MODE = "text", prompt for description
  * Otherwise: MODE = "text", DESCRIPTION = $ARGUMENTS
- Validate file exists if MODE = "plan" or "document"
- Display: "Mode: [MODE], Source: [DOC_PATH or 'text input']"

Phase 2: Enhancement Analysis
Goal: Determine if request should be enhancement or new feature

Actions:
- If SKIP_ENHANCEMENT_CHECK = true: Skip to Phase 3
- Launch enhancement-analyzer agent:

Task(
  description="Analyze enhancement vs new feature",
  subagent_type="planning:enhancement-analyzer",
  prompt="Analyze this request to determine if it should be an enhancement to an existing feature or a new feature.

  Description: $ARGUMENTS
  Plan Content: [PLAN_CONTENT if applicable]

  Read and analyze:
  - roadmap/features.json - all existing features
  - roadmap/enhancements.json - existing enhancements (if exists)
  - specs/features/ - spec directories

  Return JSON with recommendation, confidence, parent_feature (if enhancement), rationale."
)

- Parse response
- If recommendation = "enhancement" AND confidence >= 0.7:
  * Display: "This appears to be an enhancement to [PARENT_FEATURE]"
  * Use AskUserQuestion:
    "Create as enhancement to [PARENT_FEATURE] or new standalone feature?"
    Options: Enhancement (recommended), New Feature
  * If Enhancement: Redirect to /planning:add-enhancement [PARENT_ID] [NEXT_E###] "[NAME]"
  * If New Feature: Continue to Phase 3

Phase 3: Feature Analysis
Goal: Analyze context and determine feature details

Actions:
- Launch feature-analyzer agent:

Task(
  description="Analyze feature and context",
  subagent_type="planning:feature-analyzer",
  prompt="Analyze this feature request and project context.

  Input Mode: [MODE]
  Description: $ARGUMENTS
  Document Path: [DOC_PATH if applicable]
  Plan Content: [PLAN_CONTENT]

  Analyze:
  1. Read .claude/project.json for tech stack
  2. Read features.json for existing features
  3. Identify infrastructure dependencies (I0XX IDs)
  4. Calculate feature phase from dependencies
  5. Determine if ADR needed
  6. Determine priority (P0/P1/P2)

  Return JSON:
  {
    'next_number': 'F0XX',
    'name': 'feature-name',
    'phase': N,
    'priority': 'P0/P1/P2',
    'infrastructure_dependencies': ['I001'],
    'feature_dependencies': ['F001'],
    'needs_adr': true/false,
    'needs_architecture_update': true/false,
    'description': 'extracted description'
  }"
)

Phase 4: Update features.json
Goal: Add feature entry before generating docs

Actions:
- Read features.json (or create if missing)
- Add feature entry with: id, name, description, status, priority, phase, dependencies
- Update phases summary array
- Write features.json
- Display: "Added F[NUMBER] to features.json (Phase [PHASE])"

Phase 5: Generate Documentation in Parallel
Goal: Create all docs simultaneously

Actions:
- Launch ALL applicable agents in ONE message:

Task(description="Generate feature spec", subagent_type="planning:feature-spec-writer",
  prompt="Create spec for F[NUMBER]: [DESCRIPTION]. Phase: [PHASE]. Priority: [PRIORITY].
  Create: specs/features/phase-[PHASE]/F[NUMBER]-[slug]/spec.md and tasks.md")

Task(description="Update roadmap", subagent_type="planning:roadmap-planner",
  prompt="Add F[NUMBER] to ROADMAP.md: [DESCRIPTION]. Priority: [PRIORITY]. Phase: [PHASE].")

- IF needs_adr: Launch decision-documenter agent
- IF needs_architecture_update: Launch architecture-designer agent

Phase 6: Summary
Goal: Report results and next steps

Actions:
- Mark todo complete
- Display created files and next steps
- Suggest: /implementation:execute F[NUMBER] to build the feature

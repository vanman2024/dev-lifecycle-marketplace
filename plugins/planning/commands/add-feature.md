---
description: Add complete feature with roadmap, spec, ADR, and architecture updates - keeps all planning docs in sync
argument-hint: <feature-description>
allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, TodoWrite
---

**Arguments**: $ARGUMENTS

Goal: Add a new feature to the project with complete planning documentation that stays synchronized across roadmap, specs, ADRs, and architecture.

Core Principles:
- Roadmap-first: Update strategic view before tactical details
- Complete sync: All planning docs updated together
- Architecture decisions tracked: Create ADRs for new tech/approaches
- User validation: Get approval before generating all docs

Phase 1: Discovery
Goal: Gather feature requirements and context

Actions:
- Create todo list tracking workflow phases using TodoWrite
- Parse $ARGUMENTS for initial feature description
- If $ARGUMENTS is unclear or too brief, use AskUserQuestion to gather:
  - What is the feature name and purpose?
  - What problem does it solve?
  - What are the key requirements?
  - Any technical constraints?
- Load existing planning context:
  - Check if ROADMAP.md exists: !{bash test -f docs/ROADMAP.md && echo "exists" || echo "missing"}
  - Check if architecture docs exist: !{bash test -d docs/architecture && echo "exists" || echo "missing"}
  - Find highest existing spec number: !{bash find specs/features -maxdepth 1 -name "[0-9][0-9][0-9]-*" -type d 2>/dev/null | sort | tail -1 | grep -oE '[0-9]{3}' | head -1}

Phase 1.5: Similarity Check
Goal: Detect if this is an enhancement to existing feature or truly new

Actions:
- List all existing specs: !{bash ls -d specs/features/[0-9][0-9][0-9]-*/ 2>/dev/null}
- For each existing spec, read the spec.md file to extract name and description
- Compare $ARGUMENTS against existing feature names/descriptions
- Look for keyword matches, similar concepts, related functionality
- If potential match found (>70% similarity):
  - Use AskUserQuestion: "This feature sounds related to existing spec(s):
    - [SPEC_NUMBER]: [SPEC_NAME] ([SIMILARITY]% match)

    Is this:
    1. New standalone feature (create new spec [NEXT_NUMBER])
    2. Enhancement to spec [SPEC_NUMBER] (update existing)
    3. Additional tasks for spec [SPEC_NUMBER] (update tasks only)"
  - If user selects "Enhancement" or "Additional tasks":
    - Stop this command
    - Display: "Redirecting to /planning:update-feature [SPEC_NUMBER] with your description"
    - Exit (user should run update-feature instead)
  - If user selects "New standalone feature":
    - Continue to Phase 2
- If no similar specs found or similarity <70%:
  - Continue to Phase 2 (create new spec)

Phase 2: Feature Planning
Goal: Determine feature details and placement

Actions:
- Calculate next spec number (N+1 from highest)
- Use AskUserQuestion to gather:
  - Priority level? (P0, P1, P2)
  - Which phase should this be in? (Current sprint, Next sprint, Future)
  - Dependencies on existing features? (list spec numbers)
  - Does this require new technology/architecture decision?
  - Estimated complexity? (Simple: 1-2 days, Moderate: 2-3 days, Complex: 3-5 days)
- Determine if ADR needed based on new tech/architecture decision
- Determine if architecture docs need updates

Phase 3: Generate Spec
Goal: Create detailed feature specification

Actions:

Task(description="Generate feature spec", subagent_type="planning:feature-spec-writer", prompt="Create complete spec for: $ARGUMENTS. Spec number: [NEXT_NUMBER]. Priority: [P0/P1/P2]. Dependencies: [list]. Read architecture docs, reference them (don't duplicate). Create specs/features/[NUMBER]-[slug]/spec.md and tasks.md. Follow minimal format (100-150 lines).")

Update todos

Phase 4: Update Roadmap
Goal: Add feature to strategic roadmap

Actions:

Task(description="Update roadmap", subagent_type="planning:roadmap-planner", prompt="Add feature [NUMBER] to ROADMAP.md: $ARGUMENTS. Priority: [P0/P1/P2]. Phase: [X]. Complexity: [X days]. Dependencies: [list]. Read docs/ROADMAP.md, add to appropriate phase, recalculate totals, update gantt if present.")

Update todos

Phase 5: Create ADR (if needed)
Goal: Document architecture decision

Actions:
- If new architecture decision needed:
  Task(description="Create ADR", subagent_type="planning:decision-documenter", prompt="Create ADR for $ARGUMENTS decision: [context from Phase 2]. Determine next ADR number from docs/adr/. Document what/why/alternatives/consequences. Reference spec [NUMBER]. Create docs/adr/[NUMBER]-[slug].md.")
- Update todos

Phase 6: Update Architecture (if needed)
Goal: Update architecture docs

Actions:
- If architecture updates needed:
  Task(description="Update architecture", subagent_type="planning:architecture-designer", prompt="Update docs/architecture/ for $ARGUMENTS. Changes: [from Phase 2]. Read relevant files, update sections, add mermaid diagrams if needed. Cross-reference spec and ADR.")
- Update todos

Phase 7: Register in Mem0
Goal: Store relationships for synchronization

Actions:
- Run doc-sync: !{bash python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py}
- Update todos

Phase 8: Summary
Goal: Report results

Actions:
- Mark all todos complete
- Display:
  - Spec: specs/features/[NUMBER]-[slug]/
  - Roadmap: Updated (Phase X, Priority P0/P1/P2, [X days])
  - ADR: docs/adr/[NUMBER]-.md (if created)
  - Architecture: Updated files (if applicable)
- Next steps: Review spec, /supervisor:init [NUMBER], begin implementation

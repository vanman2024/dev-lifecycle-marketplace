---
description: Add complete feature with roadmap, spec, ADR, and architecture updates - accepts text or document input
argument-hint: <feature-description> OR --doc=<path/to/document.md>
---

**Arguments**: $ARGUMENTS

Goal: Add a new feature to the project with complete planning documentation that stays synchronized across roadmap, specs, ADRs, and architecture. Can accept text description OR analyze an existing document to intelligently determine what needs to be created.

Core Principles:
- Roadmap-first: Update strategic view before tactical details
- Complete sync: All planning docs updated together
- Architecture decisions tracked: Create ADRs for new tech/approaches
- Document-driven: Can analyze existing docs and intelligently route
- User validation: Get approval before generating all docs

Phase 1: Input Analysis
Goal: Parse input (text description OR document) and extract feature requirements

Actions:
- Create todo list tracking workflow phases using TodoWrite
- Parse $ARGUMENTS to detect mode:
  * If contains "--doc=" → Extract file path, set MODE=DOCUMENT
  * Otherwise → Set MODE=TEXT, store description

- **If MODE=DOCUMENT**:
  - Extract document path from $ARGUMENTS (after --doc=)
  - Validate file exists: !{bash test -f "$DOC_PATH" && echo "exists" || echo "missing"}
  - If missing: Display error and exit
  - Read document: @{DOC_PATH}
  - Extract from document:
    * Feature name/title
    * Purpose/problem being solved
    * Requirements (technical and functional)
    * Proposed technical approach
    * Any architecture decisions mentioned
  - Store as FEATURE_DESCRIPTION

- **If MODE=TEXT**:
  - Use $ARGUMENTS as FEATURE_DESCRIPTION
  - If $ARGUMENTS is unclear or too brief, use AskUserQuestion to gather:
    * What is the feature name and purpose?
    * What problem does it solve?
    * What are the key requirements?
    * Any technical constraints?

- Load existing planning context:
  - Check if ROADMAP.md exists: !{bash test -f docs/ROADMAP.md && echo "exists" || echo "missing"}
  - Check if architecture docs exist: !{bash test -d docs/architecture && echo "exists" || echo "missing"}
  - Check if specs directory exists: !{bash test -d specs/features && echo "exists" || echo "missing"}
  - Find highest existing spec number: !{bash find specs/features -maxdepth 1 -name "[0-9][0-9][0-9]-*" -type d 2>/dev/null | sort | tail -1 | grep -oE '[0-9]{3}' | head -1}

Phase 1.5: Intelligent Document Analysis (If MODE=DOCUMENT)
Goal: Determine what this document represents and route appropriately

Actions:
- **Only run if MODE=DOCUMENT**

- Analyze document against existing context:

  **1. Compare to existing specs:**
  - List all existing specs: !{bash ls -d specs/features/[0-9][0-9][0-9]-*/ 2>/dev/null}
  - For each spec, read spec.md
  - Compare document content to each spec (keyword matching, concept similarity)
  - Calculate similarity scores

  **2. Compare to existing architecture docs:**
  - List architecture docs: !{bash ls docs/architecture/*.md 2>/dev/null}
  - Check if document is architectural refinement vs new functionality
  - If document mostly describes "how" (architecture) vs "what" (features)

  **3. Check for new architectural decisions:**
  - Scan document for decision keywords: "we will use", "approach", "chosen", "decided"
  - Compare against existing ADRs: !{bash ls docs/adr/*.md 2>/dev/null}
  - Determine if new ADR needed

- Determine document type:
  * **NEW FEATURE** (>70% similarity to existing spec → ENHANCEMENT)
  * **FEATURE ENHANCEMENT** (high similarity to existing spec)
  * **ARCHITECTURE REFINEMENT** (no new functionality, design detail only)
  * **NEW DECISION** (contains architectural decisions not documented)
  * **HYBRID** (new feature + architecture + decision)

- Route based on analysis:

  **If ENHANCEMENT (>70% similarity to existing spec):**
  - Display: "📊 Document Analysis: This appears to be an enhancement to existing spec [SPEC_NUMBER]: [SPEC_NAME] ([SIMILARITY]% match)"
  - Use AskUserQuestion: "Detected similar existing spec. How to proceed?
    1. Update existing spec [SPEC_NUMBER] (recommended)
    2. Create new spec (standalone feature)
    3. Architecture refinement only (no spec needed)"
  - If option 1: Display "Redirecting to /planning:update-feature [SPEC_NUMBER] --doc=$DOC_PATH" and EXIT
  - If option 2: Continue to Phase 2 (create new spec)
  - If option 3: Skip to architecture update only

  **If ARCHITECTURE REFINEMENT:**
  - Display: "📊 Document Analysis: This appears to be architecture refinement (no new functionality detected)"
  - Use AskUserQuestion: "This document seems to refine architecture without adding features. Proceed with:
    1. Update architecture docs only (no spec created)
    2. Create spec anyway (treat as feature)"
  - If option 1: Skip to Phase 6 (update architecture) and EXIT
  - If option 2: Continue to Phase 2

  **If NEW DECISION:**
  - Display: "📊 Document Analysis: New architectural decision detected"
  - Set ADR_REQUIRED=true
  - Continue to Phase 2

  **If HYBRID or NEW FEATURE:**
  - Display: "📊 Document Analysis: New feature detected (no conflicts with existing specs)"
  - Continue to Phase 2

Phase 2: Similarity Check (If MODE=TEXT or not analyzed in Phase 1.5)
Goal: Detect if this is an enhancement to existing feature or truly new

Actions:
- **Skip if already analyzed in Phase 1.5 (document mode with routing decision)**

- List all existing specs: !{bash ls -d specs/features/[0-9][0-9][0-9]-*/ 2>/dev/null}
- For each existing spec, read the spec.md file to extract name and description
- Compare FEATURE_DESCRIPTION against existing feature names/descriptions
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
    - Continue to Phase 3
- If no similar specs found or similarity <70%:
  - Continue to Phase 3 (create new spec)

Phase 3: Feature Planning
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

Phase 4: Generate Spec
Goal: Create detailed feature specification

Actions:

Task(description="Generate feature spec", subagent_type="planning:feature-spec-writer", prompt="Create complete spec for: [FEATURE_DESCRIPTION]. Spec number: [NEXT_NUMBER]. Priority: [P0/P1/P2]. Dependencies: [list]. Read architecture docs, reference them (don't duplicate). If document mode: Use [DOC_PATH] as primary source. Create specs/features/[NUMBER]-[slug]/spec.md and tasks.md. Follow minimal format (100-150 lines).")

Update todos

Phase 5: Update Roadmap
Goal: Add feature to strategic roadmap

Actions:

Task(description="Update roadmap", subagent_type="planning:roadmap-planner", prompt="Add feature [NUMBER] to ROADMAP.md: [FEATURE_DESCRIPTION]. Priority: [P0/P1/P2]. Phase: [X]. Complexity: [X days]. Dependencies: [list]. Read docs/ROADMAP.md, add to appropriate phase, recalculate totals, update gantt if present.")

Update todos

Phase 6: Create ADR (if needed)
Goal: Document architecture decision

Actions:
- If new architecture decision needed (from Phase 2/3) OR ADR_REQUIRED=true (from Phase 1.5):
  Task(description="Create ADR", subagent_type="planning:decision-documenter", prompt="Create ADR for [FEATURE_DESCRIPTION] decision: [context from analysis]. Determine next ADR number from docs/adr/. Document what/why/alternatives/consequences. Reference spec [NUMBER]. If document mode: Extract decision details from [DOC_PATH]. Create docs/adr/[NUMBER]-[slug].md.")
- Update todos

Phase 7: Update Architecture (if needed)
Goal: Update architecture docs

Actions:
- If architecture updates needed OR MODE=DOCUMENT with architectural content:
  Task(description="Update architecture", subagent_type="planning:architecture-designer", prompt="Update docs/architecture/ for [FEATURE_DESCRIPTION]. Changes: [from Phase 3]. If document mode: Use [DOC_PATH] as source for architectural details. Read relevant files, update sections, add mermaid diagrams if needed. Cross-reference spec and ADR.")
- Update todos

Phase 8: Summary
Goal: Report results

Actions:
- Mark all todos complete
- Display mode-specific summary:
  * If MODE=DOCUMENT:
    - Display: "📄 Processed document: [DOC_PATH]"
    - Display: "📊 Analysis: [NEW FEATURE/ENHANCEMENT/HYBRID]"
  * Display: "✅ Created:"
    - Spec: specs/features/[NUMBER]-[slug]/
    - Roadmap: Updated (Phase X, Priority P0/P1/P2, [X days])
    - ADR: docs/adr/[NUMBER]-[slug].md (if created)
    - Architecture: Updated files (if applicable)
- Next steps: Review spec, /iterate:tasks [NUMBER], begin implementation

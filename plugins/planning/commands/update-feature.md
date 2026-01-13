---
description: Update existing feature across roadmap, specs, and project files. Supports feature updates and enhancement management.
argument-hint: <feature-id> [changes] [--add-enhancement] [--all]
allowed-tools: Read, Write, Edit, Bash, Task, TodoWrite, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Update an existing feature across all planning documentation. Also handles adding/updating enhancements.

Core Principles:
- Identify scope: Requirements vs priority vs architecture vs enhancement
- Cascade updates across all affected docs
- Support enhancement management within features
- Maintain consistency across roadmap, specs, enhancements.json

Phase 1: Discovery
Goal: Identify feature and understand what needs to change

Actions:
- Create todo list using TodoWrite
- Parse $ARGUMENTS for:
  - Feature ID (F###) or --all flag
  - Change description
  - Flags: --add-enhancement, --all
- If --add-enhancement flag:
  - Redirect to: /planning:add-enhancement [FEATURE_ID] "[DESCRIPTION]"
  - Exit
- If --all flag:
  - Display: "Updating ALL features with change: [changes]"
  - List all features and confirm
- Validate feature exists:
  !{bash find specs/features -type d -name "${FEATURE_ID}-*" 2>/dev/null | head -1}
- Load existing feature files: spec.md, tasks.md
- Check for enhancements: !{bash ls specs/features/*/[FEATURE_ID]-*/enhancements/ 2>/dev/null}

Phase 2: Determine Change Scope
Goal: Understand what changed and what needs updating

Actions:
- Use AskUserQuestion to determine change type:
  - What changed? (select all that apply)
    - Requirements/scope changed
    - Priority changed
    - Timeline/phase changed
    - Architecture/approach changed
    - Dependencies changed
    - Enhancement updates
- For each change type, determine affected docs:
  - Requirements -> spec.md, tasks.md
  - Priority -> spec.md, roadmap/, features.json
  - Enhancement -> enhancements/, enhancements.json
- Ask: Does this change require a new ADR?

Phase 3: Update Spec
Goal: Update feature specification

Actions:
- If spec changes needed:

Task(description="Update spec", subagent_type="planning:feature-spec-writer",
  prompt="Update spec [FEATURE_ID]-[NAME] with changes: [from Phase 2].
  Read and update spec.md, tasks.md. Maintain format and architecture references.")

- Update todos

Phase 4: Update Enhancements (if applicable)
Goal: Update enhancements for this feature

Actions:
- If enhancement updates needed:
  - List existing enhancements: !{bash ls -d specs/features/*/[FEATURE_ID]-*/enhancements/E* 2>/dev/null}
  - For each enhancement to update:
    - Read enhancement spec.md and tasks.md
    - Apply changes
    - Write updated files
  - Update roadmap/enhancements.json:
    - Read file
    - Find enhancement entries for this feature
    - Update status, tasks_total, tasks_completed
    - Write file
  - Update features.json enhancements array
- Update todos

Phase 5: Update Roadmap
Goal: Update roadmap files

Actions:
- If Priority/Timeline/Dependencies changed:

Task(description="Update roadmap", subagent_type="planning:roadmap-planner",
  prompt="Update roadmap for [FEATURE_ID]: Priority [old->new], Timeline [old->new].
  Update docs/ROADMAP.md and roadmap/features.json.")

- Update todos

Phase 6: Create ADR (if needed)
Goal: Document decision change

Actions:
- If architecture decision changed:

Task(description="Create ADR", subagent_type="planning:decision-documenter",
  prompt="Create ADR for [FEATURE_ID] decision change: [from Phase 2].
  Document old->new approach, rationale, impact.")

- Update todos

Phase 7: Update Architecture (if needed)
Goal: Update architecture documentation

Actions:
- If architecture approach changed:

Task(description="Update architecture", subagent_type="planning:architecture-designer",
  prompt="Update docs/architecture/ for [FEATURE_ID] changes.")

- Update todos

Phase 8: Sync JSON Files
Goal: Ensure all JSON files are consistent

Actions:
- Read and update features.json
- Read and update enhancements.json (if exists)
- Recalculate task counts
- Update status based on progress
- Write updated files

Phase 9: Summary
Goal: Report results

Actions:
- Mark all todos complete
- Display:
  - Feature: [FEATURE_ID]-[NAME]
  - Changes: Spec, Roadmap, Enhancements, ADR, Architecture
  - Enhancements: [count] total, [updated] updated
- Show changes: !{bash git status --short specs/ roadmap/ docs/}
- Next steps: Review changes, commit when ready

---
description: Sync project state - update specs, tasks, and documentation based on current implementation
argument-hint: none
allowed-tools: Task(*), Read(*), Write(*), Bash(*), Glob(*), Grep(*)
---

**Arguments**: $ARGUMENTS

Goal: Synchronize project documentation with actual implementation state

Core Principles:
- Keep docs in sync with code
- Update task status based on implementation
- Reflect current architecture
- Maintain spec accuracy

## Phase 1: Discovery
Goal: Identify current project state

Actions:
- Load project structure:
  !{bash find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) -not -path "*/node_modules/*" -not -path "*/.next/*" -not -path "*/.venv/*" | wc -l}
- Check for specs:
  !{bash ls -d specs/* 2>/dev/null | wc -l}
- Check for architecture docs:
  !{bash test -f docs/architecture/README.md && echo "✅ Architecture exists" || echo "❌ No architecture"}
- Check git status:
  !{bash git status --short | wc -l}
- Load project context:
  @.claude/project.json

## Phase 2: Analysis
Goal: Identify what's out of sync

Actions:
- Compare specs vs implementation:
  - List all specs: !{bash find specs -name "README.md" -type f 2>/dev/null}
  - Check implementation directories for each spec
- Check task completion status:
  - Find layered-tasks.md files: !{bash find specs -name "layered-tasks.md" 2>/dev/null}
  - Compare tasks vs implemented features
- Review recent commits for undocumented changes:
  !{bash git log --oneline -20}
- Identify documentation gaps:
  - Missing ADRs for decisions
  - Outdated architecture diagrams
  - Stale task lists

## Phase 3: Planning
Goal: Determine sync strategy

Actions:
- Prioritize sync targets:
  1. Critical spec updates (completed features marked as done)
  2. Task status updates (reflect implementation state)
  3. Architecture documentation (match current structure)
  4. ADRs (document undocumented decisions)
- Identify files to update:
  - Spec README.md files
  - layered-tasks.md files
  - Architecture docs
  - Roadmap (if exists)

## Phase 4: Execution
Goal: Sync documentation with implementation

Actions:
- Update spec status for completed features:
  !{bash find specs -name "README.md" -exec bash -c 'grep -l "status: in-progress\|status: pending" "$1" 2>/dev/null' _ {} \;}
- Mark completed tasks in layered-tasks.md:
  !{bash find specs -name "layered-tasks.md" 2>/dev/null}
- Update architecture documentation if structure changed
- Create missing ADRs for undocumented decisions
- Update roadmap completion percentages
- Display sync summary:
  - Files updated: X
  - Specs synchronized: Y
  - Tasks marked complete: Z

## Phase 5: Verification
Goal: Validate sync accuracy

Actions:
- Check updated files:
  !{bash git status --short}
- Verify spec statuses accurate:
  !{bash grep -r "status:" specs/*/README.md 2>/dev/null | head -10}
- Confirm task completion reflected:
  !{bash find specs -name "layered-tasks.md" -exec grep -l "✅\|completed" {} \; 2>/dev/null}

## Phase 6: Summary
Goal: Report sync results

Actions:
- Display: "Project documentation synchronized with implementation"
- Show files updated: !{bash git diff --name-only}
- Report sync statistics:
  - Specs updated: X
  - Tasks marked complete: Y
  - Docs refreshed: Z
- Suggest next steps:
  - "Review changes: git diff"
  - "Commit documentation updates"
  - "Run /planning:roadmap to update timeline"
- Note: "Regular syncing prevents documentation drift"

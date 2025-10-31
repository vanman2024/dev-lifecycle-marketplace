---
description: Adjust implementation based on feedback or requirements change
argument-hint: [file-or-feature]
allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Make targeted adjustments to implementation based on user feedback, changing requirements, or iteration needs

Core Principles:
- Minimal changes - only what's needed
- Preserve working code - don't break existing functionality
- Test-driven - verify changes don't introduce regressions
- Document changes - update comments and docs

## Phase 1: Discovery
Goal: Understand what needs adjustment

Actions:
- If no arguments provided, ask user:
  - "What needs to be adjusted?" (file path, feature name, or description)
  - "What's the feedback or requirement change?"
  - "What should the updated behavior be?"
- If arguments provided, parse for:
  - File path pattern (adjust specific files)
  - Feature name (adjust feature implementation)
  - General description (broader adjustments)
- Load project context:
  @.claude/project.json

## Phase 2: Analysis
Goal: Locate affected code and understand current state

Actions:
- If file path provided:
  - Validate file exists: !{bash test -f "$ARGUMENTS" && echo "✅ Found" || echo "❌ Not found"}
  - Read current implementation: @$ARGUMENTS
- If feature name provided:
  - Search for related files: !{bash find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) -not -path "*/node_modules/*" -not -path "*/.next/*" | head -20}
  - Grep for feature references: !{bash grep -r "$ARGUMENTS" --include="*.ts" --include="*.js" --include="*.py" --exclude-dir=node_modules --exclude-dir=.next | head -20}
- Load related specs if available:
  - Check specs directory: !{bash ls -d specs/* 2>/dev/null | head -10}
- Load related tests:
  - Find test files: !{bash find . -type f \( -name "*.test.*" -o -name "*.spec.*" \) | head -10}

## Phase 3: Planning
Goal: Determine adjustment strategy

Actions:
- Identify scope of changes:
  - Single file edit
  - Multiple related files
  - Architecture-level change
  - Test updates required
- Assess impact:
  - Breaking changes?
  - Backward compatibility needed?
  - Migration required?
- Plan verification:
  - Which tests to run
  - Manual verification steps
  - Documentation updates

## Phase 4: Implementation
Goal: Execute adjustments with implementation-adjuster agent

Actions:

Launch the implementation-adjuster agent to make targeted code adjustments.

Provide the agent with:
- Context: Current implementation state from Phase 2
- Requirement: User feedback/requirements change from arguments
- Constraints:
  - Minimize changes - preserve working code
  - Maintain code style and patterns
  - Update tests and documentation
  - No breaking changes unless explicitly requested
- Files to adjust: Identified in Phase 2
- Requirements:
  - Make precise, targeted changes
  - Preserve existing functionality
  - Update related tests
  - Update documentation if needed
  - Verify changes don't break build
- Deliverables:
  - Modified files with adjustments
  - Updated tests (if applicable)
  - Updated documentation (if applicable)
  - Summary of changes made

## Phase 5: Verification
Goal: Validate adjustments work correctly

Actions:
- Check files were modified:
  !{bash git status --short | grep "^ M"}
- Display changes made:
  !{bash git diff --stat}
- Run relevant tests if they exist:
  - TypeScript/JavaScript: !{bash npm test 2>/dev/null || echo "No npm tests"}
  - Python: !{bash pytest 2>/dev/null || python -m pytest 2>/dev/null || echo "No pytest"}
- Check build passes:
  - TypeScript: !{bash npx tsc --noEmit 2>&1 | head -20}

## Phase 6: Summary
Goal: Report adjustments and next steps

Actions:
- Display: "Implementation adjusted based on feedback"
- Show files modified: !{bash git diff --name-only}
- Summarize changes made
- Suggest next steps:
  - "Review changes with: git diff"
  - "Run full test suite to verify"
  - "Update spec or documentation if needed"
  - "Commit changes when satisfied"
- Note: "Changes are focused and minimal to reduce regression risk"

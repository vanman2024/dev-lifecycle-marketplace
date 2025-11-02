---
description: Refactor code for better maintainability and structure without changing functionality
argument-hint: [file-or-module]
allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Improve code structure, readability, and maintainability through refactoring while preserving all existing functionality

Core Principles:
- Preserve behavior - functionality stays the same
- Improve structure - better organization and patterns
- Enhance readability - clearer code and naming
- Reduce complexity - simpler, more maintainable code

## Phase 1: Discovery
Goal: Understand what needs refactoring

Actions:
- If no arguments provided, ask user:
  - "What code needs refactoring?" (file path, module, or area)
  - "What are the refactoring goals?" (reduce complexity, improve naming, extract functions, etc.)
  - "Any specific patterns or issues to address?"
- If arguments provided, parse for:
  - File path or pattern (refactor specific files)
  - Module name (refactor entire module)
  - Area description (broader refactoring scope)
- Load project context:
  @.claude/project.json

## Phase 2: Analysis
Goal: Identify refactoring opportunities

Actions:
- If file path provided:
  - Validate file exists: !{bash test -f "$ARGUMENTS" && echo "✅ Found" || echo "❌ Not found"}
  - Read current implementation: @$ARGUMENTS
  - Check for related files: !{bash find . -type f -name "*$(basename $ARGUMENTS .*).*" | head -10}
- If module name provided:
  - Find all files in module: !{bash find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) -path "*$ARGUMENTS*" -not -path "*/node_modules/*" | head -20}
  - Scan for patterns: !{bash grep -r "class\|function\|def " --include="*.ts" --include="*.js" --include="*.py" "$ARGUMENTS" | head -20}
- Load test files to understand expected behavior:
  !{bash find . -type f \( -name "*.test.*" -o -name "*.spec.*" \) | grep -i "$ARGUMENTS" | head -10}
- Check code complexity indicators:
  - Line counts: !{bash wc -l $(find . -name "$ARGUMENTS*" -type f 2>/dev/null) 2>/dev/null | tail -1}
  - Function counts: !{bash grep -c "function\|def " $(find . -name "$ARGUMENTS*" -type f 2>/dev/null) 2>/dev/null}

## Phase 3: Planning
Goal: Determine refactoring strategy

Actions:
- Identify refactoring opportunities:
  - Long functions (>50 lines)
  - Duplicate code
  - Complex conditionals
  - Poor naming
  - Tight coupling
  - Missing abstractions
- Assess impact:
  - Which tests need to pass
  - Breaking changes (should be none)
  - Performance implications
- Plan verification:
  - Test suite to run
  - Manual verification steps
  - Code review checklist

## Phase 4: Refactoring
Goal: Execute refactoring with code-refactorer agent

Actions:

Launch the code-refactorer agent to improve code structure and maintainability.

Provide the agent with:
- Context: Current implementation state from Phase 2
- Scope: Files/modules identified in Phase 1
- Constraints:
  - MUST preserve all existing functionality
  - MUST maintain backward compatibility
  - MUST keep tests passing
  - Follow project code style and patterns
- Refactoring goals:
  - Improve code structure and organization
  - Enhance readability and naming
  - Reduce complexity and duplication
  - Extract reusable patterns
  - Better separation of concerns
- Requirements:
  - No behavior changes
  - All tests must still pass
  - Maintain API contracts
  - Improve code metrics (cyclomatic complexity, maintainability)
  - Add comments for complex logic
- Deliverables:
  - Refactored code with improved structure
  - All tests still passing
  - Summary of refactoring changes
  - Code metrics improvements

## Phase 5: Verification
Goal: Ensure refactoring didn't break anything

Actions:
- Check files were modified:
  !{bash git status --short | grep "^ M"}
- Display refactoring changes:
  !{bash git diff --stat}
- Run full test suite:
  - TypeScript/JavaScript: !{bash npm test 2>/dev/null || echo "No npm tests"}
  - Python: !{bash pytest 2>/dev/null || python -m pytest 2>/dev/null || echo "No pytest"}
- Check build still passes:
  - TypeScript: !{bash npx tsc --noEmit 2>&1 | head -20}
  - Python: !{bash python -m py_compile $(find . -name "*.py" -not -path "*/node_modules/*" | head -5) 2>&1}
- Verify no functionality changed:
  - Compare test results before/after
  - Check all tests still pass

## Phase 6: Summary
Goal: Report refactoring improvements

Actions:
- Display: "Code refactored successfully"
- Show files improved: !{bash git diff --name-only}
- Summarize refactoring changes:
  - Structure improvements
  - Complexity reductions
  - Naming enhancements
  - Pattern extractions
- Show metrics improvements (if available):
  - Lines of code change
  - Function count changes
  - Complexity reductions
- Suggest next steps:
  - "Review changes with: git diff"
  - "Verify tests pass: npm test / pytest"
  - "Check code quality metrics"
  - "Commit refactoring when satisfied"
- Note: "All functionality preserved - tests still pass"

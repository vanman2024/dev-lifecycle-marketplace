---
description: Refactor code for quality - improve code structure and maintainability without changing functionality
argument-hint: file-or-directory
---
## Available Skills

This commands has access to the following skills from the iterate plugin:

- **sync-patterns**: Compare specs with implementation state, update spec status, and generate sync reports. Use when syncing specs, checking implementation status, marking tasks complete, generating sync reports, or when user mentions spec sync, status updates, or implementation tracking.

**To use a skill:**
```
!{skill skill-name}
```

Use skills when you need:
- Domain-specific templates and examples
- Validation scripts and automation
- Best practices and patterns
- Configuration generators

Skills provide pre-built resources to accelerate your work.

---



## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Refactor code to improve structure, readability, and maintainability while preserving all existing functionality and behavior.

Core Principles:
- Understand code thoroughly before refactoring
- Preserve existing functionality - behavior must remain identical
- Follow existing code patterns and conventions
- Validate changes with tests to ensure no regressions
- Improve code quality without introducing new bugs

Phase 1: Discovery
Goal: Understand the refactoring target and scope

Actions:
- Parse $ARGUMENTS to identify target (file, directory, or module)
- Validate target exists and is accessible
- Example: !{bash test -e "$ARGUMENTS" && echo "Target found" || echo "Target not found"}
- If $ARGUMENTS is unclear or too broad, use AskUserQuestion to clarify:
  - What specific code needs refactoring?
  - What quality issues are you concerned about?
  - Any specific refactoring goals (reduce complexity, improve naming, extract methods)?
  - Any constraints (preserve API, maintain backwards compatibility)?

Phase 2: Context Loading
Goal: Load relevant code and understand current state

Actions:
- Load the target file(s) for analysis
- Example: @$ARGUMENTS
- If directory provided, identify key files to refactor
- Example: !{bash find "$ARGUMENTS" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" \) | head -20}
- Load related test files if they exist
- Understand dependencies and usage patterns

Phase 3: Analysis
Goal: Identify refactoring opportunities

Actions:
- Analyze code structure for improvement areas:
  - Long functions that should be split
  - Unclear variable/function names
  - Repeated code patterns (DRY violations)
  - Complex conditionals that need simplification
  - Code that violates SOLID principles
- Check if tests exist to validate refactoring
- Example: !{bash find . -type f \( -name "*.test.*" -o -name "*.spec.*" \) | grep -i "$(basename $ARGUMENTS)" || echo "No tests found"}

Phase 4: Refactoring Execution
Goal: Apply code improvements via specialized agent

Actions:

Task(description="Refactor code for quality", subagent_type="iterate:code-refactorer", prompt="You are the code-refactorer agent. Refactor code for: $ARGUMENTS

Context:
- Target has been validated and loaded
- Focus on improving code quality without changing functionality
- All existing behavior MUST be preserved

Refactoring Actions:
1. Analyze code structure and identify specific improvements:
   - Extract long methods into smaller, focused functions
   - Rename unclear variables/functions for better clarity
   - Eliminate code duplication via helper functions
   - Simplify complex conditionals and logic
   - Improve error handling patterns
   - Add clarifying comments where logic is complex

2. Apply refactoring patterns:
   - Extract Method: Break down large functions
   - Rename: Improve variable/function names
   - Extract Variable: Name complex expressions
   - Consolidate Conditional: Simplify branching logic
   - Remove Dead Code: Clean up unused code

3. Preserve functionality:
   - Do NOT change public APIs or interfaces
   - Do NOT alter input/output behavior
   - Do NOT modify business logic outcomes
   - Only improve structure and readability

4. Follow conventions:
   - Match existing code style and patterns
   - Use consistent naming conventions
   - Maintain file organization structure

Deliverable:
- Refactored code with improved structure
- Summary of changes made and why
- List of specific improvements (e.g., 'Extracted calculateTotal function', 'Renamed x to userId')
- Confirmation that functionality is preserved")

Phase 5: Verification
Goal: Ensure refactoring didn't break functionality

Actions:
- Run tests if they exist to verify behavior unchanged
- Example: !{bash npm test 2>/dev/null || pytest 2>/dev/null || echo "No test runner detected"}
- Run type checking if applicable
- Example: !{bash npm run typecheck 2>/dev/null || mypy . 2>/dev/null || echo "No type checker detected"}
- Run linting to ensure code quality improved
- Example: !{bash npm run lint 2>/dev/null || eslint . 2>/dev/null || pylint . 2>/dev/null || echo "No linter detected"}
- Verify no syntax errors introduced

Phase 6: Summary
Goal: Report refactoring results

Actions:
- Summarize refactoring completed:
  - What code was refactored
  - Key improvements made (cleaner functions, better naming, reduced complexity)
  - Functionality preservation confirmed via tests
  - Code quality metrics improved
- Highlight any warnings or follow-up recommendations:
  - Areas that still need attention
  - Suggestions for additional refactoring
  - Test coverage gaps identified
- Provide next steps:
  - Review changes before committing
  - Consider adding tests if coverage is low
  - Document any new patterns introduced

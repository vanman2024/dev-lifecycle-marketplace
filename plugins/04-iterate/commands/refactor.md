---
allowed-tools: Task(*), Read(*), Bash(*)
description: Refactor code for better maintainability and structure
argument-hint: <file-or-directory>
---

**Arguments**: $ARGUMENTS

## Overview

Refactors code to improve maintainability, readability, and structure without changing functionality.

## Step 1: Validate Target

!{bash test -e "$ARGUMENTS" && echo "Target found: $ARGUMENTS" || echo "Target not found: $ARGUMENTS"}

## Step 2: Analyze Code

Load target files for analysis:

@$ARGUMENTS

## Step 3: Invoke Refactoring Agent

Task(
  description="Refactor code",
  subagent_type="code-refactorer",
  prompt="Refactor the code in $ARGUMENTS for better maintainability.

**Analysis Requirements:**
- Identify duplicate code patterns
- Find complex functions that need simplification
- Detect code smells
- Identify naming improvements
- Look for structural improvements

**Refactoring Tasks:**
- Extract repeated logic into shared utilities
- Simplify complex conditional logic
- Break down large functions into smaller ones
- Improve variable and function naming
- Reorganize code structure for clarity
- Add comments where logic is complex

**Constraints:**
- DO NOT change functionality or behavior
- Preserve all existing tests
- Maintain backward compatibility
- Focus on readability and maintainability

**Deliverables:**
- Refactored code with improvements
- Summary of changes made
- Explanation of refactoring patterns used
- Recommendations for testing"
)

## Step 4: Review Results

Display refactoring summary:
- Patterns identified and improved
- Code structure enhancements
- Next steps for validation

Recommendations:
- Run existing tests to ensure no behavior changes
- Review refactored code for clarity
- Update documentation if structure changed significantly

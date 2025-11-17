---
allowed-tools: Task, Read, Bash
description: Refactor code for better maintainability and structure
argument-hint: <file-or-directory>
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

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

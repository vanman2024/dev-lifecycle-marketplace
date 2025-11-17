---
allowed-tools: Task, Read, Bash
description: Adjust implementation based on feedback or requirements change
argument-hint: <target>
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

Refines and adjusts implementation based on feedback, changing requirements, or new insights.

## Step 1: Validate Target

!{bash test -e "$ARGUMENTS" && echo "Target found: $ARGUMENTS" || echo "Target not found: $ARGUMENTS"}

## Step 2: Load Current Implementation

@$ARGUMENTS

## Step 3: Invoke Adjustment Agent

Task(
  description="Adjust implementation",
  subagent_type="implementation-adjuster",
  prompt="Adjust the implementation in $ARGUMENTS based on requirements or feedback.

**Analysis:**
- Review current implementation
- Identify areas needing adjustment
- Understand changed requirements or feedback

**Adjustment Tasks:**
- Modify logic to meet new requirements
- Refine edge case handling
- Improve error handling
- Optimize performance if needed
- Update tests to match changes

**Deliverables:**
- Adjusted implementation
- Summary of changes made
- Updated tests if applicable
- Documentation updates if needed

Ensure changes are minimal and focused on the specific adjustments needed."
)

## Step 4: Review Results

Display adjustment summary and recommend next steps:
- Run tests to verify changes
- Update documentation if needed
- Create checkpoint with /04-iterate:mid

---
allowed-tools: Task, Read, Bash
description: Adjust implementation based on feedback or requirements change
argument-hint: <target>
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

---
allowed-tools: Task, Read, Bash
description: Enhance feature with improvements and optimizations
argument-hint: <feature-target>
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

Enhances existing features with improvements, optimizations, and additional functionality.

## Step 1: Validate Target

!{bash test -e "$ARGUMENTS" && echo "Target found: $ARGUMENTS" || echo "Target not found: $ARGUMENTS"}

## Step 2: Analyze Current Implementation

Load target for enhancement:

@$ARGUMENTS

## Step 3: Invoke Enhancement Agent

Task(
  description="Enhance feature",
  subagent_type="feature-enhancer",
  prompt="Enhance the feature in $ARGUMENTS with improvements and optimizations.

**Analysis:**
- Review current implementation and capabilities
- Identify enhancement opportunities
- Consider user experience improvements
- Look for performance optimizations
- Identify missing edge cases or features

**Enhancement Tasks:**
- Add missing functionality that improves usability
- Optimize performance bottlenecks
- Improve error handling and user feedback
- Add helpful logging or debugging features
- Enhance accessibility if applicable
- Improve configuration options
- Add useful defaults

**Quality Requirements:**
- Maintain backward compatibility where possible
- Add tests for new functionality
- Update documentation for enhancements
- Ensure enhancements align with feature purpose

**Deliverables:**
- Enhanced implementation
- Summary of improvements made
- New tests for added functionality
- Documentation updates
- Performance impact analysis if applicable"
)

## Step 4: Review Results

Display enhancement summary:
- Improvements implemented
- Performance impact
- New capabilities added

Next steps:
- Test enhanced functionality
- Update user documentation
- Consider additional enhancements if needed

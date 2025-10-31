---
allowed-tools: Task, Read, Bash
description: Enhance feature with improvements and optimizations
argument-hint: <feature-target>
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

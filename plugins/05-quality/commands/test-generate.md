---
allowed-tools: Task(*), Read(*), Bash(*), Glob(*)
description: Generate test scaffolds for project
argument-hint: <target-file>
---

**Arguments**: $ARGUMENTS

## Overview

Generates test scaffolds and boilerplate for the target file or directory.

## Step 1: Validate Target

!{bash test -e "$ARGUMENTS" && echo "Target found: $ARGUMENTS" || echo "Target not found: $ARGUMENTS"}

## Step 2: Detect Project Type

!{bash test -f package.json && echo "Node.js" || test -f requirements.txt && echo "Python" || test -f Cargo.toml && echo "Rust" || echo "Unknown"}

## Step 3: Create Test Directory Structure

!{bash if test -f package.json; then mkdir -p tests __tests__; elif test -f requirements.txt; then mkdir -p tests; elif test -f Cargo.toml; then mkdir -p tests; fi && echo "Test directories ready"}

## Step 4: Invoke Test Generator Agent

Task(
  description="Generate test scaffolds",
  subagent_type="test-generator",
  prompt="Generate comprehensive test scaffolds for $ARGUMENTS.

**Analysis:**
- Read the target file/directory
- Identify functions, classes, and methods to test
- Determine appropriate test patterns

**Test Generation:**
- Create test file structure
- Generate test cases for each function/method
- Include edge cases and error scenarios
- Add setup and teardown if needed

**Deliverables:**
- Test file(s) with scaffolded test cases
- Clear TODOs for implementation details
- Test coverage targeting critical paths"
)

## Step 5: Report Results

Display summary:
- Test files created
- Test cases scaffolded
- Next steps for implementation

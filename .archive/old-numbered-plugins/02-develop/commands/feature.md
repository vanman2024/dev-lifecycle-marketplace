---
allowed-tools: Task, Read, Write, Bash, Glob, Grep, AskUserQuestion
description: Add new feature from specification - reads specs or creates through conversation
argument-hint: [feature-name]
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

## Step 1: Detect Project State

Check if project is initialized:

!{bash test -f .claude/project.json && echo "✅ Project initialized" || echo "⚠️ No project.json - run /core:init first"}

## Step 2: Check for Specification

If feature name provided, look for spec:

!{bash if [ -n "$ARGUMENTS" ]; then find specs -name "*$ARGUMENTS*" -o -name "spec.md" 2>/dev/null | head -5 || echo "No spec found"; fi}

## Step 3: Load Project Context

Read project configuration to understand framework:

@.claude/project.json

## Step 4: Delegate to Feature Builder Agent

Task(
  description="Build feature from specification",
  subagent_type="feature-builder",
  prompt="Implement a new feature for this project.

**Feature Name**: $ARGUMENTS

**Instructions**:

1. **Detect Project Framework**:
   - Read .claude/project.json to understand the detected framework
   - Adapt code generation to the detected stack (React, Vue, Django, Go, etc.)
   - Use appropriate file structure and naming conventions

2. **Load Specification** (if exists):
   - Check specs/ directory for feature specification
   - If spec exists: Read requirements, acceptance criteria, technical approach
   - If no spec: Ask user for feature requirements through conversation

3. **Generate Code**:
   - Create frontend components (if applicable) for detected framework
   - Create backend APIs (if applicable) for detected stack
   - Add database migrations (if applicable)
   - Follow existing project patterns and conventions
   - Use proper imports and dependencies

4. **Add Tests**:
   - Generate tests using detected test framework (Jest, Pytest, Go test, etc.)
   - Include unit tests and integration tests
   - Follow existing test patterns

5. **Update Documentation**:
   - Add inline code comments
   - Update README if necessary
   - Document new API endpoints or components

**Project-Agnostic Design**:
- ❌ NEVER hardcode frameworks - DETECT from project.json
- ❌ NEVER assume project structure - ANALYZE existing patterns
- ✅ DO adapt to detected framework
- ✅ DO follow existing conventions
- ✅ DO work with ANY project type

**Deliverables**:
- Feature implementation with proper code structure
- Tests for the feature
- Documentation updates
- Summary of files created/modified
"
)

## Step 5: Review Results

Display implementation summary and next steps for testing and validation.

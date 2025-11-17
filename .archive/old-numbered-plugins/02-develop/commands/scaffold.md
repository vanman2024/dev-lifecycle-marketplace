---
allowed-tools: Task, Read, Write, Bash, Glob, Grep, SlashCommand, AskUserQuestion
description: Scaffold entire module with frontend, backend, and tests
argument-hint: <module-name>
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

## Step 2: Load Project Context

@.claude/project.json

## Step 3: Create Module Specification

Task(
  description="Create module spec",
  subagent_type="general-purpose",
  prompt="Create a specification for the module: $ARGUMENTS

Analyze the project structure and create a complete module specification including:
- Module purpose and features
- Frontend components needed
- Backend API endpoints needed
- Database models/schemas
- Testing requirements
- Integration points with existing code

Save the spec to specs/$ARGUMENTS/spec.md
"
)

## Step 4: Generate Frontend Components

SlashCommand: /develop:component $ARGUMENTS

Wait for component generation to complete.

## Step 5: Generate Backend APIs

SlashCommand: /develop:api $ARGUMENTS

Wait for API generation to complete.

## Step 6: Generate Tests

SlashCommand: /quality:test-generate $ARGUMENTS

Wait for test generation to complete.

## Step 7: Summary

Display scaffolding summary:
- Module specification created
- Frontend components generated
- Backend APIs created
- Tests scaffolded
- Files created and locations

Next steps:
- Review generated code
- Customize to requirements
- Run tests to verify
- Integrate with application

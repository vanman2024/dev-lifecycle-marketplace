---
allowed-tools: Task, Read, Bash
description: Layer tasks by complexity and assign to agents for parallel work
argument-hint: <spec-id>
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

Stratifies tasks from a spec by complexity and assigns them to appropriate agents for parallel execution. Creates layered-tasks.md and agent-specific task files.

## Step 1: Validate Spec ID

Check that spec directory exists:

!{bash test -d "specs/$ARGUMENTS" && echo "Spec found: $ARGUMENTS" || echo "Spec not found: $ARGUMENTS"}

## Step 2: Load Tasks

Read existing tasks from spec:

@specs/$ARGUMENTS/tasks.md

## Step 3: Invoke Task Layering Agent

Task(
  description="Layer tasks by complexity",
  subagent_type="task-layering",
  prompt="Stratify tasks from specs/$ARGUMENTS/tasks.md by complexity.

**Complexity Ratings:**
- **Trivial (0)**: Simple changes, < 5 minutes
- **Simple (1)**: Straightforward implementation, < 30 minutes
- **Moderate (2)**: Requires thought, < 2 hours
- **Complex (3)**: Architectural decisions, > 2 hours

**Agent Assignments:**
- **@claude**: Complex (3), security, architecture
- **@copilot**: Trivial (0), Simple (1)
- **@qwen**: Performance optimization
- **@gemini**: Documentation
- **@codex**: Testing, TDD

**Deliverables:**
Create specs/$ARGUMENTS/agent-tasks/layered-tasks.md with:
- All tasks stratified by complexity
- Dependencies identified
- Layer organization (foundation → parallel → integration)
- Agent assignments for each task

Also create agent-specific task files:
- specs/$ARGUMENTS/agent-tasks/claude-tasks.md
- specs/$ARGUMENTS/agent-tasks/copilot-tasks.md
- specs/$ARGUMENTS/agent-tasks/qwen-tasks.md
- specs/$ARGUMENTS/agent-tasks/gemini-tasks.md
- specs/$ARGUMENTS/agent-tasks/codex-tasks.md"
)

## Step 4: Report Results

Display summary:
- Tasks layered and stratified
- Agent-specific task files created
- Ready for parallel execution

Next steps:
- Review layered-tasks.md
- Distribute tasks to agents
- Begin parallel development

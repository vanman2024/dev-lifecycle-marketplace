---
allowed-tools: Task, Read, Bash, SlashCommand
description: Iteration workflow orchestrator - manages refinement and adjustment cycles
argument-hint: <workflow-type>
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

Orchestrates iteration workflows for refinement and adjustment during active development. Routes to appropriate granular commands based on workflow type.

## Step 1: Determine Workflow Type

Check what type of iteration workflow is requested:

!{bash echo "Workflow type: $ARGUMENTS"}

## Step 2: Route to Appropriate Command

Based on workflow type, invoke the appropriate command:

**Task Layering** (tasks):
SlashCommand: /04-iterate:tasks $ARGUMENTS

**Start Iteration** (start):
SlashCommand: /04-iterate:start $ARGUMENTS

**Mid-Iteration Checkpoint** (mid):
SlashCommand: /04-iterate:mid

**End Iteration** (end):
SlashCommand: /04-iterate:end

**Adjust Implementation** (adjust):
SlashCommand: /04-iterate:adjust $ARGUMENTS

**Sync Changes** (sync):
SlashCommand: /04-iterate:sync $ARGUMENTS

**Refactor Code** (refactor):
SlashCommand: /04-iterate:refactor $ARGUMENTS

**Enhance Feature** (enhance):
SlashCommand: /04-iterate:enhance $ARGUMENTS

## Step 3: Report Completion

Display summary of iteration workflow completed.

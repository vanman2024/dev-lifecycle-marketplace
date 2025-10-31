---
allowed-tools: Task, Read, Bash, SlashCommand
description: Iteration workflow orchestrator - manages refinement and adjustment cycles
argument-hint: <workflow-type>
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

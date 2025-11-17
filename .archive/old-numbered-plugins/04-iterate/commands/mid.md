---
allowed-tools: Bash, Read, Write
description: Create mid-iteration checkpoint and progress snapshot
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


## Overview

Creates a checkpoint during an active iteration to track progress and state.

## Step 1: Load Current Iteration

!{bash test -L .multiagent/iterations/current && readlink .multiagent/iterations/current || echo "No active iteration"}

## Step 2: Create Checkpoint

!{bash
ITERATION=$(readlink .multiagent/iterations/current 2>/dev/null)
if [ -n "$ITERATION" ]; then
  CHECKPOINT_ID=$(date +%s)
  mkdir -p .multiagent/iterations/$ITERATION/checkpoints/$CHECKPOINT_ID

  # Capture git status
  git status > .multiagent/iterations/$ITERATION/checkpoints/$CHECKPOINT_ID/git-status.txt

  # Capture git diff
  git diff > .multiagent/iterations/$ITERATION/checkpoints/$CHECKPOINT_ID/git-diff.txt

  # Update state
  echo "Checkpoint created: $CHECKPOINT_ID"
else
  echo "No active iteration found"
fi
}

## Step 3: Report Status

Display checkpoint summary:
- Checkpoint ID and timestamp
- Files changed since start
- Current progress status

Recommendations:
- Review changes so far
- Adjust approach if needed (/04-iterate:adjust)
- Continue implementation

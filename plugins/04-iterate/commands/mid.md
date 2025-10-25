---
allowed-tools: Bash(*), Read(*), Write(*)
description: Create mid-iteration checkpoint and progress snapshot
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

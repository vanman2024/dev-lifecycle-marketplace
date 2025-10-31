---
allowed-tools: Bash, Read, Write
description: End iteration cycle and consolidate results
---

## Overview

Completes an active iteration cycle and consolidates results.

## Step 1: Load Current Iteration

!{bash test -L .multiagent/iterations/current && readlink .multiagent/iterations/current || echo "No active iteration"}

## Step 2: Create Final Snapshot

!{bash
ITERATION=$(readlink .multiagent/iterations/current 2>/dev/null)
if [ -n "$ITERATION" ]; then
  # Final git status
  git status > .multiagent/iterations/$ITERATION/final-status.txt

  # Final git diff from start
  git diff origin/$(git rev-parse --abbrev-ref HEAD) > .multiagent/iterations/$ITERATION/final-diff.txt

  # Update state to completed
  jq '.status = "completed" | .completed_at = "'$(date -Iseconds)'"' \
    .multiagent/iterations/$ITERATION/state.json > \
    .multiagent/iterations/$ITERATION/state.json.tmp && \
    mv .multiagent/iterations/$ITERATION/state.json.tmp \
    .multiagent/iterations/$ITERATION/state.json

  echo "Iteration completed: $ITERATION"
else
  echo "No active iteration found"
fi
}

## Step 3: Remove Current Symlink

!{bash rm -f .multiagent/iterations/current}

## Step 4: Generate Summary Report

Display iteration summary:
- Total time elapsed
- Number of checkpoints created
- Files changed
- Commits made

Next steps:
- Review final changes
- Create pull request if ready
- Start new iteration if needed

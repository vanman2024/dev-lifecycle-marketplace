---
allowed-tools: Bash, Read, Write
description: Start iteration cycle and initialize tracking
argument-hint: <iteration-name>
---

**Arguments**: $ARGUMENTS

## Overview

Initializes a new iteration cycle with tracking and state management.

## Step 1: Validate Iteration Name

!{bash test -n "$ARGUMENTS" && echo "Starting iteration: $ARGUMENTS" || echo "No iteration name provided"}

## Step 2: Create Iteration Directory

!{bash mkdir -p .multiagent/iterations/$ARGUMENTS}

## Step 3: Initialize Tracking

!{bash cat > .multiagent/iterations/$ARGUMENTS/state.json << 'EOF'
{
  "name": "$ARGUMENTS",
  "status": "in_progress",
  "started_at": "$(date -Iseconds)",
  "checkpoints": []
}
EOF
}

## Step 4: Create Symlink to Current

!{bash ln -sf $ARGUMENTS .multiagent/iterations/current}

## Step 5: Report Status

Display:
- Iteration started: $ARGUMENTS
- State file created at .multiagent/iterations/$ARGUMENTS/state.json
- Tracking initialized

Next steps:
- Begin implementation work
- Use /04-iterate:mid for checkpoints
- Use /04-iterate:end to complete

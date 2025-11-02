---
allowed-tools: Bash, Read, Write, Grep, Glob
description: Initialize git worktrees for parallel agent execution based on layered tasks
argument-hint: <spec-name>
---

**Arguments**: $ARGUMENTS

## Goal

Create isolated git worktrees for each agent assigned in layered-tasks.md, enabling true parallel development without conflicts.

## Phase 1: Discovery

Actions:
- Parse spec name from arguments: $ARGUMENTS
- Verify spec directory exists: specs/$ARGUMENTS
- Check layered-tasks.md exists: specs/$ARGUMENTS/agent-tasks/layered-tasks.md
- Extract list of agents from layered-tasks (look for @agent patterns)
- Get current git branch and verify clean working directory

## Phase 2: Worktree Creation

Actions:
- Extract spec number from spec name (e.g., "004" from "004-testing-deployment")
- For each agent found in layered-tasks.md:
  - Create branch: agent-{agent-name}-{spec-number}
  - Create worktree: git worktree add ../{project}-{spec-number}-{agent-name} -b agent-{agent-name}-{spec-number}
  - Create symlink in worktree to main repo's layered-tasks.md for visibility
- Display created worktrees with git worktree list

## Phase 3: Verification

Actions:
- Verify all worktrees created successfully
- Check each worktree is on correct branch
- Ensure layered-tasks.md symlinks are valid
- Count total worktrees created

## Phase 4: Summary

Display:
- Spec name and number
- Number of worktrees created
- List of agent worktrees with paths
- Next steps: Run /supervisor:start to verify setup

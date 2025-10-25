---
name: Worktree Management
description: Git worktree helpers for parallel development. Use when working with git worktrees, managing parallel branches, or when user mentions worktrees, parallel development, or branch isolation.
allowed-tools: Read(*), Bash(git:*), Write(*)
---

# Worktree Management

This skill provides git worktree management helpers for parallel development and branch isolation.

## What This Skill Provides

### 1. Worktree Operations
- Create worktrees for feature branches
- List active worktrees
- Remove completed worktrees
- Sync worktrees with main branch

### 2. Parallel Development Support
- Isolate work on separate branches
- Switch between features easily
- Prevent branch conflicts

### 3. Worktree Scripts
- `create-worktree.sh` - Create new worktree for branch
- `list-worktrees.sh` - Show all active worktrees
- `sync-worktree.sh` - Sync worktree with main
- `cleanup-worktree.sh` - Remove completed worktrees

## Instructions

### Creating a Worktree

When user wants to work on a feature in parallel:

1. Create worktree for new feature:
   !{bash git worktree add ../project-feature-name -b feature-name}

2. User can now work in ../project-feature-name independently

3. Changes in main project don't affect the worktree

### Listing Worktrees

Show all active worktrees:

!{bash git worktree list}

### Syncing a Worktree

Sync worktree with latest main branch:

1. Navigate to worktree
2. Fetch latest changes
3. Rebase or merge as appropriate

### Removing a Worktree

When feature is complete:

!{bash git worktree remove ../project-feature-name}

## Worktree Workflow Example

**Scenario**: Working on two features simultaneously

1. Main project in `/project`
2. Feature A in `/project-feature-a` (worktree)
3. Feature B in `/project-feature-b` (worktree)

Each can be developed independently without conflicts.

## Best Practices

- Use worktrees for long-running features
- Keep worktrees in sibling directories
- Clean up completed worktrees regularly
- Sync worktrees before merging
- Use consistent naming conventions

## Success Criteria

- ✅ Worktrees are created correctly
- ✅ Parallel development is isolated
- ✅ Syncing keeps worktrees up to date
- ✅ Cleanup removes unused worktrees

---

**Plugin**: 04-iterate
**Skill Type**: Git Helpers + Scripts
**Auto-invocation**: Yes (via description matching)

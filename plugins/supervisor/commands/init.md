---
allowed-tools: Bash, Read, Write, Grep, Glob
description: Initialize git worktrees for parallel agent execution based on layered tasks
argument-hint: <spec-name> | --all | --bulk
---

**Arguments**: $ARGUMENTS

## Goal

Create isolated git worktrees for each agent assigned in layered-tasks.md, enabling true parallel development without conflicts.

**Modes**:
- `<spec-name>` - Single spec (e.g., `001-user-auth`)
- `--all` or `--bulk` - All specs at once (100+ specs supported)

## Phase 1: Discovery

Actions:
- Check if bulk mode requested (--all or --bulk in arguments)

### Single Spec Mode
- Parse spec name from arguments: $ARGUMENTS
- Verify spec directory exists: specs/$ARGUMENTS
- Check layered-tasks.md exists: specs/$ARGUMENTS/agent-tasks/layered-tasks.md
- Extract list of agents from layered-tasks (look for @agent patterns)
- Get current git branch and verify clean working directory

### Bulk Mode (--all or --bulk)
- Scan all specs: `specs/*/agent-tasks/layered-tasks.md`
- Extract agents from each spec
- Count total worktrees to create
- Show summary and confirm with user

## Phase 2: Worktree Creation & Mem0 Registration

### Single Spec Mode
Actions:
- Invoke worktree-coordinator agent to:
  - Create git worktrees for each agent
  - Register worktrees in Mem0 for global tracking
  - Register agent task assignments
  - Register inter-agent dependencies
- The agent handles:
  - Extract spec number from spec name (e.g., "004" from "004-testing-deployment")
  - For each agent found in layered-tasks.md:
    - Create branch: agent-{agent-name}-{spec-number}
    - Create worktree: git worktree add ../{project}-{spec-number}-{agent-name} -b agent-{agent-name}-{spec-number}
    - Register in Mem0: `register-worktree.py register --spec {spec} --agent {name} --path {path} --branch {branch}`
    - Register tasks: `register-worktree.py assign --spec {spec} --agent {name} --tasks ...`
  - Display created worktrees with git worktree list

### Bulk Mode
Actions:
- Run bulk creation script:
  ```bash
  python plugins/planning/skills/doc-sync/scripts/bulk-register-worktrees.py
  ```
- Creates worktrees in **parallel** for all specs (10 concurrent)
- Registers all worktrees in Mem0 automatically
- Shows progress for each spec/agent combination
- Displays summary at end

## Phase 3: Verification

Actions:
- Verify all worktrees created successfully
- Check each worktree is on correct branch
- Ensure layered-tasks.md symlinks are valid
- Count total worktrees created

## Phase 4: Mem0 Verification

Actions:
- Query Mem0 to verify all registrations successful
- Run: `register-worktree.py list` to show active worktrees
- Confirm agents can query their assignments

## Phase 5: Summary

Display:
- Spec name and number
- Number of worktrees created
- List of agent worktrees with paths
- Registered in Mem0: worktrees, assignments, dependencies
- How agents query: `register-worktree.py query --query "where does {agent} work"`
- Next steps: Run /supervisor:start to verify setup

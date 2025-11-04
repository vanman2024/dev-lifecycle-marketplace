# Git Worktree System for Parallel Agent Development

## Overview

The dev-lifecycle-marketplace uses **Git worktrees** to enable **multiple AI agents** to work on the same codebase **simultaneously without conflicts**.

## What Are Worktrees?

Git worktrees allow you to have **multiple working directories** from the same repository, each on a different branch.

```bash
# Instead of this (serial development):
main/           # Only one working directory
├── src/
└── tests/

# You get this (parallel development):
project/             # Main worktree (main branch)
project-claude/      # Claude's worktree (agent-claude-001 branch)
project-copilot/     # Copilot's worktree (agent-copilot-001 branch)
project-qwen/        # Qwen's worktree (agent-qwen-001 branch)
project-gemini/      # Gemini's worktree (agent-gemini-001 branch)
```

## Why Use Worktrees?

### Problem: Multi-Agent Conflicts
When 4+ agents work on the same codebase:
- ❌ Constant merge conflicts
- ❌ Agents overwriting each other's work
- ❌ Difficult to track who did what
- ❌ Serial development (slow)

### Solution: Worktree Isolation
Each agent gets their own isolated workspace:
- ✅ **No conflicts** - Each agent on separate branch
- ✅ **Parallel work** - All agents work simultaneously
- ✅ **Clear ownership** - Branch per agent
- ✅ **Fast development** - 4x faster (4 agents in parallel)

## System Components

### 1. Supervisor Plugin (`plugins/supervisor/`)

**Purpose**: Manages worktree lifecycle and agent compliance

**Commands**:
- `/supervisor:init <spec>` - Creates worktrees for all agents
- `/supervisor:start <spec>` - Verifies setup before work begins
- `/supervisor:mid <spec>` - Monitors progress during development
- `/supervisor:end <spec>` - Validates completion before PRs

**Scripts** (`skills/worktree-orchestration/scripts/`):
- `start-verification.sh` - Pre-work setup validation
- `mid-monitoring.sh` - Progress tracking
- `end-verification.sh` - Completion validation
- `setup-worktree-symlinks.sh` - Links shared files

### 2. Iterate Plugin (`plugins/iterate/`)

**Purpose**: Task layering and parallel assignment

**Skill**: `worktree-orchestration/` (restored from archive)

**Scripts** (same as supervisor):
- Worktree management utilities
- Task coordination scripts

### 3. GitHub Copilot Instructions

**Location**: `.github/copilot-instructions.md`

**Purpose**: Instructions for @copilot agent on how to:
- Find their assigned worktree
- Work within branch isolation
- Follow worktree protocols

## How It Works

### Complete Workflow

```bash
# Step 1: Layer tasks for parallel work
/planning:spec "user authentication"
/iterate:tasks 001-user-auth

# Step 2: Initialize worktrees for each agent
/supervisor:init 001-user-auth
# Creates:
# - ../project-001-claude (agent-claude-001 branch)
# - ../project-001-copilot (agent-copilot-001 branch)
# - ../project-001-qwen (agent-qwen-001 branch)
# - ../project-001-gemini (agent-gemini-001 branch)

# Step 3: Verify setup
/supervisor:start 001-user-auth
# Checks: Worktrees created, branches correct, tasks assigned

# Step 4: Agents work in parallel
# @claude    works in ../project-001-claude/
# @copilot   works in ../project-001-copilot/
# @qwen      works in ../project-001-qwen/
# @gemini    works in ../project-001-gemini/

# Step 5: Monitor progress
/supervisor:mid 001-user-auth
# Shows: Task completion %, agent status, blockers

# Step 6: Validate completion
/supervisor:end 001-user-auth
# Verifies: All tasks complete, tests pass, ready for PR

# Step 7: Create PRs (one per agent)
cd ../project-001-claude && git push && gh pr create
cd ../project-001-copilot && git push && gh pr create
# etc...

# Step 8: After merge, cleanup worktrees
git worktree remove ../project-001-claude
git worktree remove ../project-001-copilot
# etc...
```

### Agent Assignments

Based on `specs/001-*/agent-tasks/layered-tasks.md`:

| Agent | Specialization | Worktree | Branch |
|-------|----------------|----------|--------|
| @claude | Architecture, security, integration | `../project-001-claude/` | `agent-claude-001` |
| @copilot | Implementation (simple tasks) | `../project-001-copilot/` | `agent-copilot-001` |
| @qwen | Optimization, performance | `../project-001-qwen/` | `agent-qwen-001` |
| @gemini | Documentation, research | `../project-001-gemini/` | `agent-gemini-001` |

## Worktree Naming Convention

```
Pattern: ../project-<spec#>-<agent-name>/
Branch:  agent-<agent-name>-<spec#>

Examples:
../dev-lifecycle-001-claude/     → agent-claude-001
../my-app-042-copilot/           → agent-copilot-042
../api-server-003-qwen/          → agent-qwen-003
```

## Commands Reference

### Initialize Worktrees
```bash
/supervisor:init <spec-name>
# Example: /supervisor:init 001-user-auth
```

Creates worktrees for all agents assigned in `layered-tasks.md`.

### Verify Setup
```bash
/supervisor:start <spec-name>
# Example: /supervisor:start 001-user-auth
```

**Checks**:
- ✅ Worktrees created
- ✅ Correct branches
- ✅ Tasks assigned
- ✅ Dependencies clear

### Monitor Progress
```bash
/supervisor:mid <spec-name>
# Example: /supervisor:mid 001-user-auth

# With tests:
/supervisor:mid <spec-name> --test
```

**Monitors**:
- Task completion percentage
- Agent status (active/stale/blocked)
- Test results (with --test flag)

### Validate Completion
```bash
/supervisor:end <spec-name>
# Example: /supervisor:end 001-user-auth
```

**Validates**:
- All tasks complete
- Tests passing
- Ready for PR
- Provides exact PR commands

## Scripts Reference

### Location
```
plugins/supervisor/skills/worktree-orchestration/scripts/
plugins/iterate/skills/worktree-orchestration/scripts/
```

### Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `start-verification.sh` | Pre-work setup validation | Called by `/supervisor:start` |
| `mid-monitoring.sh` | Progress tracking | Called by `/supervisor:mid` |
| `end-verification.sh` | Completion validation | Called by `/supervisor:end` |
| `setup-worktree-symlinks.sh` | Link shared files | Called during init |

### Manual Script Usage

```bash
# Verify setup
plugins/supervisor/skills/worktree-orchestration/scripts/start-verification.sh 001-user-auth

# Monitor progress
plugins/supervisor/skills/worktree-orchestration/scripts/mid-monitoring.sh 001-user-auth

# Validate completion
plugins/supervisor/skills/worktree-orchestration/scripts/end-verification.sh 001-user-auth
```

## Agents Using Worktrees

### @claude (CTO-Level Architecture)
- **Worktree**: `../project-<spec>-claude/`
- **Branch**: `agent-claude-<spec>`
- **Handles**: Architecture, security, integration
- **Tasks**: Complexity 3-4

### @copilot (Implementation)
- **Worktree**: `../project-<spec>-copilot/`
- **Branch**: `agent-copilot-<spec>`
- **Handles**: CRUD, APIs, forms, validation
- **Tasks**: Complexity 1-2

### @qwen (Optimization)
- **Worktree**: `../project-<spec>-qwen/`
- **Branch**: `agent-qwen-<spec>`
- **Handles**: Performance, optimization
- **Tasks**: Complexity 2-3

### @gemini (Documentation)
- **Worktree**: `../project-<spec>-gemini/`
- **Branch**: `agent-gemini-<spec>`
- **Handles**: Docs, research, analysis
- **Tasks**: Complexity 1-2

## Troubleshooting

### Worktree Not Created

```bash
# List existing worktrees
git worktree list

# If missing, run init again
/supervisor:init <spec-name>

# Or create manually
git worktree add ../project-<spec>-<agent> -b agent-<agent>-<spec>
```

### Agent in Wrong Worktree

```bash
# Check current location
pwd
git branch --show-current

# Should be: ../project-<spec>-<your-agent>/
# Should show: agent-<your-agent>-<spec>

# Fix: Navigate to correct worktree
cd ../project-<spec>-<correct-agent>/
```

### Worktree Cleanup After Merge

```bash
# List worktrees
git worktree list

# Remove worktree
git worktree remove ../project-<spec>-<agent>

# If worktree locked or has uncommitted changes
git worktree remove --force ../project-<spec>-<agent>

# Delete branch (after PR merged)
git branch -d agent-<agent>-<spec>
```

## Best Practices

### ✅ DO THIS

- **Use supervisor commands** - `/supervisor:init`, `/supervisor:start`, etc.
- **Work in assigned worktree** - Stay in your branch
- **Track progress** - Use `/supervisor:mid` regularly
- **Validate before PR** - Run `/supervisor:end`
- **Clean up after merge** - Remove worktrees promptly

### ❌ DON'T DO THIS

- **Don't switch branches** in worktree - Each worktree = one branch
- **Don't work in main** worktree - Use your agent worktree
- **Don't skip validation** - Always run `/supervisor:end` before PR
- **Don't leave worktrees** - Clean up after merge

## Related Documentation

- **Supervisor Plugin**: `plugins/supervisor/README.md`
- **Iterate Plugin**: `plugins/iterate/README.md`
- **Copilot Instructions**: `.github/copilot-instructions.md`
- **Git Worktrees**: https://git-scm.com/docs/git-worktree

## Summary

**Worktrees enable**:
- ✅ 4+ agents working simultaneously
- ✅ Zero merge conflicts during development
- ✅ Clear task ownership per agent
- ✅ 4x faster development (parallel execution)

**Key components**:
- 🎛️ Supervisor plugin (lifecycle management)
- 📋 Iterate plugin (task coordination)
- 🤖 GitHub Copilot instructions (agent guidance)
- 🛠️ Worktree orchestration scripts (automation)

---

**Last Updated**: November 3, 2025
**Status**: Active (restored from archive)

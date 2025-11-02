# Worktree Orchestration Skill

## Purpose

Provides scripts, templates, and documentation for managing git worktrees in multi-agent parallel development workflows.

## What It Provides

### Scripts (`scripts/`)

- **start-verification.sh** - Verifies worktree setup before agents begin work
- **mid-monitoring.sh** - Monitors agent progress and task completion
- **end-verification.sh** - Validates PR readiness and generates push commands
- **setup-worktree-symlinks.sh** - Creates symlinks for task visibility across worktrees

### Templates (`templates/`)

- **start-report.template.md** - Pre-work verification report format
- **mid-report.template.md** - Progress monitoring report format
- **end-report.template.md** - PR readiness report format
- **supervisor-report.template.md** - General supervisor report format

### Documentation (`docs/`)

- Worktree management patterns
- Agent coordination protocols
- Compliance rules per agent type

### Memory (`memory/`)

- Agent expectations and responsibilities
- Worktree usage rules
- Coordination protocols

## When to Use

Use this skill when:
- Setting up parallel agent development environments
- Monitoring multi-agent progress
- Validating work before PR creation
- Managing git worktree lifecycle

## Integration

Commands that use this skill:
- `/supervisor:init` - Uses worktree creation patterns
- `/supervisor:start` - Uses start-verification.sh
- `/supervisor:mid` - Uses mid-monitoring.sh
- `/supervisor:end` - Uses end-verification.sh

## Key Concepts

### Worktree Isolation

Each agent gets:
- Dedicated branch: `agent-{name}-{spec-number}`
- Isolated worktree: `../{project}-{spec-number}-{agent-name}`
- Symlinked task visibility to main repo

### Progress Tracking

Monitor via:
- Task completion in layered-tasks.md
- Git commit history per worktree
- Test results (optional with --test flag)

### PR Coordination

Generate:
- Push commands per agent branch
- PR creation commands with proper metadata
- Cleanup commands for post-merge worktree removal

# Supervisor Plugin

**Version:** 1.0.0
**Marketplace:** dev-lifecycle-marketplace

## Overview

The supervisor plugin orchestrates multi-agent parallel development with git worktree isolation. It enables 90+ agents to work simultaneously on different features without conflicts by giving each agent its own isolated branch and worktree.

## Core Features

### 🌳 Worktree Management
- Automatic worktree creation for each agent
- Branch isolation: `agent-{name}-{spec-number}`
- Symlinked task visibility across worktrees

### 📊 Progress Monitoring
- Real-time task completion tracking
- Agent status dashboard
- Stale agent detection
- Optional test execution per worktree

### ✅ PR Validation
- Pre-PR completeness checks
- Main branch protection verification
- Automated PR command generation
- Post-merge cleanup automation

### 🔄 GitHub Coordination
- Generate push commands per agent
- Create PR commands with metadata
- Worktree cleanup after merge

## Commands

### `/supervisor:init <spec-name>`

Initialize git worktrees for parallel agent execution.

**What it does:**
- Reads `specs/{spec}/agent-tasks/layered-tasks.md`
- Extracts agent assignments
- Creates isolated worktree per agent
- Sets up symlinks for task visibility

**Example:**
```bash
/supervisor:init 004-testing-deployment
```

**Output:**
- Created worktrees: `../{project}-004-claude/`, `../{project}-004-copilot/`, etc.
- Branches: `agent-claude-004`, `agent-copilot-004`, etc.

### `/supervisor:start <spec-name>`

Verify agent setup before work begins.

**What it does:**
- Checks worktrees exist and are properly configured
- Verifies task assignments
- Validates git state is clean
- Reports readiness status

**Example:**
```bash
/supervisor:start 004-testing-deployment
```

**Output:**
- Status: READY or BLOCKED
- Active worktrees count
- Task assignments per agent
- Fix commands if blocked

### `/supervisor:mid <spec-name> [--test]`

Monitor agent progress during development.

**What it does:**
- Tracks task completion percentages
- Identifies stale/stuck agents
- Shows agent status dashboard
- Optionally runs tests in each worktree

**Example:**
```bash
/supervisor:mid 004-testing-deployment
/supervisor:mid 004-testing-deployment --test
```

**Output:**
- Progress: X/Y tasks (Z% complete)
- Agent status table
- Test results (if --test flag)
- Recommendations for interventions

### `/supervisor:end <spec-name>`

Validate completion and generate PR commands.

**What it does:**
- Verifies all tasks complete
- Checks for uncommitted work
- Validates main branch protection
- Generates push and PR creation commands

**Example:**
```bash
/supervisor:end 004-testing-deployment
```

**Output:**
- Status: READY or BLOCKED
- PR readiness per agent
- Generated push/PR commands
- Cleanup commands for after merge

## Typical Workflow

```bash
# 1. Layer tasks (creates layered-tasks.md with agent assignments)
/iterate:tasks 004-testing-deployment

# 2. Initialize worktrees for parallel work
/supervisor:init 004-testing-deployment

# 3. Verify setup before agents start
/supervisor:start 004-testing-deployment

# 4. Agents work in parallel in their worktrees...

# 5. Monitor progress (run every 1-2 hours)
/supervisor:mid 004-testing-deployment

# 6. Validate completion and get PR commands
/supervisor:end 004-testing-deployment

# 7. Execute generated PR commands
cd ../project-004-agent1/
git push origin agent-agent1-004
gh pr create --title "..." --body "..."

# 8. After PR merge, clean up worktrees
git worktree remove ../project-004-agent1
git branch -d agent-agent1-004
```

## Architecture

### Directory Structure

```
plugins/supervisor/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── commands/
│   ├── init.md                  # Worktree initialization
│   ├── start.md                 # Pre-work verification
│   ├── mid.md                   # Progress monitoring
│   └── end.md                   # PR readiness validation
├── skills/
│   └── worktree-orchestration/
│       ├── SKILL.md             # Skill documentation
│       ├── scripts/
│       │   ├── start-verification.sh
│       │   ├── mid-monitoring.sh
│       │   ├── end-verification.sh
│       │   └── setup-worktree-symlinks.sh
│       ├── templates/
│       │   ├── start-report.template.md
│       │   ├── mid-report.template.md
│       │   └── end-report.template.md
│       ├── memory/
│       │   ├── agent-expectations.md
│       │   ├── worktree-rules.md
│       │   └── coordination-protocols.md
│       └── docs/
│           └── OVERVIEW.md
└── README.md                    # This file
```

### Worktree Naming Convention

- **Branch**: `agent-{agent-name}-{spec-number}`
- **Worktree Path**: `../{project}-{spec-number}-{agent-name}/`
- **Example**: Branch `agent-claude-004`, worktree `../myproject-004-claude/`

### Integration Points

- **Iterate Plugin**: Uses layered-tasks.md from `/iterate:tasks`
- **Planning Plugin**: Specs directory structure from `/planning:spec`
- **GitHub CLI**: Uses `gh` for PR creation
- **Git Worktrees**: Native git worktree commands

## Benefits

✅ **True Parallelism** - 90+ agents work simultaneously without conflicts
✅ **Branch Isolation** - Each agent on dedicated branch
✅ **Progress Visibility** - Real-time monitoring across all agents
✅ **Automated Coordination** - PR commands generated automatically
✅ **Clean Workflows** - Proper setup/monitor/validate/cleanup lifecycle

## Requirements

- Git 2.5+ (for worktree support)
- GitHub CLI (`gh`) for PR creation
- Bash for script execution
- Layered tasks from `/iterate:tasks`

## Future Enhancements

See `FUTURE_ENHANCEMENTS.md` for planned features:
- Real-time code quality monitoring
- Smart conflict detection
- Agent performance analytics
- CI/CD integration
- AI-powered task suggestions

## License

MIT License - See LICENSE file for details

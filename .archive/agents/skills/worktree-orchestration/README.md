# Supervisor System - Agent Compliance & Verification

## Purpose

Monitors agent compliance and progress throughout development. Ensures worktrees are set up correctly, tasks are being completed, and PRs are ready for submission.

## What It Does

1. **Pre-work verification** - Checks worktree setup, task assignments, branch isolation
2. **Progress monitoring** - Tracks task completion, identifies stuck agents
3. **Pre-PR validation** - Ensures all tasks complete, code quality met, tests passing
4. **Compliance reporting** - Generates status reports for each verification phase

## Agents Used

- **@claude/supervisor-start** - Verifies agent setup before work begins
- **@claude/supervisor-mid** - Monitors agent progress during development
- **@claude/supervisor-end** - Validates completion before PR creation

## Commands

### Primary Commands
- `/supervisor:start [spec-dir]` - Pre-work readiness verification
- `/supervisor:mid [spec-dir]` - Mid-work progress monitoring
- `/supervisor:end [spec-dir]` - Pre-PR completion verification

### Integration Points
- Called before agents start work
- Monitors during implementation
- Validates before PR creation

## Complete Workflow

### First-Time Setup (Before Agent Work Begins)
```bash
# Step 1: Verify tasks are layered
# Prerequisite: /iterate:tasks {spec} must be run first
cat specs/{spec}/agent-tasks/layered-tasks.md
# Verify: Tasks organized, agents assigned

# Step 2: Run supervisor start verification
/supervisor:start {spec}
# What this does: Creates worktrees, verifies setup, checks task assignments
# Expected output: READY status (or BLOCKED with fix commands)
# Time: 30-60 seconds

# Step 3: If BLOCKED, resolve issues
# Follow fix commands from supervisor:start output
# Common fixes:
git worktree add -b agent-{name}-{spec#} ../{project}-{spec#}-{name} main
# Then re-run: /supervisor:start {spec}
```

**Verification**: All agents show READY status, worktrees created

### During Development (Regular Progress Checks)
```bash
# Step 1: Monitor progress periodically (every 1-2 hours)
/supervisor:mid {spec}
# What this does: Checks task completion, identifies stuck agents, validates compliance
# Expected output: Progress percentages, agent statuses
# Time: 30-60 seconds

# Step 1a: Monitor progress WITH test validation (recommended)
/supervisor:mid {spec} --test
# What this does: Same as above PLUS runs /testing:test --quick in each worktree
# Expected output: Progress percentages, agent statuses, test results per worktree
# Time: 2-5 minutes (depending on test suite size)
# Output: Test reports in specs/{spec}/testing/{agent}-test-results.txt

# Step 2: If agents stale or off-track, investigate
cd ../{project}-{spec#}-{agent-name}/
git log -5
git status
# Review recent commits and current state

# Step 3: Re-run mid check after interventions
/supervisor:mid {spec}
# Should show improved status
```

**Frequency**: Run every 1-2 hours during active development
**Recommendation**: Use `--test` flag before approving PRs to catch issues early

### Before Creating PRs (Completion Validation)
```bash
# Step 1: Validate all work complete
/supervisor:end {spec}
# What this does: Validates tasks complete, tests pass, code quality met
# Expected output: READY status per agent (or BLOCKED with issues)
# Time: 1-2 minutes

# Step 2: If READY, create PRs using provided commands
# supervisor:end output includes exact commands:
cd ../{project}-{spec#}-{agent-name}/
git push origin agent-{name}-{spec#}
gh pr create --title "..." --body "..."

# Step 3: If BLOCKED, fix issues
# Common issues:
npm test           # Fix failing tests
npm run lint --fix # Fix lint errors
# Complete remaining tasks from layered-tasks.md

# Step 4: Re-validate after fixes
/supervisor:end {spec}
# Should show READY status
```

**Validation**: All agents READY, PRs created successfully

### Multi-Spec Workflows
```bash
# Setup multiple specs at once
/supervisor:start --all
# Or specific specs: /supervisor:start 001,002,003

# Monitor all specs
/supervisor:mid --all

# Validate all specs
/supervisor:end --all
```

### Typical Session Timeline
```
Hour 0: /supervisor:start {spec}     → Setup complete (5 min)
Hour 1: Agents begin work
Hour 2: /supervisor:mid {spec}       → Check progress (30 sec)
Hour 4: /supervisor:mid {spec}       → Check progress (30 sec)
Hour 6: /supervisor:mid {spec}       → Check progress (30 sec)
Hour 8: /supervisor:end {spec}       → Validate complete (2 min)
Hour 8: Create PRs, merge to main
```

### Integration with Other Commands
```bash
# Complete feature development workflow:
/iterate:tasks 001        # Layer tasks for parallel work
/supervisor:start 001     # Setup worktrees, verify readiness
# Agents work in parallel...
/supervisor:mid 001       # Monitor progress
/supervisor:end 001       # Validate completion
# Create PRs from supervisor:end output
```

## Directory Structure

```
.multiagent/supervisor/
├── scripts/
│   ├── agent-compliance.sh      # Check agents follow templates
│   ├── worktree-verification.sh # Verify proper worktree usage
│   ├── progress-monitoring.sh   # Track agent task progress
│   ├── handoff-validation.sh    # Validate agent coordination
│   └── supervision-report.sh    # Generate oversight reports
├── templates/
│   ├── compliance-report.md     # Agent compliance summary
│   ├── progress-dashboard.md    # Agent progress overview
│   └── handoff-checklist.md     # Coordination validation
├── memory/
│   ├── agent-expectations.md    # What each agent should do
│   ├── worktree-rules.md        # Proper worktree usage
│   └── coordination-protocols.md # How agents should handoff
└── logs/
    └── [session-id]/            # Supervision session records
```

## Outputs

### 1. Compliance Reports (`logs/`)

Generated for each supervision check:

```
logs/session-20250929-100000/
├── start-verification.md        # Pre-work readiness
├── progress-check.md            # Mid-work status
├── completion-validation.md    # Pre-PR verification
└── compliance-summary.md       # Overall compliance
```

### 2. Agent Status Dashboard

| Agent | Worktree | Tasks Assigned | Tasks Complete | Compliance |
|-------|----------|----------------|----------------|------------|
| @claude | agent-claude-architecture | 5 | 3 | ✅ |
| @copilot | agent-copilot-impl | 10 | 8 | ✅ |
| @qwen | agent-qwen-optimize | 3 | 3 | ✅ |
| @gemini | agent-gemini-docs | 4 | 2 | ⚠️ |

### 3. Verification Checks

| Check Type | What's Verified | When Run |
|------------|----------------|----------|
| Worktree | Agent in correct branch | Start, Mid, End |
| Task Adherence | Working on assigned tasks | Mid, End |
| Tool Usage | Using approved tools only | Mid |
| Commit Format | Following commit standards | End |
| PR Readiness | All tasks complete | End |

## How It Works

### Phase 1: Start Verification
```bash
/supervisor:start specs/001-*
```
Checks:
- Agent has read their template (CLAUDE.md, etc.)
- Worktree is set up correctly
- Tasks are properly assigned
- Dependencies are clear

### Phase 2: Mid-Work Monitoring
```bash
/supervisor:mid specs/001-*
```
Monitors:
- Agent staying in assigned worktree
- Progress on assigned tasks
- No scope creep beyond specialization
- Proper use of TodoWrite tool

### Phase 3: End Verification
```bash
/supervisor:end specs/001-*
```
Validates:
- All assigned tasks complete
- Commits follow standards
- Tests passing
- Ready for PR creation

## Agent Compliance Rules

### @claude (CTO-Level)
- **Must work in**: `agent-claude-architecture` worktree
- **Can do**: Architecture, security, integration
- **Cannot do**: Simple implementation tasks
- **Commit format**: Include architectural decisions

### @copilot (Implementation)
- **Must work in**: `agent-copilot-impl` worktree
- **Can do**: Simple tasks (Complexity ≤2)
- **Cannot do**: Architecture changes
- **Commit format**: Reference task numbers

### @qwen (Optimization)
- **Must work in**: `agent-qwen-optimize` worktree
- **Can do**: Performance improvements
- **Cannot do**: Feature additions
- **Commit format**: Include performance metrics

### @gemini (Research)
- **Must work in**: `agent-gemini-docs` worktree
- **Can do**: Documentation, analysis
- **Cannot do**: Code implementation
- **Commit format**: Reference research sources

## Worktree Verification

Ensures agents maintain isolation:
```bash
# Correct setup
git worktree list
/home/user/project              main
/home/user/project-claude       agent-claude-architecture
/home/user/project-copilot      agent-copilot-impl
/home/user/project-qwen         agent-qwen-optimize
```

## Progress Tracking

Monitors task completion:
```markdown
# Tasks for @claude
- [x] T010 Design database schema ✅
- [x] T025 Security review ✅
- [ ] T055 API architecture (in progress)
- [ ] T070 Integration planning
```

## Coordination Protocols

### Handoff Rules
1. Complete task must be marked `[x]`
2. Commit all changes before handoff
3. Document any blockers
4. Update shared context if needed

### Dependency Management
- Layer 1 tasks: No dependencies
- Layer 2 tasks: Wait for Layer 1
- Layer 3 tasks: Integration only

## Integration with Other Systems

### With Iterate System
- Supervisor validates during iterations
- Ensures agents follow updated specs
- Monitors ecosystem coherence

### With PR Review System
- Validates before PR creation
- Ensures all feedback addressed
- Checks merge readiness

## Troubleshooting

### Agent Not in Worktree
```bash
# Fix: Move agent to correct worktree
cd ../project-[agent]
git checkout agent-[name]-[purpose]
```

### Tasks Not Being Tracked
```bash
# Fix: Use TodoWrite tool
# Agent should track all tasks internally
```

### Commits Not Following Format
```bash
# Fix: Use proper format
git commit -m "[WORKING] feat: Description

@agent completing assigned task"
```

## Key Points

- **Supervisor monitors, doesn't implement**
- **Validates agent compliance throughout**
- **Ensures worktree isolation**
- **Tracks progress and handoffs**
- **Gates PR creation on compliance**
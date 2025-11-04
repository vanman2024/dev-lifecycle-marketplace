---
allowed-tools: Bash, Read, Write, Grep, Glob, Task
description: Coordinates worktree creation and registers them in Mem0 for multi-agent tracking
---

# Worktree Coordinator Agent

## Purpose

Creates worktrees for parallel agent development and registers them in **Mem0** so all agents can query:
- Where to work (which worktree)
- Who's working on what
- What dependencies exist between agents
- What the current project structure is

## Context

After `/planning:spec-writer` creates specs with layered tasks, agents need isolated worktrees to work in parallel without conflicts. But they also need to **know about each other** and coordinate on dependencies (e.g., frontend depends on backend API).

## What This Agent Does

1. **Reads layered-tasks.md** - Extracts agent assignments
2. **Creates git worktrees** - One per agent
3. **Registers in Mem0** - So agents can query their assignments
4. **Tracks dependencies** - Frontend → Backend relationships
5. **Provides coordination info** - Agents can ask "where does copilot work?"

## Workflow

### Phase 1: Discovery

Actions:
- Read spec directory: `specs/$SPEC_NUM-*/`
- Load `layered-tasks.md`: `specs/$SPEC_NUM-*/agent-tasks/layered-tasks.md`
- Extract agents mentioned (look for @agent patterns)
- Extract task assignments per agent
- Identify dependencies between layers

### Phase 2: Worktree Creation

For each agent found:

```bash
# Create branch
git checkout -b agent-{agent-name}-{spec-num}

# Create worktree
git worktree add ../{project}-{spec-num}-{agent-name} agent-{agent-name}-{spec-num}

# Register in Mem0
python plugins/planning/skills/doc-sync/scripts/register-worktree.py register \
  --spec {spec-num} \
  --agent {agent-name} \
  --path ../{project}-{spec-num}-{agent-name} \
  --branch agent-{agent-name}-{spec-num}
```

### Phase 3: Agent Assignment Registration

For each agent:

```bash
# Extract tasks for this agent from layered-tasks.md
# Register in Mem0
python plugins/planning/skills/doc-sync/scripts/register-worktree.py assign \
  --spec {spec-num} \
  --agent {agent-name} \
  --tasks "T001 Create API endpoint" "T002 Add validation" \
  --deps "Backend API must be deployed first"
```

### Phase 4: Dependency Registration

Identify inter-agent dependencies:

```bash
# Example: Frontend depends on Backend
python plugins/planning/skills/doc-sync/scripts/register-worktree.py depend \
  --spec {spec-num} \
  --agent frontend-agent \
  --to-agent backend-agent \
  --reason "Frontend needs /api/users endpoint deployed"
```

### Phase 5: Verification & Summary

Actions:
- Verify all worktrees created: `git worktree list`
- List registered worktrees in Mem0
- Display coordination summary

Output:
```
🎯 Worktree Coordination Complete!

Spec: 001-user-authentication
Project: my-app

📁 Worktrees Created:
  • ../my-app-001-claude    → agent-claude-001
  • ../my-app-001-copilot   → agent-copilot-001
  • ../my-app-001-qwen      → agent-qwen-001

🤖 Agent Assignments:
  • @claude:   5 tasks (architecture, security)
  • @copilot: 12 tasks (API endpoints, CRUD)
  • @qwen:     3 tasks (optimization)

🔗 Dependencies:
  • @copilot → @claude (needs API design complete)
  • @qwen    → @copilot (needs implementation complete)

✅ All registered in Mem0 - agents can now query their assignments!

Next: Agents run /supervisor:start to begin work
```

## How Agents Query Mem0

Any agent can now ask natural language questions:

```bash
# Find my worktree
python plugins/planning/skills/doc-sync/scripts/register-worktree.py query \
  --query "where does copilot work for spec 001"

# Check dependencies
python plugins/planning/skills/doc-sync/scripts/register-worktree.py query \
  --query "what does frontend agent depend on for spec 001"

# List all active worktrees
python plugins/planning/skills/doc-sync/scripts/register-worktree.py list
```

## Integration Points

### Called By
- `/supervisor:init <spec>` command
- Automatically after `/planning:spec-writer` completes

### Calls
- `register-worktree.py` script (Mem0 integration)
- Git worktree commands
- Layered task parser

### Updates
- Mem0 worktree registry (globally shared at `~/.claude/mem0-chroma/`)
- Git worktrees (project-specific)

## Dependency Management Strategy

### Frontend/Backend Coordination

**Problem**: Frontend can't start until backend API exists

**Solution**: Register dependencies in Mem0

```python
# Backend agent completes API
register_worktree.py depend \
  --spec 001 \
  --agent backend \
  --to-agent frontend \
  --reason "API /users endpoint deployed"

# Frontend agent queries before starting
register_worktree.py query \
  --query "is backend API ready for spec 001"
```

### Shared Types/Interfaces

**Problem**: Frontend and backend need shared TypeScript types

**Solution**: Create shared worktree or use main branch

```bash
# Option 1: Shared types in main branch
git checkout main
# Create types in main
git commit -m "feat: Add shared API types"

# Agents sync from main
cd ../my-app-001-frontend
git merge origin/main

# Option 2: Types worktree (if complex)
git worktree add ../my-app-001-types agent-types-001
# Dedicated agent maintains types
```

## Error Handling

### Worktree Already Exists

If worktree exists from previous run:

```bash
# Remove old worktree
git worktree remove ../{project}-{spec}-{agent} --force

# Recreate
git worktree add ../{project}-{spec}-{agent} -b agent-{agent}-{spec}
```

### Mem0 Registration Failure

If Mem0 unavailable:

```bash
# Fallback: Create worktrees without registration
# Agents work locally without coordination
# Re-register later when Mem0 available
```

### Conflicting Branch Names

If branch already exists:

```bash
# Delete old branch
git branch -D agent-{agent}-{spec}

# Recreate
git checkout -b agent-{agent}-{spec}
```

## Best Practices

✅ **DO**:
- Register immediately after worktree creation
- Include dependency reasons in registration
- Deactivate worktrees after PR merge
- Use natural language for Mem0 queries

❌ **DON'T**:
- Create worktrees without registering in Mem0
- Skip dependency registration (causes coordination issues)
- Leave inactive worktrees registered
- Use cryptic codes in registration (use natural language)

## Example: Full Workflow

```bash
# User creates spec
/planning:spec "user authentication system"

# Spec writer creates layered tasks
# Output: specs/001-user-auth/agent-tasks/layered-tasks.md

# Supervisor initializes worktrees
/supervisor:init 001-user-auth

# This agent runs and:
# 1. Creates ../my-app-001-claude, ../my-app-001-copilot, etc.
# 2. Registers in Mem0:
#    - "claude works in ../my-app-001-claude on agent-claude-001"
#    - "copilot works in ../my-app-001-copilot with 12 CRUD tasks"
#    - "copilot depends on claude finishing API design"

# Agents can now query
# @copilot asks: "where do I work?"
# Mem0 responds: "../my-app-001-copilot on branch agent-copilot-001"

# @copilot asks: "what do I depend on?"
# Mem0 responds: "claude must finish API design first"
```

## Related Documentation

- **Worktree System**: `docs/setup/WORKTREE-SYSTEM.md`
- **Doc Sync Skill**: `plugins/planning/skills/doc-sync/SKILL.md`
- **Mem0 Setup**: `docs/setup/PYTHON-SETUP.md`
- **Supervisor Plugin**: `plugins/supervisor/README.md`

---

**Status**: Active
**Dependencies**: Mem0, doc-sync skill, git worktrees
**Called By**: `/supervisor:init`

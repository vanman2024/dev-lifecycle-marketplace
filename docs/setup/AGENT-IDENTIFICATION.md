# Agent Identification System

## Overview

When working with **100+ specs**, agents need to quickly identify **which specs are assigned to them** and what work they need to do.

## Supported Agents

The system supports these agents:
- **@claude** - Architecture, security, integration (CTO-level)
- **@copilot** - Implementation, CRUD, APIs (GitHub Copilot)
- **@qwen** - Optimization, performance (Qwen)
- **@gemini** - Documentation, research (Google Gemini)
- **@codex** - Code generation, patterns (OpenAI Codex)
- **@gpt4** - Complex reasoning, design (GPT-4)
- **@sonnet** - Writing, documentation (Claude Sonnet)

Add more by using `@agent-name` in layered-tasks.md!

## How Agents Find Their Work

### Method 1: Query Mem0 (Recommended)

```bash
# Find all specs assigned to me
register-worktree.py query --query "what specs are assigned to copilot"

# Output:
# Copilot assigned to:
# - Spec 001 (user-auth): 12 tasks
# - Spec 005 (admin-panel): 8 tasks
# - Spec 042 (api-gateway): 15 tasks
```

### Method 2: Search Layered-Tasks Files

```bash
# Find all specs where I'm mentioned
grep -r "@copilot" specs/*/agent-tasks/layered-tasks.md

# Output:
# specs/001-user-auth/agent-tasks/layered-tasks.md:- [ ] T030 @copilot Create users API
# specs/005-admin-panel/agent-tasks/layered-tasks.md:- [ ] T012 @copilot Build dashboard
```

### Method 3: List Worktrees

```bash
# See all my active worktrees
register-worktree.py list | grep copilot

# Output:
# ../my-app-001-copilot (agent-copilot-001)
# ../my-app-005-copilot (agent-copilot-005)
# ../my-app-042-copilot (agent-copilot-042)
```

## Spec Structure with Agent Assignments

### Example: `specs/001-user-auth/agent-tasks/layered-tasks.md`

```markdown
# Layered Tasks: 001-user-auth

## Layer 1: Architecture & Design
**Agents**: @claude
**Dependencies**: None

- [ ] T010 @claude Design user authentication API
- [ ] T020 @claude Review security requirements
- [ ] T030 @claude Create database schema

## Layer 2: Backend Implementation
**Agents**: @copilot
**Dependencies**: Layer 1 complete

- [ ] T040 @copilot Create /auth/register endpoint
- [ ] T050 @copilot Create /auth/login endpoint
- [ ] T060 @copilot Add JWT token generation
- [ ] T070 @copilot Write API tests

## Layer 3: Frontend Implementation
**Agents**: @codex
**Dependencies**: Layer 2 deployed

- [ ] T080 @codex Build login form component
- [ ] T090 @codex Build registration form
- [ ] T100 @codex Add auth state management

## Layer 4: Optimization
**Agents**: @qwen
**Dependencies**: Layer 3 complete

- [ ] T110 @qwen Optimize database queries
- [ ] T120 @qwen Add caching layer
- [ ] T130 @qwen Performance testing

## Layer 5: Documentation
**Agents**: @gemini
**Dependencies**: All layers complete

- [ ] T140 @gemini Write API documentation
- [ ] T150 @gemini Create user guide
- [ ] T160 @gemini Update architecture docs
```

## Agent Name in Spec Directory (Optional)

For very agent-specific specs, you can name directories with agent names:

```
specs/
├── 001-user-auth/                  # Shared by multiple agents
├── 002-admin-dashboard-copilot/    # Primarily @copilot
├── 003-performance-audit-qwen/     # Primarily @qwen
├── 004-api-docs-gemini/            # Primarily @gemini
```

**When to use**:
- ✅ Spec is primarily one agent's responsibility
- ✅ Minimal dependencies on other agents
- ✅ Agent works independently

**When NOT to use**:
- ❌ Multiple agents collaborate
- ❌ Complex layer dependencies
- ❌ Shared architecture/implementation

## Bulk Worktree Creation

### For ALL Specs at Once

```bash
# Create worktrees for all 100+ specs
python plugins/planning/skills/doc-sync/scripts/bulk-register-worktrees.py

# Output:
# 🔍 Scanning for specs...
# ✅ Found 127 specs
#
# 📋 Specs to process:
#   • 001-user-auth: claude, copilot, qwen, gemini
#   • 002-admin-dashboard: copilot, codex
#   • 003-performance-audit: qwen
#   ...
#
# Create worktrees for 127 specs? (y/N): y
#
# 🚀 Bulk Worktree Creation
# 📊 Specs: 127
# 🤖 Total Worktrees: 384
# ⚙️  Mode: Parallel
#
# ✅ 001-user-auth/claude → ../my-app-001-claude
# ✅ 001-user-auth/copilot → ../my-app-001-copilot
# ...
#
# ✅ Created: 384
# ⏭️  Skipped: 0
# ❌ Failed: 0
```

### Dry Run (See What Would Be Created)

```bash
# Preview without creating
python plugins/planning/skills/doc-sync/scripts/bulk-register-worktrees.py --dry-run

# Shows all specs and agents without creating worktrees
```

### Sequential Mode (One at a Time)

```bash
# Create sequentially (slower but safer)
python plugins/planning/skills/doc-sync/scripts/bulk-register-worktrees.py --sequential
```

## Adding New Agents

### Step 1: Add Agent to Layered-Tasks

Just use `@agent-name` in any layered-tasks.md:

```markdown
## Layer X: Video Processing
**Agents**: @claude-opus
**Dependencies**: None

- [ ] T010 @claude-opus Design video pipeline
- [ ] T020 @claude-opus Optimize encoding
```

### Step 2: Run Bulk Create

```bash
# Automatically detects new agent
python plugins/planning/skills/doc-sync/scripts/bulk-register-worktrees.py

# Creates worktree: ../my-app-XXX-claude-opus
```

### Step 3: Agent Queries Mem0

```bash
register-worktree.py query --query "what specs are assigned to claude-opus"

# Output:
# claude-opus assigned to:
# - Spec 010 (video-processing): 2 tasks
```

## Agent Discovery

Agents can discover what specs they're assigned to:

```bash
# Method 1: Query Mem0 for assignments
register-worktree.py query --query "show me all copilot assignments"

# Method 2: Search code for @mentions
grep -r "@copilot" specs/*/agent-tasks/layered-tasks.md | cut -d: -f1 | sort -u

# Method 3: List active worktrees
git worktree list | grep copilot
```

## Example: Agent Workflow

### @copilot's Day

```bash
# 1. Find my work
register-worktree.py query --query "what specs are assigned to copilot"
# Output: 12 specs with 87 total tasks

# 2. Pick a spec to work on
cd ../my-app-001-copilot

# 3. Check my tasks
cat ../../dev-lifecycle-marketplace/specs/001-user-auth/agent-tasks/layered-tasks.md | grep "@copilot"
# Shows my 7 tasks for this spec

# 4. Check dependencies
register-worktree.py query --query "what does copilot depend on for spec 001"
# Output: claude must complete API design (T010, T020, T030)

# 5. Start work!
```

## Agent Task Summary

Each agent can generate their task summary:

```bash
# Get my complete task list across all specs
for spec in $(register-worktree.py query --query "copilot specs" | grep -o "[0-9]\{3\}"); do
  echo "=== Spec $spec ==="
  grep "@copilot" specs/${spec}-*/agent-tasks/layered-tasks.md
done
```

## Best Practices

### ✅ DO

- Use clear agent names: `@claude`, `@copilot`, `@qwen`
- Group related tasks for same agent in layers
- Document dependencies between agents
- Use Mem0 queries to find work
- Register all worktrees in bulk

### ❌ DON'T

- Use generic names: `@agent1`, `@dev`
- Mix multiple agents in single task
- Skip Mem0 registration
- Create worktrees manually without registration
- Forget to specify layer dependencies

## Summary

**100+ specs? No problem!**

1. **Spec writer creates specs** with `@agent` assignments
2. **Bulk create worktrees**: `bulk-register-worktrees.py`
3. **Agents query Mem0**: "what specs am I assigned to?"
4. **Agents work in isolation**: Each in their worktree
5. **Coordinate via Mem0**: Check dependencies, status

**Result**: Clear agent identification + parallel work at scale! 🚀

---

**Last Updated**: November 3, 2025
**Supported Agents**: claude, copilot, qwen, gemini, codex, gpt4, sonnet + any custom

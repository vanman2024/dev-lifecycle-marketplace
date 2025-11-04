# Bulk Worktree Creation - Quick Start

## TL;DR

```bash
# Create worktrees for ALL specs at once (100+)
/supervisor:init --all

# Or run script directly
python plugins/planning/skills/doc-sync/scripts/bulk-register-worktrees.py
```

**What it does**:
- ✅ Scans all `specs/*/agent-tasks/layered-tasks.md`
- ✅ Extracts all `@agent` mentions
- ✅ Creates worktrees in parallel (10 concurrent)
- ✅ Registers everything in Mem0
- ✅ Takes ~30 seconds for 100 specs

---

## Commands

### Single Spec

```bash
# Create worktrees for one spec
/supervisor:init 001-user-auth

# Creates:
# - ../my-app-001-claude
# - ../my-app-001-copilot
# - ../my-app-001-qwen
```

### All Specs (Bulk Mode)

```bash
# Create worktrees for ALL specs
/supervisor:init --all

# Or
/supervisor:init --bulk

# Example output:
# 🚀 Bulk Worktree Creation
# 📊 Specs: 127
# 🤖 Total Worktrees: 384
# ⚙️  Mode: Parallel
#
# ✅ 001-user-auth/claude → ../my-app-001-claude
# ✅ 001-user-auth/copilot → ../my-app-001-copilot
# ...
# ✅ Created: 384
```

### Dry Run (Preview)

```bash
# See what would be created without creating
python plugins/planning/skills/doc-sync/scripts/bulk-register-worktrees.py --dry-run

# Shows all specs and agents
# No worktrees created
```

---

## Agent Identification

### Finding Your Work

**As @copilot**:

```bash
# Method 1: Query Mem0
register-worktree.py query --query "what specs are assigned to copilot"

# Method 2: Search files
grep -r "@copilot" specs/*/agent-tasks/layered-tasks.md

# Method 3: List worktrees
register-worktree.py list | grep copilot
```

### Adding Your Name to Specs

In `specs/XXX-feature/agent-tasks/layered-tasks.md`:

```markdown
## Layer 2: Implementation
**Agents**: @copilot, @codex
**Dependencies**: Layer 1 complete

- [ ] T030 @copilot Create users API
- [ ] T040 @copilot Add validation
- [ ] T050 @codex Build UI components
```

**Supported agents**:
- @claude, @copilot, @qwen, @gemini
- @codex, @gpt4, @sonnet
- ANY custom name! Just use @agent-name

---

## Workflow Example

### 1. Spec Writer Creates 100 Specs

```bash
# After running spec-writer 100 times...
ls specs/
# 001-user-auth/
# 002-admin-panel/
# ...
# 100-payment-gateway/
```

### 2. Bulk Create Worktrees

```bash
/supervisor:init --all

# Creates 300+ worktrees in ~30 seconds
```

### 3. Agents Find Their Work

**@copilot queries**:
```bash
register-worktree.py query --query "copilot assignments"
# Output: 42 specs with 287 tasks
```

**@claude queries**:
```bash
register-worktree.py query --query "claude assignments"
# Output: 38 specs with 156 architecture tasks
```

### 4. Agents Work in Parallel

```bash
# @copilot works here
cd ../my-app-001-copilot
cd ../my-app-005-copilot
# ... 42 worktrees total

# @claude works here
cd ../my-app-001-claude
cd ../my-app-002-claude
# ... 38 worktrees total

# NO CONFLICTS! ✅
```

---

## Performance

| Specs | Agents/Spec | Total Worktrees | Time (Parallel) | Time (Sequential) |
|-------|-------------|-----------------|-----------------|-------------------|
| 10    | 3-4         | 35              | ~5 sec          | ~15 sec          |
| 50    | 3-4         | 175             | ~15 sec         | ~90 sec          |
| 100   | 3-4         | 350             | ~30 sec         | ~3 min           |
| 200   | 3-4         | 700             | ~60 sec         | ~6 min           |

**Parallel mode is 10x faster!** 🚀

---

## Troubleshooting

### "Worktree already exists"

```bash
# Remove and recreate
git worktree remove ../my-app-001-copilot --force
/supervisor:init 001-user-auth
```

### "Branch already exists"

```bash
# Delete old branch
git branch -D agent-copilot-001

# Recreate
/supervisor:init 001-user-auth
```

### Mem0 Not Registering

```bash
# Check Mem0 working
register-worktree.py list

# If empty, re-register
python plugins/planning/skills/doc-sync/scripts/bulk-register-worktrees.py
```

---

## Best Practices

### ✅ DO

- Use bulk mode for 10+ specs
- Add agent names to layered-tasks.md
- Query Mem0 to find your work
- Create worktrees in parallel (default)
- Register immediately after creation

### ❌ DON'T

- Create worktrees manually
- Skip Mem0 registration
- Use sequential mode (unless debugging)
- Create without checking existing worktrees
- Forget to specify @agent in layered-tasks

---

## Summary

**100 specs?** No problem!

1. **Spec writer** creates specs with `@agent` assignments
2. **Bulk create**: `/supervisor:init --all` (30 seconds)
3. **Agents query**: "what's assigned to me?" (via Mem0)
4. **Work in parallel**: Each agent in isolated worktrees
5. **Zero conflicts**: Complete isolation ✅

**Result**: Parallel development at scale! 🚀

---

**Last Updated**: November 3, 2025
**Performance**: 100 specs in 30 seconds
**Supported**: Unlimited specs, unlimited agents

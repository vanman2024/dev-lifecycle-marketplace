# Git Worktree System for Parallel Development

## Overview

The dev-lifecycle-marketplace uses **Git worktrees** to enable **parallel development** across multiple specs without conflicts.

**Architecture**: **One worktree per spec** - All agents working on a spec share the same worktree.

## What Are Worktrees?

Git worktrees allow you to have **multiple working directories** from the same repository, each on a different branch.

```bash
# Instead of this (serial development):
main/           # Only one working directory
├── src/
└── specs/

# You get this (parallel development):
RedAI/              # Main worktree (main branch)
RedAI-001/          # Spec 001 worktree (spec-001 branch)
RedAI-002/          # Spec 002 worktree (spec-002 branch)
RedAI-003/          # Spec 003 worktree (spec-003 branch)
```

## Why One Worktree Per Spec?

### The Architecture

**Each spec gets ONE worktree shared by all agents:**
- Simpler coordination (no per-agent isolation needed)
- Dependencies installed once per spec
- Agents naturally coordinate in shared workspace
- Easier to test integration

### Benefits

✅ **Simple** - One worktree = one spec
✅ **Fast dependency install** - Install once, not per agent
✅ **Natural coordination** - All agents see each other's changes
✅ **Easy integration testing** - Everything in one place
✅ **Scales to 100+ specs** - Each spec isolated

## How It Works

### Complete Workflow

```bash
# Step 1: Create specs
/planning:spec "user authentication"
/planning:spec "admin dashboard"
# ... create 100 specs

# Step 2: Create worktrees for all specs
/supervisor:init --all

# Creates:
# - ../RedAI-001/ (spec-001 branch) + dependencies installed
# - ../RedAI-002/ (spec-002 branch) + dependencies installed
# - ../RedAI-003/ (spec-003 branch) + dependencies installed
# ... 100 worktrees total

# Step 3: Agents query which worktree to use
register-worktree.py get-worktree --spec 001
# Output: PATH=../RedAI-001

# Step 4: Agents work in the worktree
cd ../RedAI-001
# All agents (@claude, @copilot, @qwen) work here together
# Build the feature for spec 001

# Step 5: Commit and PR
git commit -m "feat: Complete user authentication (spec 001)"
git push origin spec-001
gh pr create

# Step 6: After merge, cleanup
git worktree remove ../RedAI-001
```

## Worktree Naming Convention

```
Pattern: ../{project}-{spec-num}/
Branch:  spec-{spec-num}

Examples:
../RedAI-001/     → spec-001 branch
../my-app-042/    → spec-042 branch
../api-server-003/ → spec-003 branch
```

## Commands Reference

### Create Worktrees

```bash
# Single spec
/supervisor:init 001-user-auth

# All specs (bulk mode)
/supervisor:init --all
```

### Query Worktree for Spec

```bash
# Get worktree path for spec
register-worktree.py get-worktree --spec 001

# Output:
# PATH=../RedAI-001
# BRANCH=spec-001
# SPEC=001
```

### List All Worktrees

```bash
# Via git
git worktree list

# Via Mem0
register-worktree.py list
```

## Dependency Management

**Critical Feature**: Dependencies are automatically installed in each worktree!

### Supported Project Types

**Node.js**:
- Detects: `package.json`
- Auto-selects: npm, pnpm, or yarn (based on lockfile)
- Runs: `npm install` (or pnpm/yarn equivalent)

**Python**:
- Detects: `requirements.txt` or `pyproject.toml`
- Runs: `pip install -r requirements.txt` or `pip install -e .`

### Why This Matters

When working on spec 001:
1. Worktree created: `../RedAI-001/`
2. Dependencies installed automatically
3. Agents can immediately run code/tests
4. No manual setup needed

## Agent Discovery Workflow

### Before Starting Any Work

**Agents should query Mem0** to check for worktree:

```bash
# Agent receives task: "Build user auth for spec 001"

# Step 1: Check for worktree
register-worktree.py get-worktree --spec 001

# Step 2: If found, cd to worktree
cd ../RedAI-001

# Step 3: Verify branch
git branch --show-current  # Should show: spec-001

# Step 4: Start work
# Dependencies already installed ✅
# Just start coding!
```

### Worktree Discovery in Agent Prompts

Agents have this in their prompts:

```markdown
## Worktree Discovery

Before starting work:
1. Check if task mentions a spec number (e.g., "spec 001", "001-user-auth")
2. If yes, query: `register-worktree.py get-worktree --spec {number}`
3. If worktree found: `cd {path}` and work there
4. If not found: work in main repository
```

## Bulk Creation

### Create 100+ Worktrees at Once

```bash
# Bulk create all worktrees
/supervisor:init --all

# Example output:
# 🚀 Bulk Worktree Creation
# 📊 Specs: 127
# 🤖 Total Worktrees: 127 (one per spec)
# ⚙️  Mode: Parallel
#
# ✅ 001-user-auth → ../RedAI-001 📦 (deps installed)
# ✅ 002-admin-panel → ../RedAI-002 📦
# ...
# ✅ Created: 127
# 📦 Dependencies: 127 installed
```

**Performance**: 100 specs in ~30 seconds (parallel mode)

## Integration with Mem0

All worktrees are registered in Mem0 for global tracking:

```python
# Registered per spec:
{
  "spec": "001",
  "spec_name": "user-auth",
  "path": "../RedAI-001",
  "branch": "spec-001",
  "dependencies": "installed (npm)",
  "status": "active"
}
```

**Agents query**: "worktree for spec 001" → Get path

## Comparison: Old vs New Architecture

### Old (Deprecated)

```
One worktree per agent:
../RedAI-001-claude/    (agent-claude-001)
../RedAI-001-copilot/   (agent-copilot-001)
../RedAI-001-qwen/      (agent-qwen-001)
```

Problems:
- ❌ 3-4x more worktrees (one per agent per spec)
- ❌ Dependencies installed 3-4 times per spec
- ❌ Agents can't see each other's changes
- ❌ Complex coordination required

### New (Current)

```
One worktree per spec:
../RedAI-001/           (spec-001)
  - All agents work here
  - Dependencies installed once
  - Natural coordination
```

Benefits:
- ✅ Fewer worktrees (1 per spec vs 3-4 per spec)
- ✅ Dependencies installed once
- ✅ Agents collaborate naturally
- ✅ Simple and fast

## Best Practices

### ✅ DO

- Query Mem0 before starting work on a spec
- Use `get-worktree` to find the correct path
- Work in the spec's worktree (not main)
- Commit frequently with clear messages
- Create PR when spec complete

### ❌ DON'T

- Work in main branch for spec work
- Create worktrees manually
- Skip dependency check
- Assume dependencies are installed

## Troubleshooting

### "No worktree found for spec"

```bash
# Create it
/supervisor:init 001-user-auth
```

### "Dependencies not installed"

```bash
# Install them
register-worktree.py setup-deps --path ../RedAI-001
```

### "Wrong branch"

```bash
# Switch to spec branch
cd ../RedAI-001
git checkout spec-001
```

## Summary

**Architecture**: One worktree per spec (shared by all agents)

**Benefits**:
- ✅ Simple coordination
- ✅ Fast dependency management
- ✅ Scales to 100+ specs
- ✅ Natural agent collaboration

**Usage**:
```bash
/supervisor:init --all                    # Create all
register-worktree.py get-worktree --spec 001  # Find
cd ../RedAI-001                           # Use
```

---

**Last Updated**: November 4, 2025
**Architecture**: One worktree per spec (shared)
**Status**: Production ready ✅

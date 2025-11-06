# Worktree System - Quick Start

## TL;DR

```bash
# Create worktrees for ALL specs at once (100+)
/supervisor:init --all

# Takes ~30 seconds, installs dependencies automatically
```

**Architecture**: **One worktree per spec** (all agents share it)

---

## Key Concept

**One worktree per spec** - All agents working on spec 001 share `../RedAI-001/`

```
OLD (deprecated): One per agent
../RedAI-001-claude/
../RedAI-001-copilot/     ❌ Complex!
../RedAI-001-qwen/

NEW (current): One per spec
../RedAI-001/             ✅ Simple!
  - All agents work here
  - Dependencies installed once
```

---

## Commands

### Single Spec

```bash
# Create worktree for one spec
/supervisor:init 001-user-auth

# Creates:
# - ../RedAI-001/ (spec-001 branch)
# - Dependencies installed (npm/pnpm/yarn/pip)
```

### All Specs (Bulk Mode)

```bash
# Create worktrees for ALL specs
/supervisor:init --all

# Example output:
# 🚀 Bulk Worktree Creation
# 📊 Specs: 127
# 🤖 Total Worktrees: 127 (one per spec)
#
# ✅ 001-user-auth → ../RedAI-001 📦
# ✅ 002-admin-panel → ../RedAI-002 📦
# ...
# ✅ Created: 127
# 📦 Dependencies: 127 installed
```

### Find Worktree for Spec

```bash
# Get worktree path
register-worktree.py get-worktree --spec 001

# Output:
# PATH=../RedAI-001
# BRANCH=spec-001
# SPEC=001
```

---

## Agent Workflow

### Before Starting Work

```bash
# Agent receives task: "Build user auth for spec 001"

# Step 1: Check for worktree
register-worktree.py get-worktree --spec 001

# Step 2: cd to worktree
cd ../RedAI-001

# Step 3: Verify setup
git branch --show-current  # spec-001
npm test                   # Dependencies already installed!

# Step 4: Start work
# All agents working on spec 001 use this same worktree
```

---

## Dependency Management

**Automatic dependency installation!**

### Supported

- **Node.js**: npm, pnpm, yarn (auto-detected)
- **Python**: requirements.txt, pyproject.toml

### What Happens

```bash
/supervisor:init 001-user-auth

# Creates worktree
git worktree add ../RedAI-001 -b spec-001

# Detects package.json → runs npm install
# OR detects requirements.txt → runs pip install

# ✅ Ready to work immediately!
```

---

## Performance

| Specs | Worktrees | Time (Parallel) | Dependencies |
|-------|-----------|-----------------|--------------|
| 10    | 10        | ~5 sec          | All installed |
| 50    | 50        | ~15 sec         | All installed |
| 100   | 100       | ~30 sec         | All installed |
| 200   | 200       | ~60 sec         | All installed |

**Parallel mode** (default) is 10x faster than sequential!

---

## Best Practices

### ✅ DO

- Use `/supervisor:init --all` for 10+ specs
- Query worktree before starting work
- Work in the spec's worktree
- Let dependency installer handle setup

### ❌ DON'T

- Create worktrees manually
- Work in main branch for spec work
- Skip worktree query
- Manually install dependencies

---

## Troubleshooting

### "No worktree found"

```bash
# Create it
/supervisor:init 001-user-auth
```

### "Dependencies not installed"

```bash
# Install manually
cd ../RedAI-001
npm install
# OR
pip install -r requirements.txt
```

### "Wrong branch"

```bash
cd ../RedAI-001
git checkout spec-001
```

---

## Summary

**Architecture**: One shared worktree per spec

**Benefits**:
- ✅ Simple (1 worktree = 1 spec)
- ✅ Fast (dependencies installed once)
- ✅ Scalable (100+ specs supported)
- ✅ Automatic (dependency detection)

**Commands**:
```bash
/supervisor:init --all                     # Bulk create
register-worktree.py get-worktree --spec 001   # Find
cd ../RedAI-001                            # Use
```

**Result**: Parallel development at scale! 🚀

---

**Last Updated**: November 4, 2025
**Architecture**: One worktree per spec (shared)

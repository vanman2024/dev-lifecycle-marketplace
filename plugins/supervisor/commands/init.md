---
allowed-tools: Bash, Read, Write, Grep, Glob
description: Initialize git worktrees for parallel agent execution based on layered tasks
argument-hint: <spec-name> | --all | --bulk
---

**Arguments**: $ARGUMENTS

## Goal

Create isolated git worktree for each spec, enabling parallel development without conflicts. All agents working on a spec share the same worktree.

**Modes**:
- `<spec-name>` - Single spec (e.g., `001-red-seal-ai`)
- `--all` or `--bulk` - All specs at once (100+ specs supported)

## Performance Optimization: Use pnpm for Multi-Worktree Development

**Recommended for projects creating multiple worktrees:**

If your project uses Node.js/npm, consider converting to **pnpm** for dramatic performance improvements:

```bash
# Convert your project (one-time setup)
/foundation:use-pnpm

# Or manually:
npm install -g pnpm
cd /path/to/your/project
rm -rf node_modules package-lock.json
pnpm install  # Creates pnpm-lock.yaml
```

**Benefits for Worktree Workflows:**
- ⚡ **80-90% faster installs** - 5-10s instead of 30-60s per worktree
- 💾 **75% less disk space** - 600MB instead of 2GB for 4 worktrees
- 🔒 **Still isolated** - Each worktree gets correct dependency versions
- 🤖 **Auto-detected** - Worktree system automatically uses pnpm if available

**How it works:**
- First worktree: Downloads to global cache (`~/.pnpm-store/`)
- Subsequent worktrees: Create hardlinks from cache (near-instant)
- Each worktree still has isolated `node_modules/` with correct versions

**System automatically detects and uses pnpm** - no changes to workflow needed!

## Phase 1: Discovery

Actions:
- Check if bulk mode requested (--all or --bulk in arguments)

### Single Spec Mode
- Parse spec name from arguments: $ARGUMENTS
- Verify spec directory exists: specs/$ARGUMENTS
- Extract spec number (e.g., "001" from "001-red-seal-ai")
- Extract spec name (e.g., "red-seal-ai" from "001-red-seal-ai")
- Get current git branch and verify clean working directory

### Bulk Mode (--all or --bulk)
- Scan all specs: `specs/*/`
- Extract spec numbers and names
- Count total worktrees to create (one per spec)
- Show summary and confirm with user

## Phase 2: Worktree Creation & Mem0 Registration

### Single Spec Mode
Actions:
- Invoke worktree-coordinator agent to:
  - Create single git worktree for the spec
  - **Install dependencies in worktree** (Node.js, Python)
  - Register worktree in Mem0 for global tracking
- The agent handles:
  - Extract spec number (e.g., "001" from "001-red-seal-ai")
  - Extract spec name (e.g., "red-seal-ai")
  - Create branch: spec-{spec-number}
  - Create worktree: git worktree add ../{project}-{spec-number} -b spec-{spec-number}
  - Register in Mem0: `register-worktree.py register --spec {spec} --spec-name {name} --path {path} --branch {branch}`
  - **Install dependencies**: `register-worktree.py setup-deps --path {path}` (auto-detects npm/pnpm/yarn/pip)
  - Display created worktree with git worktree list

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
- Worktree path and branch
- Dependencies installation status
- Registered in Mem0 for agent discovery
- How agents query: `register-worktree.py get-worktree --spec {number}`
- Next steps: Any agent working on this spec will automatically use the worktree

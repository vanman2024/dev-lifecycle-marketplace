---
name: worktree-coordinator
description: Coordinates worktree creation and registers them in Mem0 for multi-agent tracking
model: haiku
color: purple
allowed-tools: Read, Write, Bash(*), Grep, Glob, Skill, TodoWrite
---
## Worktree Discovery

**IMPORTANT**: Before starting any work, check if you're working on a spec in an isolated worktree.

**Steps:**
1. Look at your task - is there a spec number mentioned? (e.g., "spec 001", "001-red-seal-ai", working in `specs/001-*/`)
2. If yes, query Mem0 for the worktree:
   ```bash
   python plugins/planning/skills/doc-sync/scripts/register-worktree.py query --query "worktree for spec {number}"
   ```
3. If Mem0 returns a worktree:
   - Parse the path (e.g., `Path: ../RedAI-001`)
   - Change to that directory: `cd {path}`
   - Verify branch: `git branch --show-current` (should show `spec-{number}`)
   - Continue your work in this isolated worktree
4. If no worktree found: work in main repository (normal flow)

**Why this matters:**
- Worktrees prevent conflicts when multiple agents work simultaneously
- Changes are isolated until merged via PR
- Dependencies are installed fresh per worktree



# Worktree Coordinator Agent


## Security: API Key Handling

**CRITICAL:** Read comprehensive security rules:

@docs/security/SECURITY-RULES.md

**Never hardcode API keys, passwords, or secrets in any generated files.**

When generating configuration or code:
- ❌ NEVER use real API keys or credentials
- ✅ ALWAYS use placeholders: `your_service_key_here`
- ✅ Format: `{project}_{env}_your_key_here` for multi-environment
- ✅ Read from environment variables in code
- ✅ Add `.env*` to `.gitignore` (except `.env.example`)
- ✅ Document how to obtain real keys


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
2. **Creates git worktrees** - One per spec
3. **Copies git-ignored build files** - Ensures worktree can build
4. **Installs dependencies** - npm/pnpm/pip automatically
5. **Validates build readiness** - Checks all requirements satisfied
6. **Registers in Mem0** - So agents can query their assignments
7. **Tracks dependencies** - Frontend → Backend relationships
8. **Provides coordination info** - Agents can ask "where does copilot work?"

## Critical Fix: Git-Ignored Files Problem

**Problem**: Git worktrees only copy tracked files, not git-ignored directories.

**Impact**: Worktrees fail to build with errors like:
```
Module not found: Can't resolve '@/lib/ai/openrouter'
```

**Root Cause**:
- `lib/` directory is in `.gitignore`
- Application requires `lib/api/`, `lib/ai/`, `lib/supabase/` to build
- Worktrees don't automatically get these directories

**Solution**: This agent now automatically:
1. Detects git-ignored directories needed for build (`lib/`, `.env.local`, etc.)
2. Copies them from main repository to worktree
3. Validates worktree can build before reporting success

**Files Automatically Copied**:
- `lib/` - Application utilities (API, AI, database)
- `.env.local`, `.env.development` - Environment configs
- `.next/`, `dist/`, `build/` - Build caches (if exist)
- `node_modules/.cache/` - Dependency caches

## Available Tools & Resources

**MCP Servers Available:**
- `mcp__filesystem` - Read spec files and layered-tasks.md
- `mcp__github` - Manage git worktrees and branches
- `mcp__memory` - Store worktree coordination in Mem0

**Skills Available:**
- `Skill(supervisor:worktree-orchestration)` - Worktree creation and Mem0 registration
- Invoke skills when you need worktree scripts or coordination patterns

**Slash Commands Available:**
- `SlashCommand(/supervisor:init)` - Initialize worktree coordination
- `SlashCommand(/supervisor:start)` - Start multi-agent workflow
- Use for orchestrating parallel agent workflows

## Workflow

### Phase 1: Discovery

Actions:
- Read spec directory: `specs/$SPEC_NUM-*/`
- Extract spec number (e.g., "001" from "001-red-seal-ai")
- Extract spec name (e.g., "red-seal-ai" from "001-red-seal-ai")
- Detect project type (Node.js, Python) for dependency installation

### Phase 2: Worktree Creation (One Per Spec)

**Create single shared worktree for the spec:**

```bash
# Create branch
git checkout -b spec-{spec-num}

# Create worktree
git worktree add ../{project}-{spec-num} spec-{spec-num}

# Register in Mem0
python plugins/planning/skills/doc-sync/scripts/register-worktree.py register \
  --spec {spec-num} \
  --spec-name {spec-name} \
  --path ../{project}-{spec-num} \
  --branch spec-{spec-num}
```

### Phase 3: Complete Worktree Setup

**CRITICAL**: Run complete setup to ensure worktree is build-ready.

```bash
# Complete setup: dependencies + git-ignored files + validation
python plugins/planning/skills/doc-sync/scripts/register-worktree.py setup-complete \
  --path ../{project}-{spec-num}
```

**What setup-complete does:**

1. **Install Dependencies**
   - Node.js: Detects and uses npm, pnpm, or yarn
   - Python: Installs from requirements.txt or pyproject.toml

2. **Copy Git-Ignored Build Files**
   - `lib/` directory (API, AI, database utilities)
   - `.env.local`, `.env.development` (environment configs)
   - `.next/`, `dist/`, `build/` (build caches)
   - Any other git-ignored directories needed for build

3. **Validate Build Readiness**
   - Checks tsconfig.json paths are satisfied
   - Verifies critical directories exist
   - Ensures worktree can build successfully

**Performance Tip**: If project uses **pnpm**, subsequent worktrees install 80-90% faster via global cache (~/.pnpm-store/). Auto-detected. Use `/foundation:use-pnpm` to convert npm projects to pnpm.

**Individual Actions** (if you need granular control):
```bash
# Just install dependencies
python plugins/planning/skills/doc-sync/scripts/register-worktree.py setup-deps --path ...

# Just copy git-ignored files
python plugins/planning/skills/doc-sync/scripts/register-worktree.py copy-ignored --path ...

# Just validate build
python plugins/planning/skills/doc-sync/scripts/register-worktree.py validate-build --path ...
```

### Phase 4: Verification & Summary

Actions:
- Verify all worktrees created: `git worktree list`
- List registered worktrees in Mem0
- Display coordination summary

Output:
```
🎯 Worktree Setup Complete!

Spec: 001-red-seal-ai
Project: RedAI

📁 Worktree Created:
  • Path: ../RedAI-001
  • Branch: spec-001
  • Dependencies: ✅ installed (npm)
  • Git-ignored files: ✅ copied (lib/, .env.local)
  • Build validation: ✅ passed

✅ Registered in Mem0 - all agents can work in this worktree!

🔍 Any agent can now query:
  python plugins/planning/skills/doc-sync/scripts/register-worktree.py get-worktree --spec 001

Next: Agents working on spec 001 will automatically cd into ../RedAI-001
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

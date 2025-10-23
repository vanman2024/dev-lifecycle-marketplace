# Project Automation

**Systematic, lifecycle-ordered development automation for any framework.**

---

## What This Is

A clean, consolidated plugin system that takes you from spec → production in 6 lifecycle phases.

**Not a replacement for spec-kit.** This enhances spec-kit by adding iterative development capabilities that spec-kit lacks.

---

## Architecture: 6 Lifecycle Plugins

### 1. **core** - Foundation
Initialize, detect stack, version control setup
- `/init`, `/detect`, `/git-setup`, `/version`

### 2. **planning** - Spec → Architecture
Create specs, plans, architecture, documentation
- `/spec`, `/plan`, `/architecture`, `/roadmap`, `/notes`, `/decide`

### 3. **develop** - Build Features
Code generation, scaffolding, implementation
- `/feature`, `/component`, `/api`, `/scaffold`, `/ai-integration`

### 4. **iterate** - Refine & Adjust
Modify, refactor, enhance, sync during active development
- `/adjust`, `/sync`, `/tasks`, `/refactor`, `/enhance`, `/remember`

### 5. **quality** - Test & Validate
Testing, security, performance, compliance
- `/test`, `/test-generate`, `/security`, `/performance`, `/validate`, `/compliance`

### 6. **deploy** - Ship It
Deploy to production, monitor, observe
- `/deploy`, `/deploy-prepare`, `/monitor`, `/logs`

---

## How It Works with Spec-Kit

```
1. Spec-kit creates specs/001-feature/
2. /detect analyzes project → .claude/project.json
3. /plan reads spec, creates implementation plan
4. /feature implements from spec (using detected framework)
5. /test validates acceptance criteria
6. /deploy ships it

Then iterate:
7. /adjust modifies features
8. /sync coordinates multiple agents
9. /refactor improves code
10. /deploy ships updates
```

---

## Workflow: Spec → Production

**Initial Setup:**
```bash
# Spec-kit creates spec
spec-kit specify "Build authentication system"

# We initialize
/init                 # Detects OR bootstraps project
/plan                 # Reads spec, creates plan
```

**Development:**
```bash
/feature add-auth     # Implements feature from spec
/test                 # Validates acceptance criteria
```

**Iteration:**
```bash
/adjust               # Modify feature mid-development
/sync                 # Sync changes between agents
/refactor             # Improve code structure
```

**Quality & Deploy:**
```bash
/security             # Security audit
/performance          # Performance check
/deploy               # Ship to production
```

---

## Framework Agnostic

All plugins read `.claude/project.json` to detect:
- Framework (Next.js, Django, Go, Rails, etc.)
- Stack (React, PostgreSQL, Tailwind, etc.)
- Structure (monorepo, frontend/backend separation, etc.)

**No hardcoded assumptions.** Works with any tech stack.

---

## Building Plugins

Use the master command from multiagent-build-system:

```bash
cd /home/gotime2022/Projects/project-automation
/multiagent-build-system:build-lifecycle-plugin develop "Code generation"
```

This creates the full plugin structure with commands, agents, skills, hooks, docs, and memory.

---

## Status

**Built:** None yet (building systematically)

**Next:** Build `develop` plugin first (most needed for actual work)

**Plan:** See [CONSOLIDATION-PLAN.md](./CONSOLIDATION-PLAN.md) for full details

---

## Installation

```bash
# Register marketplace (already done)
# Plugins auto-discovered when built
```

---

**No more endless consolidation. We build, test, and use.**

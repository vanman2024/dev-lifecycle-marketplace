# The Agent-Skill Pattern

**Status:** ACTIVE PATTERN (November 20, 2025)
**Supersedes:** All previous agent orchestration patterns

---

## The Problem We Solved

**Issue:** Subagents cannot spawn other subagents.

**Previous broken approach:**
```
/implementation:execute (command)
  → Task(general-purpose, "run /clerk:init")
    → SlashCommand(/clerk:init)
      → Task(clerk-setup-agent) ❌ TOO DEEP - FAILS
```

**Root cause:** Trying to nest 3 levels of execution (command → agent → slash command → agent)

---

## The Solution: Agent-Skill Pattern

**Agents use SKILLS for knowledge/templates, NOT slash commands for execution.**

```
/implementation:execute (command - orchestrator)
  ↓
  Task(clerk-setup-agent, prompt="Setup Clerk auth...")
    ↓
    Skill(clerk:nextjs-integration) - loads templates
    ↓
    Copy templates/app-router/layout.tsx → project
    Copy templates/app-router/middleware.ts → project
    ↓
    Returns results
```

**No nesting beyond 2 levels. No subagents spawning slash commands.**

---

## The Three-Layer Architecture

### Layer 1: Slash Commands (User-Facing Orchestrators)

**Purpose:** Entry points for users, orchestrate workflows

**Capabilities:**
- Detect context (framework, environment)
- Ask user questions (AskUserQuestion)
- Spawn agents (Task tool)
- Chain other slash commands (SlashCommand) - for manual workflows only
- Verify results

**Allowed tools:** `Read, Bash, Task, AskUserQuestion, SlashCommand`

**Example:** `/clerk:init`, `/implementation:execute`, `/supabase:create-schema`

### Layer 2: Agents (Executors)

**Purpose:** Do the actual work using skills as knowledge sources

**Capabilities:**
- Load skills for templates/scripts/patterns (Skill tool)
- Read/write files
- Execute scripts from skills
- Apply templates from skills
- Return results to calling command

**Allowed tools:** `Read, Write, Bash(*), Grep, Glob, Skill, TodoWrite`

**Critical:** Agents CANNOT use SlashCommand (no nesting)

**Example:** `clerk-setup-agent`, `supabase-architect`, `task-mapper`

### Layer 3: Skills (Knowledge Bases)

**Purpose:** Provide reusable templates, scripts, examples, patterns

**Contents:**
- `SKILL.md` - Instructions and patterns
- `templates/` - Code templates agents can copy
- `scripts/` - Automation scripts agents can execute
- `examples/` - Complete usage examples

**Critical:** Skills are PASSIVE - they don't execute anything themselves

**Example:** `clerk:nextjs-integration`, `celery:celery-config-patterns`

---

## Pattern Examples

### Simple Command (Spawns 1 Agent)

```markdown
# /clerk:init command

Phase 1: Detect framework
Phase 2: Ask user preferences
Phase 3: Spawn agent

Task(
  subagent_type="clerk:clerk-setup-agent",
  prompt="Setup Clerk with Next.js App Router
         Use Skill(clerk:nextjs-integration) for templates"
)

Phase 4: Verify installation
Phase 5: Summary
```

### Complex Command (Spawns Multiple Agents in Parallel)

```markdown
# /implementation:execute I012 command

Phase 1-3: Discovery and mapping
  - Read tasks.md
  - Map: Task 1 → clerk-setup-agent
  - Map: Task 2 → redis-setup-agent
  - Map: Task 3 → supabase-architect

Phase 4: Spawn agents IN PARALLEL

Task(
  subagent_type="clerk:clerk-setup-agent",
  prompt="Setup Clerk. Use Skill(clerk:nextjs-integration)"
)

Task(
  subagent_type="redis:redis-setup-agent",
  prompt="Setup Redis. Use Skill(redis:cache-strategies)"
)

Task(
  subagent_type="supabase:supabase-architect",
  prompt="Setup Supabase. Use Skill(supabase:schema-patterns)"
)

Wait for ALL agents to complete

Phase 5: Aggregate results
```

### Agent Using Skills

```markdown
# clerk-setup-agent.md

---
allowed-tools: Read, Write, Bash(*), Grep, Glob, Skill, TodoWrite
---

## Step 1: Load Skill

Skill(clerk:nextjs-integration)

This provides:
- templates/app-router/layout.tsx
- templates/app-router/middleware.ts
- scripts/detect-framework.sh
- examples/app-router-setup.md

## Step 2: Detect Framework

!{bash ~/.claude/plugins/.../skills/clerk:nextjs-integration/scripts/detect-framework.sh}

## Step 3: Apply Templates

Read template:
@~/.claude/plugins/.../skills/clerk:nextjs-integration/templates/app-router/layout.tsx

Copy to project:
Write(app/layout.tsx, [modified template content])

## Step 4: Return Results
```

---

## What Changed

### Before (Broken)
- ❌ Agents had `SlashCommand` in allowed-tools
- ❌ Agents tried to execute other slash commands
- ❌ Created 3-level nesting (command → agent → command → agent)
- ❌ Hit "subagents cannot spawn subagents" limitation

### After (Working)
- ✅ Agents have `Skill` in allowed-tools
- ✅ Agents load skills for knowledge/templates
- ✅ Only 2-level nesting (command → agent)
- ✅ Skills provide all resources agents need
- ✅ Parallel execution works (multiple agents spawned from one command)

---

## Skill Requirements

For this pattern to work, skills MUST provide executable resources:

**Required in every skill:**
```
skill-name/
├── SKILL.md (comprehensive instructions)
├── scripts/ (executable automation)
│   ├── detect-*.sh
│   ├── validate-*.sh
│   └── generate-*.sh
├── templates/ (complete code templates)
│   ├── component.tsx
│   ├── config.py
│   └── schema.sql
└── examples/ (working examples)
    ├── basic-setup.md
    └── advanced-setup.md
```

**Skills are NOT just documentation - they're executable knowledge bases.**

---

## Command Types

### Type 1: Simple Orchestrator
- Spawns 1 agent
- Agent does focused work
- Example: `/clerk:init`, `/supabase:create-schema`

### Type 2: Parallel Orchestrator
- Spawns multiple agents simultaneously
- Aggregates results
- Example: `/implementation:execute --infrastructure`

### Type 3: Sequential Orchestrator
- Spawns multiple agents one at a time
- Each depends on previous
- Example: `/deployment:deploy` (validate → build → deploy → verify)

### Type 4: Direct Execution (No Agents)
- Simple operations
- No spawning needed
- Example: `/foundation:env-vars list`

---

## Migration Checklist

To update existing plugins to this pattern:

- [ ] Update all agent `allowed-tools` to include `Skill` not `SlashCommand`
- [ ] Add `Skill()` invocations to agent bodies
- [ ] Ensure skills have executable templates/scripts (not just docs)
- [ ] Update commands to spawn agents with skill references
- [ ] Test that agents can load and use skills
- [ ] Remove any 3-level nesting patterns

---

## Testing Verification

Test that an agent can:
1. Load a skill: `Skill(plugin:skill-name)`
2. See skill contents (SKILL.md, directory structure)
3. Read templates from skill directory
4. Execute scripts from skill directory
5. Return results without spawning other commands

---

## Related Documentation

- [Component Decision Framework](../../domain-plugin-builder/plugins/domain-plugin-builder/docs/frameworks/claude/reference/component-decision-framework.md) - Comprehensive guide for component types
- `dans-composition-pattern.md` - Foundational theory
- `SECURITY-RULES.md` - Security requirements for all patterns

## Key Example: /implementation:execute

The `/implementation:execute` command is the primary orchestrator demonstrating this pattern:

```
/implementation:execute I001 "use clerk agents in parallel"
  ↓
Phase 1-3: Analyze tasks, determine remaining work
  ↓
Phase 4: Map tasks to domain agents:
  - clerk:clerk-oauth-specialist
  - clerk:clerk-api-builder
  - clerk:clerk-nextjs-app-router-agent
  ↓
Phase 5: Spawn ALL agents in single message (parallel)
  ↓
Phase 6: Validate, check off tasks.md
  ↓
Phase 7-8: Update status, summary
```

See: `plugins/implementation/commands/execute.md`

---

**Last Updated:** November 20, 2025
**Status:** ACTIVE - Use this pattern for all new development

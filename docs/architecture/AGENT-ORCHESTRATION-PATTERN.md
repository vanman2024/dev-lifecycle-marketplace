# Agent Orchestration Pattern

**Status**: Architectural Standard
**Version**: 2.0.0
**Last Updated**: 2025-11-07

## Quick Reference: What's Correct vs. Anti-Pattern

### ✅ CORRECT: Agents Using Slash Commands

```markdown
# In an AGENT file (agents/stack-detector.md)
Phase 1: Verify environment
!{slashcommand /foundation:env-check --fix}

Phase 2: Generate types
!{slashcommand /supabase:generate-types}
```

**Agents are ALLOWED to use slash commands** - they're tools in the agent's toolbox!

### 🚨 ANTI-PATTERN: Commands Chaining Commands

```markdown
# In a COMMAND file (commands/build-full-stack.md)
Phase 1: !{slashcommand /foundation:detect}
Phase 2: !{slashcommand /foundation:env-check}
Phase 3: !{slashcommand /planning:analyze-project}
Phase 4: !{slashcommand /supervisor:init}
... (3+ commands chained)
```

**Commands should NOT chain other commands** - they should spawn agents instead!

### ✅ CORRECT: Commands Spawning Agents

```markdown
# In a COMMAND file (commands/build-full-stack.md)
Phase 1: Spawn agents in parallel
Task(subagent_type="foundation:stack-detector")
Task(subagent_type="foundation:env-validator")
Task(subagent_type="planning:spec-analyzer")
```

**Commands should ORCHESTRATE agents** - spawn them with Task() tool!

---

## The Problem: Slash Command Chaining Anti-Pattern

**IMPORTANT**: This anti-pattern applies ONLY to COMMAND files, NOT agents.
- ✅ **Agents using `!{slashcommand ...}` as utilities is CORRECT**
- 🚨 **Commands chaining 3+ other commands sequentially is WRONG**

### What's Wrong

Many **COMMAND files** currently chain multiple slash commands sequentially:

```markdown
# ANTI-PATTERN ❌
Phase 1: Execute /foundation:detect
!{slashcommand /foundation:detect $ARGUMENTS}

Phase 2: Execute /foundation:env-check
!{slashcommand /foundation:env-check --fix}

Phase 3: Execute /foundation:github-init
!{slashcommand /foundation:github-init $ARGUMENTS --private}

Phase 4: Execute /planning:analyze-project
!{slashcommand /planning:analyze-project}

Phase 5: Execute /supervisor:init multiple times
!{slashcommand /supervisor:init 001-user-auth}
!{slashcommand /supervisor:init 002-product-catalog}
!{slashcommand /supervisor:init 003-shopping-cart}
```

**Example**: `ai-tech-stack-1:build-full-stack-phase-0` chains **7+ slash commands**

### Why This is Wrong

1. **Sequential execution is SLOW** - Each command waits for the previous one to complete
   - Sequential: 18 minutes (cmd1 → WAIT → cmd2 → WAIT → cmd3)
   - Parallel: 10 minutes (all agents report back simultaneously)

2. **Deep nesting complexity** - Commands calling commands calling commands creates fragile chains

3. **No parallelization** - Independent operations run sequentially when they could run in parallel

4. **Violates Dan's Composition Pattern** - Commands should orchestrate agents, not chain other commands

## The Solution: Agent Orchestration

### Architecture Principle

**Commands are orchestrators that spawn specialized agents.**

```
COMMAND (Orchestrator)
  ├─ Agent 1: Setup (parallel)
  ├─ Agent 2: Database (parallel)
  ├─ Agent 3: API (waits for 1,2)
  └─ Agent 4: UI (waits for 3)
```

### Correct Pattern

```markdown
# CORRECT PATTERN ✅
Phase 1: Spawn Multiple Agents in Parallel

Actions:
- Spawn foundation agent:
  Task(
    description="Detect project stack and initialize",
    subagent_type="foundation:stack-detector",
    prompt="Analyze project at $ARGUMENTS and populate .claude/project.json"
  )

- Spawn environment agent (parallel):
  Task(
    description="Verify development environment",
    subagent_type="foundation:env-validator",
    prompt="Check Node.js, Python, npm, pip, Git, CLIs. Install missing with --fix flag"
  )

- Spawn specs validation agent (parallel):
  Task(
    description="Validate all specs for completeness",
    subagent_type="planning:spec-analyzer",
    prompt="Analyze all specs in specs/ and generate gaps-analysis.json"
  )

Phase 2: Wait for Agents to Complete
- All agents report back with results
- Verify all succeeded before proceeding

Phase 3: Spawn Dependent Agents
- Now spawn agents that depend on Phase 1 results
  Task(
    description="Setup GitHub repository",
    subagent_type="foundation:github-initializer",
    prompt="Create private repo $ARGUMENTS with security templates, branch protection, hooks"
  )
```

## Key Architectural Rules

### 1. Commands = Orchestrators

**Role**: Package and spawn multiple specialized agents
**Responsibilities**:
- Define workflow sequence
- Spawn agents with Task() tool
- Handle parallelization opportunities
- Verify agent completion
- Aggregate results

**NOT Responsible For**:
- ❌ Chaining other slash commands
- ❌ Doing the actual work themselves

### 2. Agents = Specialized Workers

**Role**: Execute autonomous workflows with domain expertise
**Capabilities**:
- Have domain-specific knowledge (skills)
- Can invoke slash commands when needed
- Have MCP servers available
- Execute autonomously
- Report back to orchestrator

**Tools Available**:
- Slash commands (for utilities)
- Skills (for domain knowledge)
- MCP servers (for external data)
- Basic tools (Read, Write, Bash, etc.)

### 3. Simple Commands = Reusable Prompts

**Role**: Single-purpose operations
**When to Use**:
- Quick utility functions
- No agent spawning needed
- Simple transformations

## Migration Guide: From Chaining to Orchestration

### Step 1: Identify Chained Commands

Scan for `!{slashcommand /...}` patterns:

```bash
# Find all commands that chain 3+ slash commands
grep -r "!{slashcommand" plugins/*/commands/*.md | \
  cut -d: -f1 | uniq -c | sort -rn | \
  awk '$1 >= 3 { print $1, $2 }'
```

### Step 2: Map Commands to Agents

For each chained slash command, identify or create the corresponding agent:

| Slash Command | Agent Type | Capability |
|--------------|------------|------------|
| `/foundation:detect` | `foundation:stack-detector` | Project detection |
| `/foundation:env-check` | `foundation:env-validator` | Environment verification |
| `/foundation:github-init` | `foundation:github-initializer` | GitHub setup |
| `/planning:analyze-project` | `planning:spec-analyzer` | Spec validation |
| `/supervisor:init` | `supervisor:worktree-coordinator` | Worktree creation |

### Step 3: Refactor Command

**Before** (Anti-Pattern):
```markdown
Phase 1: Setup Foundation
!{slashcommand /foundation:detect $ARGUMENTS}
!{slashcommand /foundation:env-check --fix}
```

**After** (Orchestration):
```markdown
Phase 1: Setup Foundation (Parallel Agents)

Actions:
- Spawn detection agent:
  Task(description="Detect stack", subagent_type="foundation:stack-detector", prompt="...")

- Spawn validation agent (parallel):
  Task(description="Validate env", subagent_type="foundation:env-validator", prompt="...")

- Wait for both agents to complete
- Verify results before proceeding to Phase 2
```

### Step 4: Update Agents with Allowed Tools

Ensure agents have the correct tools in their frontmatter:

```yaml
---
name: stack-detector
description: Detects project tech stack and populates .claude/project.json
allowed-tools: Read, Grep, Glob, Bash(*), Write, SlashCommand(/foundation:*)
---
```

**Note**: Agents can and SHOULD use slash commands as utilities - this is correct!

#### ✅ Correct: Agents Using Slash Commands

```markdown
# In stack-detector.md (AGENT file)
Phase 1: Verify Environment
- Check tools are installed: !{slashcommand /foundation:env-check --fix}

Phase 2: Detect Stack
- Read package.json and analyze dependencies...
- Populate .claude/project.json

Phase 3: Generate Types
- Generate TypeScript types: !{slashcommand /supabase:generate-types}
```

**This is the RIGHT way** - agents use slash commands as tools/utilities to accomplish their work.

#### 🚨 Anti-Pattern: Commands Chaining Commands

```markdown
# In build-full-stack-phase-0.md (COMMAND file)
Phase 1: !{slashcommand /foundation:detect}
Phase 2: !{slashcommand /foundation:env-check}
Phase 3: !{slashcommand /planning:analyze-project}
Phase 4: !{slashcommand /supervisor:init spec-001}
... (7+ total commands chained)
```

**This is the WRONG way** - commands should spawn agents, not chain commands.

## Parallelization Opportunities

### Dependency Analysis

**Independent Operations** (run in parallel):
```
Task(subagent_type="nextjs-frontend:setup-agent")
Task(subagent_type="fastapi-backend:setup-agent")
Task(subagent_type="supabase:schema-agent")
```
No dependencies - all can run simultaneously

**Dependent Operations** (run sequentially):
```
Phase 1: Foundation
  Task(subagent_type="database:setup-agent")

Phase 2: API (waits for Phase 1)
  Task(subagent_type="api:endpoint-agent")

Phase 3: UI (waits for Phase 2)
  Task(subagent_type="ui:component-agent")
```

### Performance Impact

| Pattern | Time | Efficiency |
|---------|------|------------|
| Sequential chaining (7 commands × 3 min) | 21 min | 🐌 Slow |
| Parallel agents (7 agents × 3 min, 3 in parallel) | 9 min | ⚡ 2.3× faster |
| Optimized parallel (smart batching) | 7 min | ⚡ 3× faster |

## Examples from Codebase

### Anti-Pattern: ai-tech-stack-1:build-full-stack-phase-0

**Current** (chains 7+ commands):
```markdown
!{slashcommand /planning:analyze-project}
!{slashcommand /supervisor:init 001-user-auth}
!{slashcommand /supervisor:init 002-product-catalog}
!{slashcommand /foundation:detect $ARGUMENTS}
!{slashcommand /foundation:env-check --fix}
!{slashcommand /foundation:github-init $ARGUMENTS --private}
!{slashcommand /foundation:doppler-setup $ARGUMENTS}
```

**Should Be** (spawns 5 agents):
```markdown
Phase 1: Parallel Setup (Batch 1)
- Task(subagent_type="planning:spec-analyzer", prompt="Validate all specs")
- Task(subagent_type="foundation:stack-detector", prompt="Detect tech stack")
- Task(subagent_type="foundation:env-validator", prompt="Verify environment")

Phase 2: Sequential Setup (Batch 2 - depends on Phase 1)
- Task(subagent_type="foundation:github-initializer", prompt="Setup GitHub repo")
- Task(subagent_type="foundation:doppler-integrator", prompt="Configure Doppler")

Phase 3: Parallel Worktrees (Batch 3 - depends on Phase 2)
- Task(subagent_type="supervisor:worktree-coordinator", prompt="Init spec 001")
- Task(subagent_type="supervisor:worktree-coordinator", prompt="Init spec 002")
```

## Validation: agent-auditor

The `quality:agent-auditor` agent now detects this anti-pattern:

### Detection Rules

- **1-2 slash commands**: Usually acceptable
- **3+ slash commands**: 🚨 ANTI-PATTERN - Flag for refactoring

### Example Output

```
🚨 ANTI-PATTERN: Chains 7 slash commands - should spawn 7 agents using Task() instead
⚡ Parallelization opportunity - spawn agents in parallel, not sequential commands

Commands found:
- /planning:analyze-project
- /supervisor:init (×3)
- /foundation:detect
- /foundation:env-check
- /foundation:github-init
- /foundation:doppler-setup

Recommendation: Refactor to spawn Task(agents) with proper dependency management
```

## Implementation Checklist

When refactoring a command:

- [ ] Identify all `!{slashcommand ...}` patterns
- [ ] Count total chained commands (flag if 3+)
- [ ] Analyze dependencies between operations
- [ ] Group independent operations (can run in parallel)
- [ ] Map each slash command to corresponding agent type
- [ ] Verify agents exist or create new agents
- [ ] Update command to spawn agents with Task()
- [ ] Add dependency management (phases/batching)
- [ ] Test parallel execution
- [ ] Verify performance improvement
- [ ] Run agent-auditor to confirm compliance

## Benefits Summary

✅ **Performance**: 2-3× faster execution via parallelization
✅ **Simplicity**: Clear separation of orchestration vs execution
✅ **Maintainability**: Agents are independently testable
✅ **Scalability**: Easy to add new agents to workflow
✅ **Flexibility**: Can adjust parallelization based on dependencies
✅ **Architecture**: Follows Dan's Composition Pattern

## References

- Dan's Composition Pattern: `~/.claude/plugins/marketplaces/domain-plugin-builder/plugins/domain-plugin-builder/docs/frameworks/claude/reference/dans-composition-pattern.md`
- Agent Auditor: `plugins/quality/agents/agent-auditor.md`
- Task Tool Documentation: Claude Code core tool documentation

---

**Next Steps**: Audit all plugins for slash command chaining and refactor to agent orchestration pattern.

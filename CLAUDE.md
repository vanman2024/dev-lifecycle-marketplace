# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# 🚨🚨🚨 CRITICAL: EXECUTE SLASH COMMANDS IMMEDIATELY 🚨🚨🚨

## ⚡ SLASH COMMAND EXECUTION POLICY ⚡

**WHEN YOU SEE A SLASH COMMAND, YOU MUST EXECUTE IT IMMEDIATELY USING THE `SlashCommand` TOOL.**

### REQUIRED BEHAVIOR:

✅ **DO THIS:**
```bash
# User asks: "Create a new agent for task validation"
→ IMMEDIATELY EXECUTE: /domain-plugin-builder:agents-create task-validator "Validate tasks against implementation"
→ USE SlashCommand TOOL RIGHT NOW - DON'T WAIT, DON'T PLAN, JUST DO IT
```

❌ **NEVER DO THIS:**
```bash
# User asks: "Create a new agent for task validation"
→ "I'll create a plan to build the agent..." ❌ NO PLANNING
→ "Let me think about this..." ❌ NO THINKING
→ "First, I should..." ❌ NO DELAYING
→ "Would you like me to...?" ❌ NO ASKING FOR PERMISSION
```

### EXECUTION RULES:

1. **IMMEDIATE EXECUTION**: When slash command is needed, invoke `SlashCommand` tool FIRST, explain AFTER
2. **NO DELAYS**: Don't plan, don't discuss, don't ask - EXECUTE IMMEDIATELY
3. **NO MANUAL CREATION**: NEVER manually create agents/commands/skills - ALWAYS use slash commands
4. **PARALLEL EXECUTION**: Multiple independent commands? Execute ALL in same message block

### EXAMPLES OF IMMEDIATE EXECUTION:

**User Request**: "Create three new agents: task-validator, code-reviewer, test-generator"

**CORRECT Response**:
```
[IMMEDIATELY USE SlashCommand TOOL:]
/domain-plugin-builder:agents-create task-validator "Validate tasks" code-reviewer "Review code quality" test-generator "Generate test suites"

[AFTER execution, explain what was done]
```

**INCORRECT Response**:
```
"Let me create a plan for these agents..." ❌
"I'll use the domain-plugin-builder to create..." ❌
"First, I should analyze the requirements..." ❌
```

---

## 🚨 CRITICAL: Security Rules - NO HARDCODED API KEYS

**This is the HIGHEST PRIORITY security rule for ALL plugins in this marketplace.**

### Absolute Prohibition

❌ **NEVER EVER** hardcode API keys, secrets, or credentials in:
- Agent prompts
- Command prompts
- Skill documentation
- Example code
- Scripts or configuration

### Required Practice

✅ **ALWAYS use placeholders:**
```bash
ANTHROPIC_API_KEY=your_anthropic_key_here
OPENAI_API_KEY=your_openai_key_here
```

✅ **ALWAYS read from environment:**
```python
import os
api_key = os.getenv("ANTHROPIC_API_KEY")
```

### Comprehensive Security Guidelines

See `@docs/security/SECURITY-RULES.md` for full validation checklist.

---

## Repository Overview

This is the **dev-lifecycle-marketplace** - a collection of tech-agnostic workflow automation plugins for Claude Code that handle the complete software development lifecycle from initialization to deployment. These plugins orchestrate **HOW you develop** (process and methodology), not **WHAT you develop with** (specific SDKs or frameworks).

**Version**: 2.0.0 (Rebuilt October 2025)

## Core Architecture

### The 7 Lifecycle Plugins

The marketplace consists of 7 independent plugins that work together as a cohesive workflow:

1. **foundation** - Project initialization, tech stack detection, environment setup, workflow generation
2. **planning** - Specifications, architecture design, roadmaps, ADRs, feature workflow generation
3. **implementation** - Execution orchestration, task-to-command mapping, automated feature building
4. **iterate** - Task layering, code adjustments, refactoring, feature enhancement
5. **quality** - Code validation, security scanning, performance analysis, compliance checking
6. **testing** - Test execution (Newman/Postman API + Playwright E2E), test generation
7. **deployment** - Platform auto-detection and deployment orchestration

### Plugin Structure

Each plugin follows this standardized structure:
```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── commands/                 # Slash commands (*.md files)
├── agents/                   # Specialized agents (*.md files)
├── skills/                   # Progressive disclosure skills
│   └── <skill-name>/
│       ├── SKILL.md         # Skill description & instructions
│       ├── scripts/         # Executable automation scripts
│       ├── templates/       # Code/config templates
│       └── examples/        # Usage examples
└── README.md                # Plugin documentation
```

### Tech Stack Agnosticism

**CRITICAL PRINCIPLE**: These plugins are completely tech-agnostic. They work by:
- Detecting the project's tech stack via `.claude/project.json`
- Adapting commands and agents to the detected stack
- Using generic patterns that work across any language/framework
- Deferring tech-specific operations to external domain plugins (nextjs-frontend, fastmcp, vercel-ai-sdk, etc.)

## Key Components

### Commands (Slash Commands)

Commands are markdown files in `plugins/<name>/commands/*.md` that define user-facing operations.

**Command File Format**:
- YAML frontmatter with: `description`, `argument-hint`, `allowed-tools`
- Phase-based workflow with clear goals and actions
- Inline commands: `!{bash command}` for shell operations, `@path/to/file` for file reads
- Agent invocation when complex autonomous work is needed

### Agents

Agents are markdown files in `plugins/<name>/agents/*.md` that define autonomous workflows.

**When to Use Agents**:
- Complex multi-step operations requiring autonomous decision-making
- Operations that need to adapt based on discovered context
- Tasks that benefit from specialized expertise (e.g., stack-detector, task-layering)

**Agent Types**:
- **stack-detector** (foundation): Analyzes codebases to detect frameworks, languages, databases
- **task-layering** (iterate): Transforms sequential tasks into parallel-capable layers with agent assignments
- **spec-writer** (planning): Creates comprehensive feature specifications
- **test-generator** (quality): Generates test suites based on implementations
- **deployment-detector** (deployment): Auto-detects project type and routes to appropriate platform

### Skills

Skills provide progressive disclosure of detailed knowledge through:
- `SKILL.md` - Core instructions and patterns
- `scripts/` - Executable automation (bash, python, etc.)
- `templates/` - Reusable code/config templates
- `examples/` - Real-world usage examples

**Important Skills**:
- **project-detection** (foundation): Framework and tech stack detection patterns
- **task-management** (iterate): Task layering and parallel execution strategies
- **newman-testing** (quality): Newman/Postman API testing patterns
- **playwright-e2e** (quality): Playwright E2E testing patterns
- **platform-detection** (deployment): Project type detection for deployment routing

## 🚨 CRITICAL: Always Use Slash Commands to Build Components

**NEVER manually create agents, commands, or skills files using Write tool.**

**ALWAYS use the domain-plugin-builder slash commands:**

### Creating Agents
```bash
# Single agent
/domain-plugin-builder:agents-create agent-name "description"

# Multiple agents (parallel creation for 3+)
/domain-plugin-builder:agents-create agent-1 "desc-1" agent-2 "desc-2" agent-3 "desc-3"
```

### Creating Commands
```bash
# Single command
/domain-plugin-builder:slash-commands-create command-name "description"

# Multiple commands (parallel creation for 3+)
/domain-plugin-builder:slash-commands-create cmd-1 "desc-1" cmd-2 "desc-2" cmd-3 "desc-3"
```

### Creating Skills
```bash
# Analyze plugin and create skills
/domain-plugin-builder:skills-create --analyze plugin-name

# Create specific skills
/domain-plugin-builder:skills-create skill-name "description"
```

**Why This Matters:**
- Slash commands use validated templates
- Automatic line count validation (agents <300 lines, commands <172 lines)
- Proper frontmatter structure (name, description, model, color)
- Framework compliance checks
- Automatic git commits with proper attribution
- Consistent quality across all components

**Exception:** Only manually edit files when FIXING existing components, not creating new ones.

---

## 🚨 CRITICAL DEVELOPMENT RULE: Always Spec → Layer → Build

**NEVER build features without creating specs and layering tasks first.**

### The Required Process:

```bash
# 1. User says: "The frontend needs improvement"

# ❌ WRONG - Don't do this:
/nextjs-frontend:add-component Button  # Random creation = technical debt

# ✅ CORRECT - Always do this:

# Step 1: Create a spec (new feature or enhancement)
/planning:add-feature "Improve frontend UX with design system"
# OR if modifying existing:
/planning:update-feature F001 "Add design system improvements"

# Step 2: Layer the tasks
/iterate:tasks F001
# Creates: specs/F001/layered-tasks.md
# L0: Infrastructure (theme, design tokens)
# L1: Core components (Button, Card, Input)
# L2: Feature components (ChatWindow, Dashboard)
# L3: Integration (wire everything together)

# Step 3: Build layer by layer
# L0 first:
/nextjs-frontend:add-component ThemeProvider

# L1 second:
/nextjs-frontend:add-component Button
/nextjs-frontend:add-component Card

# L2 third:
/nextjs-frontend:add-component ChatWindow

# L3 fourth:
/nextjs-frontend:add-page chat

# Step 4: Sync after each layer
/iterate:sync F001
```

### Why This Matters:

**Without this process:**
- Components created randomly
- Missing dependencies
- Duplicate code
- No clear architecture
- Technical debt accumulates

**With this process:**
- Structured development
- Clear dependencies
- Reusable components
- Clean architecture
- Trackable progress

**This applies to ALL changes:**
- New features → `/planning:add-feature` → `/iterate:tasks`
- Enhancements → `/iterate:enhance` → `/iterate:tasks`
- Refactoring → `/iterate:refactor` → `/iterate:tasks`
- Bug fixes → Create spec if complex, otherwise proceed directly

---

## Common Development Tasks

### Working on Plugin Commands

```bash
# Create a new command (REQUIRED)
/domain-plugin-builder:slash-commands-create validate-tasks "Validate task completion status"

# Edit existing command (allowed)
vim plugins/<plugin-name>/commands/<command-name>.md

# Test a command
/quality:validate-tasks spec-001
```

**Command Development Guidelines**:
- Use phase-based structure (Discovery → Analysis → Planning → Implementation → Verification → Summary)
- Include clear goal statements for each phase
- Use inline commands for simple operations
- Invoke agents for complex autonomous work
- Always provide helpful user feedback in Summary phase

### Working on Agents

```bash
# Create a new agent (REQUIRED)
/domain-plugin-builder:agents-create task-validator "Validate tasks against implementation"

# Edit existing agent (allowed)
vim plugins/<plugin-name>/agents/<agent-name>.md
```

```bash
# Edit an agent
vim plugins/<plugin-name>/agents/<agent-name>.md

# Test an agent through a command that invokes it
/foundation:detect    # Invokes stack-detector agent
/iterate:tasks        # Invokes task-layering agent
```

**Agent Development Guidelines**:
- Agents should be fully autonomous - no user interaction during execution
- Provide clear success/failure indicators
- Return comprehensive results to the invoking command
- Use appropriate tool restrictions in frontmatter

### Working on Skills

```bash
# Navigate to a skill
cd plugins/<plugin-name>/skills/<skill-name>/

# Structure:
# SKILL.md           - Instructions and patterns
# scripts/           - Automation scripts
# templates/         - Reusable templates
# examples/          - Usage examples

# Skills are auto-loaded by Claude when their description matches user intent
```

**Skill Development Guidelines**:
- Write clear, comprehensive documentation in SKILL.md
- Provide working scripts with clear comments
- Include templates for common use cases
- Add realistic examples showing end-to-end workflows
- Test auto-loading by matching description keywords

### Testing Changes

```bash
# Test plugin metadata is valid
cat plugins/<plugin-name>/.claude-plugin/plugin.json | jq .

# List all commands in a plugin
ls plugins/<plugin-name>/commands/

# Verify plugin structure
ls -la plugins/<plugin-name>/

# Test command execution
/planning:spec "test feature"
```

### Git Workflow

```bash
# Check status
git status

# Create meaningful commits
git commit -m "feat(iterate): Enhance task-layering agent with dependency analysis"

# Common commit prefixes:
# feat(<plugin>): New feature
# fix(<plugin>): Bug fix
# docs(<plugin>): Documentation changes
# refactor(<plugin>): Code refactoring
# test(<plugin>): Testing changes
```

## Important Conventions

### File Deletion Safety

**CRITICAL**: Always use `trash-put` instead of `rm` for file deletion (per global CLAUDE.md):
```bash
# ✅ CORRECT
trash-put old-file.txt

# ❌ NEVER USE
rm old-file.txt
```

### Plugin Naming

- Plugin names are lowercase, hyphenated (e.g., `foundation`, `iterate`)
- NO numbered prefixes (v1.x had 01-, 02-, etc. - now removed)
- Commands use colon syntax: `/plugin-name:command-name`

### Backward Compatibility

**Migration from v1.x**:
- `01-core` → `foundation`
- `02-develop` → Removed (use tech-specific plugins)
- `03-planning` → `planning` (unchanged)
- `04-iterate` → `iterate` (unchanged)
- `05-quality` → `quality` (unchanged)
- `06-deployment` → `deployment` (unchanged)

See MIGRATION.md for complete migration guide.

### Quality Plugin Standardization

The quality plugin uses **standardized testing frameworks**:
- **Newman/Postman**: API testing with collections
- **Playwright**: E2E browser testing
- **DigitalOcean**: Webhook testing infrastructure ($4-6/month)
- **Security scanning**: npm audit, safety, bandit, secret detection

Skills contain comprehensive documentation but require full implementation (scripts, templates, examples).

### Deployment Plugin Standardization

The deployment plugin uses **platform auto-detection**:
- **FastMCP Cloud**: MCP server hosting
- **Vercel**: Next.js/frontend deployments
- **Railway**: Backend/database deployments
- **DigitalOcean**: Full-stack hosting ($4-6/month)
- **Netlify/Cloudflare Pages**: Static site deployments

Projects are automatically routed to the appropriate platform.

## Development Philosophy

### Progressive Disclosure

Commands → Agents → Skills form a hierarchy of detail:
1. **Commands**: User-facing operations with clear workflows
2. **Agents**: Autonomous execution for complex tasks
3. **Skills**: Deep domain knowledge and reusable patterns

Users interact with commands. Commands invoke agents when needed. Agents leverage skills for specialized knowledge.

### Infrastructure First, Use Before Build

From task-layering principles:
1. **Infrastructure First**: Set up databases, APIs, auth before features
2. **Use Before Build**: Prefer existing libraries over custom code
3. **Complexity Stratification**: Group tasks by difficulty for appropriate agent assignment
4. **Parallel Execution**: Independent tasks run simultaneously

### Tech Stack Independence

These plugins detect and adapt to ANY tech stack:
- **Languages**: TypeScript, JavaScript, Python, Go, Rust, Java, etc.
- **Frontend**: React, Next.js, Vue, Svelte, Angular, etc.
- **Backend**: Express, FastAPI, Django, Rails, Go, etc.
- **Databases**: PostgreSQL, MongoDB, MySQL, Supabase, etc.

Tech-specific implementation is delegated to domain-specific plugins.

## Critical Agent: task-layering

The `task-layering` agent (iterate plugin) is preserved from the legacy system and is considered **critical infrastructure**. It:
- Transforms sequential task lists into parallel-capable layers
- Assigns tasks to appropriate agents based on complexity
- Creates stratified execution plans (Foundation → Infrastructure → Features → Integration)
- Generates `layered-tasks.md` with clear layer boundaries

**Do not remove or significantly modify** without extensive testing.

## Related Documentation

- **README.md**: User-facing documentation and quick start guide
- **MIGRATION.md**: Complete v1.x to v2.0 migration guide
- **REBUILD-SUMMARY.md**: Technical details of the v2.0 rebuild
- **.github/copilot-instructions.md**: Agent workflow and commit format guidelines
- Individual plugin READMEs: Plugin-specific documentation

## Typical Full Workflow

```bash
# 1. Foundation - Initialize and detect
/foundation:init my-project
/foundation:detect
/foundation:generate-workflow "AI Tech Stack 1"  # Infrastructure setup workflow

# 2. Planning - Create specifications
/planning:add-feature "user authentication"
/planning:architecture
/planning:generate-feature-workflow  # Feature implementation workflow

# 3. Implementation - Execute features automatically
/iterate:tasks F001  # Layer tasks for parallel execution
/implementation:execute F001  # Auto-map and execute all commands

# 4. Iterate - Adjust and enhance
/iterate:adjust "Add error handling to auth"
/iterate:sync F001  # Sync implementation with specs

# 5. Quality - Validate code
/quality:validate-code F001
/quality:security

# 6. Testing - Execute test suites
/testing:test F001
/testing:test-frontend

# 7. Deployment - Deploy to production
/deployment:deploy
```

## Plugin Component Summary

| Plugin | Commands | Agents | Skills | Total |
|--------|----------|--------|--------|-------|
| foundation | 4 | 1 | 3 | 8 |
| planning | 5 | 4 | 4 | 13 |
| implementation | 5 | 4 | 3 | 12 |
| iterate | 3 | 4 | 1 | 8 |
| quality | 3 | 4 | 2 | 9 |
| testing | 3 | 3 | 5 | 11 |
| deployment | 4 | 3 | 3 | 10 |
| **TOTAL** | **27** | **23** | **21** | **71** |

## Architecture Decisions

### Why 7 Plugins Instead of Monolithic?

- **Modularity**: Users can use only the lifecycle phases they need
- **Maintainability**: Each plugin has clear boundaries and responsibilities
- **Extensibility**: New lifecycle phases can be added without affecting existing ones
- **Independence**: Plugins work standalone or together as a cohesive workflow

### Why Remove 02-develop?

The `develop` plugin was removed in v2.0 because:
- Code generation is inherently tech-specific (not agnostic)
- Better handled by domain plugins (nextjs-frontend, fastmcp, etc.)
- Functionality distributed to foundation (initialization) and iterate (adjustments)
- Maintains strict separation between workflow (lifecycle) and implementation (domain)

### Why Standardize Testing?

Quality plugin standardizes on Newman/Postman (API) and Playwright (E2E) because:
- Eliminates testing framework fragmentation
- Provides consistent patterns across all projects
- Enables reusable skills, scripts, and templates
- Industry-standard tools with excellent documentation
- DigitalOcean integration enables cost-effective webhook testing ($4-6/month)

### Why Platform Auto-Detection?

Deployment plugin auto-detects platforms because:
- Eliminates manual configuration for standard project types
- Routes FastMCP servers, Next.js apps, backends to appropriate platforms
- Provides fallback options for flexibility
- Reduces deployment complexity for common scenarios

## Version Control

**Current Version**: 2.0.0 (October 2025)

**Versioning Strategy**:
- Each plugin has independent version in `.claude-plugin/plugin.json`
- Marketplace has overall version in root metadata
- Breaking changes increment major version
- New features increment minor version
- Bug fixes increment patch version

## License

MIT License - See LICENSE file for details

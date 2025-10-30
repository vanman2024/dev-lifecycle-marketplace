# Iterate Plugin

Task breakdown, layering, and iteration workflow management with parallel multi-agent execution.

## Overview

The iterate plugin transforms sequential task lists into stratified layers optimized for parallel execution. It's the core workflow engine that enables multi-agent development with intelligent task distribution based on complexity, dependencies, and agent capabilities.

## Commands

### `/iterate:tasks` - Task Layering

Transform sequential tasks.md into layered-tasks.md with parallel agent assignments.

**Usage:**
```bash
# Layer tasks for a spec
/iterate:tasks 001

# List available specs
/iterate:tasks
```

**What it does:**
1. Loads tasks from `specs/XXX/tasks.md`
2. Analyzes task complexity and dependencies
3. Stratifies into layers (Foundation → Infrastructure → Features → Integration)
4. Assigns tasks to agents based on complexity
5. Creates `specs/XXX/agent-tasks/layered-tasks.md`
6. Generates agent assignment summary

**Output:**
- `specs/XXX/agent-tasks/layered-tasks.md` - Stratified task layers
- `specs/XXX/agent-tasks/AGENTS.md` - Agent assignment summary

**Layering Principles:**
- **Infrastructure First** - Models, HTTP clients, auth before features
- **Use Before Build** - Prefer libraries (httpx, tenacity) over custom code
- **Complexity Stratification** - Trivial (0) → Simple (1) → Moderate (2) → Complex (3)
- **Parallel Execution** - Independent tasks run simultaneously

---

### `/iterate:adjust` - Implementation Adjustment

Adjust implementation based on feedback or requirements change.

**Usage:**
```bash
# Adjust specific file
/iterate:adjust src/api/users.ts

# Adjust feature
/iterate:adjust "authentication flow"

# Interactive mode
/iterate:adjust
```

**What it does:**
1. Identifies files/features to adjust
2. Analyzes current implementation
3. Makes targeted changes preserving existing functionality
4. Updates tests and documentation
5. Verifies changes don't break build

**Use cases:**
- User feedback incorporation
- Requirement changes
- Bug fixes
- Code improvements

---

### `/iterate:sync` - Documentation Sync

Sync project state - update specs, tasks, and docs based on implementation.

**Usage:**
```bash
/iterate:sync
```

**What it does:**
1. Identifies completed features vs spec status
2. Updates spec statuses (pending → in-progress → completed)
3. Marks completed tasks in layered-tasks.md
4. Refreshes architecture documentation
5. Creates missing ADRs for undocumented decisions

**Prevents:**
- Documentation drift
- Stale task lists
- Out-of-sync specs
- Missing decision records

---

## Agents

### task-layering (91 lines)
Stratifies tasks by complexity, identifies dependencies, and creates layered execution plan.

**Preserved from original**: This is the critical task-layering agent with 600+ lines of supporting documentation.

**Capabilities:**
- Infrastructure-first ordering
- Use-before-build library preference
- Complexity-based stratification (0-3 scale)
- Dependency analysis
- Agent assignment by capability

**Layering Strategy:**
```
Layer 1 (Foundation):
  - Models, schemas, types
  - HTTP client base
  - Authentication protocols

Layer 2 (Infrastructure):
  - Retry logic, rate limiting
  - State management, caching
  - Database connections

Layer 3 (Adapters):
  - API adapters
  - Auth implementations
  - Integration wrappers

Layer 4 (Features):
  - MCP tools, CLI commands
  - API endpoints, UI components
  - Business logic

Layer 5 (Integration):
  - E2E workflows
  - Testing, documentation
```

---

### implementation-adjuster (187 lines)
Makes targeted code adjustments based on feedback while preserving functionality.

**Capabilities:**
- Surgical code changes
- Impact analysis
- Test-driven adjustments
- Documentation sync

**Decision Framework:**
- **Single file**: Edit tool, precise changes
- **Multiple files**: Coordinated updates
- **Breaking changes**: Migration paths
- **Feature flags**: Gradual rollout

---

### code-refactorer (131 lines)
Improves code quality and structure without changing functionality.

**Capabilities:**
- Remove duplication (DRY)
- Improve naming
- Simplify complex logic
- Extract reusable patterns
- Reduce cognitive complexity

**Refactoring Patterns:**
- Extract Function/Variable
- Rename for clarity
- Inline unnecessary indirection
- Move to better organization

---

### feature-enhancer (132 lines)
Enhances existing features with performance, UX, and accessibility improvements.

**Capabilities:**
- Performance optimization
- UX enhancements
- Edge case handling
- Accessibility improvements

**Enhancement Types:**
- **Performance**: Caching, lazy loading, algorithm optimization
- **UX**: Loading states, error messages, keyboard shortcuts
- **Robustness**: Input validation, error handling, retry logic
- **Accessibility**: ARIA labels, keyboard nav, screen reader support

---

## Skills

### task-layering
Complete task stratification system with principles documentation.

**Documentation:**
- `task-layering.md` - 600+ lines of layering principles
- Infrastructure First principle
- Use Before Build decision framework
- Critical path blocking analysis
- Library selection guidelines

**Key Concepts:**
```
Infrastructure First:
  Models → HTTP client → Adapters → Tools

Use Before Build:
  httpx > custom HTTP
  tenacity > custom retry
  FastMCP > custom MCP
  SQLAlchemy > custom ORM
```

---

### task-stratification
Scripts and templates for task complexity analysis and stratification.

**Scripts:**
- `analyze-complexity.sh` - Calculate task complexity scores
- `identify-dependencies.sh` - Map task dependencies
- `stratify-layers.sh` - Create layer structure
- `assign-agents.sh` - Distribute tasks to agents

**Templates:**
- Complexity rating guide (0-3 scale)
- Dependency mapping format
- Layer structure template
- Agent assignment matrix

---

### iteration-tracking
Tools for tracking iteration progress and managing workflow state.

**Scripts:**
- `track-progress.sh` - Update task completion status
- `sync-specs.sh` - Synchronize specs with implementation
- `generate-report.sh` - Create progress reports
- `update-roadmap.sh` - Refresh roadmap completion

**Templates:**
- Progress tracking format
- Status update templates
- Completion reports
- Roadmap sync structure

---

### code-refinement
Patterns and examples for code quality improvements.

**Templates:**
- Refactoring patterns library
- Code smell detection
- Naming conventions
- Complexity reduction techniques

**Examples:**
- Before/after refactoring examples
- Performance optimization samples
- UX enhancement patterns
- Accessibility implementation guides

---

## Integration

### With Foundation Plugin
- Uses detected tech stack from `/foundation:detect`
- Adapts task layering to project structure
- References `.claude/project.json` for context

### With Planning Plugin
- Specs from `/planning:spec` feed into task layering
- Architecture from `/planning:architecture` informs complexity
- ADRs from `/planning:decide` guide decisions

### With Quality Plugin
- Test requirements guide task verification
- Performance benchmarks inform enhancements
- Security checks validate adjustments

### With Deployment Plugin
- Deployment tasks in integration layer
- Platform detection influences implementation
- CI/CD integration validates changes

---

## Workflow Example

```bash
# 1. Create spec with tasks
/planning:spec create "User Authentication"

# 2. Layer tasks for parallel execution
/iterate:tasks 001

# 3. Review layered task structure
cat specs/001-user-auth/agent-tasks/layered-tasks.md

# 4. Execute tasks in parallel (agents work on assigned layers)
# Layer 1: Foundation tasks (models, types)
# Layer 2: Infrastructure tasks (HTTP, auth protocols)
# Layer 3: Feature tasks (login, signup, password reset)

# 5. Adjust based on feedback
/iterate:adjust "add 2FA support to authentication"

# 6. Enhance with improvements
# (feature-enhancer adds loading states, error handling, accessibility)

# 7. Refactor for quality
# (code-refactorer removes duplication, improves naming)

# 8. Sync documentation
/iterate:sync
```

---

## Task Layering Example

**Input (`specs/001/tasks.md`):**
```
- Implement user login
- Create user model
- Add password reset
- Setup HTTP client
- Implement OAuth flow
- Add login UI
```

**Output (`specs/001/agent-tasks/layered-tasks.md`):**
```
## Layer 1: Foundation (Parallel Execution)
- T001: Create user model (Complexity: 1, Agent: @copilot)
- T002: Setup HTTP client (Use httpx) (Complexity: 1, Agent: @copilot)

## Layer 2: Infrastructure (After Layer 1)
- T003: Implement OAuth protocol (Complexity: 2, Agent: @claude)
- T004: Setup password reset tokens (Complexity: 1, Agent: @copilot)

## Layer 3: Features (After Layer 2)
- T005: Implement user login (Complexity: 2, Agent: @claude)
- T006: Implement password reset flow (Complexity: 2, Agent: @claude)

## Layer 4: Integration (After Layer 3)
- T007: Add login UI (Complexity: 2, Agent: @gemini)
- T008: E2E auth testing (Complexity: 2, Agent: @codex)
```

---

## Best Practices

### Task Layering
- Always run `/iterate:tasks` after creating specs
- Review layered-tasks.md for dependency correctness
- Adjust agent assignments based on team capabilities
- Re-layer when requirements change significantly

### Iteration Workflow
- Make small, incremental adjustments
- Run tests after each adjustment
- Sync documentation regularly
- Refactor before adding complex features

### Parallel Execution
- Execute entire layers in parallel
- Wait for layer completion before next layer
- Track progress per agent
- Merge changes carefully to avoid conflicts

---

## Directory Structure

```
specs/
├── 001-feature-name/
│   ├── README.md                    # Feature specification
│   ├── tasks.md                     # Sequential task list
│   └── agent-tasks/                 # Layered execution plan
│       ├── layered-tasks.md         # Stratified task layers
│       ├── AGENTS.md                # Agent assignment summary
│       └── progress.md              # Completion tracking
```

---

## Version

- **Version:** 1.0.0
- **Status:** Production-ready
- **Last Updated:** 2024-01-15
- **Critical Component:** task-layering agent and principles preserved from original

---

## Notes

The iterate plugin is the workflow engine of dev-lifecycle-marketplace. The task-layering system (600+ lines of docs, complex scripts) has been carefully preserved from the original implementation and is the foundation for parallel multi-agent development workflows.

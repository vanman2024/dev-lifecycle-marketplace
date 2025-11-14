# Workflow Generation Skill

**Purpose**: Provide deep knowledge about organizing software development commands into phased workflows for parallel execution and clear dependency management.

---

## Core Concepts

### The Phase-Based Execution Model

**Philosophy**: Software development commands should be organized into **distinct phases** that can be:
- Executed in **separate terminal sessions** (fresh context)
- Run in **parallel** where dependencies allow
- Used as **clear checkpoints** in the development process

**Why Phases Matter**:
1. **Avoid context contamination** - Each terminal starts fresh
2. **Enable parallel work** - Multiple developers or instances
3. **Create natural checkpoints** - Complete one phase before next
4. **Facilitate rollback** - Easy to return to phase boundaries

---

## Phase Organization Patterns

### Standard Dev Lifecycle Phases

**Phase 1: Foundation** (Always first, no dependencies)
- Purpose: Set up project structure and environment
- Typical commands:
  - Project initialization
  - Directory structure creation
  - Environment detection/validation
  - Repository initialization
  - Secret management setup
  - Tool installation verification

**Phase 2: Planning** (Requires: Foundation complete)
- Purpose: Define what to build before building it
- Typical commands:
  - Requirements gathering
  - Spec creation
  - Architecture design
  - Decision documentation (ADRs)
  - Roadmap creation
  - Database schema design

**Phase 3: Implementation** (Requires: Planning + Foundation)
- Purpose: Build the actual features
- Typical commands:
  - Task layering
  - Component creation
  - Feature development
  - Integration setup
  - Data model implementation
- Sub-phases:
  - L0: Infrastructure (databases, APIs, auth)
  - L1: Core components (shared libraries)
  - L2: Features (business logic)
  - L3: Integration (wiring everything together)

**Phase 4: Quality** (Can run parallel with late Implementation)
- Purpose: Validate what was built
- Typical commands:
  - Test suite generation
  - Security scanning
  - Code validation
  - Performance analysis
  - Accessibility testing

**Phase 5: Deployment** (Requires: Quality passed)
- Purpose: Ship to production
- Typical commands:
  - Platform detection
  - Pre-flight checks
  - CI/CD setup
  - Deployment execution
  - Health validation
  - Monitoring setup

**Phase 6: Iteration** (Ongoing, throughout process)
- Purpose: Improve and refine
- Typical commands:
  - Feature enhancement
  - Code refactoring
  - Spec synchronization
  - Feedback integration

---

## Command Classification Patterns

### How to Categorize Commands

**Foundation Indicators**:
- Keywords: `init`, `setup`, `detect`, `validate`, `env`, `structure`
- Actions: Creates directories, validates tools, sets up environment
- Examples: `/foundation:init-structure`, `/foundation:env-check`

**Planning Indicators**:
- Keywords: `wizard`, `spec`, `architecture`, `decide`, `roadmap`, `plan`
- Actions: Creates documentation, designs systems, documents decisions
- Examples: `/planning:wizard`, `/planning:architecture`

**Implementation Indicators**:
- Keywords: `add`, `create`, `integrate`, `build`, `generate`
- Actions: Creates code, components, features
- Examples: `/nextjs-frontend:add-component`, `/fastapi-backend:add-endpoint`

**Quality Indicators**:
- Keywords: `test`, `validate`, `security`, `performance`, `quality`
- Actions: Runs tests, scans for issues, validates code
- Examples: `/testing:test`, `/quality:validate-code`

**Deployment Indicators**:
- Keywords: `deploy`, `prepare`, `cicd`, `validate`, `monitor`
- Actions: Deploys to platforms, sets up pipelines, validates deployment
- Examples: `/deployment:deploy`, `/deployment:prepare`

**Iteration Indicators**:
- Keywords: `enhance`, `refactor`, `adjust`, `sync`, `improve`
- Actions: Improves existing code, syncs documentation
- Examples: `/iterate:enhance`, `/iterate:refactor`

---

## Phase Dependency Rules

### Strict Dependencies (MUST follow order)

```
Foundation → Planning → Implementation → Quality → Deployment
```

- Foundation has **no dependencies** (always first)
- Planning **requires Foundation** complete
- Implementation **requires Planning + Foundation**
- Quality **requires Implementation** (at least partially)
- Deployment **requires Quality** passed
- Iteration can happen **throughout** (but often after initial implementation)

### Parallel Execution Opportunities

**Within Foundation**:
- Environment checks can run parallel with structure validation
- Secret management can run parallel with repository init

**Within Implementation**:
- Frontend and backend can be built in parallel
- Different features can be built simultaneously (if independent)

**Quality and Late Implementation**:
- Tests can be written while final features are being implemented
- Security scanning can run on completed components

---

## Project Context Reading Patterns

### What to Read (In Order)

1. **`.claude/project.json`** (MUST READ FIRST)
   - Tech stack information
   - Framework versions
   - Architecture pattern
   - Deployment targets

2. **`docs/architecture/`** (If exists)
   - System design
   - Component diagrams
   - Data flow
   - Integration points

3. **`docs/adr/`** (If exists)
   - Architecture decisions
   - Decision rationale
   - Trade-offs made
   - Migration plans

4. **`specs/`** (If exists)
   - Feature specifications
   - Requirements
   - Task breakdowns

5. **Current file state** (File existence checks)
   - What's already implemented
   - What's missing
   - Completion status

### How to Use Context

**From project.json:**
- Extract tech stack (determines which implementation commands to include)
- Understand architecture pattern (monolithic vs microservices affects phasing)
- Identify deployment targets (determines deployment commands)

**From ADRs:**
- Understand WHY decisions were made
- Include relevant context in workflow
- Respect architectural patterns chosen

**From architecture docs:**
- Understand system design
- Include in workflow overview
- Guide implementation phase organization

**From specs:**
- Know what features exist
- Understand current state
- Determine what still needs building

**From file existence:**
- Mark commands as ✅ (done) if files exist
- Mark as □ (todo) if files missing
- Show progress through workflow

---

## Workflow Document Structure

### Recommended Sections

1. **Project Overview**
   - Tech stack summary (from project.json)
   - Architecture pattern (from ADRs)
   - Current status (from file checks)

2. **Phased Commands**
   - One section per phase
   - Clear phase boundaries
   - Commands grouped logically
   - Dependencies noted

3. **Progress Indicators**
   - ✅ = Already done (auto-detected)
   - □ = Still to do
   - 🔄 = In progress (partial implementation)

4. **Project-Specific Context**
   - Relevant ADR summaries
   - Architecture highlights
   - Business metrics (if applicable)

5. **Next Steps**
   - What to run next
   - What's blocking progress
   - How to regenerate workflow

---

## Examples from Real Projects

### Example: AI Education Platform (Monolithic MVP)

**Context from ADRs**:
- ADR 0006: Start monolithic, migrate to microservices later
- Trigger: >5,000 students or >30 sec AI response times

**Phase Organization**:
```
Phase 1: Foundation
- /foundation:init-structure
- /foundation:github-init
- /foundation:doppler-setup

Phase 2: Planning
- /planning:wizard
- /planning:architecture
- /planning:decide

Phase 3: Implementation (Monolithic)
- /fastapi-backend:init (single service)
- /nextjs-frontend:init
- /supabase:init
- Implement study partner as embedded library (NOT microservice)

Phase 4-6: Standard (Quality, Deployment, Iteration)
```

**Key Insight**: Architecture decision (monolithic) directly affects implementation phase.

---

## Integration with Dan's Composition Pattern

### How This Skill Fits

```
Slash Command (/foundation:generate-workflow)
  ↓
  Loads THIS SKILL (knowledge about phasing)
  ↓
  Runs Python script (bulk Airtable query)
  ↓
  Uses skill knowledge to organize commands
  ↓
  Outputs workflow markdown
```

**This skill provides:**
- Phase organization knowledge
- Command classification patterns
- Dependency rules
- Project context patterns

**The slash command applies:**
- Reads project context
- Applies skill patterns
- Makes intelligent decisions
- Generates final workflow

**The Python script provides:**
- Raw Airtable data
- Command validation
- Bulk operations

---

## Best Practices

### Do's ✅

- **Always read project.json first** - It drives everything else
- **Respect architecture decisions** - ADRs guide phasing
- **Validate commands** - Check Airtable vs filesystem
- **Use file existence** - Auto-detect completion status
- **Clear phase boundaries** - Easy to execute in separate terminals
- **Include project context** - ADRs, architecture, business metrics

### Don'ts ❌

- **Don't hardcode phases in Python** - Intelligence belongs in slash command
- **Don't ignore ADRs** - They contain critical context
- **Don't assume command availability** - Always validate
- **Don't mix phase boundaries** - Keep them distinct
- **Don't generate static workflows** - Make them project-aware

---

## Validation Checklist

When generating a workflow, ensure:

- [ ] All commands from Airtable are validated against filesystem
- [ ] Warnings are displayed for mismatches
- [ ] Project context has been read (project.json, ADRs, etc.)
- [ ] Commands are organized into logical phases
- [ ] Phase dependencies are respected
- [ ] Completion status is auto-detected (✅/□/🔄)
- [ ] Project-specific context is included
- [ ] Workflow is ready for multi-terminal execution
- [ ] Regeneration command is included

---

## Regeneration Pattern

Always include regeneration command in output:

```bash
# To regenerate this workflow with latest Airtable data:
/foundation:generate-workflow "Your Tech Stack Name"
```

This allows users to:
- Update workflow when Airtable changes
- Refresh completion status
- Incorporate new commands
- Re-validate against filesystem

---

**This skill enables intelligent, project-aware workflow generation that respects architecture decisions and enables parallel execution.**

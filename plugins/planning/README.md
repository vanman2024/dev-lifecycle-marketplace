# Planning Plugin

Comprehensive planning, architecture design, and decision documentation for development projects.

## Overview

The planning plugin provides tools for creating specifications, designing architecture, documenting decisions, capturing notes, and building roadmaps. It works with any tech stack and integrates seamlessly with the dev-lifecycle-marketplace ecosystem.

---

## 🚀 NEW: Intelligent Multi-Agent Spec Generation

### The Problem: Duplicate Tables & Wrong Build Order

When generating multiple feature specs in parallel **without coordination**, you get disasters:

❌ **Agent 1** creates `users` table in `001-exam-system`
❌ **Agent 2** creates `users` table in `002-voice-companion` (DUPLICATE!)
❌ **Agent 3** tries to build `003` before `001` exists (WRONG ORDER!)

### The Solution: Entity Ownership Tracking

Our system uses **intelligent dependency analysis** to prevent duplicates and ensure correct build order:

✅ **Agent 1** creates `users` table in `001-exam-system` (OWNS it)
✅ **Agent 2** references `users` via FK → `001.users.id` (no duplicate)
✅ **Build phases** ensure `001` completes before `002` starts

### How It Works

```
1. /planning:init-project "massive project description..."
   ↓
2. feature-analyzer agent breaks into features with dependencies
   ↓ (generates JSON with entity ownership)
   {
     "features": [
       {
         "number": "001",
         "buildPhase": 1,
         "sharedEntities": {
           "owns": ["User", "Exam"],
           "references": ["Trade"]
         }
       },
       {
         "number": "002",
         "buildPhase": 2,
         "sharedEntities": {
           "owns": ["VoiceSession"],
           "references": ["User", "Exam"]
         }
       }
     ]
   }
   ↓
3. Spawn N parallel spec-writer agents (all at once)
   ↓
4. Each agent creates spec.md/plan.md/tasks.md
   - For OWNED entities → CREATE TABLE
   - For REFERENCED entities → FK only, NEVER recreate
   ↓
5. Generate 000-project-overview with build phases
   ↓
6. Consolidate to .planning/project-specs.json
```

### Build Phases

**Phase 1: Foundation** (build first)
- Features with no dependencies
- Own core data entities (User, Exam, Trade)
- Must complete before Phase 2

**Phase 2: Core** (build after Phase 1)
- Features that depend on Phase 1
- Reference Phase 1 entities via FK
- Cannot start until Phase 1 done

**Phase 3: Integration** (build last)
- Connect multiple Phase 1/2 features
- Final integration layer

### Example Output

```
specs/
├── 000-project-overview/
│   └── README.md (build phases, dependency graph, critical path)
├── 001-exam-system/        [Phase 1: OWNS User, Exam]
│   ├── spec.md
│   ├── plan.md
│   └── tasks.md
├── 002-voice-companion/    [Phase 2: REFERENCES User, Exam]
│   ├── spec.md
│   ├── plan.md
│   └── tasks.md
└── 003-trade-library/      [Phase 1: OWNS Trade]
    ├── spec.md
    ├── plan.md
    └── tasks.md
```

### New Commands

#### `/planning:init-project <project-description>`
**Create ALL specs in one shot from massive description**

Spawns N parallel agents, each creates spec/plan/tasks for one feature. Prevents duplicate tables with entity ownership tracking.

**Example:**
```bash
/planning:init-project "Red Seal AI: Exam prep platform with voice companion, mentorship, and payments. Tech stack: Next.js 15, FastAPI, Supabase."
```

#### `/planning:add-spec <feature-description>`
**Add single spec to existing project**

Auto-detects next spec number, maintains consistency with existing specs.

**Example:**
```bash
/planning:add-spec "Employer portal for hiring apprentices"
```

#### `/planning:analyze-project`
**Analyze existing specs for completeness**

Spawns N parallel spec-analyzer agents, generates gap analysis.

**Example:**
```bash
/planning:analyze-project
```

### New Agents

#### `feature-analyzer`
Breaks massive project description into features with **entity ownership detection**. Assigns build phases (1=Foundation, 2=Core, 3=Integration). Outputs JSON with dependency graph.

#### `spec-writer` (enhanced)
Creates spec/plan/tasks for ONE feature. **Respects entity ownership boundaries** - never recreates tables owned by other specs. Uses FK for referenced entities.

#### `spec-analyzer`
Analyzes existing spec for completeness, quality issues, implementation gaps.

### Key Files

**Templates:**
- `spec-simple-template.md` - Tech-agnostic user requirements
- `plan-template.md` - Technical design with DB schema (OWNED vs REFERENCED sections)
- `tasks-template.md` - Implementation tasks (5 phases, numbered)
- `project-overview-template.md` - High-level project view with build phases

**Scripts:**
- `generate-json-output.sh` - Format spec as JSON
- `consolidate-specs.sh` - Merge all specs into .planning/project-specs.json

---

## Commands

### `/planning:spec` - Specification Management

Create, list, validate, and manage feature specifications in the `specs/` directory.

**Usage:**
```bash
# Create new specification
/planning:spec create "User Authentication System"

# List all specifications
/planning:spec list

# Validate specification completeness
/planning:spec validate 001

# Show specification details
/planning:spec show 001
```

**Actions:**
- `create` - Create new numbered specification with template
- `list` - List all specifications with status
- `validate` - Check specification completeness
- `show` - Display specification content

**Output:**
- Numbered spec directories: `specs/001-feature-name/`
- Comprehensive README.md with all sections
- Metadata tracking (status, dates, tags)

---

### `/planning:architecture` - Architecture Design

Design and document system architecture including diagrams, data flows, and technical specifications.

**Usage:**
```bash
# Design complete architecture
/planning:architecture design

# Create specific diagram
/planning:architecture diagram component

# Update existing architecture
/planning:architecture update

# Review architecture documentation
/planning:architecture review
```

**Actions:**
- `design` - Create comprehensive architecture documentation
- `diagram` - Generate specific diagram type
- `update` - Add new sections to architecture
- `review` - Validate architecture completeness

**Output:**
- Architecture documentation in `docs/architecture/`
- Component, data flow, deployment diagrams (mermaid)
- Technology stack alignment
- Security and scalability specifications

---

### `/planning:decide` - Architecture Decision Records

Document architectural decisions as ADRs with proper numbering and context.

**Usage:**
```bash
# Create new ADR
/planning:decide "Use PostgreSQL for Database"

# Supersede existing ADR
/planning:decide supersede 0001 "Migrate to Supabase"
```

**Output:**
- Numbered ADR files: `docs/adr/0001-decision-title.md`
- Michael Nygard ADR format
- Immutable decision records
- ADR index with status tracking

**Sections:**
- Context and problem statement
- Decision made
- Alternatives considered
- Consequences (pros and cons)
- References to related docs

---

### `/planning:notes` - Development Notes

Capture technical notes, decisions, learnings, and development journal entries.

**Usage:**
```bash
# Create new note
/planning:notes "Performance optimization findings"

# Search notes
/planning:notes search "database"

# List recent notes
/planning:notes list
```

**Actions:**
- `create` - Create timestamped note
- `search` - Search note content
- `list` - List all notes

**Output:**
- Timestamped notes: `docs/notes/YYYY-MM-DD-topic.md`
- Searchable markdown files
- Quick capture and retrieval

---

### `/planning:roadmap` - Project Roadmap

Create development roadmap with milestones, phases, timelines, and gantt charts.

**Usage:**
```bash
# Create quarterly roadmap
/planning:roadmap quarterly

# Create annual roadmap
/planning:roadmap annual

# Create release-based roadmap
/planning:roadmap release
```

**Timeframes:**
- `quarterly` - 3-month planning cycles
- `annual` - Yearly planning
- `release` - Feature-driven milestones
- Custom timeframe (e.g., "6-months")

**Output:**
- Comprehensive roadmap: `docs/ROADMAP.md`
- Mermaid gantt charts
- Phased development plan
- Risk assessment and dependencies

---

## Agents

### spec-writer
Creates, validates, and manages feature specifications following standardized templates.

**Capabilities:**
- Generate complete specifications with all sections
- Validate spec completeness
- List and search specifications
- Update spec status

**Tools:** Read, Write, Bash, Glob, Grep

---

### architecture-designer
Designs comprehensive system architecture with diagrams and technical documentation.

**Capabilities:**
- Create architecture documentation
- Generate mermaid diagrams (component, data flow, deployment)
- Adapt to detected tech stack
- Document security and scalability

**Tools:** Read, Write, Bash, Glob, Grep

---

### decision-documenter
Creates and manages Architecture Decision Records (ADRs) with proper numbering.

**Capabilities:**
- Create ADRs following Michael Nygard format
- Automatic sequential numbering
- Superseding workflow
- ADR index maintenance

**Tools:** Read, Write, Bash, Glob, Grep

---

### roadmap-planner
Creates project roadmaps with milestones, phases, and visual timelines.

**Capabilities:**
- Design phased development plans
- Estimate timelines based on complexity
- Identify dependencies and critical path
- Generate mermaid gantt charts

**Tools:** Read, Write, Bash, Glob, Grep

---

## Skills

### spec-management
Templates, scripts, and examples for managing specifications.

**Scripts:**
- `create-spec.sh` - Create numbered specs
- `list-specs.sh` - List with filtering
- `validate-spec.sh` - Check completeness
- `update-status.sh` - Status transitions
- `search-specs.sh` - Search content

**Templates:**
- Complete specification structure
- Metadata frontmatter
- Task breakdown format
- Requirements documentation
- Success criteria

**Examples:**
- Simple, complex, and AI feature specs
- Validation reports
- List outputs

---

### architecture-patterns
Architecture design templates and mermaid diagrams.

**Scripts:**
- `create-architecture.sh` - Scaffold docs
- `validate-mermaid.sh` - Check syntax
- `generate-diagrams.sh` - Create placeholders
- `update-architecture.sh` - Add sections
- `export-diagrams.sh` - Extract diagrams

**Templates:**
- Architecture overview
- Component, data flow, deployment diagrams
- API architecture
- Security architecture

**Examples:**
- Next.js, FastAPI, full stack architectures
- AI/RAG system architecture
- Microservices pattern

---

### decision-tracking
ADR templates and decision documentation patterns.

**Scripts:**
- `create-adr.sh` - Auto-numbered ADRs
- `list-adrs.sh` - List with status
- `search-adrs.sh` - Search content
- `update-adr-index.sh` - Maintain index
- `supersede-adr.sh` - Superseding workflow

**Templates:**
- Michael Nygard ADR format
- Decision matrix
- Consequences analysis
- ADR index structure

**Examples:**
- Technology, architecture, security decisions
- Superseded ADR workflow
- Complete ADR index

---

## Integration

### With Foundation Plugin
- Uses `detect` to understand tech stack
- Aligns architecture with detected frameworks
- References `.claude/project.json` for context

### With Iterate Plugin
- Specs feed into task layering
- Roadmap phases guide task assignment
- Architecture informs complexity estimates

### With Quality Plugin
- Specs define testing requirements
- Architecture guides test strategy
- ADRs document testing decisions

### With Deployment Plugin
- Architecture defines infrastructure needs
- Roadmap sets deployment milestones
- ADRs capture deployment decisions

---

## Workflow Example

```bash
# 1. Detect tech stack
/foundation:detect

# 2. Design architecture
/planning:architecture design

# 3. Document key decisions
/planning:decide "Use Next.js App Router"
/planning:decide "Use Supabase for Database"

# 4. Create feature specs
/planning:spec create "User Authentication"
/planning:spec create "Dashboard with Analytics"

# 5. Build roadmap
/planning:roadmap quarterly

# 6. Break into tasks (iterate plugin)
/iterate:tasks 001  # User Authentication spec

# 7. Capture learnings
/planning:notes "Authentication implementation insights"
```

---

## Directory Structure

```
project-root/
├── specs/                          # Feature specifications
│   ├── 001-user-auth/
│   │   └── README.md
│   ├── 002-dashboard/
│   │   └── README.md
│   └── ...
├── docs/
│   ├── architecture/              # Architecture documentation
│   │   ├── README.md
│   │   ├── components.md
│   │   ├── data-model.md
│   │   ├── api-spec.md
│   │   └── security.md
│   ├── adr/                       # Architecture Decision Records
│   │   ├── README.md
│   │   ├── 0001-use-nextjs.md
│   │   ├── 0002-use-supabase.md
│   │   └── ...
│   ├── notes/                     # Development notes
│   │   ├── 2024-01-15-performance.md
│   │   └── ...
│   └── ROADMAP.md                 # Project roadmap
└── .claude/
    └── project.json               # Detected tech stack
```

---

## Best Practices

### Specifications
- Create specs before implementation
- Validate completeness before starting work
- Update status as features progress
- Reference architecture and ADRs

### Architecture
- Design architecture early in project
- Update as system evolves
- Include diagrams for clarity
- Document security and scalability

### Decisions
- Document all significant decisions
- Consider alternatives thoroughly
- ADRs are immutable - create new ones to supersede
- Link related ADRs

### Roadmap
- Base estimates on actual complexity
- Include buffer time (15-20%)
- Identify critical path
- Update as priorities change

---

## Version

- **Version:** 1.0.0
- **Status:** Production-ready
- **Last Updated:** 2024-01-15

# Agent Patterns

This document defines standardized agent patterns for the dev-lifecycle-marketplace. Following these patterns ensures consistent, efficient, and maintaiable command workflows.

---

## Core Principle

**Agents are composable primitives. Commands orchestrate agents. Skills provide domain knowledge.**

---

## Agent Patterns

### 1. Single-Agent Pattern (Simple Work)

**When to use:**
- Simple, focused operations
- Single file or component creation
- Straightforward execution with minimal analysis
- Quick operations (<2 minutes)

**Examples:**
- `/planning:spec create` - Create one feature spec
- `/foundation:env-vars setup` - Configure environment variables
- `/nextjs-frontend:add-component Button` - Generate single component
- `/supabase:add-rls` - Add RLS policy to table

**Structure:**
```
Command
  ↓
Agent (analyze + execute in one pass)
  ↓
Result
```

**Output:** Direct changes to codebase/files

---

### 2. Two-Agent Pattern (Moderate Complexity)

**When to use:**
- Moderate data processing (10-50 items)
- Operations requiring analysis before execution
- Risk of incorrect execution without planning
- Operations taking 2-10 minutes

**Examples:**
- `/iterate:tasks` - Analyze spec, create layered tasks
- `/quality:test` - Analyze test coverage, run tests
- `/deployment:validate` - Check deployment readiness, report issues

**Structure:**
```
Command
  ↓
Agent 1: Analyzer
  → Reads data
  → Creates plan/report
  → Outputs: docs/reports/analysis-[name]-[timestamp].json
  ↓
Agent 2: Executor
  → Reads analysis report
  → Implements changes
  → Outputs: docs/reports/execution-[name]-[timestamp].json
```

**Report Schema (Analysis):**
```json
{
  "timestamp": "2025-11-11T18:30:00Z",
  "command": "/iterate:tasks F001",
  "analysis": {
    "items_analyzed": 25,
    "findings": [...],
    "recommendations": [...]
  },
  "execution_plan": {
    "actions": [...],
    "estimated_time": "5 minutes",
    "risk_level": "low"
  }
}
```

**Report Schema (Execution):**
```json
{
  "timestamp": "2025-11-11T18:35:00Z",
  "command": "/iterate:tasks F001",
  "analysis_report": "docs/reports/analysis-tasks-F001-20251111183000.json",
  "execution": {
    "actions_completed": [...],
    "files_modified": [...],
    "duration": "4m 32s"
  },
  "results": {
    "success": true,
    "errors": [],
    "warnings": []
  }
}
```

---

### 3. Three-Agent Pattern (Deep Work)

**When to use:**
- Complex operations processing large datasets (100+ items)
- High-risk changes requiring validation
- Operations where mistakes are costly
- Multi-stage workflows (10+ minutes)

**Examples:**
- `/planning:consolidate-docs` - 140+ markdown files to organize
- `/iterate:refactor` - Major codebase refactoring
- `/quality:validate-code` - Full codebase review and fixes
- `/deployment:prepare` - Complex multi-platform deployment prep

**Structure:**
```
Command
  ↓
Agent 1: Analyzer
  → Deep analysis of all data
  → Comprehensive assessment
  → Outputs: docs/reports/analysis-[name]-[timestamp].json
  ↓
Agent 2: Reviewer/Judge
  → Reviews analysis report
  → Identifies gaps, risks, improvements
  → Adjusts and validates execution plan
  → Outputs: docs/reports/execution-plan-[name]-[timestamp].json
  ↓
Agent 3: Executor
  → Reads execution plan
  → Implements all changes
  → Reports results
  → Outputs: docs/reports/execution-results-[name]-[timestamp].json
```

**Report Schema (Analysis):**
```json
{
  "timestamp": "2025-11-11T18:30:00Z",
  "command": "/planning:consolidate-docs",
  "analysis": {
    "total_files": 142,
    "classified": {
      "specs": 25,
      "architecture": 18,
      "adrs": 12,
      "duplicates": 15,
      "orphaned": 8,
      "unknown": 64
    },
    "duplicates_detected": [
      {
        "group": "auth-feature",
        "files": ["auth-spec.md", "authentication.md", "user-auth.md"],
        "recommendation": "merge"
      }
    ],
    "overlaps": [...],
    "gaps": [...]
  },
  "metadata": {
    "processing_time": "8m 15s",
    "files_read": 142,
    "classifications_made": 142
  }
}
```

**Report Schema (Execution Plan):**
```json
{
  "timestamp": "2025-11-11T18:38:15Z",
  "command": "/planning:consolidate-docs",
  "analysis_report": "docs/reports/analysis-consolidate-docs-20251111183000.json",
  "review": {
    "analysis_quality": "excellent",
    "gaps_found": [],
    "adjustments_made": [
      "Preserve auth-spec.md as primary instead of authentication.md",
      "Archive 3 additional files marked as outdated"
    ]
  },
  "execution_plan": {
    "phase_1_merge": [
      {
        "action": "merge",
        "files": ["auth-spec.md", "authentication.md", "user-auth.md"],
        "target": "specs/features/F001-authentication/spec.md",
        "risk": "low"
      }
    ],
    "phase_2_move": [...],
    "phase_3_archive": [...],
    "phase_4_delete": [...]
  },
  "risk_assessment": {
    "overall_risk": "medium",
    "high_risk_actions": [],
    "requires_backup": true
  }
}
```

**Report Schema (Execution Results):**
```json
{
  "timestamp": "2025-11-11T18:45:00Z",
  "command": "/planning:consolidate-docs",
  "execution_plan": "docs/reports/execution-plan-consolidate-docs-20251111183815.json",
  "execution": {
    "duration": "6m 45s",
    "actions_completed": 87,
    "actions_skipped": 0,
    "actions_failed": 0
  },
  "results": {
    "files_merged": 15,
    "files_moved": 42,
    "files_archived": 18,
    "files_deleted": 12,
    "new_structure": {
      "specs/": 25,
      "docs/architecture/": 18,
      "docs/adrs/": 12,
      "docs/archive/": 18
    }
  },
  "success": true,
  "errors": [],
  "warnings": [
    "3 files had encoding issues, converted to UTF-8"
  ]
}
```

---

## Report Directory Structure

All agent reports are stored in a standardized location:

```
docs/
├── reports/
│   ├── README.md                                    # Explains report structure
│   ├── analysis-consolidate-docs-20251111183000.json
│   ├── execution-plan-consolidate-docs-20251111183815.json
│   ├── execution-results-consolidate-docs-20251111184500.json
│   ├── analysis-refactor-api-20251111190000.json
│   └── ...
├── architecture/
├── adrs/
└── ROADMAP.md
```

**Report Naming Convention:**
```
[stage]-[command-name]-[timestamp].json

stage: analysis | execution-plan | execution-results
command-name: consolidate-docs | refactor-api | validate-code
timestamp: YYYYMMDDHHmmss (UTC)
```

---

## Parallel Agent Execution

Commands can spawn multiple agents in parallel when processing independent work:

**Automatic Parallelization:**
- Commands detect when work can be split
- Auto-spawn multiple agents (default: 3)
- Each agent processes subset of data

**Manual Override:**
```bash
/planning:consolidate-docs --agents=5  # Force 5 parallel agents
/planning:consolidate-docs --agents=1  # Force single agent (debugging)
```

**When to Parallelize:**
- Processing 50+ independent items
- Each item takes >30 seconds
- No dependencies between items
- Available resources support it

**Example:**
```
/planning:consolidate-docs (142 files)
  ↓
Spawn 3 Analyzer Agents in Parallel:
  - Agent 1: Files 1-48
  - Agent 2: Files 49-95
  - Agent 3: Files 96-142
  ↓
Combine results into single analysis report
  ↓
Continue to Reviewer/Judge (single agent)
```

---

## Decision Matrix

| Complexity | Items | Risk | Time | Pattern | Agents |
|------------|-------|------|------|---------|--------|
| Simple | 1-10 | Low | <2min | Single | 1 |
| Moderate | 10-50 | Medium | 2-10min | Two-Agent | 2 |
| Complex | 50-100 | Medium | 10-20min | Two-Agent + Parallel | 2 (with 2-3 parallel) |
| Deep Work | 100+ | High | 20min+ | Three-Agent + Parallel | 3 (with 3-5 parallel) |

---

## Implementation Guidelines

### For Command Authors

**When creating a new command:**

1. **Assess complexity** using decision matrix
2. **Choose appropriate pattern** (1, 2, or 3 agents)
3. **Define report schemas** if using multi-agent pattern
4. **Implement agent orchestration** in command phases
5. **Add parallelization** if processing 50+ items

**Example (Two-Agent Pattern):**
```markdown
Phase 3: Analyze Tasks
Goal: Analyze spec and create task layers

Actions:
- Invoke Task(subagent_type="iterate:task-analyzer", prompt="...")
- Wait for analysis report: docs/reports/analysis-tasks-F001-[timestamp].json
- Display summary of findings

Phase 4: Create Layered Tasks
Goal: Execute task layering based on analysis

Actions:
- Invoke Task(subagent_type="iterate:task-layering", prompt="Read analysis report from Phase 3 and create layered-tasks.md")
- Wait for execution results
- Display what was created
```

### For Agent Authors

**When creating agents:**

1. **Know your role**: Analyzer, Reviewer, or Executor
2. **Follow report schemas** exactly
3. **Output to docs/reports/** with standard naming
4. **Pass context** via report files, not memory
5. **Be autonomous** - no user interaction during execution

**Analyzer Agents:**
- Read all input data
- Classify, assess, detect patterns
- Create comprehensive analysis
- Output analysis report JSON
- DO NOT make changes

**Reviewer Agents:**
- Read analysis report
- Validate completeness and correctness
- Identify risks and gaps
- Adjust execution plan
- Output execution plan JSON
- DO NOT make changes

**Executor Agents:**
- Read execution plan
- Implement changes exactly as planned
- Report progress and results
- Output execution results JSON
- DO NOT deviate from plan

---

## Common Anti-Patterns

❌ **Single agent trying to analyze + execute complex work**
- Agent gets overwhelmed
- Does surface-level work
- Misses critical issues

✅ **Use two or three agents for complex work**

---

❌ **Agents communicating via conversation/memory**
- Context gets lost
- Hard to debug
- Not reproducible

✅ **Use report files for agent-to-agent communication**

---

❌ **No parallelization for 100+ items**
- Takes forever
- User waits unnecessarily
- Poor resource utilization

✅ **Auto-parallelize or provide --agents flag**

---

❌ **Reports stored in random locations**
- Hard to find
- Inconsistent naming
- No audit trail

✅ **Always use docs/reports/ with standard naming**

---

## Migration Path

**Existing commands should be gradually migrated:**

1. **Identify deep work commands** (process 50+ items)
2. **Split into multi-agent pattern** (2 or 3 agents)
3. **Add report output** to docs/reports/
4. **Add parallelization** where beneficial
5. **Update command documentation**

**Priority for migration:**
- `/planning:consolidate-docs` - Currently broken, needs 3-agent
- `/iterate:refactor` - Complex work, needs 3-agent
- `/quality:validate-code` - High-risk, needs 3-agent
- `/iterate:tasks` - Already has some structure, enhance to 2-agent

---

## Version History

- **v1.0** (2025-11-11): Initial pattern documentation
  - Single, Two, and Three-agent patterns defined
  - Report schemas and directory structure standardized
  - Parallel execution guidelines added
  - Migration path for existing commands

# Wizard Workflow Testing Document

**Version**: 1.0
**Date**: 2025-01-04
**Purpose**: Validate the complete wizard → Phase 0 → implementation workflow

---

## Overview

This document outlines the expected outcomes when the planning wizard workflow is successful. The workflow consists of three main stages:

1. **Wizard Stage**: Interactive requirements gathering and planning
2. **Phase 0 Stage**: Infrastructure setup and worktree creation
3. **Implementation Stages**: Feature development (Phases 1-5)

---

## Test Scenarios

### Scenario 1: New AI Application (Primary Test)

**Input**: User wants to build a trade exam preparation app with voice AI features
**Expected Duration** (with parallel generation + validation):
- **OLD**: 30-40 minutes (wizard) + 10-15 minutes (Phase 0) = 40-55 minutes total
- **NEW**: 15-20 minutes (wizard) + 10-15 minutes (Phase 0) = 25-35 minutes total
- **Improvement**: 40% faster with parallel execution

**Breakdown**:
- Phase 1-3 (Requirements): 5-7 minutes
- Phase 4 (Parallel Architecture): 4-5 minutes (vs. 15-20 sequential)
- Phase 4.5 (Validation): 3-5 minutes (new quality gate)
- Phase 4.6 (ADRs/Roadmap): 2-3 minutes
- Phase 5 (Specs): 1-2 minutes

---

## Stage 1: Planning Wizard (`/planning:wizard`)

### Expected User Interactions

1. **Initial Question**: "What would you like to build?"
   - User provides: Project description (text or file upload)

2. **File Upload Prompt**: "Upload any files to help me understand:"
   - User may provide: Wireframes, docs, competitor URLs, GitHub repos

3. **Structured Q&A (6-8 rounds)**: AskUserQuestion covers:
   - Project type and target users
   - Core features (MVP vs. future)
   - Technical stack preferences
   - External integrations needed
   - Timeline and constraints
   - Success metrics

### Expected Wizard Outputs

#### Phase 1-3: Requirements Captured

**Directory Structure Created:**
```
docs/
├── requirements/
│   └── 2025-01-04-trade-exam-app/
│       ├── 01-initial-request.md
│       ├── 02-wizard-qa.md
│       └── .wizard/
│           ├── extracted-requirements.json
│           └── completion-summary.md
```

**File: `01-initial-request.md`**
- Contains: User's project description
- Size: ~500-2000 characters
- Format: Markdown with clear project goals
- ✅ Success: File exists and contains project description
- ❌ Failure: File missing or empty

**File: `.wizard/extracted-requirements.json`** (if files uploaded)
- Contains: Structured JSON with:
  - `source`: File name or URL
  - `type`: "document|code|image|url"
  - `extracted.features`: Array of feature strings
  - `extracted.user_stories`: Array of user stories
  - `extracted.technical_constraints`: Array of constraints
  - `extracted.integrations`: Array of integrations
  - `confidence`: Number (0-100)
- ✅ Success: Valid JSON with extracted data
- ❌ Failure: Invalid JSON or missing required fields

**File: `02-wizard-qa.md`**
- Contains: All Q&A rounds documented
- Format: Markdown with questions and answers
- Expected sections:
  - Project Type & Users
  - Core Features
  - Technical Stack
  - Integrations
  - Timeline & Constraints
  - Success Metrics
- ✅ Success: 6-8 Q&A rounds documented
- ❌ Failure: Less than 6 rounds or missing answers

#### Phase 4: Architecture + ADRs + Roadmap (BATCHED PARALLEL)

**⚠️ UI CONSTRAINT**: Maximum 10-12 agents per batch (UI breaks with >10 agents)

**🚀 Performance Improvement**:
- **OLD**: Sequential generation (~25-30 minutes for architecture + ADRs + roadmap)
- **NEW**: Batched parallel generation (6 agents in one batch, ~5-6 minutes)
- **Speedup**: 5x faster with parallel execution

**Batch 1 (6 agents)**: Architecture + ADRs + Roadmap
```
Agent 1: README.md + backend.md → 2 files (system overview, Claude Agent SDK, MCP)
Agent 2: data.md + ai.md → 2 files (Supabase schema, AI architecture)
Agent 3: security.md + integrations.md → 2 files (auth, API keys, external services)
Agent 4: infrastructure.md + frontend.md → 2 files (deployment, optional dashboard)
Agent 5: ADRs → 7+ decision records (decision-documenter agent)
Agent 6: ROADMAP.md → master plan (roadmap-planner agent)
```

**Expected Behavior**:
- All 6 agents launched in SINGLE message (parallel execution)
- Batch size ≤ 10 agents (UI-safe)
- Agents work simultaneously (not sequentially)
- Total time: ~5-6 minutes vs. 25-30 minutes sequential
- ✅ Success: 8 architecture files + ADRs + roadmap created in parallel, < 8 minutes
- ❌ Failure: Sequential execution OR >10 agents in batch OR >15 minutes

**Directory Structure Created:**
```
docs/
├── architecture/
│   ├── README.md          (overview)
│   ├── frontend.md        (Next.js pages, components, routing)
│   ├── backend.md         (FastAPI endpoints, services)
│   ├── data.md            (database schema, entities, relationships)
│   ├── ai.md              (AI architecture, agents, prompts)
│   ├── security.md        (auth, RLS, encryption)
│   └── integrations.md    (third-party services)
├── adr/
│   ├── 0001-tech-stack-selection.md
│   ├── 0002-frontend-framework.md
│   ├── 0003-backend-framework.md
│   └── 0004-*.md          (additional ADRs as needed)
└── ROADMAP.md
```

**Architecture Files Validation:**

Each architecture file should contain:
- **Headers**: Clear section structure with `#`, `##`, `###`
- **Mermaid diagrams**: At least 1-2 diagrams per file
- **Technical details**: Specific implementation guidance
- **Size**: 3-10 KB per file (not tiny, not massive)
- **References**: Links to ADRs and other docs

**File: `docs/architecture/data.md`**
- Contains:
  - Database schema with tables
  - Entity relationships (ER diagram)
  - Data model definitions
  - RLS policy guidelines
- ✅ Success: Has schema definitions with clear entity names
- ❌ Failure: Generic template without project-specific entities

**File: `docs/architecture/ai.md`**
- Contains:
  - AI architecture overview
  - Model selection rationale
  - Agent workflows
  - Prompt engineering patterns
  - Vector database setup (if RAG)
- ✅ Success: Specific AI features for this project
- ❌ Failure: Missing or generic AI content

**File: `docs/ROADMAP.md`**
- Contains:
  - All features listed with numbers (001, 002, etc.)
  - Priority levels (P0, P1, P2)
  - Dependencies between features
  - Timeline estimates
  - Gantt chart (mermaid)
- Format:
```markdown
# Project Roadmap

## Features

### 001: Exam Question Bank (P0)
- **Estimated**: 3 days
- **Dependencies**: None
- **Description**: Question database with categories

### 002: Exam Taking Interface (P0)
- **Estimated**: 2 days
- **Dependencies**: 001
- **Description**: Interactive exam UI

## Timeline

```mermaid
gantt
    title Development Timeline
    ...
```

- ✅ Success: Features numbered, dependencies clear, gantt chart present
- ❌ Failure: No feature numbers or missing timeline

**ADR Files Validation:**

Each ADR should follow this structure:
```markdown
# ADR-XXXX: Title

**Status**: Accepted
**Date**: 2025-01-04
**Context**: Why this decision was needed
**Decision**: What was decided
**Alternatives**: What else was considered
**Consequences**: Impact of this decision
```

- ✅ Success: Sequential numbering (0001, 0002, etc.)
- ❌ Failure: Duplicate numbers or missing sections

#### Phase 4.5: Architecture Validation (MULTI-TIER)

**🎯 Quality Improvement**:
- **Purpose**: Catch issues before implementation
- **Approach**: Multi-tier validation (Technical → Cost → Timeline → CTO)
- **Benefit**: Higher quality architecture, fewer rework cycles

**Validation Tier 1: Technical Validators (PARALLEL)**

Launch 3 validators in parallel:

**Validator 1: Technical Completeness**
- **Checks**:
  - All 8 architecture files present
  - Each file has mermaid diagrams
  - Security best practices followed (no hardcoded keys)
  - Integration patterns documented
  - Database schema complete with ER diagram
- **Output**: `docs/architecture/validation-report-technical.md`
- ✅ Success: All checks pass, score >90%
- ⚠️  Warning: Some checks fail, score 70-90%
- ❌ Failure: Critical issues, score <70%

**Validator 2: Cost Validation**
- **Checks**:
  - External service costs estimated
  - Costs align with budget constraints (from Q&A)
  - Free tier utilization maximized
  - Cost-optimization strategies documented
  - Monthly/annual cost breakdown provided
- **Output**: `docs/architecture/validation-report-cost.md`
- ✅ Success: Within budget, <$100/month as specified
- ⚠️  Warning: Slightly over budget, alternatives suggested
- ❌ Failure: Significantly over budget, no cost estimates

**Validator 3: Timeline Feasibility**
- **Checks**:
  - Features estimated (days/weeks)
  - Timeline matches Q&A constraints (1-3 months aggressive)
  - Dependencies identified for parallel work
  - Critical path analyzed
  - Risk factors documented
- **Output**: `docs/architecture/validation-report-timeline.md`
- ✅ Success: Feasible within 1-3 months
- ⚠️  Warning: Tight but possible, risks noted
- ❌ Failure: Not achievable in timeframe

**Validation Tier 2: CTO-Level Review**

After validators complete, launch CTO reviewer:

**CTO Reviewer Agent**:
- **Reads**:
  - All 8 architecture files
  - All 3 validation reports
  - Wizard requirements (Q&A, extracted data)
- **Analyzes**:
  - Architecture quality and completeness
  - Alignment with business requirements
  - Technical risks and mitigation strategies
  - Scalability and maintainability
  - Security posture
  - Cost-benefit trade-offs
- **Outputs**: `docs/architecture/CTO-REVIEW.md`
  - **Executive Summary** (2-3 paragraphs)
  - **Critical Issues** (blockers that must be fixed)
  - **Warnings** (should fix but not blocking)
  - **Recommendations** (nice-to-haves, optimizations)
  - **Approval Status**: APPROVED | APPROVED_WITH_CHANGES | REJECTED

**Expected CTO Review Output**:
```markdown
# CTO Architecture Review

**Date**: 2025-01-04
**Reviewer**: CTO-level validator agent
**Status**: APPROVED_WITH_CHANGES

## Executive Summary
The architecture is solid and production-ready with minor improvements needed. The multi-channel conversational approach is well-designed, security practices are strong (no hardcoded keys), and cost estimates align with budget (<$100/month target). Timeline is aggressive but achievable with parallel development.

## Critical Issues
None - architecture is sound

## Warnings (Should Fix)
1. **LinkedIn Integration**: Mulilead API rate limits not documented - add retry logic
2. **Database Backup**: Supabase backup frequency not specified - recommend daily
3. **Monitoring**: Missing APM/observability strategy - add Sentry or similar

## Recommendations (Optional)
1. Consider adding Redis cache for CATS API responses (reduce API calls)
2. Evaluate Vercel Edge Functions for conversation routing (lower latency)
3. Add A/B testing framework for question generation strategies

## Approval
APPROVED WITH CHANGES - Address 3 warnings before implementation
```

**Validation Flow**:
1. Launch 3 validators in parallel (~2-3 minutes)
2. Wait for all validators to complete
3. Launch CTO reviewer (~1-2 minutes)
4. Display CTO review to user
5. If REJECTED: Ask user to regenerate architecture
6. If APPROVED_WITH_CHANGES: Continue with warnings noted
7. If APPROVED: Continue to next phase

**Total Validation Time**: 3-5 minutes (parallel execution)

**Files Created**:
```
docs/architecture/
├── validation-report-technical.md
├── validation-report-cost.md
├── validation-report-timeline.md
└── CTO-REVIEW.md
```

#### Phase 5: Feature Specs Generated (BATCHED PARALLEL)

**⚠️ UI CONSTRAINT**: Maximum 10-12 agents per batch (UI breaks with >10 agents)

**🚀 Performance Improvement**:
- **OLD**: Sequential generation (1 agent per spec, ~40 minutes for 20 specs)
- **NEW**: Batched parallel generation (2 batches of 10 agents, ~4-6 minutes total)
- **Speedup**: 10x faster with batched parallel execution

**Batch 1 (10 agents)**: Feature specs 001-010
```
Agent 1-10: feature-spec-writer agents for features 001-010
```

**Batch 2 (10 agents)**: Feature specs 011-020
```
Agent 1-10: feature-spec-writer agents for features 011-020
```

**Expected Behavior**:
- Each batch: 10 agents launched in SINGLE message (parallel execution)
- Batch size ≤ 10 agents (UI-safe)
- Agents work simultaneously within batch
- Total time: ~2-3 minutes per batch = 4-6 minutes for all 20 specs
- ✅ Success: All 20 specs created via batched parallel execution, < 8 minutes total
- ❌ Failure: Sequential execution OR >10 agents in batch OR >20 minutes

**Directory Structure Created:**
```
specs/
└── features/
    ├── 001-exam-question-bank/
    │   ├── spec.md
    │   └── tasks.md
    ├── 002-exam-taking-interface/
    │   ├── spec.md
    │   └── tasks.md
    ├── 003-voice-companion/
    │   ├── spec.md
    │   └── tasks.md
    └── ...
```

**Feature Spec Validation:**

**File: `specs/features/001-exam-question-bank/spec.md`**
- Size: 100-150 lines (NOT 647!)
- Contains:
  - Feature name and description
  - User stories (As a... I want... So that...)
  - Acceptance criteria (3-5 testable criteria)
  - References to architecture docs
  - Dependencies on other features
  - Scope (what's in, what's out)
- ✅ Success: Concise, references architecture, clear scope
- ❌ Failure: Duplicates architecture content, >200 lines, vague criteria

**File: `specs/features/001-exam-question-bank/tasks.md`**
- Size: 30-50 tasks
- Contains phase-based structure:
  - Database phase (migration, schema, RLS, tests)
  - Backend phase (endpoints, validation, error handling, tests)
  - Frontend phase (components, API connection, loading, errors)
  - Integration phase (wire dependencies, E2E tests)
  - Production ready (performance, security, E2E, docs)
- ✅ Success: 15-25 tasks per feature, actionable checklist
- ❌ Failure: >50 tasks, vague descriptions, missing phases

**Feature Breakdown Validation:**

**File: `.wizard/feature-breakdown.json`**
```json
{
  "features": [
    {
      "number": "001",
      "name": "exam-question-bank",
      "shortName": "exam-question-bank",
      "focus": "Question database with categories and trade-specific content",
      "dependencies": [],
      "estimatedDays": 3,
      "complexity": "medium",
      "architectureReferences": [
        "docs/architecture/data.md#exam-schema",
        "docs/architecture/backend.md#question-api"
      ],
      "buildPhase": 1,
      "sharedEntities": {
        "owns": ["Question", "QuestionCategory", "TradeSpecialization"],
        "references": ["User"]
      }
    }
  ],
  "sharedContext": {
    "techStack": ["Next.js 15", "FastAPI", "Supabase"],
    "userTypes": ["Apprentice", "Mentor", "Admin"],
    "dataEntities": ["Question", "QuestionCategory", "TradeSpecialization"],
    "entityOwnership": {
      "Question": "001-exam-question-bank",
      "QuestionCategory": "001-exam-question-bank"
    }
  }
}
```

- ✅ Success:
  - Features numbered sequentially
  - Each feature 2-3 days max
  - Entity ownership assigned (no duplicates)
  - Architecture references provided
  - Build phases assigned (1=Foundation, 2=Core, 3=Integration)
  - **NO infrastructure features** (auth, database, API setup)
- ❌ Failure:
  - Features >3 days
  - Duplicate entity ownership
  - Infrastructure features present (e.g., "001-user-auth-setup")
  - Missing architecture references

#### Phase 6: Final Plan Validation (Complete Review)

**🎯 Purpose**: CTO-level validation of ENTIRE planning package before implementation

**Validation Scope**:
- All 8 architecture files
- All ADRs and ROADMAP.md
- All feature specs (20 specs)
- All tasks files (20 tasks.md)
- Alignment and consistency checks

**Expected Behavior**:
- Launch 1 CTO reviewer agent (~3-5 minutes)
- Agent reads ALL planning documents
- Validates complete plan is production-ready
- Checks for spec/architecture conflicts
- ✅ Success: Single agent, comprehensive review, < 6 minutes
- ❌ Failure: Multiple agents OR incomplete review OR >10 minutes

**File Created: `docs/FINAL-APPROVAL.md`**

```markdown
# Final Plan Approval

**Date:** 2025-01-04
**Reviewer:** CTO-level validator agent
**Status:** APPROVED | APPROVED_WITH_CHANGES | REJECTED

## Executive Summary
[2-3 paragraphs assessing complete planning package]

## Plan Completeness
- ✅/❌ All 8 architecture files present and complete
- ✅/❌ All 20 feature specs align with architecture
- ✅/❌ All tasks files have proper phase structure
- ✅/❌ Dependencies mapped correctly (no circular deps)
- ✅/❌ No conflicts between specs

## Alignment Analysis
- ✅/❌ Specs reference architecture (no duplication)
- ✅/❌ Features implementable with chosen tech stack
- ✅/❌ Timeline feasible based on spec complexity
- ✅/❌ Budget realistic for feature scope
- ✅/❌ Entity ownership clear (no duplicate tables)

## Production Readiness
- ✅/❌ Security addressed in architecture and specs
- ✅/❌ Testing strategy defined in tasks
- ✅/❌ Deployment approach clear
- ✅/❌ Monitoring/observability planned

## Critical Issues (Blockers)
[List issues that prevent implementation - empty if APPROVED]

## Warnings (Should Fix)
[List concerns to address - empty if fully APPROVED]

## Recommendations (Optional)
[List nice-to-have improvements]

## Final Decision

**Status:** APPROVED

**Rationale:**
The complete planning package is production-ready. All 20 features align with
architecture, dependencies are properly mapped, timeline is aggressive but achievable
with parallel execution, and budget constraints are met. No critical issues found.

**Next Steps:**
- Proceed to Phase 0 infrastructure setup
- Run /supervisor:init --all to create worktrees
- Begin parallel implementation
```

**Validation Criteria**:
- ✅ Success: Status = APPROVED, no critical issues, clear rationale
- ⚠️ Warning: Status = APPROVED_WITH_CHANGES, warnings to fix
- ❌ Failure: Status = REJECTED, critical issues found

#### Phase 7-8: Finalization & Summary

**File: `.wizard/completion-summary.md`**
- Contains:
  - Feature count created
  - Total estimated time
  - Infrastructure note (handled by plugins)
  - Next steps (Phase 0)
- ✅ Success: Summary present with clear next steps
- ❌ Failure: Missing summary

**Console Output Expected:**
```
✅ Phase 7 Complete: Planning Wizard

Wizard Output:
- Requirements: docs/requirements/2025-01-04-trade-exam-app/
- Architecture: docs/architecture/ (7 files)
- ADRs: docs/adr/ (4 files)
- Roadmap: docs/ROADMAP.md
- Features: specs/features/ (15 features)

Infrastructure: Handled by ai-tech-stack-1 plugin Phase 0-2
No infrastructure specs needed (auth, database, API setup excluded)

Next Steps:
1. Review ROADMAP.md for project timeline
2. Run /ai-tech-stack-1:build-full-stack-phase-0
3. Run /supervisor:init --all to create worktrees

Estimated Development: 30-45 days (15 features × 2-3 days each)
```

---

## Stage 2: Phase 0 Setup (`/ai-tech-stack-1:build-full-stack-phase-0`)

### Expected Phase 0 Inputs

- Requires: docs/requirements/, docs/architecture/, docs/ROADMAP.md, specs/features/
- If missing: Should display error and exit

### Expected Phase 0 Outputs

#### Phase 1: Read Wizard Output

**Console Output Expected:**
```
✅ Wizard output found
- Requirements: docs/requirements/2025-01-04-trade-exam-app/
- Architecture: 7 files
- ADRs: 4 files
- Roadmap: ROADMAP.md
- Features: 15 specs
```

- ✅ Success: All wizard files detected
- ❌ Failure: Missing wizard output, error displayed

#### Phase 2: Validate All Specs

**File Created: `gaps-analysis.json`**
```json
{
  "total_specs": 15,
  "avg_completeness": 92.5,
  "critical_gaps": [],
  "incomplete_specs": []
}
```

- ✅ Success: avg_completeness > 85%, critical_gaps = []
- ❌ Failure: avg_completeness < 70% or critical_gaps present

#### Phase 3: Bulk Worktree Creation

**Git Worktrees Created:**
```bash
$ git worktree list
/path/to/project                    abc123 [main]
../TradeExam-001                    def456 [spec-001]
../TradeExam-002                    ghi789 [spec-002]
../TradeExam-003                    jkl012 [spec-003]
...
```

**Mem0 Registration:**
```bash
$ python plugins/planning/skills/doc-sync/scripts/register-worktree.py query --query "worktree for spec 001"

Results:
- Worktree: ../TradeExam-001
- Branch: spec-001
- Spec: 001-exam-question-bank
- Status: active
```

- ✅ Success:
  - 1 worktree per spec created
  - Branches named `spec-NNN`
  - Registered in Mem0
  - Can query via register-worktree.py
- ❌ Failure:
  - Worktrees missing
  - Not registered in Mem0
  - Query returns no results

#### Phase 4: Project Detection

**File Created: `.claude/project.json`**
```json
{
  "name": "trade-exam-app",
  "stack": {
    "frontend": "Next.js 15",
    "backend": "FastAPI",
    "database": "Supabase",
    "ai": ["OpenRouter", "Vercel AI SDK", "Mem0"],
    "deployment": ["Vercel", "Railway"]
  }
}
```

- ✅ Success: Detected stack matches architecture
- ❌ Failure: Stack mismatch or missing

#### Phase 5: Environment Verification

**Console Output Expected:**
```
✅ Environment ready
- Node.js: v20.10.0
- Python: v3.11.5
- npm: v10.2.3
- Git: v2.42.0
```

- ✅ Success: All tools installed
- ❌ Failure: Missing tools, installation failed

#### Phase 6: Git Hooks Setup

**Files Created:**
```
.git/hooks/
├── pre-commit      (secret scanning)
├── commit-msg      (message validation)
└── pre-push        (security checks)
```

- ✅ Success: Hooks executable and working
- ❌ Failure: Hooks missing or not executable

#### Phase 7: MCP Configuration

**File Created: `.env.example`**
```bash
# Supabase (Required)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here

# Mem0 (Optional)
MEM0_API_KEY=your_mem0_key_here

# Context7 (Optional)
CONTEXT7_API_KEY=your_context7_key_here
```

- ✅ Success: Placeholders present, no real keys
- ❌ Failure: Real API keys hardcoded

#### Phase 8: Doppler Setup

**Files Created:**
```
doppler-sync.sh         (bidirectional sync script)
DOPPLER.md              (documentation)
```

**Console Output Expected:**
```
✓ Doppler setup complete
- Project: trade-exam-app
- Environments: dev, dev_personal, stg, prd
- Commands:
  doppler run -- npm run dev
  doppler secrets
```

- ✅ Success: Doppler configured, secrets synced
- ❌ Failure: Authentication failed or project not created

#### Phase 9: Summary

**File Updated: `.ai-stack-config.json`**
```json
{
  "phase0Complete": true,
  "phase": 0,
  "appName": "trade-exam-app",
  "timestamp": "2025-01-04T10:30:00Z",
  "nextPhase": "Phase 1 - Foundation (Next.js + FastAPI + Supabase)",
  "worktreesSetup": true,
  "worktreeCount": 15,
  "dopplerEnabled": true,
  "dopplerProject": "trade-exam-app"
}
```

**Console Output Expected:**
```
✅ Phase 0 Complete: Dev Lifecycle Foundation

Wizard Output Loaded:
- Requirements: docs/requirements/ ✓
- Architecture: docs/architecture/ (7 files) ✓
- ADRs: docs/adr/ (4 files) ✓
- Roadmap: docs/ROADMAP.md ✓
- Specs: specs/features/ (15 features) ✓

Infrastructure Setup:
- Specs validated (avg 92.5% complete) ✓
- Worktrees created (15 worktrees) ✓
- Agents registered in Mem0 ✓
- Project detected (.claude/project.json) ✓
- Environment verified ✓
- Git hooks installed ✓
- MCP servers documented ✓
- Secret management: Doppler enabled ✓

Ready for Phase 1: Implementation
Run: /ai-tech-stack-1:build-full-stack-phase-1

Time: ~10-15 minutes
```

- ✅ Success: All checkmarks present
- ❌ Failure: Any component marked failed

---

## Validation Commands

Run these commands to verify success:

### 1. Wizard Output Validation

```bash
# Check requirements
ls -lh docs/requirements/*/01-initial-request.md
cat docs/requirements/*/01-initial-request.md | wc -l  # Should be > 10 lines

# Check architecture
ls -lh docs/architecture/
test -f docs/architecture/data.md && echo "✓ data.md exists"
test -f docs/architecture/ai.md && echo "✓ ai.md exists"
grep -c "mermaid" docs/architecture/*.md  # Should have diagrams

# Check roadmap
test -f docs/ROADMAP.md && echo "✓ ROADMAP.md exists"
grep -E "^### [0-9]{3}:" docs/ROADMAP.md | wc -l  # Count features

# Check ADRs
ls -1 docs/adr/ | wc -l  # Should have 3-7 ADRs
ls -1 docs/adr/ | grep -E "^[0-9]{4}-"  # Verify numbering

# Check specs
ls -d specs/features/*/ | wc -l  # Count feature directories
test -f specs/features/001-*/spec.md && echo "✓ First spec exists"
cat specs/features/001-*/spec.md | wc -l  # Should be 100-150 lines (not 647!)

# Check feature breakdown
test -f .wizard/feature-breakdown.json && echo "✓ Breakdown exists"
cat .wizard/feature-breakdown.json | jq '.features | length'  # Count features
cat .wizard/feature-breakdown.json | jq '.features[0]'  # Show first feature
```

### 2. Phase 0 Validation

```bash
# Check worktrees
git worktree list | wc -l  # Should be > 1
git worktree list | grep "spec-"  # Show spec branches

# Check Mem0 registration
python plugins/planning/skills/doc-sync/scripts/register-worktree.py query --query "all worktrees"

# Check project detection
test -f .claude/project.json && echo "✓ project.json exists"
cat .claude/project.json | jq '.stack'

# Check environment
node --version  # v18+ for Next.js
python --version  # v3.9+ for FastAPI
npm --version

# Check git hooks
ls -la .git/hooks/pre-commit
ls -la .git/hooks/commit-msg

# Check Doppler
doppler --version
doppler projects

# Check config
test -f .ai-stack-config.json && echo "✓ config exists"
cat .ai-stack-config.json | jq '.phase0Complete'  # Should be true
```

### 3. Content Quality Validation

```bash
# Architecture should be project-specific (not generic)
grep -i "exam" docs/architecture/data.md  # Should find project terms
grep -i "question" docs/architecture/data.md  # Should find domain terms

# Specs should reference architecture (not duplicate)
grep -c "docs/architecture" specs/features/001-*/spec.md  # Should be > 0

# Features should NOT include infrastructure
grep -i "auth.*setup" specs/features/*/spec.md  # Should return nothing
grep -i "database.*setup" specs/features/*/spec.md  # Should return nothing
grep -i "stripe.*integration" specs/features/*/spec.md  # Should return nothing

# Entity ownership should be unique
cat .wizard/feature-breakdown.json | jq '.sharedContext.entityOwnership'  # Each entity owned once

# Features should be properly sized
cat .wizard/feature-breakdown.json | jq '.features[].estimatedDays' | sort -u  # Should be 1-3

# No hardcoded API keys
grep -r "sk-" . --exclude-dir=node_modules --exclude-dir=.git  # Should return nothing
grep -r "API_KEY.*=" .env  # Should only be in .env (not committed)
```

---

## Success Criteria Summary

### Wizard Success (Stage 1)

- ✅ Requirements captured in `docs/requirements/`
- ✅ Architecture docs created (7+ files, 3-10 KB each)
- ✅ ADRs created (3-7 files, sequential numbering)
- ✅ Roadmap created with numbered features
- ✅ Feature specs created (10-50 specs, 100-150 lines each)
- ✅ Feature breakdown JSON valid
- ✅ Only CUSTOM features (no infrastructure)
- ✅ Entity ownership unique (no duplicates)
- ✅ Features sized 2-3 days max
- ✅ Specs reference architecture (not duplicate)

### Phase 0 Success (Stage 2)

- ✅ Wizard output loaded successfully
- ✅ Specs validated (>85% completeness)
- ✅ Worktrees created (1 per spec)
- ✅ Mem0 registration working
- ✅ Project detected correctly
- ✅ Environment verified (all tools)
- ✅ Git hooks installed
- ✅ Doppler configured
- ✅ No hardcoded API keys
- ✅ Config file updated

### Overall Success

**Time**: 40-55 minutes total (30-40 wizard + 10-15 Phase 0)
**Features**: 10-50 custom features created
**Quality**:
- Specs concise (100-150 lines)
- Tasks actionable (15-25 tasks)
- Architecture comprehensive (7+ docs)
- No infrastructure specs

**Ready for**: Phase 1 implementation

---

## Common Failure Modes

### 1. Wizard Failures

**Symptom**: No architecture files created
**Cause**: `/planning:architecture` not invoked
**Fix**: Check wizard.md Phase 4

**Symptom**: Specs include "001-user-auth-setup"
**Cause**: feature-analyzer not filtering infrastructure
**Fix**: Verify feature-analyzer.md rules

**Symptom**: Specs are 647 lines (too long)
**Cause**: Duplicating architecture content
**Fix**: Verify specs reference architecture instead

### 2. Phase 0 Failures

**Symptom**: "Run wizard first" error
**Cause**: Missing docs/requirements/
**Fix**: Run /planning:wizard first

**Symptom**: Worktrees not created
**Cause**: /supervisor:init failed
**Fix**: Check git worktree compatibility

**Symptom**: Mem0 registration failed
**Cause**: Mem0 not installed or configured
**Fix**: Install mem0ai in global venv

### 3. Integration Failures

**Symptom**: Phase 1 can't find specs
**Cause**: Specs not in specs/features/
**Fix**: Check directory structure

**Symptom**: Agents duplicate database tables
**Cause**: Entity ownership not assigned
**Fix**: Verify feature-breakdown.json entityOwnership

---

## Test Execution Checklist

- [ ] Start fresh project directory
- [ ] Run `/planning:wizard`
- [ ] Provide multimodal inputs (text + files)
- [ ] Complete all Q&A rounds (6-8)
- [ ] Verify requirements captured
- [ ] Verify architecture created
- [ ] Verify roadmap created
- [ ] Verify specs created
- [ ] Count features (10-50 expected)
- [ ] Check feature sizing (2-3 days)
- [ ] Verify no infrastructure features
- [ ] Run `/ai-tech-stack-1:build-full-stack-phase-0`
- [ ] Verify wizard output loaded
- [ ] Verify specs validated
- [ ] Verify worktrees created
- [ ] Verify Mem0 registration
- [ ] Verify environment ready
- [ ] Verify git hooks installed
- [ ] Verify Doppler configured
- [ ] Check no hardcoded keys
- [ ] Verify config updated
- [ ] Ready for Phase 1

---

## Reporting Results

When testing is complete, report:

1. **Success Rate**: X/Y phases completed
2. **Timing**: Actual time vs. expected
3. **Feature Count**: Number of custom features generated
4. **Quality Metrics**:
   - Average spec length (target: 100-150 lines)
   - Average task count (target: 15-25 tasks)
   - Completeness score (target: >85%)
5. **Issues Found**: List any failures or deviations
6. **Recommendations**: Improvements needed

**Report Template:**
```markdown
## Wizard Workflow Test Results

**Date**: 2025-01-04
**Tester**: [Name]
**Project**: Trade Exam App

### Results
- ✅ Wizard completed: 35 minutes
- ✅ Phase 0 completed: 12 minutes
- ✅ Features created: 18 custom features
- ✅ Average spec length: 142 lines
- ✅ Average tasks: 22 tasks
- ✅ Completeness: 94%

### Issues
- None

### Recommendations
- None needed - working as expected

### Conclusion
✅ PASS - Ready for production use
```

---

**End of Testing Document**

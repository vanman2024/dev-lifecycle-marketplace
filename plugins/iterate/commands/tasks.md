---
description: Layer tasks for parallel execution with dependency analysis (FAST - <2 min)
argument-hint: <spec-name>
allowed-tools: Read, Grep, Write, TodoWrite
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

---


**Arguments**: $ARGUMENTS

Goal: Quickly analyze tasks.md and create layered-tasks.md with L0-L3 layers for parallel execution

**SPEED TARGET: <2 minutes for simple features, <5 minutes for complex**

Phase 1: Quick Discovery (10 seconds)

Actions:
- Parse spec name: $ARGUMENTS
- Read tasks file: @specs/$ARGUMENTS/tasks.md
- Count tasks (if >50 tasks, warn user this is too large)
- Quick scan for obvious patterns (auth, database, UI, API)

Phase 2: Fast Dependency Analysis (30-60 seconds)

Actions:
- Identify infrastructure tasks (keywords: setup, install, configure, initialize, database, auth)
- Identify core tasks (keywords: create, implement, build, develop)
- Identify feature tasks (keywords: add, enhance, integrate, connect)
- Identify integration tasks (keywords: wire, connect, test, deploy)
- Check for explicit dependencies (e.g., "depends on task X")

**NO deep code analysis - just keyword-based categorization**

Phase 3: Layer Assignment (30 seconds)

Actions:
- Create layered-tasks.md with 4 layers:

```markdown
# Layered Tasks for F00X

## Layer 0: Infrastructure (Run First)
**These must complete before other layers**

- [ ] Task: Setup database schema
  - Complexity: Mid
  - Agent: Backend
  - Dependencies: None

- [ ] Task: Configure authentication
  - Complexity: Senior
  - Agent: Backend
  - Dependencies: None

## Layer 1: Core Services (Parallel)
**Can run in parallel after L0 completes**

- [ ] Task: Create API endpoints
  - Complexity: Mid
  - Agent: Backend
  - Dependencies: L0 complete

- [ ] Task: Create base components
  - Complexity: Junior
  - Agent: Frontend
  - Dependencies: None

## Layer 2: Features (Parallel)
**Can run in parallel after L1 completes**

- [ ] Task: Build chat interface
  - Complexity: Mid
  - Agent: Frontend
  - Dependencies: L1 components

- [ ] Task: Implement chat API
  - Complexity: Senior
  - Agent: Backend
  - Dependencies: L1 endpoints

## Layer 3: Integration (Sequential)
**Wire everything together**

- [ ] Task: Connect frontend to backend
  - Complexity: Mid
  - Agent: Fullstack
  - Dependencies: L2 complete

- [ ] Task: End-to-end testing
  - Complexity: Senior
  - Agent: QA
  - Dependencies: All layers complete
```

**Layering Rules (Fast Heuristics):**
- L0: Contains "setup", "install", "configure", "database", "auth"
- L1: Contains "create", "build", "implement" + is foundational
- L2: Contains "add", "enhance", "feature" + depends on L1
- L3: Contains "integrate", "connect", "wire", "test", "deploy"

Phase 4: Complexity Assignment (20 seconds)

**Fast complexity heuristics:**
- Junior: UI components, simple CRUD, basic forms
- Mid: API endpoints, state management, simple integrations
- Senior: Authentication, complex logic, performance optimization
- Expert: Architecture changes, distributed systems, advanced AI

Phase 5: Agent Assignment (20 seconds)

**Fast agent assignment:**
- Backend: API, database, auth, server tasks
- Frontend: UI, components, pages, styling
- Fullstack: Integration, wiring, deployment
- QA: Testing, validation, quality checks
- DevOps: CI/CD, deployment, infrastructure

Phase 6: Write Output (10 seconds)

Actions:
- Write layered-tasks.md to specs/$ARGUMENTS/
- Display summary:
  - Total tasks: X
  - L0 (Infrastructure): Y tasks
  - L1 (Core): Z tasks
  - L2 (Features): A tasks
  - L3 (Integration): B tasks
- Show parallelization potential: "L1 and L2 tasks can run in parallel"

Phase 7: Quick Recommendations (10 seconds)

Actions:
- If L0 has >5 tasks: "Consider breaking infrastructure setup into separate feature"
- If L2 has >10 tasks: "Consider breaking features into multiple specs"
- If any layer is empty: "This looks like it could be simplified - layer X is empty"

**IMPORTANT SPEED OPTIMIZATIONS:**

1. **NO deep code analysis** - Just read tasks.md and categorize by keywords
2. **NO file searching** - Don't grep through codebase
3. **NO complex dependency graphs** - Just simple L0 → L1 → L2 → L3
4. **Use heuristics, not perfection** - 80/20 rule, good enough is good enough
5. **Parallel by default** - Assume tasks within a layer can run in parallel unless explicit dependency

**If task is taking >2 minutes for simple features:**
- User has too many tasks in one spec (should break into multiple features)
- Tasks are too granular (combine related tasks)
- Spec is too complex (needs architecture redesign)

**Output Files:**
- specs/$ARGUMENTS/layered-tasks.md

**Next Steps for User:**
1. Review layered-tasks.md
2. Start building L0 tasks first
3. After L0 complete, build L1 tasks in parallel
4. After L1 complete, build L2 tasks in parallel
5. After L2 complete, build L3 tasks sequentially
6. Run `/iterate:sync $ARGUMENTS` after each layer

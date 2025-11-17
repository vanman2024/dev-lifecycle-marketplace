---
description: Transform sequential tasks.md into layered-tasks.md with parallel agent assignments and functional grouping
argument-hint: [spec-id]
allowed-tools: Task, Read, Write, Bash, Glob, Grep
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

Goal: Transform sequential task list into stratified layers with complexity-based agent assignments for parallel execution

Core Principles:
- Infrastructure First - foundation before features
- Use Before Build - prefer libraries over custom code
- Complexity Stratification - group by difficulty
- Parallel Execution - independent tasks run simultaneously

## Phase 1: Discovery
Goal: Locate and validate spec

Actions:
- If no arguments provided, list available specs:
  !{bash ls -d specs/[0-9][0-9][0-9]* 2>/dev/null | sed 's|specs/||'}
- Validate spec directory exists:
  !{bash test -d "specs/$ARGUMENTS" && echo "✅ Found: $ARGUMENTS" || echo "❌ Not found: $ARGUMENTS"}
- If spec not found, exit with error
- Load task-layering principles documentation:
  @plugins/iterate/task-layering.md

## Phase 2: Analysis
Goal: Load existing tasks

Actions:
- Check for tasks.md in spec:
  !{bash test -f "specs/$ARGUMENTS/tasks.md" && echo "✅ tasks.md exists" || echo "❌ tasks.md missing"}
- If tasks.md missing, check README.md for tasks section
- Load spec content:
  @specs/$ARGUMENTS/README.md
- Load existing tasks:
  @specs/$ARGUMENTS/tasks.md (if exists)
- Identify task count and complexity indicators

## Phase 3: Planning
Goal: Prepare for task layering

Actions:
- Create agent-tasks directory if needed:
  !{bash mkdir -p "specs/$ARGUMENTS/agent-tasks"}
- Determine layering strategy:
  - Identify foundation tasks (models, infrastructure)
  - Identify parallel-capable tasks
  - Identify integration tasks (require multiple components)
- Review task-layering skill documentation:
  @plugins/iterate/skills/task-layering/SKILL.md

## Phase 4: Implementation
Goal: Invoke task-layering agent

Actions:

Launch the task-layering agent to stratify tasks and create layered execution plan.

Provide the agent with:
- Context: Spec ID $ARGUMENTS
- Source tasks: specs/$ARGUMENTS/tasks.md
- Task-layering principles: Infrastructure First, Use Before Build, Complexity Stratification
- Requirements:
  - Analyze each task for complexity (Trivial 0, Simple 1, Moderate 2, Complex 3)
  - Identify dependencies and blocking relationships
  - Organize into layers (Foundation → Infrastructure → Features → Integration)
  - Assign tasks to appropriate agents based on complexity
  - Create layered-tasks.md with clear layer boundaries
  - Generate agent-specific task files for parallel execution
- Deliverables:
  - specs/$ARGUMENTS/agent-tasks/layered-tasks.md
  - specs/$ARGUMENTS/agent-tasks/AGENTS.md (agent assignment summary)
  - Optional: Individual agent task files if beneficial

## Phase 5: Verification
Goal: Validate layered tasks created

Actions:
- Check layered-tasks.md created:
  !{bash test -f "specs/$ARGUMENTS/agent-tasks/layered-tasks.md" && echo "✅ Created" || echo "❌ Failed"}
- Display file location and size:
  !{bash ls -lh "specs/$ARGUMENTS/agent-tasks/layered-tasks.md"}
- Show layer summary:
  !{bash grep -E "^## Layer|^### Layer" "specs/$ARGUMENTS/agent-tasks/layered-tasks.md" | head -20}

## Phase 6: Summary
Goal: Report results and next steps

Actions:
- Display: "Task layering complete for spec $ARGUMENTS"
- Show layers created and task distribution
- Provide file locations:
  - Layered tasks: specs/$ARGUMENTS/agent-tasks/layered-tasks.md
  - Agent assignments: specs/$ARGUMENTS/agent-tasks/AGENTS.md
- Suggest next steps:
  - "Review layered-tasks.md to validate layer structure"
  - "Check AGENTS.md for agent assignment distribution"
  - "Use /iterate:adjust to refine task assignments if needed"
  - "Begin parallel execution with assigned agents"
- Note: "Tasks are organized for maximum parallelization while respecting dependencies"

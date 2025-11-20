---
description: Execute feature/infrastructure implementation - single item or full parallel build across phases
argument-hint: [spec-id | --all | --infrastructure | --features]
allowed-tools: Read, Bash, Task, TodoWrite
---

**Arguments**: $ARGUMENTS

Goal: Execute implementation with intelligent phase orchestration. Delegates to execution-orchestrator agent for actual work.

**Modes:**
- *(no args)* - Auto-continue: find next incomplete item and execute it
- `<spec-id>` - Execute single infrastructure (I001) or feature (F001)
- `--all` - Execute EVERYTHING: all infrastructure phases, then all feature phases
- `--infrastructure` - Execute all infrastructure phases (0→1→2→3→4→5)
- `--features` - Execute all feature phases (after infrastructure validation)

**Automatic Plugin Detection:**
The system automatically detects which plugins to use by:
1. Reading each spec's tasks.md
2. Analyzing task keywords (auth, component, endpoint, streaming, etc.)
3. Matching to available plugins in settings.json
4. Using only the plugins that are enabled AND relevant to the task

**Parallel Execution:**
- Items WITHIN a phase run in parallel (I001, I002, I003 all Phase 0 → parallel)
- Phases run sequentially (Phase 0 completes → Phase 1 starts)

## Execution

Phase 1: Parse Arguments and Determine Mode
Goal: Understand what to execute

Actions:
- Create todo: "Execute implementation"
- Parse $ARGUMENTS:
  * If empty/no args: MODE = "auto-continue"
  * If `--all`: MODE = "full"
  * If `--infrastructure`: MODE = "infrastructure"
  * If `--features`: MODE = "features"
  * If starts with I (e.g., I001): MODE = "single-infrastructure"
  * If starts with F (e.g., F001): MODE = "single-feature"
  * Otherwise: MODE = "single" (legacy spec path)
- Display: "Mode: [MODE]"

Phase 2: Launch Execution Orchestrator Agent
Goal: Delegate to agent for actual execution

Actions:
- Launch execution-orchestrator agent with mode and target:

```
Task(
  description="Execute [MODE] implementation",
  subagent_type="implementation:execution-orchestrator",
  prompt="Execute implementation in [MODE] mode.

  Target: $ARGUMENTS
  Mode: [MODE]

  Read schema templates first:
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-detection/templates/project-json-schema.json
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/spec-management/templates/features-json-schema.json

  Then read project context:
  - .claude/project.json (infrastructure phases)
  - features.json (feature phases and dependencies)
  - .claude/settings.json (enabled plugins - this is your command source)

  Automatic Plugin Detection:
  - Read settings.json enabledPlugins to know what's available
  - For each task, analyze what it needs and find matching plugin commands
  - Only use commands from enabled plugins
  - If no matching plugin enabled, error with message

  For MODE=auto-continue:
  - Read .claude/execution/*.json to see what's been run
  - Check project.json infrastructure statuses
  - Check features.json feature statuses
  - Find next incomplete item in lowest incomplete phase
  - Execute it and continue to next
  - Keep going until user stops or everything is done

  For MODE=full/infrastructure/features:
  - Group items by phase
  - Execute phases sequentially (0→1→2→3→4→5)
  - Within each phase, launch parallel Task agents for all items
  - Wait for phase to complete before next
  - Update statuses in project.json/features.json

  For MODE=single-*:
  - Validate dependencies first
  - Execute single item's tasks
  - Update status when complete

  Return comprehensive summary with:
  - Items executed per phase
  - Success/failure counts
  - Plugins used
  - Duration
  - Any errors"
)
```

Phase 3: Display Results
Goal: Show execution summary

Actions:
- Display agent's execution summary
- Show next steps:
  * /quality:validate-code
  * /testing:test
  * /deployment:deploy
- Mark todo complete

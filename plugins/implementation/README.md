# Implementation Plugin

Orchestrate execution of layered tasks by mapping to tech-specific commands.

## Overview

The implementation plugin bridges the critical gap between planning/task-layering and quality phases by automatically executing the layered tasks using tech-specific commands.

## Commands

- `/implementation:execute` - Execute all layered tasks sequentially (L0→L3)
- `/implementation:execute-layer` - Execute specific layer only
- `/implementation:status` - Show execution progress and current state
- `/implementation:continue` - Resume execution after pause or failure
- `/implementation:map-task` - Preview task-to-command mapping (dry-run)

## Agents

- `execution-orchestrator` - Orchestrate layer-by-layer execution with auto-sync
- `task-mapper` - Map task descriptions to tech-specific commands intelligently
- `command-executor` - Execute commands with retry logic and error handling
- `progress-tracker` - Track and report execution status in .claude/execution/

## Skills

- `execution-tracking` - Execution status management and reporting (3 scripts, 5 templates, 3 examples)

## Usage

```bash
# 1. Create feature spec
/planning:add-feature "AI chat interface"

# 2. Layer tasks
/iterate:tasks F001

# 3. Execute implementation
/implementation:execute F001

# 4. Check progress
/implementation:status F001

# 5. Validate
/quality:validate-code F001
```

## License

MIT

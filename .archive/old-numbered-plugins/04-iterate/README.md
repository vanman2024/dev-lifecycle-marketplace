# 04-iterate Plugin

The **04-iterate** plugin handles refinement and adjustment during active development. It consolidates functionality from:
- multiagent-iterate
- multiagent-supervisor
- multiagent-refactoring
- multiagent-enhancement

## Installation

```bash
/plugin install 04-iterate@ai-dev-marketplace
```

## Commands

Commands available as /04-iterate:command-name

### Core Commands

- **/04-iterate** - Main orchestrator for iteration workflows
- **/04-iterate:tasks** - Task layering and breakdown
- **/04-iterate:start** - Start iteration cycle
- **/04-iterate:mid** - Mid-iteration checkpoint
- **/04-iterate:end** - End iteration and consolidate
- **/04-iterate:adjust** - Adjust implementation
- **/04-iterate:sync** - Sync changes and updates
- **/04-iterate:refactor** - Refactoring workflows
- **/04-iterate:enhance** - Enhancement workflows

## Skills

Auto-invoked by Claude when working on iteration tasks:
- **Iteration Tracking** - Tracks iteration progress and state
- **Worktree Management** - Git worktree helpers
- **Task Layering** - Breaks down specs into layered tasks
- **Refactoring Patterns** - Common refactoring patterns

## Workflow Example

```bash
# Typical iteration cycle
1. 01-core → Initialize project
2. 03-planning → Create specs and architecture
3. 04-iterate → Refine and enhance implementation

# Start iteration
/04-iterate:start feature-name

# Mid-iteration checkpoint
/04-iterate:mid

# Adjust as needed
/04-iterate:adjust

# End iteration
/04-iterate:end
```

## Design Principles

- **Project-Agnostic**: Works with any framework/stack
- **Workflow-Driven**: Follows iteration cycle patterns
- **Auto-Discovering**: No hardcoded paths or frameworks

---

**Part of**: ai-dev-marketplace lifecycle plugins
**Order**: 04 (after planning, during development)

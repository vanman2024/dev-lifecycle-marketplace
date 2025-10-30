# 03-planning Plugin

> Spec → Architecture: Create specs, plans, architecture, documentation

## Overview

The **03-planning** plugin handles the planning and architecture phase of the development lifecycle. It consolidates functionality from:
- multiagent-docs
- multiagent-notes
- multiagent-idea
- multiagent-cto

## Purpose

Transform ideas into structured plans, specifications, and architectural decisions that guide development.

## Commands

### Orchestrator Command
- `/planning` - Master command that chains granular planning commands based on context

### Granular Commands
- `/spec` - Create feature specifications and requirements
- `/plan` - Generate implementation plans
- `/architecture` - Design system architecture
- `/roadmap` - Create project roadmaps and timelines
- `/notes` - Manage development notes and decisions
- `/decide` - Track architectural decisions (ADRs)

## Skills

### Model-Invoked (Auto-loaded)
- **Spec Management** - Templates and patterns for requirements docs
- **Architecture Patterns** - Common architectural patterns and best practices
- **Decision Tracking** - ADR (Architecture Decision Records) management

## Installation

### From Marketplace
```bash
/plugin marketplace add multiagent-marketplace/ai-dev-marketplace
/plugin install 03-planning@ai-dev-marketplace
```

### Local Development
```bash
# Already included in ai-dev-marketplace
# Commands available as /03-planning:command-name
```

## Usage Examples

### Create a Feature Spec
```bash
/03-planning:spec user-authentication
```

### Generate Implementation Plan
```bash
/03-planning:plan payment-integration
```

### Design Architecture
```bash
/03-planning:architecture microservices
```

### Track Decisions
```bash
/03-planning:decide database-choice
```

### Master Orchestrator
```bash
# Analyzes context and runs appropriate planning commands
/03-planning
```

## Project-Agnostic Design

This plugin works with any project structure:
- Detects framework from `.claude/project.json`
- Adapts templates to project context
- No hard-coded paths or assumptions

## Integration with Other Lifecycle Plugins

**Workflow Position**: Phase 2 of 6
- **After**: `01-core` (foundation setup)
- **Before**: `03-develop` (implementation)

**Typical Chain**:
1. `01-core` → Initialize project, detect stack
2. `03-planning` → Create specs and architecture
3. `03-develop` → Implement features
4. `04-iterate` → Refine and adjust
5. `05-quality` → Test and validate
6. `06-deploy` → Deploy to production

## Directory Structure

```
03-planning/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/                 # Slash commands (auto-discovered)
│   ├── planning.md          # Orchestrator
│   ├── spec.md
│   ├── plan.md
│   ├── architecture.md
│   ├── roadmap.md
│   ├── notes.md
│   └── decide.md
├── skills/                   # Agent skills (auto-discovered)
│   ├── spec-management/
│   ├── architecture-patterns/
│   └── decision-tracking/
├── scripts/                  # Utility scripts
├── docs/                     # Additional documentation
├── .gitignore
├── .mcp.json                # MCP server config
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Contributing

This plugin follows the lifecycle plugin architecture:
- 1 orchestrator command
- 6 granular commands
- 3 skills

See `plugins/multiagent-build-system/docs/06-lifecycle-plugin-architecture.md` for details.

## License

MIT License - See LICENSE file for details

## Version

1.0.0 - Initial release

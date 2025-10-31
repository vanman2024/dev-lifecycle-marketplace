---
description: Create development roadmap and timeline
argument-hint: [timeframe]
allowed-tools: Task, Read, Write, Bash, Glob, Grep, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Create project roadmap with milestones, phases, and timeline for development

Core Principles:
- Realistic - based on actual specs and tasks
- Phased - organized into logical phases
- Flexible - can be updated as project evolves
- Visual - clear timeline representation

## Phase 1: Discovery
Goal: Understand roadmap scope

Actions:
- Parse $ARGUMENTS for timeframe (quarterly, annual, release-based)
- Load all existing specs
- Example: !{bash find specs -name "README.md" -type f}
- Load architecture documentation
- Example: @docs/architecture/README.md
- Check for existing roadmap
- Example: !{bash test -f docs/ROADMAP.md && echo "exists"}

## Phase 2: Analysis
Goal: Analyze project scope

Actions:
- Review all specs for estimation
- Identify dependencies between specs
- Determine phases and milestones
- If unclear, use AskUserQuestion to ask:
  - What's the target timeline?
  - Any fixed milestones or deadlines?
  - Priority order for features?

## Phase 3: Planning
Goal: Structure roadmap

Actions:
- Organize into phases:
  - Phase 1: Foundation
  - Phase 2: Core Features
  - Phase 3: Advanced Features
  - Phase 4: Polish and Launch
- Identify milestones
- Estimate timelines based on task complexity

## Phase 4: Implementation
Goal: Create roadmap with agent

Actions:

Launch the roadmap-planner agent to create the project roadmap.

Provide the agent with:
- Context: All specs, architecture, current progress
- Timeframe: $ARGUMENTS
- Requirements:
  - Create phased roadmap
  - Define milestones
  - Estimate timelines
  - Show dependencies
  - Include risk assessment
  - Provide visual timeline (mermaid gantt chart)
- Expected output: docs/ROADMAP.md

## Phase 5: Review
Goal: Verify roadmap

Actions:
- Check roadmap created
- Example: @docs/ROADMAP.md
- Verify all specs included
- Confirm timeline realistic

## Phase 6: Summary
Goal: Report roadmap creation

Actions:
- Display: "Roadmap created: docs/ROADMAP.md"
- Show key milestones
- Suggest: "Review and adjust timeline as needed"
- Note: "Use /iterate:tasks to break down each phase"

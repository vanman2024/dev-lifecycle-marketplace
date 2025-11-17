---
description: Create development roadmap and timeline
argument-hint: [timeframe] [--refresh]
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


## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Create project roadmap with milestones, phases, and timeline for development

Core Principles:
- Realistic - based on actual specs and tasks
- Phased - organized into logical phases
- Flexible - can be updated as project evolves
- Visual - clear timeline representation

## Available Skills

This commands has access to the following skills from the planning plugin:

- **architecture-patterns**: Architecture design templates, mermaid diagrams, documentation patterns, and validation tools. Use when designing system architecture, creating architecture documentation, generating mermaid diagrams, documenting component relationships, designing data flows, planning deployments, creating API architectures, or when user mentions architecture diagrams, system design, mermaid, architecture documentation, or component design.
- **decision-tracking**: Architecture Decision Records (ADR) templates, sequential numbering, decision documentation patterns, and decision history management. Use when creating ADRs, documenting architectural decisions, tracking decision rationale, managing decision lifecycle, superseding decisions, searching decision history, or when user mentions ADR, architecture decision, decision record, decision tracking, or decision documentation.
- **spec-management**: Templates, scripts, and examples for managing feature specifications in specs/ directory. Use when creating feature specs, listing specifications, validating spec completeness, updating spec status, searching spec content, organizing project requirements, tracking feature development, managing technical documentation, or when user mentions spec management, feature specifications, requirements docs, spec validation, or specification organization.

**To use a skill:**
```
!{skill skill-name}
```

Use skills when you need:
- Domain-specific templates and examples
- Validation scripts and automation
- Best practices and patterns
- Configuration generators

Skills provide pre-built resources to accelerate your work.

---


## Phase 1: Discovery
Goal: Understand roadmap scope

Actions:
- Parse $ARGUMENTS for:
  - Timeframe (quarterly, annual, release-based)
  - Flags: --refresh (regenerate from current specs)
- Load all existing specs
- Example: !{bash find specs -name "README.md" -type f}
- Load architecture documentation
- Example: @docs/architecture/README.md
- Check for existing roadmap
- Example: !{bash test -f docs/ROADMAP.md && echo "exists" || echo "new"}
- If --refresh flag present:
  - Display: "🔄 Refreshing roadmap from current specs and architecture"
  - Backup existing roadmap: !{bash cp docs/ROADMAP.md docs/ROADMAP.backup.md 2>/dev/null || true}

## Phase 2: Analysis
Goal: Analyze project scope

Actions:
- Check for wizard requirements (if /planning:wizard was run):
  - Load: @docs/requirements/*/01-initial-request.md
  - Load: @docs/requirements/*/.wizard/extracted-requirements.json
  - Load: @docs/requirements/*/02-wizard-qa.md
  - These contain: features, constraints, timeline, priorities
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

Task(description="Create project roadmap", subagent_type="planning:roadmap-planner", prompt="You are the roadmap-planner agent. Create project roadmap for $ARGUMENTS.

Context:
- Wizard requirements (if available): docs/requirements/*/01-initial-request.md, docs/requirements/*/.wizard/extracted-requirements.json, docs/requirements/*/02-wizard-qa.md
- All specs: specs/*/
- Architecture: docs/architecture/
- Timeframe: $ARGUMENTS

Requirements:
  - Read wizard requirements first (if they exist) to understand features, priorities, constraints
  - Create phased roadmap
  - Define milestones
  - Estimate timelines
  - Show dependencies
  - Include risk assessment
  - Provide visual timeline (mermaid gantt chart)

Deliverable: docs/ROADMAP.md with comprehensive project timeline")

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
- If --refresh flag was used:
  - Display: "✅ Roadmap refreshed: docs/ROADMAP.md"
  - Display: "📋 Backup saved: docs/ROADMAP.backup.md"
  - Display: "🔍 Review changes to ensure timeline still accurate"
- Else:
  - Display: "✅ Roadmap created: docs/ROADMAP.md"
- Show key milestones
- Suggest: "Review and adjust timeline as needed"
- Note: "Use /iterate:tasks to break down each phase"
- Tip: "Use --refresh flag to regenerate roadmap after spec changes"

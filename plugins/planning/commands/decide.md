---
description: Create Architecture Decision Records (ADRs)
argument-hint: [decision-title]
allowed-tools: Task, Read, Write, Bash, Glob, Grep, AskUserQuestion, Skill
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

Goal: Document architectural decisions as ADRs with proper numbering, context, and rationale

Core Principles:
- Structured format - consistent ADR template
- Numbered sequence - automatic ADR numbering
- Immutable - decisions are recorded, not changed
- Searchable - easy to find past decisions

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
Goal: Understand decision to document

Actions:
- Parse $ARGUMENTS for decision title
- Check for existing ADRs directory
- Example: !{bash ls docs/adr/ 2>/dev/null | wc -l}
- Determine next ADR number
- Example: !{bash ls docs/adr/*.md 2>/dev/null | tail -1}

## Phase 2: Analysis
Goal: Gather decision context

Actions:
- Check for wizard requirements (if /planning:wizard was run):
  - Load: @docs/requirements/*/01-initial-request.md
  - Load: @docs/requirements/*/.wizard/extracted-requirements.json
  - Load: @docs/requirements/*/02-wizard-qa.md
  - These may identify architectural decisions to document
- If decision unclear, use AskUserQuestion to ask:
  - What decision was made?
  - What were the alternatives considered?
  - Why was this chosen?
- Load project context: @.claude/project.json
- Review related architecture: @docs/architecture/

## Phase 3: Planning
Goal: Structure ADR content

Actions:
- Outline ADR sections:
  - Title and status
  - Context and problem
  - Decision made
  - Alternatives considered
  - Consequences
  - References

## Phase 4: Implementation
Goal: Create ADR with agent

Actions:

Task(description="Create ADR", subagent_type="planning:decision-documenter", prompt="You are the decision-documenter agent. Create Architecture Decision Record for $ARGUMENTS.

Context:
- Project stack: .claude/project.json
- Architecture docs: docs/architecture/
- Wizard requirements (if available): docs/requirements/*/01-initial-request.md, docs/requirements/*/.wizard/extracted-requirements.json, docs/requirements/*/02-wizard-qa.md
- Decision: $ARGUMENTS

Requirements:
  - Read wizard requirements first (if they exist) to understand project context
  - Follow ADR template format
  - Number sequentially (ADR-XXXX)
  - Include all required sections
  - Link to related specs/architecture
  - Use decision-tracking skill templates

Deliverable: docs/adr/XXXX-decision-title.md")

## Phase 5: Review
Goal: Verify ADR created

Actions:
- Check ADR file exists and is complete
- Example: @docs/adr/XXXX-*.md
- Verify all sections present
- Update ADR index if exists

## Phase 6: Documentation Sync & Implementation Tracking

Goal: Register ADR and identify implementing specs

Actions:
- Sync ADR to Mem0 documentation registry:
  !{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet 2>/dev/null && echo "✅ ADR registered in documentation system" || echo "⚠️  Doc sync unavailable (mem0 not installed)"}

- Query which specs implement this ADR:
  !{bash if [ -f /tmp/mem0-env/bin/activate ]; then ADR_NUM=$(ls -1 docs/adr/*.md 2>/dev/null | tail -1 | grep -oP '\d+' | head -1); if [ -n "$ADR_NUM" ]; then source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What specs implement ADR-$ADR_NUM?" 2>/dev/null | grep -E "Specification|implement" | head -10 || echo "ℹ️  No specs yet implement this ADR"; fi; fi}

- Display implementing specs (if any)
- This tracks:
  - Which specs are implementing this decision
  - Where this ADR is being applied
  - What features are affected

## Phase 7: Summary
Goal: Report ADR creation

Actions:
- Display: "Created ADR-XXXX: {title}"
- Show file location
- Suggest: "ADRs are immutable - create new ADR to supersede"

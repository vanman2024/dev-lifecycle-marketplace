---
description: Create Architecture Decision Records (ADRs)
argument-hint: [decision-title]
allowed-tools: Task, Read, Write, Bash, Glob, Grep, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Document architectural decisions as ADRs with proper numbering, context, and rationale

Core Principles:
- Structured format - consistent ADR template
- Numbered sequence - automatic ADR numbering
- Immutable - decisions are recorded, not changed
- Searchable - easy to find past decisions

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

Context: Project stack and architecture
Decision: $ARGUMENTS

Requirements:
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

## Phase 6: Summary
Goal: Report ADR creation

Actions:
- Display: "Created ADR-XXXX: {title}"
- Show file location
- Suggest: "ADRs are immutable - create new ADR to supersede"

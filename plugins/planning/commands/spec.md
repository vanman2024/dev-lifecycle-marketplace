---
description: Create, list, and validate specifications in specs/ directory
argument-hint: <action> [spec-name]
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

Goal: Manage feature specifications in the specs/ directory - create new specs, list existing ones, and validate spec completeness

Core Principles:
- Framework-agnostic - works with any tech stack
- Structured format - consistent spec template
- Validate completeness - ensure all required sections present
- Support iteration - specs guide task layering in iterate plugin

## Available Skills

This commands has access to the following skills from the planning plugin:

- **architecture-patterns**: Architecture design templates, mermaid diagrams, documentation patterns, and validation tools. Use when designing system architecture, creating architecture documentation, generating mermaid diagrams, documenting component relationships, designing data flows, planning deployments, creating API architectures, or when user mentions architecture diagrams, system design, mermaid, architecture documentation, or component design.
- **decision-tracking**: Architecture Decision Records (ADR) templates, sequential numbering, decision documentation patterns, and decision history management. Use when creating ADRs, documenting architectural decisions, tracking decision rationale, managing decision lifecycle, superseding decisions, searching decision history, or when user mentions ADR, architecture decision, decision record, decision tracking, or decision documentation.
- **doc-sync**: Documentation synchronization using Mem0 for tracking relationships between specs, architecture, ADRs, and roadmap. Use when syncing documentation, querying documentation relationships, finding impact of changes, validating doc consistency, or when user mentions doc sync, documentation tracking, spec dependencies, architecture references, or impact analysis.
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

Goal: Understand the requested action and current spec state

Actions:
- Parse $ARGUMENTS for action (create, list, validate, show)
- Check if specs/ directory exists
- Example: !{bash test -d specs && echo "exists" || echo "missing"}
- If missing and creating, will create it
- Load existing specs if listing or validating
- Example: !{bash find specs -name "*.md" -type f 2>/dev/null | head -20}

## Phase 2: Analysis

Goal: Determine what needs to be done

Actions:
- For 'create' action:
  - If spec name not provided, use AskUserQuestion to ask:
    - What feature are you specifying?
    - Brief description?
    - Any specific requirements?
  - Determine next spec number (001, 002, etc.)
  - Example: !{bash ls -d specs/[0-9][0-9][0-9] 2>/dev/null | tail -1}

- For 'list' action:
  - Read all spec directories
  - Load spec metadata (name, status, date)

- For 'validate' action:
  - Load spec to validate
  - Check for required sections

- For 'show' action:
  - Display specific spec content

## Phase 3: Planning

Goal: Prepare for spec operation

Actions:
- For create: Outline spec structure sections
- For validate: Define validation criteria
- For list: Format output structure
- Review spec-management skill templates
- Confirm approach if significant

## Phase 4: Implementation

Goal: Execute spec operation with agent

Actions:

Task(description="Handle spec operation", subagent_type="planning:spec-writer", prompt="You are the spec-writer agent. Handle specification operation for $ARGUMENTS.

Context: Current specs/ directory state
Action: $ARGUMENTS (create, list, validate, show)

Requirements:
  - For create: Generate complete specification with:
    - Overview and goals
    - Requirements (functional, non-functional)
    - Technical approach
    - Tasks breakdown
    - Success criteria
    - Dependencies
  - For list: Show all specs with status
  - For validate: Check completeness of spec sections
  - For show: Display spec in readable format

Template: Use spec-management skill templates
Deliverable: Created/updated spec file or validation report")

## Phase 5: Review

Goal: Verify spec operation results

Actions:
- Check agent's output
- Verify spec file created/updated (for create)
- Validate spec structure (for validate)
- Example: @specs/XXX/README.md (to verify content)
- Ensure all required sections present

## Phase 6: Documentation Sync

Goal: Register spec in documentation system

Actions:
- If action was 'create' or 'update':
  - Sync spec to Mem0 documentation registry:
    !{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet 2>/dev/null && echo "✅ Spec registered in documentation system" || echo "⚠️  Doc sync unavailable (mem0 not installed)"}
  - This registers:
    - Architecture document references
    - ADR implementations
    - Spec dependencies
    - Creation/modification timestamps
- If action was 'list' or 'validate':
  - Skip sync (no changes made)

## Phase 7: Summary

Goal: Report what was accomplished

Actions:
- Display summary based on action:
  - For create: "Created specification: specs/{number}/{name}"
  - For list: "{count} specifications found"
  - For validate: "Validation result: {status}"
  - For show: "Displaying spec: {name}"
- Show spec location and structure
- Suggest next steps:
  - After create: "Run /iterate:tasks {spec-number} to create layered tasks"
  - After validate: "Address missing sections if any"
  - General: "Use /planning:architecture to design technical approach"

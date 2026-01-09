---
description: Capture technical notes and development journal
argument-hint: [note-topic]
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

Goal: Capture technical notes, decisions, learnings, and development journal entries

Core Principles:
- Quick capture - low friction for note-taking
- Searchable - easy to find past notes
- Dated - timestamped entries
- Organized - categorized by topic

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
Goal: Understand note request

Actions:
- Parse $ARGUMENTS for note topic or search query
- Check for notes directory
- Example: !{bash test -d docs/notes && echo "exists" || mkdir -p docs/notes}
- Determine action (create, search, list)

## Phase 2: Validation
Goal: Prepare for note operation

Actions:
- For create: If topic not provided, ask user for note content
- For search: Parse search terms
- For list: Determine sorting (date, topic)

## Phase 3: Execution
Goal: Perform note operation

Actions:
- For create:
  - Create timestamped note file
  - Example: docs/notes/YYYY-MM-DD-topic.md
  - Add frontmatter with metadata
  - Write note content

- For search:
  - Search note contents
  - Example: !{bash grep -r "$ARGUMENTS" docs/notes/}

- For list:
  - List all notes with summaries
  - Example: !{bash ls -lt docs/notes/*.md | head -20}

## Phase 4: Summary
Goal: Report note operation result

Actions:
- For create: "Note created: docs/notes/{filename}"
- For search: "Found {count} notes matching query"
- For list: "Showing {count} notes"
- Suggest: "Use /planning:notes search <term> to find notes"

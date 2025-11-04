---
description: Gather clarification on ambiguous requirements, specs, or tasks through structured questions. Helps resolve uncertainty before implementation.
argument-hint: [spec-name or topic]
allowed-tools: Read, AskUserQuestion, Write, Bash, Grep, Glob
---
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



## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Arguments**: $ARGUMENTS

Goal: Resolve ambiguity and gather missing information through structured clarification questions

Core Principles:
- Ask before assuming - get clarity on uncertain requirements
- Structured questions - use AskUserQuestion for clear options
- Document answers - update specs with clarifications
- Prevent rework - resolve uncertainty upfront

Phase 1: Identify Ambiguities
Goal: Find what needs clarification

Actions:
- Parse $ARGUMENTS for spec name or topic to clarify
- If spec provided, load it: @specs/$SPEC_NAME/spec.md
- If no spec provided, ask what needs clarification
- Analyze for ambiguities:
  - Vague requirements ("user-friendly", "fast", "secure")
  - Missing acceptance criteria
  - Unclear technical decisions
  - Multiple interpretations possible
  - Dependencies or constraints not specified
- List all ambiguous items found
- Prioritize by impact on implementation

Phase 2: Structure Clarification Questions
Goal: Prepare clear, actionable questions

Actions:
- For each ambiguity, formulate structured question
- Use AskUserQuestion with specific options:
  - Question: Clear, specific question about the ambiguity
  - Header: Short label (max 12 chars)
  - Options: 2-4 concrete choices with descriptions
  - MultiSelect: true if multiple choices applicable
- Group related questions together
- Limit to 4 questions per batch (tool constraint)
- Example question structure:
  - Header: "Auth method"
  - Question: "Which authentication method should we use?"
  - Options:
    - JWT: "Stateless tokens, good for APIs"
    - Sessions: "Server-side state, traditional web apps"
    - OAuth: "Third-party login (Google, GitHub)"

Phase 3: Gather Clarifications
Goal: Get answers from user through structured questions

Actions:
- Use AskUserQuestion to present questions
- Ask up to 4 questions at a time (tool limit)
- If more than 4 ambiguities, batch them
- Capture all responses
- For "Other" responses, ask follow-up for details
- Confirm understanding of answers

Phase 4: Document Clarifications
Goal: Update specs with resolved information

Actions:
- If spec file exists, update it with clarifications:
  - Add resolved details to appropriate sections
  - Update acceptance criteria with specifics
  - Add technical decisions to plan.md
  - Mark ambiguities as resolved
- If no spec file, create clarification summary document
- Use Write or Edit to update files
- Format clarifications clearly:
  - **Question**: Original ambiguity
  - **Answer**: User's response
  - **Impact**: What this clarifies for implementation

Phase 5: Validate Completeness
Goal: Ensure no critical ambiguities remain

Actions:
- Review updated spec or topic
- Check for remaining uncertainties
- List any follow-up questions needed
- Verify acceptance criteria are now clear
- Confirm technical approach is defined

Phase 6: Summary
Goal: Report clarification results

Actions:
- Display summary:
  - **Topic**: What was clarified
  - **Ambiguities Resolved**: Count
  - **Key Decisions**:
    - List each clarification with answer
  - **Files Updated**: Specs or docs modified
  - **Remaining Questions**: Any unresolved items

- If spec was updated:
  - Show what changed
  - Recommend next steps: /planning:spec validate

- If creating new spec:
  - Suggest: /planning:spec create with clarified requirements

- Provide implementation guidance based on clarifications

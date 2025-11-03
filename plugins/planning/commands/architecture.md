---
description: Design and document system architecture
argument-hint: <action> [architecture-name]
allowed-tools: Task, Read, Write, Bash, Glob, Grep, AskUserQuestion
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

Goal: Design and document system architecture including component diagrams, data flows, infrastructure, and technical decisions

Core Principles:
- Framework-agnostic - works with any detected tech stack
- Comprehensive - covers all architectural aspects
- Visual - includes diagrams and flow charts
- Adaptable - aligns with detected stack from .claude/project.json

## Phase 1: Discovery

Goal: Understand the architecture request and current project state

Actions:
- Parse $ARGUMENTS for action (design, update, diagram, review)
- Load detected tech stack: @.claude/project.json
- Check for existing architecture documentation
- Example: !{bash find docs -name "architecture*.md" 2>/dev/null}
- Identify architecture scope (frontend, backend, database, infrastructure, all)

## Phase 2: Analysis

Goal: Analyze project structure and determine architectural needs

Actions:
- Review project structure and components
- Example: !{bash find . -type d -name "src" -o -name "app" -o -name "api" | head -10}
- Identify key architectural areas:
  - Frontend architecture (if detected)
  - Backend/API architecture (if detected)
  - Database schema and relationships
  - Infrastructure and deployment
  - Integration points
- Load any existing specs for context
- Example: @specs/*/README.md

## Phase 3: Planning

Goal: Outline architectural approach

Actions:
- If action unclear, use AskUserQuestion to ask:
  - What architectural aspect to focus on?
  - High-level or detailed design?
  - Any specific concerns (scalability, security, performance)?
- Determine documentation structure:
  - System overview
  - Component architecture
  - Data architecture
  - Infrastructure architecture
  - Security architecture
  - Integration architecture

## Phase 4: Implementation

Goal: Execute architecture design with agent

Actions:

Task(description="Design system architecture", subagent_type="planning:architecture-designer", prompt="You are the architecture-designer agent. Create system architecture for $ARGUMENTS.

Context: Detected tech stack from .claude/project.json
Action: $ARGUMENTS (design, update, diagram, review)

Requirements:
  - Create comprehensive architecture documentation including:
    - System overview and goals
    - Component diagrams
    - Data flow diagrams
    - Database schema design
    - API architecture
    - Infrastructure design
    - Security architecture
    - Deployment architecture
    - Integration patterns
  - Adapt to detected stack (Next.js, FastAPI, AI SDKs, etc.)
  - Use architecture-patterns skill templates

Deliverable: Complete architecture documentation with mermaid diagrams in docs/architecture/")

## Phase 5: Review

Goal: Verify architecture documentation

Actions:
- Check agent's output for completeness
- Verify architecture file created/updated
- Example: @docs/architecture/README.md
- Ensure all key areas covered:
  - Components ✓
  - Data flows ✓
  - Infrastructure ✓
  - Security ✓

## Phase 6: Summary

Goal: Report architecture design results

Actions:
- Display summary:
  - "Architecture documented: docs/architecture/"
  - List main sections created
  - Highlight key architectural decisions
- Show next steps:
  - "Review architecture with team"
  - "Use /planning:decide to document key decisions as ADRs"
  - "Create specs based on architectural components"
  - "Use architecture to guide /iterate:tasks assignments"

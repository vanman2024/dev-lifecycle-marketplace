---
allowed-tools: Task, Read, Write, Bash, Grep, Glob
description: Design system architecture and technical decisions
argument-hint: <feature-name|--full>
---

**Arguments**: $ARGUMENTS

## Step 1: Determine Scope

Check if full system architecture or feature-specific:

!{bash test "$ARGUMENTS" = "--full" && echo "Full system architecture" || echo "Feature architecture: $ARGUMENTS"}

## Step 2: Gather Context

Load project configuration:

@.claude/project.json

Analyze existing architecture:

!{bash find . -name "ARCHITECTURE.md" -o -name "architecture.md" 2>/dev/null | head -1}

Check for specs:

!{bash test -d "specs/$ARGUMENTS" && echo "Spec exists" || echo "No spec found"}

## Step 3: Load Relevant Documentation

If spec exists, load it:

@specs/$ARGUMENTS/spec.md

Scan existing codebase structure:

!{bash find . -type d -name "src" -o -name "lib" -o -name "components" 2>/dev/null | head -10}

## Step 4: Design Architecture

Task(
  description="Design system architecture",
  subagent_type="architecture-designer",
  prompt="Design architecture for: $ARGUMENTS

**Context:**
- Project framework and stack from .claude/project.json
- Existing codebase structure
- Specifications (if available)

**Your Task:**

Create architecture document at appropriate location:
- If --full: Create/update ARCHITECTURE.md at project root
- If feature: Create specs/$ARGUMENTS/architecture.md

**Architecture Document Should Include:**

1. **System Overview**
   - High-level architecture diagram (mermaid)
   - Key components and their responsibilities
   - Data flow between components

2. **Component Design**
   - Frontend components (if applicable)
   - Backend services (if applicable)
   - Data models and schema
   - API contracts

3. **Technology Stack**
   - Frameworks and libraries (detected from project)
   - Database choices
   - External services/APIs
   - Infrastructure requirements

4. **Design Patterns**
   - Architectural patterns used (MVC, microservices, etc.)
   - Design patterns for common problems
   - Code organization principles

5. **Data Architecture**
   - Database schema design
   - Data relationships
   - Caching strategy
   - State management approach

6. **API Design**
   - RESTful endpoints (if applicable)
   - GraphQL schema (if applicable)
   - WebSocket events (if applicable)
   - Request/response formats

7. **Security Considerations**
   - Authentication approach
   - Authorization model
   - Data protection
   - Security best practices

8. **Scalability & Performance**
   - Performance requirements
   - Scalability considerations
   - Optimization strategies
   - Monitoring approach

**Format:**
- Use mermaid diagrams for visual representation
- Include code examples for key patterns
- Reference existing architecture where applicable
- Keep it practical and actionable

**Output:**
Complete architecture document with diagrams and detailed explanations."
)

## Step 5: Verify Architecture Document

Check that architecture document was created:

!{bash test "$ARGUMENTS" = "--full" && test -f "ARCHITECTURE.md" && echo "✅ System architecture created" || test -f "specs/$ARGUMENTS/architecture.md" && echo "✅ Feature architecture created" || echo "⚠️  Architecture creation incomplete"}

## Step 6: Display Summary

Show what was created:

!{bash test "$ARGUMENTS" = "--full" && echo "📐 System architecture: ARCHITECTURE.md" || echo "📐 Feature architecture: specs/$ARGUMENTS/architecture.md"}

**Next Steps:**
- Review architecture design
- Use /03-planning:decide to document key architectural decisions
- Begin implementation with /03-develop commands

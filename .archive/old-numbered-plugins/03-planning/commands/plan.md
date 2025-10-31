---
allowed-tools: Task, Read, Write, Bash, Grep, Glob
description: Generate implementation plans from specs
argument-hint: <spec-name>
---

**Arguments**: $ARGUMENTS

## Step 1: Validate Spec Exists

Check that spec directory exists:

!{bash test -d "specs/$ARGUMENTS" && echo "✅ Found spec: $ARGUMENTS" || echo "❌ Spec not found. Run /03-planning:spec first"}

## Step 2: Load Existing Spec

Read the specification document:

@specs/$ARGUMENTS/spec.md

Load tasks if they exist:

@specs/$ARGUMENTS/tasks.md

## Step 3: Analyze Project Context

Check project configuration:

@.claude/project.json

Identify project structure:

!{bash ls -d src/ app/ lib/ components/ 2>/dev/null | head -5}

## Step 4: Generate Implementation Plan

Task(
  description="Generate detailed implementation plan",
  subagent_type="spec-writer",
  prompt="Create a detailed implementation plan for: $ARGUMENTS

**Context:**
You have access to:
- specs/$ARGUMENTS/spec.md (requirements)
- specs/$ARGUMENTS/tasks.md (task breakdown)
- Project structure and framework

**Your Task:**

Update or create specs/$ARGUMENTS/plan.md with:

1. **Implementation Approach**
   - High-level strategy
   - Technology choices (based on detected framework)
   - Architecture patterns to follow

2. **Phase Breakdown**
   - Phase 1: Foundation (what to build first)
   - Phase 2: Core Features (main functionality)
   - Phase 3: Integration (connecting components)
   - Phase 4: Polish (refinement and optimization)

3. **Integration Points**
   - Where this connects to existing code
   - APIs or interfaces to create/modify
   - Database schema changes if applicable

4. **Testing Strategy**
   - Unit test approach
   - Integration test requirements
   - E2E test scenarios

5. **Rollout Plan**
   - Feature flags if needed
   - Migration strategy
   - Deployment approach

6. **Risk Mitigation**
   - Technical risks identified
   - Mitigation strategies
   - Contingency plans

**Format:**
- Clear, actionable markdown
- Include code examples for key patterns
- Add mermaid diagrams for complex flows
- Reference existing code where applicable

**Output:**
Update specs/$ARGUMENTS/plan.md with comprehensive implementation guidance."
)

## Step 5: Verify Plan Created

Check that plan was created:

!{bash test -f "specs/$ARGUMENTS/plan.md" && echo "✅ Implementation plan created" || echo "⚠️  Plan creation incomplete"}

## Step 6: Display Summary

Show plan location:

!{bash echo "✅ Implementation plan: specs/$ARGUMENTS/plan.md"}

**Next Steps:**
- Review the implementation plan
- Use /04-iterate:tasks to break down into parallel work
- Begin development with /03-develop commands

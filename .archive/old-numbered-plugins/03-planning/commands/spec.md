---
allowed-tools: Task, Read, Write, Bash, Grep, Glob
description: Create feature specifications and requirements documents
argument-hint: <spec-name>
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


**Arguments**: $ARGUMENTS

## Step 1: Validate Spec Name

Check that spec name is provided:

!{bash test -n "$ARGUMENTS" && echo "Creating spec: $ARGUMENTS" || echo "ERROR: Spec name required"}

## Step 2: Create Spec Directory

Initialize spec directory structure:

!{bash mkdir -p "specs/$ARGUMENTS" && echo "✅ Created specs/$ARGUMENTS" || echo "❌ Failed to create directory"}

## Step 3: Gather Project Context

Load project configuration if available:

@.claude/project.json

Check for existing documentation:

!{bash find . -maxdepth 2 -name "README.md" -o -name "ARCHITECTURE.md" 2>/dev/null | head -5}

## Step 4: Delegate to Spec Creation Agent

Task(
  description="Create comprehensive specification",
  subagent_type="spec-writer",
  prompt="Create a comprehensive feature specification for: $ARGUMENTS

**Your Task:**

Create the following files in specs/$ARGUMENTS/:

1. **spec.md** - Comprehensive requirements document
   - Problem statement
   - Requirements (functional + non-functional)
   - Success criteria
   - Out of scope
   - Dependencies and constraints

2. **tasks.md** - Sequential task breakdown
   - Break down into actionable tasks
   - Add complexity ratings (trivial/simple/moderate/complex)
   - Identify dependencies between tasks
   - Estimate effort for each task

3. **plan.md** - Implementation roadmap
   - Implementation approach
   - Integration points
   - Testing strategy
   - Rollout plan

4. **quickstart.md** - Quick reference summary
   - Key points from spec
   - Quick start guide
   - Essential commands/workflows

**Context:**
- Analyze existing codebase structure
- Identify integration points
- Consider project framework and stack
- Ensure requirements are testable and measurable

**Format:**
- Use clear, concise markdown
- Include code examples where helpful
- Add diagrams (mermaid) for complex flows
- Link to related documentation

**Deliverables:**
All four files created in specs/$ARGUMENTS/ with complete, actionable content."
)

## Step 5: Validate Spec Structure

Verify all required files were created:

!{bash ls specs/$ARGUMENTS/*.md 2>/dev/null | wc -l | xargs -I {} echo "Created {} specification files"}

## Step 6: Display Summary

Show what was created:

!{bash echo "✅ Specification created at: specs/$ARGUMENTS/"}
!{bash echo ""}
!{bash echo "Files:"}
!{bash ls -1 specs/$ARGUMENTS/*.md 2>/dev/null}

**Next Steps:**
- Review specs/$ARGUMENTS/spec.md for requirements
- Use /03-planning:plan to refine implementation approach
- Use /04-iterate:tasks to stratify tasks by complexity
- Begin development with /03-develop commands

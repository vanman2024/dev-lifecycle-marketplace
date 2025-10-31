---
allowed-tools: Task, Read, Write, Bash, Grep, Glob, SlashCommand, AskUserQuestion
description: Master orchestrator that chains granular planning commands based on context. Analyzes project needs and runs appropriate planning workflows.
argument-hint: [feature-name|--full]
---

**Arguments**: $ARGUMENTS

## Step 1: Detect Planning Context

Analyze what planning is needed:

!{bash test -f .claude/project.json && echo "✅ Project initialized" || echo "⚠️  Run /01-core:init first"}

Check for existing specs:

!{bash ls -d specs/*/ 2>/dev/null | wc -l | xargs -I {} echo "Found {} existing specs"}

## Step 2: Determine Planning Phase

Based on context, identify what planning is needed:

!{bash test -n "$ARGUMENTS" && echo "Planning for: $ARGUMENTS" || echo "Interactive planning mode"}

## Step 3: Route to Appropriate Planning Commands

**Pattern: Sequential Orchestration with SlashCommands**

### If creating new feature/project spec:

SlashCommand: /03-planning:spec $ARGUMENTS

Wait for spec creation to complete.

### If spec exists, generate implementation plan:

SlashCommand: /03-planning:plan $ARGUMENTS

Wait for plan generation to complete.

### If architecture design is needed:

SlashCommand: /03-planning:architecture $ARGUMENTS

Wait for architecture design to complete.

### If building roadmap (--full flag or comprehensive planning):

SlashCommand: /03-planning:roadmap $ARGUMENTS

Wait for roadmap creation to complete.

### If tracking decisions:

Check if user needs to document architectural decisions:

AskUserQuestion: Do you need to document an architectural decision?
- Yes → SlashCommand: /03-planning:decide $ARGUMENTS
- No → Skip

## Step 4: Sync Documentation

After planning components are created, synchronize:

!{bash test -d "specs/$ARGUMENTS" && echo "Spec directory exists" || echo "No spec to sync"}

## Step 5: Summary

Display planning artifacts created:
- Specification document (if created)
- Implementation plan (if created)
- Architecture design (if created)
- Project roadmap (if created)
- Decision records (if created)

**Next Steps:**
- Review generated planning documents
- Use /03-develop commands to begin implementation
- Use /04-iterate:tasks to break down work

---
allowed-tools: Task, Read, Write, Bash, Grep, Glob
description: Create project roadmaps and timelines
argument-hint: <project-name|--sprint>
---

**Arguments**: $ARGUMENTS

## Step 1: Determine Roadmap Type

Check roadmap scope:

!{bash test "$ARGUMENTS" = "--sprint" && echo "Sprint roadmap" || echo "Project roadmap: $ARGUMENTS"}

## Step 2: Gather Project Context

Load project configuration:

@.claude/project.json

Find existing specs:

!{bash ls -d specs/*/ 2>/dev/null | wc -l | xargs -I {} echo "Found {} specifications"}

List all spec directories:

!{bash ls -d specs/*/ 2>/dev/null | xargs -n1 basename | head -10}

## Step 3: Load Relevant Specs

Load all available specs for roadmap planning:

!{bash for spec in specs/*/spec.md; do echo "=== $(dirname $spec) ==="; cat "$spec" | head -20; done 2>/dev/null}

## Step 4: Generate Roadmap

Task(
  description="Create project roadmap",
  subagent_type="roadmap-planner",
  prompt="Create a project roadmap for: $ARGUMENTS

**Context:**
- All available specifications in specs/ directory
- Project framework and stack
- Current project state

**Your Task:**

Create roadmap document:
- If --sprint: Create docs/roadmap-sprint-$(date +%Y%m).md
- If project name: Create docs/roadmap-$ARGUMENTS.md

**Roadmap Document Should Include:**

1. **Executive Summary**
   - Project goals and objectives
   - Key milestones
   - Success criteria
   - Timeline overview

2. **Phase Breakdown**

   For each phase:
   - **Phase Name & Duration**
   - **Goals**: What we're achieving
   - **Features**: What we're building
   - **Dependencies**: What must be done first
   - **Deliverables**: Concrete outputs
   - **Success Metrics**: How we measure completion

3. **Feature Priorities**
   - Must-have (P0): Critical for launch
   - Should-have (P1): Important but not blocking
   - Nice-to-have (P2): Future enhancements
   - Won't-have: Out of scope

4. **Timeline** (use Mermaid gantt chart format: title, sections, features with dates and durations)

5. **Team Allocation**
   - Who is working on what
   - Parallel work streams
   - Resource requirements

6. **Risk Assessment**
   - Technical risks
   - Resource constraints
   - External dependencies
   - Mitigation strategies

7. **Milestones**
   - M1: Foundation complete (date)
   - M2: Core features done (date)
   - M3: Beta ready (date)
   - M4: Production launch (date)

8. **Communication Plan**
   - Status update frequency
   - Demo schedule
   - Stakeholder touchpoints

**For Sprint Roadmap:**
- Focus on 2-week sprint
- Specific tasks with estimates
- Daily capacity planning
- Sprint goals and demos

**Format:**
- Use tables for feature matrices
- Use mermaid gantt charts for timelines
- Include dates and durations
- Keep it realistic and achievable

**Output:**
Complete roadmap document with timelines, phases, and priorities."
)

## Step 5: Verify Roadmap Created

Check that roadmap was created:

!{bash test -f "docs/roadmap-"* && echo "✅ Roadmap created" || echo "⚠️  Roadmap creation incomplete"}

## Step 6: Display Summary

Show roadmap location:

!{bash ls docs/roadmap-* 2>/dev/null | tail -1}

**Next Steps:**
- Review and adjust timeline estimates
- Share with team for feedback
- Use /04-iterate:tasks to break down phases into tasks
- Begin Phase 1 implementation

---
allowed-tools: Task, Read, Write, Bash, Grep, Glob
description: Track architectural decisions (ADRs)
argument-hint: <decision-title>
---

**Arguments**: $ARGUMENTS

## Step 1: Initialize ADR Directory

Ensure decisions directory exists:

!{bash mkdir -p docs/decisions && echo "✅ ADR directory ready"}

## Step 2: Generate ADR Number

Find next ADR number:

!{bash NEXT_NUM=$(ls docs/decisions/*.md 2>/dev/null | wc -l | xargs -I {} echo $(({}+1))) && printf "ADR-%04d\n" $NEXT_NUM}

## Step 3: Create ADR Slug

Generate filename from title:

!{bash SLUG=$(echo "$ARGUMENTS" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g') && echo "$SLUG"}

## Step 4: Generate ADR Document

Task(
  description="Create architectural decision record",
  subagent_type="decision-documenter",
  prompt="Create an Architectural Decision Record (ADR) for: $ARGUMENTS

**Context:**
ADRs document important architectural decisions made during project development.

**Your Task:**

Create ADR document at: docs/decisions/$(printf "%04d" $NEXT_NUM)-$SLUG.md

**ADR Template Structure:**

# ADR-NNNN: Decision Title
**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded

## Context
What is the issue we're seeing that motivates this decision or change? Include current situation, problem statement, business/technical drivers, and constraints.

## Decision
What is the change that we're proposing and/or doing? Include the decision made, why this approach was chosen, and key benefits.

## Consequences
What becomes easier or more difficult to do because of this change?
Positive: List benefits
Negative: List trade-offs
Neutral: List neutral impacts

## Alternatives Considered
What other options did we evaluate? List each option with pros, cons, and why rejected.

## References
Related specs, external docs, and related ADRs

**Instructions:**
1. Analyze project context and existing architecture
2. Research the decision area thoroughly
3. Document clear rationale for the decision
4. List concrete alternatives that were considered
5. Be specific about trade-offs and consequences

**Output:**
Complete ADR document following the template above."
)

## Step 5: Verify ADR Created

Check that ADR was created:

!{bash ls docs/decisions/*.md 2>/dev/null | tail -1}

## Step 6: Update ADR Index

Create or update ADR index:

!{bash echo "# Architecture Decision Records" > docs/decisions/README.md && echo "" >> docs/decisions/README.md && for adr in docs/decisions/[0-9]*.md; do basename "$adr" | sed 's/\.md//' >> docs/decisions/README.md; done}

## Step 7: Display Summary

Show ADR location:

!{bash ls docs/decisions/*.md 2>/dev/null | tail -1}
!{bash echo "Total ADRs: $(ls docs/decisions/[0-9]*.md 2>/dev/null | wc -l)"}

**Next Steps:**
- Review ADR for completeness
- Share with team for discussion
- Update status when decision is accepted
- Reference ADR in implementation PRs

**ADR Statuses:**
- **Proposed**: Under discussion
- **Accepted**: Decision made and active
- **Deprecated**: No longer recommended
- **Superseded**: Replaced by newer ADR

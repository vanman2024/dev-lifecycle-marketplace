---
description: Create ALL project specs in one shot from massive description using parallel agents
argument-hint: <project-description>
allowed-tools: Task, Read, Write, Bash, Grep, Glob
---

**Arguments**: $ARGUMENTS

Goal: Rapidly generate complete project specifications from a massive project description by breaking it into features and generating specs in parallel

Core Principles:
- Break down complexity with feature-analyzer
- Generate specs in parallel for speed
- Use structured JSON to coordinate agents
- Consolidate results into project-specs.json
- Provide comprehensive summary with paths

Phase 1: Parse Project Description
Goal: Save the massive project description and validate input

Actions:
- Parse $ARGUMENTS to extract project description
- Save description to temporary file for analysis
- Example: !{bash echo "$ARGUMENTS" > /tmp/project-description.txt}
- Verify description is substantial (>100 words)
- Count words: !{bash wc -w < /tmp/project-description.txt}

Phase 2: Feature Analysis
Goal: Break massive description into discrete features with dependencies

Actions:

Task(description="Analyze project and break into features", subagent_type="feature-analyzer", prompt="You are the feature-analyzer agent. Analyze the project description and break it into discrete features (max 10).

Project Description:
$ARGUMENTS

Deliverable: JSON output with:
- features array (number, name, shortName, focus, dependencies, integrations)
- sharedContext (techStack, userTypes, dataEntities, integrations)

Save JSON to: /tmp/feature-breakdown.json")

Wait for feature-analyzer to complete and generate JSON.

Phase 3: Load Feature Breakdown
Goal: Parse the feature breakdown JSON for parallel spec generation

Actions:
- Load the generated JSON: @/tmp/feature-breakdown.json
- Extract feature list from JSON
- Count total features: !{bash jq '.features | length' /tmp/feature-breakdown.json}
- Display feature list for user visibility
- Example: !{bash jq -r '.features[] | "\(.number) - \(.name): \(.focus)"' /tmp/feature-breakdown.json}

Phase 4: Parallel Spec Generation
Goal: Spawn N spec-writer agents (one per feature) to run simultaneously

Actions:

Read feature breakdown JSON and launch one spec-writer agent per feature:

For each feature in the JSON, launch a parallel Task:

Task(description="Generate spec for feature 001", subagent_type="spec-writer", prompt="You are the spec-writer agent. Create complete specifications (spec.md, plan.md, tasks.md) for this feature.

Full Project Context:
$ARGUMENTS

Your Feature Assignment:
- Feature: Extract from JSON /tmp/feature-breakdown.json feature 001
- Focus: Extract focus from JSON
- Dependencies: Extract dependencies from JSON
- Integrations: Extract integrations from JSON
- Shared Context: Extract sharedContext from JSON

Deliverable: Three files in specs/{number}-{name}/ directory:
- spec.md (user requirements, tech-agnostic)
- plan.md (technical design with database schema, API contracts)
- tasks.md (implementation tasks, 5 phases, numbered)")

Task(description="Generate spec for feature 002", subagent_type="spec-writer", prompt="You are the spec-writer agent. Create complete specifications (spec.md, plan.md, tasks.md) for this feature.

Full Project Context:
$ARGUMENTS

Your Feature Assignment:
- Feature: Extract from JSON /tmp/feature-breakdown.json feature 002
- Focus: Extract focus from JSON
- Dependencies: Extract dependencies from JSON
- Integrations: Extract integrations from JSON
- Shared Context: Extract sharedContext from JSON

Deliverable: Three files in specs/{number}-{name}/ directory:
- spec.md (user requirements, tech-agnostic)
- plan.md (technical design with database schema, API contracts)
- tasks.md (implementation tasks, 5 phases, numbered)")

Continue launching Task() calls for ALL features in parallel (one Task per feature).

NOTE: In actual execution, the command orchestrator will read the JSON and dynamically create N Task() calls based on feature count.

Wait for ALL spec-writer agents to complete before proceeding.

Phase 5: Consolidation
Goal: Generate consolidated project-specs.json from all specs

Actions:
- Run consolidation script to generate JSON output
- Example: !{bash bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/spec-management/scripts/consolidate-specs.sh}
- Verify JSON was created: !{bash test -f .planning/project-specs.json && echo "Generated" || echo "Missing"}
- Count total specs created: !{bash ls -1 specs/*/spec.md 2>/dev/null | wc -l}

Phase 6: Summary
Goal: Provide comprehensive results with paths and next steps

Actions:
- Display feature count and spec locations
- Show project-specs.json location
- List all created spec directories: !{bash ls -1d specs/*/ 2>/dev/null}
- Display summary:
  - Total features analyzed
  - Total specs created (spec.md, plan.md, tasks.md per feature)
  - JSON consolidation location: .planning/project-specs.json
  - Next steps: Review specs, run /planning:validate-specs

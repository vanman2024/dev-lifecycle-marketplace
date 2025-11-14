---
description: Create all spec directories from features.json in parallel
argument-hint: none
allowed-tools: Read, Write, Bash, Task, TodoWrite
---

**Arguments**: None

Goal: Read features.json and generate all feature specification directories in parallel using multiple agents for fast execution.

Core Principles:
- Parallel execution (all specs created simultaneously)
- features.json is source of truth
- Each spec gets: spec.md, tasks.md, feature.json
- Maintains consistency across all specs
- Fast execution for large feature sets

Phase 1: Discovery
Goal: Load features.json and validate

Actions:
- Create todo list: !{TodoWrite}
- Check features.json exists:
  !{bash test -f features.json && echo \"exists\" || echo \"missing\"}

- If missing:
  - Display: "❌ Error: features.json not found"
  - Display: "   Run /planning:generate-features first"
  - Exit

- Validate JSON: !{bash python3 -m json.tool features.json > /dev/null && echo \"valid\" || echo \"invalid\"}
- Read features.json: @features.json
- Count features: !{bash python3 -c \"import json; print(len(json.load(open('features.json'))['features']))\"}
- Display: "📊 Found [count] features to create"

Phase 2: Prepare Spec Directories
Goal: Create spec directory structure

Actions:
- Ensure specs/features directory exists:
  !{bash mkdir -p specs/features}
- Check for existing specs:
  !{bash ls -d specs/features/[0-9][0-9][0-9]-*/ 2>/dev/null | wc -l}
- If existing specs found:
  - Display warning about overwriting
  - Continue (agents will handle existing files)

Phase 3: Launch Parallel Spec Generation
Goal: Create all specs simultaneously using multiple agents

Actions:
- **CRITICAL: Launch ALL Task() calls in a SINGLE message for parallel execution**

- For EACH feature in features.json, launch agent:

Task(description="Create spec F001", subagent_type="planning:feature-spec-writer", prompt="Create complete spec for feature F001 from features.json.

Read features.json and extract feature F001 details:
- Name, description, priority, complexity
- Dependencies, operational tasks
- ADR references, architecture notes

Create directory: specs/features/001-[slug]/

Generate three files:

1. **spec.md** (100-150 lines):
   - Feature name and description
   - Requirements and scope
   - Dependencies
   - Architecture references (link to ADRs)
   - Technical approach
   - Operational tasks section

2. **tasks.md** (initial task list):
   - Break feature into implementation tasks
   - Group by layer (L0-L3)
   - Mark all as □ (not started)
   - Note dependencies

3. **feature.json** (metadata):
   - Copy feature details from main features.json
   - Add spec_path field
   - Add created_at timestamp

Follow minimal format (100-150 lines for spec.md).
Cross-reference architecture docs.
Don't duplicate architecture - reference it.")

Task(description="Create spec F002", subagent_type="planning:feature-spec-writer", prompt="[Same structure for F002]")

[... Launch Task() for ALL features in parallel ...]

- Display: "🚀 Launched [count] parallel spec generation agents"

Phase 4: Monitor Progress
Goal: Wait for all agents to complete

Actions:
- Display: "⏳ Generating specs in parallel..."
- Display: "   This may take 1-2 minutes for large feature sets"
- All Task() calls complete automatically before proceeding

Phase 5: Validation
Goal: Verify all specs were created

Actions:
- List created specs:
  !{bash ls -d specs/features/[0-9][0-9][0-9]-*/ 2>/dev/null}
- Count created specs: !{bash ls -d specs/features/[0-9][0-9][0-9]-*/ 2>/dev/null | wc -l}
- For each spec directory, verify files exist:
  !{bash for dir in specs/features/[0-9][0-9][0-9]-*/; do [ -f \"$dir/spec.md\" ] && [ -f \"$dir/tasks.md\" ] && [ -f \"$dir/feature.json\" ] && echo \"$dir: ✅\" || echo \"$dir: ❌\"; done}

- If any specs missing files:
  - Display warnings
  - List incomplete specs
  - Suggest manual inspection

Phase 6: Summary
Goal: Report results

Actions:
- Mark todos complete
- Display: ""
- Display: "✅ All specs created successfully!"
- Display: ""
- Display: "📊 Results:"
- Display: "   Total features: [from features.json]"
- Display: "   Specs created: [count]"
- Display: "   Success rate: [percentage]%"
- Display: ""
- Display: "📁 Location: specs/features/"
- List all specs:
  !{bash ls -d specs/features/[0-9][0-9][0-9]-*/ | while read dir; do basename \"$dir\"; done}
- Display: ""
- Display: "Next steps:"
- Display: "  1. Review generated specs: cat specs/features/*/spec.md"
- Display: "  2. Layer tasks: /iterate:tasks F001"
- Display: "  3. Begin implementation"
- Display: ""

**Error Handling:**
- features.json missing → Suggest /planning:generate-features
- JSON invalid → Show validation error
- Spec creation fails → Show which specs failed, suggest retry
- Incomplete specs → List problems, suggest manual fixes

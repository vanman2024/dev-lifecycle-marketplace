---
description: Generate features.json from architecture and ADR docs
argument-hint: none
allowed-tools: Read, Write, Bash, Task, TodoWrite
---

**Arguments**: None

Goal: Analyze planning documentation (architecture, ADRs, requirements, project.json) and generate a comprehensive features.json file containing all features, dependencies, and operational tasks for the project.

Core Principles:
- Architecture drives features (ADRs and architecture docs are source of truth)
- Features extracted from decisions and requirements
- Dependencies detected automatically
- Operational tasks identified per feature
- Output is machine-readable for spec generation

Phase 1: Discovery
Goal: Load all planning documentation

Actions:
- Create todo list: !{TodoWrite}
- Check what planning docs exist:
  !{bash ls .claude/project.json 2>/dev/null && echo "project.json:exists" || echo "project.json:missing"}
  !{bash ls docs/architecture/*.md 2>/dev/null | wc -l}
  !{bash ls docs/adr/*.md 2>/dev/null | wc -l}
  !{bash ls docs/requirements/*.md 2>/dev/null | wc -l}

- If no planning docs exist:
  - Display: "⚠️  No planning documentation found. Run /planning:architecture and /planning:decide first."
  - Exit

- Display: "📚 Found planning documentation:"
- Display: "  - Architecture docs: [count]"
- Display: "  - ADRs: [count]"
- Display: "  - Requirements: [count]"

Phase 2: Read Planning Context
Goal: Load all relevant planning documents

Actions:
- Read project.json: @.claude/project.json
- Read all architecture docs:
  !{bash ls docs/architecture/*.md 2>/dev/null}
  - For each: @docs/architecture/[file]
- Read all ADRs (most recent 10):
  !{bash ls -t docs/adr/*.md 2>/dev/null | head -10}
  - For each: @docs/adr/[file]
- Read requirements if they exist:
  !{bash ls docs/requirements/*.md 2>/dev/null}
  - For each: @docs/requirements/[file]

- Display: "✅ Loaded planning context"

Phase 3: Analyze and Generate Features
Goal: Use AI to analyze docs and extract features

Actions:

Task(description="Generate features.json", subagent_type="planning:feature-analyzer", prompt="Analyze planning documentation and generate features.json.

You have access to:
- project.json (tech stack, architecture pattern)
- Architecture docs (system design, components, data flows)
- ADRs (architecture decisions, rationale, patterns)
- Requirements docs (if available)

Your task:
1. Identify all distinct features needed based on the planning docs
2. For each feature, determine:
   - Feature ID (F001, F002, etc.)
   - Feature name
   - Description
   - Priority (P0, P1, P2)
   - Dependencies on other features
   - Complexity estimate (Simple, Moderate, Complex)
   - Operational tasks (ongoing work like data uploads, maintenance)
   - Architecture decisions that affect it

3. Generate features.json with this structure:
{
  \"project\": \"[from project.json]\",
  \"generated_at\": \"[timestamp]\",
  \"features\": [
    {
      \"id\": \"F001\",
      \"name\": \"Feature Name\",
      \"description\": \"What this feature does\",
      \"priority\": \"P0\",
      \"phase\": \"MVP\",
      \"complexity\": \"Moderate\",
      \"estimated_days\": 3,
      \"dependencies\": [\"Database\", \"Auth\"],
      \"dependent_features\": [],
      \"operational_tasks\": [
        \"Upload data for X\",
        \"Run batch process for Y\"
      ],
      \"adr_references\": [\"0001\", \"0006\"],
      \"architecture_notes\": \"Key architectural context\"
    }
  ]
}

Write the output to: features.json
Ensure all features from architecture and ADRs are captured.")

- Update todo

Phase 4: Validation
Goal: Verify features.json is valid

Actions:
- Check file exists: !{bash test -f features.json && echo \"exists\" || echo \"missing\"}
- Validate JSON syntax: !{bash python3 -m json.tool features.json > /dev/null && echo \"valid\" || echo \"invalid\"}
- Count features: !{bash python3 -c \"import json; print(len(json.load(open('features.json'))['features']))\"}
- Display features summary:
  !{bash python3 -c \"import json; f=json.load(open('features.json')); [print(f\\\"  {ft['id']}: {ft['name']} (P{ft['priority']}, {ft['complexity']})\\\") for ft in f['features']]\"}

Phase 5: Summary
Goal: Report results

Actions:
- Mark todos complete
- Display: ""
- Display: "✅ features.json generated successfully!"
- Display: ""
- Display: "📄 File: features.json"
- Display: "📊 Features: [count] total"
- Display: "  - P0 (critical): [count]"
- Display: "  - P1 (important): [count]"
- Display: "  - P2 (nice-to-have): [count]"
- Display: ""
- Display: "Next steps:"
- Display: "  1. Review features.json"
- Display: "  2. Run /planning:create-all-specs to generate specs"
- Display: ""

**Error Handling:**
- No planning docs found → Suggest running /planning:architecture first
- JSON validation fails → Show error and suggest fixes
- Agent fails → Display error and suggest manual feature.json creation

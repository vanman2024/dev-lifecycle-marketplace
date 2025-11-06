---
description: Validate task completion status against actual implementation
argument-hint: <spec-number>
allowed-tools: Task, Read, Bash, Glob
---

**Arguments**: $ARGUMENTS

Goal: Validate that tasks marked complete in tasks.md have corresponding implementation work

Core Principles:
- Verify don't assume - check actual files and git history
- Evidence-based validation - require proof of implementation
- Actionable reporting - provide specific remediation steps

Phase 1: Discovery
Goal: Parse spec number and locate task files

Actions:
- Parse $ARGUMENTS for spec number (e.g., "001", "spec-001")
- Find spec directory: !{bash find specs -type f -name "tasks.md" -path "*$SPEC_NUMBER*" | head -1 | xargs dirname}
- Verify tasks.md exists: !{bash SPEC_DIR=$(find specs -type f -name "tasks.md" -path "*$SPEC_NUMBER*" | head -1 | xargs dirname) && test -f "$SPEC_DIR/tasks.md" && echo "✓ Found" || echo "✗ Missing"}
- If missing, report error and suggest creating tasks.md

Phase 2: Validation
Goal: Launch task-validator agent

Actions:

Task(description="Validate task completion", subagent_type="quality:task-validator", prompt="You are the task-validator agent. Validate task completion for spec $ARGUMENTS.

Load the tasks.md file and verify each task marked [x] has:
- Corresponding files that exist
- Git commits related to the task
- Tests covering the functionality
- No uncommitted changes for the feature

Also identify tasks that should be marked complete but aren't.

Generate a comprehensive validation report with:
- ✅ Verified completions (high confidence)
- ⚠️ Questionable completions (needs verification)
- ❌ False completions (no evidence)
- 📝 Completed but not marked

Provide specific file paths, commit SHAs, and remediation steps.")

Phase 3: Summary
Goal: Report validation results

Actions:
- Display agent's validation report
- Show health score (% of tasks verified)
- List priority actions
- Suggest next steps:
  - Update tasks.md based on findings
  - Run `/quality:test` to verify functionality
  - Address false completions immediately

---
description: Add enhancement/sub-spec to existing feature
argument-hint: <feature-id> <enhancement-id> "<enhancement-name>"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

**Arguments**: $ARGUMENTS

Goal: Add an enhancement (sub-spec) to an existing feature. Creates enhancements/E###/ directory under feature spec with spec.md and tasks.md. Updates features.json.

Core Principles:
- Validate feature exists before creating enhancement
- Auto-detect next enhancement ID if not provided
- Enhancements inherit feature's phase and dependencies

Phase 1: Parse Arguments
Goal: Extract feature ID, enhancement ID, and name

Actions:
- Parse $ARGUMENTS for: FEATURE_ID (required), ENHANCEMENT_ID (optional), ENHANCEMENT_NAME (required)
- Example: F017 E001 "Infrastructure Bundling"
- If FEATURE_ID or ENHANCEMENT_NAME missing: Show usage and exit

Phase 2: Validate Feature Exists
Goal: Ensure target feature exists and find its spec directory

Actions:
- Find feature spec: !{bash find specs/features -type d -name "${FEATURE_ID}-*" 2>/dev/null | head -1}
- If not found: Error and show available features
- Store FEATURE_DIR path
- Read feature context: @${FEATURE_DIR}/spec.md

Phase 3: Determine Enhancement ID
Goal: Auto-generate enhancement ID if not provided

Actions:
- If ENHANCEMENT_ID not provided: Find highest existing E### and increment
- Check enhancement doesn't exist: !{bash test -d "${FEATURE_DIR}/enhancements/${ENHANCEMENT_ID}" && echo exists}
- If exists: Error and exit

Phase 4: Create Enhancement Directory
Goal: Create enhancements/E###/ directory with spec.md and tasks.md

Actions:
- Create directory: !{bash mkdir -p "${FEATURE_DIR}/enhancements/${ENHANCEMENT_ID}"}
- Create spec.md with header, overview, problem/solution sections, dependencies, success criteria
- Create tasks.md with parent feature reference and layer sections (L0: Core, L1: Integration, L2: Testing)
- Write both files using Write tool

Phase 5: Update features.json
Goal: Add enhancement entry to feature's enhancements array

Actions:
- Read: @roadmap/features.json
- Find feature by FEATURE_ID
- Add/create enhancements array if missing
- Append enhancement object: id, name, status="planned", tasks_total=0, tasks_completed=0
- Write updated features.json

Phase 6: Summary
Goal: Report results

Actions:
- Display:
  * Feature: ${FEATURE_ID}
  * Enhancement: ${ENHANCEMENT_ID} - ${ENHANCEMENT_NAME}
  * Location: ${FEATURE_DIR}/enhancements/${ENHANCEMENT_ID}/
  * Files: spec.md, tasks.md
  * Updated: features.json
- Next steps:
  * Edit spec.md to fill in details
  * Edit tasks.md to add tasks
  * Run /iterate:tasks ${FEATURE_ID} to see combined progress

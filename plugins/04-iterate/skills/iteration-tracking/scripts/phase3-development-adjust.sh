#!/usr/bin/env bash
# Script: phase3-development-adjust.sh
# Purpose: Handle live development adjustments with ecosystem sync
# Subsystem: iterate
# Called by: /iterate:adjust slash command
# Outputs: Updated iteration files (iteration-N-tasks.md, synced ecosystem)

set -euo pipefail

# --- Configuration ---
SPEC_DIR="${1:-.}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Validation ---
if [[ ! -d "$SPEC_DIR" ]]; then
  echo "❌ Error: Spec directory not found: $SPEC_DIR"
  exit 1
fi

# Extract spec number from directory name
SPEC_NUM=$(basename "$SPEC_DIR" | grep -oE '^[0-9]+')
if [[ -z "$SPEC_NUM" ]]; then
  echo "❌ Error: Could not extract spec number from: $SPEC_DIR"
  exit 1
fi

echo "[INFO] Adjusting development for spec: $SPEC_DIR"

# --- Main Logic ---
cd "$SPEC_DIR" || exit 1

# 1. Verify tasks.md exists (source of truth)
if [[ ! -f "tasks.md" ]]; then
  echo "❌ Error: tasks.md not found in $SPEC_DIR"
  exit 1
fi

# 2. Determine next iteration number
ITERATION_NUM=1
if [[ -d "agent-tasks" ]]; then
  LAST_ITERATION=$(find agent-tasks -name "iteration-*-tasks.md" 2>/dev/null | wc -l)
  ITERATION_NUM=$((LAST_ITERATION + 1))
fi

echo "[INFO] Creating iteration $ITERATION_NUM..."

# 3. Create backup of current layered-tasks.md if it exists
if [[ -f "agent-tasks/layered-tasks.md" ]]; then
  BACKUP_FILE="agent-tasks/iteration-$((ITERATION_NUM - 1))-tasks.md"
  if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "[INFO] Backing up previous iteration to $BACKUP_FILE..."
    cp agent-tasks/layered-tasks.md "$BACKUP_FILE"
  fi
fi

# 4. Re-run Phase 1 (task layering)
# Note: This would normally invoke the task-layering agent via /iterate:tasks
# For this script, we'll create a marker file indicating adjustment is needed
echo "[INFO] Preparing for task re-layering..."
cat > agent-tasks/.adjustment-needed <<EOF
Iteration: $ITERATION_NUM
Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Reason: Live development adjustments requested
Action: Re-run /iterate:tasks $SPEC_NUM to create new layered-tasks.md
EOF

# 5. Update iteration-log.md
ITERATION_LOG="agent-tasks/iteration-log.md"
if [[ -f "$ITERATION_LOG" ]]; then
  echo "[INFO] Updating iteration-log.md..."
  cat >> "$ITERATION_LOG" <<EOF

## Iteration $ITERATION_NUM - $(date +%Y-%m-%d)

**Status**: Adjustment Needed
**Trigger**: Live development changes
**Previous**: iteration-$((ITERATION_NUM - 1))-tasks.md

### Changes Required
- Tasks.md updated with new requirements
- Need to re-layer tasks via /iterate:tasks
- Previous iteration backed up

### Next Steps
1. Run: /iterate:tasks $SPEC_NUM
2. Review new layered-tasks.md
3. Re-sync ecosystem: /iterate:sync $SPEC_NUM
EOF
else
  echo "⚠️  Warning: iteration-log.md not found, creating new one..."
  cat > "$ITERATION_LOG" <<EOF
# Iteration Log - Spec ${SPEC_NUM}

## Iteration $ITERATION_NUM - $(date +%Y-%m-%d)

**Status**: Adjustment Needed
**Trigger**: Live development changes

### Next Steps
1. Run: /iterate:tasks $SPEC_NUM
2. Review new layered-tasks.md
3. Re-sync ecosystem: /iterate:sync $SPEC_NUM
EOF
fi

# 6. Create JSON summary output
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cat > /tmp/phase3-adjust-${SPEC_NUM}.json <<EOF
{
  "timestamp": "$TIMESTAMP",
  "spec": "$SPEC_NUM",
  "iteration": $ITERATION_NUM,
  "status": "adjustment_prepared",
  "backup_created": "agent-tasks/iteration-$((ITERATION_NUM - 1))-tasks.md",
  "files_updated": [
    "agent-tasks/iteration-log.md",
    "agent-tasks/.adjustment-needed"
  ],
  "next_steps": [
    "/iterate:tasks $SPEC_NUM",
    "/iterate:sync $SPEC_NUM",
    "Resume agent work"
  ]
}
EOF

echo "✅ Development adjustment prepared for spec $SPEC_NUM"
echo ""
echo "📋 Changes:"
echo "  - Backed up previous iteration: iteration-$((ITERATION_NUM - 1))-tasks.md"
echo "  - Updated iteration-log.md with iteration $ITERATION_NUM"
echo "  - Created adjustment marker"
echo ""
echo "🔄 Required next steps:"
echo "  1. /iterate:tasks $SPEC_NUM    (re-layer tasks)"
echo "  2. /iterate:sync $SPEC_NUM     (sync ecosystem)"
echo "  3. Resume agent work with new structure"
echo ""
echo "⚠️  Note: Previous layered-tasks.md backed up. Agents should pull latest changes."

exit 0

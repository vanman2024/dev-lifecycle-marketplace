#!/usr/bin/env bash
# Script: phase2-ecosystem-sync.sh
# Purpose: Sync entire spec ecosystem to match layered tasks
# Subsystem: iterate
# Called by: /iterate:sync slash command
# Outputs: Updated spec files (plan.md, quickstart.md, current-tasks.md symlink)

set -euo pipefail

# --- Configuration ---
SPEC_DIR="${1:-.}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"

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

echo "[INFO] Syncing spec ecosystem for: $SPEC_DIR"

# --- Main Logic ---
cd "$SPEC_DIR" || exit 1

# 1. Verify layered-tasks.md exists
if [[ ! -f "agent-tasks/layered-tasks.md" ]]; then
  echo "❌ Error: layered-tasks.md not found. Run /iterate:tasks first."
  exit 1
fi

# 2. Create current-tasks.md symlink (points to latest iteration)
if [[ ! -L "agent-tasks/current-tasks.md" ]]; then
  echo "[INFO] Creating current-tasks.md symlink..."
  ln -sf layered-tasks.md agent-tasks/current-tasks.md
fi

# 3. Update plan.md with iteration reference
if [[ -f "plan.md" ]]; then
  echo "[INFO] Updating plan.md with iteration reference..."
  if ! grep -q "Current Tasks" plan.md; then
    cat >> plan.md <<EOF

## Current Tasks

See \`agent-tasks/current-tasks.md\` for the latest task structure.
EOF
  fi
fi

# 4. Update quickstart.md with agent assignments
if [[ -f "quickstart.md" ]]; then
  echo "[INFO] Updating quickstart.md with agent workflow..."
  if ! grep -q "Agent Workflow" quickstart.md; then
    cat >> quickstart.md <<EOF

## Agent Workflow

1. Review your assigned tasks in \`agent-tasks/current-tasks.md\`
2. Create your worktree: \`git worktree add ../agent-{agent}-{spec} main\`
3. Follow the layered structure (complete Layer 1 before Layer 2)
4. Mark tasks complete in your layer before proceeding
EOF
  fi
fi

# 5. Create/update iteration-log.md
ITERATION_LOG="agent-tasks/iteration-log.md"
if [[ ! -f "$ITERATION_LOG" ]]; then
  echo "[INFO] Creating iteration-log.md..."
  cat > "$ITERATION_LOG" <<EOF
# Iteration Log - Spec ${SPEC_NUM}

## Iteration 1 - $(date +%Y-%m-%d)

**Status**: Active
**Tasks File**: layered-tasks.md
**Changes**: Initial task layering

### Agent Assignments
- See layered-tasks.md for current assignments

### Notes
- Spec ecosystem synchronized
- All agents can begin work
EOF
else
  echo "[INFO] iteration-log.md already exists"
fi

# 6. Create JSON summary output
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cat > /tmp/phase2-sync-${SPEC_NUM}.json <<EOF
{
  "timestamp": "$TIMESTAMP",
  "spec": "$SPEC_NUM",
  "status": "success",
  "files_updated": [
    "agent-tasks/current-tasks.md",
    "plan.md",
    "quickstart.md",
    "agent-tasks/iteration-log.md"
  ],
  "next_steps": [
    "Review updated files",
    "Begin agent work",
    "Use /supervisor:start to verify readiness"
  ]
}
EOF

echo "✅ Spec ecosystem synchronized for spec $SPEC_NUM"
echo ""
echo "📋 Files updated:"
echo "  - agent-tasks/current-tasks.md (symlink)"
echo "  - plan.md (iteration reference added)"
echo "  - quickstart.md (workflow guidance added)"
echo "  - agent-tasks/iteration-log.md (tracking created)"
echo ""
echo "🚀 Next steps:"
echo "  1. Review updated files in $SPEC_DIR"
echo "  2. Begin agent work"
echo "  3. Use /supervisor:start $SPEC_NUM to verify readiness"

exit 0

#!/usr/bin/env bash

set -e

# Parse command line arguments
SPEC_NAME="$1"
JSON_MODE=false

if [[ "$2" == "--json" ]]; then
    JSON_MODE=true
fi

if [[ -z "$SPEC_NAME" ]]; then
    echo "Usage: $0 <spec-directory> [--json]"
    echo "Example: $0 002-system-context-we"
    exit 1
fi

# Get paths - script runs from ~/.multiagent/ but user is in their project directory
REPO_ROOT="$(pwd)"  # Current working directory is the project root
SPEC_DIR="$REPO_ROOT/specs/$SPEC_NAME"
LAYERED_TASKS="$SPEC_DIR/agent-tasks/layered-tasks.md"

# Verify spec directory exists
if [[ ! -d "$SPEC_DIR" ]]; then
    echo "Error: Spec directory not found: $SPEC_DIR" >&2
    exit 1
fi

# Get current timestamp
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

# Extract spec number from spec name (e.g., 004 from 004-testing-deployment-validation)
SPEC_NUMBER=$(echo "$SPEC_NAME" | grep -oE '^[0-9]+')

# Check if layered-tasks.md exists and validate symlink
LAYERED_TASKS_EXISTS="NO"
IS_SYMLINK="NO"
SYMLINK_VALID="NO"
SYMLINK_TARGET=""

if [[ -f "$LAYERED_TASKS" ]]; then
    LAYERED_TASKS_EXISTS="YES"
    if [[ -L "$LAYERED_TASKS" ]]; then
        IS_SYMLINK="YES"
        SYMLINK_TARGET=$(readlink -f "$LAYERED_TASKS")
        if [[ -f "$SYMLINK_TARGET" ]]; then
            SYMLINK_VALID="YES"
            LOAD_STATUS="✅ layered-tasks.md found as valid symlink"
            TASK_SETUP="READY"
        else
            LOAD_STATUS="❌ layered-tasks.md symlink target missing: $SYMLINK_TARGET"
            TASK_SETUP="BLOCKED"
        fi
    else
        LOAD_STATUS="❌ layered-tasks.md exists but is NOT a symlink (should be symlinked to shared task file)"
        TASK_SETUP="BLOCKED"
    fi
else
    LOAD_STATUS="❌ layered-tasks.md missing - run /iterate:tasks first"
    TASK_SETUP="BLOCKED"
fi

# Check worktree status for each agent
check_agent_worktree() {
    local agent="$1"
    local worktree_name="agent-${agent}-${SPEC_NUMBER}"

    if git worktree list | grep -q "$worktree_name"; then
        echo "ACTIVE"
    else
        echo "MISSING"
    fi
}

CLAUDE_WORKTREE=$(check_agent_worktree "claude")
COPILOT_WORKTREE=$(check_agent_worktree "copilot")
CODEX_WORKTREE=$(check_agent_worktree "codex")
QWEN_WORKTREE=$(check_agent_worktree "qwen")
GEMINI_WORKTREE=$(check_agent_worktree "gemini")

# Count active worktrees for this spec
ACTIVE_WORKTREES=$(git worktree list | grep -c "agent-.*-${SPEC_NUMBER}" || echo "0")

# Check git status
GIT_CLEAN=$(git status --porcelain | wc -l)
GIT_STATE=$([[ "$GIT_CLEAN" == "0" ]] && echo "CLEAN" || echo "DIRTY")

# Check if main branch is synced
git fetch origin main >/dev/null 2>&1 || true
LOCAL_MAIN=$(git rev-parse main 2>/dev/null || echo "")
REMOTE_MAIN=$(git rev-parse origin/main 2>/dev/null || echo "")
MAIN_SYNCED=$([[ "$LOCAL_MAIN" == "$REMOTE_MAIN" ]] && echo "YES" || echo "NO")

# Count tasks per agent - strip newlines
CLAUDE_TASKS=$(grep -c "@claude" "$LAYERED_TASKS" 2>/dev/null || echo "0")
CLAUDE_TASKS=$(echo "$CLAUDE_TASKS" | tr -d '\n' | head -c 10)
COPILOT_TASKS=$(grep -c "@copilot" "$LAYERED_TASKS" 2>/dev/null || echo "0")
COPILOT_TASKS=$(echo "$COPILOT_TASKS" | tr -d '\n' | head -c 10)
CODEX_TASKS=$(grep -c "@codex" "$LAYERED_TASKS" 2>/dev/null || echo "0")
CODEX_TASKS=$(echo "$CODEX_TASKS" | tr -d '\n' | head -c 10)
QWEN_TASKS=$(grep -c "@qwen" "$LAYERED_TASKS" 2>/dev/null || echo "0")
QWEN_TASKS=$(echo "$QWEN_TASKS" | tr -d '\n' | head -c 10)
GEMINI_TASKS=$(grep -c "@gemini" "$LAYERED_TASKS" 2>/dev/null || echo "0")
GEMINI_TASKS=$(echo "$GEMINI_TASKS" | tr -d '\n' | head -c 10)
TOTAL_TASKS=$((CLAUDE_TASKS + COPILOT_TASKS + CODEX_TASKS + QWEN_TASKS + GEMINI_TASKS))

# Determine overall status
if [[ "$TASK_SETUP" == "READY" ]] && [[ "$ACTIVE_WORKTREES" -gt 0 ]]; then
    OVERALL_STATUS="READY"
    SUMMARY="Task setup ready, $ACTIVE_WORKTREES agent worktrees active. System ready for parallel agent work."
else
    OVERALL_STATUS="BLOCKED"
    SUMMARY="Setup incomplete. Missing task layering or agent worktrees. Agents cannot start work safely."
fi

# Generate blockers list
BLOCKERS=()
[[ "$LAYERED_TASKS_EXISTS" == "NO" ]] && BLOCKERS+=("layered-tasks.md missing")
[[ "$IS_SYMLINK" == "NO" ]] && [[ "$LAYERED_TASKS_EXISTS" == "YES" ]] && BLOCKERS+=("layered-tasks.md not a symlink")
[[ "$ACTIVE_WORKTREES" == "0" ]] && BLOCKERS+=("no agent worktrees created")
[[ "$GIT_STATE" == "DIRTY" ]] && BLOCKERS+=("uncommitted changes in working directory")

# Output results
if [[ "$JSON_MODE" == "true" ]]; then
    # JSON output for agent consumption
    cat <<EOF
{
  "spec_name": "$SPEC_NAME",
  "spec_number": "$SPEC_NUMBER",
  "spec_dir": "$SPEC_DIR",
  "timestamp": "$TIMESTAMP",
  "layered_tasks": {
    "exists": "$LAYERED_TASKS_EXISTS",
    "is_symlink": "$IS_SYMLINK",
    "symlink_valid": "$SYMLINK_VALID",
    "symlink_target": "$SYMLINK_TARGET",
    "status": "$LOAD_STATUS"
  },
  "worktrees": {
    "claude": "$CLAUDE_WORKTREE",
    "copilot": "$COPILOT_WORKTREE",
    "codex": "$CODEX_WORKTREE",
    "qwen": "$QWEN_WORKTREE",
    "gemini": "$GEMINI_WORKTREE",
    "active_count": $ACTIVE_WORKTREES
  },
  "git": {
    "state": "$GIT_STATE",
    "main_synced": "$MAIN_SYNCED"
  },
  "tasks": {
    "claude": $CLAUDE_TASKS,
    "copilot": $COPILOT_TASKS,
    "codex": $CODEX_TASKS,
    "qwen": $QWEN_TASKS,
    "gemini": $GEMINI_TASKS,
    "total": $TOTAL_TASKS
  },
  "overall_status": "$OVERALL_STATUS",
  "task_setup": "$TASK_SETUP",
  "summary": "$SUMMARY",
  "blockers": [$(printf '"%s",' "${BLOCKERS[@]}" | sed 's/,$//')],
  "blockers_count": ${#BLOCKERS[@]}
}
EOF
else
    # Human-readable output
    echo "=== Supervisor Start Phase Verification ==="
    echo "Spec: $SPEC_NAME"
    echo "Phase: START (Pre-work setup verification)"
    echo ""
    echo "📋 **Report Generated**: $SPEC_DIR/supervisor/start-report.md"
    echo "🎯 **Overall Status**: $([[ "$OVERALL_STATUS" == "READY" ]] && echo "✅ $OVERALL_STATUS" || echo "❌ $OVERALL_STATUS")"
    echo ""
    echo "📊 **Quick Summary**:"
    echo "  - Task Setup: $TASK_SETUP"
    echo "  - Active Worktrees: $ACTIVE_WORKTREES/5"
    echo "  - Issues Found: ${#BLOCKERS[@]}"
    echo ""
    if [[ ${#BLOCKERS[@]} -gt 0 ]]; then
        echo "⚠️ **Action Required**: Fix setup issues before agent work begins"
    else
        echo "✅ **All Clear**: Agents can begin work"
    fi
fi

exit 0

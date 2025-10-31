#!/usr/bin/env bash

set -e

# Parse command line arguments
SPEC_NAME="$1"
JSON_MODE=false

# Check for flags
for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
    esac
done

if [[ -z "$SPEC_NAME" ]]; then
    echo "Usage: $0 <spec-directory> [--json]"
    echo "Example: $0 002-system-context-we"
    echo "Flags:"
    echo "  --json  Output JSON format"
    exit 1
fi

# Get script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SPEC_DIR="$REPO_ROOT/specs/$SPEC_NAME"
SUPERVISOR_DIR="$SPEC_DIR/supervisor"
TEMPLATE="$REPO_ROOT/.multiagent/supervisor/templates/mid-report.template.md"
OUTPUT="$SUPERVISOR_DIR/mid-report.md"

# Verify spec directory exists
if [[ ! -d "$SPEC_DIR" ]]; then
    echo "Error: Spec directory not found: $SPEC_DIR"
    exit 1
fi

# Verify template exists
if [[ ! -f "$TEMPLATE" ]]; then
    echo "Error: Supervisor template not found: $TEMPLATE"
    exit 1
fi

# Create supervisor directory in spec
mkdir -p "$SUPERVISOR_DIR"

# Get current timestamp
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

echo "=== Supervisor Mid Phase Monitoring ==="
echo "Spec: $SPEC_NAME"
echo "Phase: MID (Progress and compliance monitoring)"

# Check if layered-tasks.md exists
LAYERED_TASKS="$SPEC_DIR/agent-tasks/layered-tasks.md"
if [[ -f "$LAYERED_TASKS" ]]; then
    LOAD_STATUS="✅ layered-tasks.md found and readable"
    TASK_SETUP="READY"
else
    LOAD_STATUS="❌ layered-tasks.md missing - run /iterate tasks first"
    TASK_SETUP="BLOCKED"
fi

# Advanced worktree analysis - check actual agent activity
check_agent_activity() {
    local agent="$1"
    
    # Look for ANY worktree that might belong to this agent
    local agent_worktrees=$(git worktree list | grep -i "$agent" | wc -l)
    local main_commits=$(git log main --oneline -10 --author="$agent" 2>/dev/null | wc -l)
    
    if [[ "$main_commits" -gt 0 ]]; then
        echo "⚠️ WORKING_ON_MAIN"
    elif [[ "$agent_worktrees" -gt 0 ]]; then
        echo "✅ PROPER_WORKTREE"
    else
        echo "❌ NO_ACTIVITY"
    fi
}

# Check main branch protection
check_main_protection() {
    local recent_main_commits=$(git log main --oneline -5 --format="%an" 2>/dev/null | grep -c "Claude\|Copilot\|Codex\|Qwen\|Gemini" || echo "0")
    recent_main_commits=$(echo "$recent_main_commits" | head -1)  # Take first line only
    
    if [[ "$recent_main_commits" =~ ^[0-9]+$ ]] && [[ "$recent_main_commits" -gt 0 ]]; then
        echo "❌ MAIN_POLLUTED"
    else
        echo "✅ MAIN_PROTECTED"
    fi
}

CLAUDE_ACTIVITY=$(check_agent_activity "claude")
COPILOT_ACTIVITY=$(check_agent_activity "copilot") 
CODEX_ACTIVITY=$(check_agent_activity "codex")
QWEN_ACTIVITY=$(check_agent_activity "qwen")
GEMINI_ACTIVITY=$(check_agent_activity "gemini")

MAIN_PROTECTION=$(check_main_protection)

# Count total worktrees and check for main branch violations
TOTAL_WORKTREES=$(git worktree list | wc -l)
MAIN_VIOLATIONS=$(git log main --oneline -10 --format="%an" 2>/dev/null | grep -c "Claude\|Copilot\|Codex\|Qwen\|Gemini" || echo "0")
MAIN_VIOLATIONS=$(echo "$MAIN_VIOLATIONS" | head -1)  # Take first line only

# Check task progress
COMPLETED_TASKS=$(grep -c "\[x\]" "$LAYERED_TASKS" 2>/dev/null || echo "0")
PENDING_TASKS=$(grep -c "\[ \]" "$LAYERED_TASKS" 2>/dev/null || echo "0")
TOTAL_TASKS=$((COMPLETED_TASKS + PENDING_TASKS))

# Check for documented blockers in layered-tasks.md
DOCUMENTED_BLOCKERS=""
if [[ -f "$LAYERED_TASKS" ]]; then
    # Extract lines containing documented issues (Note:, BLOCKER, Issue:, etc.)
    BLOCKER_LINES=$(grep -n "Note:\|BLOCKER\|Issue:\|Warning:\|TODO:\|FIXME:" "$LAYERED_TASKS" 2>/dev/null || echo "")

    if [[ -n "$BLOCKER_LINES" ]]; then
        DOCUMENTED_BLOCKERS="FOUND"
        echo "⚠️  Found documented blockers in layered-tasks.md:"
        echo "$BLOCKER_LINES"
    fi
fi

# Generate summary
if [[ "$MAIN_VIOLATIONS" =~ ^[0-9]+$ ]] && [[ "$MAIN_VIOLATIONS" -gt 0 ]]; then
    SUMMARY="MID phase monitoring: ⚠️ MAIN BRANCH VIOLATIONS DETECTED. $MAIN_VIOLATIONS commits found on main. Agents must work in worktrees only."
    OVERALL_STATUS="⚠️ VIOLATIONS"
elif [[ "$TOTAL_TASKS" -gt 0 ]] && [[ "$COMPLETED_TASKS" -gt 0 ]]; then
    SUMMARY="MID phase monitoring: Progress detected. $COMPLETED_TASKS/$TOTAL_TASKS tasks completed. Agents working properly in isolation."
    OVERALL_STATUS="✅ PROGRESSING"
else
    SUMMARY="MID phase monitoring: Minimal activity detected. Agents may not have started work yet."
    OVERALL_STATUS="⚠️ LOW_ACTIVITY"
fi

# Copy template and fill placeholders
cp "$TEMPLATE" "$OUTPUT"

# Replace placeholders with actual values
sed -i "s|\[SPEC_NAME\]|$SPEC_NAME|g" "$OUTPUT"
sed -i "s|\[PHASE\]|MID|g" "$OUTPUT"
sed -i "s|\[TIMESTAMP\]|$TIMESTAMP|g" "$OUTPUT"
sed -i "s|\[SPEC_PATH\]|$SPEC_DIR|g" "$OUTPUT"
sed -i "s|\[LOAD_STATUS\]|$LOAD_STATUS|g" "$OUTPUT"
sed -i "s|\[WORKTREE_STATUS\]|$TOTAL_WORKTREES total worktrees, Main protection: $MAIN_PROTECTION|g" "$OUTPUT"
sed -i "s|\[ROLE_STATUS\]|Active monitoring during work phase|g" "$OUTPUT"
sed -i "s|\[PROGRESS_STATUS\]|$COMPLETED_TASKS/$TOTAL_TASKS tasks completed|g" "$OUTPUT"
sed -i "s|\[REPORT_STATUS\]|✅ Generated|g" "$OUTPUT"
sed -i "s|\[SUMMARY_TEXT\]|$SUMMARY|g" "$OUTPUT"

# Fill agent-specific activity status
sed -i "s|\[CLAUDE_WORKTREE_STATUS\]|$CLAUDE_ACTIVITY|g" "$OUTPUT"
sed -i "s|\[COPILOT_WORKTREE_STATUS\]|$COPILOT_ACTIVITY|g" "$OUTPUT"
sed -i "s|\[CODEX_WORKTREE_STATUS\]|$CODEX_ACTIVITY|g" "$OUTPUT"
sed -i "s|\[QWEN_WORKTREE_STATUS\]|$QWEN_ACTIVITY|g" "$OUTPUT"
sed -i "s|\[GEMINI_WORKTREE_STATUS\]|$GEMINI_ACTIVITY|g" "$OUTPUT"

# Role status (specialization compliance)
sed -i "s|\[CLAUDE_ROLE_STATUS\]|ACTIVE|g" "$OUTPUT"
sed -i "s|\[CLAUDE_ROLE_DETAILS\]|Architecture and coordination work|g" "$OUTPUT"
sed -i "s|\[COPILOT_ROLE_STATUS\]|ACTIVE|g" "$OUTPUT"
sed -i "s|\[COPILOT_ROLE_DETAILS\]|Implementation tasks|g" "$OUTPUT"
sed -i "s|\[CODEX_ROLE_STATUS\]|ACTIVE|g" "$OUTPUT"
sed -i "s|\[CODEX_ROLE_DETAILS\]|Scripts and automation|g" "$OUTPUT"
sed -i "s|\[QWEN_ROLE_STATUS\]|MONITORING|g" "$OUTPUT"
sed -i "s|\[QWEN_ROLE_DETAILS\]|Performance optimization|g" "$OUTPUT"
sed -i "s|\[GEMINI_ROLE_STATUS\]|MONITORING|g" "$OUTPUT"
sed -i "s|\[GEMINI_ROLE_DETAILS\]|Research and analysis|g" "$OUTPUT"

# Phase-specific content for MID phase
MAIN_STATUS=$([ "$MAIN_VIOLATIONS" -eq 0 ] && echo "PROTECTED" || echo "VIOLATED")
ACTIVITY_LEVEL=$([ "$COMPLETED_TASKS" -gt 0 ] && echo "ACTIVE" || echo "MINIMAL")

PHASE_CHECKS="Mid-work Progress Monitoring: Main branch status: $MAIN_STATUS, Activity level: $ACTIVITY_LEVEL, Completed tasks: $COMPLETED_TASKS/$TOTAL_TASKS, Total worktrees: $TOTAL_WORKTREES"

sed -i "s|\[PHASE_SPECIFIC_CHECKS\]|$PHASE_CHECKS|g" "$OUTPUT"

# Generate issues and recommendations
ISSUES=""
RECOMMENDATIONS=""

if [[ "$MAIN_VIOLATIONS" -gt 0 ]]; then
    ISSUES="- CRITICAL: $MAIN_VIOLATIONS commits found on main branch by agents"
    RECOMMENDATIONS="- Immediately stop work on main branch. Create proper worktrees. Clean up main branch commits."
elif [[ "$COMPLETED_TASKS" -eq 0 ]] && [[ "$TOTAL_TASKS" -gt 0 ]]; then
    ISSUES="- No task progress detected despite available tasks"
    RECOMMENDATIONS="- Check if agents have started work. Verify worktree setup. Monitor next phase."
else
    ISSUES="- None detected"
    RECOMMENDATIONS="- Continue monitoring progress. Prepare for end phase verification."
fi

sed -i "s|\[ISSUES_LIST\]|$ISSUES|g" "$OUTPUT"
sed -i "s|\[RECOMMENDATIONS_LIST\]|$RECOMMENDATIONS|g" "$OUTPUT"

# Task progress table
CLAUDE_TASKS=$(grep -c "@claude" "$LAYERED_TASKS" 2>/dev/null || echo "0")
COPILOT_TASKS=$(grep -c "@copilot" "$LAYERED_TASKS" 2>/dev/null || echo "0")  
CODEX_TASKS=$(grep -c "@codex" "$LAYERED_TASKS" 2>/dev/null || echo "0")

TASK_TABLE="Progress Summary: Total=$TOTAL_TASKS, Completed=$COMPLETED_TASKS, Pending=$PENDING_TASKS, Agent distribution: claude=$CLAUDE_TASKS, copilot=$COPILOT_TASKS, codex=$CODEX_TASKS"

sed -i "s|\[TASK_PROGRESS_TABLE\]|$TASK_TABLE|g" "$OUTPUT"

# Compliance gates
WORKTREE_GATE=$([ "$TOTAL_WORKTREES" -gt 1 ] && echo "✅ PASS" || echo "❌ FAIL")
ROLE_GATE=$([ "$OVERALL_STATUS" != "⚠️ VIOLATIONS" ] && echo "✅ PASS" || echo "❌ FAIL")
COORDINATION_GATE=$([ "$COMPLETED_TASKS" -gt 0 ] && echo "✅ PASS" || echo "⚠️ PENDING")
PHASE_GATE=$([ "$MAIN_VIOLATIONS" -eq 0 ] && echo "✅ PASS" || echo "❌ FAIL")

sed -i "s|\[WORKTREE_GATE_STATUS\]|$WORKTREE_GATE|g" "$OUTPUT"
sed -i "s|\[ROLE_GATE_STATUS\]|$ROLE_GATE|g" "$OUTPUT"
sed -i "s|\[COORDINATION_GATE_STATUS\]|$COORDINATION_GATE|g" "$OUTPUT"
sed -i "s|\[PHASE_GATE_STATUS\]|$PHASE_GATE|g" "$OUTPUT"

# Quality gates
sed -i "s|\[COMMIT_GATE_STATUS\]|$([ "$MAIN_VIOLATIONS" -eq 0 ] && echo "✅ PASS" || echo "❌ FAIL")|g" "$OUTPUT"
sed -i "s|\[QUALITY_GATE_STATUS\]|Monitoring in progress|g" "$OUTPUT"
sed -i "s|\[DOCS_GATE_STATUS\]|Monitoring in progress|g" "$OUTPUT"

# Next steps
if [[ "$MAIN_VIOLATIONS" -gt 0 ]]; then
    NEXT_STEPS="CRITICAL: Fix main branch violations immediately. Stop all work until resolved."
elif [[ "$OVERALL_STATUS" == "✅ PROGRESSING" ]]; then
    NEXT_STEPS="Continue monitoring progress. Run /supervisor end $SPEC_NAME when work completes."
else
    NEXT_STEPS="Check agent activity. Ensure proper worktree usage. Monitor task completion."
fi

sed -i "s|\[NEXT_STEPS_LIST\]|$NEXT_STEPS|g" "$OUTPUT"

# Audit trail
sed -i "s|\[AGENTS_COUNT\]|5|g" "$OUTPUT"
ISSUES_COUNT=$([ "$MAIN_VIOLATIONS" -gt 0 ] && echo "1" || echo "0")
sed -i "s|\[ISSUES_COUNT\]|$ISSUES_COUNT|g" "$OUTPUT"
BLOCKERS_COUNT=$([ "$MAIN_VIOLATIONS" -gt 0 ] && echo "1" || echo "0")
sed -i "s|\[BLOCKERS_COUNT\]|$BLOCKERS_COUNT|g" "$OUTPUT"

echo ""
echo "✅ **Supervisor Mid Monitoring Complete**"
echo ""
echo "📁 **Spec**: $SPEC_NAME"
echo "📋 **Report Generated**: $OUTPUT"
echo "🎯 **Overall Status**: $OVERALL_STATUS"
echo ""
echo "📊 **Progress Summary**:"
echo "  - Tasks Completed: $COMPLETED_TASKS/$TOTAL_TASKS"
echo "  - Main Branch: $([ "$MAIN_VIOLATIONS" -eq 0 ] && echo "✅ Protected" || echo "❌ $MAIN_VIOLATIONS violations")"
echo "  - Active Worktrees: $TOTAL_WORKTREES"

echo ""
if [[ "$MAIN_VIOLATIONS" -gt 0 ]]; then
    echo "🚨 **CRITICAL**: Main branch violations detected!"
    echo "⚠️ **Action Required**: Fix immediately before continuing"
else
    echo "🔄 **Next Check**: /supervisor:end $SPEC_NAME when work completes"
fi
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

# Get script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SPEC_DIR="$REPO_ROOT/specs/$SPEC_NAME"
SUPERVISOR_DIR="$SPEC_DIR/supervisor"
TEMPLATE="$REPO_ROOT/.multiagent/supervisor/templates/end-report.template.md"
OUTPUT="$SUPERVISOR_DIR/end-report.md"

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

echo "=== Supervisor End Phase Verification ==="
echo "Spec: $SPEC_NAME"
echo "Phase: END (PR readiness and worktree cleanup)"

# Check if layered-tasks.md exists
LAYERED_TASKS="$SPEC_DIR/agent-tasks/layered-tasks.md"
if [[ -f "$LAYERED_TASKS" ]]; then
    LOAD_STATUS="✅ layered-tasks.md found and readable"
    TASK_SETUP="READY"
else
    LOAD_STATUS="❌ layered-tasks.md missing"
    TASK_SETUP="BLOCKED"
fi

# Advanced completion analysis
check_task_completion() {
    local completed=$(grep -c "\[x\]" "$LAYERED_TASKS" 2>/dev/null || echo "0")
    local pending=$(grep -c "\[ \]" "$LAYERED_TASKS" 2>/dev/null || echo "0")
    local total=$((completed + pending))
    
    if [[ "$total" -eq 0 ]]; then
        echo "NO_TASKS"
    elif [[ "$completed" -eq "$total" ]]; then
        echo "ALL_COMPLETE"
    elif [[ "$completed" -gt 0 ]]; then
        echo "PARTIAL_COMPLETE"
    else
        echo "NO_PROGRESS"
    fi
}

# Check worktree cleanup readiness
check_worktree_cleanup() {
    local agent_worktrees=$(git worktree list | grep -v "$(git rev-parse --show-toplevel)" | wc -l)
    
    if [[ "$agent_worktrees" -eq 0 ]]; then
        echo "✅ CLEAN"
    else
        echo "⚠️ $agent_worktrees WORKTREES_NEED_CLEANUP"
    fi
}

# Check for uncommitted work in worktrees
check_uncommitted_work() {
    local uncommitted_found=false
    
    git worktree list --porcelain | grep "worktree" | while read -r line; do
        if [[ "$line" =~ ^worktree ]]; then
            worktree_path="${line#worktree }"
            if [[ "$worktree_path" != "$(git rev-parse --show-toplevel)" ]]; then
                cd "$worktree_path" 2>/dev/null || continue
                if [[ -n "$(git status --porcelain)" ]]; then
                    uncommitted_found=true
                fi
            fi
        fi
    done
    
    if $uncommitted_found; then
        echo "⚠️ UNCOMMITTED_WORK"
    else
        echo "✅ COMMITTED"
    fi
}

# Check main branch protection (final check)
check_final_main_protection() {
    local main_commits=$(git log main --oneline -20 --format="%an" 2>/dev/null | grep -c "Claude\|Copilot\|Codex\|Qwen\|Gemini" || echo "0")
    main_commits=$(echo "$main_commits" | head -1)  # Take first line only
    
    if [[ "$main_commits" =~ ^[0-9]+$ ]] && [[ "$main_commits" -gt 0 ]]; then
        echo "❌ MAIN_POLLUTED_$main_commits"
    else
        echo "✅ MAIN_CLEAN"
    fi
}

# Check PR readiness
check_pr_readiness() {
    local completion_status=$(check_task_completion)
    local main_status=$(check_final_main_protection)
    local worktree_status=$(check_worktree_cleanup)
    
    if [[ "$completion_status" == "ALL_COMPLETE" ]] && [[ "$main_status" =~ ^✅ ]] && [[ "$worktree_status" =~ ^✅ ]]; then
        echo "✅ READY"
    else
        echo "❌ NOT_READY"
    fi
}

TASK_COMPLETION=$(check_task_completion)
WORKTREE_CLEANUP=$(check_worktree_cleanup)
UNCOMMITTED_STATUS=$(check_uncommitted_work)
MAIN_PROTECTION=$(check_final_main_protection)
PR_READINESS=$(check_pr_readiness)

# Count metrics
COMPLETED_TASKS=$(grep -c "\[x\]" "$LAYERED_TASKS" 2>/dev/null || echo "0")
PENDING_TASKS=$(grep -c "\[ \]" "$LAYERED_TASKS" 2>/dev/null || echo "0")
TOTAL_TASKS=$((COMPLETED_TASKS + PENDING_TASKS))
ACTIVE_WORKTREES=$(git worktree list | grep -v "$(git rev-parse --show-toplevel)" | wc -l)

# Generate summary
if [[ "$PR_READINESS" == "✅ READY" ]]; then
    SUMMARY="END phase verification: ✅ ALL SYSTEMS READY. Tasks complete, main branch clean, worktrees ready for cleanup. PRs can be created."
    OVERALL_STATUS="✅ READY_FOR_PRS"
elif [[ "$MAIN_PROTECTION" =~ POLLUTED ]]; then
    SUMMARY="END phase verification: ❌ MAIN BRANCH VIOLATIONS. Must clean main branch before PR creation."
    OVERALL_STATUS="❌ MAIN_VIOLATIONS"
elif [[ "$TASK_COMPLETION" != "ALL_COMPLETE" ]]; then
    SUMMARY="END phase verification: ⚠️ INCOMPLETE WORK. $COMPLETED_TASKS/$TOTAL_TASKS tasks completed. Finish work before PRs."
    OVERALL_STATUS="⚠️ INCOMPLETE"
else
    SUMMARY="END phase verification: ⚠️ CLEANUP NEEDED. Work complete but worktrees need cleanup before PR creation."
    OVERALL_STATUS="⚠️ NEEDS_CLEANUP"
fi

# Copy template and fill placeholders
cp "$TEMPLATE" "$OUTPUT"

# Replace placeholders with actual values
sed -i "s|\[SPEC_NAME\]|$SPEC_NAME|g" "$OUTPUT"
sed -i "s|\[PHASE\]|END|g" "$OUTPUT"
sed -i "s|\[TIMESTAMP\]|$TIMESTAMP|g" "$OUTPUT"
sed -i "s|\[SPEC_PATH\]|$SPEC_DIR|g" "$OUTPUT"
sed -i "s|\[LOAD_STATUS\]|$LOAD_STATUS|g" "$OUTPUT"
sed -i "s|\[WORKTREE_STATUS\]|$ACTIVE_WORKTREES active worktrees, Status: $WORKTREE_CLEANUP|g" "$OUTPUT"
sed -i "s|\[ROLE_STATUS\]|End phase - completion verification|g" "$OUTPUT"
sed -i "s|\[PROGRESS_STATUS\]|$COMPLETED_TASKS/$TOTAL_TASKS tasks completed|g" "$OUTPUT"
sed -i "s|\[REPORT_STATUS\]|✅ Generated|g" "$OUTPUT"
sed -i "s|\[SUMMARY_TEXT\]|$SUMMARY|g" "$OUTPUT"

# Fill agent-specific completion status
sed -i "s|\[CLAUDE_WORKTREE_STATUS\]|$TASK_COMPLETION|g" "$OUTPUT"
sed -i "s|\[COPILOT_WORKTREE_STATUS\]|$TASK_COMPLETION|g" "$OUTPUT"
sed -i "s|\[CODEX_WORKTREE_STATUS\]|$TASK_COMPLETION|g" "$OUTPUT"
sed -i "s|\[QWEN_WORKTREE_STATUS\]|$TASK_COMPLETION|g" "$OUTPUT"
sed -i "s|\[GEMINI_WORKTREE_STATUS\]|$TASK_COMPLETION|g" "$OUTPUT"

# Role status (final verification)
sed -i "s|\[CLAUDE_ROLE_STATUS\]|COMPLETE|g" "$OUTPUT"
sed -i "s|\[CLAUDE_ROLE_DETAILS\]|Architecture work finished|g" "$OUTPUT"
sed -i "s|\[COPILOT_ROLE_STATUS\]|COMPLETE|g" "$OUTPUT"
sed -i "s|\[COPILOT_ROLE_DETAILS\]|Implementation finished|g" "$OUTPUT"
sed -i "s|\[CODEX_ROLE_STATUS\]|COMPLETE|g" "$OUTPUT"
sed -i "s|\[CODEX_ROLE_DETAILS\]|Scripts and automation finished|g" "$OUTPUT"
sed -i "s|\[QWEN_ROLE_STATUS\]|COMPLETE|g" "$OUTPUT"
sed -i "s|\[QWEN_ROLE_DETAILS\]|Performance optimization finished|g" "$OUTPUT"
sed -i "s|\[GEMINI_ROLE_STATUS\]|COMPLETE|g" "$OUTPUT"
sed -i "s|\[GEMINI_ROLE_DETAILS\]|Research and analysis finished|g" "$OUTPUT"

# Phase-specific content for END phase
CLEANUP_STATUS=$([ "$ACTIVE_WORKTREES" -eq 0 ] && echo "COMPLETE" || echo "PENDING")
COMMIT_STATUS=$([ "$UNCOMMITTED_STATUS" =~ ^✅ ] && echo "CLEAN" || echo "UNCOMMITTED")

PHASE_CHECKS="PR Readiness Verification: Task completion: $TASK_COMPLETION, Main branch: $MAIN_PROTECTION, Worktree cleanup: $CLEANUP_STATUS, Commit status: $COMMIT_STATUS, Overall PR readiness: $PR_READINESS"

sed -i "s|\[PHASE_SPECIFIC_CHECKS\]|$PHASE_CHECKS|g" "$OUTPUT"

# Generate issues and recommendations based on status
ISSUES=""
RECOMMENDATIONS=""

if [[ "$MAIN_PROTECTION" =~ POLLUTED ]]; then
    main_count=$(echo "$MAIN_PROTECTION" | grep -o '[0-9]\+' || echo "unknown")
    ISSUES="- CRITICAL: $main_count commits found on main branch"
    RECOMMENDATIONS="- Clean main branch immediately. Move commits to proper branches. Do not create PRs until fixed."
elif [[ "$TASK_COMPLETION" == "NO_PROGRESS" ]]; then
    ISSUES="- No tasks completed"
    RECOMMENDATIONS="- Verify agents completed their work. Check worktrees for uncommitted changes."
elif [[ "$TASK_COMPLETION" == "PARTIAL_COMPLETE" ]]; then
    ISSUES="- Incomplete work: $COMPLETED_TASKS/$TOTAL_TASKS tasks finished"
    RECOMMENDATIONS="- Complete remaining tasks before PR creation. Verify no blocking dependencies."
elif [[ "$ACTIVE_WORKTREES" -gt 0 ]]; then
    ISSUES="- $ACTIVE_WORKTREES worktrees still active"
    RECOMMENDATIONS="- Create PRs from worktrees, then clean up worktrees after PR merge."
else
    ISSUES="- None detected"
    RECOMMENDATIONS="- Create PRs from completed work. Clean up worktrees after merge."
fi

sed -i "s|\[ISSUES_LIST\]|$ISSUES|g" "$OUTPUT"
sed -i "s|\[RECOMMENDATIONS_LIST\]|$RECOMMENDATIONS|g" "$OUTPUT"

# Task progress table (final summary)
CLAUDE_TASKS=$(grep -c "@claude" "$LAYERED_TASKS" 2>/dev/null || echo "0")
COPILOT_TASKS=$(grep -c "@copilot" "$LAYERED_TASKS" 2>/dev/null || echo "0")  
CODEX_TASKS=$(grep -c "@codex" "$LAYERED_TASKS" 2>/dev/null || echo "0")

COMPLETION_RATE=$(( TOTAL_TASKS > 0 ? (COMPLETED_TASKS * 100) / TOTAL_TASKS : 0 ))

TASK_TABLE="Final Summary: Total=$TOTAL_TASKS, Completed=$COMPLETED_TASKS ($COMPLETION_RATE%), Pending=$PENDING_TASKS, Active worktrees=$ACTIVE_WORKTREES, PR readiness=$PR_READINESS"

sed -i "s|\[TASK_PROGRESS_TABLE\]|$TASK_TABLE|g" "$OUTPUT"

# Compliance gates (final verification)
WORKTREE_GATE=$([ "$PR_READINESS" == "✅ READY" ] && echo "✅ PASS" || echo "❌ FAIL")
ROLE_GATE=$([ "$TASK_COMPLETION" == "ALL_COMPLETE" ] && echo "✅ PASS" || echo "❌ FAIL")
COORDINATION_GATE=$([ "$MAIN_PROTECTION" =~ ^✅ ] && echo "✅ PASS" || echo "❌ FAIL")
PHASE_GATE=$([ "$PR_READINESS" == "✅ READY" ] && echo "✅ PASS" || echo "❌ FAIL")

sed -i "s|\[WORKTREE_GATE_STATUS\]|$WORKTREE_GATE|g" "$OUTPUT"
sed -i "s|\[ROLE_GATE_STATUS\]|$ROLE_GATE|g" "$OUTPUT"
sed -i "s|\[COORDINATION_GATE_STATUS\]|$COORDINATION_GATE|g" "$OUTPUT"
sed -i "s|\[PHASE_GATE_STATUS\]|$PHASE_GATE|g" "$OUTPUT"

# Quality gates (final check)
sed -i "s|\[COMMIT_GATE_STATUS\]|$([ "$UNCOMMITTED_STATUS" =~ ^✅ ] && echo "✅ PASS" || echo "❌ FAIL")|g" "$OUTPUT"
sed -i "s|\[QUALITY_GATE_STATUS\]|$([ "$MAIN_PROTECTION" =~ ^✅ ] && echo "✅ PASS" || echo "❌ FAIL")|g" "$OUTPUT"
sed -i "s|\[DOCS_GATE_STATUS\]|$([ "$TASK_COMPLETION" == "ALL_COMPLETE" ] && echo "✅ PASS" || echo "⚠️ PENDING")|g" "$OUTPUT"

# Next steps and worktree cleanup
if [[ "$PR_READINESS" == "✅ READY" ]]; then
    NEXT_STEPS="Ready for PR creation. After PR merge: Clean up worktrees with: git worktree remove [worktree-path] && git branch -d [branch-name]"
elif [[ "$MAIN_PROTECTION" =~ POLLUTED ]]; then
    NEXT_STEPS="CRITICAL: Clean main branch before PR creation. Move agent commits to proper branches."
else
    NEXT_STEPS="Complete remaining work and fix issues. Re-run /supervisor end $SPEC_NAME when ready."
fi

sed -i "s|\[NEXT_STEPS_LIST\]|$NEXT_STEPS|g" "$OUTPUT"

# Audit trail
sed -i "s|\[AGENTS_COUNT\]|5|g" "$OUTPUT"
ISSUES_COUNT=$([ "$PR_READINESS" == "✅ READY" ] && echo "0" || echo "1")
sed -i "s|\[ISSUES_COUNT\]|$ISSUES_COUNT|g" "$OUTPUT"
BLOCKERS_COUNT=$([ "$MAIN_PROTECTION" =~ POLLUTED ] && echo "1" || echo "0")
sed -i "s|\[BLOCKERS_COUNT\]|$BLOCKERS_COUNT|g" "$OUTPUT"

# Generate worktree cleanup commands if needed
if [[ "$ACTIVE_WORKTREES" -gt 0 ]]; then
    echo ""
    echo "🧹 **Worktree Cleanup Commands** (run after PR merge):"
    git worktree list | grep -v "$(git rev-parse --show-toplevel)" | while read -r worktree branch commit; do
        if [[ -n "$worktree" && -n "$branch" ]]; then
            echo "  git worktree remove $worktree"
            echo "  git branch -d $(basename "$branch")"
        fi
    done
fi

echo ""
echo "✅ **Supervisor End Verification Complete**"
echo ""
echo "📁 **Spec**: $SPEC_NAME"
echo "📋 **Report Generated**: $OUTPUT"
echo "🎯 **Overall Status**: $OVERALL_STATUS"
echo ""
echo "📊 **Final Summary**:"
echo "  - Task Completion: $COMPLETED_TASKS/$TOTAL_TASKS ($COMPLETION_RATE%)"
echo "  - Main Branch: $([ "$MAIN_PROTECTION" =~ ^✅ ] && echo "✅ Clean" || echo "❌ Polluted")"
echo "  - PR Readiness: $PR_READINESS"
echo "  - Active Worktrees: $ACTIVE_WORKTREES (need cleanup after PR merge)"
echo ""
if [[ "$PR_READINESS" == "✅ READY" ]]; then
    echo "🚀 **Ready**: Create PRs from worktrees"
    echo "🧹 **After Merge**: Clean up worktrees (commands shown above)"
else
    echo "⚠️ **Action Required**: Fix issues before PR creation"
fi
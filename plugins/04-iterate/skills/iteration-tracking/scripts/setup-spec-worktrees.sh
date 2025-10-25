#!/bin/bash
# Setup Agent Worktrees for a Spec
# Location: $HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate/scripts/setup-spec-worktrees.sh
# Usage: Called by task-layering agent after layered-tasks.md is created
# Example: $HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate/scripts/setup-spec-worktrees.sh 005-documentation-management-system

set -euo pipefail

SPEC_NAME="$1"

if [[ -z "$SPEC_NAME" ]]; then
    echo "Usage: setup-spec-worktrees.sh <spec-name>"
    echo "Example: setup-spec-worktrees.sh 005-documentation-management-system"
    exit 1
fi

# SECURITY: Validate SPEC_NAME to prevent path traversal
if [[ "$SPEC_NAME" =~ \.\. ]] || [[ "$SPEC_NAME" =~ / ]]; then
    echo "ERROR: Invalid spec name '$SPEC_NAME'"
    echo "Spec name cannot contain '..' or '/' (path traversal attempt)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SPEC_DIR="$REPO_ROOT/specs/$SPEC_NAME"

# Verify we're in main/master branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
    echo "ERROR: Must be on main/master branch to create worktrees"
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Use current branch as base for worktrees
BASE_BRANCH="$CURRENT_BRANCH"

# Verify layered tasks exist
LAYERED_TASKS="$SPEC_DIR/agent-tasks/layered-tasks.md"
if [[ ! -f "$LAYERED_TASKS" ]]; then
    echo "ERROR: Layered tasks not found at: $LAYERED_TASKS"
    echo "This script must run AFTER layered-tasks.md is created"
    exit 1
fi

echo "🚀 Setting up agent worktrees for spec: $SPEC_NAME"
echo ""

# Extract spec number from spec name (e.g., 005 from 005-documentation-management-system)
SPEC_NUMBER=$(echo "$SPEC_NAME" | grep -oE '^[0-9]+')

# Detect which agents have tasks in layered-tasks.md
echo "📋 Analyzing layered-tasks.md to detect agents with work..."
AGENTS_WITH_TASKS=()

for agent in claude codex qwen gemini copilot; do
    if grep -q "@$agent" "$LAYERED_TASKS"; then
        TASK_COUNT=$(grep -c "@$agent" "$LAYERED_TASKS")
        echo "   ✓ @$agent has $TASK_COUNT tasks"
        AGENTS_WITH_TASKS+=("$agent")
    else
        echo "   ○ @$agent has no tasks (skipping worktree)"
    fi
done

if [[ ${#AGENTS_WITH_TASKS[@]} -eq 0 ]]; then
    echo ""
    echo "⚠️  No agents with tasks found in layered-tasks.md"
    exit 0
fi

echo ""
echo "📁 Creating worktrees for ${#AGENTS_WITH_TASKS[@]} agents with tasks..."
echo ""

WORKTREE_BASE="$(cd "$REPO_ROOT/.." && pwd)"
CREATED_WORKTREES=()

# Create worktrees only for agents that have tasks
for AGENT in "${AGENTS_WITH_TASKS[@]}"; do
    BRANCH_NAME="agent-${AGENT}-${SPEC_NUMBER}"
    WORKTREE_PATH="$WORKTREE_BASE/${BRANCH_NAME}"

    # Check if worktree already exists
    if [[ -d "$WORKTREE_PATH" ]]; then
        echo "⚠️  Worktree already exists: $WORKTREE_PATH"
        echo "   Checking if it's for a different spec..."

        # Check current branch in existing worktree
        EXISTING_BRANCH=$(cd "$WORKTREE_PATH" && git branch --show-current)

        if [[ "$EXISTING_BRANCH" == "$BRANCH_NAME" ]]; then
            echo "   ✓ Already set up for this spec, skipping..."
            CREATED_WORKTREES+=("$AGENT:$WORKTREE_PATH")
            continue
        else
            echo "   ✗ Different spec ($EXISTING_BRANCH), needs cleanup"
            echo "   Removing old worktree..."
            git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || true
            git branch -D "$EXISTING_BRANCH" 2>/dev/null || true
        fi
    fi

    # Create worktree from BASE_BRANCH (stays on current, creates branch in worktree)
    echo "📁 Creating worktree for @${AGENT}..."
    echo "   Branch: $BRANCH_NAME"
    echo "   Path: $WORKTREE_PATH"
    echo "   Base: $BASE_BRANCH"

    git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "$BASE_BRANCH"
    CREATED_WORKTREES+=("$AGENT:$WORKTREE_PATH")

    echo "   ✅ Worktree created"
    echo ""
done

# Create symlinks in each worktree
echo "🔗 Setting up task visibility symlinks..."
echo ""

SYMLINK_SCRIPT="$SCRIPT_DIR/setup-worktree-symlinks.sh"

for ENTRY in "${CREATED_WORKTREES[@]}"; do
    AGENT="${ENTRY%%:*}"
    WORKTREE_PATH="${ENTRY#*:}"

    echo "   @${AGENT}: Creating symlink..."

    # Run symlink script from the worktree context
    cd "$WORKTREE_PATH"

    if bash "$SYMLINK_SCRIPT" "$SPEC_NAME"; then
        echo "   ✅ Symlink created at: specs/$SPEC_NAME/layered-tasks-main.md"
    else
        echo "   ⚠️  Symlink creation failed for @${AGENT}"
        echo "   Tasks will not auto-update from main. Manual sync required."
    fi
    echo ""
done

# Return to main repo
cd "$REPO_ROOT"

echo "✅ **Worktree Setup Complete**"
echo ""
echo "📋 **Spec**: $SPEC_NAME (Spec #$SPEC_NUMBER)"
echo "🌳 **Worktrees Created**: ${#CREATED_WORKTREES[@]} agents with tasks"
echo ""
echo "**Agent Worktrees**:"
for ENTRY in "${CREATED_WORKTREES[@]}"; do
    AGENT="${ENTRY%%:*}"
    WORKTREE_PATH="${ENTRY#*:}"
    BRANCH=$(cd "$WORKTREE_PATH" && git branch --show-current)
    echo "   @$AGENT → $WORKTREE_PATH [$BRANCH]"
done
echo ""
echo "**All Worktrees**:"
git worktree list
echo ""
echo "**Branch Naming**: agent-{agent}-{spec-number}"
echo "   Example: agent-claude-005, agent-codex-005"
echo ""
echo "**Next Steps**:"
echo "1. Agents: Run 'git worktree list' to find your worktree"
echo "2. Navigate: cd ../agent-{agent}-$SPEC_NUMBER"
echo "3. Check tasks: cat specs/$SPEC_NAME/agent-tasks/layered-tasks-main.md"
echo "4. Commit with @{agent} tag in final commit"
echo "5. Create PR: gh pr create"
echo ""
echo "**Cleanup After Merge**:"
echo "   cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" (main repo)"
echo "   git worktree remove ../agent-{agent}-$SPEC_NUMBER"
echo "   git branch -d agent-{agent}-$SPEC_NUMBER"
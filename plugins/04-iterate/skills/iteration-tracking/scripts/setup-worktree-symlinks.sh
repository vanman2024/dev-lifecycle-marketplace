#!/bin/bash
# Agent Worktree Symlink Setup
# Location: $HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate/scripts/setup-worktree-symlinks.sh
# Usage: $([ -f "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate/scripts/setup-worktree-symlinks.sh" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate/scripts/setup-worktree-symlinks.sh" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate/skills/*/scripts" -name "setup-worktree-symlinks.sh" -type f 2>/dev/null | head -1) <spec-name>
# Example: $HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate/scripts/setup-worktree-symlinks.sh 005-documentation-management-system

set -euo pipefail

SPEC_NAME="$1"

if [[ -z "$SPEC_NAME" ]]; then
    echo "Usage: setup-worktree-symlinks.sh <spec-name>"
    echo "Example: setup-worktree-symlinks.sh 005-documentation-management-system"
    exit 1
fi

# Get the repo root from current working directory (where script is run from)
# This script is called from the worktree, so pwd gives us the worktree root
REPO_ROOT="$(pwd)"

# Main repo is typically named "multiagent-core"
# If we're in a worktree, we need to go to the actual main repo
if [[ "$(basename "$REPO_ROOT")" == "multiagent-core" ]]; then
    # We're in main repo
    MAIN_REPO_PATH="$REPO_ROOT"
else
    # We're in a worktree (project-codex, project-qwen, etc)
    # Main repo is sibling directory named multiagent-core
    MAIN_REPO_PATH="$(cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"" && pwd)"
fi

MAIN_LAYERED_TASKS="$MAIN_REPO_PATH/specs/$SPEC_NAME/agent-tasks/layered-tasks.md"

# Create symlink in worktree's spec agent-tasks directory
SPEC_DIR="$REPO_ROOT/specs/$SPEC_NAME"
AGENT_TASKS_DIR="$SPEC_DIR/agent-tasks"
WORKTREE_LINK="$AGENT_TASKS_DIR/layered-tasks-main.md"

echo "🔗 Setting up worktree symlink for task visibility..."
echo "   Main repo: $MAIN_REPO_PATH"
echo "   Spec: $SPEC_NAME"

if [[ ! -f "$MAIN_LAYERED_TASKS" ]]; then
    echo "❌ ERROR: Main layered-tasks.md not found at: $MAIN_LAYERED_TASKS"
    echo "   Make sure you're running this from an agent worktree"
    exit 1
fi

# Create symlink
ln -sf "$MAIN_LAYERED_TASKS" "$WORKTREE_LINK"

echo "✅ Symlink created successfully!"
echo "   Link: $WORKTREE_LINK"
echo "   Target: $MAIN_LAYERED_TASKS"
echo ""
echo "📋 Now you can:"
echo "   - Check off tasks in your worktree"
echo "   - Updates visible in main repo instantly"
echo "   - Monitor progress: cat layered-tasks-main.md"
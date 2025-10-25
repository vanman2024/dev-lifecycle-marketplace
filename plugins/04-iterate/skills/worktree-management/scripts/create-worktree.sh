#!/usr/bin/env bash
set -euo pipefail

# Create git worktree for parallel development

BRANCH_NAME="${1:-}"

if [ -z "$BRANCH_NAME" ]; then
    echo "Usage: $0 <branch-name>"
    exit 1
fi

PROJECT_DIR=$(basename "$PWD")
WORKTREE_DIR="../${PROJECT_DIR}-${BRANCH_NAME}"

echo "Creating worktree for branch: $BRANCH_NAME"
git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME"

echo "✅ Worktree created at: $WORKTREE_DIR"
echo "To work in worktree: cd $WORKTREE_DIR"

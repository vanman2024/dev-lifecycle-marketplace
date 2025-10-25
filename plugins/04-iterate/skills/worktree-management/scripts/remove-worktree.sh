#!/usr/bin/env bash
set -euo pipefail

# Remove completed worktree

WORKTREE_PATH="${1:-}"

if [ -z "$WORKTREE_PATH" ]; then
    echo "Usage: $0 <worktree-path>"
    echo ""
    echo "Active worktrees:"
    git worktree list
    exit 1
fi

echo "Removing worktree: $WORKTREE_PATH"
git worktree remove "$WORKTREE_PATH"

echo "✅ Worktree removed"

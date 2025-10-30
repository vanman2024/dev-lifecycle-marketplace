#!/usr/bin/env bash
set -euo pipefail

# List all active git worktrees

echo "Active worktrees:"
git worktree list

echo ""
echo "Total worktrees: $(git worktree list | wc -l)"

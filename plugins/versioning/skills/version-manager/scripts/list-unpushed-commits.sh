#!/usr/bin/env bash
# Script: list-unpushed-commits.sh
# Purpose: List unpushed commits for version bump analysis
# Subsystem: version-management
# Called by: /version:status, version-analyzer agent
# Outputs: JSON with commit list and metadata

set -euo pipefail

# --- Configuration ---
PROJECT_DIR="${1:-.}"
OUTPUT_FILE="${2:-/tmp/unpushed-commits.json}"
BRANCH="${3:-$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")}"

# --- Main Logic ---
cd "$PROJECT_DIR" || exit 1

echo "[INFO] Analyzing unpushed commits on branch '$BRANCH'..."

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    cat > "$OUTPUT_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "error",
  "message": "Not a git repository",
  "commit_count": 0,
  "commits": []
}
EOF
    echo "❌ Not a git repository"
    exit 1
fi

# Get upstream branch
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")

# If no upstream, use origin/branch
if [[ -z "$UPSTREAM" ]]; then
    UPSTREAM="origin/$BRANCH"
fi

# Check if upstream exists
if ! git rev-parse "$UPSTREAM" >/dev/null 2>&1; then
    # No remote branch, count all commits
    COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    COMMIT_RANGE="HEAD"
    MESSAGE="No remote branch found, showing all commits"
else
    # Count commits ahead of upstream
    COMMIT_COUNT=$(git rev-list --count "$UPSTREAM..HEAD" 2>/dev/null || echo "0")
    COMMIT_RANGE="$UPSTREAM..HEAD"
    MESSAGE="Commits ahead of $UPSTREAM"
fi

# Get commit details
COMMITS_JSON="[]"
if [[ "$COMMIT_COUNT" -gt 0 ]]; then
    # Format: hash|date|author|subject
    COMMITS_JSON=$(git log --pretty=format:'{"hash":"%H","short_hash":"%h","date":"%aI","author":"%an","email":"%ae","subject":"%s","body":"%b"}' "$COMMIT_RANGE" | jq -s '.')
fi

# Output JSON result
cat > "$OUTPUT_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "success",
  "message": "$MESSAGE",
  "branch": "$BRANCH",
  "upstream": "$UPSTREAM",
  "commit_count": $COMMIT_COUNT,
  "commits": $COMMITS_JSON
}
EOF

if [[ "$COMMIT_COUNT" -eq 0 ]]; then
    echo "✅ No unpushed commits"
    exit 0
else
    echo "📋 Found $COMMIT_COUNT unpushed commit(s)"
    exit 0
fi

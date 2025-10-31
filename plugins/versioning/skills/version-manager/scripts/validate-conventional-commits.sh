#!/usr/bin/env bash
# Script: validate-conventional-commits.sh
# Purpose: Validate commit messages follow Conventional Commits format
# Subsystem: version-management
# Called by: /version:validate, version-analyzer agent
# Outputs: JSON with validation results and violations

set -euo pipefail

# --- Configuration ---
PROJECT_DIR="${1:-.}"
OUTPUT_FILE="${2:-/tmp/commit-validation.json}"
COMMIT_RANGE="${3:-HEAD~10..HEAD}"  # Default: last 10 commits

# --- Main Logic ---
cd "$PROJECT_DIR" || exit 1

echo "[INFO] Validating conventional commit format for range: $COMMIT_RANGE..."

# Conventional Commits pattern
# Format: type(scope?): subject
# Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|BREAKING CHANGE)(\(.+\))?!?: .{1,}'

# Initialize counters
TOTAL_COMMITS=0
VALID_COMMITS=0
INVALID_COMMITS=0
VIOLATIONS_JSON="[]"

# Get commits in range
while IFS='|' read -r hash short_hash subject; do
    ((TOTAL_COMMITS++))

    # Skip merge commits
    if [[ "$subject" =~ ^Merge ]]; then
        continue
    fi

    # Skip commits with [WORKING], [STABLE], [WIP], [HOTFIX] prefixes (allowed pattern)
    if [[ "$subject" =~ ^\[(WORKING|STABLE|WIP|HOTFIX)\] ]]; then
        # Remove prefix and check remaining format
        CLEAN_SUBJECT=$(echo "$subject" | sed -E 's/^\[(WORKING|STABLE|WIP|HOTFIX)\] //')
    else
        CLEAN_SUBJECT="$subject"
    fi

    # Check if subject matches conventional commits pattern
    if [[ "$CLEAN_SUBJECT" =~ $PATTERN ]]; then
        ((VALID_COMMITS++))
    else
        ((INVALID_COMMITS++))

        # Suggest fix
        SUGGESTED_FIX="Unknown type"
        if [[ "$CLEAN_SUBJECT" =~ ^[Aa]dd ]]; then
            SUGGESTED_FIX="feat: ${CLEAN_SUBJECT#[Aa]dd }"
        elif [[ "$CLEAN_SUBJECT" =~ ^[Ff]ix ]]; then
            SUGGESTED_FIX="fix: ${CLEAN_SUBJECT#[Ff]ix }"
        elif [[ "$CLEAN_SUBJECT" =~ ^[Uu]pdate ]]; then
            SUGGESTED_FIX="chore: ${CLEAN_SUBJECT#[Uu]pdate }"
        elif [[ "$CLEAN_SUBJECT" =~ ^[Rr]efactor ]]; then
            SUGGESTED_FIX="refactor: ${CLEAN_SUBJECT#[Rr]efactor }"
        elif [[ "$CLEAN_SUBJECT" =~ ^[Dd]ocs? ]]; then
            SUGGESTED_FIX="docs: ${CLEAN_SUBJECT#[Dd]ocs? }"
        else
            SUGGESTED_FIX="chore: $CLEAN_SUBJECT"
        fi

        # Add to violations
        VIOLATION=$(cat <<EOF
{
  "hash": "$hash",
  "short_hash": "$short_hash",
  "original": "$subject",
  "suggested": "$SUGGESTED_FIX",
  "reason": "Does not follow Conventional Commits format: type(scope?): subject"
}
EOF
)
        VIOLATIONS_JSON=$(echo "$VIOLATIONS_JSON" | jq --argjson new "$VIOLATION" '. + [$new]')
    fi
done < <(git log --pretty=format:'%H|%h|%s' "$COMMIT_RANGE" 2>/dev/null)

# Calculate percentage
if [[ "$TOTAL_COMMITS" -gt 0 ]]; then
    VALID_PERCENT=$((VALID_COMMITS * 100 / TOTAL_COMMITS))
else
    VALID_PERCENT=0
fi

# Determine status
STATUS="success"
MESSAGE="All commits follow Conventional Commits format"
if [[ "$INVALID_COMMITS" -gt 0 ]]; then
    STATUS="violations_found"
    MESSAGE="Found $INVALID_COMMITS invalid commit(s) out of $TOTAL_COMMITS"
fi

# Output JSON result
cat > "$OUTPUT_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "$STATUS",
  "message": "$MESSAGE",
  "commit_range": "$COMMIT_RANGE",
  "total_commits": $TOTAL_COMMITS,
  "valid_commits": $VALID_COMMITS,
  "invalid_commits": $INVALID_COMMITS,
  "valid_percent": $VALID_PERCENT,
  "violations": $VIOLATIONS_JSON
}
EOF

if [[ "$INVALID_COMMITS" -eq 0 ]]; then
    echo "✅ All $TOTAL_COMMITS commits follow Conventional Commits format"
    exit 0
else
    echo "⚠️  Found $INVALID_COMMITS invalid commit(s) out of $TOTAL_COMMITS ($VALID_PERCENT% valid)"
    exit 1
fi

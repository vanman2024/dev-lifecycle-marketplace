#!/bin/bash
# Generate formatted changelog from git commits

set -e

FROM_TAG="${1}"
TO_REF="${2:-HEAD}"
VERSION="${3}"

# Validate inputs
if [ -z "$FROM_TAG" ]; then
    echo "Error: FROM_TAG required" >&2
    exit 1
fi

# Get commit range
COMMITS=$(git log "$FROM_TAG..$TO_REF" --pretty=format:"%h|%s|%an" 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
    echo "Error: No commits found between $FROM_TAG and $TO_REF" >&2
    exit 1
fi

# Initialize arrays for categorization
FEATURES=()
FIXES=()
BREAKING=()
PERF=()

# Parse commits
while IFS='|' read -r HASH SUBJECT AUTHOR; do
    # Check for breaking changes
    if [[ "$SUBJECT" =~ BREAKING[[:space:]]CHANGE: ]] || [[ "$SUBJECT" =~ ^[a-z]+!: ]]; then
        BREAKING+=("$SUBJECT ($HASH)")
    # Check for features
    elif [[ "$SUBJECT" =~ ^feat(\(.*\))?: ]]; then
        FEATURES+=("$SUBJECT ($HASH)")
    # Check for fixes
    elif [[ "$SUBJECT" =~ ^fix(\(.*\))?: ]]; then
        FIXES+=("$SUBJECT ($HASH)")
    # Check for performance
    elif [[ "$SUBJECT" =~ ^perf(\(.*\))?: ]]; then
        PERF+=("$SUBJECT ($HASH)")
    fi
done <<< "$COMMITS"

# Generate changelog output
DATE=$(date +%Y-%m-%d)

if [ -n "$VERSION" ]; then
    echo "## [$VERSION] - $DATE"
else
    echo "## Unreleased - $DATE"
fi
echo ""

# Breaking Changes section (if any)
if [ ${#BREAKING[@]} -gt 0 ]; then
    echo "### Breaking Changes"
    echo ""
    for item in "${BREAKING[@]}"; do
        # Remove type prefix
        CLEAN=$(echo "$item" | sed -E 's/^[a-z]+!?(\([^)]+\))?:[[:space:]]*//')
        echo "- $CLEAN"
    done
    echo ""
fi

# Features section (if any)
if [ ${#FEATURES[@]} -gt 0 ]; then
    echo "### Features"
    echo ""
    for item in "${FEATURES[@]}"; do
        # Remove "feat:" or "feat(scope):" prefix
        CLEAN=$(echo "$item" | sed -E 's/^feat(\([^)]+\))?:[[:space:]]*//')
        echo "- $CLEAN"
    done
    echo ""
fi

# Bug Fixes section (if any)
if [ ${#FIXES[@]} -gt 0 ]; then
    echo "### Bug Fixes"
    echo ""
    for item in "${FIXES[@]}"; do
        # Remove "fix:" or "fix(scope):" prefix
        CLEAN=$(echo "$item" | sed -E 's/^fix(\([^)]+\))?:[[:space:]]*//')
        echo "- $CLEAN"
    done
    echo ""
fi

# Performance section (if any)
if [ ${#PERF[@]} -gt 0 ]; then
    echo "### Performance"
    echo ""
    for item in "${PERF[@]}"; do
        # Remove "perf:" or "perf(scope):" prefix
        CLEAN=$(echo "$item" | sed -E 's/^perf(\([^)]+\))?:[[:space:]]*//')
        echo "- $CLEAN"
    done
    echo ""
fi

# Footer statistics
COMMIT_COUNT=$(echo "$COMMITS" | wc -l)
CONTRIBUTOR_COUNT=$(echo "$COMMITS" | cut -d'|' -f3 | sort -u | wc -l)

echo "**Commits**: $COMMIT_COUNT | **Contributors**: $CONTRIBUTOR_COUNT"

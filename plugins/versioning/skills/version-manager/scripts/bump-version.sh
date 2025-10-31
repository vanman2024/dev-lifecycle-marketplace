#!/bin/bash
# Bump semantic version (major, minor, or patch)

set -e

BUMP_TYPE="${1:-patch}"
CURRENT_VERSION="${2}"

# If no version provided, try to read from VERSION file
if [ -z "$CURRENT_VERSION" ] && [ -f "VERSION" ]; then
    CURRENT_VERSION=$(cat VERSION | jq -r '.version' 2>/dev/null || echo "")
fi

# Validate current version provided
if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Current version not provided and VERSION file not found" >&2
    exit 1
fi

# Validate version format (semver)
if ! [[ "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid version format: $CURRENT_VERSION (expected: X.Y.Z)" >&2
    exit 1
fi

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Calculate new version based on bump type
case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Error: Invalid bump type: $BUMP_TYPE (expected: major, minor, or patch)" >&2
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Output new version
echo "$NEW_VERSION"

# Log to stderr
echo "Bumped version: $CURRENT_VERSION → $NEW_VERSION ($BUMP_TYPE)" >&2

#!/bin/bash
# Create annotated git tag with changelog

set -e

VERSION="${1}"
CHANGELOG_FILE="${2}"

# Validate inputs
if [ -z "$VERSION" ]; then
    echo "Error: Version required" >&2
    exit 1
fi

# Add 'v' prefix if not present
if [[ ! "$VERSION" =~ ^v ]]; then
    TAG_NAME="v$VERSION"
else
    TAG_NAME="$VERSION"
fi

# Check if tag already exists
if git tag -l "$TAG_NAME" | grep -q "^$TAG_NAME$"; then
    echo "Error: Tag $TAG_NAME already exists" >&2
    exit 1
fi

# Read changelog content
if [ -n "$CHANGELOG_FILE" ] && [ -f "$CHANGELOG_FILE" ]; then
    CHANGELOG_CONTENT=$(cat "$CHANGELOG_FILE")
else
    CHANGELOG_CONTENT="Release $VERSION"
fi

# Create annotated tag
git tag -a "$TAG_NAME" -m "$CHANGELOG_CONTENT"

# Verify tag created
if git tag -l "$TAG_NAME" | grep -q "^$TAG_NAME$"; then
    echo "✅ Created tag: $TAG_NAME" >&2
    
    # Show tag details
    echo "" >&2
    echo "Tag details:" >&2
    git show "$TAG_NAME" --no-patch >&2
else
    echo "Error: Failed to create tag $TAG_NAME" >&2
    exit 1
fi

# Output tag name
echo "$TAG_NAME"

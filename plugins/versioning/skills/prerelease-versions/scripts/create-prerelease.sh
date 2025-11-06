#!/bin/bash

# create-prerelease.sh
# Create a new pre-release version with automatic version calculation
# Usage: bash create-prerelease.sh <prerelease_type> <base_version>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

# Validate arguments
if [ $# -ne 2 ]; then
    print_error "Invalid number of arguments"
    echo "Usage: $0 <prerelease_type> <base_version>"
    echo "  prerelease_type: alpha, beta, or rc"
    echo "  base_version: Target stable version (e.g., 1.0.0)"
    exit 1
fi

PRERELEASE_TYPE="$1"
BASE_VERSION="$2"

# Validate pre-release type
if [[ ! "$PRERELEASE_TYPE" =~ ^(alpha|beta|rc)$ ]]; then
    print_error "Invalid pre-release type: $PRERELEASE_TYPE"
    echo "Valid types: alpha, beta, rc"
    exit 1
fi

# Validate base version format (semantic versioning)
if [[ ! "$BASE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Invalid base version format: $BASE_VERSION"
    echo "Expected format: MAJOR.MINOR.PATCH (e.g., 1.0.0)"
    exit 1
fi

# Find the latest pre-release number for this type and base version
LATEST_PRERELEASE_NUM=0

# Check git tags for existing pre-releases
if git rev-parse --git-dir > /dev/null 2>&1; then
    EXISTING_TAGS=$(git tag -l "v${BASE_VERSION}-${PRERELEASE_TYPE}.*" 2>/dev/null || true)

    if [ -n "$EXISTING_TAGS" ]; then
        # Extract the highest pre-release number
        for tag in $EXISTING_TAGS; do
            # Extract number after the pre-release type
            NUM=$(echo "$tag" | sed -n "s/^v${BASE_VERSION}-${PRERELEASE_TYPE}\.\([0-9]*\)$/\1/p")
            if [ -n "$NUM" ] && [ "$NUM" -gt "$LATEST_PRERELEASE_NUM" ]; then
                LATEST_PRERELEASE_NUM=$NUM
            fi
        done
    fi
fi

# Increment pre-release number
NEW_PRERELEASE_NUM=$((LATEST_PRERELEASE_NUM + 1))
NEW_VERSION="${BASE_VERSION}-${PRERELEASE_TYPE}.${NEW_PRERELEASE_NUM}"

print_info "Creating pre-release version: $NEW_VERSION"

# Update VERSION file if it exists
if [ -f "VERSION" ]; then
    print_info "Updating VERSION file..."
    # Check if VERSION is JSON format
    if grep -q "{" VERSION 2>/dev/null; then
        # JSON format
        TMP_FILE=$(mktemp)
        jq --arg version "$NEW_VERSION" '.version = $version' VERSION > "$TMP_FILE"
        mv "$TMP_FILE" VERSION
    else
        # Plain text format
        echo "$NEW_VERSION" > VERSION
    fi
    print_success "VERSION file updated to $NEW_VERSION"
fi

# Update package.json if it exists (Node.js/TypeScript projects)
if [ -f "package.json" ]; then
    print_info "Updating package.json..."
    TMP_FILE=$(mktemp)
    jq --arg version "$NEW_VERSION" '.version = $version' package.json > "$TMP_FILE"
    mv "$TMP_FILE" package.json
    print_success "package.json updated to $NEW_VERSION"
fi

# Update pyproject.toml if it exists (Python projects)
if [ -f "pyproject.toml" ]; then
    print_info "Updating pyproject.toml..."
    sed -i.bak "s/^version = .*/version = \"$NEW_VERSION\"/" pyproject.toml
    rm -f pyproject.toml.bak
    print_success "pyproject.toml updated to $NEW_VERSION"
fi

# Create git tag if in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    TAG_NAME="v${NEW_VERSION}"

    # Check if tag already exists
    if git tag -l "$TAG_NAME" | grep -q "$TAG_NAME"; then
        print_error "Git tag $TAG_NAME already exists"
        exit 3
    fi

    # Create tag message based on pre-release type
    case "$PRERELEASE_TYPE" in
        alpha)
            TAG_MESSAGE="Alpha Release v${NEW_VERSION}

🚧 INTERNAL TESTING ONLY

This is an unstable alpha release for internal testing.
Breaking changes are expected in future releases.

DO NOT USE IN PRODUCTION"
            ;;
        beta)
            TAG_MESSAGE="Beta Release v${NEW_VERSION}

🧪 EARLY ACCESS

This is a beta release for early adopters and testing.
Features are complete but bugs may exist.

Use with caution in production environments."
            ;;
        rc)
            TAG_MESSAGE="Release Candidate v${NEW_VERSION}

✅ PRODUCTION READY (pending final validation)

This release candidate is considered stable and ready for production
unless critical issues are discovered during final testing."
            ;;
    esac

    print_info "Creating git tag $TAG_NAME..."
    git tag -a "$TAG_NAME" -m "$TAG_MESSAGE"
    print_success "Git tag $TAG_NAME created"

    print_info "To push the tag to remote, run:"
    echo "  git push origin $TAG_NAME"
fi

# Output the new version (for scripting/automation)
echo "$NEW_VERSION"

print_success "Pre-release $NEW_VERSION created successfully"
print_info "Next steps:"
echo "  1. Commit version changes: git add . && git commit -m 'chore: bump version to $NEW_VERSION'"
echo "  2. Push tag to remote: git push origin v$NEW_VERSION"
echo "  3. Create GitHub release: gh release create v$NEW_VERSION --prerelease"

exit 0

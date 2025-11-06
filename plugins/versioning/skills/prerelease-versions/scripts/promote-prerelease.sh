#!/bin/bash

# promote-prerelease.sh
# Promote a pre-release to the next stage or stable release
# Usage: bash promote-prerelease.sh <current_version> [--force]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_promotion() {
    echo -e "${BLUE}PROMOTION: $1${NC}"
}

# Validate arguments
if [ $# -lt 1 ]; then
    print_error "Invalid number of arguments"
    echo "Usage: $0 <current_version> [--force]"
    echo "  current_version: Current pre-release version (e.g., 1.0.0-alpha.3)"
    echo "  --force: Force promotion without validation (optional)"
    exit 1
fi

CURRENT_VERSION="$1"
FORCE_MODE=false

# Check for --force flag
if [ $# -eq 2 ] && [ "$2" = "--force" ]; then
    FORCE_MODE=true
    print_info "Force mode enabled - skipping validation"
fi

# Parse current version
if [[ "$CURRENT_VERSION" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-([a-z]+)\.([0-9]+)$ ]]; then
    BASE_VERSION="${BASH_REMATCH[1]}"
    PRERELEASE_TYPE="${BASH_REMATCH[2]}"
    PRERELEASE_NUM="${BASH_REMATCH[3]}"
elif [[ "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Version $CURRENT_VERSION is already a stable release"
    echo "Cannot promote a stable release further"
    exit 1
else
    print_error "Invalid version format: $CURRENT_VERSION"
    echo "Expected format: MAJOR.MINOR.PATCH-TYPE.NUMBER (e.g., 1.0.0-alpha.3)"
    exit 1
fi

# Validate pre-release type
if [[ ! "$PRERELEASE_TYPE" =~ ^(alpha|beta|rc)$ ]]; then
    print_error "Invalid pre-release type: $PRERELEASE_TYPE"
    echo "Valid types: alpha, beta, rc"
    exit 1
fi

# Determine promotion path
case "$PRERELEASE_TYPE" in
    alpha)
        NEW_VERSION="${BASE_VERSION}-beta.1"
        PROMOTION_PATH="Alpha → Beta"
        ;;
    beta)
        NEW_VERSION="${BASE_VERSION}-rc.1"
        PROMOTION_PATH="Beta → Release Candidate"
        ;;
    rc)
        NEW_VERSION="${BASE_VERSION}"
        PROMOTION_PATH="Release Candidate → Stable"
        ;;
esac

print_promotion "Promoting $CURRENT_VERSION → $NEW_VERSION"
print_info "Promotion path: $PROMOTION_PATH"

# Validation checks (unless force mode)
if [ "$FORCE_MODE" = false ]; then
    print_info "Running validation checks..."

    # Check if current version tag exists
    if git rev-parse --git-dir > /dev/null 2>&1; then
        CURRENT_TAG="v${CURRENT_VERSION}"
        if ! git tag -l "$CURRENT_TAG" | grep -q "$CURRENT_TAG"; then
            print_error "Current version tag $CURRENT_TAG does not exist"
            echo "Run with --force to skip validation"
            exit 2
        fi
        print_success "Current version tag exists: $CURRENT_TAG"
    fi

    # Check if VERSION file exists and matches
    if [ -f "VERSION" ]; then
        if grep -q "{" VERSION 2>/dev/null; then
            # JSON format
            VERSION_FILE_VERSION=$(jq -r '.version' VERSION)
        else
            # Plain text format
            VERSION_FILE_VERSION=$(cat VERSION | tr -d '\n')
        fi

        if [ "$VERSION_FILE_VERSION" != "$CURRENT_VERSION" ]; then
            print_error "VERSION file mismatch: expected $CURRENT_VERSION, found $VERSION_FILE_VERSION"
            echo "Run with --force to skip validation"
            exit 2
        fi
        print_success "VERSION file validated"
    fi

    # Check if CHANGELOG.md has entry for current version
    if [ -f "CHANGELOG.md" ]; then
        if ! grep -q "$CURRENT_VERSION" CHANGELOG.md; then
            print_error "CHANGELOG.md missing entry for $CURRENT_VERSION"
            echo "Add changelog entry before promotion or run with --force"
            exit 2
        fi
        print_success "CHANGELOG.md entry exists"
    fi

    print_success "All validation checks passed"
fi

# Confirmation prompt (unless force mode)
if [ "$FORCE_MODE" = false ] && [ -t 0 ]; then
    echo ""
    echo "Ready to promote:"
    echo "  From: $CURRENT_VERSION"
    echo "  To:   $NEW_VERSION"
    echo "  Path: $PROMOTION_PATH"
    echo ""
    read -p "Continue with promotion? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Promotion cancelled by user"
        exit 0
    fi
fi

# Update VERSION file if it exists
if [ -f "VERSION" ]; then
    print_info "Updating VERSION file..."
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

# Update package.json if it exists
if [ -f "package.json" ]; then
    print_info "Updating package.json..."
    TMP_FILE=$(mktemp)
    jq --arg version "$NEW_VERSION" '.version = $version' package.json > "$TMP_FILE"
    mv "$TMP_FILE" package.json
    print_success "package.json updated to $NEW_VERSION"
fi

# Update pyproject.toml if it exists
if [ -f "pyproject.toml" ]; then
    print_info "Updating pyproject.toml..."
    sed -i.bak "s/^version = .*/version = \"$NEW_VERSION\"/" pyproject.toml
    rm -f pyproject.toml.bak
    print_success "pyproject.toml updated to $NEW_VERSION"
fi

# Generate changelog for promoted version
if [ -f "CHANGELOG.md" ] && git rev-parse --git-dir > /dev/null 2>&1; then
    print_info "Generating changelog for $NEW_VERSION..."

    # Get commits since current version tag
    CURRENT_TAG="v${CURRENT_VERSION}"
    CHANGELOG_ENTRIES=$(git log "$CURRENT_TAG"..HEAD --pretty=format:"- %s (%h)" --no-merges 2>/dev/null || echo "")

    if [ -n "$CHANGELOG_ENTRIES" ]; then
        # Prepare changelog header based on promotion type
        if [[ "$NEW_VERSION" =~ - ]]; then
            # Still a pre-release
            CHANGELOG_HEADER="## [$NEW_VERSION] - $(date +%Y-%m-%d) [PRE-RELEASE]"
        else
            # Stable release
            CHANGELOG_HEADER="## [$NEW_VERSION] - $(date +%Y-%m-%d)"
        fi

        # Insert changelog at the top (after title)
        TMP_FILE=$(mktemp)
        {
            head -n 1 CHANGELOG.md  # Keep title
            echo ""
            echo "$CHANGELOG_HEADER"
            echo ""
            echo "### Promoted from $CURRENT_VERSION"
            echo ""
            echo "$CHANGELOG_ENTRIES"
            echo ""
            tail -n +2 CHANGELOG.md  # Rest of file
        } > "$TMP_FILE"
        mv "$TMP_FILE" CHANGELOG.md
        print_success "Changelog updated with promotion details"
    fi
fi

# Create git tag if in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    TAG_NAME="v${NEW_VERSION}"

    # Check if tag already exists
    if git tag -l "$TAG_NAME" | grep -q "$TAG_NAME"; then
        print_error "Git tag $TAG_NAME already exists"
        exit 3
    fi

    # Create appropriate tag message
    if [[ "$NEW_VERSION" =~ - ]]; then
        # Still a pre-release
        PRERELEASE_TYPE_NEW=$(echo "$NEW_VERSION" | sed -n 's/.*-\([a-z]*\)\..*/\1/p')
        case "$PRERELEASE_TYPE_NEW" in
            beta)
                TAG_MESSAGE="Beta Release v${NEW_VERSION}

🧪 EARLY ACCESS (promoted from $CURRENT_VERSION)

This beta release has been promoted from alpha testing.
Features are complete but bugs may exist.

Promotion: $PROMOTION_PATH

Use with caution in production environments."
                ;;
            rc)
                TAG_MESSAGE="Release Candidate v${NEW_VERSION}

✅ PRODUCTION READY (promoted from $CURRENT_VERSION)

This release candidate has been promoted from beta testing.
Ready for production unless critical issues are discovered.

Promotion: $PROMOTION_PATH

Expected stable release: $(date -d '+7 days' +%Y-%m-%d)"
                ;;
        esac
    else
        # Stable release
        TAG_MESSAGE="Stable Release v${NEW_VERSION}

🎉 PRODUCTION RELEASE (promoted from $CURRENT_VERSION)

This stable release has been promoted from release candidate.
Production ready and fully tested.

Promotion: $PROMOTION_PATH"
    fi

    print_info "Creating git tag $TAG_NAME..."
    git tag -a "$TAG_NAME" -m "$TAG_MESSAGE"
    print_success "Git tag $TAG_NAME created"

    print_info "To push the tag to remote, run:"
    echo "  git push origin $TAG_NAME"
fi

# Output the new version
echo "$NEW_VERSION"

print_success "Promotion to $NEW_VERSION completed successfully"
print_info "Next steps:"
echo "  1. Commit version changes: git add . && git commit -m 'chore: promote to $NEW_VERSION'"
echo "  2. Push changes: git push origin HEAD"
echo "  3. Push tag: git push origin v$NEW_VERSION"

if [[ "$NEW_VERSION" =~ - ]]; then
    echo "  4. Create GitHub pre-release: gh release create v$NEW_VERSION --prerelease"
else
    echo "  4. Create GitHub release: gh release create v$NEW_VERSION"
fi

exit 0

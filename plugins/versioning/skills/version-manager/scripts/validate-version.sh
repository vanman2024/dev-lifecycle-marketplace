#!/bin/bash
# Validate version consistency across project files

set -e

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

# Check if VERSION file exists
if [ ! -f "VERSION" ]; then
    echo "Error: VERSION file not found" >&2
    exit 2
fi

# Read version from VERSION file
VERSION_FILE_VERSION=$(cat VERSION | jq -r '.version' 2>/dev/null)
if [ -z "$VERSION_FILE_VERSION" ] || [ "$VERSION_FILE_VERSION" = "null" ]; then
    echo "Error: Could not parse version from VERSION file" >&2
    exit 2
fi

echo "VERSION file: $VERSION_FILE_VERSION" >&2

# Check pyproject.toml (Python projects)
if [ -f "pyproject.toml" ]; then
    PYPROJECT_VERSION=$(grep -E '^version[[:space:]]*=' pyproject.toml | sed -E 's/.*"([^"]+)".*/\1/' || echo "")
    if [ -n "$PYPROJECT_VERSION" ]; then
        echo "pyproject.toml: $PYPROJECT_VERSION" >&2
        if [ "$VERSION_FILE_VERSION" != "$PYPROJECT_VERSION" ]; then
            echo "Error: Version mismatch - VERSION file ($VERSION_FILE_VERSION) != pyproject.toml ($PYPROJECT_VERSION)" >&2
            exit 1
        fi
    fi
fi

# Check package.json (TypeScript/JavaScript projects)
if [ -f "package.json" ]; then
    PACKAGE_VERSION=$(cat package.json | jq -r '.version' 2>/dev/null)
    if [ -n "$PACKAGE_VERSION" ] && [ "$PACKAGE_VERSION" != "null" ]; then
        echo "package.json: $PACKAGE_VERSION" >&2
        if [ "$VERSION_FILE_VERSION" != "$PACKAGE_VERSION" ]; then
            echo "Error: Version mismatch - VERSION file ($VERSION_FILE_VERSION) != package.json ($PACKAGE_VERSION)" >&2
            exit 1
        fi
    fi
fi

# Check git tag (if available)
GIT_TAG=$(git describe --tags --abbrev=0 --match "v*" 2>/dev/null || echo "")
if [ -n "$GIT_TAG" ]; then
    GIT_VERSION="${GIT_TAG#v}"  # Remove 'v' prefix
    echo "Latest git tag: $GIT_TAG ($GIT_VERSION)" >&2
    # Don't fail if git tag is behind VERSION file (normal for bumping)
    # Just report it
    if [ "$VERSION_FILE_VERSION" != "$GIT_VERSION" ]; then
        echo "Note: VERSION file ($VERSION_FILE_VERSION) != latest git tag ($GIT_VERSION)" >&2
    fi
fi

echo "✅ Version validation passed" >&2
exit 0

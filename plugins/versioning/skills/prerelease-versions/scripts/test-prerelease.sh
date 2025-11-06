#!/bin/bash

# test-prerelease.sh
# Validate pre-release version format and readiness
# Usage: bash test-prerelease.sh <version>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Exit codes
EXIT_SUCCESS=0
EXIT_FORMAT_ERROR=1
EXIT_CONSISTENCY_ERROR=2
EXIT_TAG_CONFLICT=3
EXIT_CHANGELOG_MISSING=4

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

# Function to print colored output
print_error() {
    echo -e "${RED}✗ FAIL: $1${NC}"
    ((CHECKS_FAILED++))
}

print_success() {
    echo -e "${GREEN}✓ PASS: $1${NC}"
    ((CHECKS_PASSED++))
}

print_info() {
    echo -e "${YELLOW}ℹ INFO: $1${NC}"
}

print_test_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Validate arguments
if [ $# -ne 1 ]; then
    print_error "Invalid number of arguments"
    echo "Usage: $0 <version>"
    echo "  version: Pre-release version to validate (e.g., 1.0.0-alpha.1)"
    exit $EXIT_FORMAT_ERROR
fi

VERSION="$1"

echo ""
print_test_header "Pre-release Version Validation: $VERSION"
echo ""

# Test 1: Semantic Versioning Format
print_test_header "Test 1: Semantic Versioning Format"

if [[ "$VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)-([a-z]+)\.([0-9]+)$ ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    PATCH="${BASH_REMATCH[3]}"
    PRERELEASE_TYPE="${BASH_REMATCH[4]}"
    PRERELEASE_NUM="${BASH_REMATCH[5]}"

    print_success "Version format is valid"
    print_info "  Major: $MAJOR"
    print_info "  Minor: $MINOR"
    print_info "  Patch: $PATCH"
    print_info "  Type: $PRERELEASE_TYPE"
    print_info "  Number: $PRERELEASE_NUM"
else
    print_error "Invalid semantic version format"
    echo "Expected format: MAJOR.MINOR.PATCH-TYPE.NUMBER"
    echo "Example: 1.0.0-alpha.1"
    exit $EXIT_FORMAT_ERROR
fi

# Test 2: Pre-release Type Validation
print_test_header "Test 2: Pre-release Type Validation"

if [[ "$PRERELEASE_TYPE" =~ ^(alpha|beta|rc)$ ]]; then
    print_success "Pre-release type is valid: $PRERELEASE_TYPE"

    case "$PRERELEASE_TYPE" in
        alpha)
            print_info "  Stage: Internal testing, unstable"
            print_info "  Next: Promote to beta or create new alpha"
            ;;
        beta)
            print_info "  Stage: External testing, feature complete"
            print_info "  Next: Promote to RC or create new beta"
            ;;
        rc)
            print_info "  Stage: Release candidate, production ready"
            print_info "  Next: Promote to stable or create new RC"
            ;;
    esac
else
    print_error "Invalid pre-release type: $PRERELEASE_TYPE"
    echo "Valid types: alpha, beta, rc"
    exit $EXIT_FORMAT_ERROR
fi

# Test 3: Pre-release Number Validation
print_test_header "Test 3: Pre-release Number Validation"

if [ "$PRERELEASE_NUM" -ge 1 ]; then
    print_success "Pre-release number is valid: $PRERELEASE_NUM"
else
    print_error "Pre-release number must be >= 1, found: $PRERELEASE_NUM"
    exit $EXIT_FORMAT_ERROR
fi

# Test 4: Version File Consistency
print_test_header "Test 4: Version File Consistency"

VERSION_FILE_FOUND=false

# Check VERSION file
if [ -f "VERSION" ]; then
    VERSION_FILE_FOUND=true
    if grep -q "{" VERSION 2>/dev/null; then
        # JSON format
        VERSION_FILE_VERSION=$(jq -r '.version' VERSION 2>/dev/null || echo "")
    else
        # Plain text format
        VERSION_FILE_VERSION=$(cat VERSION | tr -d '\n' 2>/dev/null || echo "")
    fi

    if [ "$VERSION_FILE_VERSION" = "$VERSION" ]; then
        print_success "VERSION file matches: $VERSION"
    else
        print_error "VERSION file mismatch: expected $VERSION, found $VERSION_FILE_VERSION"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
else
    print_info "VERSION file not found (optional)"
fi

# Check package.json
if [ -f "package.json" ]; then
    VERSION_FILE_FOUND=true
    PACKAGE_VERSION=$(jq -r '.version' package.json 2>/dev/null || echo "")

    if [ "$PACKAGE_VERSION" = "$VERSION" ]; then
        print_success "package.json matches: $VERSION"
    else
        print_error "package.json mismatch: expected $VERSION, found $PACKAGE_VERSION"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
else
    print_info "package.json not found (optional)"
fi

# Check pyproject.toml
if [ -f "pyproject.toml" ]; then
    VERSION_FILE_FOUND=true
    PYPROJECT_VERSION=$(grep "^version = " pyproject.toml | sed 's/version = "\(.*\)"/\1/' 2>/dev/null || echo "")

    if [ "$PYPROJECT_VERSION" = "$VERSION" ]; then
        print_success "pyproject.toml matches: $VERSION"
    else
        print_error "pyproject.toml mismatch: expected $VERSION, found $PYPROJECT_VERSION"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
else
    print_info "pyproject.toml not found (optional)"
fi

if [ "$VERSION_FILE_FOUND" = false ]; then
    print_error "No version files found (VERSION, package.json, or pyproject.toml)"
    exit $EXIT_CONSISTENCY_ERROR
fi

# Test 5: Git Tag Validation
print_test_header "Test 5: Git Tag Validation"

if git rev-parse --git-dir > /dev/null 2>&1; then
    TAG_NAME="v${VERSION}"

    # Check if tag exists
    if git tag -l "$TAG_NAME" | grep -q "$TAG_NAME"; then
        print_success "Git tag exists: $TAG_NAME"

        # Check tag annotation
        TAG_MESSAGE=$(git tag -l --format='%(contents)' "$TAG_NAME" 2>/dev/null || echo "")
        if [ -n "$TAG_MESSAGE" ]; then
            print_success "Tag is annotated"
            print_info "  First line: $(echo "$TAG_MESSAGE" | head -n 1)"
        else
            print_error "Tag exists but is not annotated (lightweight tag)"
        fi
    else
        print_info "Git tag does not exist yet: $TAG_NAME"
        print_info "  Create with: git tag -a $TAG_NAME -m 'Release message'"
    fi

    # Check for conflicting tags
    BASE_VERSION="${MAJOR}.${MINOR}.${PATCH}"
    CONFLICTING_TAGS=$(git tag -l "v${BASE_VERSION}-*" | grep -v "$TAG_NAME" || true)

    if [ -n "$CONFLICTING_TAGS" ]; then
        print_info "Other pre-release tags found for $BASE_VERSION:"
        echo "$CONFLICTING_TAGS" | while read -r tag; do
            print_info "    $tag"
        done
    fi
else
    print_info "Not a git repository - skipping git tag validation"
fi

# Test 6: Changelog Entry Validation
print_test_header "Test 6: Changelog Entry Validation"

if [ -f "CHANGELOG.md" ]; then
    if grep -q "$VERSION" CHANGELOG.md; then
        print_success "CHANGELOG.md contains entry for $VERSION"

        # Extract the changelog section
        CHANGELOG_SECTION=$(sed -n "/## \[$VERSION\]/,/## \[/p" CHANGELOG.md | head -n -1)
        if [ -n "$CHANGELOG_SECTION" ]; then
            LINE_COUNT=$(echo "$CHANGELOG_SECTION" | wc -l)
            print_info "  Changelog section: $LINE_COUNT lines"
        fi
    else
        print_error "CHANGELOG.md missing entry for $VERSION"
        print_info "  Add changelog section before release"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
else
    print_info "CHANGELOG.md not found (recommended)"
fi

# Test 7: Pre-release Readiness Checks
print_test_header "Test 7: Pre-release Readiness Checks"

# Check for README
if [ -f "README.md" ]; then
    print_success "README.md exists"
else
    print_error "README.md not found"
fi

# Check for LICENSE
if [ -f "LICENSE" ] || [ -f "LICENSE.md" ] || [ -f "LICENSE.txt" ]; then
    print_success "LICENSE file exists"
else
    print_info "LICENSE file not found (recommended)"
fi

# Check for tests directory
if [ -d "tests" ] || [ -d "test" ] || [ -d "__tests__" ]; then
    print_success "Tests directory exists"
else
    print_info "Tests directory not found (recommended)"
fi

# Check for CI/CD configuration
if [ -d ".github/workflows" ] || [ -f ".gitlab-ci.yml" ] || [ -f ".circleci/config.yml" ]; then
    print_success "CI/CD configuration exists"
else
    print_info "CI/CD configuration not found (recommended)"
fi

# Test 8: Pre-release Stage Recommendations
print_test_header "Test 8: Pre-release Stage Recommendations"

case "$PRERELEASE_TYPE" in
    alpha)
        echo "Alpha Release Checklist:"
        echo "  ☐ Internal testing completed"
        echo "  ☐ Core functionality implemented"
        echo "  ☐ Known issues documented"
        echo "  ☐ Breaking changes acceptable"
        echo "  ☐ Ready for rapid iteration"
        ;;
    beta)
        echo "Beta Release Checklist:"
        echo "  ☐ Feature freeze in place"
        echo "  ☐ External testing ready"
        echo "  ☐ Documentation reviewed"
        echo "  ☐ Known bugs tracked"
        echo "  ☐ Performance tested"
        ;;
    rc)
        echo "Release Candidate Checklist:"
        echo "  ☐ All tests passing"
        echo "  ☐ No known critical bugs"
        echo "  ☐ Documentation complete"
        echo "  ☐ Production environment tested"
        echo "  ☐ Stakeholder approval obtained"
        ;;
esac

# Summary
echo ""
print_test_header "Validation Summary"
echo ""
echo "Total Checks Passed: $CHECKS_PASSED"
echo "Total Checks Failed: $CHECKS_FAILED"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    print_success "All validation checks passed!"
    echo ""
    print_info "Version $VERSION is ready for release"
    exit $EXIT_SUCCESS
else
    print_error "Some validation checks failed"
    echo ""
    print_info "Fix the issues above before releasing $VERSION"

    # Determine appropriate exit code based on failures
    if [ $CHECKS_FAILED -gt 2 ]; then
        exit $EXIT_CONSISTENCY_ERROR
    else
        exit $EXIT_FORMAT_ERROR
    fi
fi

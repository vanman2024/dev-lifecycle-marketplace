#!/usr/bin/env bash
#
# validate-build.sh - Run pre-deployment build validation checks
#
# Usage: bash validate-build.sh [project-dir]
#

set -euo pipefail

PROJECT_DIR="${1:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

# Change to project directory
cd "$PROJECT_DIR"

print_info "Running build validation for: $(pwd)"
echo ""

ERRORS=0
WARNINGS=0

# Function to run a validation check
run_check() {
    local check_name="$1"
    shift
    local check_command=("$@")

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Running: $check_name"
    echo ""

    if "${check_command[@]}"; then
        print_success "$check_name passed"
        return 0
    else
        print_error "$check_name failed"
        ((ERRORS++))
        return 1
    fi
}

# Check 1: Detect project type
print_info "Detecting project type..."
PROJECT_TYPE="unknown"

if [[ -f "package.json" ]]; then
    PROJECT_TYPE="node"
    print_success "Node.js project detected"
elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
    PROJECT_TYPE="python"
    print_success "Python project detected"
elif [[ -f "Gemfile" ]]; then
    PROJECT_TYPE="ruby"
    print_success "Ruby project detected"
elif [[ -f "go.mod" ]]; then
    PROJECT_TYPE="go"
    print_success "Go project detected"
else
    print_warning "Unknown project type"
    ((WARNINGS++))
fi

echo ""

# Check 2: Dependencies installed
if [[ "$PROJECT_TYPE" == "node" ]]; then
    if [[ -d "node_modules" ]]; then
        print_success "node_modules directory exists"
    else
        print_warning "node_modules not found - run npm install"
        ((WARNINGS++))
    fi

    # Check for package-lock or yarn.lock
    if [[ -f "package-lock.json" ]] || [[ -f "yarn.lock" ]] || [[ -f "pnpm-lock.yaml" ]]; then
        print_success "Lock file found"
    else
        print_warning "No lock file found - dependencies may be inconsistent"
        ((WARNINGS++))
    fi
fi

# Check 3: Environment files
if [[ -f ".env.example" ]] && [[ ! -f ".env" ]]; then
    print_warning ".env.example exists but .env not found"
    ((WARNINGS++))
else
    print_success "Environment configuration OK"
fi

# Check 4: Git status (ensure clean or staged)
if git rev-parse --git-dir > /dev/null 2>&1; then
    print_info "Checking git status..."

    if [[ -n $(git status --porcelain) ]]; then
        print_warning "Working directory has uncommitted changes"
        ((WARNINGS++))
    else
        print_success "Working directory clean"
    fi

    # Check current branch
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    print_info "Current branch: $BRANCH"

    if [[ "$BRANCH" == "main" ]] || [[ "$BRANCH" == "master" ]]; then
        print_success "On primary branch"
    else
        print_info "On branch: $BRANCH"
    fi
fi

echo ""

# Check 5: Run linting if available
if [[ "$PROJECT_TYPE" == "node" ]]; then
    if command -v npm &> /dev/null; then
        # Check if lint script exists
        if grep -q '"lint"' package.json 2>/dev/null; then
            run_check "Linting" npm run lint
        else
            print_info "No lint script found in package.json"
        fi

        # Check if type check script exists
        if grep -q '"type-check"' package.json 2>/dev/null; then
            run_check "Type checking" npm run type-check
        elif grep -q '"tsc"' package.json 2>/dev/null; then
            run_check "Type checking" npm run tsc
        fi
    fi
fi

# Check 6: Run tests if available
if [[ "$PROJECT_TYPE" == "node" ]]; then
    if grep -q '"test"' package.json 2>/dev/null; then
        # Check if test command is not placeholder
        TEST_CMD=$(grep '"test"' package.json | grep -v 'echo "Error: no test specified"' || true)
        if [[ -n "$TEST_CMD" ]]; then
            print_info "Test script found"
            # Don't run tests by default in validation (can be slow)
            # Uncomment to enable: run_check "Tests" npm test
            print_info "Skipping tests (run manually: npm test)"
        else
            print_warning "No test script configured"
            ((WARNINGS++))
        fi
    fi
fi

# Check 7: Build directory checks
if [[ "$PROJECT_TYPE" == "node" ]]; then
    # Check for common build directories
    BUILD_DIRS=("dist" "build" ".next" "out" ".output")
    BUILD_FOUND=false

    for dir in "${BUILD_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            print_success "Build directory found: $dir"
            BUILD_FOUND=true
            break
        fi
    done

    if ! $BUILD_FOUND; then
        print_info "No build directory found (will be created during deployment)"
    fi
fi

# Check 8: Check for security vulnerabilities
if [[ "$PROJECT_TYPE" == "node" ]] && command -v npm &> /dev/null; then
    print_info "Checking for security vulnerabilities..."

    if npm audit --audit-level=high &> /dev/null; then
        print_success "No high/critical vulnerabilities found"
    else
        print_warning "Security vulnerabilities detected - run 'npm audit' for details"
        ((WARNINGS++))
    fi
fi

# Check 9: File size check (detect large files that shouldn't be committed)
print_info "Checking for large files..."
LARGE_FILES=$(find . -type f -size +10M ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" ! -path "*/build/*" 2>/dev/null || true)

if [[ -n "$LARGE_FILES" ]]; then
    print_warning "Large files detected (>10MB):"
    echo "$LARGE_FILES" | while read -r file; do
        SIZE=$(du -h "$file" | cut -f1)
        echo "  - $file ($SIZE)"
    done
    ((WARNINGS++))
else
    print_success "No large files detected"
fi

# Check 10: Configuration file validation
print_info "Validating configuration files..."

# Check Dockerfile if exists
if [[ -f "Dockerfile" ]]; then
    if grep -q "FROM" Dockerfile; then
        print_success "Dockerfile appears valid"
    else
        print_error "Dockerfile may be invalid"
        ((ERRORS++))
    fi
fi

# Check docker-compose if exists
if [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
    if command -v docker-compose &> /dev/null; then
        if docker-compose config &> /dev/null; then
            print_success "docker-compose configuration valid"
        else
            print_error "docker-compose configuration invalid"
            ((ERRORS++))
        fi
    fi
fi

# Check vercel.json if exists
if [[ -f "vercel.json" ]]; then
    if python3 -m json.tool vercel.json &> /dev/null; then
        print_success "vercel.json is valid JSON"
    else
        print_error "vercel.json has invalid JSON"
        ((ERRORS++))
    fi
fi

# Check netlify.toml if exists
if [[ -f "netlify.toml" ]]; then
    print_success "netlify.toml found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Summary
if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    print_success "Build validation passed with no errors or warnings"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    print_warning "Build validation passed with $WARNINGS warning(s)"
    print_info "Review warnings before deploying"
    exit 0
else
    print_error "Build validation failed with $ERRORS error(s) and $WARNINGS warning(s)"
    print_error "Fix errors before deploying"
    exit 1
fi

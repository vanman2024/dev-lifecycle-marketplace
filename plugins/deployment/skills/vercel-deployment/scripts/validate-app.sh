#!/bin/bash
#
# Validate application for Vercel deployment
#
# Usage: ./validate-app.sh <app-path>
#
# Environment Variables:
#   STATIC_SITE - Set to "true" for static site validation
#   VERBOSE - Set to "1" for detailed output
#
# Exit Codes:
#   0 - Validation passed
#   1 - Validation failed

set -e

APP_PATH="${1:-.}"
VERBOSE="${VERBOSE:-0}"
STATIC_SITE="${STATIC_SITE:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validation results
ERRORS=0
WARNINGS=0

log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

log_verbose() {
    if [[ "$VERBOSE" == "1" ]]; then
        echo "  → $1"
    fi
}

echo "Validating application for Vercel deployment..."
echo "App Path: $APP_PATH"
echo ""

# Check if path exists
if [[ ! -d "$APP_PATH" ]]; then
    log_error "Application path does not exist: $APP_PATH"
    exit 1
fi

cd "$APP_PATH"

# Detect framework
log_verbose "Detecting framework..."
FRAMEWORK="unknown"

if [[ -f "next.config.js" ]] || [[ -f "next.config.mjs" ]] || [[ -f "next.config.ts" ]]; then
    FRAMEWORK="nextjs"
    log_info "Next.js application detected"
elif [[ -f "package.json" ]]; then
    if grep -q '"react"' package.json; then
        FRAMEWORK="react"
        log_info "React application detected"
    elif grep -q '"vue"' package.json; then
        FRAMEWORK="vue"
        log_info "Vue application detected"
    elif grep -q '"vite"' package.json; then
        FRAMEWORK="vite"
        log_info "Vite application detected"
    else
        FRAMEWORK="nodejs"
        log_info "Node.js application detected"
    fi
elif [[ "$STATIC_SITE" == "true" ]]; then
    FRAMEWORK="static"
    log_info "Static site deployment"
else
    log_error "Could not detect framework (no package.json or Next.js config)"
fi

# Check for package.json (required for Node.js apps)
if [[ "$FRAMEWORK" != "static" ]] && [[ ! -f "package.json" ]]; then
    log_error "package.json not found (required for Node.js/React/Vue apps)"
fi

# Check for build script
if [[ -f "package.json" ]] && [[ "$FRAMEWORK" != "static" ]]; then
    log_verbose "Checking build configuration..."

    if grep -q '"build"' package.json; then
        log_info "Build script found in package.json"
    else
        log_warn "No build script found in package.json (may be required)"
    fi

    # Check for start script (Next.js standalone mode)
    if [[ "$FRAMEWORK" == "nextjs" ]]; then
        if grep -q '"start"' package.json; then
            log_verbose "Start script found (Next.js standalone mode supported)"
        fi
    fi
fi

# Check for environment configuration
log_verbose "Checking environment configuration..."
if [[ -f ".env.example" ]] || [[ -f ".env.local.example" ]]; then
    log_info "Environment example file found"

    # Count environment variables
    if [[ -f ".env.example" ]]; then
        ENV_COUNT=$(grep -c "^[A-Z]" .env.example || echo "0")
        log_verbose "Found $ENV_COUNT environment variables in .env.example"
    fi
elif [[ -f ".env" ]] || [[ -f ".env.local" ]]; then
    log_warn ".env file found but no .env.example (should document required env vars)"
else
    log_warn "No environment configuration files found (.env.example recommended)"
fi

# Check for hardcoded secrets
log_verbose "Scanning for hardcoded secrets..."
SECRET_PATTERNS=(
    "api[_-]?key\s*=\s*['\"][a-zA-Z0-9]"
    "secret\s*=\s*['\"][a-zA-Z0-9]"
    "password\s*=\s*['\"][^{]"
    "token\s*=\s*['\"][a-zA-Z0-9]"
)

FOUND_SECRETS=false
for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -riE "$pattern" . --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist --exclude-dir=build --exclude=".env*" 2>/dev/null | grep -v ".env.example" | grep -q .; then
        FOUND_SECRETS=true
        break
    fi
done

if [[ "$FOUND_SECRETS" == "true" ]]; then
    log_error "Potential hardcoded secrets found in code (use environment variables)"
else
    log_info "No hardcoded secrets detected in code"
fi

# Check for .gitignore
log_verbose "Checking .gitignore..."
if [[ -f ".gitignore" ]]; then
    log_info ".gitignore found"

    if grep -q "\.env" .gitignore; then
        log_info ".env files are gitignored"
    else
        log_warn ".env files should be in .gitignore"
    fi

    if grep -q "node_modules" .gitignore; then
        log_verbose "node_modules is gitignored"
    else
        log_warn "node_modules should be in .gitignore"
    fi
else
    log_warn "No .gitignore found (recommended)"
fi

# Check Node.js version compatibility
if [[ -f "package.json" ]]; then
    log_verbose "Checking Node.js version requirements..."

    if grep -q '"engines"' package.json; then
        NODE_VERSION=$(grep -A 2 '"engines"' package.json | grep '"node"' | sed 's/.*"node".*"\(.*\)".*/\1/' || echo "")
        if [[ -n "$NODE_VERSION" ]]; then
            log_info "Node.js version specified: $NODE_VERSION"
        fi
    else
        log_warn "No Node.js version specified in package.json engines field"
    fi
fi

# Check for vercel.json
log_verbose "Checking for Vercel configuration..."
if [[ -f "vercel.json" ]]; then
    log_info "vercel.json configuration found"

    # Validate JSON syntax
    if ! python3 -m json.tool vercel.json >/dev/null 2>&1; then
        log_error "vercel.json has invalid JSON syntax"
    else
        log_verbose "vercel.json syntax is valid"
    fi
else
    log_verbose "No vercel.json found (optional, Vercel will auto-detect settings)"
fi

# Framework-specific checks
case "$FRAMEWORK" in
    nextjs)
        log_verbose "Running Next.js specific checks..."

        # Check for pages or app directory
        if [[ -d "pages" ]] || [[ -d "app" ]]; then
            log_info "Next.js pages/app directory found"
        else
            log_warn "No pages or app directory found (unusual for Next.js)"
        fi

        # Check for public directory
        if [[ -d "public" ]]; then
            log_verbose "Public assets directory found"
        fi
        ;;

    react)
        log_verbose "Running React specific checks..."

        # Check for src directory
        if [[ -d "src" ]]; then
            log_info "React src directory found"
        else
            log_warn "No src directory found (check project structure)"
        fi
        ;;

    static)
        log_verbose "Running static site checks..."

        # Check for index.html
        if [[ -f "index.html" ]] || [[ -f "public/index.html" ]]; then
            log_info "index.html found"
        else
            log_error "No index.html found (required for static sites)"
        fi
        ;;
esac

# Summary
echo ""
echo "Validation Summary:"
echo "  Application Type: $FRAMEWORK"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}Validation FAILED${NC} - Please fix errors before deploying"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}Validation PASSED with warnings${NC} - Review warnings before deploying"
    exit 0
else
    echo -e "${GREEN}Validation PASSED${NC} - Ready for Vercel deployment"
    exit 0
fi

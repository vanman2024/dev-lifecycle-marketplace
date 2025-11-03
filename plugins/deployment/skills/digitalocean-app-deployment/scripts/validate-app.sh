#!/bin/bash
#
# Validate application for DigitalOcean App Platform deployment
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

echo "Validating application for DigitalOcean App Platform..."
echo "App Path: $APP_PATH"
echo ""

# Check if path exists
if [[ ! -d "$APP_PATH" ]]; then
    log_error "Application path does not exist: $APP_PATH"
    exit 1
fi

cd "$APP_PATH"

# Check for Dockerfile or runtime detection
log_verbose "Checking for Dockerfile or supported runtime..."
if [[ -f "Dockerfile" ]]; then
    log_info "Dockerfile found"
    APP_TYPE="docker"

    # Validate Dockerfile
    log_verbose "Validating Dockerfile..."

    # Check for EXPOSE directive
    if grep -q "^EXPOSE" Dockerfile; then
        PORT=$(grep "^EXPOSE" Dockerfile | awk '{print $2}' | head -1)
        if [[ "$PORT" != "8080" ]]; then
            log_warn "Dockerfile exposes port $PORT, but App Platform expects 8080"
        else
            log_info "Dockerfile exposes correct port (8080)"
        fi
    else
        log_warn "No EXPOSE directive in Dockerfile (App Platform expects port 8080)"
    fi

    # Check for hardcoded secrets
    if grep -iE "(api[_-]?key|secret|password|token)" Dockerfile | grep -v "ENV" | grep -q "="; then
        log_error "Potential hardcoded secrets found in Dockerfile"
    else
        log_info "No hardcoded secrets detected in Dockerfile"
    fi

elif [[ -f "package.json" ]]; then
    log_info "Node.js application detected (package.json found)"
    APP_TYPE="nodejs"

    # Check for build script
    if grep -q '"build"' package.json; then
        log_info "Build script found in package.json"
    else
        log_warn "No build script found in package.json (may be required)"
    fi

    # Check for start script
    if grep -q '"start"' package.json; then
        log_info "Start script found in package.json"
    else
        log_error "No start script found in package.json (required for App Platform)"
    fi

elif [[ -f "requirements.txt" ]] || [[ -f "Pipfile" ]] || [[ -f "pyproject.toml" ]]; then
    log_info "Python application detected"
    APP_TYPE="python"

    # Check for entry point
    if [[ -f "app.py" ]] || [[ -f "main.py" ]] || [[ -f "server.py" ]]; then
        log_info "Python entry point found"
    else
        log_error "No Python entry point found (app.py, main.py, or server.py)"
    fi

elif [[ "$STATIC_SITE" == "true" ]]; then
    log_info "Static site deployment"
    APP_TYPE="static"

    # Check for package.json (static sites often use npm for builds)
    if [[ -f "package.json" ]]; then
        log_info "package.json found (for build process)"

        if grep -q '"build"' package.json; then
            log_info "Build script found in package.json"
        else
            log_warn "No build script found (may be required for static site)"
        fi
    fi

else
    log_error "Could not detect application type (no Dockerfile, package.json, requirements.txt, or static site marker)"
fi

# Check for environment configuration
log_verbose "Checking environment configuration..."
if [[ -f ".env.example" ]]; then
    log_info "Environment example file found (.env.example)"

    # Count environment variables
    ENV_COUNT=$(grep -c "^[A-Z]" .env.example || echo "0")
    log_verbose "Found $ENV_COUNT environment variables in .env.example"

elif [[ -f ".env" ]]; then
    log_warn ".env file found but no .env.example (should document required env vars)"
else
    log_warn "No environment configuration files found (.env.example recommended)"
fi

# Check for hardcoded secrets in code
log_verbose "Scanning for hardcoded secrets..."
SECRET_PATTERNS=(
    "api[_-]?key\s*=\s*['\"][a-zA-Z0-9]"
    "secret\s*=\s*['\"][a-zA-Z0-9]"
    "password\s*=\s*['\"][^{]"
    "token\s*=\s*['\"][a-zA-Z0-9]"
)

FOUND_SECRETS=false
for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -riE "$pattern" . --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv --exclude-dir=dist --exclude=".env*" 2>/dev/null | grep -v ".env.example" | grep -q .; then
        FOUND_SECRETS=true
        break
    fi
done

if [[ "$FOUND_SECRETS" == "true" ]]; then
    log_error "Potential hardcoded secrets found in code (use environment variables)"
else
    log_info "No hardcoded secrets detected in code"
fi

# Check for port configuration
log_verbose "Checking port configuration..."
if [[ -f ".env.example" ]]; then
    if grep -q "^PORT=" .env.example; then
        PORT_VALUE=$(grep "^PORT=" .env.example | cut -d= -f2)
        if [[ "$PORT_VALUE" == "8080" ]] || [[ "$PORT_VALUE" == "\${PORT}" ]] || [[ "$PORT_VALUE" == "your_port_here" ]]; then
            log_info "Port configuration looks good (8080 or variable)"
        else
            log_warn "Port in .env.example is $PORT_VALUE (App Platform uses 8080)"
        fi
    else
        log_warn "No PORT variable in .env.example (App Platform expects 8080)"
    fi
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
else
    log_warn "No .gitignore found (recommended)"
fi

# Check for health check endpoint (recommended)
if [[ "$APP_TYPE" != "static" ]] && [[ "$STATIC_SITE" != "true" ]]; then
    log_verbose "Checking for health check endpoint..."
    if grep -riE "(\/health|\/healthz|\/ping)" . --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=venv --exclude-dir=dist 2>/dev/null | grep -q .; then
        log_info "Health check endpoint appears to be implemented"
    else
        log_warn "No health check endpoint detected (recommended: /health or /healthz)"
    fi
fi

# Summary
echo ""
echo "Validation Summary:"
echo "  Application Type: $APP_TYPE"
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
    echo -e "${GREEN}Validation PASSED${NC} - Ready for deployment"
    exit 0
fi

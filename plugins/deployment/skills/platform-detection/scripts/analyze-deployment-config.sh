#!/usr/bin/env bash
# analyze-deployment-config.sh - Analyze existing deployment configuration
# Usage: bash analyze-deployment-config.sh <project-path>

set -euo pipefail

PROJECT_PATH="${1:-.}"

# Validate project path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path does not exist: $PROJECT_PATH" >&2
    exit 1
fi

# Change to project directory
cd "$PROJECT_PATH"

echo "=== Deployment Configuration Analysis ===" >&2
echo "" >&2

# Track findings
HAS_DOCKER=false
HAS_CI_CD=false
HAS_PLATFORM_CONFIG=false
HAS_ENV_CONFIG=false
HAS_BUILD_SCRIPTS=false

# Docker Analysis
echo "--- Docker Configuration ---" >&2
if [ -f "Dockerfile" ]; then
    echo "✓ Found Dockerfile" >&2
    HAS_DOCKER=true

    # Analyze Dockerfile
    if grep -q "FROM.*node" Dockerfile 2>/dev/null; then
        echo "  - Base Image: Node.js" >&2
    elif grep -q "FROM.*python" Dockerfile 2>/dev/null; then
        echo "  - Base Image: Python" >&2
    fi

    if grep -q "EXPOSE" Dockerfile 2>/dev/null; then
        PORTS=$(grep "EXPOSE" Dockerfile | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')
        echo "  - Exposed Ports: $PORTS" >&2
    fi

    if grep -q "ENV" Dockerfile 2>/dev/null; then
        echo "  - Environment Variables: Configured" >&2
    fi
fi

if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    echo "✓ Found docker-compose configuration" >&2
    HAS_DOCKER=true

    # Count services
    SERVICE_COUNT=$(grep -c "^  [a-z].*:" docker-compose.yml 2>/dev/null || echo "0")
    echo "  - Services Defined: $SERVICE_COUNT" >&2
fi

if [ -f ".dockerignore" ]; then
    echo "✓ Found .dockerignore" >&2
fi

if [ "$HAS_DOCKER" = false ]; then
    echo "⚠ No Docker configuration found" >&2
fi
echo "" >&2

# CI/CD Analysis
echo "--- CI/CD Configuration ---" >&2

# GitHub Actions
if [ -f ".github/workflows/deploy.yml" ] || [ -f ".github/workflows/main.yml" ]; then
    echo "✓ Found GitHub Actions workflow" >&2
    HAS_CI_CD=true

    # Count jobs
    if [ -f ".github/workflows/deploy.yml" ]; then
        WORKFLOW_FILE=".github/workflows/deploy.yml"
    else
        WORKFLOW_FILE=".github/workflows/main.yml"
    fi

    if grep -q "build" "$WORKFLOW_FILE" 2>/dev/null; then
        echo "  - Has build job" >&2
    fi

    if grep -q "test" "$WORKFLOW_FILE" 2>/dev/null; then
        echo "  - Has test job" >&2
    fi

    if grep -q "deploy" "$WORKFLOW_FILE" 2>/dev/null; then
        echo "  - Has deploy job" >&2
    fi
fi

# GitLab CI
if [ -f ".gitlab-ci.yml" ]; then
    echo "✓ Found GitLab CI configuration" >&2
    HAS_CI_CD=true
fi

# CircleCI
if [ -f ".circleci/config.yml" ]; then
    echo "✓ Found CircleCI configuration" >&2
    HAS_CI_CD=true
fi

# Travis CI
if [ -f ".travis.yml" ]; then
    echo "✓ Found Travis CI configuration" >&2
    HAS_CI_CD=true
fi

if [ "$HAS_CI_CD" = false ]; then
    echo "⚠ No CI/CD configuration found" >&2
fi
echo "" >&2

# Platform-Specific Configuration
echo "--- Platform Configuration ---" >&2

if [ -f "vercel.json" ]; then
    echo "✓ Found Vercel configuration" >&2
    HAS_PLATFORM_CONFIG=true

    if grep -q "\"builds\"" vercel.json 2>/dev/null; then
        echo "  - Custom build configuration" >&2
    fi

    if grep -q "\"routes\"" vercel.json 2>/dev/null; then
        echo "  - Custom routing rules" >&2
    fi
fi

if [ -f "netlify.toml" ]; then
    echo "✓ Found Netlify configuration" >&2
    HAS_PLATFORM_CONFIG=true

    if grep -q "\[build\]" netlify.toml 2>/dev/null; then
        BUILD_CMD=$(grep "command" netlify.toml | head -1 | cut -d'"' -f2)
        echo "  - Build Command: $BUILD_CMD" >&2
    fi

    if grep -q "\[functions\]" netlify.toml 2>/dev/null; then
        echo "  - Serverless functions configured" >&2
    fi
fi

if [ -f "app.yaml" ]; then
    echo "✓ Found DigitalOcean App Platform configuration" >&2
    HAS_PLATFORM_CONFIG=true
fi

if [ -f "wrangler.toml" ]; then
    echo "✓ Found Cloudflare Workers configuration" >&2
    HAS_PLATFORM_CONFIG=true
fi

if [ -f ".mcp.json" ] || [ -f "mcp.json" ]; then
    echo "✓ Found MCP server configuration" >&2
    HAS_PLATFORM_CONFIG=true
fi

if [ "$HAS_PLATFORM_CONFIG" = false ]; then
    echo "⚠ No platform-specific configuration found" >&2
fi
echo "" >&2

# Environment Configuration
echo "--- Environment Configuration ---" >&2

if [ -f ".env.example" ] || [ -f ".env.template" ]; then
    echo "✓ Found environment variables template" >&2
    HAS_ENV_CONFIG=true

    ENV_FILE="${1:-.env.example}"
    [ -f ".env.template" ] && ENV_FILE=".env.template"

    VAR_COUNT=$(grep -c "^[A-Z_]*=" "$ENV_FILE" 2>/dev/null || echo "0")
    echo "  - Variables Defined: $VAR_COUNT" >&2
fi

if [ -f ".env" ]; then
    echo "✓ Found .env file (ensure it's in .gitignore)" >&2
    HAS_ENV_CONFIG=true

    if [ -f ".gitignore" ] && grep -q "^\.env$" .gitignore 2>/dev/null; then
        echo "  - .env is properly gitignored" >&2
    else
        echo "  - ⚠ WARNING: .env is not in .gitignore!" >&2
    fi
fi

if [ "$HAS_ENV_CONFIG" = false ]; then
    echo "⚠ No environment configuration found" >&2
fi
echo "" >&2

# Build Scripts Analysis
echo "--- Build Scripts ---" >&2

if [ -f "package.json" ]; then
    if grep -q "\"build\"" package.json 2>/dev/null; then
        echo "✓ Found npm build script" >&2
        HAS_BUILD_SCRIPTS=true

        BUILD_CMD=$(grep "\"build\"" package.json | head -1 | cut -d':' -f2 | tr -d '", ')
        echo "  - Build Command: $BUILD_CMD" >&2
    fi

    if grep -q "\"start\"" package.json 2>/dev/null; then
        echo "✓ Found npm start script" >&2
        HAS_BUILD_SCRIPTS=true
    fi

    if grep -q "\"deploy\"" package.json 2>/dev/null; then
        echo "✓ Found npm deploy script" >&2
    fi
fi

if [ -f "Makefile" ]; then
    echo "✓ Found Makefile" >&2
    HAS_BUILD_SCRIPTS=true

    if grep -q "^build:" Makefile 2>/dev/null; then
        echo "  - Has build target" >&2
    fi

    if grep -q "^deploy:" Makefile 2>/dev/null; then
        echo "  - Has deploy target" >&2
    fi
fi

if [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    echo "✓ Found Python package configuration" >&2
    HAS_BUILD_SCRIPTS=true
fi

if [ "$HAS_BUILD_SCRIPTS" = false ]; then
    echo "⚠ No build scripts found" >&2
fi
echo "" >&2

# Optimization Recommendations
echo "--- Recommendations ---" >&2

RECOMMENDATIONS=()

if [ "$HAS_DOCKER" = false ]; then
    RECOMMENDATIONS+=("Consider adding Dockerfile for containerized deployments")
fi

if [ "$HAS_CI_CD" = false ]; then
    RECOMMENDATIONS+=("Set up CI/CD pipeline (GitHub Actions, GitLab CI, etc.)")
fi

if [ "$HAS_PLATFORM_CONFIG" = false ]; then
    RECOMMENDATIONS+=("Add platform-specific configuration (vercel.json, netlify.toml, etc.)")
fi

if [ "$HAS_ENV_CONFIG" = false ]; then
    RECOMMENDATIONS+=("Create .env.example to document required environment variables")
fi

if [ ! -f ".gitignore" ]; then
    RECOMMENDATIONS+=("Add .gitignore to exclude sensitive files and build artifacts")
fi

if [ ! -f "README.md" ]; then
    RECOMMENDATIONS+=("Add README.md with deployment instructions")
fi

if [ ${#RECOMMENDATIONS[@]} -eq 0 ]; then
    echo "✓ No critical issues found" >&2
else
    for i in "${!RECOMMENDATIONS[@]}"; do
        echo "$((i + 1)). ${RECOMMENDATIONS[$i]}" >&2
    done
fi

echo "" >&2
echo "=== Analysis Complete ===" >&2

# Output summary as JSON for programmatic use
cat <<EOF
{
  "has_docker": $HAS_DOCKER,
  "has_ci_cd": $HAS_CI_CD,
  "has_platform_config": $HAS_PLATFORM_CONFIG,
  "has_env_config": $HAS_ENV_CONFIG,
  "has_build_scripts": $HAS_BUILD_SCRIPTS,
  "recommendation_count": ${#RECOMMENDATIONS[@]}
}
EOF

exit 0

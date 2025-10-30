#!/usr/bin/env bash
# validate-platform-requirements.sh - Validate project meets platform requirements
# Usage: bash validate-platform-requirements.sh <project-path> <platform>

set -euo pipefail

PROJECT_PATH="${1:-.}"
PLATFORM="${2:-}"

# Validate inputs
if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path does not exist: $PROJECT_PATH" >&2
    exit 1
fi

if [ -z "$PLATFORM" ]; then
    echo "ERROR: Platform name required" >&2
    echo "Usage: $0 <project-path> <platform>" >&2
    echo "Platforms: fastmcp-cloud, digitalocean, vercel, netlify, cloudflare-pages, hostinger" >&2
    exit 1
fi

# Change to project directory
cd "$PROJECT_PATH"

# Track validation status
ERRORS=0
WARNINGS=0

# Validation functions
check_required_file() {
    local file="$1"
    local description="$2"

    if [ ! -f "$file" ]; then
        echo "ERROR: Missing required file: $file ($description)" >&2
        ERRORS=$((ERRORS + 1))
        return 1
    else
        echo "✓ Found: $file" >&2
        return 0
    fi
}

check_optional_file() {
    local file="$1"
    local description="$2"

    if [ ! -f "$file" ]; then
        echo "WARNING: Missing optional file: $file ($description)" >&2
        WARNINGS=$((WARNINGS + 1))
        return 1
    else
        echo "✓ Found: $file" >&2
        return 0
    fi
}

check_package_json_field() {
    local field="$1"
    local description="$2"

    if [ ! -f "package.json" ]; then
        return 1
    fi

    if grep -q "\"$field\"" package.json 2>/dev/null; then
        echo "✓ Found package.json field: $field" >&2
        return 0
    else
        echo "WARNING: Missing package.json field: $field ($description)" >&2
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

# Platform-specific validation
validate_fastmcp_cloud() {
    echo "=== Validating for FastMCP Cloud ===" >&2

    # Required: MCP configuration
    if ! check_required_file ".mcp.json" "MCP server configuration"; then
        if ! check_required_file "mcp.json" "MCP server configuration"; then
            check_required_file ".mcp.yaml" "MCP server configuration"
        fi
    fi

    # Required: FastMCP dependency
    if [ -f "package.json" ]; then
        if ! grep -q "fastmcp" package.json 2>/dev/null; then
            echo "ERROR: FastMCP dependency not found in package.json" >&2
            ERRORS=$((ERRORS + 1))
        else
            echo "✓ Found FastMCP dependency" >&2
        fi
    elif [ -f "requirements.txt" ]; then
        if ! grep -q "fastmcp" requirements.txt 2>/dev/null; then
            echo "ERROR: FastMCP dependency not found in requirements.txt" >&2
            ERRORS=$((ERRORS + 1))
        else
            echo "✓ Found FastMCP dependency" >&2
        fi
    else
        echo "ERROR: No package.json or requirements.txt found" >&2
        ERRORS=$((ERRORS + 1))
    fi

    # Optional: Environment variables template
    check_optional_file ".env.example" "Environment variables template"

    # Optional: README
    check_optional_file "README.md" "Project documentation"
}

validate_digitalocean() {
    echo "=== Validating for DigitalOcean App Platform ===" >&2

    # Check for Dockerfile or buildpack compatibility
    if [ -f "Dockerfile" ]; then
        echo "✓ Found Dockerfile for container deployment" >&2
    elif [ -f "package.json" ]; then
        echo "✓ Found package.json - will use Node.js buildpack" >&2
        check_package_json_field "start" "Start script for production"
    elif [ -f "requirements.txt" ]; then
        echo "✓ Found requirements.txt - will use Python buildpack" >&2
        check_optional_file "Procfile" "Process definition for deployment"
    else
        echo "WARNING: No Dockerfile, package.json, or requirements.txt found" >&2
        WARNINGS=$((WARNINGS + 1))
    fi

    # Optional: .doignore
    check_optional_file ".doignore" "Files to exclude from deployment"

    # Optional: app.yaml
    check_optional_file "app.yaml" "DigitalOcean App Platform configuration"

    # Environment variables
    check_optional_file ".env.example" "Environment variables template"
}

validate_vercel() {
    echo "=== Validating for Vercel ===" >&2

    # Required: package.json for Node.js projects
    if [ -f "package.json" ]; then
        echo "✓ Found package.json" >&2

        # Check for build script
        check_package_json_field "build" "Build script"

        # Check for framework
        if grep -Eq "next|react|vue|astro|svelte" package.json 2>/dev/null; then
            echo "✓ Detected supported framework" >&2
        else
            echo "WARNING: No recognized framework detected" >&2
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo "ERROR: No package.json found - Vercel requires Node.js project" >&2
        ERRORS=$((ERRORS + 1))
    fi

    # Optional: vercel.json
    check_optional_file "vercel.json" "Vercel configuration"

    # Optional: .vercelignore
    check_optional_file ".vercelignore" "Files to exclude from deployment"

    # Check for output directory
    if [ -d ".next" ] || [ -d "dist" ] || [ -d "build" ] || [ -d "out" ]; then
        echo "✓ Found build output directory" >&2
    else
        echo "INFO: No build output directory found (will be created during build)" >&2
    fi
}

validate_netlify() {
    echo "=== Validating for Netlify ===" >&2

    # Check for build configuration
    if check_optional_file "netlify.toml" "Netlify configuration"; then
        echo "✓ Using netlify.toml for configuration" >&2
    elif [ -f "package.json" ]; then
        check_package_json_field "build" "Build script"
    fi

    # Check for package.json or static files
    if [ -f "package.json" ]; then
        echo "✓ Found package.json for build process" >&2
    elif [ -f "index.html" ]; then
        echo "✓ Found index.html for static site" >&2
    else
        echo "WARNING: No package.json or index.html found" >&2
        WARNINGS=$((WARNINGS + 1))
    fi

    # Optional: _redirects or _headers
    check_optional_file "_redirects" "Redirect rules"
    check_optional_file "_headers" "Custom headers"

    # Optional: functions directory
    if [ -d "netlify/functions" ] || [ -d "functions" ]; then
        echo "✓ Found serverless functions directory" >&2
    fi
}

validate_cloudflare_pages() {
    echo "=== Validating for Cloudflare Pages ===" >&2

    # Check for static files or build process
    if [ -f "index.html" ]; then
        echo "✓ Found index.html for static site" >&2
    elif [ -f "package.json" ]; then
        echo "✓ Found package.json for build process" >&2
        check_package_json_field "build" "Build script"
    else
        echo "ERROR: No index.html or package.json found" >&2
        ERRORS=$((ERRORS + 1))
    fi

    # Optional: wrangler.toml for advanced configuration
    check_optional_file "wrangler.toml" "Cloudflare Workers configuration"

    # Optional: _redirects
    check_optional_file "_redirects" "Redirect rules"

    # Check for output directory
    if [ -d "dist" ] || [ -d "build" ] || [ -d "public" ]; then
        echo "✓ Found output directory" >&2
    fi
}

validate_hostinger() {
    echo "=== Validating for Hostinger ===" >&2

    # Hostinger supports static sites and PHP
    if [ -f "index.html" ] || [ -f "index.php" ]; then
        echo "✓ Found entry point (index.html or index.php)" >&2
    else
        echo "ERROR: No index.html or index.php found" >&2
        ERRORS=$((ERRORS + 1))
    fi

    # Optional: .htaccess for Apache configuration
    check_optional_file ".htaccess" "Apache configuration"

    # Check for static assets
    if [ -d "css" ] || [ -d "js" ] || [ -d "images" ] || [ -d "assets" ]; then
        echo "✓ Found static assets directory" >&2
    fi
}

# Run platform-specific validation
case "$PLATFORM" in
    fastmcp-cloud)
        validate_fastmcp_cloud
        ;;
    digitalocean)
        validate_digitalocean
        ;;
    vercel)
        validate_vercel
        ;;
    netlify)
        validate_netlify
        ;;
    cloudflare-pages)
        validate_cloudflare_pages
        ;;
    hostinger)
        validate_hostinger
        ;;
    *)
        echo "ERROR: Unknown platform: $PLATFORM" >&2
        echo "Supported platforms: fastmcp-cloud, digitalocean, vercel, netlify, cloudflare-pages, hostinger" >&2
        exit 1
        ;;
esac

# Summary
echo "" >&2
echo "=== Validation Summary ===" >&2
echo "Errors: $ERRORS" >&2
echo "Warnings: $WARNINGS" >&2

if [ $ERRORS -gt 0 ]; then
    echo "RESULT: FAILED - Fix errors before deploying" >&2
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "RESULT: PASSED with warnings - Review warnings before deploying" >&2
    exit 0
else
    echo "RESULT: PASSED - Ready for deployment" >&2
    exit 0
fi

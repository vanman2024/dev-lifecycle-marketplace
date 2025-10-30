#!/usr/bin/env bash
# recommend-platform.sh - Recommend deployment platform based on project characteristics
# Usage: bash recommend-platform.sh <project-path>

set -euo pipefail

PROJECT_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validate project path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path does not exist: $PROJECT_PATH" >&2
    exit 1
fi

# Change to project directory
cd "$PROJECT_PATH"

# Detect project type and framework
PROJECT_TYPE=$("$SCRIPT_DIR/detect-project-type.sh" "$PROJECT_PATH")
FRAMEWORK=$("$SCRIPT_DIR/detect-framework.sh" "$PROJECT_PATH")

# Platform recommendation logic
recommend_platform() {
    local project_type="$1"
    local framework="$2"

    # MCP Server recommendations
    if [ "$project_type" = "mcp-server" ]; then
        if echo "$framework" | grep -q "FastMCP"; then
            echo "fastmcp-cloud"
            echo "REASON: FastMCP Cloud is optimized for FastMCP servers with automatic scaling and built-in MCP protocol support" >&2
            return 0
        else
            echo "digitalocean"
            echo "REASON: DigitalOcean App Platform provides flexible container hosting for custom MCP servers" >&2
            return 0
        fi
    fi

    # API recommendations
    if [ "$project_type" = "api" ]; then
        # Check if Dockerfile exists
        if [ -f "Dockerfile" ]; then
            echo "digitalocean"
            echo "REASON: DigitalOcean App Platform supports containerized APIs with auto-scaling and managed databases" >&2
            return 0
        fi

        # Check for serverless-compatible frameworks
        if echo "$framework" | grep -Eq "Express|FastAPI"; then
            # Check if package.json has vercel adapter or similar
            if [ -f "package.json" ] && grep -q "vercel" package.json 2>/dev/null; then
                echo "vercel"
                echo "REASON: Vercel supports serverless API routes with edge functions" >&2
                return 0
            fi

            echo "digitalocean"
            echo "REASON: DigitalOcean provides reliable hosting for traditional API frameworks" >&2
            return 0
        fi

        echo "digitalocean"
        echo "REASON: DigitalOcean is versatile for most API deployments" >&2
        return 0
    fi

    # Frontend recommendations
    if [ "$project_type" = "frontend" ]; then
        if echo "$framework" | grep -q "Next.js"; then
            echo "vercel"
            echo "REASON: Vercel is built by the Next.js team, offering optimal performance and developer experience" >&2
            return 0
        fi

        if echo "$framework" | grep -Eq "Astro|React|Vue|Svelte"; then
            # Check if SSR is enabled
            if [ -f "astro.config.mjs" ] && grep -q "output.*server" astro.config.mjs 2>/dev/null; then
                echo "vercel"
                echo "REASON: Vercel supports SSR Astro apps with edge functions" >&2
                return 0
            fi

            # Static or hybrid rendering
            echo "vercel"
            echo "REASON: Vercel provides excellent performance for modern frontend frameworks with edge CDN" >&2
            return 0
        fi

        echo "vercel"
        echo "REASON: Vercel is optimized for frontend deployments" >&2
        return 0
    fi

    # Static site recommendations
    if [ "$project_type" = "static-site" ]; then
        # Check project size/complexity
        if [ -f "package.json" ]; then
            # More complex static site
            echo "netlify"
            echo "REASON: Netlify offers great build tools and CDN for static sites with build processes" >&2
            return 0
        else
            # Simple static site
            echo "cloudflare-pages"
            echo "REASON: Cloudflare Pages provides fast global CDN for simple static sites" >&2
            return 0
        fi
    fi

    # Monorepo recommendations
    if [ "$project_type" = "monorepo" ]; then
        echo "multiple-platforms"
        echo "REASON: Monorepos typically require multiple deployment platforms - analyze each service separately" >&2
        echo "HINT: Run detection on each service directory independently" >&2
        return 0
    fi

    # Default recommendation
    echo "digitalocean"
    echo "REASON: DigitalOcean App Platform is versatile for most deployment scenarios" >&2
    return 0
}

# Get recommendation
PLATFORM=$(recommend_platform "$PROJECT_TYPE" "$FRAMEWORK")

# Output primary result
echo "$PLATFORM"

# Debug output
if [ "${DEBUG:-}" = "1" ]; then
    echo "=== Platform Recommendation ===" >&2
    echo "Project Type: $PROJECT_TYPE" >&2
    echo "Framework: $FRAMEWORK" >&2
    echo "Recommended: $PLATFORM" >&2
fi

exit 0

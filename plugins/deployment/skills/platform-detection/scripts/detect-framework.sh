#!/usr/bin/env bash
# detect-framework.sh - Detect framework used in project
# Usage: bash detect-framework.sh <project-path>

set -euo pipefail

PROJECT_PATH="${1:-.}"

# Validate project path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path does not exist: $PROJECT_PATH" >&2
    exit 1
fi

# Change to project directory
cd "$PROJECT_PATH"

# Framework detection functions

detect_fastmcp() {
    if [ -f "package.json" ] && grep -q "fastmcp" package.json 2>/dev/null; then
        VERSION=$(grep -o '"fastmcp"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)
        echo "FastMCP (TypeScript) ${VERSION:-unknown}"
        return 0
    fi

    if [ -f "requirements.txt" ] && grep -q "fastmcp" requirements.txt 2>/dev/null; then
        VERSION=$(grep "fastmcp" requirements.txt | grep -o '[0-9.]*' | head -1)
        echo "FastMCP (Python) ${VERSION:-unknown}"
        return 0
    fi

    if [ -f "pyproject.toml" ] && grep -q "fastmcp" pyproject.toml 2>/dev/null; then
        VERSION=$(grep "fastmcp" pyproject.toml | grep -o '[0-9.]*' | head -1)
        echo "FastMCP (Python) ${VERSION:-unknown}"
        return 0
    fi

    return 1
}

detect_nextjs() {
    if [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ]; then
        if [ -f "package.json" ]; then
            VERSION=$(grep -o '"next"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)
            echo "Next.js ${VERSION:-unknown}"
            return 0
        fi
        echo "Next.js unknown"
        return 0
    fi

    if [ -f "package.json" ] && grep -q '"next"' package.json 2>/dev/null; then
        VERSION=$(grep -o '"next"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)
        echo "Next.js ${VERSION:-unknown}"
        return 0
    fi

    return 1
}

detect_astro() {
    if [ -f "astro.config.mjs" ] || [ -f "astro.config.ts" ]; then
        if [ -f "package.json" ]; then
            VERSION=$(grep -o '"astro"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)
            echo "Astro ${VERSION:-unknown}"
            return 0
        fi
        echo "Astro unknown"
        return 0
    fi

    return 1
}

detect_react() {
    if [ -f "package.json" ] && grep -q '"react"' package.json 2>/dev/null; then
        VERSION=$(grep -o '"react"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)

        # Check if Vite-based
        if grep -q '"vite"' package.json 2>/dev/null; then
            echo "React (Vite) ${VERSION:-unknown}"
            return 0
        fi

        # Check if Create React App
        if grep -q '"react-scripts"' package.json 2>/dev/null; then
            echo "React (CRA) ${VERSION:-unknown}"
            return 0
        fi

        echo "React ${VERSION:-unknown}"
        return 0
    fi

    return 1
}

detect_vue() {
    if [ -f "package.json" ] && grep -q '"vue"' package.json 2>/dev/null; then
        VERSION=$(grep -o '"vue"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)

        # Check if Nuxt
        if grep -q '"nuxt"' package.json 2>/dev/null; then
            NUXT_VERSION=$(grep -o '"nuxt"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)
            echo "Nuxt.js ${NUXT_VERSION:-unknown} (Vue ${VERSION:-unknown})"
            return 0
        fi

        echo "Vue ${VERSION:-unknown}"
        return 0
    fi

    return 1
}

detect_svelte() {
    if [ -f "package.json" ] && grep -q '"svelte"' package.json 2>/dev/null; then
        VERSION=$(grep -o '"svelte"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)

        # Check if SvelteKit
        if grep -q '"@sveltejs/kit"' package.json 2>/dev/null; then
            echo "SvelteKit ${VERSION:-unknown}"
            return 0
        fi

        echo "Svelte ${VERSION:-unknown}"
        return 0
    fi

    return 1
}

detect_fastapi() {
    if [ -f "requirements.txt" ] && grep -q "fastapi" requirements.txt 2>/dev/null; then
        VERSION=$(grep "fastapi" requirements.txt | grep -o '[0-9.]*' | head -1)
        echo "FastAPI ${VERSION:-unknown}"
        return 0
    fi

    if [ -f "pyproject.toml" ] && grep -q "fastapi" pyproject.toml 2>/dev/null; then
        VERSION=$(grep "fastapi" pyproject.toml | grep -o '[0-9.]*' | head -1)
        echo "FastAPI ${VERSION:-unknown}"
        return 0
    fi

    return 1
}

detect_flask() {
    if [ -f "requirements.txt" ] && grep -q "flask" requirements.txt 2>/dev/null; then
        VERSION=$(grep "^flask" requirements.txt | grep -o '[0-9.]*' | head -1)
        echo "Flask ${VERSION:-unknown}"
        return 0
    fi

    if [ -f "pyproject.toml" ] && grep -q "flask" pyproject.toml 2>/dev/null; then
        VERSION=$(grep "flask" pyproject.toml | grep -o '[0-9.]*' | head -1)
        echo "Flask ${VERSION:-unknown}"
        return 0
    fi

    return 1
}

detect_django() {
    if [ -f "requirements.txt" ] && grep -q "django" requirements.txt 2>/dev/null; then
        VERSION=$(grep "^django" requirements.txt | grep -o '[0-9.]*' | head -1)
        echo "Django ${VERSION:-unknown}"
        return 0
    fi

    if [ -f "pyproject.toml" ] && grep -q "django" pyproject.toml 2>/dev/null; then
        VERSION=$(grep "django" pyproject.toml | grep -o '[0-9.]*' | head -1)
        echo "Django ${VERSION:-unknown}"
        return 0
    fi

    if [ -f "manage.py" ] && grep -q "django" manage.py 2>/dev/null; then
        echo "Django unknown"
        return 0
    fi

    return 1
}

detect_express() {
    if [ -f "package.json" ] && grep -q '"express"' package.json 2>/dev/null; then
        VERSION=$(grep -o '"express"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)
        echo "Express ${VERSION:-unknown}"
        return 0
    fi

    return 1
}

detect_static_site_generator() {
    # Jekyll
    if [ -f "_config.yml" ] && [ -d "_posts" ]; then
        echo "Jekyll"
        return 0
    fi

    # Hugo
    if [ -f "config.toml" ] || [ -f "config.yaml" ]; then
        if [ -d "content" ] || [ -d "themes" ]; then
            echo "Hugo"
            return 0
        fi
    fi

    # Gatsby
    if [ -f "gatsby-config.js" ] || [ -f "gatsby-config.ts" ]; then
        if [ -f "package.json" ]; then
            VERSION=$(grep -o '"gatsby"[^}]*"[0-9.]*"' package.json | grep -o '[0-9.]*' | head -1)
            echo "Gatsby ${VERSION:-unknown}"
            return 0
        fi
        echo "Gatsby unknown"
        return 0
    fi

    return 1
}

# Run detection in priority order (most specific first)
FRAMEWORK=""

# MCP frameworks first
if detect_fastmcp; then
    exit 0
fi

# Frontend frameworks
if detect_nextjs; then
    exit 0
fi

if detect_astro; then
    exit 0
fi

if detect_vue; then
    exit 0
fi

if detect_svelte; then
    exit 0
fi

if detect_react; then
    exit 0
fi

# Backend frameworks
if detect_fastapi; then
    exit 0
fi

if detect_django; then
    exit 0
fi

if detect_flask; then
    exit 0
fi

if detect_express; then
    exit 0
fi

# Static site generators
if detect_static_site_generator; then
    exit 0
fi

# No framework detected
echo "unknown"
exit 0

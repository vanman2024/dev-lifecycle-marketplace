#!/usr/bin/env bash
# detect-project-type.sh - Detect project type from project structure
# Usage: bash detect-project-type.sh <project-path>

set -euo pipefail

PROJECT_PATH="${1:-.}"

# Validate project path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path does not exist: $PROJECT_PATH" >&2
    exit 1
fi

# Change to project directory
cd "$PROJECT_PATH"

# Scoring system for project type detection
declare -A SCORES
SCORES[mcp-server]=0
SCORES[api]=0
SCORES[frontend]=0
SCORES[static-site]=0
SCORES[monorepo]=0

# MCP Server Detection
if [ -f ".mcp.json" ] || [ -f "mcp.json" ] || [ -f ".mcp.yaml" ]; then
    SCORES[mcp-server]=$((SCORES[mcp-server] + 10))
fi

if [ -f "package.json" ] && grep -q "fastmcp" package.json 2>/dev/null; then
    SCORES[mcp-server]=$((SCORES[mcp-server] + 8))
fi

if [ -f "requirements.txt" ] && grep -q "fastmcp" requirements.txt 2>/dev/null; then
    SCORES[mcp-server]=$((SCORES[mcp-server] + 8))
fi

if [ -f "pyproject.toml" ] && grep -q "fastmcp" pyproject.toml 2>/dev/null; then
    SCORES[mcp-server]=$((SCORES[mcp-server] + 8))
fi

# Check for MCP server initialization patterns
if find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) -exec grep -l "FastMCP\|createMCPServer\|MCPServer" {} \; 2>/dev/null | head -1 | grep -q .; then
    SCORES[mcp-server]=$((SCORES[mcp-server] + 5))
fi

# API Detection
if [ -f "package.json" ] && grep -Eq "express|fastify|koa|hapi" package.json 2>/dev/null; then
    SCORES[api]=$((SCORES[api] + 7))
fi

if [ -f "requirements.txt" ] && grep -Eq "fastapi|flask|django" requirements.txt 2>/dev/null; then
    SCORES[api]=$((SCORES[api] + 7))
fi

if [ -f "pyproject.toml" ] && grep -Eq "fastapi|flask|django" pyproject.toml 2>/dev/null; then
    SCORES[api]=$((SCORES[api] + 7))
fi

# Check for API route patterns
if find . -type f \( -name "*.ts" -o -name "*.js" \) -path "*/routes/*" 2>/dev/null | head -1 | grep -q .; then
    SCORES[api]=$((SCORES[api] + 4))
fi

if find . -type f -name "*.py" -path "*/routers/*" 2>/dev/null | head -1 | grep -q .; then
    SCORES[api]=$((SCORES[api] + 4))
fi

# Check for OpenAPI/Swagger
if find . -type f \( -name "openapi.json" -o -name "swagger.json" -o -name "openapi.yaml" \) 2>/dev/null | head -1 | grep -q .; then
    SCORES[api]=$((SCORES[api] + 5))
fi

# Frontend Detection
if [ -f "package.json" ]; then
    if grep -Eq "next|react|vue|astro|svelte|solid-js" package.json 2>/dev/null; then
        SCORES[frontend]=$((SCORES[frontend] + 8))
    fi
fi

if [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ]; then
    SCORES[frontend]=$((SCORES[frontend] + 10))
fi

if [ -f "astro.config.mjs" ] || [ -f "astro.config.ts" ]; then
    SCORES[frontend]=$((SCORES[frontend] + 10))
fi

if [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
    SCORES[frontend]=$((SCORES[frontend] + 6))
fi

if [ -d "src/pages" ] || [ -d "app" ] || [ -d "pages" ]; then
    SCORES[frontend]=$((SCORES[frontend] + 5))
fi

# Static Site Detection
if [ -f "index.html" ] && [ ! -f "package.json" ]; then
    SCORES[static-site]=$((SCORES[static-site] + 8))
fi

if [ -f "_config.yml" ]; then  # Jekyll
    SCORES[static-site]=$((SCORES[static-site] + 10))
fi

if [ -f "config.toml" ] || [ -f "config.yaml" ]; then  # Hugo
    SCORES[static-site]=$((SCORES[static-site] + 10))
fi

# Check for static site generator patterns
if find . -type f -name "*.md" -path "*/_posts/*" 2>/dev/null | head -1 | grep -q .; then
    SCORES[static-site]=$((SCORES[static-site] + 5))
fi

# Monorepo Detection
if [ -f "pnpm-workspace.yaml" ] || [ -f "lerna.json" ] || [ -f "nx.json" ]; then
    SCORES[monorepo]=$((SCORES[monorepo] + 10))
fi

if [ -f "package.json" ] && grep -q "\"workspaces\"" package.json 2>/dev/null; then
    SCORES[monorepo]=$((SCORES[monorepo] + 10))
fi

# Count package.json files (excluding node_modules)
PACKAGE_JSON_COUNT=$(find . -name "package.json" -not -path "*/node_modules/*" 2>/dev/null | wc -l)
if [ "$PACKAGE_JSON_COUNT" -gt 1 ]; then
    SCORES[monorepo]=$((SCORES[monorepo] + 8))
fi

# Count requirements.txt files
REQUIREMENTS_COUNT=$(find . -name "requirements.txt" -not -path "*/venv/*" -not -path "*/.venv/*" 2>/dev/null | wc -l)
if [ "$REQUIREMENTS_COUNT" -gt 1 ]; then
    SCORES[monorepo]=$((SCORES[monorepo] + 6))
fi

# Find the highest score
MAX_SCORE=0
DETECTED_TYPE="unknown"

for TYPE in "${!SCORES[@]}"; do
    SCORE=${SCORES[$TYPE]}
    if [ "$SCORE" -gt "$MAX_SCORE" ]; then
        MAX_SCORE=$SCORE
        DETECTED_TYPE="$TYPE"
    fi
done

# If no clear detection, default to unknown
if [ "$MAX_SCORE" -lt 5 ]; then
    DETECTED_TYPE="unknown"
fi

# Output result
echo "$DETECTED_TYPE"

# Debug output (to stderr)
if [ "${DEBUG:-}" = "1" ]; then
    echo "=== Detection Scores ===" >&2
    for TYPE in "${!SCORES[@]}"; do
        echo "$TYPE: ${SCORES[$TYPE]}" >&2
    done
    echo "Selected: $DETECTED_TYPE (score: $MAX_SCORE)" >&2
fi

exit 0

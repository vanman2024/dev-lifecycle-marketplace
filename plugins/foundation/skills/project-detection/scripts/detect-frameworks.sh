#!/bin/bash
# detect-frameworks.sh - Comprehensive framework detection across all languages
# Usage: ./detect-frameworks.sh <project-path>

set -euo pipefail

PROJECT_PATH="${1:-.}"
RESULTS=()

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function to add detection result
add_detection() {
    local name="$1"
    local version="$2"
    local confidence="$3"
    local evidence="$4"

    RESULTS+=("{\"name\":\"$name\",\"version\":\"$version\",\"confidence\":\"$confidence\",\"evidence\":\"$evidence\"}")
}

# Detect Next.js
detect_nextjs() {
    if [[ -f "$PROJECT_PATH/next.config.js" ]] || [[ -f "$PROJECT_PATH/next.config.ts" ]] || [[ -f "$PROJECT_PATH/next.config.mjs" ]]; then
        local version="unknown"
        if [[ -f "$PROJECT_PATH/package.json" ]]; then
            version=$(grep -o '"next"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
        fi
        add_detection "Next.js" "$version" "high" "next.config.js"
    fi
}

# Detect React
detect_react() {
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"react"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"react"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "React" "$version" "high" "package.json"
        fi
    fi
}

# Detect Vue
detect_vue() {
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"vue"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"vue"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Vue" "$version" "high" "package.json"
        fi
    fi

    if [[ -f "$PROJECT_PATH/vite.config.js" ]] && grep -q "vue" "$PROJECT_PATH/vite.config.js"; then
        add_detection "Vue" "unknown" "medium" "vite.config.js"
    fi
}

# Detect Svelte
detect_svelte() {
    if [[ -f "$PROJECT_PATH/svelte.config.js" ]] || [[ -f "$PROJECT_PATH/svelte.config.ts" ]]; then
        local version="unknown"
        if [[ -f "$PROJECT_PATH/package.json" ]]; then
            version=$(grep -o '"svelte"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
        fi
        add_detection "Svelte" "$version" "high" "svelte.config.js"
    fi
}

# Detect Angular
detect_angular() {
    if [[ -f "$PROJECT_PATH/angular.json" ]]; then
        local version="unknown"
        if [[ -f "$PROJECT_PATH/package.json" ]]; then
            version=$(grep -o '"@angular/core"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
        fi
        add_detection "Angular" "$version" "high" "angular.json"
    fi
}

# Detect FastAPI
detect_fastapi() {
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "fastapi" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "fastapi" "$PROJECT_PATH/requirements.txt" | sed 's/fastapi==\(.*\)/\1/' || echo "unknown")
            add_detection "FastAPI" "$version" "high" "requirements.txt"
        fi
    fi

    if [[ -f "$PROJECT_PATH/pyproject.toml" ]] && grep -qi "fastapi" "$PROJECT_PATH/pyproject.toml"; then
        add_detection "FastAPI" "unknown" "medium" "pyproject.toml"
    fi
}

# Detect Django
detect_django() {
    if [[ -f "$PROJECT_PATH/manage.py" ]] && grep -q "django" "$PROJECT_PATH/manage.py"; then
        local version="unknown"
        if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
            version=$(grep -i "django" "$PROJECT_PATH/requirements.txt" | head -1 | sed 's/[dD]jango==\(.*\)/\1/' || echo "unknown")
        fi
        add_detection "Django" "$version" "high" "manage.py"
    fi
}

# Detect Flask
detect_flask() {
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "flask" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "^flask" "$PROJECT_PATH/requirements.txt" | sed 's/[fF]lask==\(.*\)/\1/' || echo "unknown")
            add_detection "Flask" "$version" "high" "requirements.txt"
        fi
    fi
}

# Detect Express
detect_express() {
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"express"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"express"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Express" "$version" "high" "package.json"
        fi
    fi
}

# Detect NestJS
detect_nestjs() {
    if [[ -f "$PROJECT_PATH/nest-cli.json" ]]; then
        local version="unknown"
        if [[ -f "$PROJECT_PATH/package.json" ]]; then
            version=$(grep -o '"@nestjs/core"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
        fi
        add_detection "NestJS" "$version" "high" "nest-cli.json"
    fi
}

# Detect Go frameworks
detect_go_frameworks() {
    if [[ -f "$PROJECT_PATH/go.mod" ]]; then
        # Gin
        if grep -q "github.com/gin-gonic/gin" "$PROJECT_PATH/go.mod"; then
            local version=$(grep "github.com/gin-gonic/gin" "$PROJECT_PATH/go.mod" | awk '{print $2}' || echo "unknown")
            add_detection "Gin" "$version" "high" "go.mod"
        fi

        # Echo
        if grep -q "github.com/labstack/echo" "$PROJECT_PATH/go.mod"; then
            local version=$(grep "github.com/labstack/echo" "$PROJECT_PATH/go.mod" | awk '{print $2}' || echo "unknown")
            add_detection "Echo" "$version" "high" "go.mod"
        fi

        # Fiber
        if grep -q "github.com/gofiber/fiber" "$PROJECT_PATH/go.mod"; then
            local version=$(grep "github.com/gofiber/fiber" "$PROJECT_PATH/go.mod" | awk '{print $2}' || echo "unknown")
            add_detection "Fiber" "$version" "high" "go.mod"
        fi

        # Chi
        if grep -q "github.com/go-chi/chi" "$PROJECT_PATH/go.mod"; then
            local version=$(grep "github.com/go-chi/chi" "$PROJECT_PATH/go.mod" | awk '{print $2}' || echo "unknown")
            add_detection "Chi" "$version" "high" "go.mod"
        fi
    fi
}

# Detect Rust frameworks
detect_rust_frameworks() {
    if [[ -f "$PROJECT_PATH/Cargo.toml" ]]; then
        # Actix-web
        if grep -q "actix-web" "$PROJECT_PATH/Cargo.toml"; then
            local version=$(grep "actix-web" "$PROJECT_PATH/Cargo.toml" | grep version | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Actix-web" "$version" "high" "Cargo.toml"
        fi

        # Rocket
        if grep -q "rocket" "$PROJECT_PATH/Cargo.toml"; then
            local version=$(grep "^rocket" "$PROJECT_PATH/Cargo.toml" | grep version | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Rocket" "$version" "high" "Cargo.toml"
        fi

        # Axum
        if grep -q "axum" "$PROJECT_PATH/Cargo.toml"; then
            local version=$(grep "axum" "$PROJECT_PATH/Cargo.toml" | grep version | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Axum" "$version" "high" "Cargo.toml"
        fi
    fi
}

# Detect Vite
detect_vite() {
    if [[ -f "$PROJECT_PATH/vite.config.js" ]] || [[ -f "$PROJECT_PATH/vite.config.ts" ]]; then
        local version="unknown"
        if [[ -f "$PROJECT_PATH/package.json" ]]; then
            version=$(grep -o '"vite"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
        fi
        add_detection "Vite" "$version" "high" "vite.config.js"
    fi
}

# Main detection logic
echo -e "${GREEN}Starting framework detection...${NC}" >&2
echo -e "${YELLOW}Scanning: $PROJECT_PATH${NC}" >&2

# Run all detectors
detect_nextjs
detect_react
detect_vue
detect_svelte
detect_angular
detect_fastapi
detect_django
detect_flask
detect_express
detect_nestjs
detect_go_frameworks
detect_rust_frameworks
detect_vite

# Output JSON
echo "{"
echo "  \"project_path\": \"$PROJECT_PATH\","
echo "  \"detected_frameworks\": ["

# Print results with proper JSON formatting
first=true
for result in "${RESULTS[@]}"; do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    echo "    $result"
done

echo ""
echo "  ],"
echo "  \"count\": ${#RESULTS[@]},"
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

echo -e "${GREEN}Detection complete! Found ${#RESULTS[@]} frameworks.${NC}" >&2

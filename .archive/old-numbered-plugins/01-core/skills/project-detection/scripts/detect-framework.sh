#!/usr/bin/env bash
# Script: detect-framework.sh
# Purpose: Detect project framework from configuration files
# Plugin: core
# Skill: project-detection
# Usage: ./detect-framework.sh [project-path]

set -euo pipefail

PROJECT_PATH="${1:-.}"

# Navigate to project directory
cd "$PROJECT_PATH" || exit 1

echo "[INFO] Detecting framework in: $PROJECT_PATH"

# Node.js Detection
if [[ -f "package.json" ]]; then
    if grep -q '"next"' package.json; then
        echo "Framework: Next.js"
        exit 0
    elif grep -q '"react"' package.json && [[ -d "src" ]]; then
        echo "Framework: React"
        exit 0
    elif grep -q '"vue"' package.json; then
        echo "Framework: Vue.js"
        exit 0
    elif grep -q '"express"' package.json; then
        echo "Framework: Express.js"
        exit 0
    elif grep -q '"@nestjs/core"' package.json; then
        echo "Framework: NestJS"
        exit 0
    else
        echo "Framework: Node.js (generic)"
        exit 0
    fi
fi

# Python Detection
if [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
    if grep -q -i "django" pyproject.toml requirements.txt 2>/dev/null; then
        echo "Framework: Django"
        exit 0
    elif grep -q -i "fastapi" pyproject.toml requirements.txt 2>/dev/null; then
        echo "Framework: FastAPI"
        exit 0
    elif grep -q -i "flask" pyproject.toml requirements.txt 2>/dev/null; then
        echo "Framework: Flask"
        exit 0
    else
        echo "Framework: Python (generic)"
        exit 0
    fi
fi

# Rust Detection
if [[ -f "Cargo.toml" ]]; then
    echo "Framework: Rust"
    exit 0
fi

# Go Detection
if [[ -f "go.mod" ]]; then
    echo "Framework: Go"
    exit 0
fi

# Java Detection
if [[ -f "pom.xml" ]]; then
    echo "Framework: Java/Maven"
    exit 0
elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
    echo "Framework: Java/Gradle"
    exit 0
fi

echo "[WARN] No framework detected"
exit 1

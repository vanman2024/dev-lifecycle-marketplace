#!/usr/bin/env bash
# Script: detect-platform.sh
# Purpose: Detect deployment platform from git remote URLs
# Subsystem: mcp
# Called by: /mcp:add slash command (for auto-selecting remote variants)
# Outputs: Detected platform name (vercel, aws, railway, render, or unknown)

set -euo pipefail

# --- Configuration ---
PROJECT_DIR="${1:-.}"
OUTPUT_FILE="${2:-/tmp/mcp-platform-detection.json}"

# --- Main Logic ---
cd "$PROJECT_DIR" || exit 1

echo "[INFO] Detecting deployment platform from git remote..."

# Get git remote URL
if ! git remote -v &>/dev/null; then
    echo "[INFO] Not a git repository"
    PLATFORM="unknown"
else
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

    # Detect platform from remote URL patterns
    if [[ "$REMOTE_URL" =~ vercel ]]; then
        PLATFORM="vercel"
    elif [[ "$REMOTE_URL" =~ amazonaws.com ]]; then
        PLATFORM="aws"
    elif [[ "$REMOTE_URL" =~ railway.app ]]; then
        PLATFORM="railway"
    elif [[ "$REMOTE_URL" =~ render.com ]]; then
        PLATFORM="render"
    elif [[ "$REMOTE_URL" =~ heroku.com ]]; then
        PLATFORM="heroku"
    else
        PLATFORM="unknown"
    fi
fi

# Check for platform-specific config files as secondary detection
if [[ "$PLATFORM" == "unknown" ]]; then
    if [[ -f "vercel.json" ]] || [[ -f ".vercel/project.json" ]]; then
        PLATFORM="vercel"
    elif [[ -f "railway.json" ]] || [[ -f "railway.toml" ]]; then
        PLATFORM="railway"
    elif [[ -f "render.yaml" ]]; then
        PLATFORM="render"
    fi
fi

# Output detection result
cat > "$OUTPUT_FILE" <<EOF
{
  "platform": "$PLATFORM",
  "detected_from": "$([ -n "$REMOTE_URL" ] && echo "git_remote" || echo "config_files")",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

if [[ "$PLATFORM" != "unknown" ]]; then
    echo "✅ Detected platform: $PLATFORM"
else
    echo "ℹ️  Platform unknown (will use local MCP variant)"
fi

exit 0

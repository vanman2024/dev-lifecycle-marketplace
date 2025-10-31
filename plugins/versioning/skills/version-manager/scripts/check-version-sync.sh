#!/usr/bin/env bash
# Script: check-version-sync.sh
# Purpose: Verify VERSION file matches pyproject.toml or package.json
# Subsystem: version-management
# Called by: /version:validate, /version:status slash commands
# Outputs: JSON with version comparison results

set -euo pipefail

# --- Configuration ---
PROJECT_DIR="${1:-.}"
OUTPUT_FILE="${2:-/tmp/version-sync-check.json}"

# --- Main Logic ---
cd "$PROJECT_DIR" || exit 1

echo "[INFO] Checking version synchronization..."

# Initialize result
VERSION_FILE_VERSION=""
PROJECT_FILE_VERSION=""
PROJECT_TYPE=""
SYNC_STATUS="unknown"
MESSAGE=""

# Check if VERSION file exists
if [[ -f VERSION ]]; then
    VERSION_FILE_VERSION=$(jq -r '.version' VERSION 2>/dev/null || echo "")
    if [[ -z "$VERSION_FILE_VERSION" ]]; then
        MESSAGE="VERSION file exists but is invalid JSON or missing version field"
        SYNC_STATUS="error"
    fi
else
    MESSAGE="VERSION file not found"
    SYNC_STATUS="missing"
fi

# Detect project type and read version
if [[ -f pyproject.toml ]]; then
    PROJECT_TYPE="python"
    # Extract version from pyproject.toml
    PROJECT_FILE_VERSION=$(grep -E '^version\s*=' pyproject.toml | sed -E 's/version\s*=\s*"([^"]+)"/\1/' | tr -d ' ' || echo "")
    if [[ -z "$PROJECT_FILE_VERSION" ]]; then
        MESSAGE="pyproject.toml found but version field is missing or invalid"
        SYNC_STATUS="error"
    fi
elif [[ -f package.json ]]; then
    PROJECT_TYPE="typescript"
    # Extract version from package.json
    PROJECT_FILE_VERSION=$(jq -r '.version // empty' package.json 2>/dev/null || echo "")
    if [[ -z "$PROJECT_FILE_VERSION" ]]; then
        MESSAGE="package.json found but version field is missing or invalid"
        SYNC_STATUS="error"
    fi
else
    MESSAGE="No pyproject.toml or package.json found"
    SYNC_STATUS="no_project_file"
fi

# Compare versions if both exist
if [[ -n "$VERSION_FILE_VERSION" && -n "$PROJECT_FILE_VERSION" ]]; then
    if [[ "$VERSION_FILE_VERSION" == "$PROJECT_FILE_VERSION" ]]; then
        SYNC_STATUS="synced"
        MESSAGE="Versions are synchronized"
    else
        SYNC_STATUS="out_of_sync"
        MESSAGE="Versions do not match: VERSION=$VERSION_FILE_VERSION, $PROJECT_TYPE=$PROJECT_FILE_VERSION"
    fi
fi

# Output JSON result
cat > "$OUTPUT_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "$SYNC_STATUS",
  "message": "$MESSAGE",
  "version_file_version": "$VERSION_FILE_VERSION",
  "project_file_version": "$PROJECT_FILE_VERSION",
  "project_type": "$PROJECT_TYPE",
  "project_dir": "$PROJECT_DIR"
}
EOF

# Exit with appropriate code
case "$SYNC_STATUS" in
    synced)
        echo "✅ Versions are synchronized: $VERSION_FILE_VERSION"
        exit 0
        ;;
    out_of_sync)
        echo "❌ Versions are out of sync: VERSION=$VERSION_FILE_VERSION, $PROJECT_TYPE=$PROJECT_FILE_VERSION"
        exit 1
        ;;
    missing|no_project_file|error)
        echo "⚠️  $MESSAGE"
        exit 2
        ;;
    *)
        echo "❓ Unknown status: $SYNC_STATUS"
        exit 3
        ;;
esac

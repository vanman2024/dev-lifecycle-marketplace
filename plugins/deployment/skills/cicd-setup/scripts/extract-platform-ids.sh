#!/bin/bash
#
# Extract Platform-Specific Project IDs
#
# Usage: ./extract-platform-ids.sh <platform> <project-path>
#
# Platforms: vercel | digitalocean-app | digitalocean-droplet | railway
#
# Exit Codes:
#   0 - IDs extracted successfully
#   1 - Extraction failed
#   2 - Platform not linked

set -e

PLATFORM="$1"
PROJECT_PATH="${2:-.}"

cd "$PROJECT_PATH"

# Output JSON
extract_vercel_ids() {
    local VERCEL_CONFIG=".vercel/project.json"

    # Check if project is linked
    if [[ ! -f "$VERCEL_CONFIG" ]]; then
        echo "Project not linked to Vercel. Linking now..." >&2

        # Link project interactively
        if vercel link --yes &> /dev/null; then
            echo "✓ Project linked to Vercel" >&2
        else
            echo "✗ Failed to link project to Vercel" >&2
            echo "Run manually: vercel link" >&2
            exit 2
        fi
    fi

    # Extract IDs from config file
    if [[ -f "$VERCEL_CONFIG" ]]; then
        ORG_ID=$(jq -r '.orgId // empty' "$VERCEL_CONFIG")
        PROJECT_ID=$(jq -r '.projectId // empty' "$VERCEL_CONFIG")

        if [[ -z "$ORG_ID" ]] || [[ -z "$PROJECT_ID" ]]; then
            echo "✗ Failed to extract IDs from $VERCEL_CONFIG" >&2
            exit 1
        fi

        # Get project name from vercel CLI
        PROJECT_NAME=$(basename "$(pwd)")

        cat <<EOF
{
  "platform": "vercel",
  "orgId": "$ORG_ID",
  "projectId": "$PROJECT_ID",
  "projectName": "$PROJECT_NAME",
  "extracted_from": "$VERCEL_CONFIG",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
        exit 0
    else
        echo "✗ Vercel config file not found: $VERCEL_CONFIG" >&2
        exit 1
    fi
}

extract_digitalocean_app_ids() {
    # Try to get app info from doctl
    if command -v doctl &> /dev/null; then
        # List apps and get the first one (assuming single app)
        APP_INFO=$(doctl apps list --format ID,Spec.Name --no-header 2>/dev/null | head -1)

        if [[ -n "$APP_INFO" ]]; then
            APP_ID=$(echo "$APP_INFO" | awk '{print $1}')
            APP_NAME=$(echo "$APP_INFO" | awk '{print $2}')

            cat <<EOF
{
  "platform": "digitalocean-app",
  "appId": "$APP_ID",
  "appName": "$APP_NAME",
  "extracted_from": "doctl apps list",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
            exit 0
        fi
    fi

    echo "✗ Could not extract DigitalOcean App IDs" >&2
    echo "Ensure app is created: doctl apps create --spec app-spec.yml" >&2
    exit 1
}

extract_digitalocean_droplet_ids() {
    # Try to get droplet info from deployment metadata
    METADATA_FILE=".digitalocean/droplet.json"

    if [[ -f "$METADATA_FILE" ]]; then
        DROPLET_ID=$(jq -r '.dropletId // empty' "$METADATA_FILE")
        DROPLET_NAME=$(jq -r '.dropletName // empty' "$METADATA_FILE")

        if [[ -n "$DROPLET_ID" ]]; then
            cat <<EOF
{
  "platform": "digitalocean-droplet",
  "dropletId": "$DROPLET_ID",
  "dropletName": "$DROPLET_NAME",
  "extracted_from": "$METADATA_FILE",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
            exit 0
        fi
    fi

    # Fallback to doctl
    if command -v doctl &> /dev/null; then
        DROPLET_INFO=$(doctl compute droplet list --format ID,Name --no-header 2>/dev/null | head -1)

        if [[ -n "$DROPLET_INFO" ]]; then
            DROPLET_ID=$(echo "$DROPLET_INFO" | awk '{print $1}')
            DROPLET_NAME=$(echo "$DROPLET_INFO" | awk '{print $2}')

            cat <<EOF
{
  "platform": "digitalocean-droplet",
  "dropletId": "$DROPLET_ID",
  "dropletName": "$DROPLET_NAME",
  "extracted_from": "doctl compute droplet list",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
            exit 0
        fi
    fi

    echo "✗ Could not extract DigitalOcean Droplet IDs" >&2
    exit 1
}

extract_railway_ids() {
    # Check for railway.json
    if [[ -f "railway.json" ]]; then
        PROJECT_ID=$(jq -r '.projectId // empty' railway.json)
        SERVICE_ID=$(jq -r '.serviceId // empty' railway.json)

        if [[ -n "$PROJECT_ID" ]]; then
            cat <<EOF
{
  "platform": "railway",
  "projectId": "$PROJECT_ID",
  "serviceId": "$SERVICE_ID",
  "extracted_from": "railway.json",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
            exit 0
        fi
    fi

    # Try railway CLI
    if command -v railway &> /dev/null; then
        # Link project if not linked
        if ! railway status &> /dev/null; then
            echo "Project not linked to Railway. Linking now..." >&2
            railway link || exit 2
        fi

        PROJECT_ID=$(railway status --json 2>/dev/null | jq -r '.project.id // empty')

        if [[ -n "$PROJECT_ID" ]]; then
            cat <<EOF
{
  "platform": "railway",
  "projectId": "$PROJECT_ID",
  "extracted_from": "railway status",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
            exit 0
        fi
    fi

    echo "✗ Could not extract Railway IDs" >&2
    exit 1
}

# Main logic
case "$PLATFORM" in
    vercel)
        extract_vercel_ids
        ;;
    digitalocean-app)
        extract_digitalocean_app_ids
        ;;
    digitalocean-droplet)
        extract_digitalocean_droplet_ids
        ;;
    railway)
        extract_railway_ids
        ;;
    *)
        echo "✗ Unsupported platform: $PLATFORM" >&2
        exit 1
        ;;
esac

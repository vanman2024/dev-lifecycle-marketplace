#!/bin/bash
#
# Configure GitHub Repository Secrets via gh CLI
#
# Usage: ./configure-github-secrets.sh <platform> <project-path>
#
# Platforms: vercel | digitalocean-app | digitalocean-droplet | railway
#
# Exit Codes:
#   0 - Secrets configured successfully
#   1 - Configuration failed
#   2 - Missing gh CLI or not authenticated

set -e

PLATFORM="$1"
PROJECT_PATH="${2:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check gh CLI
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) not installed"
    exit 2
fi

# Check gh authentication
if ! gh auth status &> /dev/null; then
    log_error "GitHub CLI not authenticated. Run: gh auth login"
    exit 2
fi

cd "$PROJECT_PATH"

# Extract platform IDs
IDS_JSON=""
if [[ -f "$SCRIPT_DIR/extract-platform-ids.sh" ]]; then
    log_info "Extracting platform IDs..."
    IDS_JSON=$(bash "$SCRIPT_DIR/extract-platform-ids.sh" "$PLATFORM" "." 2>/dev/null || echo "")
fi

configure_vercel_secrets() {
    log_info "Configuring Vercel secrets..."

    # Set VERCEL_TOKEN
    if [[ -n "$VERCEL_TOKEN" ]]; then
        echo "$VERCEL_TOKEN" | gh secret set VERCEL_TOKEN
        log_info "Set VERCEL_TOKEN"
    else
        log_warn "VERCEL_TOKEN not set in environment, skipping"
    fi

    # Set VERCEL_ORG_ID and VERCEL_PROJECT_ID from extracted IDs
    if [[ -n "$IDS_JSON" ]]; then
        ORG_ID=$(echo "$IDS_JSON" | jq -r '.orgId // empty' 2>/dev/null)
        PROJECT_ID=$(echo "$IDS_JSON" | jq -r '.projectId // empty' 2>/dev/null)

        if [[ -n "$ORG_ID" ]]; then
            echo "$ORG_ID" | gh secret set VERCEL_ORG_ID
            log_info "Set VERCEL_ORG_ID: $ORG_ID"
        else
            log_warn "Could not extract VERCEL_ORG_ID"
        fi

        if [[ -n "$PROJECT_ID" ]]; then
            echo "$PROJECT_ID" | gh secret set VERCEL_PROJECT_ID
            log_info "Set VERCEL_PROJECT_ID: $PROJECT_ID"
        else
            log_warn "Could not extract VERCEL_PROJECT_ID"
        fi
    else
        log_warn "Could not extract Vercel IDs. Project may not be linked."
        log_warn "Run: vercel link"
    fi

    # Optional: Set VERCEL_SCOPE if user has team
    if [[ -n "$VERCEL_SCOPE" ]]; then
        echo "$VERCEL_SCOPE" | gh secret set VERCEL_SCOPE
        log_info "Set VERCEL_SCOPE: $VERCEL_SCOPE"
    fi
}

configure_digitalocean_app_secrets() {
    log_info "Configuring DigitalOcean App Platform secrets..."

    # Set DIGITALOCEAN_ACCESS_TOKEN
    if [[ -n "$DIGITALOCEAN_ACCESS_TOKEN" ]]; then
        echo "$DIGITALOCEAN_ACCESS_TOKEN" | gh secret set DIGITALOCEAN_ACCESS_TOKEN
        log_info "Set DIGITALOCEAN_ACCESS_TOKEN"
    else
        log_warn "DIGITALOCEAN_ACCESS_TOKEN not set in environment"
    fi

    # Set DO_APP_ID from extracted IDs
    if [[ -n "$IDS_JSON" ]]; then
        APP_ID=$(echo "$IDS_JSON" | jq -r '.appId // empty' 2>/dev/null)
        APP_NAME=$(echo "$IDS_JSON" | jq -r '.appName // empty' 2>/dev/null)

        if [[ -n "$APP_ID" ]]; then
            echo "$APP_ID" | gh secret set DO_APP_ID
            log_info "Set DO_APP_ID: $APP_ID"
        fi

        if [[ -n "$APP_NAME" ]]; then
            echo "$APP_NAME" | gh secret set DO_APP_NAME
            log_info "Set DO_APP_NAME: $APP_NAME"
        fi
    else
        log_warn "Could not extract DigitalOcean App IDs"
    fi
}

configure_digitalocean_droplet_secrets() {
    log_info "Configuring DigitalOcean Droplet secrets..."

    # Set DIGITALOCEAN_ACCESS_TOKEN
    if [[ -n "$DIGITALOCEAN_ACCESS_TOKEN" ]]; then
        echo "$DIGITALOCEAN_ACCESS_TOKEN" | gh secret set DIGITALOCEAN_ACCESS_TOKEN
        log_info "Set DIGITALOCEAN_ACCESS_TOKEN"
    else
        log_warn "DIGITALOCEAN_ACCESS_TOKEN not set in environment"
    fi

    # Set DROPLET_ID from extracted IDs
    if [[ -n "$IDS_JSON" ]]; then
        DROPLET_ID=$(echo "$IDS_JSON" | jq -r '.dropletId // empty' 2>/dev/null)

        if [[ -n "$DROPLET_ID" ]]; then
            echo "$DROPLET_ID" | gh secret set DROPLET_ID
            log_info "Set DROPLET_ID: $DROPLET_ID"
        fi
    fi

    # Set SSH_PRIVATE_KEY if available
    SSH_KEY_PATH="${SSH_PRIVATE_KEY_PATH:-$HOME/.ssh/id_rsa}"
    if [[ -f "$SSH_KEY_PATH" ]]; then
        gh secret set SSH_PRIVATE_KEY < "$SSH_KEY_PATH"
        log_info "Set SSH_PRIVATE_KEY from $SSH_KEY_PATH"
    else
        log_warn "SSH private key not found at $SSH_KEY_PATH"
        log_warn "Set SSH_PRIVATE_KEY_PATH to custom location or generate key: ssh-keygen -t ed25519"
    fi
}

configure_railway_secrets() {
    log_info "Configuring Railway secrets..."

    # Set RAILWAY_TOKEN
    if [[ -n "$RAILWAY_TOKEN" ]]; then
        echo "$RAILWAY_TOKEN" | gh secret set RAILWAY_TOKEN
        log_info "Set RAILWAY_TOKEN"
    else
        log_warn "RAILWAY_TOKEN not set in environment"
    fi

    # Set RAILWAY_PROJECT_ID from extracted IDs
    if [[ -n "$IDS_JSON" ]]; then
        PROJECT_ID=$(echo "$IDS_JSON" | jq -r '.projectId // empty' 2>/dev/null)
        SERVICE_ID=$(echo "$IDS_JSON" | jq -r '.serviceId // empty' 2>/dev/null)

        if [[ -n "$PROJECT_ID" ]]; then
            echo "$PROJECT_ID" | gh secret set RAILWAY_PROJECT_ID
            log_info "Set RAILWAY_PROJECT_ID: $PROJECT_ID"
        fi

        if [[ -n "$SERVICE_ID" ]]; then
            echo "$SERVICE_ID" | gh secret set RAILWAY_SERVICE_ID
            log_info "Set RAILWAY_SERVICE_ID: $SERVICE_ID"
        fi
    else
        log_warn "Could not extract Railway IDs"
    fi
}

# Main logic
case "$PLATFORM" in
    vercel)
        configure_vercel_secrets
        ;;
    digitalocean-app)
        configure_digitalocean_app_secrets
        ;;
    digitalocean-droplet)
        configure_digitalocean_droplet_secrets
        ;;
    railway)
        configure_railway_secrets
        ;;
    *)
        log_error "Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

echo ""
log_info "Secrets configured successfully!"
log_info "View secrets: gh secret list"

exit 0

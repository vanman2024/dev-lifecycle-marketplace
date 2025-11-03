#!/bin/bash
#
# Deploy application to DigitalOcean App Platform
#
# Usage: ./deploy-to-app-platform.sh <app-spec-path> [app-id]
#
# Environment Variables:
#   MONITOR - Set to "true" to monitor deployment progress
#   WAIT - Set to "true" to wait for deployment completion
#   TIMEOUT - Deployment timeout in minutes (default: 15)
#
# Exit Codes:
#   0 - Deployment successful
#   1 - Deployment failed

set -e

APP_SPEC_PATH="$1"
APP_ID="${2:-}"
MONITOR="${MONITOR:-false}"
WAIT="${WAIT:-true}"
TIMEOUT="${TIMEOUT:-15}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_step() {
    echo -e "${BLUE}→${NC} $1"
}

# Validate inputs
if [[ -z "$APP_SPEC_PATH" ]]; then
    log_error "App spec path is required"
    echo "Usage: $0 <app-spec-path> [app-id]"
    exit 1
fi

if [[ ! -f "$APP_SPEC_PATH" ]]; then
    log_error "App spec file not found: $APP_SPEC_PATH"
    exit 1
fi

echo "DigitalOcean App Platform Deployment"
echo "App Spec: $APP_SPEC_PATH"
if [[ -n "$APP_ID" ]]; then
    echo "App ID: $APP_ID (updating existing app)"
else
    echo "Creating new app"
fi
echo ""

# Check doctl authentication
log_step "Checking doctl authentication..."
if ! doctl auth list | grep -q "current"; then
    log_error "doctl is not authenticated. Run: doctl auth init"
    exit 1
fi
log_info "doctl authenticated"

# Validate app spec
log_step "Validating app spec..."
if ! doctl apps spec validate "$APP_SPEC_PATH" 2>&1 | grep -q "valid"; then
    log_error "App spec validation failed"
    doctl apps spec validate "$APP_SPEC_PATH"
    exit 1
fi
log_info "App spec is valid"

# Deploy app
if [[ -z "$APP_ID" ]]; then
    # Create new app
    log_step "Creating new app..."

    if ! DEPLOYMENT_OUTPUT=$(doctl apps create --spec "$APP_SPEC_PATH" --format ID,DefaultIngress --no-header 2>&1); then
        log_error "Failed to create app"
        echo "$DEPLOYMENT_OUTPUT"
        exit 1
    fi

    APP_ID=$(echo "$DEPLOYMENT_OUTPUT" | awk '{print $1}')
    APP_URL=$(echo "$DEPLOYMENT_OUTPUT" | awk '{print $2}')

    log_info "App created successfully"
    echo "  App ID: $APP_ID"
    echo "  App URL: $APP_URL"

else
    # Update existing app
    log_step "Updating existing app..."

    if ! doctl apps update "$APP_ID" --spec "$APP_SPEC_PATH" >/dev/null 2>&1; then
        log_error "Failed to update app"
        exit 1
    fi

    log_info "App updated successfully"

    # Get app URL
    APP_URL=$(doctl apps get "$APP_ID" --format DefaultIngress --no-header)
    echo "  App URL: $APP_URL"
fi

# Get latest deployment
DEPLOYMENT_ID=$(doctl apps list-deployments "$APP_ID" --format ID --no-header | head -1)
echo "  Deployment ID: $DEPLOYMENT_ID"

# Wait for deployment if requested
if [[ "$WAIT" == "true" ]] || [[ "$MONITOR" == "true" ]]; then
    log_step "Waiting for deployment to complete..."

    START_TIME=$(date +%s)
    TIMEOUT_SECONDS=$((TIMEOUT * 60))

    while true; do
        DEPLOYMENT_STATUS=$(doctl apps list-deployments "$APP_ID" --format ID,Phase --no-header | grep "^$DEPLOYMENT_ID" | awk '{print $2}')

        case "$DEPLOYMENT_STATUS" in
            "ACTIVE")
                log_info "Deployment completed successfully"
                break
                ;;
            "ERROR"|"FAILED"|"CANCELED")
                log_error "Deployment failed with status: $DEPLOYMENT_STATUS"

                # Show deployment logs
                log_step "Deployment logs:"
                doctl apps logs "$APP_ID" --deployment "$DEPLOYMENT_ID" --type BUILD 2>/dev/null || echo "  No build logs available"

                exit 1
                ;;
            "PENDING_BUILD"|"BUILDING"|"PENDING_DEPLOY"|"DEPLOYING")
                if [[ "$MONITOR" == "true" ]]; then
                    echo -ne "  Status: $DEPLOYMENT_STATUS\r"
                fi
                ;;
            *)
                log_warn "Unknown deployment status: $DEPLOYMENT_STATUS"
                ;;
        esac

        # Check timeout
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))

        if [[ $ELAPSED -ge $TIMEOUT_SECONDS ]]; then
            log_error "Deployment timed out after $TIMEOUT minutes"
            exit 1
        fi

        sleep 10
    done
fi

# Show deployment information
echo ""
log_step "Deployment Information:"
echo "  App ID: $APP_ID"
echo "  Deployment ID: $DEPLOYMENT_ID"
echo "  App URL: $APP_URL"

# Get app components
log_step "App Components:"
doctl apps get "$APP_ID" --format Spec.Services,Spec.StaticSites,Spec.Workers --no-header 2>/dev/null | while IFS= read -r line; do
    if [[ -n "$line" ]] && [[ "$line" != "null" ]]; then
        echo "  $line"
    fi
done

# Health check
log_step "Running health check..."
sleep 5  # Give app a moment to start

if curl -sSf -o /dev/null -w "%{http_code}" "$APP_URL" 2>/dev/null | grep -q "200\|301\|302"; then
    log_info "App is responding"
else
    log_warn "App may not be responding yet (check manually: $APP_URL)"
fi

echo ""
log_info "Deployment complete!"
echo ""
echo "Next steps:"
echo "  - View app: $APP_URL"
echo "  - View logs: doctl apps logs $APP_ID --follow"
echo "  - Check health: curl $APP_URL/health"
echo "  - Manage app: doctl apps get $APP_ID"
echo ""

#!/bin/bash
#
# Deploy application to Vercel
#
# Usage: ./deploy-to-vercel.sh <app-path> [environment]
#
# Environment Variables:
#   VERCEL_TOKEN - Vercel authentication token
#   PROJECT_NAME - Custom project name
#   WAIT - Set to "true" to wait for deployment completion
#   PROD - Set to "true" for production deployment
#
# Exit Codes:
#   0 - Deployment successful
#   1 - Deployment failed

set -e

APP_PATH="${1:-.}"
ENVIRONMENT="${2:-preview}"
WAIT="${WAIT:-true}"
PROD="${PROD:-false}"
PROJECT_NAME="${PROJECT_NAME:-}"

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
if [[ ! -d "$APP_PATH" ]]; then
    log_error "Application path does not exist: $APP_PATH"
    exit 1
fi

echo "Vercel Deployment"
echo "App Path: $APP_PATH"
echo "Environment: $ENVIRONMENT"
if [[ -n "$PROJECT_NAME" ]]; then
    echo "Project Name: $PROJECT_NAME"
fi
echo ""

cd "$APP_PATH"

# Check Vercel CLI installation
log_step "Checking Vercel CLI..."
if ! command -v vercel &> /dev/null; then
    log_error "Vercel CLI is not installed. Install with: npm install -g vercel"
    exit 1
fi
log_info "Vercel CLI installed"

# Check authentication
log_step "Checking Vercel authentication..."
if [[ -n "$VERCEL_TOKEN" ]]; then
    log_info "Using VERCEL_TOKEN environment variable"
    export VERCEL_TOKEN
elif vercel whoami &> /dev/null; then
    log_info "Vercel CLI authenticated"
else
    log_error "Vercel CLI is not authenticated. Run: vercel login"
    exit 1
fi

# Build deployment command
DEPLOY_CMD="vercel"

# Add production flag if needed
if [[ "$ENVIRONMENT" == "production" ]] || [[ "$PROD" == "true" ]]; then
    DEPLOY_CMD="$DEPLOY_CMD --prod"
    log_step "Deploying to production..."
else
    log_step "Deploying to preview environment..."
fi

# Add project name if specified
if [[ -n "$PROJECT_NAME" ]]; then
    DEPLOY_CMD="$DEPLOY_CMD --name $PROJECT_NAME"
fi

# Add yes flag to skip prompts
DEPLOY_CMD="$DEPLOY_CMD --yes"

# Execute deployment
log_step "Executing deployment..."
echo "  Command: $DEPLOY_CMD"
echo ""

if DEPLOY_OUTPUT=$($DEPLOY_CMD 2>&1); then
    log_info "Deployment command executed successfully"

    # Extract deployment URL
    DEPLOYMENT_URL=$(echo "$DEPLOY_OUTPUT" | grep -oE 'https://[a-zA-Z0-9.-]+\.vercel\.app' | head -1)

    if [[ -n "$DEPLOYMENT_URL" ]]; then
        echo ""
        log_info "Deployment successful!"
        echo "  Deployment URL: $DEPLOYMENT_URL"
    else
        log_warn "Deployment completed but could not extract URL"
        echo "$DEPLOY_OUTPUT"
    fi

    # Wait for deployment if requested
    if [[ "$WAIT" == "true" ]]; then
        log_step "Waiting for deployment to complete..."
        sleep 5

        # Check if URL is accessible
        if curl -sf -o /dev/null "$DEPLOYMENT_URL"; then
            log_info "Deployment is live and accessible"
        else
            log_warn "Deployment URL not yet accessible (may take a few moments)"
        fi
    fi

    echo ""
    echo "Next steps:"
    echo "  - View deployment: $DEPLOYMENT_URL"
    echo "  - View logs: vercel logs $DEPLOYMENT_URL"
    if [[ "$ENVIRONMENT" != "production" ]]; then
        echo "  - Promote to production: vercel --prod"
    fi
    echo ""

    exit 0
else
    log_error "Deployment failed"
    echo "$DEPLOY_OUTPUT"
    exit 1
fi

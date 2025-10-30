#!/usr/bin/env bash
#
# vercel-deploy.sh - Deploy to Vercel with environment handling
#
# Usage: bash vercel-deploy.sh [environment]
# Environment: production (default), preview, development
#

set -euo pipefail

ENVIRONMENT="${1:-production}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    print_error "Vercel CLI not installed"
    print_info "Install with: npm i -g vercel"
    exit 1
fi

# Check authentication
if ! vercel whoami &> /dev/null; then
    print_error "Not authenticated with Vercel"
    print_info "Run: vercel login"
    exit 1
fi

print_info "Deploying to Vercel ($ENVIRONMENT)"
echo ""

# Load environment variables if file exists
ENV_FILE=".env.$ENVIRONMENT"
if [[ -f "$ENV_FILE" ]]; then
    print_info "Loading environment from: $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
fi

# Set deployment flags based on environment
DEPLOY_FLAGS=()

case "$ENVIRONMENT" in
    production|prod)
        print_info "Production deployment"
        DEPLOY_FLAGS+=("--prod")
        ;;
    preview|staging)
        print_info "Preview deployment"
        # Vercel creates preview by default for non-production
        ;;
    development|dev)
        print_info "Development deployment"
        DEPLOY_FLAGS+=("--target" "development")
        ;;
    *)
        print_warning "Unknown environment: $ENVIRONMENT, treating as preview"
        ;;
esac

# Add common flags
DEPLOY_FLAGS+=("--yes")  # Skip confirmation prompts

# Check for vercel.json
if [[ -f "vercel.json" ]]; then
    print_success "Found vercel.json configuration"
else
    print_warning "No vercel.json found - using default configuration"
fi

# Check if project is already linked
if [[ -f ".vercel/project.json" ]]; then
    print_success "Project already linked to Vercel"
else
    print_info "Linking project to Vercel..."
    vercel link --yes
fi

echo ""
print_info "Starting deployment..."
echo ""

# Deploy
if vercel deploy "${DEPLOY_FLAGS[@]}"; then
    print_success "Deployment successful!"

    echo ""

    # Get deployment info
    print_info "Deployment details:"
    vercel inspect

    # Get deployment URL
    if [[ "$ENVIRONMENT" == "production" ]] || [[ "$ENVIRONMENT" == "prod" ]]; then
        DEPLOY_URL=$(vercel inspect --json | grep -o '"url":"[^"]*' | cut -d'"' -f4 | head -1)
        print_info "Production URL: https://$DEPLOY_URL"
    else
        print_info "Preview URL available in output above"
    fi

    exit 0
else
    print_error "Deployment failed"
    exit 1
fi

#!/usr/bin/env bash
#
# netlify-deploy.sh - Deploy to Netlify with configuration
#
# Usage: bash netlify-deploy.sh [environment]
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

# Check if Netlify CLI is installed
if ! command -v netlify &> /dev/null; then
    print_error "Netlify CLI not installed"
    print_info "Install with: npm i -g netlify-cli"
    exit 1
fi

# Check authentication
if ! netlify status &> /dev/null; then
    print_error "Not authenticated with Netlify"
    print_info "Run: netlify login"
    exit 1
fi

print_info "Deploying to Netlify ($ENVIRONMENT)"
echo ""

# Load environment variables if file exists
ENV_FILE=".env.$ENVIRONMENT"
if [[ -f "$ENV_FILE" ]]; then
    print_info "Loading environment from: $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
fi

# Detect build directory
BUILD_DIR=""
if [[ -d "dist" ]]; then
    BUILD_DIR="dist"
elif [[ -d "build" ]]; then
    BUILD_DIR="build"
elif [[ -d ".next" ]]; then
    BUILD_DIR=".next"
elif [[ -d "out" ]]; then
    BUILD_DIR="out"
elif [[ -d "public" ]]; then
    BUILD_DIR="public"
fi

# Check netlify.toml
if [[ -f "netlify.toml" ]]; then
    print_success "Found netlify.toml configuration"
    # Extract build directory from netlify.toml if not found
    if [[ -z "$BUILD_DIR" ]]; then
        BUILD_DIR=$(grep -A5 "\[build\]" netlify.toml | grep "publish" | cut -d'"' -f2 || echo "")
    fi
else
    print_warning "No netlify.toml found"
fi

if [[ -z "$BUILD_DIR" ]]; then
    print_error "Could not detect build directory"
    print_info "Specify build directory in netlify.toml or create one of: dist, build, out, public"
    exit 1
fi

print_info "Build directory: $BUILD_DIR"
echo ""

# Set deployment flags based on environment
DEPLOY_FLAGS=()

case "$ENVIRONMENT" in
    production|prod)
        print_info "Production deployment"
        DEPLOY_FLAGS+=("--prod")
        ;;
    preview|staging|development|dev)
        print_info "Preview deployment"
        # Netlify creates preview by default for non-production
        ;;
    *)
        print_warning "Unknown environment: $ENVIRONMENT, treating as preview"
        ;;
esac

# Add build directory
DEPLOY_FLAGS+=("--dir" "$BUILD_DIR")

# Check if site is already linked
if [[ -f ".netlify/state.json" ]]; then
    print_success "Site already linked to Netlify"
else
    print_info "Linking site to Netlify..."
    netlify link
fi

echo ""
print_info "Starting deployment..."
echo ""

# Deploy
if netlify deploy "${DEPLOY_FLAGS[@]}"; then
    print_success "Deployment successful!"

    echo ""

    # Get deployment info
    print_info "Deployment details:"
    netlify status

    exit 0
else
    print_error "Deployment failed"
    exit 1
fi

#!/usr/bin/env bash
#
# check-auth.sh - Verify authentication for deployment platforms
#
# Usage: bash check-auth.sh <platform>
# Platforms: vercel, netlify, aws, gcloud, fly, render
#

set -euo pipefail

PLATFORM="${1:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "ℹ $1"; }

# Check if platform is specified
if [[ -z "$PLATFORM" ]]; then
    print_error "Platform not specified"
    echo "Usage: $0 <platform>"
    echo "Supported platforms: vercel, netlify, aws, gcloud, fly, render"
    exit 1
fi

# Convert platform to lowercase
PLATFORM=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')

# Function to check Vercel authentication
check_vercel() {
    print_info "Checking Vercel authentication..."

    if ! command -v vercel &> /dev/null; then
        print_error "Vercel CLI not installed"
        print_info "Install with: npm i -g vercel"
        return 1
    fi

    if vercel whoami &> /dev/null; then
        local user=$(vercel whoami)
        print_success "Authenticated as: $user"
        return 0
    else
        print_error "Not authenticated with Vercel"
        print_info "Run: vercel login"
        return 1
    fi
}

# Function to check Netlify authentication
check_netlify() {
    print_info "Checking Netlify authentication..."

    if ! command -v netlify &> /dev/null; then
        print_error "Netlify CLI not installed"
        print_info "Install with: npm i -g netlify-cli"
        return 1
    fi

    if netlify status &> /dev/null; then
        local user=$(netlify status | grep "Current user" | cut -d: -f2 | xargs)
        print_success "Authenticated as: $user"
        return 0
    else
        print_error "Not authenticated with Netlify"
        print_info "Run: netlify login"
        return 1
    fi
}

# Function to check AWS authentication
check_aws() {
    print_info "Checking AWS authentication..."

    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not installed"
        print_info "Install from: https://aws.amazon.com/cli/"
        return 1
    fi

    if aws sts get-caller-identity &> /dev/null; then
        local account=$(aws sts get-caller-identity --query Account --output text)
        local user=$(aws sts get-caller-identity --query Arn --output text)
        print_success "Authenticated to account: $account"
        print_success "Identity: $user"
        return 0
    else
        print_error "Not authenticated with AWS"
        print_info "Run: aws configure"
        return 1
    fi
}

# Function to check Google Cloud authentication
check_gcloud() {
    print_info "Checking Google Cloud authentication..."

    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud CLI not installed"
        print_info "Install from: https://cloud.google.com/sdk/docs/install"
        return 1
    fi

    if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        local account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
        if [[ -n "$account" ]]; then
            print_success "Authenticated as: $account"
            local project=$(gcloud config get-value project 2>/dev/null)
            if [[ -n "$project" ]]; then
                print_success "Active project: $project"
            fi
            return 0
        fi
    fi

    print_error "Not authenticated with Google Cloud"
    print_info "Run: gcloud auth login"
    return 1
}

# Function to check Fly.io authentication
check_fly() {
    print_info "Checking Fly.io authentication..."

    if ! command -v flyctl &> /dev/null; then
        print_error "Fly.io CLI not installed"
        print_info "Install from: https://fly.io/docs/hands-on/install-flyctl/"
        return 1
    fi

    if flyctl auth whoami &> /dev/null; then
        local user=$(flyctl auth whoami)
        print_success "Authenticated as: $user"
        return 0
    else
        print_error "Not authenticated with Fly.io"
        print_info "Run: flyctl auth login"
        return 1
    fi
}

# Function to check Render authentication
check_render() {
    print_info "Checking Render authentication..."

    # Render uses API key authentication
    if [[ -z "${RENDER_API_KEY:-}" ]]; then
        print_error "RENDER_API_KEY environment variable not set"
        print_info "Get your API key from: https://dashboard.render.com/u/settings#api-keys"
        print_info "Set with: export RENDER_API_KEY=your_key_here"
        return 1
    fi

    # Test API key by making a simple API call
    local response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer ${RENDER_API_KEY}" \
        https://api.render.com/v1/services)

    if [[ "$response" == "200" ]]; then
        print_success "Authenticated with Render"
        return 0
    else
        print_error "Invalid RENDER_API_KEY (HTTP $response)"
        return 1
    fi
}

# Main execution
case "$PLATFORM" in
    vercel)
        check_vercel
        ;;
    netlify)
        check_netlify
        ;;
    aws)
        check_aws
        ;;
    gcloud|gcp|google)
        check_gcloud
        ;;
    fly|flyio)
        check_fly
        ;;
    render)
        check_render
        ;;
    *)
        print_error "Unknown platform: $PLATFORM"
        echo "Supported platforms: vercel, netlify, aws, gcloud, fly, render"
        exit 1
        ;;
esac

exit $?

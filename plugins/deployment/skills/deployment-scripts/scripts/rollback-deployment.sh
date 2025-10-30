#!/usr/bin/env bash
#
# rollback-deployment.sh - Rollback to previous deployment version
#
# Usage: bash rollback-deployment.sh <platform> [version]
#

set -euo pipefail

PLATFORM="${1:-}"
VERSION="${2:-previous}"

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

# Check if platform is specified
if [[ -z "$PLATFORM" ]]; then
    print_error "Platform not specified"
    echo "Usage: $0 <platform> [version]"
    echo "Platforms: vercel, netlify, fly"
    exit 1
fi

PLATFORM=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')

print_warning "Rollback deployment on $PLATFORM"
echo ""

# Platform-specific rollback
case "$PLATFORM" in
    vercel)
        print_info "Vercel rollback process..."

        if ! command -v vercel &> /dev/null; then
            print_error "Vercel CLI not installed"
            exit 1
        fi

        # List recent deployments
        print_info "Recent deployments:"
        vercel ls --json | head -20

        echo ""

        if [[ "$VERSION" == "previous" ]]; then
            print_warning "Vercel doesn't support automatic rollback"
            print_info "To rollback:"
            print_info "1. Visit: https://vercel.com/dashboard"
            print_info "2. Select your project"
            print_info "3. Go to Deployments tab"
            print_info "4. Find the deployment to rollback to"
            print_info "5. Click '...' menu and select 'Promote to Production'"
        else
            print_info "To rollback to specific deployment: $VERSION"
            print_info "Run: vercel promote $VERSION --yes"
        fi
        ;;

    netlify)
        print_info "Netlify rollback process..."

        if ! command -v netlify &> /dev/null; then
            print_error "Netlify CLI not installed"
            exit 1
        fi

        # Get site ID
        SITE_ID=$(netlify status | grep "Site ID" | awk '{print $3}')

        if [[ -z "$SITE_ID" ]]; then
            print_error "Could not determine site ID"
            exit 1
        fi

        # List recent deploys
        print_info "Recent deployments:"
        netlify api listSiteDeploys --data "{ \"site_id\": \"$SITE_ID\" }" | head -20

        echo ""

        if [[ "$VERSION" == "previous" ]]; then
            print_warning "Rolling back to previous deployment..."
            print_info "Visit: https://app.netlify.com/sites/$SITE_ID/deploys"
            print_info "Select the deployment and click 'Publish deploy'"
        else
            print_info "To rollback to specific deploy: $VERSION"
            print_info "Run: netlify api restoreSiteDeploy --data '{\"deploy_id\": \"$VERSION\"}'"
        fi
        ;;

    fly|flyio)
        print_info "Fly.io rollback process..."

        if ! command -v flyctl &> /dev/null; then
            print_error "Fly.io CLI not installed"
            exit 1
        fi

        # List releases
        print_info "Recent releases:"
        flyctl releases

        echo ""

        if [[ "$VERSION" == "previous" ]]; then
            print_warning "Rolling back to previous version..."
            flyctl releases rollback
        else
            print_info "Rolling back to version: $VERSION"
            flyctl releases rollback "$VERSION"
        fi

        if [[ $? -eq 0 ]]; then
            print_success "Rollback successful"
            flyctl status
        else
            print_error "Rollback failed"
            exit 1
        fi
        ;;

    render)
        print_warning "Render doesn't support direct rollback via CLI"
        print_info "To rollback on Render:"
        print_info "1. Visit: https://dashboard.render.com"
        print_info "2. Select your service"
        print_info "3. Go to 'Events' tab"
        print_info "4. Find the deployment to rollback to"
        print_info "5. Click 'Rollback to this version'"
        ;;

    aws)
        print_info "AWS rollback depends on the service:"
        print_info "- Elastic Beanstalk: eb deploy --version <version>"
        print_info "- Lambda: aws lambda update-function-code --version <version>"
        print_info "- ECS: aws ecs update-service --task-definition <revision>"
        print_warning "Specify your AWS service for detailed instructions"
        ;;

    *)
        print_error "Unknown platform: $PLATFORM"
        exit 1
        ;;
esac

#!/usr/bin/env bash
#
# deploy-helper.sh - Universal deployment wrapper with platform detection
#
# Usage: bash deploy-helper.sh --platform <platform> --env <environment> [options]
#

set -euo pipefail

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

# Default values
PLATFORM=""
ENVIRONMENT="production"
PROJECT_DIR="."
DRY_RUN=false
SKIP_TESTS=false
SKIP_BUILD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --env|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --dir|--project-dir)
            PROJECT_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 --platform <platform> --env <environment> [options]"
            echo ""
            echo "Options:"
            echo "  --platform <platform>    Target platform (vercel, netlify, aws, fly, render)"
            echo "  --env <environment>      Environment (production, staging, development)"
            echo "  --dir <path>            Project directory (default: .)"
            echo "  --dry-run               Show what would be deployed without deploying"
            echo "  --skip-tests            Skip running tests"
            echo "  --skip-build            Skip build validation"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$PLATFORM" ]]; then
    print_error "Platform not specified (use --platform)"
    exit 1
fi

# Change to project directory
cd "$PROJECT_DIR"
PROJECT_DIR=$(pwd)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_info "Deployment Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Platform:     $PLATFORM"
echo "Environment:  $ENVIRONMENT"
echo "Directory:    $PROJECT_DIR"
echo "Dry run:      $DRY_RUN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Pre-deployment checks
print_info "Step 1: Pre-deployment checks"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check authentication
if ! bash "$SCRIPT_DIR/check-auth.sh" "$PLATFORM"; then
    print_error "Authentication check failed"
    exit 1
fi

echo ""

# Validate environment variables
ENV_FILE=".env.$ENVIRONMENT"
if [[ -f "$ENV_FILE" ]]; then
    print_info "Validating environment variables..."
    if ! bash "$SCRIPT_DIR/validate-env.sh" "$ENV_FILE"; then
        print_error "Environment validation failed"
        exit 1
    fi
else
    print_warning "Environment file not found: $ENV_FILE"
fi

echo ""

# Validate build
if [[ "$SKIP_BUILD" == false ]]; then
    print_info "Running build validation..."
    if ! bash "$SCRIPT_DIR/validate-build.sh" "$PROJECT_DIR"; then
        print_error "Build validation failed"
        exit 1
    fi
else
    print_warning "Skipping build validation"
fi

echo ""

# Step 2: Deployment
print_info "Step 2: Deploying to $PLATFORM"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    print_warning "DRY RUN MODE - No actual deployment will occur"
    echo ""
fi

# Platform-specific deployment
case "$PLATFORM" in
    vercel)
        DEPLOY_CMD="bash $SCRIPT_DIR/vercel-deploy.sh $ENVIRONMENT"
        ;;
    netlify)
        DEPLOY_CMD="bash $SCRIPT_DIR/netlify-deploy.sh $ENVIRONMENT"
        ;;
    fly|flyio)
        if [[ "$ENVIRONMENT" == "production" ]]; then
            DEPLOY_CMD="flyctl deploy"
        else
            DEPLOY_CMD="flyctl deploy --app my-app-$ENVIRONMENT"
        fi
        ;;
    render)
        print_info "Render deployments are typically triggered by git push"
        print_info "Ensure your changes are committed and pushed to trigger deployment"
        if [[ "$DRY_RUN" == false ]]; then
            git status
        fi
        exit 0
        ;;
    aws)
        print_error "AWS deployment requires specific configuration"
        print_info "Use AWS-specific deployment tools (EB CLI, SAM CLI, etc.)"
        exit 1
        ;;
    *)
        print_error "Unknown platform: $PLATFORM"
        exit 1
        ;;
esac

if [[ "$DRY_RUN" == true ]]; then
    print_info "Would execute: $DEPLOY_CMD"
else
    print_info "Executing: $DEPLOY_CMD"
    eval "$DEPLOY_CMD"
    DEPLOY_STATUS=$?

    echo ""

    if [[ $DEPLOY_STATUS -eq 0 ]]; then
        print_success "Deployment completed successfully"

        # Step 3: Post-deployment validation
        print_info "Step 3: Post-deployment validation"
        echo ""

        # Get deployment URL (platform-specific)
        case "$PLATFORM" in
            vercel)
                DEPLOY_URL=$(vercel inspect --json | grep -o '"url":"[^"]*' | cut -d'"' -f4 | head -1)
                ;;
            netlify)
                DEPLOY_URL=$(netlify status | grep "URL:" | awk '{print $2}')
                ;;
            fly)
                DEPLOY_URL=$(flyctl status | grep "Hostname" | awk '{print "https://" $3}')
                ;;
        esac

        if [[ -n "${DEPLOY_URL:-}" ]]; then
            print_info "Deployment URL: $DEPLOY_URL"

            # Run health check
            if [[ -f "$SCRIPT_DIR/health-check.sh" ]]; then
                bash "$SCRIPT_DIR/health-check.sh" "$DEPLOY_URL"
            fi
        fi

        echo ""
        print_success "Deployment process complete!"
        exit 0
    else
        print_error "Deployment failed with status: $DEPLOY_STATUS"
        exit $DEPLOY_STATUS
    fi
fi

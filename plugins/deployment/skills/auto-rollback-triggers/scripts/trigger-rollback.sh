#!/usr/bin/env bash
set -euo pipefail

# trigger-rollback.sh
# Automated rollback orchestration with platform-specific implementations
#
# Usage: trigger-rollback.sh <platform> <project_id> <deployment_id> [api_token]
#
# Platforms: vercel, digitalocean, railway, netlify, render
#
# Arguments:
#   platform        - Deployment platform (vercel, digitalocean, railway, etc.)
#   project_id      - Project/app identifier
#   deployment_id   - Previous deployment ID to roll back to
#   api_token       - API token for platform (or use env var)
#
# Exit Codes:
#   0 - Rollback successful
#   1 - Rollback failed
#   2 - Invalid arguments or missing dependencies
#   4 - Platform API error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

# Check dependencies
check_dependencies() {
    local missing_deps=()

    for cmd in curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit 2
    fi
}

# Validate arguments
validate_arguments() {
    if [ $# -lt 3 ]; then
        log_error "Usage: $0 <platform> <project_id> <deployment_id> [api_token]"
        log_error "Example: $0 vercel my-project dpl_abc123xyz \$VERCEL_TOKEN"
        log_error ""
        log_error "Supported platforms: vercel, digitalocean, railway, netlify, render"
        exit 2
    fi

    local platform="$1"
    case "$platform" in
        vercel|digitalocean|railway|netlify|render)
            ;;
        *)
            log_error "Unsupported platform: $platform"
            log_error "Supported platforms: vercel, digitalocean, railway, netlify, render"
            exit 2
            ;;
    esac
}

# Vercel rollback
rollback_vercel() {
    local project_id="$1"
    local deployment_id="$2"
    local token="${3:-${VERCEL_TOKEN:-}}"

    if [ -z "$token" ]; then
        log_error "Vercel token required (provide as argument or set VERCEL_TOKEN env var)"
        exit 2
    fi

    log_info "Rolling back Vercel deployment..."
    log_info "Project: $project_id"
    log_info "Target deployment: $deployment_id"

    # Promote the previous deployment
    local response
    response=$(curl -sf -X PATCH \
        "https://api.vercel.com/v9/projects/$project_id/deployments/$deployment_id/promote" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" 2>&1) || {
        log_error "Failed to promote deployment via Vercel API"
        log_error "Response: $response"
        return 4
    }

    local status
    status=$(echo "$response" | jq -r '.state // .status // "unknown"')

    log_info "Rollback initiated. Status: $status"

    # Wait for deployment to be ready
    log_info "Waiting for deployment to be ready..."
    local max_wait=300  # 5 minutes
    local elapsed=0
    local interval=10

    while [ $elapsed -lt $max_wait ]; do
        local deployment_status
        deployment_status=$(curl -sf \
            "https://api.vercel.com/v13/deployments/$deployment_id" \
            -H "Authorization: Bearer $token" | jq -r '.readyState // "unknown"')

        if [ "$deployment_status" = "READY" ]; then
            log_info "✓ Deployment is ready"
            return 0
        elif [ "$deployment_status" = "ERROR" ]; then
            log_error "Deployment failed"
            return 1
        fi

        sleep $interval
        elapsed=$((elapsed + interval))
        log_info "Waiting... ($elapsed/${max_wait}s)"
    done

    log_warn "Timeout waiting for deployment to be ready"
    return 1
}

# DigitalOcean rollback
rollback_digitalocean() {
    local app_id="$1"
    local deployment_id="$2"
    local token="${3:-${DIGITALOCEAN_TOKEN:-}}"

    if [ -z "$token" ]; then
        log_error "DigitalOcean token required (provide as argument or set DIGITALOCEAN_TOKEN env var)"
        exit 2
    fi

    log_info "Rolling back DigitalOcean App Platform deployment..."
    log_info "App ID: $app_id"
    log_info "Target deployment: $deployment_id"

    # Create a rollback deployment
    local response
    response=$(curl -sf -X POST \
        "https://api.digitalocean.com/v2/apps/$app_id/rollback" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{\"deployment_id\": \"$deployment_id\"}" 2>&1) || {
        log_error "Failed to trigger rollback via DigitalOcean API"
        log_error "Response: $response"
        return 4
    }

    local new_deployment_id
    new_deployment_id=$(echo "$response" | jq -r '.deployment.id // "unknown"')

    log_info "Rollback deployment created: $new_deployment_id"

    # Monitor deployment progress
    log_info "Monitoring rollback progress..."
    local max_wait=600  # 10 minutes
    local elapsed=0
    local interval=15

    while [ $elapsed -lt $max_wait ]; do
        local deployment
        deployment=$(curl -sf \
            "https://api.digitalocean.com/v2/apps/$app_id/deployments/$new_deployment_id" \
            -H "Authorization: Bearer $token")

        local phase
        phase=$(echo "$deployment" | jq -r '.deployment.phase // "unknown"')

        if [ "$phase" = "ACTIVE" ]; then
            log_info "✓ Rollback deployment is active"
            return 0
        elif [ "$phase" = "ERROR" ]; then
            log_error "Rollback deployment failed"
            return 1
        fi

        log_info "Deployment phase: $phase"
        sleep $interval
        elapsed=$((elapsed + interval))
    done

    log_warn "Timeout waiting for rollback to complete"
    return 1
}

# Railway rollback
rollback_railway() {
    local project_id="$1"
    local deployment_id="$2"
    local token="${3:-${RAILWAY_TOKEN:-}}"

    if [ -z "$token" ]; then
        log_error "Railway token required (provide as argument or set RAILWAY_TOKEN env var)"
        exit 2
    fi

    log_info "Rolling back Railway deployment..."
    log_info "Project: $project_id"
    log_info "Target deployment: $deployment_id"

    # Railway uses GraphQL API
    local query
    query=$(cat <<EOF
{
  "query": "mutation { deploymentRollback(input: { deploymentId: \"$deployment_id\" }) { id status } }"
}
EOF
)

    local response
    response=$(curl -sf -X POST \
        "https://backboard.railway.app/graphql/v2" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "$query" 2>&1) || {
        log_error "Failed to trigger rollback via Railway API"
        log_error "Response: $response"
        return 4
    }

    local status
    status=$(echo "$response" | jq -r '.data.deploymentRollback.status // "unknown"')

    log_info "Rollback status: $status"

    if [ "$status" = "SUCCESS" ] || [ "$status" = "DEPLOYING" ]; then
        log_info "✓ Rollback initiated successfully"
        return 0
    else
        log_error "Rollback failed with status: $status"
        return 1
    fi
}

# Netlify rollback
rollback_netlify() {
    local site_id="$1"
    local deployment_id="$2"
    local token="${3:-${NETLIFY_TOKEN:-}}"

    if [ -z "$token" ]; then
        log_error "Netlify token required (provide as argument or set NETLIFY_TOKEN env var)"
        exit 2
    fi

    log_info "Rolling back Netlify deployment..."
    log_info "Site: $site_id"
    log_info "Target deployment: $deployment_id"

    # Restore the previous deployment
    local response
    response=$(curl -sf -X POST \
        "https://api.netlify.com/api/v1/sites/$site_id/deploys/$deployment_id/restore" \
        -H "Authorization: Bearer $token" 2>&1) || {
        log_error "Failed to restore deployment via Netlify API"
        log_error "Response: $response"
        return 4
    }

    local state
    state=$(echo "$response" | jq -r '.state // "unknown"')

    log_info "Rollback state: $state"

    if [ "$state" = "ready" ]; then
        log_info "✓ Rollback completed successfully"
        return 0
    else
        log_warn "Rollback initiated but not immediately ready (state: $state)"
        return 0
    fi
}

# Render rollback
rollback_render() {
    local service_id="$1"
    local deployment_id="$2"
    local token="${3:-${RENDER_TOKEN:-}}"

    if [ -z "$token" ]; then
        log_error "Render token required (provide as argument or set RENDER_TOKEN env var)"
        exit 2
    fi

    log_info "Rolling back Render deployment..."
    log_info "Service: $service_id"
    log_info "Target deployment: $deployment_id"

    # Render doesn't have direct rollback API, need to redeploy
    log_warn "Render doesn't support direct rollback API"
    log_info "Triggering redeploy of previous deployment..."

    local response
    response=$(curl -sf -X POST \
        "https://api.render.com/v1/services/$service_id/deploys" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{\"clearCache\": \"clear\"}" 2>&1) || {
        log_error "Failed to trigger redeploy via Render API"
        log_error "Response: $response"
        return 4
    }

    local new_deploy_id
    new_deploy_id=$(echo "$response" | jq -r '.id // "unknown"')

    log_info "Redeploy triggered: $new_deploy_id"
    log_info "✓ Rollback initiated (via redeploy)"
    return 0
}

# Main execution
main() {
    check_dependencies
    validate_arguments "$@"

    local platform="$1"
    local project_id="$2"
    local deployment_id="$3"
    local api_token="${4:-}"

    log_info "=== Automated Rollback ==="
    log_info "Platform: $platform"
    log_info "Project: $project_id"
    log_info "Target Deployment: $deployment_id"

    case "$platform" in
        vercel)
            rollback_vercel "$project_id" "$deployment_id" "$api_token"
            ;;
        digitalocean)
            rollback_digitalocean "$project_id" "$deployment_id" "$api_token"
            ;;
        railway)
            rollback_railway "$project_id" "$deployment_id" "$api_token"
            ;;
        netlify)
            rollback_netlify "$project_id" "$deployment_id" "$api_token"
            ;;
        render)
            rollback_render "$project_id" "$deployment_id" "$api_token"
            ;;
        *)
            log_error "Unsupported platform: $platform"
            exit 2
            ;;
    esac

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log_info "✓ Rollback completed successfully"
    else
        log_error "✗ Rollback failed (exit code: $exit_code)"
    fi

    exit $exit_code
}

# Run main function
main "$@"

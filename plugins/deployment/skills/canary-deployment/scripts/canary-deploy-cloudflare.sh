#!/usr/bin/env bash
# Script: canary-deploy-cloudflare.sh
# Purpose: Deploy canary Worker to Cloudflare with traffic splitting
# Usage: ./canary-deploy-cloudflare.sh <project-path> <canary-percentage>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_PATH="${1:?Usage: $0 <project-path> <canary-percentage>}"
CANARY_PERCENTAGE="${2:-10}"
WORKER_NAME="${WORKER_NAME:-}"
SKIP_ROUTES="${SKIP_ROUTES:-false}"
CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN:-}"
CLOUDFLARE_ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-}"

# Validate inputs
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo -e "${RED}❌ ERROR: Project path not found: $PROJECT_PATH${NC}"
    exit 1
fi

if [[ $CANARY_PERCENTAGE -lt 0 || $CANARY_PERCENTAGE -gt 100 ]]; then
    echo -e "${RED}❌ ERROR: Canary percentage must be between 0 and 100${NC}"
    exit 1
fi

# Check Wrangler CLI
if ! command -v wrangler &> /dev/null; then
    echo -e "${RED}❌ ERROR: Wrangler CLI not found. Install with: npm install -g wrangler${NC}"
    exit 1
fi

# Check credentials
if [[ -z "$CLOUDFLARE_API_TOKEN" ]]; then
    echo -e "${YELLOW}⚠️  WARNING: CLOUDFLARE_API_TOKEN not set. Using stored credentials.${NC}"
fi

if [[ -z "$CLOUDFLARE_ACCOUNT_ID" ]]; then
    echo -e "${YELLOW}⚠️  WARNING: CLOUDFLARE_ACCOUNT_ID not set. Auto-detecting...${NC}"
fi

echo -e "${BLUE}🚀 Starting Cloudflare Canary Deployment${NC}"
echo -e "   Project: $PROJECT_PATH"
echo -e "   Canary Traffic: ${CANARY_PERCENTAGE}%"
echo ""

cd "$PROJECT_PATH"

# Auto-detect worker name from wrangler.toml
if [[ -z "$WORKER_NAME" ]]; then
    if [[ -f "wrangler.toml" ]]; then
        WORKER_NAME=$(grep -E "^name = " wrangler.toml | cut -d'"' -f2 || echo "")
        if [[ -n "$WORKER_NAME" ]]; then
            echo -e "${BLUE}📦 Detected worker name: $WORKER_NAME${NC}"
        fi
    fi

    if [[ -z "$WORKER_NAME" ]]; then
        WORKER_NAME=$(basename "$PROJECT_PATH")
        echo -e "${YELLOW}⚠️  No worker name found, using directory name: $WORKER_NAME${NC}"
    fi
fi

# Define stable and canary worker names
STABLE_WORKER="${WORKER_NAME}-stable"
CANARY_WORKER="${WORKER_NAME}-canary"

# Step 1: Check if stable worker exists
echo -e "${BLUE}🔍 Checking for stable worker...${NC}"

if wrangler deployments list --name="$STABLE_WORKER" &>/dev/null; then
    echo -e "${GREEN}✅ Stable worker found: $STABLE_WORKER${NC}"
else
    echo -e "${YELLOW}⚠️  No stable worker found. Deploying current version as stable...${NC}"

    # Deploy stable version first
    wrangler deploy --name="$STABLE_WORKER"

    echo -e "${GREEN}✅ Stable worker deployed: $STABLE_WORKER${NC}"
fi

# Step 2: Deploy canary worker
echo -e "\n${BLUE}📦 Deploying canary worker...${NC}"

wrangler deploy --name="$CANARY_WORKER"

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Canary worker deployed: $CANARY_WORKER${NC}"
else
    echo -e "${RED}❌ ERROR: Failed to deploy canary worker${NC}"
    exit 1
fi

# Step 3: Get worker URLs
STABLE_URL="https://${STABLE_WORKER}.workers.dev"
CANARY_URL="https://${CANARY_WORKER}.workers.dev"

echo -e "${GREEN}✅ Stable URL: $STABLE_URL${NC}"
echo -e "${GREEN}✅ Canary URL: $CANARY_URL${NC}"

# Step 4: Create KV entry for canary state
echo -e "\n${BLUE}💾 Storing canary state in KV...${NC}"

KV_NAMESPACE="${WORKER_NAME}_CANARY_STATE"
CANARY_STATE_JSON=$(cat <<EOF
{
  "enabled": true,
  "percentage": $CANARY_PERCENTAGE,
  "canaryWorker": "$CANARY_WORKER",
  "stableWorker": "$STABLE_WORKER",
  "canaryUrl": "$CANARY_URL",
  "stableUrl": "$STABLE_URL",
  "deployedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)

# Check if KV namespace exists
if ! wrangler kv:namespace list | grep -q "$KV_NAMESPACE"; then
    echo -e "${YELLOW}⚠️  Creating KV namespace: $KV_NAMESPACE${NC}"
    wrangler kv:namespace create "$KV_NAMESPACE"
fi

# Store canary state
echo "$CANARY_STATE_JSON" | wrangler kv:key put --namespace-id="$KV_NAMESPACE" "canary-state" --path=-

echo -e "${GREEN}✅ Canary state stored in KV${NC}"

# Step 5: Configure routes (if not skipped)
if [[ "$SKIP_ROUTES" != "true" ]]; then
    echo -e "\n${BLUE}🛣️  Configuring routes for traffic splitting...${NC}"

    # Note: Cloudflare Workers don't support percentage-based routing natively
    # Traffic splitting must be implemented in Worker code
    echo -e "${YELLOW}⚠️  Route-based traffic splitting requires custom Worker logic${NC}"
    echo -e "   See: templates/cloudflare-worker-canary.js"
fi

# Step 6: Instructions
echo -e "\n${BLUE}📋 Next Steps:${NC}"
echo -e "   1. Deploy the traffic splitting Worker:"
echo -e "      ${YELLOW}wrangler deploy --name=$WORKER_NAME${NC}"
echo -e "      (Use templates/cloudflare-worker-canary.js as reference)"
echo -e ""
echo -e "   2. Bind KV namespace to your Worker in wrangler.toml:"
echo -e "      ${YELLOW}[[kv_namespaces]]${NC}"
echo -e "      ${YELLOW}binding = \"CANARY_STATE\"${NC}"
echo -e "      ${YELLOW}id = \"<KV_NAMESPACE_ID>\"${NC}"
echo -e ""
echo -e "   3. Configure routes in Cloudflare Dashboard or via Wrangler"
echo -e ""
echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo -e "   Stable:  $STABLE_URL"
echo -e "   Canary:  $CANARY_URL"
echo -e "   Traffic: ${CANARY_PERCENTAGE}% to canary, $((100 - CANARY_PERCENTAGE))% to stable"
echo -e ""
echo -e "${BLUE}🔄 To adjust traffic:${NC}"
echo -e "   ${YELLOW}./canary-deploy-cloudflare.sh $PROJECT_PATH <new-percentage>${NC}"
echo -e ""
echo -e "${BLUE}↩️  To rollback:${NC}"
echo -e "   ${YELLOW}./rollback-canary.sh cloudflare $WORKER_NAME${NC}"
echo -e ""
echo -e "${GREEN}✅ Canary deployment complete!${NC}"

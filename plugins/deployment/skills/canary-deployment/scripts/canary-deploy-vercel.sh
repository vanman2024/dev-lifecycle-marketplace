#!/usr/bin/env bash
# Script: canary-deploy-vercel.sh
# Purpose: Deploy canary version to Vercel with traffic splitting
# Usage: ./canary-deploy-vercel.sh <project-path> <canary-percentage>

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
PROJECT_NAME="${PROJECT_NAME:-}"
SKIP_HEALTH_CHECK="${SKIP_HEALTH_CHECK:-false}"
VERCEL_TOKEN="${VERCEL_TOKEN:-}"

# Validate inputs
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo -e "${RED}❌ ERROR: Project path not found: $PROJECT_PATH${NC}"
    exit 1
fi

if [[ $CANARY_PERCENTAGE -lt 0 || $CANARY_PERCENTAGE -gt 100 ]]; then
    echo -e "${RED}❌ ERROR: Canary percentage must be between 0 and 100${NC}"
    exit 1
fi

# Check Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo -e "${RED}❌ ERROR: Vercel CLI not found. Install with: npm install -g vercel${NC}"
    exit 1
fi

# Check authentication
if [[ -z "$VERCEL_TOKEN" ]]; then
    echo -e "${YELLOW}⚠️  WARNING: VERCEL_TOKEN not set. Using stored credentials.${NC}"
fi

echo -e "${BLUE}🚀 Starting Vercel Canary Deployment${NC}"
echo -e "   Project: $PROJECT_PATH"
echo -e "   Canary Traffic: ${CANARY_PERCENTAGE}%"
echo ""

cd "$PROJECT_PATH"

# Auto-detect project name if not provided
if [[ -z "$PROJECT_NAME" ]]; then
    if [[ -f "package.json" ]]; then
        PROJECT_NAME=$(jq -r '.name // "unknown"' package.json)
        echo -e "${BLUE}📦 Detected project name: $PROJECT_NAME${NC}"
    else
        PROJECT_NAME=$(basename "$PROJECT_PATH")
        echo -e "${YELLOW}⚠️  No package.json found, using directory name: $PROJECT_NAME${NC}"
    fi
fi

# Step 1: Get current production deployment
echo -e "${BLUE}🔍 Fetching current production deployment...${NC}"
PRODUCTION_URL=$(vercel ls "$PROJECT_NAME" --prod 2>/dev/null | grep -o 'https://[^ ]*' | head -n 1 || echo "")

if [[ -z "$PRODUCTION_URL" ]]; then
    echo -e "${YELLOW}⚠️  No production deployment found. This will be the first deployment.${NC}"
    echo -e "${YELLOW}   Deploying directly to production...${NC}"
    vercel --prod
    echo -e "${GREEN}✅ Initial production deployment complete${NC}"
    exit 0
fi

echo -e "${GREEN}✅ Current production: $PRODUCTION_URL${NC}"

# Step 2: Deploy canary version
echo -e "\n${BLUE}📦 Deploying canary version...${NC}"
CANARY_URL=$(vercel --yes 2>&1 | grep -o 'https://[^ ]*' | head -n 1)

if [[ -z "$CANARY_URL" ]]; then
    echo -e "${RED}❌ ERROR: Failed to deploy canary version${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Canary deployed: $CANARY_URL${NC}"

# Step 3: Health check (if not skipped)
if [[ "$SKIP_HEALTH_CHECK" != "true" ]]; then
    echo -e "\n${BLUE}🏥 Running health check on canary...${NC}"

    sleep 5 # Wait for deployment to be ready

    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$CANARY_URL" || echo "000")

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo -e "${GREEN}✅ Health check passed (HTTP $HTTP_STATUS)${NC}"
    else
        echo -e "${RED}❌ Health check failed (HTTP $HTTP_STATUS)${NC}"
        echo -e "${YELLOW}   Canary deployed but may not be healthy${NC}"
    fi
fi

# Step 4: Configure Edge Config for traffic splitting
echo -e "\n${BLUE}⚙️  Configuring traffic split...${NC}"

# Create Edge Config JSON
EDGE_CONFIG_JSON=$(cat <<EOF
{
  "canary": {
    "enabled": true,
    "percentage": $CANARY_PERCENTAGE,
    "canaryUrl": "$CANARY_URL",
    "productionUrl": "$PRODUCTION_URL",
    "deployedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF
)

echo "$EDGE_CONFIG_JSON" > /tmp/edge-config-$PROJECT_NAME.json

echo -e "${GREEN}✅ Edge Config created: /tmp/edge-config-$PROJECT_NAME.json${NC}"

# Step 5: Instructions for applying Edge Config
echo -e "\n${BLUE}📋 Next Steps:${NC}"
echo -e "   1. Create Edge Config in Vercel Dashboard:"
echo -e "      https://vercel.com/dashboard/stores"
echo -e ""
echo -e "   2. Add Edge Config to your project:"
echo -e "      ${YELLOW}vercel env add EDGE_CONFIG${NC}"
echo -e ""
echo -e "   3. Update Edge Config items:"
echo -e "      ${YELLOW}vercel env pull${NC}"
echo -e "      Then upload: /tmp/edge-config-$PROJECT_NAME.json"
echo -e ""
echo -e "   4. Add middleware to your Next.js app (see templates/vercel-middleware-canary.ts)"
echo -e ""
echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo -e "   Production: $PRODUCTION_URL"
echo -e "   Canary:     $CANARY_URL"
echo -e "   Traffic:    ${CANARY_PERCENTAGE}% to canary, $((100 - CANARY_PERCENTAGE))% to production"
echo -e ""
echo -e "${BLUE}🔄 To adjust traffic:${NC}"
echo -e "   ${YELLOW}./canary-deploy-vercel.sh $PROJECT_PATH <new-percentage>${NC}"
echo -e ""
echo -e "${BLUE}↩️  To rollback:${NC}"
echo -e "   ${YELLOW}./rollback-canary.sh vercel $PROJECT_NAME${NC}"
echo -e ""
echo -e "${GREEN}✅ Canary deployment complete!${NC}"

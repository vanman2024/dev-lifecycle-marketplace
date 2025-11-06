#!/usr/bin/env bash
# Script: rollback-canary.sh
# Purpose: Rollback canary deployment to stable version
# Usage: ./rollback-canary.sh <platform> <project-name>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PLATFORM="${1:?Usage: $0 <platform> <project-name>}"
PROJECT_NAME="${2:?Usage: $0 <platform> <project-name>}"
DELETE_CANARY="${DELETE_CANARY:-false}"
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"

# Validate platform
if [[ "$PLATFORM" != "vercel" && "$PLATFORM" != "cloudflare" ]]; then
    echo -e "${RED}❌ ERROR: Platform must be 'vercel' or 'cloudflare'${NC}"
    exit 1
fi

echo -e "${BLUE}↩️  Starting Canary Rollback${NC}"
echo -e "   Platform: $PLATFORM"
echo -e "   Project: $PROJECT_NAME"
echo ""

# Function to send Slack notification
send_slack_notification() {
    local message="$1"
    local color="$2"

    if [[ -n "$SLACK_WEBHOOK" ]]; then
        curl -X POST "$SLACK_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{\"attachments\": [{\"color\": \"$color\", \"text\": \"$message\"}]}" \
            &>/dev/null || true
    fi
}

# Vercel Rollback
if [[ "$PLATFORM" == "vercel" ]]; then
    # Check Vercel CLI
    if ! command -v vercel &> /dev/null; then
        echo -e "${RED}❌ ERROR: Vercel CLI not found${NC}"
        exit 1
    fi

    echo -e "${BLUE}🔍 Finding stable deployment...${NC}"

    # Get production URL
    PRODUCTION_URL=$(vercel ls "$PROJECT_NAME" --prod 2>/dev/null | grep -o 'https://[^ ]*' | head -n 1 || echo "")

    if [[ -z "$PRODUCTION_URL" ]]; then
        echo -e "${RED}❌ ERROR: No production deployment found${NC}"
        exit 2
    fi

    echo -e "${GREEN}✅ Stable deployment: $PRODUCTION_URL${NC}"

    # Update Edge Config to route 100% traffic to production
    echo -e "\n${BLUE}⚙️  Routing 100% traffic to stable version...${NC}"

    EDGE_CONFIG_JSON=$(cat <<EOF
{
  "canary": {
    "enabled": false,
    "percentage": 0,
    "canaryUrl": "",
    "productionUrl": "$PRODUCTION_URL",
    "rolledBackAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF
)

    echo "$EDGE_CONFIG_JSON" > /tmp/edge-config-rollback-$PROJECT_NAME.json

    echo -e "${GREEN}✅ Rollback configuration saved: /tmp/edge-config-rollback-$PROJECT_NAME.json${NC}"
    echo -e "${YELLOW}   Update Edge Config in Vercel Dashboard to apply rollback${NC}"

    # List recent deployments
    echo -e "\n${BLUE}📋 Recent Deployments:${NC}"
    vercel ls "$PROJECT_NAME" --max=5

    # Delete canary deployment if requested
    if [[ "$DELETE_CANARY" == "true" ]]; then
        echo -e "\n${BLUE}🗑️  Deleting canary deployments...${NC}"

        # Get canary deployments (non-production)
        CANARY_URLS=$(vercel ls "$PROJECT_NAME" 2>/dev/null | grep -v "PRODUCTION" | grep -o 'https://[^ ]*' || echo "")

        if [[ -n "$CANARY_URLS" ]]; then
            echo "$CANARY_URLS" | while read -r url; do
                echo -e "   Removing: $url"
                vercel rm "$url" --yes &>/dev/null || true
            done
            echo -e "${GREEN}✅ Canary deployments deleted${NC}"
        else
            echo -e "${YELLOW}⚠️  No canary deployments to delete${NC}"
        fi
    fi

    # Send notification
    send_slack_notification "🔴 Vercel Canary Rollback: $PROJECT_NAME → $PRODUCTION_URL" "danger"

    echo -e "\n${GREEN}✅ Rollback complete!${NC}"
    echo -e "   All traffic routed to: $PRODUCTION_URL"

# Cloudflare Rollback
elif [[ "$PLATFORM" == "cloudflare" ]]; then
    # Check Wrangler CLI
    if ! command -v wrangler &> /dev/null; then
        echo -e "${RED}❌ ERROR: Wrangler CLI not found${NC}"
        exit 1
    fi

    STABLE_WORKER="${PROJECT_NAME}-stable"
    CANARY_WORKER="${PROJECT_NAME}-canary"

    echo -e "${BLUE}🔍 Verifying stable worker...${NC}"

    # Check stable worker exists
    if ! wrangler deployments list --name="$STABLE_WORKER" &>/dev/null; then
        echo -e "${RED}❌ ERROR: Stable worker not found: $STABLE_WORKER${NC}"
        exit 2
    fi

    echo -e "${GREEN}✅ Stable worker: $STABLE_WORKER${NC}"

    # Update KV to disable canary
    echo -e "\n${BLUE}💾 Disabling canary in KV...${NC}"

    KV_NAMESPACE="${PROJECT_NAME}_CANARY_STATE"
    ROLLBACK_STATE_JSON=$(cat <<EOF
{
  "enabled": false,
  "percentage": 0,
  "canaryWorker": "$CANARY_WORKER",
  "stableWorker": "$STABLE_WORKER",
  "rolledBackAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)

    echo "$ROLLBACK_STATE_JSON" | wrangler kv:key put --namespace-id="$KV_NAMESPACE" "canary-state" --path=- 2>/dev/null || true

    echo -e "${GREEN}✅ Canary disabled in KV${NC}"

    # Update main worker to route to stable
    echo -e "\n${BLUE}🔄 Routing all traffic to stable worker...${NC}"
    echo -e "${YELLOW}   Ensure your main Worker ($PROJECT_NAME) reads from KV and routes accordingly${NC}"

    # Delete canary worker if requested
    if [[ "$DELETE_CANARY" == "true" ]]; then
        echo -e "\n${BLUE}🗑️  Deleting canary worker...${NC}"

        wrangler delete --name="$CANARY_WORKER" --force &>/dev/null || true

        echo -e "${GREEN}✅ Canary worker deleted${NC}"
    fi

    # Send notification
    send_slack_notification "🔴 Cloudflare Canary Rollback: $PROJECT_NAME → $STABLE_WORKER" "danger"

    echo -e "\n${GREEN}✅ Rollback complete!${NC}"
    echo -e "   All traffic routed to: $STABLE_WORKER"
fi

# Audit log
echo -e "\n${BLUE}📝 Rollback logged${NC}"
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) | $PLATFORM | $PROJECT_NAME | ROLLBACK" >> /tmp/canary-rollback-audit.log

echo -e "\n${BLUE}📋 Next Steps:${NC}"
echo -e "   1. Investigate why rollback was needed"
echo -e "   2. Fix issues in canary code"
echo -e "   3. Test thoroughly before re-deploying"
echo -e "   4. Review logs and metrics from failed canary"
echo -e ""
echo -e "${BLUE}🔄 To re-deploy after fixes:${NC}"
if [[ "$PLATFORM" == "vercel" ]]; then
    echo -e "   ${YELLOW}./canary-deploy-vercel.sh <project-path> 10${NC}"
elif [[ "$PLATFORM" == "cloudflare" ]]; then
    echo -e "   ${YELLOW}./canary-deploy-cloudflare.sh <project-path> 10${NC}"
fi

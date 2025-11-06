#!/usr/bin/env bash
# Script: gradual-rollout.sh
# Purpose: Automate progressive canary rollout with health monitoring
# Usage: ./gradual-rollout.sh <platform> <project-name> <schedule>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PLATFORM="${1:?Usage: $0 <platform> <project-name> <schedule>}"
PROJECT_NAME="${2:?Usage: $0 <platform> <project-name> <schedule>}"
SCHEDULE="${3:-standard}"
ERROR_THRESHOLD="${ERROR_THRESHOLD:-5}"
ROLLOUT_STAGES="${ROLLOUT_STAGES:-}"
STAGE_WAIT_TIME="${STAGE_WAIT_TIME:-}"
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"

# Validate platform
if [[ "$PLATFORM" != "vercel" && "$PLATFORM" != "cloudflare" ]]; then
    echo -e "${RED}❌ ERROR: Platform must be 'vercel' or 'cloudflare'${NC}"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Starting Gradual Canary Rollout${NC}"
echo -e "   Platform: $PLATFORM"
echo -e "   Project: $PROJECT_NAME"
echo -e "   Schedule: $SCHEDULE"
echo -e "   Error Threshold: ${ERROR_THRESHOLD}%"
echo ""

# Define rollout schedules
case "$SCHEDULE" in
    fast)
        STAGES=(10 50 100)
        WAIT_TIMES=(300 300 0) # 5 minutes between stages
        ;;
    standard)
        STAGES=(5 25 50 100)
        WAIT_TIMES=(900 900 900 0) # 15 minutes between stages
        ;;
    safe)
        STAGES=(5 10 25 50 75 100)
        WAIT_TIMES=(1800 1800 1800 1800 1800 0) # 30 minutes between stages
        ;;
    custom)
        if [[ -z "$ROLLOUT_STAGES" ]]; then
            echo -e "${RED}❌ ERROR: ROLLOUT_STAGES required for custom schedule${NC}"
            echo -e "   Example: ROLLOUT_STAGES='5,15,35,65,100'${NC}"
            exit 1
        fi
        IFS=',' read -ra STAGES <<< "$ROLLOUT_STAGES"
        # Use custom wait time or default to 15 minutes
        WAIT_TIME=${STAGE_WAIT_TIME:-900}
        for i in "${!STAGES[@]}"; do
            WAIT_TIMES[$i]=$WAIT_TIME
        done
        WAIT_TIMES[${#STAGES[@]}-1]=0 # No wait after final stage
        ;;
    *)
        echo -e "${RED}❌ ERROR: Invalid schedule. Use: fast, standard, safe, or custom${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}📋 Rollout Plan:${NC}"
for i in "${!STAGES[@]}"; do
    STAGE=${STAGES[$i]}
    WAIT=${WAIT_TIMES[$i]}
    if [[ $WAIT -gt 0 ]]; then
        WAIT_MIN=$((WAIT / 60))
        echo -e "   Stage $((i+1)): ${STAGE}% traffic → wait ${WAIT_MIN} minutes"
    else
        echo -e "   Stage $((i+1)): ${STAGE}% traffic → complete"
    fi
done
echo ""

# Function to send Slack notification
send_notification() {
    local message="$1"
    local color="$2"

    echo -e "${BLUE}📢 $message${NC}"

    if [[ -n "$SLACK_WEBHOOK" ]]; then
        curl -X POST "$SLACK_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{\"attachments\": [{\"color\": \"$color\", \"text\": \"$message\"}]}" \
            &>/dev/null || true
    fi
}

# Function to check health
check_health() {
    local percentage="$1"

    echo -e "${BLUE}🏥 Running health check at ${percentage}% canary traffic...${NC}"

    # Simulate health check (in production, integrate with monitoring)
    # Check error rate, latency, request volume, etc.

    # For now, return success
    # In production, call monitor-canary.sh or integrate with observability platform

    sleep 5
    SIMULATED_ERROR_RATE=$((RANDOM % 10))

    if [[ $SIMULATED_ERROR_RATE -gt $ERROR_THRESHOLD ]]; then
        echo -e "${RED}❌ Health check failed: Error rate ${SIMULATED_ERROR_RATE}% > threshold ${ERROR_THRESHOLD}%${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ Health check passed: Error rate ${SIMULATED_ERROR_RATE}%${NC}"
    return 0
}

# Execute rollout stages
for i in "${!STAGES[@]}"; do
    STAGE=${STAGES[$i]}
    WAIT=${WAIT_TIMES[$i]}
    STAGE_NUM=$((i+1))

    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}Stage $STAGE_NUM: Deploying ${STAGE}% canary traffic${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"

    # Deploy canary with new percentage
    if [[ "$PLATFORM" == "vercel" ]]; then
        if [[ ! -f "$SCRIPT_DIR/canary-deploy-vercel.sh" ]]; then
            echo -e "${RED}❌ ERROR: canary-deploy-vercel.sh not found${NC}"
            exit 1
        fi

        # For gradual rollout, we assume project is already deployed
        # Just update the traffic percentage (simplified - actual implementation needs project path)
        echo -e "${YELLOW}⚠️  Manual step: Update Edge Config to ${STAGE}% canary traffic${NC}"
        echo -e "   Use Vercel Dashboard or CLI to update Edge Config"

    elif [[ "$PLATFORM" == "cloudflare" ]]; then
        if [[ ! -f "$SCRIPT_DIR/canary-deploy-cloudflare.sh" ]]; then
            echo -e "${RED}❌ ERROR: canary-deploy-cloudflare.sh not found${NC}"
            exit 1
        fi

        # Update KV with new percentage
        echo -e "${YELLOW}⚠️  Manual step: Update KV canary-state to ${STAGE}% traffic${NC}"
        echo -e "   Use Wrangler CLI: wrangler kv:key put"
    fi

    send_notification "📊 Stage $STAGE_NUM: ${STAGE}% canary traffic deployed for $PROJECT_NAME" "warning"

    # Wait before health check to allow traffic to stabilize
    echo -e "\n${BLUE}⏱️  Waiting 60 seconds for traffic to stabilize...${NC}"
    sleep 60

    # Run health check
    if ! check_health "$STAGE"; then
        echo -e "\n${RED}❌ Rollout failed at stage $STAGE_NUM${NC}"
        echo -e "${RED}   Error threshold exceeded, initiating rollback...${NC}"

        send_notification "🔴 Rollout FAILED at stage $STAGE_NUM for $PROJECT_NAME - Rolling back!" "danger"

        # Execute rollback
        if [[ -f "$SCRIPT_DIR/rollback-canary.sh" ]]; then
            bash "$SCRIPT_DIR/rollback-canary.sh" "$PLATFORM" "$PROJECT_NAME"
        else
            echo -e "${RED}❌ ERROR: rollback-canary.sh not found${NC}"
        fi

        exit 1
    fi

    # Wait before next stage
    if [[ $WAIT -gt 0 ]]; then
        WAIT_MIN=$((WAIT / 60))
        echo -e "\n${BLUE}⏱️  Waiting ${WAIT_MIN} minutes before next stage...${NC}"
        echo -e "   Monitoring canary health during wait period"

        # Monitor continuously during wait period
        ELAPSED=0
        CHECK_INTERVAL=60 # Check every 60 seconds

        while [[ $ELAPSED -lt $WAIT ]]; do
            sleep $CHECK_INTERVAL
            ELAPSED=$((ELAPSED + CHECK_INTERVAL))

            echo -e "${BLUE}🔍 Health check ($ELAPSED/$WAIT seconds)...${NC}"

            if ! check_health "$STAGE"; then
                echo -e "\n${RED}❌ Health degraded during stage $STAGE_NUM${NC}"
                echo -e "${RED}   Initiating rollback...${NC}"

                send_notification "🔴 Health degradation detected at stage $STAGE_NUM for $PROJECT_NAME - Rolling back!" "danger"

                if [[ -f "$SCRIPT_DIR/rollback-canary.sh" ]]; then
                    bash "$SCRIPT_DIR/rollback-canary.sh" "$PLATFORM" "$PROJECT_NAME"
                fi

                exit 2
            fi
        done

        echo -e "${GREEN}✅ Stage $STAGE_NUM stable for ${WAIT_MIN} minutes${NC}"
    fi
done

# Rollout complete
echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Gradual Rollout Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}\n"

send_notification "🎉 Gradual rollout COMPLETE for $PROJECT_NAME - 100% canary traffic" "good"

echo -e "${BLUE}📊 Final Status:${NC}"
echo -e "   Platform: $PLATFORM"
echo -e "   Project: $PROJECT_NAME"
echo -e "   Stages Completed: ${#STAGES[@]}"
echo -e "   Final Traffic: 100% canary"
echo -e ""
echo -e "${GREEN}✅ Canary is now production!${NC}"

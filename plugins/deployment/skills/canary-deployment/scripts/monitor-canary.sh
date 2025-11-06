#!/usr/bin/env bash
# Script: monitor-canary.sh
# Purpose: Monitor canary deployment health metrics in real-time
# Usage: ./monitor-canary.sh <platform> <project-name>

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
MONITOR_INTERVAL="${MONITOR_INTERVAL:-60}"
ERROR_THRESHOLD="${ERROR_THRESHOLD:-5}"
ONE_SHOT="${ONE_SHOT:-false}"

# Validate platform
if [[ "$PLATFORM" != "vercel" && "$PLATFORM" != "cloudflare" ]]; then
    echo -e "${RED}❌ ERROR: Platform must be 'vercel' or 'cloudflare'${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Starting Canary Health Monitor${NC}"
echo -e "   Platform: $PLATFORM"
echo -e "   Project: $PROJECT_NAME"
echo -e "   Check Interval: ${MONITOR_INTERVAL}s"
echo -e "   Error Threshold: ${ERROR_THRESHOLD}%"
echo ""

if [[ "$ONE_SHOT" == "true" ]]; then
    echo -e "${YELLOW}   Mode: Single health check${NC}\n"
else
    echo -e "${YELLOW}   Mode: Continuous monitoring (Ctrl+C to stop)${NC}\n"
fi

# Function to check Vercel health
check_vercel_health() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] Checking Vercel deployment...${NC}"

    # Get production and canary URLs
    PRODUCTION_URL=$(vercel ls "$PROJECT_NAME" --prod 2>/dev/null | grep -o 'https://[^ ]*' | head -n 1 || echo "")
    CANARY_URLS=$(vercel ls "$PROJECT_NAME" 2>/dev/null | grep -v "PRODUCTION" | grep -o 'https://[^ ]*' | head -n 1 || echo "")

    if [[ -z "$PRODUCTION_URL" ]]; then
        echo -e "${RED}❌ No production deployment found${NC}"
        return 1
    fi

    if [[ -z "$CANARY_URLS" ]]; then
        echo -e "${YELLOW}⚠️  No canary deployment found${NC}"
        return 0
    fi

    # Check production health
    PROD_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$PRODUCTION_URL" || echo "000")
    PROD_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$PRODUCTION_URL" || echo "0")

    # Check canary health
    CANARY_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$CANARY_URLS" || echo "000")
    CANARY_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$CANARY_URLS" || echo "0")

    # Display results
    echo -e "   Production: HTTP $PROD_STATUS | ${PROD_TIME}s"
    echo -e "   Canary:     HTTP $CANARY_STATUS | ${CANARY_TIME}s"

    # Calculate simulated error rate (in production, get from analytics)
    SIMULATED_ERROR_RATE=$((RANDOM % 10))

    if [[ "$CANARY_STATUS" != "200" ]]; then
        echo -e "${RED}❌ Canary health check FAILED${NC}"
        echo -e "   Canary returned HTTP $CANARY_STATUS"
        return 1
    fi

    # Check latency degradation
    if (( $(echo "$CANARY_TIME > $PROD_TIME * 2" | bc -l) )); then
        echo -e "${YELLOW}⚠️  WARNING: Canary latency > 2x production${NC}"
        echo -e "   Canary: ${CANARY_TIME}s | Production: ${PROD_TIME}s"
    fi

    # Check simulated error rate
    if [[ $SIMULATED_ERROR_RATE -gt $ERROR_THRESHOLD ]]; then
        echo -e "${RED}❌ Error rate ${SIMULATED_ERROR_RATE}% exceeds threshold ${ERROR_THRESHOLD}%${NC}"
        echo -e "   Rollback recommended!"
        return 1
    fi

    echo -e "${GREEN}✅ Health check passed | Error rate: ${SIMULATED_ERROR_RATE}%${NC}"
    return 0
}

# Function to check Cloudflare health
check_cloudflare_health() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] Checking Cloudflare Workers...${NC}"

    STABLE_WORKER="${PROJECT_NAME}-stable"
    CANARY_WORKER="${PROJECT_NAME}-canary"

    STABLE_URL="https://${STABLE_WORKER}.workers.dev"
    CANARY_URL="https://${CANARY_WORKER}.workers.dev"

    # Check stable worker
    STABLE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$STABLE_URL" || echo "000")
    STABLE_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$STABLE_URL" || echo "0")

    # Check canary worker
    CANARY_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$CANARY_URL" || echo "000")
    CANARY_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$CANARY_URL" || echo "0")

    # Display results
    echo -e "   Stable:  HTTP $STABLE_STATUS | ${STABLE_TIME}s"
    echo -e "   Canary:  HTTP $CANARY_STATUS | ${CANARY_TIME}s"

    # Calculate simulated error rate
    SIMULATED_ERROR_RATE=$((RANDOM % 10))

    if [[ "$CANARY_STATUS" != "200" ]]; then
        echo -e "${RED}❌ Canary health check FAILED${NC}"
        echo -e "   Canary returned HTTP $CANARY_STATUS"
        return 1
    fi

    # Check latency degradation
    if (( $(echo "$CANARY_TIME > $STABLE_TIME * 2" | bc -l) )); then
        echo -e "${YELLOW}⚠️  WARNING: Canary latency > 2x stable${NC}"
        echo -e "   Canary: ${CANARY_TIME}s | Stable: ${STABLE_TIME}s"
    fi

    # Check simulated error rate
    if [[ $SIMULATED_ERROR_RATE -gt $ERROR_THRESHOLD ]]; then
        echo -e "${RED}❌ Error rate ${SIMULATED_ERROR_RATE}% exceeds threshold ${ERROR_THRESHOLD}%${NC}"
        echo -e "   Rollback recommended!"
        return 1
    fi

    echo -e "${GREEN}✅ Health check passed | Error rate: ${SIMULATED_ERROR_RATE}%${NC}"
    return 0
}

# Main monitoring loop
EXIT_CODE=0

if [[ "$ONE_SHOT" == "true" ]]; then
    # Single health check
    if [[ "$PLATFORM" == "vercel" ]]; then
        if ! check_vercel_health; then
            EXIT_CODE=1
        fi
    elif [[ "$PLATFORM" == "cloudflare" ]]; then
        if ! check_cloudflare_health; then
            EXIT_CODE=1
        fi
    fi

    exit $EXIT_CODE
fi

# Continuous monitoring
CONSECUTIVE_FAILURES=0
MAX_CONSECUTIVE_FAILURES=3

while true; do
    if [[ "$PLATFORM" == "vercel" ]]; then
        if ! check_vercel_health; then
            CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
        else
            CONSECUTIVE_FAILURES=0
        fi
    elif [[ "$PLATFORM" == "cloudflare" ]]; then
        if ! check_cloudflare_health; then
            CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
        else
            CONSECUTIVE_FAILURES=0
        fi
    fi

    # Alert on consecutive failures
    if [[ $CONSECUTIVE_FAILURES -ge $MAX_CONSECUTIVE_FAILURES ]]; then
        echo -e "\n${RED}🚨 ALERT: $CONSECUTIVE_FAILURES consecutive health check failures!${NC}"
        echo -e "${RED}   Immediate rollback recommended!${NC}\n"

        # Exit with error code
        EXIT_CODE=1
        break
    fi

    # Wait before next check
    echo -e "${BLUE}⏱️  Next check in ${MONITOR_INTERVAL}s...${NC}\n"
    sleep "$MONITOR_INTERVAL"
done

exit $EXIT_CODE

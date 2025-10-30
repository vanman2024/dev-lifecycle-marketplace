#!/usr/bin/env bash

# HTTP/HTTPS Health Check Script
# Validates HTTP endpoints with status codes, response times, and content verification
# Usage: ./http-health-check.sh <url> [expected_status] [max_response_time_ms] [content_pattern]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
URL="${1:-}"
EXPECTED_STATUS="${2:-200}"
MAX_RESPONSE_TIME="${3:-5000}" # milliseconds
CONTENT_PATTERN="${4:-}"
TIMEOUT="${TIMEOUT:-10}" # seconds
RETRIES="${RETRIES:-3}"
RETRY_DELAY="${RETRY_DELAY:-2}"

# Validate arguments
if [ -z "$URL" ]; then
    echo -e "${RED}Error: URL is required${NC}"
    echo "Usage: $0 <url> [expected_status] [max_response_time_ms] [content_pattern]"
    echo "Example: $0 https://example.com 200 3000 'Welcome'"
    exit 2
fi

# Check dependencies
for cmd in curl jq; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: $cmd is required but not installed${NC}"
        exit 2
    fi
done

# Function to check HTTP endpoint
check_http_endpoint() {
    local url="$1"
    local attempt="$2"

    echo -e "${YELLOW}Attempt $attempt/$RETRIES: Checking $url${NC}"

    # Temporary files for response
    local response_file=$(mktemp)
    local headers_file=$(mktemp)
    local timing_file=$(mktemp)

    # Cleanup on exit
    trap "rm -f $response_file $headers_file $timing_file" EXIT

    # Make request with timing information
    local http_code
    local time_total

    http_code=$(curl -o "$response_file" -D "$headers_file" -w "%{http_code}" \
        --silent \
        --show-error \
        --location \
        --max-time "$TIMEOUT" \
        --write-out "%{time_total}" \
        "$url" 2>&1 | tail -n 1 || echo "000")

    # Extract timing (last line from curl output)
    time_total=$(curl -o "$response_file" -D "$headers_file" \
        --silent \
        --show-error \
        --location \
        --max-time "$TIMEOUT" \
        --write-out "%{time_total}" \
        "$url" 2>&1 | tail -n 1 || echo "0")

    # Get status code from headers (more reliable)
    if [ -f "$headers_file" ]; then
        http_code=$(grep -E "^HTTP/" "$headers_file" | tail -n 1 | awk '{print $2}' || echo "$http_code")
    fi

    # Convert response time to milliseconds
    local response_time_ms
    if command -v bc &> /dev/null; then
        response_time_ms=$(echo "$time_total * 1000" | bc | cut -d. -f1)
    else
        response_time_ms=$(awk "BEGIN {printf \"%.0f\", $time_total * 1000}")
    fi

    # Validation results
    local status_ok=false
    local time_ok=false
    local content_ok=true

    # Check HTTP status code
    if [ "$http_code" = "$EXPECTED_STATUS" ]; then
        status_ok=true
        echo -e "${GREEN}✓ Status code: $http_code (expected: $EXPECTED_STATUS)${NC}"
    else
        echo -e "${RED}✗ Status code: $http_code (expected: $EXPECTED_STATUS)${NC}"
    fi

    # Check response time
    if [ "$response_time_ms" -le "$MAX_RESPONSE_TIME" ]; then
        time_ok=true
        echo -e "${GREEN}✓ Response time: ${response_time_ms}ms (max: ${MAX_RESPONSE_TIME}ms)${NC}"
    else
        echo -e "${RED}✗ Response time: ${response_time_ms}ms (max: ${MAX_RESPONSE_TIME}ms)${NC}"
    fi

    # Check content pattern if provided
    if [ -n "$CONTENT_PATTERN" ]; then
        if grep -q "$CONTENT_PATTERN" "$response_file"; then
            echo -e "${GREEN}✓ Content contains: '$CONTENT_PATTERN'${NC}"
        else
            content_ok=false
            echo -e "${RED}✗ Content does not contain: '$CONTENT_PATTERN'${NC}"
        fi
    fi

    # Display headers (first 5 lines)
    echo -e "\n${YELLOW}Response headers:${NC}"
    head -n 5 "$headers_file"

    # Display response body preview (first 200 chars)
    echo -e "\n${YELLOW}Response body preview:${NC}"
    head -c 200 "$response_file"
    echo -e "\n"

    # Overall result
    if $status_ok && $time_ok && $content_ok; then
        echo -e "${GREEN}✓ Health check PASSED${NC}"
        return 0
    else
        echo -e "${RED}✗ Health check FAILED${NC}"
        return 1
    fi
}

# Main execution with retries
attempt=1
while [ $attempt -le $RETRIES ]; do
    if check_http_endpoint "$URL" "$attempt"; then
        echo -e "\n${GREEN}SUCCESS: $URL is healthy${NC}"
        exit 0
    fi

    if [ $attempt -lt $RETRIES ]; then
        echo -e "${YELLOW}Retrying in ${RETRY_DELAY}s...${NC}\n"
        sleep "$RETRY_DELAY"
    fi

    ((attempt++))
done

echo -e "\n${RED}FAILURE: $URL failed health check after $RETRIES attempts${NC}"
exit 1

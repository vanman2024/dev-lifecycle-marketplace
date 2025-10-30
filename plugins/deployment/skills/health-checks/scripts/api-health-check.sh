#!/usr/bin/env bash

# API Health Check Script
# Validates RESTful API endpoints with JSON response validation and authentication
# Usage: ./api-health-check.sh <api_url> [auth_header] [expected_json_path] [expected_value]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
API_URL="${1:-}"
AUTH_HEADER="${2:-}"
EXPECTED_JSON_PATH="${3:-}"
EXPECTED_VALUE="${4:-}"
TIMEOUT="${TIMEOUT:-15}"
RETRIES="${RETRIES:-3}"
RETRY_DELAY="${RETRY_DELAY:-3}"

# Validate arguments
if [ -z "$API_URL" ]; then
    echo -e "${RED}Error: API URL is required${NC}"
    echo "Usage: $0 <api_url> [auth_header] [expected_json_path] [expected_value]"
    echo ""
    echo "Examples:"
    echo "  $0 https://api.example.com/health"
    echo "  $0 https://api.example.com/v1/status 'Bearer token123'"
    echo "  $0 https://api.example.com/health '' '.status' 'ok'"
    echo "  $0 https://api.example.com/health 'Authorization: Bearer xyz' '.health.database' 'connected'"
    exit 2
fi

# Check dependencies
for cmd in curl jq; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: $cmd is required but not installed${NC}"
        echo "Install with: sudo apt-get install $cmd"
        exit 2
    fi
done

# Function to validate JSON response
validate_json_response() {
    local response="$1"
    local json_path="$2"
    local expected="$3"

    if [ -z "$json_path" ]; then
        return 0
    fi

    echo -e "${BLUE}Validating JSON path: $json_path${NC}"

    # Extract value using jq
    local actual
    actual=$(echo "$response" | jq -r "$json_path" 2>/dev/null || echo "")

    if [ -z "$actual" ]; then
        echo -e "${RED}✗ JSON path not found: $json_path${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ JSON path exists: $json_path${NC}"
    echo -e "  Value: $actual"

    # Check expected value if provided
    if [ -n "$expected" ]; then
        if [ "$actual" = "$expected" ]; then
            echo -e "${GREEN}✓ Value matches expected: '$expected'${NC}"
            return 0
        else
            echo -e "${RED}✗ Value mismatch: got '$actual', expected '$expected'${NC}"
            return 1
        fi
    fi

    return 0
}

# Function to check API endpoint
check_api_endpoint() {
    local url="$1"
    local auth="$2"
    local attempt="$3"

    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Attempt $attempt/$RETRIES: Checking API endpoint${NC}"
    echo -e "${YELLOW}URL: $url${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Temporary files
    local response_file=$(mktemp)
    local headers_file=$(mktemp)

    # Cleanup on exit
    trap "rm -f $response_file $headers_file" EXIT

    # Build curl command
    local curl_cmd="curl"
    curl_cmd="$curl_cmd --silent --show-error"
    curl_cmd="$curl_cmd --location"
    curl_cmd="$curl_cmd --max-time $TIMEOUT"
    curl_cmd="$curl_cmd --write-out '\n%{http_code}\n%{time_total}'"
    curl_cmd="$curl_cmd -D $headers_file"
    curl_cmd="$curl_cmd -H 'Accept: application/json'"
    curl_cmd="$curl_cmd -H 'Content-Type: application/json'"

    # Add authentication header if provided
    if [ -n "$auth" ]; then
        # Check if header already contains 'Authorization:' or similar
        if [[ "$auth" =~ ^[A-Za-z-]+:\ .* ]]; then
            curl_cmd="$curl_cmd -H '$auth'"
        else
            # Assume it's a Bearer token
            curl_cmd="$curl_cmd -H 'Authorization: $auth'"
        fi
    fi

    curl_cmd="$curl_cmd '$url'"

    # Execute request
    local output
    output=$(eval $curl_cmd 2>&1 || echo "")

    # Parse output (response, status code, time)
    local response=$(echo "$output" | head -n -2)
    local http_code=$(echo "$output" | tail -n 2 | head -n 1)
    local time_total=$(echo "$output" | tail -n 1)

    # Fallback: extract from headers if needed
    if [ -z "$http_code" ] || [ "$http_code" = "" ]; then
        http_code=$(grep -E "^HTTP/" "$headers_file" | tail -n 1 | awk '{print $2}' 2>/dev/null || echo "000")
    fi

    # Convert response time to milliseconds
    local response_time_ms=0
    if [ -n "$time_total" ] && [ "$time_total" != "" ]; then
        if command -v bc &> /dev/null; then
            response_time_ms=$(echo "$time_total * 1000" | bc | cut -d. -f1)
        else
            response_time_ms=$(awk "BEGIN {printf \"%.0f\", $time_total * 1000}")
        fi
    fi

    # Validation flags
    local status_ok=false
    local json_valid=false
    local json_check_ok=true

    # Check HTTP status code
    if [[ "$http_code" =~ ^2[0-9][0-9]$ ]]; then
        status_ok=true
        echo -e "${GREEN}✓ Status code: $http_code (Success)${NC}"
    else
        echo -e "${RED}✗ Status code: $http_code (Expected 2xx)${NC}"
    fi

    # Display response time
    echo -e "${BLUE}⧗ Response time: ${response_time_ms}ms${NC}"

    # Validate JSON response
    if echo "$response" | jq empty 2>/dev/null; then
        json_valid=true
        echo -e "${GREEN}✓ Valid JSON response${NC}"

        # Pretty print JSON (first 500 chars)
        echo -e "\n${BLUE}Response body:${NC}"
        echo "$response" | jq '.' 2>/dev/null | head -c 500
        echo -e "\n"

        # Validate specific JSON path if provided
        if [ -n "$EXPECTED_JSON_PATH" ]; then
            if validate_json_response "$response" "$EXPECTED_JSON_PATH" "$EXPECTED_VALUE"; then
                json_check_ok=true
            else
                json_check_ok=false
            fi
        fi
    else
        echo -e "${RED}✗ Invalid JSON response${NC}"
        echo -e "\n${YELLOW}Response preview:${NC}"
        echo "$response" | head -c 200
        echo -e "\n"
    fi

    # Check common health indicators in JSON
    if $json_valid; then
        echo -e "\n${BLUE}Checking common health indicators:${NC}"

        # Check for 'status' field
        local status_field=$(echo "$response" | jq -r '.status // .health // .state // empty' 2>/dev/null || echo "")
        if [ -n "$status_field" ]; then
            echo -e "  ${GREEN}✓${NC} Status field: $status_field"
        fi

        # Check for 'healthy' field
        local healthy_field=$(echo "$response" | jq -r '.healthy // empty' 2>/dev/null || echo "")
        if [ -n "$healthy_field" ]; then
            echo -e "  ${GREEN}✓${NC} Healthy field: $healthy_field"
        fi

        # Check for 'version' field
        local version_field=$(echo "$response" | jq -r '.version // .apiVersion // empty' 2>/dev/null || echo "")
        if [ -n "$version_field" ]; then
            echo -e "  ${GREEN}✓${NC} Version: $version_field"
        fi

        # Check for 'uptime' field
        local uptime_field=$(echo "$response" | jq -r '.uptime // .uptimeSeconds // empty' 2>/dev/null || echo "")
        if [ -n "$uptime_field" ]; then
            echo -e "  ${GREEN}✓${NC} Uptime: $uptime_field"
        fi
    fi

    # Overall result
    if $status_ok && $json_valid && $json_check_ok; then
        echo -e "\n${GREEN}✓ API health check PASSED${NC}"
        return 0
    else
        echo -e "\n${RED}✗ API health check FAILED${NC}"
        return 1
    fi
}

# Main execution with retries
attempt=1
while [ $attempt -le $RETRIES ]; do
    if check_api_endpoint "$API_URL" "$AUTH_HEADER" "$attempt"; then
        echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}SUCCESS: API endpoint is healthy${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        exit 0
    fi

    if [ $attempt -lt $RETRIES ]; then
        echo -e "${YELLOW}Retrying in ${RETRY_DELAY}s...${NC}\n"
        sleep "$RETRY_DELAY"
    fi

    ((attempt++))
done

echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}FAILURE: API endpoint failed health check after $RETRIES attempts${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
exit 1

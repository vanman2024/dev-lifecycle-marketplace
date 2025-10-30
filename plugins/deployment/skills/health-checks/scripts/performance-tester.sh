#!/usr/bin/env bash

# Performance Testing Script
# Load testing and performance metrics collection with concurrent request handling
# Usage: ./performance-tester.sh <url> [concurrent_requests] [total_requests] [timeout_seconds]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
URL="${1:-}"
CONCURRENT="${2:-10}"
TOTAL_REQUESTS="${3:-100}"
TIMEOUT="${4:-10}"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp/perf-test-$$}"

# Validate arguments
if [ -z "$URL" ]; then
    echo -e "${RED}Error: URL is required${NC}"
    echo "Usage: $0 <url> [concurrent_requests] [total_requests] [timeout_seconds]"
    echo ""
    echo "Examples:"
    echo "  $0 https://example.com"
    echo "  $0 https://api.example.com 50 500 15"
    echo "  $0 https://example.com 100 1000 20"
    exit 2
fi

# Validate numeric arguments
if ! [[ "$CONCURRENT" =~ ^[0-9]+$ ]] || [ "$CONCURRENT" -lt 1 ]; then
    echo -e "${RED}Error: Concurrent requests must be a positive number${NC}"
    exit 2
fi

if ! [[ "$TOTAL_REQUESTS" =~ ^[0-9]+$ ]] || [ "$TOTAL_REQUESTS" -lt 1 ]; then
    echo -e "${RED}Error: Total requests must be a positive number${NC}"
    exit 2
fi

# Check dependencies
for cmd in curl bc; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: $cmd is required but not installed${NC}"
        exit 2
    fi
done

# Create output directory
mkdir -p "$OUTPUT_DIR"
trap "rm -rf $OUTPUT_DIR" EXIT

echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}Performance Testing${NC}"
echo -e "${MAGENTA}URL: $URL${NC}"
echo -e "${MAGENTA}Concurrent requests: $CONCURRENT${NC}"
echo -e "${MAGENTA}Total requests: $TOTAL_REQUESTS${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Function to make single request and record metrics
make_request() {
    local request_id="$1"
    local output_file="$OUTPUT_DIR/request-$request_id.txt"

    local start_time=$(date +%s%N)

    # Make request with detailed timing
    local result=$(curl -w "\n%{http_code}\n%{time_total}\n%{time_connect}\n%{time_starttransfer}\n%{size_download}" \
        -o /dev/null \
        -s \
        --max-time "$TIMEOUT" \
        "$URL" 2>&1)

    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))

    # Parse curl output
    local http_code=$(echo "$result" | sed -n '2p' || echo "000")
    local time_total=$(echo "$result" | sed -n '3p' || echo "0")
    local time_connect=$(echo "$result" | sed -n '4p' || echo "0")
    local time_starttransfer=$(echo "$result" | sed -n '5p' || echo "0")
    local size_download=$(echo "$result" | sed -n '6p' || echo "0")

    # Write results
    echo "$request_id,$http_code,$time_total,$time_connect,$time_starttransfer,$size_download,$duration_ms" > "$output_file"
}

export -f make_request
export URL TIMEOUT OUTPUT_DIR

# Step 1: Warmup request
echo -e "\n${BLUE}Step 1: Warmup request...${NC}"
make_request "warmup"
echo -e "${GREEN}✓ Warmup complete${NC}"

# Step 2: Run performance test
echo -e "\n${BLUE}Step 2: Running performance test...${NC}"
echo -e "${CYAN}Sending $TOTAL_REQUESTS requests with $CONCURRENT concurrent connections...${NC}"

START_TIME=$(date +%s)

# Run requests in parallel batches
for ((i=1; i<=TOTAL_REQUESTS; i++)); do
    make_request "$i" &

    # Limit concurrent processes
    if (( i % CONCURRENT == 0 )); then
        wait
        echo -ne "\r${CYAN}Progress: $i/$TOTAL_REQUESTS requests completed${NC}"
    fi
done

# Wait for remaining requests
wait
echo -ne "\r${GREEN}Progress: $TOTAL_REQUESTS/$TOTAL_REQUESTS requests completed${NC}\n"

END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

echo -e "${GREEN}✓ Test completed in ${TOTAL_TIME}s${NC}"

# Step 3: Analyze results
echo -e "\n${BLUE}Step 3: Analyzing results...${NC}"

# Collect all results
RESULTS_FILE="$OUTPUT_DIR/all-results.csv"
echo "request_id,http_code,time_total,time_connect,time_starttransfer,size_download,duration_ms" > "$RESULTS_FILE"

for file in "$OUTPUT_DIR"/request-*.txt; do
    [ -f "$file" ] && cat "$file" >> "$RESULTS_FILE"
done

# Calculate statistics using awk for better performance
STATS=$(awk -F',' 'NR>1 {
    count++
    status[$2]++
    total_time += $3
    total_connect += $4
    total_transfer += $5
    total_size += $6

    # Track min/max
    if (NR==2 || $3 < min_time) min_time = $3
    if (NR==2 || $3 > max_time) max_time = $3

    # Store times for percentile calculation
    times[count] = $3
}
END {
    # Sort times for percentiles
    n = asort(times)

    # Calculate percentiles
    p50_idx = int(n * 0.50)
    p90_idx = int(n * 0.90)
    p95_idx = int(n * 0.95)
    p99_idx = int(n * 0.99)

    print count
    print total_time / count
    print total_connect / count
    print total_transfer / count
    print min_time
    print max_time
    print times[p50_idx]
    print times[p90_idx]
    print times[p95_idx]
    print times[p99_idx]
    print total_size
    for (code in status) print code ":" status[code]
}' "$RESULTS_FILE")

# Parse statistics
TOTAL_SUCCESSFUL=$(echo "$STATS" | head -1)
AVG_TIME=$(echo "$STATS" | sed -n '2p')
AVG_CONNECT=$(echo "$STATS" | sed -n '3p')
AVG_TRANSFER=$(echo "$STATS" | sed -n '4p')
MIN_TIME=$(echo "$STATS" | sed -n '5p')
MAX_TIME=$(echo "$STATS" | sed -n '6p')
P50_TIME=$(echo "$STATS" | sed -n '7p')
P90_TIME=$(echo "$STATS" | sed -n '8p')
P95_TIME=$(echo "$STATS" | sed -n '9p')
P99_TIME=$(echo "$STATS" | sed -n '10p')
TOTAL_DATA=$(echo "$STATS" | sed -n '11p')

# Convert to milliseconds for display
AVG_TIME_MS=$(echo "$AVG_TIME * 1000" | bc -l | cut -d. -f1)
MIN_TIME_MS=$(echo "$MIN_TIME * 1000" | bc -l | cut -d. -f1)
MAX_TIME_MS=$(echo "$MAX_TIME * 1000" | bc -l | cut -d. -f1)
P50_TIME_MS=$(echo "$P50_TIME * 1000" | bc -l | cut -d. -f1)
P90_TIME_MS=$(echo "$P90_TIME * 1000" | bc -l | cut -d. -f1)
P95_TIME_MS=$(echo "$P95_TIME * 1000" | bc -l | cut -d. -f1)
P99_TIME_MS=$(echo "$P99_TIME * 1000" | bc -l | cut -d. -f1)

# Calculate requests per second
REQUESTS_PER_SEC=$(echo "scale=2; $TOTAL_REQUESTS / $TOTAL_TIME" | bc)

# Display results
echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}Performance Test Results${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n${CYAN}Request Statistics:${NC}"
echo -e "  Total requests:        $TOTAL_REQUESTS"
echo -e "  Successful requests:   $TOTAL_SUCCESSFUL"
echo -e "  Failed requests:       $((TOTAL_REQUESTS - TOTAL_SUCCESSFUL))"
echo -e "  Test duration:         ${TOTAL_TIME}s"
echo -e "  Requests per second:   $REQUESTS_PER_SEC"

echo -e "\n${CYAN}Response Time (ms):${NC}"
echo -e "  Average:               ${AVG_TIME_MS}ms"
echo -e "  Minimum:               ${MIN_TIME_MS}ms"
echo -e "  Maximum:               ${MAX_TIME_MS}ms"
echo -e "  50th percentile (p50): ${P50_TIME_MS}ms"
echo -e "  90th percentile (p90): ${P90_TIME_MS}ms"
echo -e "  95th percentile (p95): ${P95_TIME_MS}ms"
echo -e "  99th percentile (p99): ${P99_TIME_MS}ms"

echo -e "\n${CYAN}HTTP Status Codes:${NC}"
echo "$STATS" | tail -n +12 | while IFS=: read -r code count; do
    if [ -n "$code" ]; then
        if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then
            echo -e "  ${GREEN}$code${NC}: $count"
        elif [[ "$code" =~ ^[45][0-9][0-9]$ ]]; then
            echo -e "  ${RED}$code${NC}: $count"
        else
            echo -e "  ${YELLOW}$code${NC}: $count"
        fi
    fi
done

# Data transfer
if [ -n "$TOTAL_DATA" ] && [ "$TOTAL_DATA" != "0" ]; then
    TOTAL_MB=$(echo "scale=2; $TOTAL_DATA / 1048576" | bc)
    echo -e "\n${CYAN}Data Transfer:${NC}"
    echo -e "  Total data:            ${TOTAL_MB} MB"
fi

# Step 4: Performance assessment
echo -e "\n${BLUE}Step 4: Performance assessment...${NC}"

# Calculate success rate
SUCCESS_RATE=$(echo "scale=2; ($TOTAL_SUCCESSFUL / $TOTAL_REQUESTS) * 100" | bc)

# Performance thresholds (can be customized)
THRESHOLD_AVG_TIME=3000  # 3 seconds
THRESHOLD_P95_TIME=5000  # 5 seconds
THRESHOLD_SUCCESS_RATE=95.0

PERFORMANCE_OK=true

# Check success rate
if (( $(echo "$SUCCESS_RATE >= $THRESHOLD_SUCCESS_RATE" | bc -l) )); then
    echo -e "${GREEN}✓ Success rate: ${SUCCESS_RATE}% (threshold: ${THRESHOLD_SUCCESS_RATE}%)${NC}"
else
    echo -e "${RED}✗ Success rate: ${SUCCESS_RATE}% (threshold: ${THRESHOLD_SUCCESS_RATE}%)${NC}"
    PERFORMANCE_OK=false
fi

# Check average response time
if (( $(echo "$AVG_TIME_MS <= $THRESHOLD_AVG_TIME" | bc -l) )); then
    echo -e "${GREEN}✓ Average response time: ${AVG_TIME_MS}ms (threshold: ${THRESHOLD_AVG_TIME}ms)${NC}"
else
    echo -e "${YELLOW}⚠ Average response time: ${AVG_TIME_MS}ms (threshold: ${THRESHOLD_AVG_TIME}ms)${NC}"
fi

# Check p95 response time
if (( $(echo "$P95_TIME_MS <= $THRESHOLD_P95_TIME" | bc -l) )); then
    echo -e "${GREEN}✓ 95th percentile: ${P95_TIME_MS}ms (threshold: ${THRESHOLD_P95_TIME}ms)${NC}"
else
    echo -e "${YELLOW}⚠ 95th percentile: ${P95_TIME_MS}ms (threshold: ${THRESHOLD_P95_TIME}ms)${NC}"
fi

# Final result
echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if $PERFORMANCE_OK; then
    echo -e "${GREEN}SUCCESS: Performance test passed${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${RED}FAILURE: Performance test failed${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 5
fi

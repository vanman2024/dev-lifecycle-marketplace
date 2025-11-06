#!/usr/bin/env bash
set -euo pipefail

# collect-metrics.sh
# Metrics collection from various sources (logs, APM, monitoring services)
#
# Usage: collect-metrics.sh <metrics_url> [output_format]
#
# Arguments:
#   metrics_url     - URL to metrics endpoint or log source
#   output_format   - Output format: json (default), prometheus, csv
#
# Exit Codes:
#   0 - Metrics collected successfully
#   2 - Invalid arguments
#   3 - Network error or timeout

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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

validate_arguments() {
    if [ $# -lt 1 ]; then
        log_error "Usage: $0 <metrics_url> [output_format]"
        log_error "Example: $0 https://api.example.com/metrics json"
        exit 2
    fi
}

fetch_metrics() {
    local url="$1"
    local timeout=15

    log_info "Fetching metrics from: $url"

    local response
    response=$(curl -sf --max-time "$timeout" "$url" 2>&1) || {
        log_error "Failed to fetch metrics"
        return 3
    }

    echo "$response"
}

parse_prometheus_metrics() {
    local data="$1"

    # Parse Prometheus text format to JSON
    local json_output='{"metrics":[]}'

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue

        # Parse metric name and value
        if [[ "$line" =~ ^([a-zA-Z_:][a-zA-Z0-9_:]*)\{([^}]*)\}[[:space:]]+([0-9.+-eE]+)$ ]]; then
            local metric_name="${BASH_REMATCH[1]}"
            local labels="${BASH_REMATCH[2]}"
            local value="${BASH_REMATCH[3]}"

            json_output=$(echo "$json_output" | jq --arg name "$metric_name" --arg val "$value" \
                '.metrics += [{"name": $name, "value": ($val | tonumber)}]')
        elif [[ "$line" =~ ^([a-zA-Z_:][a-zA-Z0-9_:]*)[[:space:]]+([0-9.+-eE]+)$ ]]; then
            local metric_name="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"

            json_output=$(echo "$json_output" | jq --arg name "$metric_name" --arg val "$value" \
                '.metrics += [{"name": $name, "value": ($val | tonumber)}]')
        fi
    done <<< "$data"

    echo "$json_output"
}

format_output() {
    local data="$1"
    local format="${2:-json}"

    case "$format" in
        json)
            echo "$data" | jq '.'
            ;;
        prometheus)
            # Convert JSON to Prometheus text format
            echo "$data" | jq -r '.metrics[]? // .[] | "\(.name // .metric_name) \(.value)"'
            ;;
        csv)
            # Convert to CSV
            echo "metric_name,value,timestamp"
            local timestamp
            timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            echo "$data" | jq -r --arg ts "$timestamp" \
                '.metrics[]? // .[] | [(.name // .metric_name), .value, $ts] | @csv'
            ;;
        *)
            log_error "Unsupported output format: $format"
            exit 2
            ;;
    esac
}

extract_key_metrics() {
    local data="$1"

    log_info "Extracting key metrics..."

    # Extract common metrics
    local error_rate latency_p95 success_rate uptime request_count

    error_rate=$(echo "$data" | jq -r '.error_rate // .errorRate // .metrics[] | select(.name == "error_rate") | .value // empty' 2>/dev/null || echo "N/A")
    latency_p95=$(echo "$data" | jq -r '.latency_p95 // .latency.p95 // .metrics[] | select(.name == "latency_p95") | .value // empty' 2>/dev/null || echo "N/A")
    success_rate=$(echo "$data" | jq -r '.success_rate // .successRate // .metrics[] | select(.name == "success_rate") | .value // empty' 2>/dev/null || echo "N/A")
    uptime=$(echo "$data" | jq -r '.uptime // .availability // .metrics[] | select(.name == "uptime") | .value // empty' 2>/dev/null || echo "N/A")
    request_count=$(echo "$data" | jq -r '.total_requests // .totalRequests // .metrics[] | select(.name == "request_count") | .value // empty' 2>/dev/null || echo "N/A")

    log_info "Key Metrics Summary:"
    log_info "  Error Rate: $error_rate%"
    log_info "  Latency P95: ${latency_p95}ms"
    log_info "  Success Rate: $success_rate%"
    log_info "  Uptime: $uptime%"
    log_info "  Request Count: $request_count"
}

main() {
    check_dependencies
    validate_arguments "$@"

    local metrics_url="$1"
    local output_format="${2:-json}"

    log_info "=== Metrics Collection ==="
    log_info "Source: $metrics_url"
    log_info "Output Format: $output_format"

    local metrics
    metrics=$(fetch_metrics "$metrics_url") || exit 3

    # Detect if metrics are in Prometheus format
    if echo "$metrics" | grep -qE '^[a-zA-Z_:][a-zA-Z0-9_:]*'; then
        log_info "Detected Prometheus format, converting to JSON..."
        metrics=$(parse_prometheus_metrics "$metrics")
    fi

    # Extract and display key metrics
    extract_key_metrics "$metrics"

    # Format and output
    log_info ""
    log_info "=== Metrics Output ==="
    format_output "$metrics" "$output_format"

    log_info ""
    log_info "✓ Metrics collection completed"
    exit 0
}

main "$@"

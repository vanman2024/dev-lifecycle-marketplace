#!/usr/bin/env bash
set -euo pipefail

# monitor-error-rate.sh
# Real-time error rate monitoring with configurable thresholds and time windows
#
# Usage: monitor-error-rate.sh <metrics_url> <threshold_percent> <time_window_seconds> [config_file]
#
# Arguments:
#   metrics_url           - URL to fetch metrics (JSON format expected)
#   threshold_percent     - Error rate threshold (e.g., 5.0 for 5%)
#   time_window_seconds   - Time window to monitor (e.g., 300 for 5 minutes)
#   config_file          - Optional: JSON config file for advanced settings
#
# Exit Codes:
#   0 - Error rate within threshold
#   1 - Error rate exceeds threshold (trigger rollback)
#   2 - Invalid arguments or missing dependencies
#   3 - Network error or timeout

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Function to check dependencies
check_dependencies() {
    local missing_deps=()

    for cmd in curl jq bc date; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo apt-get install curl jq bc coreutils"
        exit 2
    fi
}

# Function to validate arguments
validate_arguments() {
    if [ $# -lt 3 ]; then
        log_error "Usage: $0 <metrics_url> <threshold_percent> <time_window_seconds> [config_file]"
        log_error "Example: $0 https://api.example.com/metrics 5.0 300"
        exit 2
    fi

    # Validate threshold is a number
    if ! echo "$2" | grep -Eq '^[0-9]+\.?[0-9]*$'; then
        log_error "Threshold must be a valid number (e.g., 5.0)"
        exit 2
    fi

    # Validate time window is a positive integer
    if ! echo "$3" | grep -Eq '^[0-9]+$'; then
        log_error "Time window must be a positive integer (seconds)"
        exit 2
    fi
}

# Function to fetch metrics
fetch_metrics() {
    local url="$1"
    local timeout=10

    log_info "Fetching metrics from: $url"

    local response
    response=$(curl -sf --max-time "$timeout" "$url" 2>&1) || {
        log_error "Failed to fetch metrics from $url"
        return 3
    }

    echo "$response"
}

# Function to calculate error rate from metrics
calculate_error_rate() {
    local metrics="$1"

    # Try to extract error rate from common metric formats
    # Format 1: { "error_rate": 5.2 }
    local error_rate
    error_rate=$(echo "$metrics" | jq -r '.error_rate // .errorRate // .errors.rate // empty' 2>/dev/null)

    if [ -n "$error_rate" ] && [ "$error_rate" != "null" ]; then
        echo "$error_rate"
        return 0
    fi

    # Format 2: Calculate from total and error counts
    # { "total_requests": 1000, "error_requests": 52 }
    local total errors
    total=$(echo "$metrics" | jq -r '.total_requests // .totalRequests // .requests.total // empty' 2>/dev/null)
    errors=$(echo "$metrics" | jq -r '.error_requests // .errorRequests // .errors.count // empty' 2>/dev/null)

    if [ -n "$total" ] && [ -n "$errors" ] && [ "$total" != "null" ] && [ "$errors" != "null" ]; then
        # Calculate percentage: (errors / total) * 100
        error_rate=$(echo "scale=2; ($errors / $total) * 100" | bc)
        echo "$error_rate"
        return 0
    fi

    # Format 3: Calculate from success rate
    # { "success_rate": 94.8 }
    local success_rate
    success_rate=$(echo "$metrics" | jq -r '.success_rate // .successRate // empty' 2>/dev/null)

    if [ -n "$success_rate" ] && [ "$success_rate" != "null" ]; then
        # Error rate = 100 - success rate
        error_rate=$(echo "scale=2; 100 - $success_rate" | bc)
        echo "$error_rate"
        return 0
    fi

    log_error "Could not extract error rate from metrics"
    log_error "Expected formats:"
    log_error "  1. { \"error_rate\": 5.2 }"
    log_error "  2. { \"total_requests\": 1000, \"error_requests\": 52 }"
    log_error "  3. { \"success_rate\": 94.8 }"
    return 2
}

# Function to compare error rate with threshold
check_threshold() {
    local current="$1"
    local threshold="$2"

    # Use bc for floating point comparison
    local exceeds
    exceeds=$(echo "$current > $threshold" | bc)

    if [ "$exceeds" -eq 1 ]; then
        return 1  # Threshold exceeded
    else
        return 0  # Within threshold
    fi
}

# Function to monitor over time window
monitor_time_window() {
    local url="$1"
    local threshold="$2"
    local time_window="$3"
    local interval=60  # Check every 60 seconds

    local start_time
    start_time=$(date +%s)
    local end_time=$((start_time + time_window))

    local violations=0
    local checks=0

    log_info "Monitoring for $time_window seconds ($(echo "scale=1; $time_window / 60" | bc) minutes)"
    log_info "Threshold: ${threshold}%"
    log_info "Check interval: ${interval}s"

    while [ "$(date +%s)" -lt "$end_time" ]; do
        local metrics
        metrics=$(fetch_metrics "$url") || {
            log_warn "Failed to fetch metrics, will retry..."
            sleep "$interval"
            continue
        }

        local error_rate
        error_rate=$(calculate_error_rate "$metrics") || {
            log_warn "Failed to calculate error rate, will retry..."
            sleep "$interval"
            continue
        }

        checks=$((checks + 1))

        log_info "Check $checks: Error rate = ${error_rate}%"

        if ! check_threshold "$error_rate" "$threshold"; then
            violations=$((violations + 1))
            log_warn "Threshold exceeded! (${error_rate}% > ${threshold}%)"
        fi

        # Sleep until next check (unless we're at the end)
        if [ "$(date +%s)" -lt "$end_time" ]; then
            local sleep_time=$interval
            local remaining=$((end_time - $(date +%s)))
            if [ "$remaining" -lt "$interval" ]; then
                sleep_time=$remaining
            fi
            if [ "$sleep_time" -gt 0 ]; then
                sleep "$sleep_time"
            fi
        fi
    done

    # Calculate violation rate
    local violation_rate=0
    if [ "$checks" -gt 0 ]; then
        violation_rate=$(echo "scale=2; ($violations / $checks) * 100" | bc)
    fi

    log_info "Monitoring complete:"
    log_info "  Total checks: $checks"
    log_info "  Violations: $violations"
    log_info "  Violation rate: ${violation_rate}%"

    # Consider it a failure if >50% of checks exceeded threshold
    if [ "$violations" -gt 0 ] && [ "$(echo "$violation_rate > 50" | bc)" -eq 1 ]; then
        log_error "Error rate consistently exceeded threshold"
        return 1
    fi

    log_info "Error rate within acceptable bounds"
    return 0
}

# Main execution
main() {
    check_dependencies
    validate_arguments "$@"

    local metrics_url="$1"
    local threshold="$2"
    local time_window="$3"

    log_info "=== Error Rate Monitor ==="
    log_info "Metrics URL: $metrics_url"
    log_info "Threshold: ${threshold}%"
    log_info "Time Window: ${time_window}s"

    # If time window is short (< 120s), do single check
    if [ "$time_window" -lt 120 ]; then
        log_info "Short time window detected, performing single check"

        local metrics
        metrics=$(fetch_metrics "$metrics_url") || exit 3

        local error_rate
        error_rate=$(calculate_error_rate "$metrics") || exit 2

        log_info "Current error rate: ${error_rate}%"

        if check_threshold "$error_rate" "$threshold"; then
            log_info "✓ Error rate within threshold"
            exit 0
        else
            log_error "✗ Error rate exceeds threshold (${error_rate}% > ${threshold}%)"
            exit 1
        fi
    else
        # Monitor over time window
        if monitor_time_window "$metrics_url" "$threshold" "$time_window"; then
            log_info "✓ Monitoring passed"
            exit 0
        else
            log_error "✗ Monitoring failed - error rate threshold exceeded"
            exit 1
        fi
    fi
}

# Run main function
main "$@"

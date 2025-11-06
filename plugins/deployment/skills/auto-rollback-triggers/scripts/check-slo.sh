#!/usr/bin/env bash
set -euo pipefail

# check-slo.sh
# SLO (Service Level Objective) validation with success rate calculations
#
# Usage: check-slo.sh <health_url> <slo_target_percent> [config_file]
#
# Arguments:
#   health_url          - URL to health check endpoint
#   slo_target_percent  - SLO target (e.g., 99.9 for 99.9% uptime)
#   config_file         - Optional: JSON config file with SLO definitions
#
# Exit Codes:
#   0 - SLO met
#   1 - SLO violated (trigger rollback)
#   2 - Invalid arguments or missing dependencies
#   3 - Network error or timeout

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check dependencies
check_dependencies() {
    local missing_deps=()

    for cmd in curl jq bc date; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit 2
    fi
}

# Validate arguments
validate_arguments() {
    if [ $# -lt 2 ]; then
        log_error "Usage: $0 <health_url> <slo_target_percent> [config_file]"
        log_error "Example: $0 https://api.example.com/health 99.9"
        exit 2
    fi

    # Validate SLO target is a number between 0 and 100
    if ! echo "$2" | grep -Eq '^[0-9]+\.?[0-9]*$'; then
        log_error "SLO target must be a valid number (e.g., 99.9)"
        exit 2
    fi

    local slo_value
    slo_value=$(echo "$2" | bc)
    if [ "$(echo "$slo_value < 0 || $slo_value > 100" | bc)" -eq 1 ]; then
        log_error "SLO target must be between 0 and 100"
        exit 2
    fi
}

# Check health endpoint
check_health() {
    local url="$1"
    local timeout=10

    local response
    local http_code
    http_code=$(curl -sf --max-time "$timeout" -w "%{http_code}" -o /dev/null "$url" 2>/dev/null) || {
        log_error "Failed to reach health endpoint: $url"
        return 1
    }

    # Consider 2xx as healthy
    if [[ "$http_code" =~ ^2 ]]; then
        return 0
    else
        log_warn "Health check returned non-2xx status: $http_code"
        return 1
    fi
}

# Get metrics from health endpoint
get_health_metrics() {
    local url="$1"
    local timeout=10

    local response
    response=$(curl -sf --max-time "$timeout" "$url" 2>&1) || {
        log_error "Failed to fetch health metrics"
        return 3
    }

    echo "$response"
}

# Calculate availability from metrics
calculate_availability() {
    local metrics="$1"

    # Try to extract availability from common formats
    # Format 1: { "uptime": 99.95 }
    local uptime
    uptime=$(echo "$metrics" | jq -r '.uptime // .availability // .success_rate // empty' 2>/dev/null)

    if [ -n "$uptime" ] && [ "$uptime" != "null" ]; then
        echo "$uptime"
        return 0
    fi

    # Format 2: Calculate from successful/total requests
    # { "successful": 9995, "total": 10000 }
    local successful total
    successful=$(echo "$metrics" | jq -r '.successful // .success_count // empty' 2>/dev/null)
    total=$(echo "$metrics" | jq -r '.total // .total_requests // empty' 2>/dev/null)

    if [ -n "$successful" ] && [ -n "$total" ] && [ "$total" != "null" ] && [ "$successful" != "null" ]; then
        local availability
        availability=$(echo "scale=4; ($successful / $total) * 100" | bc)
        echo "$availability"
        return 0
    fi

    # Format 3: Calculate from error rate
    # { "error_rate": 0.05 }
    local error_rate
    error_rate=$(echo "$metrics" | jq -r '.error_rate // .errorRate // empty' 2>/dev/null)

    if [ -n "$error_rate" ] && [ "$error_rate" != "null" ]; then
        local availability
        availability=$(echo "scale=4; 100 - $error_rate" | bc)
        echo "$availability"
        return 0
    fi

    log_error "Could not extract availability from metrics"
    return 2
}

# Check latency SLO
check_latency_slo() {
    local metrics="$1"
    local target_ms="${2:-500}"  # Default 500ms

    local latency
    latency=$(echo "$metrics" | jq -r '.latency_p95 // .latency.p95 // .response_time_p95 // empty' 2>/dev/null)

    if [ -n "$latency" ] && [ "$latency" != "null" ]; then
        log_info "P95 Latency: ${latency}ms (target: <${target_ms}ms)"

        if [ "$(echo "$latency > $target_ms" | bc)" -eq 1 ]; then
            log_warn "Latency SLO violated: ${latency}ms > ${target_ms}ms"
            return 1
        else
            log_info "✓ Latency SLO met"
            return 0
        fi
    else
        log_warn "Latency metric not available, skipping check"
        return 0  # Don't fail if metric not available
    fi
}

# Check error rate SLO
check_error_rate_slo() {
    local metrics="$1"
    local max_error_rate="${2:-1.0}"  # Default 1%

    local error_rate
    error_rate=$(echo "$metrics" | jq -r '.error_rate // .errorRate // empty' 2>/dev/null)

    if [ -n "$error_rate" ] && [ "$error_rate" != "null" ]; then
        log_info "Error Rate: ${error_rate}% (target: <${max_error_rate}%)"

        if [ "$(echo "$error_rate > $max_error_rate" | bc)" -eq 1 ]; then
            log_warn "Error rate SLO violated: ${error_rate}% > ${max_error_rate}%"
            return 1
        else
            log_info "✓ Error rate SLO met"
            return 0
        fi
    else
        log_warn "Error rate metric not available, skipping check"
        return 0  # Don't fail if metric not available
    fi
}

# Monitor SLO over time period
monitor_slo_period() {
    local url="$1"
    local slo_target="$2"
    local duration="${3:-300}"  # Default 5 minutes

    log_info "Monitoring SLO for $duration seconds..."

    local start_time
    start_time=$(date +%s)
    local end_time=$((start_time + duration))

    local checks=0
    local failures=0
    local interval=30  # Check every 30 seconds

    while [ "$(date +%s)" -lt "$end_time" ]; do
        checks=$((checks + 1))

        if check_health "$url"; then
            log_info "Check $checks: ✓ Healthy"
        else
            failures=$((failures + 1))
            log_warn "Check $checks: ✗ Failed"
        fi

        local remaining=$((end_time - $(date +%s)))
        if [ "$remaining" -gt 0 ]; then
            local sleep_time=$interval
            if [ "$remaining" -lt "$interval" ]; then
                sleep_time=$remaining
            fi
            sleep "$sleep_time"
        fi
    done

    # Calculate actual availability
    local successful=$((checks - failures))
    local actual_availability
    actual_availability=$(echo "scale=4; ($successful / $checks) * 100" | bc)

    log_info "SLO Check Results:"
    log_info "  Total checks: $checks"
    log_info "  Successful: $successful"
    log_info "  Failed: $failures"
    log_info "  Actual availability: ${actual_availability}%"
    log_info "  Target SLO: ${slo_target}%"

    # Check if SLO met
    if [ "$(echo "$actual_availability >= $slo_target" | bc)" -eq 1 ]; then
        log_info "✓ SLO met (${actual_availability}% >= ${slo_target}%)"
        return 0
    else
        log_error "✗ SLO violated (${actual_availability}% < ${slo_target}%)"
        return 1
    fi
}

# Load SLO config from file
load_slo_config() {
    local config_file="$1"

    if [ ! -f "$config_file" ]; then
        log_error "Config file not found: $config_file"
        return 2
    fi

    local config
    config=$(cat "$config_file")

    # Validate JSON
    if ! echo "$config" | jq empty 2>/dev/null; then
        log_error "Invalid JSON in config file"
        return 2
    fi

    echo "$config"
}

# Main execution
main() {
    check_dependencies
    validate_arguments "$@"

    local health_url="$1"
    local slo_target="$2"
    local config_file="${3:-}"

    log_info "=== SLO Validation ==="
    log_info "Health URL: $health_url"
    log_info "SLO Target: ${slo_target}%"

    # Load config if provided
    local config=""
    local latency_target=500
    local error_rate_target=1.0
    local monitoring_duration=300

    if [ -n "$config_file" ]; then
        log_info "Loading config from: $config_file"
        config=$(load_slo_config "$config_file") || exit 2

        # Extract custom targets from config
        latency_target=$(echo "$config" | jq -r '.latency_p95_target // 500')
        error_rate_target=$(echo "$config" | jq -r '.error_rate_target // 1.0')
        monitoring_duration=$(echo "$config" | jq -r '.monitoring_duration // 300')
    fi

    # Step 1: Check if endpoint is reachable
    log_info "Step 1: Checking endpoint health..."
    if ! check_health "$health_url"; then
        log_error "Health check failed - endpoint unreachable"
        exit 1
    fi
    log_info "✓ Endpoint is healthy"

    # Step 2: Get current metrics
    log_info "Step 2: Fetching health metrics..."
    local metrics
    metrics=$(get_health_metrics "$health_url") || {
        log_error "Failed to fetch metrics"
        exit 3
    }

    # Step 3: Calculate availability
    log_info "Step 3: Calculating availability..."
    local availability
    availability=$(calculate_availability "$metrics") || {
        log_warn "Could not calculate availability from metrics, will use monitoring"
        availability=""
    }

    if [ -n "$availability" ]; then
        log_info "Current availability: ${availability}%"

        # Check if SLO met
        if [ "$(echo "$availability >= $slo_target" | bc)" -eq 1 ]; then
            log_info "✓ Availability SLO met (${availability}% >= ${slo_target}%)"
        else
            log_warn "Availability SLO not met (${availability}% < ${slo_target}%)"
        fi
    fi

    # Step 4: Check additional SLO metrics
    log_info "Step 4: Checking additional SLO metrics..."

    local latency_ok=0
    local error_rate_ok=0

    check_latency_slo "$metrics" "$latency_target" && latency_ok=1
    check_error_rate_slo "$metrics" "$error_rate_target" && error_rate_ok=1

    # Step 5: Monitor over time if needed
    log_info "Step 5: Time-based SLO monitoring..."
    local monitoring_ok=0
    monitor_slo_period "$health_url" "$slo_target" "$monitoring_duration" && monitoring_ok=1

    # Final decision
    log_info "=== SLO Validation Summary ==="

    local violations=0
    if [ -n "$availability" ] && [ "$(echo "$availability < $slo_target" | bc)" -eq 1 ]; then
        log_warn "✗ Availability SLO violated"
        violations=$((violations + 1))
    fi

    if [ "$latency_ok" -eq 0 ]; then
        log_warn "✗ Latency SLO violated"
        violations=$((violations + 1))
    fi

    if [ "$error_rate_ok" -eq 0 ]; then
        log_warn "✗ Error rate SLO violated"
        violations=$((violations + 1))
    fi

    if [ "$monitoring_ok" -eq 0 ]; then
        log_warn "✗ Time-based monitoring SLO violated"
        violations=$((violations + 1))
    fi

    if [ "$violations" -gt 0 ]; then
        log_error "SLO validation failed with $violations violation(s)"
        exit 1
    else
        log_info "✓ All SLO checks passed"
        exit 0
    fi
}

# Run main function
main "$@"

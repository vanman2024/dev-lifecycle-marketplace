#!/usr/bin/env bash
# health-check-test.sh - Reusable health check function template
# Source this file and call check_health in your scripts

check_health() {
  local url="${1:?URL required}"
  local timeout="${2:-10}"
  local expected_status="${3:-200}"

  local http_code
  http_code=$(curl -sf -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url" 2>/dev/null || echo "000")

  if [ "$http_code" = "$expected_status" ]; then
    echo "PASS"
    return 0
  else
    echo "FAIL (got $http_code, expected $expected_status)"
    return 1
  fi
}

# Usage when sourced:
# source health-check-test.sh
# result=$(check_health "http://localhost:3000/api/health")
# echo "Health check: $result"

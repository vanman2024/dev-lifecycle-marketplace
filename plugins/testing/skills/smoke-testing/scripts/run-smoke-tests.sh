#!/usr/bin/env bash
# run-smoke-tests.sh - Orchestrator for all smoke tests
# Usage: bash run-smoke-tests.sh [base-url] [project-path]

set -euo pipefail

BASE_URL="${1:-http://localhost:3000}"
PROJECT_DIR="${2:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULT_DIR="${PROJECT_DIR}/test-results/smoke"
PASSED=0
FAILED=0
TOTAL=0

mkdir -p "$RESULT_DIR"

echo "=== Smoke Tests ==="
echo "Base URL: $BASE_URL"
echo ""

# --- Health Endpoint ---
HEALTH_ENDPOINT="/api/health"

# Try to read from project.json
if command -v jq &>/dev/null && [ -f "$PROJECT_DIR/.claude/project.json" ]; then
  H=$(jq -r '.testing.smoke.health_endpoint // empty' "$PROJECT_DIR/.claude/project.json" 2>/dev/null || true)
  if [ -n "$H" ] && [ "$H" != "null" ]; then
    HEALTH_ENDPOINT="$H"
  fi
fi

echo "--- Health Check: ${HEALTH_ENDPOINT} ---"
TOTAL=$((TOTAL + 1))
HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "${BASE_URL}${HEALTH_ENDPOINT}" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
  echo "  PASS: ${HEALTH_ENDPOINT} -> ${HTTP_CODE}"
  PASSED=$((PASSED + 1))
else
  echo "  FAIL: ${HEALTH_ENDPOINT} -> ${HTTP_CODE}"
  FAILED=$((FAILED + 1))
fi

# --- Critical Paths ---
CRITICAL_PATHS=()

# Read from project.json
if command -v jq &>/dev/null && [ -f "$PROJECT_DIR/.claude/project.json" ]; then
  mapfile -t CRITICAL_PATHS < <(jq -r '.testing.smoke.critical_paths[]? // empty' "$PROJECT_DIR/.claude/project.json" 2>/dev/null || true)
fi

# Default paths if none configured
if [ ${#CRITICAL_PATHS[@]} -eq 0 ]; then
  CRITICAL_PATHS=("/" "/login")
fi

echo ""
echo "--- Critical Paths ---"
for path in "${CRITICAL_PATHS[@]}"; do
  [ -z "$path" ] && continue
  TOTAL=$((TOTAL + 1))
  HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "${BASE_URL}${path}" 2>/dev/null || echo "000")

  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "  PASS: ${path} -> ${HTTP_CODE}"
    PASSED=$((PASSED + 1))
  else
    echo "  FAIL: ${path} -> ${HTTP_CODE}"
    FAILED=$((FAILED + 1))
  fi
done

# --- Write Results ---
echo ""
echo "=== Smoke Test Results ==="
echo "Passed: $PASSED / $TOTAL"
echo "Failed: $FAILED / $TOTAL"

cat > "$RESULT_DIR/results.json" <<EOF
{
  "type": "smoke",
  "base_url": "$BASE_URL",
  "total": $TOTAL,
  "passed": $PASSED,
  "failed": $FAILED,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi

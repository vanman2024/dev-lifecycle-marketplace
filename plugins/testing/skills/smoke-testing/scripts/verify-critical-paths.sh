#!/usr/bin/env bash
# verify-critical-paths.sh - Verify critical paths respond with success status
# Usage: bash verify-critical-paths.sh [base-url] [paths...]
# Example: bash verify-critical-paths.sh http://localhost:3000 / /login /dashboard

set -euo pipefail

BASE_URL="${1:-http://localhost:3000}"
shift || true

PATHS=("$@")
if [ ${#PATHS[@]} -eq 0 ]; then
  PATHS=("/" "/login")
fi

PASSED=0
FAILED=0
TOTAL=${#PATHS[@]}

echo "Verifying $TOTAL critical paths against $BASE_URL"
echo ""

for path in "${PATHS[@]}"; do
  HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" --max-time 10 "${BASE_URL}${path}" 2>/dev/null || echo "000")

  case "$HTTP_CODE" in
    200|201|301|302|304)
      echo "  PASS: ${path} -> ${HTTP_CODE}"
      PASSED=$((PASSED + 1))
      ;;
    000)
      echo "  FAIL: ${path} -> connection refused"
      FAILED=$((FAILED + 1))
      ;;
    *)
      echo "  FAIL: ${path} -> ${HTTP_CODE}"
      FAILED=$((FAILED + 1))
      ;;
  esac
done

echo ""
echo "Results: $PASSED/$TOTAL passed, $FAILED/$TOTAL failed"

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi

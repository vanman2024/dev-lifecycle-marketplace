#!/usr/bin/env bash
# check-health-endpoint.sh - Check a health endpoint returns 200
# Usage: bash check-health-endpoint.sh [url]

set -euo pipefail

URL="${1:-http://localhost:3000/api/health}"
TIMEOUT="${2:-10}"

echo "Checking health: $URL (timeout: ${TIMEOUT}s)"

HTTP_CODE=$(curl -sf -o /tmp/health-response.json -w "%{http_code}" --max-time "$TIMEOUT" "$URL" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
  echo "PASS: Health endpoint returned $HTTP_CODE"
  if [ -f /tmp/health-response.json ] && command -v jq &>/dev/null; then
    echo "Response: $(jq -c '.' /tmp/health-response.json 2>/dev/null || cat /tmp/health-response.json)"
  fi
  exit 0
else
  echo "FAIL: Health endpoint returned $HTTP_CODE"
  if [ "$HTTP_CODE" = "000" ]; then
    echo "  Could not connect to $URL"
    echo "  Is the server running?"
  fi
  exit 1
fi

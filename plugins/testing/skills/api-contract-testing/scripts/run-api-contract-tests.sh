#!/usr/bin/env bash
# run-api-contract-tests.sh - Execute Newman with auth injection and reporting
# Usage: bash run-api-contract-tests.sh <collection> [--auth strategy] [--env env-file]

set -euo pipefail

COLLECTION=""
AUTH_STRATEGY="none"
ENV_FILE=""
RESULT_DIR="test-results/api-contract"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --auth) AUTH_STRATEGY="$2"; shift 2 ;;
    --env) ENV_FILE="$2"; shift 2 ;;
    *) COLLECTION="$1"; shift ;;
  esac
done

if [ -z "$COLLECTION" ]; then
  echo "Usage: run-api-contract-tests.sh <collection.json> [--auth strategy] [--env env-file]"
  echo "Auth strategies: none, supabase_cookie, clerk_jwt, auth0_token, bearer_token, api_key"
  exit 1
fi

if [ ! -f "$COLLECTION" ]; then
  echo "[!] Collection not found: $COLLECTION"
  exit 1
fi

# Check Newman
if ! command -v newman &>/dev/null; then
  echo "[!] Newman not installed. Run: npm install -g newman"
  exit 1
fi

mkdir -p "$RESULT_DIR"

echo "=== API Contract Tests ==="
echo "Collection: $COLLECTION"
echo "Auth: $AUTH_STRATEGY"
echo ""

# Inject auth if needed
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKING_COLLECTION="$COLLECTION"

if [ "$AUTH_STRATEGY" != "none" ]; then
  WORKING_COLLECTION="${RESULT_DIR}/collection-with-auth.json"
  cp "$COLLECTION" "$WORKING_COLLECTION"
  bash "$SCRIPT_DIR/inject-auth.sh" "$WORKING_COLLECTION" "$AUTH_STRATEGY"
fi

# Build Newman command
NEWMAN_CMD="newman run \"$WORKING_COLLECTION\" --reporters cli,json --reporter-json-export \"$RESULT_DIR/newman-results.json\""

if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
  NEWMAN_CMD="$NEWMAN_CMD -e \"$ENV_FILE\""
fi

# Execute
echo "Running Newman..."
eval "$NEWMAN_CMD" || true

# Parse results
if [ -f "$RESULT_DIR/newman-results.json" ] && command -v jq &>/dev/null; then
  echo ""
  echo "=== Results ==="
  TOTAL=$(jq '.run.stats.assertions.total // 0' "$RESULT_DIR/newman-results.json")
  FAILED=$(jq '.run.stats.assertions.failed // 0' "$RESULT_DIR/newman-results.json")
  PASSED=$((TOTAL - FAILED))
  echo "Assertions: $PASSED/$TOTAL passed ($FAILED failed)"

  if [ "$FAILED" -gt 0 ]; then
    echo ""
    echo "Failures:"
    jq -r '.run.executions[] | select(.assertions[]?.error) | .item.name + ": " + (.assertions[] | select(.error) | .error.message)' "$RESULT_DIR/newman-results.json" 2>/dev/null || true
    exit 1
  fi
fi

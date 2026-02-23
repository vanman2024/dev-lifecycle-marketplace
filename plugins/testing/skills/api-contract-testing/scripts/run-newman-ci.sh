#!/usr/bin/env bash
# run-newman-ci.sh - CI-optimized Newman runner with JUnit output
# Usage: bash run-newman-ci.sh <collection> [--env env-file]

set -euo pipefail

COLLECTION=""
ENV_FILE=""
RESULT_DIR="test-results/api-contract"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENV_FILE="$2"; shift 2 ;;
    *) COLLECTION="$1"; shift ;;
  esac
done

if [ -z "$COLLECTION" ] || [ ! -f "$COLLECTION" ]; then
  echo "Usage: run-newman-ci.sh <collection.json> [--env env-file]"
  exit 1
fi

if ! command -v newman &>/dev/null; then
  echo "::error::Newman not installed. Run: npm install -g newman"
  exit 1
fi

mkdir -p "$RESULT_DIR"

echo "::group::Newman API Contract Tests"
echo "Collection: $COLLECTION"

# Build command
CMD="newman run \"$COLLECTION\""
CMD="$CMD --reporters cli,json,junit"
CMD="$CMD --reporter-json-export \"$RESULT_DIR/newman-results.json\""
CMD="$CMD --reporter-junit-export \"$RESULT_DIR/newman-junit.xml\""

if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
  CMD="$CMD -e \"$ENV_FILE\""
fi

# Execute
EXIT_CODE=0
eval "$CMD" || EXIT_CODE=$?

echo "::endgroup::"

# Parse and report
if [ -f "$RESULT_DIR/newman-results.json" ] && command -v jq &>/dev/null; then
  TOTAL=$(jq '.run.stats.assertions.total // 0' "$RESULT_DIR/newman-results.json")
  FAILED=$(jq '.run.stats.assertions.failed // 0' "$RESULT_DIR/newman-results.json")
  PASSED=$((TOTAL - FAILED))
  DURATION=$(jq '.run.timings.completed // 0' "$RESULT_DIR/newman-results.json")

  echo ""
  echo "API Contract Tests: $PASSED/$TOTAL passed ($FAILED failed) ${DURATION}ms"

  if [ "$FAILED" -gt 0 ]; then
    echo ""
    jq -r '.run.executions[] | select(.assertions[]?.error) | "::error::" + .item.name + ": " + (.assertions[] | select(.error) | .error.message)' "$RESULT_DIR/newman-results.json" 2>/dev/null || true
  fi
fi

exit $EXIT_CODE

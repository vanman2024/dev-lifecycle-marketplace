#!/usr/bin/env bash
# run-newman-ci.sh - CI-optimized Newman runner with JUnit output
# Usage: bash run-newman-ci.sh <collection.json> [-e environment.json]
# Produces JUnit XML and JSON reports for CI integration

set -euo pipefail

COLLECTION="${1:?Usage: run-newman-ci.sh <collection.json> [-e environment.json]}"
shift
ENV_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -e) ENV_FILE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

RESULT_DIR="test-results/api-contract"
mkdir -p "$RESULT_DIR"

if ! command -v newman &>/dev/null; then
  echo "::error::Newman not installed. Run: npm install -g newman"
  exit 1
fi

echo "::group::Newman Tests - $(basename "$COLLECTION")"

CMD="newman run \"$COLLECTION\""
CMD="$CMD --reporters cli,json,junit"
CMD="$CMD --reporter-json-export \"$RESULT_DIR/newman-results.json\""
CMD="$CMD --reporter-junit-export \"$RESULT_DIR/newman-junit.xml\""

if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
  CMD="$CMD -e \"$ENV_FILE\""
fi

EXIT_CODE=0
eval "$CMD" || EXIT_CODE=$?

echo "::endgroup::"

# Summary
if [ -f "$RESULT_DIR/newman-results.json" ] && command -v jq &>/dev/null; then
  TOTAL=$(jq '.run.stats.assertions.total // 0' "$RESULT_DIR/newman-results.json")
  FAILED=$(jq '.run.stats.assertions.failed // 0' "$RESULT_DIR/newman-results.json")
  echo "Newman: $((TOTAL - FAILED))/$TOTAL assertions passed"
fi

exit $EXIT_CODE

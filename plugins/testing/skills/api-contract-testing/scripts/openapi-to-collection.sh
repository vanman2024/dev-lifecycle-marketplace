#!/usr/bin/env bash
# openapi-to-collection.sh - Convert OpenAPI spec to Postman collection via Portman
# Usage: bash openapi-to-collection.sh <openapi-spec> [output-collection] [portman-config]

set -euo pipefail

SPEC="${1:?Usage: openapi-to-collection.sh <openapi-spec> [output-collection] [portman-config]}"
OUTPUT="${2:-api-tests.postman_collection.json}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTMAN_CONFIG="${3:-$SCRIPT_DIR/../templates/portman-config.json}"

echo "=== OpenAPI to Postman Collection ==="
echo "Spec:    $SPEC"
echo "Output:  $OUTPUT"
echo ""

# Check if Portman is installed
if ! command -v portman &>/dev/null; then
  echo "[!] Portman not installed. Attempting install..."
  npm install -g @apideck/portman
fi

# Check if spec file exists
if [ ! -f "$SPEC" ]; then
  echo "[!] OpenAPI spec not found: $SPEC"
  exit 1
fi

# Run Portman to convert OpenAPI -> Postman collection with tests
if [ -f "$PORTMAN_CONFIG" ]; then
  echo "Using Portman config: $PORTMAN_CONFIG"
  portman --local "$SPEC" \
    --output "$OUTPUT" \
    --portmanConfigFile "$PORTMAN_CONFIG" \
    2>&1
else
  echo "Using default Portman configuration"
  portman --local "$SPEC" \
    --output "$OUTPUT" \
    2>&1
fi

if [ -f "$OUTPUT" ]; then
  echo ""
  echo "Collection generated: $OUTPUT"

  if command -v jq &>/dev/null; then
    ITEM_COUNT=$(jq '[.. | .item? // empty | .[] ] | length' "$OUTPUT" 2>/dev/null || echo "?")
    echo "Requests: $ITEM_COUNT"
  fi
else
  echo "[!] Failed to generate collection"
  exit 1
fi

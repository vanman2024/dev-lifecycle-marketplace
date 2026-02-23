#!/usr/bin/env bash
# sync-from-routes.sh - Generate Postman collection from route files
# Usage: bash sync-from-routes.sh <routes-dir> [output-collection]
# Scans Next.js App Router API routes or Express route files

set -euo pipefail

ROUTES_DIR="${1:?Usage: sync-from-routes.sh <routes-dir> [output-collection]}"
OUTPUT="${2:-api-routes.postman_collection.json}"

if [ ! -d "$ROUTES_DIR" ]; then
  echo "[!] Routes directory not found: $ROUTES_DIR"
  exit 1
fi

echo "=== Syncing Collection from Routes ==="
echo "Routes: $ROUTES_DIR"
echo "Output: $OUTPUT"
echo ""

ITEMS="[]"

# Scan for Next.js App Router API routes
while IFS= read -r route_file; do
  [ -z "$route_file" ] && continue

  # Extract path from file location
  REL_PATH="${route_file#$ROUTES_DIR}"
  API_PATH="/api${REL_PATH%/route.*}"
  API_PATH="${API_PATH%/}"

  # Detect HTTP methods
  METHODS=""
  grep -oE 'export\s+(async\s+)?function\s+(GET|POST|PUT|PATCH|DELETE)' "$route_file" 2>/dev/null | while read -r line; do
    METHOD=$(echo "$line" | grep -oE '(GET|POST|PUT|PATCH|DELETE)')
    echo "  [+] $METHOD $API_PATH"
  done

  for method in GET POST PUT PATCH DELETE; do
    if grep -q "function $method" "$route_file" 2>/dev/null; then
      if command -v jq &>/dev/null; then
        ITEM=$(jq -n --arg name "$method $API_PATH" --arg method "$method" --arg path "$API_PATH" \
          '{name: $name, request: {method: $method, url: {raw: ("{{base_url}}" + $path), host: ["{{base_url}}"], path: ($path | split("/") | map(select(. != "")))}}}')
        ITEMS=$(echo "$ITEMS" | jq --argjson item "$ITEM" '. + [$item]')
      fi
    fi
  done
done < <(find "$ROUTES_DIR" -name "route.ts" -o -name "route.js" 2>/dev/null)

# Generate collection
if command -v jq &>/dev/null; then
  jq -n --argjson items "$ITEMS" \
    '{info: {name: "API Routes Collection", schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"}, item: $items}' \
    > "$OUTPUT"

  ITEM_COUNT=$(echo "$ITEMS" | jq 'length')
  echo ""
  echo "Collection generated: $OUTPUT ($ITEM_COUNT requests)"
else
  echo "[!] jq required for collection generation"
  exit 1
fi

#!/usr/bin/env bash
# Validate BUILD-GUIDE.json structure

set -e

JSON_FILE="$1"

if [ -z "$JSON_FILE" ]; then
    echo "Usage: $0 <path-to-BUILD-GUIDE.json>"
    exit 1
fi

if [ ! -f "$JSON_FILE" ]; then
    echo "❌ File not found: $JSON_FILE"
    exit 1
fi

echo "🔍 Validating BUILD-GUIDE.json..."

# Check if valid JSON
if ! jq empty "$JSON_FILE" 2>/dev/null; then
    echo "❌ Invalid JSON format"
    exit 1
fi

# Check required fields
REQUIRED_FIELDS=("project" "techStack" "buildLayers" "metadata")

for field in "${REQUIRED_FIELDS[@]}"; do
    if ! jq -e ".$field" "$JSON_FILE" >/dev/null 2>&1; then
        echo "❌ Missing required field: $field"
        exit 1
    fi
    echo "   ✓ $field exists"
done

# Check buildLayers is array with 4 items
LAYER_COUNT=$(jq '.buildLayers | length' "$JSON_FILE")
if [ "$LAYER_COUNT" -ne 4 ]; then
    echo "❌ Expected 4 build layers, found $LAYER_COUNT"
    exit 1
fi
echo "   ✓ 4 build layers present"

echo ""
echo "✅ BUILD-GUIDE.json is valid!"

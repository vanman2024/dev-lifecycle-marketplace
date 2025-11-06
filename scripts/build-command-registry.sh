#!/bin/bash
# Build complete command registry with descriptions

echo "🔍 Building complete command registry..."

REGISTRY_FILE="/tmp/command-registry.json"

# Start JSON
echo '{' > "$REGISTRY_FILE"
echo '  "commands": {' >> "$REGISTRY_FILE"

first=true

# Find all command files
find "$HOME/.claude/plugins/marketplaces" -path "*/commands/*.md" -type f 2>/dev/null | sort | while read -r cmd_file; do
    # Extract plugin name
    plugin=$(echo "$cmd_file" | grep -oP 'plugins/\K[^/]+(?=/commands)')

    # Extract marketplace
    marketplace=$(echo "$cmd_file" | grep -oP 'marketplaces/\K[^/]+(?=/plugins)')

    # Extract command name
    command=$(basename "$cmd_file" .md)

    # Extract description from frontmatter
    description=$(grep -m1 '^description:' "$cmd_file" | sed 's/description: *//g' | tr -d '"' | tr -d "'")

    # Skip if no description
    if [ -z "$description" ]; then
        description="No description"
    fi

    # Add comma if not first
    if [ "$first" = false ]; then
        echo ',' >> "$REGISTRY_FILE"
    fi
    first=false

    # Add entry
    cat >> "$REGISTRY_FILE" << EOF
    "/$plugin:$command": {
      "description": "$description",
      "plugin": "$plugin",
      "marketplace": "$marketplace",
      "file": "$cmd_file"
    }
EOF
done

# Close JSON
echo '' >> "$REGISTRY_FILE"
echo '  }' >> "$REGISTRY_FILE"
echo '}' >> "$REGISTRY_FILE"

echo "✅ Registry built: $REGISTRY_FILE"
echo ""
echo "📊 Statistics:"
jq '.commands | length' "$REGISTRY_FILE" | xargs -I {} echo "Total commands: {}"
echo ""
echo "📋 By marketplace:"
jq -r '.commands | group_by(.marketplace) | map({marketplace: .[0].marketplace, count: length}) | .[] | "\(.marketplace): \(.count)"' "$REGISTRY_FILE"
echo ""
echo "📋 By plugin:"
jq -r '.commands | group_by(.plugin) | map({plugin: .[0].plugin, count: length}) | sort_by(.count) | reverse | .[] | "\(.plugin): \(.count)"' "$REGISTRY_FILE"

# Show sample
echo ""
echo "📄 Sample entries:"
jq '.commands | to_entries | .[0:5] | .[] | "\(.key): \(.value.description)"' "$REGISTRY_FILE"

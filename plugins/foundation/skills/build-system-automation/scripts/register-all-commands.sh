#!/bin/bash
# Register ALL active commands (preserves existing Skills, MCP servers, tools)

set -e

SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_FILE="$SETTINGS_FILE.backup"

echo "🔍 Registering all active commands in $SETTINGS_FILE"
echo "📦 Creating backup: $BACKUP_FILE"
cp "$SETTINGS_FILE" "$BACKUP_FILE"

# Collect ALL active commands (exclude archives, test marketplaces, templates)
echo "🔎 Scanning for active commands..."
ALL_COMMANDS=$(mktemp)

find "$HOME/.claude/plugins/marketplaces" -path "*/commands/*.md" -type f 2>/dev/null | \
  grep -v -E '(\.archive|/archived/|dev-lifecycle-test-agent-001|/templates/|/docs/frameworks/)' | \
  sort | while read -r cmd_file; do
    plugin=$(echo "$cmd_file" | grep -oP 'plugins/\K[^/]+(?=/commands)')
    command=$(basename "$cmd_file" .md)
    echo "SlashCommand(/$plugin:$command)"
done > "$ALL_COMMANDS"

TOTAL_FOUND=$(wc -l < "$ALL_COMMANDS")
echo "📊 Found $TOTAL_FOUND active commands"

# Extract EXISTING permissions from settings.json
EXISTING_ALLOW=$(mktemp)
jq -r '.permissions.allow[]' "$SETTINGS_FILE" > "$EXISTING_ALLOW"

# Count current commands
CURRENT_COMMANDS=$(grep -c '^SlashCommand(' "$EXISTING_ALLOW" || true)
echo "📊 Currently registered: $CURRENT_COMMANDS commands"

# Find missing commands
echo ""
echo "➕ Missing commands (first 20):"
MISSING_COMMANDS=$(mktemp)
comm -13 \
  <(grep '^SlashCommand(' "$EXISTING_ALLOW" | sort) \
  <(cat "$ALL_COMMANDS" | sort) > "$MISSING_COMMANDS"

head -20 "$MISSING_COMMANDS"

MISSING_COUNT=$(wc -l < "$MISSING_COMMANDS")
if [ "$MISSING_COUNT" -eq 0 ]; then
  echo "✅ All commands already registered!"
  rm "$ALL_COMMANDS" "$EXISTING_ALLOW" "$MISSING_COMMANDS"
  exit 0
fi

echo ""
echo "📝 Adding $MISSING_COUNT missing commands..."

# Build updated allow array
UPDATED_ALLOW=$(mktemp)

# Add ALL existing entries FIRST (preserves Skills, MCP, tools)
cat "$EXISTING_ALLOW" > "$UPDATED_ALLOW"

# Remove the generic "SlashCommand" wildcard if it exists
sed -i '/^SlashCommand$/d' "$UPDATED_ALLOW"

# Add missing commands
cat "$MISSING_COMMANDS" >> "$UPDATED_ALLOW"

# Re-add the generic wildcard at the end
echo "SlashCommand" >> "$UPDATED_ALLOW"

# Sort allow array for readability (keeps related items together)
SORTED_ALLOW=$(mktemp)
{
  # Commands first (sorted)
  grep '^SlashCommand(' "$UPDATED_ALLOW" | sort -u

  # Then non-command entries (preserve original order)
  grep -v '^SlashCommand' "$UPDATED_ALLOW"
} > "$SORTED_ALLOW"

# Update settings.json using jq (preserves structure perfectly)
jq --arg allow "$(cat "$SORTED_ALLOW" | jq -R . | jq -s .)" \
   '.permissions.allow = ($allow | fromjson)' \
   "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"

mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

# Cleanup
rm "$ALL_COMMANDS" "$EXISTING_ALLOW" "$MISSING_COMMANDS" "$UPDATED_ALLOW" "$SORTED_ALLOW"

echo ""
echo "✅ Registration complete!"
echo "📊 Now registered: $(jq '.permissions.allow | map(select(startswith("SlashCommand("))) | length' "$SETTINGS_FILE") commands"
echo "📊 Skills preserved: $(jq '.permissions.allow | map(select(startswith("Skill("))) | length' "$SETTINGS_FILE") skills"
echo "💾 Backup saved: $BACKUP_FILE"
echo ""
echo "🔍 Sample registered commands:"
jq -r '.permissions.allow | map(select(startswith("SlashCommand("))) | .[0:10] | .[]' "$SETTINGS_FILE"

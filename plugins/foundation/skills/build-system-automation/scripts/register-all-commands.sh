#!/bin/bash
# Register ALL active commands (excludes .archive, test marketplaces, templates)

set -e

SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d-%H%M%S)"

echo "🔍 Registering all active commands in $SETTINGS_FILE"
echo "📦 Creating backup: $BACKUP_FILE"
cp "$SETTINGS_FILE" "$BACKUP_FILE"

# Collect ALL active commands (exclude archives, test marketplaces, templates)
echo "🔎 Scanning for active commands..."
ALL_COMMANDS=$(mktemp)

find "$HOME/.claude/plugins/marketplaces" -path "*/commands/*.md" -type f 2>/dev/null | \
  grep -v -E '(\.archive|/archived/|dev-lifecycle-test-agent-001|/templates/|/docs/frameworks/)' | \
  sort | while read -r cmd_file; do
    # Extract plugin name (handle both direct plugins/ and nested structures)
    plugin=$(echo "$cmd_file" | grep -oP 'plugins/\K[^/]+(?=/commands)')
    command=$(basename "$cmd_file" .md)
    echo "SlashCommand(/$plugin:$command)"
done > "$ALL_COMMANDS"

TOTAL_FOUND=$(wc -l < "$ALL_COMMANDS")
echo "📊 Found $TOTAL_FOUND active commands"

# Read current settings
CURRENT_COMMANDS=$(grep -o 'SlashCommand([^)]*' "$SETTINGS_FILE" | wc -l)
echo "📊 Currently registered: $CURRENT_COMMANDS commands"

# Find what's missing
echo ""
echo "➕ Missing commands (first 20):"
comm -13 <(grep -o 'SlashCommand([^)]*)' "$SETTINGS_FILE" | sed 's/SlashCommand(//; s/)//' | sort) \
         <(sed 's/SlashCommand(//; s/)//' "$ALL_COMMANDS" | sort) | head -20

# Extract existing sections from settings.json
TEMP_SETTINGS=$(mktemp)
TEMP_ALLOW_ARRAY=$(mktemp)

# Get everything before "allow": [
sed -n '1,/"allow": \[/p' "$SETTINGS_FILE" > "$TEMP_SETTINGS"

# Build new allow array
{
  # Add all commands (sorted, unique)
  sed 's/^/      "/; s/$/",/' "$ALL_COMMANDS" | sort -u

  # Add core tools
  echo '      "Bash",'
  echo '      "Read",'
  echo '      "Write",'
  echo '      "Edit",'
  echo '      "MultiEdit",'
  echo '      "LS",'
  echo '      "Grep",'
  echo '      "Glob",'
  echo '      "Task",'
  echo '      "TodoWrite",'
  echo '      "TodoRead",'
  echo '      "WebFetch",'
  echo '      "WebSearch",'
  echo '      "NotebookRead",'
  echo '      "NotebookEdit",'
  echo '      "ExitPlanMode",'
  echo '      "ListMcpResourcesTool",'
  echo '      "ReadMcpResourceTool",'
  echo '      "BashOutput",'
  echo '      "KillShell",'
  echo '      "AskUserQuestion",'
  echo '      "Skill",'
  echo '      "SlashCommand",'

  # Add MCP servers
  echo '      "mcp__github",'
  echo '      "mcp__supabase",'
  echo '      "mcp__shadcn",'
  echo '      "mcp__puppeteer",'
  echo '      "mcp__vercel-v0-enhanced",'
  echo '      "mcp__docker",'
  echo '      "mcp__memory",'
  echo '      "mcp__filesystem",'
  echo '      "mcp__sequential-thinking",'
  echo '      "mcp__ide",'
  echo '      "mcp__figma-mcp-application",'
  echo '      "mcp__ngrok",'
  echo '      "mcp__everything",'
  echo '      "mcp__postman",'
  echo '      "mcp__fetch",'
  echo '      "mcp__browserbase",'
  echo '      "mcp__vercel-deploy",'
  echo '      "mcp__uiux-design",'
  echo '      "mcp__gemini",'
  echo '      "mcp__slack",'
  echo '      "mcp__redis",'
  echo '      "mcp__notion",'
  echo '      "mcp__playwright",'
  echo '      "mcp__google-drive",'
  echo '      "mcp__google-sheets",'
  echo '      "mcp__google-docs",'
  echo '      "mcp__google-tasks",'
  echo '      "mcp__google-gmail",'
  echo '      "mcp__google-calendar",'
  echo '      "mcp__google-apps-script",'
  echo '      "mcp__context7",'
  echo '      "mcp__plugin_supabase_supabase",'
  echo '      "mcp__plugin_deployment_sentry",'
  echo '      "mcp__plugin_nextjs-frontend_shadcn",'
  echo '      "mcp__plugin_nextjs-frontend_design-system"'
} > "$TEMP_ALLOW_ARRAY"

# Remove trailing comma from last line
sed -i '$ s/,$//' "$TEMP_ALLOW_ARRAY"

# Append allow array
cat "$TEMP_ALLOW_ARRAY" >> "$TEMP_SETTINGS"

# Close allow array
echo '    ],' >> "$TEMP_SETTINGS"
echo '    "deny": [],' >> "$TEMP_SETTINGS"
echo '    "defaultMode": "acceptEdits",' >> "$TEMP_SETTINGS"
echo '    "additionalDirectories": [' >> "$TEMP_SETTINGS"
echo '      "/tmp"' >> "$TEMP_SETTINGS"
echo '    ]' >> "$TEMP_SETTINGS"
echo '  },' >> "$TEMP_SETTINGS"

# Copy hooks section from original
sed -n '/"hooks": {/,/^  },$/p' "$SETTINGS_FILE" >> "$TEMP_SETTINGS"

# Copy enabledPlugins section
sed -n '/"enabledPlugins": {/,/^  },$/p' "$SETTINGS_FILE" >> "$TEMP_SETTINGS"

# Copy alwaysThinkingEnabled
sed -n '/"alwaysThinkingEnabled":/p' "$SETTINGS_FILE" >> "$TEMP_SETTINGS"

# Close main object
echo '}' >> "$TEMP_SETTINGS"

# Replace original
mv "$TEMP_SETTINGS" "$SETTINGS_FILE"

# Cleanup
rm "$ALL_COMMANDS" "$TEMP_ALLOW_ARRAY"

echo ""
echo "✅ Registration complete!"
echo "📊 Now registered: $(grep -c 'SlashCommand' "$SETTINGS_FILE") commands"
echo "💾 Backup saved: $BACKUP_FILE"
echo ""
echo "🔍 Sample registered commands:"
grep 'SlashCommand' "$SETTINGS_FILE" | head -10

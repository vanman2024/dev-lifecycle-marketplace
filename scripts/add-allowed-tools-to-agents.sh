#!/bin/bash

# Script to add allowed-tools to all agent frontmatter across all marketplaces
# This ensures agents can use SlashCommand tool to execute slash commands

MARKETPLACES_DIR="/home/gotime2022/.claude/plugins/marketplaces"
ALLOWED_TOOLS="allowed-tools: Read, Write, Bash(*), Grep, Glob, SlashCommand, TodoWrite"

echo "=========================================="
echo "Adding allowed-tools to all agents"
echo "=========================================="
echo ""

total_agents=0
updated_agents=0
skipped_agents=0

# Find all agent files across all marketplaces
find "$MARKETPLACES_DIR" -type f -path "*/plugins/*/agents/*.md" 2>/dev/null | while read -r agent_file; do
    ((total_agents++)) || true

    agent_name=$(basename "$agent_file" .md)
    plugin_dir=$(dirname "$(dirname "$agent_file")")
    plugin_name=$(basename "$plugin_dir")
    marketplace_dir=$(dirname "$(dirname "$plugin_dir")"

)
    marketplace_name=$(basename "$marketplace_dir")

    echo "Processing: $marketplace_name/$plugin_name/$agent_name"

    # Check if already has allowed-tools
    if grep -q "^allowed-tools:" "$agent_file"; then
        echo "  ✓ Already has allowed-tools"
        ((skipped_agents++)) || true
        continue
    fi

    # Check if has frontmatter
    if ! head -1 "$agent_file" | grep -q "^---$"; then
        echo "  ⚠️  No frontmatter, skipping"
        continue
    fi

    # Add allowed-tools before closing ---
    # Find line number of second ---
    second_dash=$(awk '/^---$/ {count++; if (count==2) {print NR; exit}}' "$agent_file")

    if [ -z "$second_dash" ]; then
        echo "  ⚠️  Invalid frontmatter, skipping"
        continue
    fi

    # Insert allowed-tools line before the closing ---
    sed -i "${second_dash}i${ALLOWED_TOOLS}" "$agent_file"

    echo "  ✅ Added allowed-tools"
    ((updated_agents++)) || true
done

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Total agents processed: $total_agents"
echo "Agents updated: $updated_agents"
echo "Agents skipped: $skipped_agents"
echo ""
echo "✅ Done!"

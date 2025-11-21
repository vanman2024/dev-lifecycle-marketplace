#!/bin/bash

# Script to update all agents to use Skill instead of SlashCommand in allowed-tools
# Agents should load skills for knowledge/templates, not execute slash commands

MARKETPLACES_DIR="/home/gotime2022/.claude/plugins/marketplaces"

echo "=========================================="
echo "Updating agent allowed-tools"
echo "=========================================="
echo ""
echo "Changes:"
echo "  Remove: SlashCommand (agents shouldn't spawn commands)"
echo "  Add: Skill (agents should use skills for knowledge)"
echo ""

total=0
updated=0

# Find all agent files across all marketplaces
find "$MARKETPLACES_DIR" -type f -path "*/plugins/*/agents/*.md" 2>/dev/null | while read -r agent_file; do
    ((total++)) || true

    agent_name=$(basename "$agent_file" .md)

    # Check if has SlashCommand in allowed-tools
    if grep -q "^allowed-tools:.*SlashCommand" "$agent_file"; then
        echo "Updating: $agent_name"

        # Replace SlashCommand with Skill in allowed-tools line
        sed -i 's/allowed-tools: Read, Write, Bash(\*), Grep, Glob, SlashCommand, TodoWrite/allowed-tools: Read, Write, Bash(*), Grep, Glob, Skill, TodoWrite/' "$agent_file"

        ((updated++)) || true
        echo "  ✅ Replaced SlashCommand → Skill"
    fi
done

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Total agents processed: $total"
echo "Agents updated: $updated"
echo ""
echo "✅ Done!"
echo ""
echo "Next step: Add Skill() invocations to agent bodies"

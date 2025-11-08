#!/bin/bash
# Show agent-auditor workflow for testing

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 AGENT-AUDITOR WORKFLOW: START → MIDDLE → END"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo "📋 STEP 1: START - Get Records from Airtable"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Query: Get all commands from ai-tech-stack-1 plugin"
echo "Result: List of record IDs, names, file paths"
echo

# Find actual ai-tech-stack-1 commands
echo "Actual files found in ai-tech-stack-1:"
echo
AI_COMMANDS=$(find /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/ai-tech-stack-1/commands -name "*.md" -type f | head -10)

i=1
for cmd_file in $AI_COMMANDS; do
    cmd_name=$(basename "$cmd_file" .md)
    echo "$i. $cmd_name"
    echo "   File: ai-tech-stack-1/commands/$cmd_name.md"

    # Count slash commands in file
    slash_count=$(grep -o '!{slashcommand' "$cmd_file" 2>/dev/null | wc -l)
    echo "   Slash commands: $slash_count"

    if [ $slash_count -ge 3 ]; then
        echo "   ⚠️  POTENTIAL ANTI-PATTERN (3+ commands chained)"
    fi
    echo
    ((i++))
done

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 STEP 2: MIDDLE - Spawn Agent-Auditors in Parallel"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "In Claude Code, you would run:"
echo
echo "Task(description='Audit cmd 1', subagent_type='quality:agent-auditor', prompt='...')"
echo "Task(description='Audit cmd 2', subagent_type='quality:agent-auditor', prompt='...')"
echo "Task(description='Audit cmd 3', subagent_type='quality:agent-auditor', prompt='...')"
echo "... (all 10 in parallel)"
echo
echo "Each agent:"
echo "  1. Reads the command file"
echo "  2. Scans for !{slashcommand ...} patterns"
echo "  3. Counts total chained commands"
echo "  4. Detects anti-pattern if 3+"
echo "  5. Generates findings"
echo "  6. Writes to Airtable Notes field"
echo

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 STEP 3: END - Results Written to Airtable"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Each agent updates the Notes field in Airtable:"
echo

# Show example for first command
first_cmd=$(find /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/ai-tech-stack-1/commands -name "*.md" -type f | head -1)
first_name=$(basename "$first_cmd" .md)
slash_count=$(grep -o '!{slashcommand' "$first_cmd" 2>/dev/null | wc -l)

echo "Example for: $first_name.md"
echo "Slash commands found: $slash_count"
echo

if [ $slash_count -ge 3 ]; then
    echo "Notes field gets updated with:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  AUDIT FINDINGS:"
    echo
    echo "COMMAND CHAINING:"
    echo "🚨 ANTI-PATTERN: Chains $slash_count slash commands - should spawn agents using Task() instead"
    echo "⚡ Parallelization opportunity - spawn agents in parallel, not sequential commands"
    echo

    # Extract actual slash commands
    echo "Commands found:"
    grep -o '!{slashcommand [^}]*' "$first_cmd" 2>/dev/null | sed 's/!{slashcommand /  - /' | head -10

    echo
    echo "RECOMMENDED REFACTOR:"
    echo "Replace sequential command chaining with parallel agent orchestration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "Notes field gets updated with:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  AUDIT FINDINGS:"
    echo
    echo "COMMAND CHAINING:"
    echo "✅ No anti-pattern detected (only $slash_count commands chained)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ WORKFLOW COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "What happens:"
echo "  ✓ 10 agent-auditors run in parallel"
echo "  ✓ Each analyzes 1 command file"
echo "  ✓ Each writes findings to Airtable Notes"
echo "  ✓ Results visible in Airtable immediately"
echo
echo "Time: ~2-3 minutes for 10 commands in parallel"
echo "      (~20-30 minutes if run sequentially)"
echo

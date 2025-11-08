#!/usr/bin/env bash
# Fix: Change AIRTABLE_API_KEY to AIRTABLE_TOKEN in all scripts

SCRIPTS_DIR="/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/scripts"

echo "🔧 Renaming AIRTABLE_API_KEY to AIRTABLE_TOKEN..."
echo ""

for script in "$SCRIPTS_DIR"/*.py; do
    if grep -q "AIRTABLE_API_KEY" "$script" 2>/dev/null; then
        echo "📝 Fixing: $(basename $script)"

        # Replace all instances
        sed -i 's/AIRTABLE_API_KEY/AIRTABLE_TOKEN/g' "$script"

        echo "   ✓ Updated"
    fi
done

echo ""
echo "✅ All scripts updated to use AIRTABLE_TOKEN!"

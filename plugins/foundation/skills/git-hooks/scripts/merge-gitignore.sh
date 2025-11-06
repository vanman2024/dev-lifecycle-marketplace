#!/bin/bash
# ===================================================================
# Merge .gitignore - Smart merge that preserves existing entries
# ===================================================================

set -e

TEMPLATE_PATH="$HOME/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/git-hooks/templates/gitignore-comprehensive.template"
TARGET_GITIGNORE="${1:-.gitignore}"

echo "🔒 Merging comprehensive .gitignore template..."

# Check if template exists
if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "❌ Error: Template not found at $TEMPLATE_PATH"
    exit 1
fi

# Backup existing .gitignore if it exists
if [ -f "$TARGET_GITIGNORE" ]; then
    BACKUP="${TARGET_GITIGNORE}.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$TARGET_GITIGNORE" "$BACKUP"
    echo "📦 Backed up existing .gitignore to $BACKUP"

    # Create merged version
    TEMP_FILE=$(mktemp)

    # Start with existing content (preserving user's custom entries)
    cat "$TARGET_GITIGNORE" > "$TEMP_FILE"

    # Add separator
    echo "" >> "$TEMP_FILE"
    echo "# ====================================================================" >> "$TEMP_FILE"
    echo "# SECURITY ADDITIONS (Auto-merged by Claude Code)" >> "$TEMP_FILE"
    echo "# ====================================================================" >> "$TEMP_FILE"

    # Add template entries that don't already exist
    while IFS= read -r line; do
        # Skip empty lines and comments from template
        if [[ -z "$line" ]] || [[ "$line" =~ ^#.*$ ]]; then
            echo "$line" >> "$TEMP_FILE"
            continue
        fi

        # Check if pattern already exists in current .gitignore
        # Use exact match to avoid false positives
        if ! grep -Fxq "$line" "$TARGET_GITIGNORE"; then
            echo "$line" >> "$TEMP_FILE"
        fi
    done < "$TEMPLATE_PATH"

    # Replace original with merged version
    mv "$TEMP_FILE" "$TARGET_GITIGNORE"

    echo "✅ Merged .gitignore successfully"
    echo "   - Preserved your existing entries"
    echo "   - Added missing security patterns"
    echo "   - Backup saved to: $BACKUP"
else
    # No existing .gitignore, just copy template
    cp "$TEMPLATE_PATH" "$TARGET_GITIGNORE"
    echo "✅ Created new .gitignore from comprehensive template"
fi

# Display critical protections
echo ""
echo "🔒 Critical protections now active:"
echo "   ✓ .mcp.json (and all variants)"
echo "   ✓ .env* (all environment files)"
echo "   ✓ *.key, *.pem (private keys)"
echo "   ✓ credentials.json, secrets/"
echo "   ✓ service-account*.json"
echo ""
echo "📊 Total patterns: $(grep -v '^#' "$TARGET_GITIGNORE" | grep -v '^$' | wc -l)"

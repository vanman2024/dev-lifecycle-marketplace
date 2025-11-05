#!/bin/bash
#
# Create spec folder structure from feature breakdown JSON
# Usage: ./create-spec-structure.sh
#
# Reads: .wizard/feature-breakdown.json
# Creates: specs/features/NNN-name/ with spec.md and tasks.md
#

set -e

BREAKDOWN_FILE=".wizard/feature-breakdown.json"
TEMPLATE_DIR="$(dirname "$0")/../templates"
SPEC_TEMPLATE="$TEMPLATE_DIR/feature-spec-minimal.md"
TASKS_TEMPLATE="$TEMPLATE_DIR/feature-tasks-minimal.md"

# Check if breakdown file exists
if [ ! -f "$BREAKDOWN_FILE" ]; then
    echo "❌ Error: $BREAKDOWN_FILE not found"
    echo "Run the wizard first to generate feature breakdown"
    exit 1
fi

# Check if templates exist
if [ ! -f "$SPEC_TEMPLATE" ] || [ ! -f "$TASKS_TEMPLATE" ]; then
    echo "❌ Error: Template files not found"
    echo "Expected: $SPEC_TEMPLATE"
    echo "Expected: $TASKS_TEMPLATE"
    exit 1
fi

# Create specs/features directory
mkdir -p specs/features

# Extract features from JSON and create folders
echo "Creating feature spec structure..."
echo ""

jq -r '.features[] | "\(.number)|\(.name)|\(.focus // .shortName)"' "$BREAKDOWN_FILE" | while IFS='|' read -r num name focus; do
    FEATURE_DIR="specs/features/${num}-${name}"

    # Create directory
    mkdir -p "$FEATURE_DIR"

    # Create spec.md from template
    sed -e "s/{feature-name}/${name}/g" \
        -e "s/{brief-description}/${focus}/g" \
        -e "s/{number}/${num}/g" \
        "$SPEC_TEMPLATE" > "$FEATURE_DIR/spec.md"

    # Create tasks.md from template
    sed -e "s/{feature-name}/${name}/g" \
        "$TASKS_TEMPLATE" > "$FEATURE_DIR/tasks.md"

    echo "✓ Created $FEATURE_DIR"
done

echo ""
echo "✅ Spec structure created!"
echo ""
echo "Summary:"
FEATURE_COUNT=$(jq '.features | length' "$BREAKDOWN_FILE")
echo "  Features: $FEATURE_COUNT"
echo ""
echo "Next steps:"
echo "  1. Review specs/features/ structure"
echo "  2. Run feature-spec-writer agents to fill content"
echo "  3. Create worktrees: /supervisor:init --all"
echo ""

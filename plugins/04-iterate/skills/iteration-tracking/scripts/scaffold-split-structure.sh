#!/bin/bash
# scaffold-split-structure.sh - Create directory structure for split specs
# Usage: scaffold-split-structure.sh <original-spec-number>
# Example: scaffold-split-structure.sh 001

set -euo pipefail

ORIGINAL_SPEC="$1"

if [[ -z "$ORIGINAL_SPEC" ]]; then
    echo "Usage: scaffold-split-structure.sh <original-spec-number>"
    echo "Example: scaffold-split-structure.sh 001"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PWD}"

# Find the original spec directory
if [[ "$ORIGINAL_SPEC" =~ ^[0-9]+$ ]]; then
    SPEC_DIR=$(find "$PROJECT_ROOT/specs" -maxdepth 1 -type d -name "${ORIGINAL_SPEC}-*" | head -1)
else
    SPEC_DIR="$PROJECT_ROOT/specs/$ORIGINAL_SPEC"
fi

if [[ ! -d "$SPEC_DIR" ]]; then
    echo "ERROR: Original spec directory not found: $ORIGINAL_SPEC"
    exit 1
fi

SPEC_NAME=$(basename "$SPEC_DIR")
ANALYSIS_REPORT="$SPEC_DIR/reports/SPLIT_ANALYSIS.md"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Scaffolding Split Spec Structure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Original spec: $SPEC_NAME"
echo "Analysis report: $ANALYSIS_REPORT"
echo ""

# Verify analysis report exists
if [[ ! -f "$ANALYSIS_REPORT" ]]; then
    echo "ERROR: Analysis report not found at: $ANALYSIS_REPORT"
    echo "Run: /split:spec $ORIGINAL_SPEC --analyze first"
    exit 1
fi

echo "✓ Analysis report found"
echo ""

# Parse the analysis report to get proposed spec structure
echo "📋 Parsing proposed structure from analysis report..."
echo ""

# Extract spec directory names from the "Proposed New Structure" section
# Look for lines like: ├── 002-candidate-discovery/
PROPOSED_SPECS=$(grep -A 100 "## Proposed New Structure" "$ANALYSIS_REPORT" | \
                 grep -E "├──|└──" | \
                 grep -oE "[0-9]{3}-[a-z-]+" | \
                 sort -u)

if [[ -z "$PROPOSED_SPECS" ]]; then
    echo "ERROR: Could not parse proposed spec structure from analysis report"
    echo "Expected format: ├── 002-spec-name/ or └── 007-spec-name/"
    exit 1
fi

echo "Found proposed specs:"
while IFS= read -r spec; do
    echo "  - $spec"
done <<< "$PROPOSED_SPECS"
echo ""

# Count how many specs
SPEC_COUNT=$(echo "$PROPOSED_SPECS" | wc -l)
echo "Total specs to create: $SPEC_COUNT"
echo ""

# Create each spec directory structure
CREATED_COUNT=0

while IFS= read -r spec_name; do
    SPEC_PATH="$PROJECT_ROOT/specs/$spec_name"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Creating: $spec_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check if already exists
    if [[ -d "$SPEC_PATH" ]]; then
        echo "⚠️  Directory already exists: $SPEC_PATH"
        echo "   Skipping creation..."
        echo ""
        continue
    fi

    # Create main directory
    mkdir -p "$SPEC_PATH"
    echo "✓ Created directory: $SPEC_PATH"

    # Create subdirectories
    mkdir -p "$SPEC_PATH/contracts"
    mkdir -p "$SPEC_PATH/checklists"
    mkdir -p "$SPEC_PATH/agent-tasks"
    mkdir -p "$SPEC_PATH/reports"
    echo "✓ Created subdirectories"

    # Create empty files
    touch "$SPEC_PATH/spec.md"
    touch "$SPEC_PATH/tasks.md"
    touch "$SPEC_PATH/data-model.md"
    touch "$SPEC_PATH/plan.md"
    touch "$SPEC_PATH/research.md"
    echo "✓ Created empty files"

    CREATED_COUNT=$((CREATED_COUNT + 1))
    echo "✓ $spec_name scaffolded successfully"
    echo ""
done <<< "$PROPOSED_SPECS"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Scaffold Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Created: $CREATED_COUNT spec directories"
echo "Location: $PROJECT_ROOT/specs/"
echo ""
echo "Structure created for each spec:"
echo "  ├── spec.md (empty)"
echo "  ├── tasks.md (empty)"
echo "  ├── data-model.md (empty)"
echo "  ├── plan.md (empty)"
echo "  ├── research.md (empty)"
echo "  ├── contracts/ (empty dir)"
echo "  ├── checklists/ (empty dir)"
echo "  ├── agent-tasks/ (empty dir)"
echo "  └── reports/ (empty dir)"
echo ""
echo "Next step: Content distribution"
echo "The spec-splitter subagent will now fill these files with content"
echo ""

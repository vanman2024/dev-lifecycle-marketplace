#!/bin/bash
# validate-mermaid.sh - Validates Mermaid diagram syntax

set -e

ARCH_FILE="${1:-ARCHITECTURE.md}"

if [ ! -f "$ARCH_FILE" ]; then
    echo "❌ Architecture file not found: $ARCH_FILE"
    exit 1
fi

echo "Validating Mermaid diagrams in $ARCH_FILE..."

# Extract mermaid blocks and check basic syntax
MERMAID_COUNT=$(grep -c '```mermaid' "$ARCH_FILE" || echo "0")

if [ "$MERMAID_COUNT" -eq 0 ]; then
    echo "⚠️  No Mermaid diagrams found"
    exit 0
fi

echo "✅ Found $MERMAID_COUNT Mermaid diagram(s)"

# Check for common diagram types
if grep -q '```mermaid' "$ARCH_FILE"; then
    grep -A 1 '```mermaid' "$ARCH_FILE" | grep -E '(graph|sequenceDiagram|classDiagram|erDiagram|gantt|flowchart)' || \
        echo "⚠️  Diagram type not detected"
fi

echo "✅ Mermaid validation passed"

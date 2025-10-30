#!/usr/bin/env bash
#
# export-diagrams.sh - Extract mermaid diagrams from markdown to separate files
#
# Usage: ./export-diagrams.sh <markdown-file> <output-dir>
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MARKDOWN_FILE="${1:-}"
OUTPUT_DIR="${2:-diagrams}"

if [[ -z "$MARKDOWN_FILE" ]]; then
    echo -e "${RED}Error: Markdown file is required${NC}"
    echo "Usage: $0 <markdown-file> <output-dir>"
    exit 1
fi

if [[ ! -f "$MARKDOWN_FILE" ]]; then
    echo -e "${RED}Error: File not found: $MARKDOWN_FILE${NC}"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}Extracting diagrams from: $MARKDOWN_FILE${NC}"
echo -e "${GREEN}Output directory: $OUTPUT_DIR${NC}"
echo ""

# Variables for tracking state
IN_MERMAID=false
DIAGRAM_NUM=0
DIAGRAM_CONTENT=""
DIAGRAM_TITLE=""
PREV_LINE=""

# Process the markdown file
while IFS= read -r line; do
    # Check for diagram title (heading before mermaid block)
    if [[ "$line" =~ ^#+\ (.+) ]]; then
        DIAGRAM_TITLE="${BASH_REMATCH[1]}"
        # Convert title to filename-safe format
        DIAGRAM_TITLE=$(echo "$DIAGRAM_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    fi

    # Check for mermaid code block start
    if [[ "$line" =~ ^\`\`\`mermaid ]]; then
        IN_MERMAID=true
        DIAGRAM_CONTENT=""
        ((DIAGRAM_NUM++))
        continue
    fi

    # Check for code block end
    if [[ "$line" =~ ^\`\`\`$ ]] && [[ "$IN_MERMAID" = true ]]; then
        IN_MERMAID=false

        # Determine filename
        if [[ -n "$DIAGRAM_TITLE" ]]; then
            FILENAME="${OUTPUT_DIR}/${DIAGRAM_NUM}-${DIAGRAM_TITLE}.mmd"
        else
            FILENAME="${OUTPUT_DIR}/diagram-${DIAGRAM_NUM}.mmd"
        fi

        # Write diagram to file
        echo "$DIAGRAM_CONTENT" > "$FILENAME"
        echo -e "${GREEN}Exported diagram $DIAGRAM_NUM: $FILENAME${NC}"

        # Reset title for next diagram
        DIAGRAM_TITLE=""
        continue
    fi

    # Collect mermaid content
    if [[ "$IN_MERMAID" = true ]]; then
        if [[ -z "$DIAGRAM_CONTENT" ]]; then
            DIAGRAM_CONTENT="$line"
        else
            DIAGRAM_CONTENT="${DIAGRAM_CONTENT}\n${line}"
        fi
    fi
done < "$MARKDOWN_FILE"

# Create index file
INDEX_FILE="${OUTPUT_DIR}/index.md"
cat > "$INDEX_FILE" <<EOF
# Extracted Diagrams

Diagrams extracted from: \`$MARKDOWN_FILE\`

Total diagrams: $DIAGRAM_NUM

## Diagram List

EOF

# List all exported diagrams
COUNTER=1
for diagram in "$OUTPUT_DIR"/*.mmd; do
    if [[ -f "$diagram" ]]; then
        BASENAME=$(basename "$diagram" .mmd)
        echo "- [$BASENAME](./$BASENAME.mmd)" >> "$INDEX_FILE"
        ((COUNTER++))
    fi
done

cat >> "$INDEX_FILE" <<EOF

## Viewing Diagrams

You can view these diagrams using:

1. **Mermaid Live Editor**: https://mermaid.live/
2. **VS Code Extension**: Markdown Preview Mermaid Support
3. **GitHub**: Renders mermaid in markdown files automatically

## Re-embedding Diagrams

To embed a diagram in markdown:

\`\`\`markdown
\`\`\`mermaid
$(cat "$OUTPUT_DIR"/1-*.mmd 2>/dev/null || echo "graph TD\n    A --> B")
\`\`\`
\`\`\`
EOF

echo ""
echo -e "${GREEN}Diagram export complete!${NC}"
echo ""
echo "Exported $DIAGRAM_NUM diagrams to: $OUTPUT_DIR"
echo "Index file created: $INDEX_FILE"
echo ""
echo "Next steps:"
echo "  1. Review extracted diagrams in: $OUTPUT_DIR"
echo "  2. View index: cat $INDEX_FILE"
echo "  3. Edit diagrams: vim $OUTPUT_DIR/*.mmd"
echo "  4. Validate diagrams: bash scripts/validate-mermaid.sh <diagram-file>"
echo ""

#!/usr/bin/env bash
#
# validate-mermaid.sh - Validate mermaid diagram syntax in markdown files
#
# Usage: ./validate-mermaid.sh <markdown-file>
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MARKDOWN_FILE="${1:-}"

if [[ -z "$MARKDOWN_FILE" ]]; then
    echo -e "${RED}Error: Markdown file is required${NC}"
    echo "Usage: $0 <markdown-file>"
    exit 1
fi

if [[ ! -f "$MARKDOWN_FILE" ]]; then
    echo -e "${RED}Error: File not found: $MARKDOWN_FILE${NC}"
    exit 1
fi

echo "Validating mermaid diagrams in: $MARKDOWN_FILE"
echo ""

# Extract mermaid code blocks
TEMP_FILE=$(mktemp)
IN_MERMAID=false
LINE_NUM=0
DIAGRAM_NUM=0
ERROR_COUNT=0
WARNING_COUNT=0

while IFS= read -r line; do
    ((LINE_NUM++))

    # Check for mermaid code block start
    if [[ "$line" =~ ^\`\`\`mermaid ]]; then
        IN_MERMAID=true
        ((DIAGRAM_NUM++))
        DIAGRAM_START_LINE=$LINE_NUM
        DIAGRAM_TYPE=""
        echo -e "${GREEN}Found diagram #$DIAGRAM_NUM at line $LINE_NUM${NC}"
        continue
    fi

    # Check for code block end
    if [[ "$line" =~ ^\`\`\`$ ]] && [[ "$IN_MERMAID" = true ]]; then
        IN_MERMAID=false
        echo "  - Type: ${DIAGRAM_TYPE:-unknown}"
        echo ""
        continue
    fi

    # Validate mermaid syntax
    if [[ "$IN_MERMAID" = true ]]; then
        # Detect diagram type
        if [[ -z "$DIAGRAM_TYPE" ]]; then
            if [[ "$line" =~ ^graph|^flowchart ]]; then
                DIAGRAM_TYPE="graph/flowchart"
            elif [[ "$line" =~ ^sequenceDiagram ]]; then
                DIAGRAM_TYPE="sequence"
            elif [[ "$line" =~ ^classDiagram ]]; then
                DIAGRAM_TYPE="class"
            elif [[ "$line" =~ ^stateDiagram ]]; then
                DIAGRAM_TYPE="state"
            elif [[ "$line" =~ ^erDiagram ]]; then
                DIAGRAM_TYPE="entity-relationship"
            elif [[ "$line" =~ ^gantt ]]; then
                DIAGRAM_TYPE="gantt"
            elif [[ "$line" =~ ^pie ]]; then
                DIAGRAM_TYPE="pie"
            fi
        fi

        # Check for common syntax errors

        # Check for unclosed brackets
        if [[ "$line" =~ \[.*[^\]] ]] && [[ ! "$line" =~ \[.*\] ]]; then
            echo -e "${YELLOW}  Warning (line $LINE_NUM): Possible unclosed bracket${NC}"
            ((WARNING_COUNT++))
        fi

        # Check for unclosed parentheses
        if [[ "$line" =~ \(.*[^\)] ]] && [[ ! "$line" =~ \(.*\) ]]; then
            echo -e "${YELLOW}  Warning (line $LINE_NUM): Possible unclosed parenthesis${NC}"
            ((WARNING_COUNT++))
        fi

        # Check for invalid arrow syntax
        if [[ "$line" =~ -- ]] && [[ ! "$line" =~ (-->|---|--\>|--\|) ]]; then
            echo -e "${RED}  Error (line $LINE_NUM): Invalid arrow syntax${NC}"
            ((ERROR_COUNT++))
        fi

        # Check for missing node definitions in relationships
        if [[ "$line" =~ [A-Za-z0-9_]+.*--\>.*[A-Za-z0-9_]+ ]]; then
            # Valid relationship syntax
            :
        elif [[ "$line" =~ --\> ]] && [[ ! "$line" =~ \|.*\| ]]; then
            echo -e "${YELLOW}  Warning (line $LINE_NUM): Check arrow relationship syntax${NC}"
            ((WARNING_COUNT++))
        fi

        # Check for unescaped special characters in labels
        if [[ "$line" =~ \[.*[\"\'].*\] ]]; then
            echo -e "${YELLOW}  Warning (line $LINE_NUM): Consider escaping quotes in labels${NC}"
            ((WARNING_COUNT++))
        fi

        # Check for missing semicolons in sequence diagrams
        if [[ "$DIAGRAM_TYPE" = "sequence" ]] && [[ "$line" =~ -\>\> ]] && [[ ! "$line" =~ : ]]; then
            echo -e "${YELLOW}  Warning (line $LINE_NUM): Sequence diagram message might need a label${NC}"
            ((WARNING_COUNT++))
        fi
    fi
done < "$MARKDOWN_FILE"

rm -f "$TEMP_FILE"

# Summary
echo "================================"
echo "Validation Summary"
echo "================================"
echo "File: $MARKDOWN_FILE"
echo "Diagrams found: $DIAGRAM_NUM"
echo "Errors: $ERROR_COUNT"
echo "Warnings: $WARNING_COUNT"
echo ""

if [[ $ERROR_COUNT -eq 0 ]] && [[ $WARNING_COUNT -eq 0 ]]; then
    echo -e "${GREEN}All diagrams passed validation!${NC}"
    exit 0
elif [[ $ERROR_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}Validation passed with warnings${NC}"
    exit 0
else
    echo -e "${RED}Validation failed with errors${NC}"
    echo ""
    echo "Common fixes:"
    echo "  - Ensure all brackets [] are closed"
    echo "  - Use proper arrow syntax: -->, ---, -->|label|"
    echo "  - Define all nodes before using them in relationships"
    echo "  - Escape special characters in labels"
    exit 1
fi

#!/usr/bin/env bash
# search-adrs.sh - Search Architecture Decision Records content
# Usage: search-adrs.sh <search-term> [docs-path] [--regex] [--section=SECTION]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 <search-term> [docs-path] [--regex] [--section=SECTION]"
    echo ""
    echo "Arguments:"
    echo "  search-term - Text or pattern to search for"
    echo "  docs-path   - Optional path to docs/adr directory (default: ./docs/adr)"
    echo "  --regex     - Treat search-term as regex pattern"
    echo "  --section   - Search only in specific section (context, decision, consequences)"
    echo ""
    echo "Examples:"
    echo "  $0 'PostgreSQL'"
    echo "  $0 'database' /path/to/docs/adr"
    echo "  $0 'auth.*strategy' --regex"
    echo "  $0 'microservices' --section=decision"
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Search term is required${NC}"
    usage
fi

SEARCH_TERM="$1"
shift

DOCS_PATH="./docs/adr"
USE_REGEX=false
SECTION_FILTER=""

# Parse remaining arguments
for arg in "$@"; do
    case $arg in
        --regex)
            USE_REGEX=true
            ;;
        --section=*)
            SECTION_FILTER="${arg#*=}"
            ;;
        --help)
            usage
            ;;
        *)
            if [ -d "$arg" ]; then
                DOCS_PATH="$arg"
            fi
            ;;
    esac
done

# Check if docs/adr directory exists
if [ ! -d "$DOCS_PATH" ]; then
    echo -e "${RED}Error: ADR directory not found: $DOCS_PATH${NC}"
    exit 1
fi

# Find all ADR files
ADR_FILES=$(find "$DOCS_PATH" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' | sort)

if [ -z "$ADR_FILES" ]; then
    echo -e "${YELLOW}No ADRs found in $DOCS_PATH${NC}"
    exit 0
fi

# Set grep options
GREP_OPTS="-i"
if [ "$USE_REGEX" = true ]; then
    GREP_OPTS="$GREP_OPTS -E"
fi

# Print header
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}ADR Search Results${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Search term: ${YELLOW}${SEARCH_TERM}${NC}"
if [ -n "$SECTION_FILTER" ]; then
    echo -e "Section filter: ${YELLOW}${SECTION_FILTER}${NC}"
fi
echo ""

# Counter for results
MATCH_COUNT=0
FILE_COUNT=0

# Function to extract section content
extract_section() {
    local file="$1"
    local section="$2"

    case "$section" in
        context)
            sed -n '/^## Context$/,/^## /p' "$file" | sed '1d;$d'
            ;;
        decision)
            sed -n '/^## Decision$/,/^## /p' "$file" | sed '1d;$d'
            ;;
        consequences)
            sed -n '/^## Consequences$/,/^## /p' "$file" | sed '1d;$d'
            ;;
        *)
            cat "$file"
            ;;
    esac
}

# Function to highlight search term in text
highlight_match() {
    local text="$1"
    local term="$2"

    if [ "$USE_REGEX" = true ]; then
        echo "$text" | sed -E "s/($term)/${YELLOW}\1${NC}/gi"
    else
        echo "$text" | sed -E "s/($term)/${YELLOW}\1${NC}/gi"
    fi
}

# Search each ADR file
while IFS= read -r file; do
    # Extract ADR number and title
    filename=$(basename "$file")
    adr_num=$(echo "$filename" | sed -E 's/^([0-9]{4})-.*/\1/')

    # Get content to search (full file or specific section)
    if [ -n "$SECTION_FILTER" ]; then
        content=$(extract_section "$file" "$SECTION_FILTER")
    else
        content=$(cat "$file")
    fi

    # Search for term
    if echo "$content" | grep -q $GREP_OPTS "$SEARCH_TERM"; then
        FILE_COUNT=$((FILE_COUNT + 1))

        # Extract title
        title=$(grep -m 1 "^# " "$file" | sed 's/^# //' | sed -E 's/^[0-9]{4}:? *//')

        # Extract status
        status=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^status:" | sed 's/^status: *//' || echo "unknown")
        if [ -z "$status" ] || [ "$status" = "null" ]; then
            status=$(grep -i "^\*\*status\*\*" "$file" | sed -E 's/\*\*[^*]+\*\*\s*//' | tr -d ' ' || echo "unknown")
        fi

        # Print ADR header
        echo -e "${GREEN}ADR-${adr_num}${NC}: ${title}"
        echo -e "Status: ${CYAN}${status}${NC}"
        echo -e "File: ${file}"
        echo ""

        # Get matching lines with context
        matching_lines=$(echo "$content" | grep -n $GREP_OPTS -A 2 -B 1 "$SEARCH_TERM" | head -20)

        # Count matches in this file
        local_matches=$(echo "$content" | grep -c $GREP_OPTS "$SEARCH_TERM" || echo "0")
        MATCH_COUNT=$((MATCH_COUNT + local_matches))

        # Show snippets
        echo "Matching snippets:"
        while IFS= read -r line; do
            if [[ "$line" =~ ^[0-9]+: ]]; then
                line_num=$(echo "$line" | cut -d: -f1)
                line_text=$(echo "$line" | cut -d: -f2-)

                # Highlight the match
                highlighted=$(highlight_match "$line_text" "$SEARCH_TERM")

                echo -e "  Line ${line_num}: ${highlighted}"
            elif [[ "$line" =~ ^-- ]]; then
                echo "  ..."
            fi
        done <<< "$matching_lines"

        echo ""
        echo "---"
        echo ""
    fi
done <<< "$ADR_FILES"

# Print summary
echo ""
echo -e "${GREEN}Search complete${NC}"
echo -e "Files with matches: ${YELLOW}${FILE_COUNT}${NC}"
echo -e "Total matches: ${YELLOW}${MATCH_COUNT}${NC}"
echo ""

if [ $FILE_COUNT -eq 0 ]; then
    echo -e "${YELLOW}No ADRs found matching '${SEARCH_TERM}'${NC}"
    echo ""
    echo "Try:"
    echo "  - Using different search terms"
    echo "  - Using --regex for pattern matching"
    echo "  - Checking spelling"
fi

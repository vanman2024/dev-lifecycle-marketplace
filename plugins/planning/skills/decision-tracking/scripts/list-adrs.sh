#!/usr/bin/env bash
# list-adrs.sh - List all Architecture Decision Records with filtering
# Usage: list-adrs.sh [docs-path] [--status=STATUS] [--summary]

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
    echo "Usage: $0 [docs-path] [--status=STATUS] [--summary]"
    echo ""
    echo "Arguments:"
    echo "  docs-path  - Optional path to docs/adr directory (default: ./docs/adr)"
    echo "  --status   - Filter by status: accepted, proposed, deprecated, superseded"
    echo "  --summary  - Show brief summary from each ADR"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 /path/to/docs/adr"
    echo "  $0 --status=accepted"
    echo "  $0 --status=proposed --summary"
    exit 1
}

# Parse arguments
DOCS_PATH="./docs/adr"
FILTER_STATUS=""
SHOW_SUMMARY=false

for arg in "$@"; do
    case $arg in
        --status=*)
            FILTER_STATUS="${arg#*=}"
            ;;
        --summary)
            SHOW_SUMMARY=true
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
    echo "Run create-adr.sh to create your first ADR"
    exit 1
fi

# Find all ADR files
ADR_FILES=$(find "$DOCS_PATH" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' | sort)

if [ -z "$ADR_FILES" ]; then
    echo -e "${YELLOW}No ADRs found in $DOCS_PATH${NC}"
    echo "Run create-adr.sh to create your first ADR"
    exit 0
fi

# Function to extract frontmatter field
extract_field() {
    local file="$1"
    local field="$2"
    local value

    # Extract value from YAML frontmatter
    value=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | sed "s/^${field}: *//" | tr -d '"' || echo "")

    # If not found in frontmatter, try to extract from content
    if [ -z "$value" ]; then
        case "$field" in
            status)
                # Look for **status** in content
                value=$(grep -i "^\*\*${field}\*\*" "$file" | sed -E 's/\*\*[^*]+\*\*\s*//' | tr -d ' ' || echo "unknown")
                ;;
        esac
    fi

    echo "$value"
}

# Function to get status color
get_status_color() {
    case "$1" in
        accepted)
            echo "$GREEN"
            ;;
        proposed)
            echo "$YELLOW"
            ;;
        deprecated)
            echo "$RED"
            ;;
        superseded)
            echo "$CYAN"
            ;;
        *)
            echo "$NC"
            ;;
    esac
}

# Print header
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Architecture Decision Records${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ -n "$FILTER_STATUS" ]; then
    echo -e "Filter: Status = ${YELLOW}${FILTER_STATUS}${NC}"
    echo ""
fi

# Print table header
printf "%-8s %-50s %-12s %-12s\n" "Number" "Title" "Status" "Date"
printf "%-8s %-50s %-12s %-12s\n" "------" "-----" "------" "----"

# Counter for filtered results
COUNT=0

# Process each ADR file
while IFS= read -r file; do
    # Extract ADR number from filename
    filename=$(basename "$file")
    adr_num=$(echo "$filename" | sed -E 's/^([0-9]{4})-.*/\1/')

    # Extract metadata
    title=$(extract_field "$file" "title")
    status=$(extract_field "$file" "status")
    date=$(extract_field "$file" "date")

    # If title not in frontmatter, try to extract from first heading
    if [ -z "$title" ] || [ "$title" = "null" ]; then
        title=$(grep -m 1 "^# " "$file" | sed 's/^# //' | sed -E 's/^[0-9]{4}:? *//' || echo "Untitled")
    fi

    # Default values if not found
    status=${status:-unknown}
    date=${date:-unknown}

    # Filter by status if specified
    if [ -n "$FILTER_STATUS" ] && [ "$status" != "$FILTER_STATUS" ]; then
        continue
    fi

    COUNT=$((COUNT + 1))

    # Truncate title if too long
    if [ ${#title} -gt 48 ]; then
        title="${title:0:45}..."
    fi

    # Get color for status
    status_color=$(get_status_color "$status")

    # Print row
    printf "%-8s %-50s ${status_color}%-12s${NC} %-12s\n" \
        "$adr_num" \
        "$title" \
        "$status" \
        "$date"

    # Show summary if requested
    if [ "$SHOW_SUMMARY" = true ]; then
        # Extract first paragraph from Context section
        summary=$(sed -n '/^## Context$/,/^## /p' "$file" | sed '1d;$d' | head -3 | tr '\n' ' ' | sed 's/  */ /g')
        if [ -n "$summary" ]; then
            echo "    ${summary:0:100}..."
        fi
        echo ""
    fi
done <<< "$ADR_FILES"

echo ""
echo -e "${GREEN}Total ADRs: $COUNT${NC}"

# Show status summary
if [ -z "$FILTER_STATUS" ]; then
    echo ""
    echo "Status Summary:"

    for status_type in accepted proposed deprecated superseded; do
        status_count=$(echo "$ADR_FILES" | while read -r file; do
            status=$(extract_field "$file" "status")
            [ "$status" = "$status_type" ] && echo "1"
        done | wc -l)

        if [ "$status_count" -gt 0 ]; then
            status_color=$(get_status_color "$status_type")
            echo -e "  ${status_color}${status_type}${NC}: $status_count"
        fi
    done
fi

echo ""

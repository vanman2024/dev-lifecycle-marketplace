#!/usr/bin/env bash
# update-adr-index.sh - Update or create ADR index file
# Usage: update-adr-index.sh [docs-path]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [docs-path]"
    echo ""
    echo "Arguments:"
    echo "  docs-path  - Optional path to docs/adr directory (default: ./docs/adr)"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 /path/to/docs/adr"
    exit 1
}

# Parse arguments
DOCS_PATH="${1:-./docs/adr}"

# Check if docs/adr directory exists
if [ ! -d "$DOCS_PATH" ]; then
    echo -e "${RED}Error: ADR directory not found: $DOCS_PATH${NC}"
    exit 1
fi

# Index file path
INDEX_FILE="${DOCS_PATH}/index.md"

# Find all ADR files
ADR_FILES=$(find "$DOCS_PATH" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' | sort)

if [ -z "$ADR_FILES" ]; then
    echo -e "${YELLOW}No ADRs found in $DOCS_PATH${NC}"
    echo "Skipping index generation"
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
    if [ -z "$value" ] || [ "$value" = "null" ]; then
        case "$field" in
            title)
                value=$(grep -m 1 "^# " "$file" | sed 's/^# //' | sed -E 's/^[0-9]{4}:? *//' || echo "Untitled")
                ;;
            status)
                value=$(grep -i "^\*\*${field}\*\*" "$file" | sed -E 's/\*\*[^*]+\*\*\s*//' | tr -d ' ' || echo "unknown")
                ;;
        esac
    fi

    echo "$value"
}

# Count ADRs by status
count_accepted=0
count_proposed=0
count_deprecated=0
count_superseded=0

# Arrays to hold ADRs by status
declare -a accepted_adrs=()
declare -a proposed_adrs=()
declare -a deprecated_adrs=()
declare -a superseded_adrs=()

# Process each ADR file
while IFS= read -r file; do
    filename=$(basename "$file")
    adr_num=$(echo "$filename" | sed -E 's/^([0-9]{4})-.*/\1/')

    title=$(extract_field "$file" "title")
    status=$(extract_field "$file" "status")
    date=$(extract_field "$file" "date")

    # Build ADR entry line
    adr_entry="- [ADR-${adr_num}: ${title}](${filename}) - *${date}*"

    # Categorize by status
    case "$status" in
        accepted)
            accepted_adrs+=("$adr_entry")
            count_accepted=$((count_accepted + 1))
            ;;
        proposed)
            proposed_adrs+=("$adr_entry")
            count_proposed=$((count_proposed + 1))
            ;;
        deprecated)
            deprecated_adrs+=("$adr_entry")
            count_deprecated=$((count_deprecated + 1))
            ;;
        superseded)
            superseded_adrs+=("$adr_entry")
            count_superseded=$((count_superseded + 1))
            ;;
        *)
            # Default to proposed if status unknown
            proposed_adrs+=("$adr_entry")
            count_proposed=$((count_proposed + 1))
            ;;
    esac
done <<< "$ADR_FILES"

# Get total count
total_count=$((count_accepted + count_proposed + count_deprecated + count_superseded))

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Generate index file
cat > "$INDEX_FILE" << 'EOF_HEADER'
# Architecture Decision Records (ADR)

This document provides an index of all Architecture Decision Records (ADRs) for this project.

## About ADRs

Architecture Decision Records (ADRs) are documents that capture important architectural decisions made during the project's lifecycle. Each ADR describes:

- The context and problem being addressed
- The decision that was made
- The consequences of that decision

ADRs follow the format proposed by Michael Nygard in his article ["Documenting Architecture Decisions"](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

## ADR Lifecycle

ADRs can have the following statuses:

- **Proposed**: The ADR is under discussion and not yet decided
- **Accepted**: The decision has been approved and is being implemented
- **Deprecated**: The decision is no longer recommended but may still be in use
- **Superseded**: The decision has been replaced by a newer ADR

EOF_HEADER

# Add statistics
cat >> "$INDEX_FILE" << EOF

## Statistics

- **Total ADRs**: ${total_count}
- **Accepted**: ${count_accepted}
- **Proposed**: ${count_proposed}
- **Deprecated**: ${count_deprecated}
- **Superseded**: ${count_superseded}

*Last updated: ${CURRENT_DATE}*

---

EOF

# Add accepted ADRs
if [ ${count_accepted} -gt 0 ]; then
    cat >> "$INDEX_FILE" << 'EOF'

## Accepted Decisions

These decisions have been approved and are currently in effect:

EOF
    for adr in "${accepted_adrs[@]}"; do
        echo "$adr" >> "$INDEX_FILE"
    done
    echo "" >> "$INDEX_FILE"
fi

# Add proposed ADRs
if [ ${count_proposed} -gt 0 ]; then
    cat >> "$INDEX_FILE" << 'EOF'

## Proposed Decisions

These decisions are under discussion and awaiting approval:

EOF
    for adr in "${proposed_adrs[@]}"; do
        echo "$adr" >> "$INDEX_FILE"
    done
    echo "" >> "$INDEX_FILE"
fi

# Add deprecated ADRs
if [ ${count_deprecated} -gt 0 ]; then
    cat >> "$INDEX_FILE" << 'EOF'

## Deprecated Decisions

These decisions are no longer recommended but may still be in use:

EOF
    for adr in "${deprecated_adrs[@]}"; do
        echo "$adr" >> "$INDEX_FILE"
    done
    echo "" >> "$INDEX_FILE"
fi

# Add superseded ADRs
if [ ${count_superseded} -gt 0 ]; then
    cat >> "$INDEX_FILE" << 'EOF'

## Superseded Decisions

These decisions have been replaced by newer ADRs:

EOF
    for adr in "${superseded_adrs[@]}"; do
        echo "$adr" >> "$INDEX_FILE"
    done
    echo "" >> "$INDEX_FILE"
fi

# Add footer
cat >> "$INDEX_FILE" << 'EOF'

---

## Creating a New ADR

To create a new ADR, use the provided script:

```bash
./scripts/create-adr.sh "Title of Your Decision"
```

The script will:
1. Automatically assign the next sequential ADR number
2. Create a new file with the proper format
3. Update this index

## Searching ADRs

To search through ADRs:

```bash
./scripts/search-adrs.sh "search term"
```

## Listing ADRs

To list all ADRs with filtering:

```bash
./scripts/list-adrs.sh --status=accepted
```

EOF

echo -e "${GREEN}ADR index updated successfully${NC}"
echo -e "Index file: ${BLUE}${INDEX_FILE}${NC}"
echo ""
echo "Summary:"
echo "  Total ADRs: ${total_count}"
echo "  Accepted: ${count_accepted}"
echo "  Proposed: ${count_proposed}"
echo "  Deprecated: ${count_deprecated}"
echo "  Superseded: ${count_superseded}"
echo ""

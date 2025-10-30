#!/usr/bin/env bash
# supersede-adr.sh - Mark an ADR as superseded and create a replacement
# Usage: supersede-adr.sh <old-adr-number> <new-title> [docs-path]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 <old-adr-number> <new-title> [docs-path]"
    echo ""
    echo "Arguments:"
    echo "  old-adr-number - Number of ADR to supersede (e.g., 0005 or 5)"
    echo "  new-title      - Title for the new replacement ADR"
    echo "  docs-path      - Optional path to docs/adr directory (default: ./docs/adr)"
    echo ""
    echo "Examples:"
    echo "  $0 5 'Use PostgreSQL 15 with Connection Pooling'"
    echo "  $0 0042 'Migrate to Microservices Architecture' /path/to/docs/adr"
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Both old ADR number and new title are required${NC}"
    usage
fi

OLD_ADR_NUM="$1"
NEW_TITLE="$2"
DOCS_PATH="${3:-./docs/adr}"

# Ensure docs/adr directory exists
if [ ! -d "$DOCS_PATH" ]; then
    echo -e "${RED}Error: ADR directory not found: $DOCS_PATH${NC}"
    exit 1
fi

# Format old ADR number with zero padding
OLD_ADR_PADDED=$(printf "%04d" "$((10#$OLD_ADR_NUM))")

# Find the old ADR file
OLD_ADR_FILE=$(find "$DOCS_PATH" -maxdepth 1 -type f -name "${OLD_ADR_PADDED}-*.md" | head -1)

if [ -z "$OLD_ADR_FILE" ]; then
    echo -e "${RED}Error: ADR-${OLD_ADR_PADDED} not found in $DOCS_PATH${NC}"
    echo "Available ADRs:"
    find "$DOCS_PATH" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' -exec basename {} \; | sort
    exit 1
fi

echo -e "${BLUE}Found old ADR: $(basename $OLD_ADR_FILE)${NC}"

# Extract old ADR title
OLD_TITLE=$(grep -m 1 "^# " "$OLD_ADR_FILE" | sed 's/^# //' | sed -E 's/^[0-9]{4}:? *//')

# Check if already superseded
CURRENT_STATUS=$(sed -n '/^---$/,/^---$/p' "$OLD_ADR_FILE" | grep "^status:" | sed 's/^status: *//' || echo "")
if [ -z "$CURRENT_STATUS" ]; then
    CURRENT_STATUS=$(grep -i "^\*\*status\*\*" "$OLD_ADR_FILE" | sed -E 's/\*\*[^*]+\*\*\s*//' | tr -d ' ' || echo "unknown")
fi

if [ "$CURRENT_STATUS" = "superseded" ]; then
    echo -e "${YELLOW}Warning: ADR-${OLD_ADR_PADDED} is already superseded${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Find the next ADR number for new ADR
LAST_NUM=$(find "$DOCS_PATH" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' \
    | sed -E 's/.*\/([0-9]{4})-.*/\1/' \
    | sort -n \
    | tail -1)

NEXT_NUM=$((10#$LAST_NUM + 1))
NEW_ADR_NUM=$(printf "%04d" "$NEXT_NUM")

# Convert new title to kebab-case
KEBAB_TITLE=$(echo "$NEW_TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')

# Create new ADR filename
NEW_FILENAME="${NEW_ADR_NUM}-${KEBAB_TITLE}.md"
NEW_FILEPATH="${DOCS_PATH}/${NEW_FILENAME}"

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

echo ""
echo -e "${YELLOW}Creating new ADR...${NC}"
echo -e "Old ADR: ${RED}ADR-${OLD_ADR_PADDED}${NC} - ${OLD_TITLE}"
echo -e "New ADR: ${GREEN}ADR-${NEW_ADR_NUM}${NC} - ${NEW_TITLE}"
echo ""

# Create new ADR file
cat > "$NEW_FILEPATH" << EOF
---
number: $NEW_ADR_NUM
title: $NEW_TITLE
date: $CURRENT_DATE
status: proposed
deciders: []
consulted: []
informed: []
supersedes: ADR-${OLD_ADR_PADDED}
---

# $NEW_ADR_NUM: $NEW_TITLE

## Status

**proposed**

*This ADR supersedes [ADR-${OLD_ADR_PADDED}: ${OLD_TITLE}]($(basename "$OLD_ADR_FILE"))*

## Context

This decision supersedes ADR-${OLD_ADR_PADDED} because:

[Explain why the previous decision is being replaced. What has changed? What new information do we have? What problems emerged with the previous decision?]

### Previous Decision Recap

The previous ADR (ADR-${OLD_ADR_PADDED}) decided to:
- [Summarize key points of the superseded decision]
- [What was the original rationale?]

### What Changed

- [New requirements or constraints]
- [Problems discovered with the previous approach]
- [New technologies or options available]
- [Changes in the project or business context]

## Decision

We will [describe the new decision in full sentences, with active voice].

### How This Differs from ADR-${OLD_ADR_PADDED}

Key differences from the previous decision:
1. **Difference 1**: [Explain what's different and why]
2. **Difference 2**: [Explain what's different and why]
3. **Difference 3**: [Explain what's different and why]

### Considered Alternatives

1. **Continue with ADR-${OLD_ADR_PADDED}**: Keep the previous decision
   - Pros: No migration needed, familiar approach
   - Cons: [Reasons why this is no longer suitable]

2. **Alternative 2**: Brief description
   - Pros: What makes this attractive
   - Cons: What makes this less suitable

3. **Alternative 3**: Brief description
   - Pros: What makes this attractive
   - Cons: What makes this less suitable

## Consequences

### Positive

- What becomes easier or better with this new decision
- What problems are solved that the previous decision couldn't address
- What new opportunities are created

### Negative

- Migration effort required from the previous approach
- What becomes harder or more complex
- What new problems might arise

### Neutral

- What changes but isn't clearly positive or negative
- What stays the same from the previous decision
- What new responsibilities emerge

## Migration from ADR-${OLD_ADR_PADDED}

### Migration Strategy

1. **Phase 1**: [First steps to transition]
2. **Phase 2**: [Next steps]
3. **Phase 3**: [Final migration steps]

### Backwards Compatibility

- [How to handle existing implementations of ADR-${OLD_ADR_PADDED}]
- [Whether both approaches will coexist temporarily]
- [Timeline for complete migration]

### Risk Mitigation

- [Risks in migrating from the old decision]
- [How to minimize disruption]
- [Rollback plan if issues arise]

## References

- [ADR-${OLD_ADR_PADDED}: ${OLD_TITLE}]($(basename "$OLD_ADR_FILE")) - Superseded by this ADR
- [Relevant documentation]
- [External resources]

## Notes

Additional information about this superseding decision.

---

*Date: $CURRENT_DATE*
*Supersedes: ADR-${OLD_ADR_PADDED}*
*Status: proposed*
EOF

echo -e "${GREEN}Created new ADR: $NEW_FILEPATH${NC}"

# Update old ADR to mark as superseded
echo ""
echo -e "${YELLOW}Updating old ADR status...${NC}"

# Create a temporary file
TEMP_FILE=$(mktemp)

# Read the old file and update it
IN_FRONTMATTER=false
FRONTMATTER_COUNT=0
UPDATED_FRONTMATTER=false
STATUS_SECTION_FOUND=false

while IFS= read -r line; do
    # Track frontmatter boundaries
    if [[ "$line" == "---" ]]; then
        FRONTMATTER_COUNT=$((FRONTMATTER_COUNT + 1))
        echo "$line" >> "$TEMP_FILE"

        # If leaving frontmatter and status wasn't updated, add it
        if [ $FRONTMATTER_COUNT -eq 2 ] && [ "$UPDATED_FRONTMATTER" = false ]; then
            echo "status: superseded" >> "$TEMP_FILE"
            echo "superseded_by: ADR-${NEW_ADR_NUM}" >> "$TEMP_FILE"
            echo "superseded_date: $CURRENT_DATE" >> "$TEMP_FILE"
            UPDATED_FRONTMATTER=true
        fi
        continue
    fi

    # Update status in frontmatter
    if [ $FRONTMATTER_COUNT -eq 1 ]; then
        if [[ "$line" =~ ^status: ]]; then
            echo "status: superseded" >> "$TEMP_FILE"
            UPDATED_FRONTMATTER=true
            continue
        fi
    fi

    # Update status in content
    if [[ "$line" =~ ^\*\*[Ss]tatus\*\* ]] || [[ "$line" =~ ^## Status ]]; then
        STATUS_SECTION_FOUND=true
        echo "$line" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        echo "**superseded** by [ADR-${NEW_ADR_NUM}: ${NEW_TITLE}](${NEW_FILENAME})" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        echo "*Superseded on: ${CURRENT_DATE}*" >> "$TEMP_FILE"

        # Skip the next few lines (old status info)
        read -r line
        while [[ "$line" =~ ^(\*\*|$) ]]; do
            read -r line || break
        done
        echo "$line" >> "$TEMP_FILE"
        continue
    fi

    echo "$line" >> "$TEMP_FILE"
done < "$OLD_ADR_FILE"

# Replace old file with updated version
mv "$TEMP_FILE" "$OLD_ADR_FILE"

echo -e "${GREEN}Updated old ADR to mark as superseded${NC}"

# Update ADR index
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/update-adr-index.sh" ]; then
    echo ""
    echo "Updating ADR index..."
    "$SCRIPT_DIR/update-adr-index.sh" "$DOCS_PATH"
fi

# Print summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Superseding Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Old ADR (superseded): ${RED}ADR-${OLD_ADR_PADDED}${NC}"
echo -e "  File: $(basename "$OLD_ADR_FILE")"
echo -e "  Status: superseded"
echo ""
echo -e "New ADR (replacement): ${GREEN}ADR-${NEW_ADR_NUM}${NC}"
echo -e "  File: ${NEW_FILENAME}"
echo -e "  Status: proposed"
echo ""
echo "Next steps:"
echo "1. Edit the new ADR to complete all sections"
echo "2. Update the Context section to explain why the decision changed"
echo "3. Document the migration strategy from the old decision"
echo "4. Change status to 'accepted' once approved"
echo ""

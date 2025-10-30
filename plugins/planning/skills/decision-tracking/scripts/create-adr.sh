#!/usr/bin/env bash
# create-adr.sh - Create new Architecture Decision Record with auto-numbering
# Usage: create-adr.sh <title> [docs-path]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 <title> [docs-path]"
    echo ""
    echo "Arguments:"
    echo "  title      - Title of the ADR (e.g., 'Use PostgreSQL for Primary Database')"
    echo "  docs-path  - Optional path to docs/adr directory (default: ./docs/adr)"
    echo ""
    echo "Examples:"
    echo "  $0 'Use PostgreSQL for Primary Database'"
    echo "  $0 'Adopt Microservices Architecture' /path/to/docs/adr"
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Title is required${NC}"
    usage
fi

TITLE="$1"
DOCS_PATH="${2:-./docs/adr}"

# Ensure docs/adr directory exists
mkdir -p "$DOCS_PATH"

# Find the next ADR number
NEXT_NUM=1
if [ -d "$DOCS_PATH" ]; then
    # Find all ADR files matching pattern NNNN-*.md
    LAST_NUM=$(find "$DOCS_PATH" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' \
        | sed -E 's/.*\/([0-9]{4})-.*/\1/' \
        | sort -n \
        | tail -1 || echo "0000")

    if [ -n "$LAST_NUM" ] && [ "$LAST_NUM" != "0000" ]; then
        NEXT_NUM=$((10#$LAST_NUM + 1))
    fi
fi

# Format number with zero padding
ADR_NUM=$(printf "%04d" "$NEXT_NUM")

# Convert title to kebab-case
KEBAB_TITLE=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')

# Create filename
FILENAME="${ADR_NUM}-${KEBAB_TITLE}.md"
FILEPATH="${DOCS_PATH}/${FILENAME}"

# Check if file already exists
if [ -f "$FILEPATH" ]; then
    echo -e "${RED}Error: File already exists: $FILEPATH${NC}"
    exit 1
fi

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Create ADR file with template
cat > "$FILEPATH" << EOF
---
number: $ADR_NUM
title: $TITLE
date: $CURRENT_DATE
status: proposed
deciders: []
consulted: []
informed: []
---

# $ADR_NUM: $TITLE

## Status

**proposed**

## Context

What is the issue that we're seeing that is motivating this decision or change?

Describe the forces at play, including:
- Technological constraints
- Business requirements
- Team capabilities
- Time and resource constraints
- Stakeholder concerns
- Industry standards and best practices

## Decision

We will [describe the decision in full sentences, with active voice].

### Considered Alternatives

1. **Alternative 1**: Brief description
   - Pros: What makes this attractive
   - Cons: What makes this less suitable

2. **Alternative 2**: Brief description
   - Pros: What makes this attractive
   - Cons: What makes this less suitable

3. **Alternative 3**: Brief description
   - Pros: What makes this attractive
   - Cons: What makes this less suitable

### Why This Decision

Explain why the chosen decision is better than the alternatives:
- How it addresses the context and forces
- What trade-offs are being made
- What makes it the best choice given the constraints

## Consequences

### Positive

- What becomes easier or better
- What problems are solved
- What opportunities are created

### Negative

- What becomes harder or more complex
- What new problems might arise
- What limitations are introduced

### Neutral

- What changes but isn't clearly positive or negative
- What stays the same
- What new responsibilities emerge

## Implementation

### Required Changes

- List specific changes needed to implement this decision
- Include code changes, configuration updates, infrastructure changes
- Identify affected systems and components

### Migration Strategy

- How to transition from current state to new state
- What needs to happen first, second, third
- How to handle existing systems or data

### Rollback Plan

- How to reverse this decision if needed
- What would trigger a rollback
- What data or state needs to be preserved

## References

- [Relevant documentation]
- [Related ADRs]
- [External resources]
- [Discussion threads or meeting notes]

## Notes

Additional information, clarifications, or future considerations.

---

*Date: $CURRENT_DATE*
*Deciders: [Names of decision makers]*
*Status: proposed*
EOF

echo -e "${GREEN}Created ADR: $FILEPATH${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Fill in the Context section with the problem and constraints"
echo "2. Document the Decision and considered alternatives"
echo "3. List all Consequences (positive, negative, neutral)"
echo "4. Update status to 'accepted' once approved"
echo ""
echo -e "${GREEN}ADR Number: $ADR_NUM${NC}"
echo -e "${GREEN}Filename: $FILENAME${NC}"

# Update ADR index if update script exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/update-adr-index.sh" ]; then
    echo ""
    echo "Updating ADR index..."
    "$SCRIPT_DIR/update-adr-index.sh" "$DOCS_PATH"
fi

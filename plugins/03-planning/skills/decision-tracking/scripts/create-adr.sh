#!/bin/bash
# create-adr.sh - Creates a new ADR with auto-numbering

set -e

TITLE="$1"
ADR_DIR="${2:-docs/decisions}"

if [ -z "$TITLE" ]; then
    echo "Usage: create-adr.sh <title> [adr-directory]"
    echo "Example: create-adr.sh \"Use PostgreSQL for Database\""
    exit 1
fi

mkdir -p "$ADR_DIR"

# Get next ADR number
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXT_NUM=$("$SCRIPT_DIR/find-next-adr-number.sh" "$ADR_DIR")

# Create filename
FILENAME="ADR-${NEXT_NUM}-$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-').md"
FILEPATH="$ADR_DIR/$FILENAME"

# Create ADR from template
cat > "$FILEPATH" << EOF
# ADR-${NEXT_NUM}: ${TITLE}

**Status**: Proposed

**Date**: $(date +%Y-%m-%d)

**Deciders**: [List decision makers]

## Context and Problem Statement

[Describe the context and problem statement]

## Decision Drivers

* [driver 1]
* [driver 2]

## Considered Options

* [option 1]
* [option 2]
* [option 3]

## Decision Outcome

Chosen option: "[option 1]", because [justification].

### Positive Consequences

* [consequence 1]

### Negative Consequences

* [consequence 1]

## Pros and Cons of the Options

### [option 1]

* Good, because [argument a]
* Bad, because [argument c]

### [option 2]

* Good, because [argument a]
* Bad, because [argument b]

## Links

* [Related ADR-NNNN]
EOF

echo "✅ Created: $FILEPATH"
echo "$FILEPATH"

#!/bin/bash
# update-adr-index.sh - Updates ADR index/README

set -e

ADR_DIR="${1:-docs/decisions}"

if [ ! -d "$ADR_DIR" ]; then
    echo "❌ ADR directory not found: $ADR_DIR"
    exit 1
fi

INDEX_FILE="$ADR_DIR/README.md"

cat > "$INDEX_FILE" << 'EOF'
# Architecture Decision Records

## Accepted

EOF

# List all accepted ADRs
find "$ADR_DIR" -name "ADR-*.md" -type f | sort | while read -r adr; do
    if grep -q "Status.*Accepted" "$adr" 2>/dev/null; then
        TITLE=$(grep '^# ADR-' "$adr" | head -1 | sed 's/^# //')
        FILENAME=$(basename "$adr")
        echo "- [$TITLE](./$FILENAME)" >> "$INDEX_FILE"
    fi
done

cat >> "$INDEX_FILE" << 'EOF'

## Proposed

EOF

# List all proposed ADRs
find "$ADR_DIR" -name "ADR-*.md" -type f | sort | while read -r adr; do
    if grep -q "Status.*Proposed" "$adr" 2>/dev/null; then
        TITLE=$(grep '^# ADR-' "$adr" | head -1 | sed 's/^# //')
        FILENAME=$(basename "$adr")
        echo "- [$TITLE](./$FILENAME)" >> "$INDEX_FILE"
    fi
done

cat >> "$INDEX_FILE" << 'EOF'

## Deprecated

EOF

# List all deprecated ADRs
find "$ADR_DIR" -name "ADR-*.md" -type f | sort | while read -r adr; do
    if grep -qE "Status.*(Deprecated|Superseded)" "$adr" 2>/dev/null; then
        TITLE=$(grep '^# ADR-' "$adr" | head -1 | sed 's/^# //')
        FILENAME=$(basename "$adr")
        echo "- [$TITLE](./$FILENAME)" >> "$INDEX_FILE"
    fi
done

echo "✅ Updated: $INDEX_FILE"

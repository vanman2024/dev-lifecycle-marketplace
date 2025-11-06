#!/usr/bin/env bash
# Script: proto-diff.sh
# Purpose: Compare Protocol Buffer definitions and detect breaking changes
# Usage: bash proto-diff.sh <old-proto.proto> <new-proto.proto> [--output report.md]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

OLD_PROTO="${1:?Usage: $0 <old.proto> <new.proto> [--output report.md]}"
NEW_PROTO="${2:?Usage: $0 <old.proto> <new.proto> [--output report.md]}"
OUTPUT_FILE=""

# Parse optional output argument
shift 2
while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 2
            ;;
    esac
done

# Check input files exist
[[ ! -f "$OLD_PROTO" ]] && { echo "Error: Old proto not found: $OLD_PROTO"; exit 2; }
[[ ! -f "$NEW_PROTO" ]] && { echo "Error: New proto not found: $NEW_PROTO"; exit 2; }

echo "🔍 Analyzing Protocol Buffer definitions..."
echo "   Old: $OLD_PROTO"
echo "   New: $NEW_PROTO"
echo ""

# Initialize breaking changes counter
BREAKING_COUNT=0
NON_BREAKING_COUNT=0

# Output buffer
REPORT=""

# Helper function to add to report
add_to_report() {
    REPORT+="$1\n"
}

# Extract message definitions
echo "📊 Checking for removed messages..."
OLD_MESSAGES=$(grep -E "^message [A-Z]" "$OLD_PROTO" | awk '{print $2}' | sort || echo "")
NEW_MESSAGES=$(grep -E "^message [A-Z]" "$NEW_PROTO" | awk '{print $2}' | sort || echo "")

REMOVED_MESSAGES=$(comm -23 <(echo "$OLD_MESSAGES") <(echo "$NEW_MESSAGES"))

if [[ -n "$REMOVED_MESSAGES" ]]; then
    echo -e "${RED}❌ BREAKING: Removed messages detected${NC}"
    while IFS= read -r msg; do
        [[ -z "$msg" ]] && continue
        echo "   - $msg"
        add_to_report "### ❌ BREAKING: Removed Message\n**Message:** \`$msg\`\n**Impact:** Clients using this message type will fail to serialize/deserialize\n"
        ((BREAKING_COUNT++))
    done <<< "$REMOVED_MESSAGES"
else
    echo -e "${GREEN}✅ No removed messages${NC}"
fi

echo ""

# Check for field number changes (critical in protobuf)
echo "📊 Checking for field number changes..."

for msg in $OLD_MESSAGES; do
    if echo "$NEW_MESSAGES" | grep -q "^${msg}$"; then
        # Extract field numbers for this message
        OLD_FIELD_NUMS=$(sed -n "/^message ${msg}/,/^}/p" "$OLD_PROTO" | \
            grep -E "^[[:space:]]+[a-z].*= [0-9]+" | \
            sed -E 's/.*= ([0-9]+);.*/\1/' | \
            sort -n || echo "")

        NEW_FIELD_NUMS=$(sed -n "/^message ${msg}/,/^}/p" "$NEW_PROTO" | \
            grep -E "^[[:space:]]+[a-z].*= [0-9]+" | \
            sed -E 's/.*= ([0-9]+);.*/\1/' | \
            sort -n || echo "")

        # Extract field names with their numbers
        OLD_FIELD_MAP=$(sed -n "/^message ${msg}/,/^}/p" "$OLD_PROTO" | \
            grep -E "^[[:space:]]+[a-z].*= [0-9]+" | \
            sed -E 's/^[[:space:]]+[a-z]+[[:space:]]+([a-z_]+).*= ([0-9]+);.*/\2:\1/' | \
            sort || echo "")

        NEW_FIELD_MAP=$(sed -n "/^message ${msg}/,/^}/p" "$NEW_PROTO" | \
            grep -E "^[[:space:]]+[a-z].*= [0-9]+" | \
            sed -E 's/^[[:space:]]+[a-z]+[[:space:]]+([a-z_]+).*= ([0-9]+);.*/\2:\1/' | \
            sort || echo "")

        # Check if any field number was reused for different field name
        while IFS= read -r old_mapping; do
            [[ -z "$old_mapping" ]] && continue
            field_num=$(echo "$old_mapping" | cut -d: -f1)
            field_name=$(echo "$old_mapping" | cut -d: -f2)

            # Check if this field number exists in new proto
            new_field_name=$(echo "$NEW_FIELD_MAP" | grep "^${field_num}:" | cut -d: -f2 || echo "")

            if [[ -n "$new_field_name" ]] && [[ "$new_field_name" != "$field_name" ]]; then
                echo -e "${RED}❌ BREAKING: Field number reused in message '$msg'${NC}"
                echo "   - Field #$field_num: '$field_name' → '$new_field_name'"
                add_to_report "### ❌ BREAKING: Field Number Reused\n**Message:** \`$msg\`\n**Field Number:** \`$field_num\`\n**Old Name:** \`$field_name\`\n**New Name:** \`$new_field_name\`\n**Impact:** CRITICAL - Will cause data corruption. Field numbers must never be reused.\n"
                ((BREAKING_COUNT++))
            fi

            # Check if field number was removed
            if [[ -z "$new_field_name" ]]; then
                echo -e "${YELLOW}⚠️  WARNING: Field number removed in message '$msg'${NC}"
                echo "   - Field #$field_num: '$field_name'"
                add_to_report "### ⚠️ WARNING: Field Removed\n**Message:** \`$msg\`\n**Field Number:** \`$field_num\`\n**Field Name:** \`$field_name\`\n**Impact:** Old clients will ignore unknown field, new clients won't send it\n"
                ((NON_BREAKING_COUNT++))
            fi
        done <<< "$OLD_FIELD_MAP"
    fi
done

echo ""

# Check for changed field types
echo "📊 Checking for field type changes..."

for msg in $OLD_MESSAGES; do
    if echo "$NEW_MESSAGES" | grep -q "^${msg}$"; then
        # Extract fields with types
        OLD_FIELDS=$(sed -n "/^message ${msg}/,/^}/p" "$OLD_PROTO" | \
            grep -E "^[[:space:]]+[a-z].*= [0-9]+" | \
            sed -E 's/^[[:space:]]+([a-z]+)[[:space:]]+([a-z_]+).*= ([0-9]+);.*/\3:\1:\2/' || echo "")

        NEW_FIELDS=$(sed -n "/^message ${msg}/,/^}/p" "$NEW_PROTO" | \
            grep -E "^[[:space:]]+[a-z].*= [0-9]+" | \
            sed -E 's/^[[:space:]]+([a-z]+)[[:space:]]+([a-z_]+).*= ([0-9]+);.*/\3:\1:\2/' || echo "")

        # Compare field types for same field numbers
        while IFS= read -r old_field; do
            [[ -z "$old_field" ]] && continue
            field_num=$(echo "$old_field" | cut -d: -f1)
            old_type=$(echo "$old_field" | cut -d: -f2)
            field_name=$(echo "$old_field" | cut -d: -f3)

            new_field=$(echo "$NEW_FIELDS" | grep "^${field_num}:" || echo "")

            if [[ -n "$new_field" ]]; then
                new_type=$(echo "$new_field" | cut -d: -f2)

                if [[ "$old_type" != "$new_type" ]]; then
                    echo -e "${RED}❌ BREAKING: Field type changed in message '$msg'${NC}"
                    echo "   - Field #$field_num '$field_name': $old_type → $new_type"
                    add_to_report "### ❌ BREAKING: Field Type Changed\n**Message:** \`$msg\`\n**Field:** \`$field_name\` (field #$field_num)\n**Old Type:** \`$old_type\`\n**New Type:** \`$new_type\`\n**Impact:** Deserialization will fail or produce incorrect values\n"
                    ((BREAKING_COUNT++))
                fi
            fi
        done <<< "$OLD_FIELDS"
    fi
done

echo ""

# Check for removed services
echo "📊 Checking for removed services..."
OLD_SERVICES=$(grep -E "^service [A-Z]" "$OLD_PROTO" | awk '{print $2}' | sort || echo "")
NEW_SERVICES=$(grep -E "^service [A-Z]" "$NEW_PROTO" | awk '{print $2}' | sort || echo "")

REMOVED_SERVICES=$(comm -23 <(echo "$OLD_SERVICES") <(echo "$NEW_SERVICES"))

if [[ -n "$REMOVED_SERVICES" ]]; then
    echo -e "${RED}❌ BREAKING: Removed services detected${NC}"
    while IFS= read -r svc; do
        [[ -z "$svc" ]] && continue
        echo "   - $svc"
        add_to_report "### ❌ BREAKING: Removed Service\n**Service:** \`$svc\`\n**Impact:** Clients calling this service will fail with unimplemented errors\n"
        ((BREAKING_COUNT++))
    done <<< "$REMOVED_SERVICES"
fi

echo ""

# Check for removed RPC methods
echo "📊 Checking for removed RPC methods..."

for svc in $OLD_SERVICES; do
    if echo "$NEW_SERVICES" | grep -q "^${svc}$"; then
        OLD_RPCS=$(sed -n "/^service ${svc}/,/^}/p" "$OLD_PROTO" | \
            grep -E "^[[:space:]]+rpc [A-Z]" | \
            awk '{print $2}' | \
            sed 's/(.*//' | \
            sort || echo "")

        NEW_RPCS=$(sed -n "/^service ${svc}/,/^}/p" "$NEW_PROTO" | \
            grep -E "^[[:space:]]+rpc [A-Z]" | \
            awk '{print $2}' | \
            sed 's/(.*//' | \
            sort || echo "")

        REMOVED_RPCS=$(comm -23 <(echo "$OLD_RPCS") <(echo "$NEW_RPCS"))

        if [[ -n "$REMOVED_RPCS" ]]; then
            echo -e "${RED}❌ BREAKING: Removed RPC methods in service '$svc'${NC}"
            while IFS= read -r rpc; do
                [[ -z "$rpc" ]] && continue
                echo "   - $rpc"
                add_to_report "### ❌ BREAKING: Removed RPC Method\n**Service:** \`$svc\`\n**Method:** \`$rpc\`\n**Impact:** Clients calling this method will receive unimplemented errors\n"
                ((BREAKING_COUNT++))
            done <<< "$REMOVED_RPCS"
        fi
    fi
done

echo ""

# Summary
echo "================================"
echo "📋 Summary"
echo "================================"
echo -e "${RED}Breaking changes: $BREAKING_COUNT${NC}"
echo -e "${YELLOW}Non-breaking changes: $NON_BREAKING_COUNT${NC}"
echo ""

# Generate report if output file specified
if [[ -n "$OUTPUT_FILE" ]]; then
    {
        echo "# Protocol Buffer Breaking Change Report"
        echo ""
        echo "**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo "**Old Proto:** $OLD_PROTO"
        echo "**New Proto:** $NEW_PROTO"
        echo ""
        echo "## Summary"
        echo ""
        echo "- **Breaking Changes:** $BREAKING_COUNT"
        echo "- **Non-Breaking Changes:** $NON_BREAKING_COUNT"
        echo ""
        if [[ $BREAKING_COUNT -gt 0 ]]; then
            echo "⚠️ **RECOMMENDATION:** This proto change requires a **MAJOR version bump** (e.g., v2.0.0)"
        else
            echo "✅ **RECOMMENDATION:** This proto change requires a **MINOR version bump** (e.g., v1.1.0)"
        fi
        echo ""
        echo "## Detected Changes"
        echo ""
        echo -e "$REPORT"
        echo ""
        echo "## Protobuf Best Practices"
        echo ""
        echo "1. **NEVER reuse field numbers** - Even if you delete a field"
        echo "2. **NEVER change field types** - This breaks wire format compatibility"
        echo "3. **Use reserved for deleted fields** - \`reserved 2, 15, 9 to 11;\`"
        echo "4. **Add new fields as optional** - Old clients can safely ignore"
        echo "5. **Deprecate before removing** - Give clients time to migrate"
        echo ""
    } > "$OUTPUT_FILE"

    echo "📄 Report written to: $OUTPUT_FILE"
    echo ""
fi

# Exit with appropriate code
if [[ $BREAKING_COUNT -gt 0 ]]; then
    echo "❌ Breaking changes detected - MAJOR version bump required"
    exit 1
else
    echo "✅ No breaking changes detected"
    exit 0
fi

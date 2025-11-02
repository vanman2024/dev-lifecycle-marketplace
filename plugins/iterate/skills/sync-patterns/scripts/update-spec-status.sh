#!/bin/bash
# update-spec-status.sh
# Update status markers in specification documents

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Valid status values
VALID_STATUSES=("complete" "in-progress" "pending" "blocked")

# Usage information
usage() {
    cat <<EOF
Usage: $0 <spec-file> <status> [reason]

Update status markers in specification documents.

Arguments:
    spec-file    Path to specification markdown file
    status       New status: complete, in-progress, pending, blocked
    reason       Reason for status change (required for 'blocked' status)

Options:
    -h, --help      Show this help message
    -u, --user      User/agent making the change (default: current user)
    -n, --no-backup Do not create backup before modification

Examples:
    $0 specs/auth-feature.md complete
    $0 specs/api.md blocked "Waiting for API key"
    $0 specs/feature.md in-progress --user="sync-analyzer"

Exit codes:
    0 - Success
    1 - Invalid arguments
    2 - File not found
    3 - Invalid status
    5 - Write permission error
EOF
}

# Parse arguments
SPEC_FILE=""
NEW_STATUS=""
REASON=""
UPDATED_BY="${USER:-agent}"
CREATE_BACKUP=1

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -u|--user)
            UPDATED_BY="$2"
            shift 2
            ;;
        --user=*)
            UPDATED_BY="${1#*=}"
            shift
            ;;
        -n|--no-backup)
            CREATE_BACKUP=0
            shift
            ;;
        *)
            if [[ -z "$SPEC_FILE" ]]; then
                SPEC_FILE="$1"
            elif [[ -z "$NEW_STATUS" ]]; then
                NEW_STATUS="$1"
            elif [[ -z "$REASON" ]]; then
                REASON="$1"
            else
                echo "Error: Unknown argument: $1" >&2
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$SPEC_FILE" ]]; then
    echo "Error: spec-file is required" >&2
    usage
    exit 1
fi

if [[ -z "$NEW_STATUS" ]]; then
    echo "Error: status is required" >&2
    usage
    exit 1
fi

if [[ ! -f "$SPEC_FILE" ]]; then
    echo "Error: Spec file not found: $SPEC_FILE" >&2
    exit 2
fi

# Validate status
NEW_STATUS=$(echo "$NEW_STATUS" | tr '[:upper:]' '[:lower:]')
if [[ ! " ${VALID_STATUSES[@]} " =~ " ${NEW_STATUS} " ]]; then
    echo "Error: Invalid status: $NEW_STATUS" >&2
    echo "Valid statuses: ${VALID_STATUSES[*]}" >&2
    exit 3
fi

# Require reason for blocked status
if [[ "$NEW_STATUS" == "blocked" ]] && [[ -z "$REASON" ]]; then
    echo "Error: Reason is required for 'blocked' status" >&2
    exit 1
fi

# Check write permission
if [[ ! -w "$SPEC_FILE" ]]; then
    echo "Error: No write permission for: $SPEC_FILE" >&2
    exit 5
fi

# Create backup if requested
if [[ $CREATE_BACKUP -eq 1 ]]; then
    cp "$SPEC_FILE" "$SPEC_FILE.bak"
fi

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Extract current frontmatter
has_frontmatter() {
    head -1 "$1" | grep -q "^---$"
}

extract_frontmatter() {
    local file="$1"
    if has_frontmatter "$file"; then
        sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d'
    else
        echo ""
    fi
}

extract_body() {
    local file="$1"
    if has_frontmatter "$file"; then
        sed -n '/^---$/,/^---$/!p' "$file" | tail -n +2
    else
        cat "$file"
    fi
}

# Get current status from frontmatter
get_current_status() {
    local frontmatter="$1"
    echo "$frontmatter" | grep -E "^status:" | sed 's/^status:[[:space:]]*//' || echo "pending"
}

# Update or add status field in frontmatter
update_frontmatter_status() {
    local frontmatter="$1"
    local new_status="$2"
    local timestamp="$3"
    local reason="$4"
    local updated_by="$5"

    # Check if status field exists
    if echo "$frontmatter" | grep -q "^status:"; then
        # Update existing status
        frontmatter=$(echo "$frontmatter" | sed "s/^status:.*/status: $new_status/")
    else
        # Add status field
        frontmatter=$(printf "%s\nstatus: %s" "$frontmatter" "$new_status")
    fi

    # Update or add last_updated field
    if echo "$frontmatter" | grep -q "^last_updated:"; then
        frontmatter=$(echo "$frontmatter" | sed "s/^last_updated:.*/last_updated: $timestamp/")
    else
        frontmatter=$(printf "%s\nlast_updated: %s" "$frontmatter" "$timestamp")
    fi

    # Update or add updated_by field
    if echo "$frontmatter" | grep -q "^updated_by:"; then
        frontmatter=$(echo "$frontmatter" | sed "s/^updated_by:.*/updated_by: $updated_by/")
    else
        frontmatter=$(printf "%s\nupdated_by: %s" "$frontmatter" "$updated_by")
    fi

    # Add blocked_reason if status is blocked
    if [[ "$new_status" == "blocked" ]] && [[ -n "$reason" ]]; then
        if echo "$frontmatter" | grep -q "^blocked_reason:"; then
            frontmatter=$(echo "$frontmatter" | sed "s/^blocked_reason:.*/blocked_reason: $reason/")
        else
            frontmatter=$(printf "%s\nblocked_reason: %s" "$frontmatter" "$reason")
        fi
    else
        # Remove blocked_reason if not blocked
        frontmatter=$(echo "$frontmatter" | grep -v "^blocked_reason:" || true)
    fi

    # Add to status history
    local history_entry="  - status: $new_status, date: $timestamp, by: $updated_by"
    if [[ -n "$reason" ]]; then
        history_entry="$history_entry, reason: $reason"
    fi

    if echo "$frontmatter" | grep -q "^status_history:"; then
        # Append to existing history
        frontmatter=$(printf "%s\n%s" "$frontmatter" "$history_entry")
    else
        # Create new history
        frontmatter=$(printf "%s\nstatus_history:\n%s" "$frontmatter" "$history_entry")
    fi

    echo "$frontmatter"
}

# Main update logic
update_status() {
    local spec_file="$1"
    local new_status="$2"
    local timestamp="$3"
    local reason="$4"
    local updated_by="$5"

    # Read current content
    local current_frontmatter=""
    local body=""

    if has_frontmatter "$spec_file"; then
        current_frontmatter=$(extract_frontmatter "$spec_file")
        body=$(extract_body "$spec_file")
    else
        # No frontmatter, create new one
        current_frontmatter=""
        body=$(cat "$spec_file")
    fi

    # Get current status
    local old_status=$(get_current_status "$current_frontmatter")

    # Update frontmatter
    local new_frontmatter=$(update_frontmatter_status "$current_frontmatter" "$new_status" "$timestamp" "$reason" "$updated_by")

    # Write updated file
    {
        echo "---"
        echo "$new_frontmatter"
        echo "---"
        echo
        echo "$body"
    } > "$spec_file"

    # Output success message
    echo -e "${GREEN}✓ Successfully updated spec status${NC}"
    echo
    echo -e "${BLUE}File:${NC} $spec_file"
    echo -e "${BLUE}Old Status:${NC} $old_status"
    echo -e "${BLUE}New Status:${NC} $new_status"
    echo -e "${BLUE}Updated By:${NC} $updated_by"
    echo -e "${BLUE}Timestamp:${NC} $timestamp"
    if [[ -n "$reason" ]]; then
        echo -e "${BLUE}Reason:${NC} $reason"
    fi

    if [[ $CREATE_BACKUP -eq 1 ]]; then
        echo
        echo -e "${YELLOW}Backup created:${NC} $spec_file.bak"
    fi
}

# Run update
update_status "$SPEC_FILE" "$NEW_STATUS" "$TIMESTAMP" "$REASON" "$UPDATED_BY"

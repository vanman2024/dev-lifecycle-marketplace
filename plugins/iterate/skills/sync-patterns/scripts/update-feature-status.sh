#!/bin/bash
# update-feature-status.sh
# Update feature status in features.json based on file paths or feature ID

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    cat <<EOF
Usage: $0 <feature-id-or-keyword> [status]

Update feature status in features.json.

Arguments:
    feature-id-or-keyword   Feature ID (F052) or keyword to match (consultant, blog)
    status                  New status: planned, in-progress, completed (default: in-progress)

Options:
    -h, --help      Show this help
    -f, --file      Path to features.json (default: ./features.json)
    --check-tasks   Check tasks.md completion before setting to completed

Examples:
    $0 F052 in-progress
    $0 consultant                    # Matches F052 Consultant Booking
    $0 F052 completed --check-tasks  # Only set completed if tasks done
EOF
}

FEATURES_FILE="features.json"
CHECK_TASKS=0
FEATURE_INPUT=""
NEW_STATUS="in-progress"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -f|--file) FEATURES_FILE="$2"; shift 2 ;;
        --check-tasks) CHECK_TASKS=1; shift ;;
        *)
            if [[ -z "$FEATURE_INPUT" ]]; then
                FEATURE_INPUT="$1"
            else
                NEW_STATUS="$1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$FEATURE_INPUT" ]]; then
    echo "Error: feature-id or keyword required" >&2
    usage
    exit 1
fi

if [[ ! -f "$FEATURES_FILE" ]]; then
    echo "Error: features.json not found at $FEATURES_FILE" >&2
    exit 2
fi

# Find feature by ID or keyword match
find_feature() {
    local input="$1"
    local file="$2"

    # Try exact ID match first (F052, F001, etc)
    if [[ "$input" =~ ^F[0-9]+$ ]]; then
        jq -r --arg id "$input" '.features[] | select(.id == $id) | .id' "$file" 2>/dev/null
    else
        # Keyword match in name
        jq -r --arg kw "$input" '.features[] | select(.name | ascii_downcase | contains($kw | ascii_downcase)) | .id' "$file" 2>/dev/null | head -1
    fi
}

# Get current status
get_status() {
    local id="$1"
    local file="$2"
    jq -r --arg id "$id" '.features[] | select(.id == $id) | .status' "$file"
}

# Get feature name
get_name() {
    local id="$1"
    local file="$2"
    jq -r --arg id "$id" '.features[] | select(.id == $id) | .name' "$file"
}

# Check tasks.md completion for feature
check_task_completion() {
    local feature_id="$1"

    # Find tasks.md for this feature
    local tasks_file=$(find specs -name "tasks.md" -path "*${feature_id}*" 2>/dev/null | head -1)

    if [[ -z "$tasks_file" ]]; then
        echo "no-tasks-file"
        return
    fi

    local total=$(grep -c "^\s*- \[" "$tasks_file" 2>/dev/null || echo 0)
    local done=$(grep -c "^\s*- \[x\]" "$tasks_file" 2>/dev/null || echo 0)

    if [[ "$total" -eq 0 ]]; then
        echo "no-tasks"
    elif [[ "$done" -eq "$total" ]]; then
        echo "all-complete"
    else
        echo "$done/$total"
    fi
}

# Update status in features.json
update_status() {
    local id="$1"
    local new_status="$2"
    local file="$3"

    # Use jq to update
    local tmp=$(mktemp)
    jq --arg id "$id" --arg status "$new_status" '
        .features = [.features[] | if .id == $id then .status = $status else . end]
    ' "$file" > "$tmp" && mv "$tmp" "$file"
}

# Main
FEATURE_ID=$(find_feature "$FEATURE_INPUT" "$FEATURES_FILE")

if [[ -z "$FEATURE_ID" ]]; then
    echo -e "${YELLOW}No feature found matching: $FEATURE_INPUT${NC}" >&2
    exit 0  # Exit cleanly - no match isn't an error for commit flow
fi

FEATURE_NAME=$(get_name "$FEATURE_ID" "$FEATURES_FILE")
OLD_STATUS=$(get_status "$FEATURE_ID" "$FEATURES_FILE")

# Check tasks if setting to completed
if [[ "$NEW_STATUS" == "completed" ]] && [[ $CHECK_TASKS -eq 1 ]]; then
    TASK_STATUS=$(check_task_completion "$FEATURE_ID")
    if [[ "$TASK_STATUS" != "all-complete" ]] && [[ "$TASK_STATUS" != "no-tasks" ]] && [[ "$TASK_STATUS" != "no-tasks-file" ]]; then
        echo -e "${YELLOW}Cannot set to completed - tasks incomplete: $TASK_STATUS${NC}"
        NEW_STATUS="in-progress"
    fi
fi

# Skip if already at target status
if [[ "$OLD_STATUS" == "$NEW_STATUS" ]]; then
    echo -e "${BLUE}$FEATURE_ID ($FEATURE_NAME): already $NEW_STATUS${NC}"
    exit 0
fi

# Don't downgrade completed → in-progress
if [[ "$OLD_STATUS" == "completed" ]] && [[ "$NEW_STATUS" == "in-progress" ]]; then
    echo -e "${BLUE}$FEATURE_ID ($FEATURE_NAME): keeping as completed${NC}"
    exit 0
fi

# Update
update_status "$FEATURE_ID" "$NEW_STATUS" "$FEATURES_FILE"

echo -e "${GREEN}📊 $FEATURE_ID ($FEATURE_NAME): $OLD_STATUS → $NEW_STATUS${NC}"

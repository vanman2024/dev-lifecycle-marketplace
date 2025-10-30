#!/usr/bin/env bash
# list-specs.sh - List all specifications with filtering and formatting
# Usage: list-specs.sh [--status STATUS] [--format FORMAT]

set -euo pipefail

# Configuration
SPECS_DIR="${SPECS_DIR:-./specs}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Helper functions
log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Show usage
show_usage() {
    cat <<EOF
Usage: list-specs.sh [OPTIONS]

Lists all specifications with filtering and formatting options.

Options:
  -d, --dir DIR         Specs directory (default: ./specs)
  -s, --status STATUS   Filter by status (draft, in-progress, review, approved, implemented, rejected)
  -p, --priority PRIO   Filter by priority (low, medium, high, critical)
  -t, --tag TAG         Filter by tag
  -f, --format FORMAT   Output format: table, json, markdown, csv (default: table)
  -h, --help            Show this help message

Examples:
  list-specs.sh
  list-specs.sh --status draft
  list-specs.sh --format json
  list-specs.sh --status in-progress --priority high

Environment Variables:
  SPECS_DIR             Directory for specifications (default: ./specs)
EOF
}

# Parse arguments
STATUS_FILTER=""
PRIORITY_FILTER=""
TAG_FILTER=""
OUTPUT_FORMAT="table"

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            SPECS_DIR="$2"
            shift 2
            ;;
        -s|--status)
            STATUS_FILTER="$2"
            shift 2
            ;;
        -p|--priority)
            PRIORITY_FILTER="$2"
            shift 2
            ;;
        -t|--tag)
            TAG_FILTER="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if specs directory exists
if [[ ! -d "$SPECS_DIR" ]]; then
    log_error "Specs directory not found: $SPECS_DIR"
    exit 1
fi

# Find all spec files
SPEC_FILES=$(find "$SPECS_DIR" -maxdepth 1 -name "[0-9][0-9][0-9]-*.md" | sort)

if [[ -z "$SPEC_FILES" ]]; then
    log_error "No specifications found in $SPECS_DIR"
    exit 1
fi

# Extract spec data
declare -a SPECS
while IFS= read -r spec_file; do
    if [[ ! -f "$spec_file" ]]; then
        continue
    fi

    # Extract frontmatter
    spec_id=$(grep -m1 "^spec-id:" "$spec_file" | sed 's/spec-id: *//' | xargs || echo "000")
    title=$(grep -m1 "^title:" "$spec_file" | sed 's/title: *//' | xargs || echo "Unknown")
    status=$(grep -m1 "^status:" "$spec_file" | sed 's/status: *//' | xargs || echo "draft")
    priority=$(grep -m1 "^priority:" "$spec_file" | sed 's/priority: *//' | xargs || echo "medium")
    owner=$(grep -m1 "^owner:" "$spec_file" | sed 's/owner: *//' | xargs || echo "unknown")
    updated=$(grep -m1 "^updated:" "$spec_file" | sed 's/updated: *//' | xargs || echo "unknown")
    tags=$(grep -m1 "^tags:" "$spec_file" | sed 's/tags: *//' | xargs || echo "[]")

    # Apply filters
    if [[ -n "$STATUS_FILTER" && "$status" != "$STATUS_FILTER" ]]; then
        continue
    fi

    if [[ -n "$PRIORITY_FILTER" && "$priority" != "$PRIORITY_FILTER" ]]; then
        continue
    fi

    if [[ -n "$TAG_FILTER" && ! "$tags" =~ $TAG_FILTER ]]; then
        continue
    fi

    # Store spec data
    SPECS+=("$spec_id|$title|$status|$priority|$owner|$updated|$(basename "$spec_file")")
done <<< "$SPEC_FILES"

# Check if any specs match filters
if [[ ${#SPECS[@]} -eq 0 ]]; then
    log_error "No specifications match the filters"
    exit 1
fi

# Get status color
get_status_color() {
    case $1 in
        draft) echo "$YELLOW" ;;
        in-progress) echo "$BLUE" ;;
        review) echo "$CYAN" ;;
        approved) echo "$GREEN" ;;
        implemented) echo "$GREEN" ;;
        rejected) echo "$RED" ;;
        *) echo "$NC" ;;
    esac
}

# Get priority symbol
get_priority_symbol() {
    case $1 in
        critical) echo "🔴" ;;
        high) echo "🟠" ;;
        medium) echo "🟡" ;;
        low) echo "🟢" ;;
        *) echo "⚪" ;;
    esac
}

# Output formats
case $OUTPUT_FORMAT in
    table)
        # Print table header
        printf "${CYAN}%-6s %-40s %-15s %-10s %-15s %-12s${NC}\n" "ID" "Title" "Status" "Priority" "Owner" "Updated"
        printf "%.0s-" {1..110}
        echo

        # Print each spec
        for spec in "${SPECS[@]}"; do
            IFS='|' read -r spec_id title status priority owner updated filename <<< "$spec"
            color=$(get_status_color "$status")
            priority_symbol=$(get_priority_symbol "$priority")

            printf "%-6s %-40s ${color}%-15s${NC} %s %-9s %-15s %-12s\n" \
                "$spec_id" \
                "${title:0:40}" \
                "$status" \
                "$priority_symbol" \
                "$priority" \
                "$owner" \
                "$updated"
        done
        ;;

    json)
        echo "["
        first=true
        for spec in "${SPECS[@]}"; do
            IFS='|' read -r spec_id title status priority owner updated filename <<< "$spec"

            if [[ "$first" == "false" ]]; then
                echo ","
            fi
            first=false

            cat <<EOF
  {
    "id": "$spec_id",
    "title": "$title",
    "status": "$status",
    "priority": "$priority",
    "owner": "$owner",
    "updated": "$updated",
    "filename": "$filename"
  }
EOF
        done
        echo ""
        echo "]"
        ;;

    markdown)
        echo "| ID | Title | Status | Priority | Owner | Updated |"
        echo "|----|-------|--------|----------|-------|---------|"

        for spec in "${SPECS[@]}"; do
            IFS='|' read -r spec_id title status priority owner updated filename <<< "$spec"
            echo "| $spec_id | $title | $status | $priority | $owner | $updated |"
        done
        ;;

    csv)
        echo "ID,Title,Status,Priority,Owner,Updated,Filename"
        for spec in "${SPECS[@]}"; do
            IFS='|' read -r spec_id title status priority owner updated filename <<< "$spec"
            echo "\"$spec_id\",\"$title\",\"$status\",\"$priority\",\"$owner\",\"$updated\",\"$filename\""
        done
        ;;

    *)
        log_error "Invalid output format: $OUTPUT_FORMAT"
        exit 1
        ;;
esac

# Print summary
if [[ "$OUTPUT_FORMAT" == "table" ]]; then
    echo ""
    echo -e "${CYAN}Total specifications: ${#SPECS[@]}${NC}"
fi

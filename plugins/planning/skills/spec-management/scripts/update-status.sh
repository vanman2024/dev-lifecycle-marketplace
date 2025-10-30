#!/usr/bin/env bash
# update-status.sh - Update specification status with history tracking
# Usage: update-status.sh <spec-file> <new-status> [comment]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    cat <<EOF
Usage: update-status.sh <spec-file> <new-status> [comment]

Updates specification status with history tracking.

Arguments:
  spec-file     Path to specification file
  new-status    New status value
  comment       Optional comment for status change

Valid Status Values:
  draft         Initial draft state
  in-progress   Currently being implemented
  review        Under review
  approved      Approved for implementation
  implemented   Fully implemented
  rejected      Rejected/cancelled

Options:
  -f, --force   Skip status transition validation
  -h, --help    Show this help message

Status Transition Rules:
  draft → in-progress, rejected
  in-progress → review, draft, rejected
  review → approved, in-progress, rejected
  approved → in-progress, implemented
  implemented → (terminal state)
  rejected → (terminal state)

Examples:
  update-status.sh specs/001-auth.md in-progress
  update-status.sh specs/001-auth.md approved "Reviewed by team"
  update-status.sh --force specs/001-auth.md implemented
EOF
}

# Parse arguments
SPEC_FILE=""
NEW_STATUS=""
COMMENT=""
FORCE_UPDATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_UPDATE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            if [[ -z "$SPEC_FILE" ]]; then
                SPEC_FILE="$1"
            elif [[ -z "$NEW_STATUS" ]]; then
                NEW_STATUS="$1"
            else
                COMMENT="$1"
            fi
            shift
            ;;
    esac
done

# Validate inputs
if [[ -z "$SPEC_FILE" ]]; then
    log_error "Spec file is required"
    show_usage
    exit 1
fi

if [[ -z "$NEW_STATUS" ]]; then
    log_error "New status is required"
    show_usage
    exit 1
fi

if [[ ! -f "$SPEC_FILE" ]]; then
    log_error "Spec file not found: $SPEC_FILE"
    exit 1
fi

# Validate status value
VALID_STATUSES="draft in-progress review approved implemented rejected"
if [[ ! " $VALID_STATUSES " =~ " $NEW_STATUS " ]]; then
    log_error "Invalid status: $NEW_STATUS"
    log_error "Valid statuses: $VALID_STATUSES"
    exit 1
fi

# Get current status
CURRENT_STATUS=$(grep -m1 "^status:" "$SPEC_FILE" | sed 's/status: *//' | xargs || echo "unknown")

if [[ "$CURRENT_STATUS" == "unknown" ]]; then
    log_error "Could not find current status in spec file"
    exit 1
fi

log_info "Current status: $CURRENT_STATUS"
log_info "New status: $NEW_STATUS"

# Check if status is changing
if [[ "$CURRENT_STATUS" == "$NEW_STATUS" ]]; then
    log_warning "Status is already $NEW_STATUS"
    exit 0
fi

# Validate status transitions (unless forced)
if [[ "$FORCE_UPDATE" == "false" ]]; then
    VALID_TRANSITION=false

    case "$CURRENT_STATUS" in
        draft)
            if [[ "$NEW_STATUS" == "in-progress" || "$NEW_STATUS" == "rejected" ]]; then
                VALID_TRANSITION=true
            fi
            ;;
        in-progress)
            if [[ "$NEW_STATUS" == "review" || "$NEW_STATUS" == "draft" || "$NEW_STATUS" == "rejected" ]]; then
                VALID_TRANSITION=true
            fi
            ;;
        review)
            if [[ "$NEW_STATUS" == "approved" || "$NEW_STATUS" == "in-progress" || "$NEW_STATUS" == "rejected" ]]; then
                VALID_TRANSITION=true
            fi
            ;;
        approved)
            if [[ "$NEW_STATUS" == "in-progress" || "$NEW_STATUS" == "implemented" ]]; then
                VALID_TRANSITION=true
            fi
            ;;
        implemented)
            log_error "Cannot change status from 'implemented' (terminal state)"
            exit 1
            ;;
        rejected)
            log_error "Cannot change status from 'rejected' (terminal state)"
            exit 1
            ;;
    esac

    if [[ "$VALID_TRANSITION" == "false" ]]; then
        log_error "Invalid status transition: $CURRENT_STATUS → $NEW_STATUS"
        log_error "Use --force to override transition validation"
        exit 1
    fi
fi

# Create backup
BACKUP_FILE="${SPEC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$SPEC_FILE" "$BACKUP_FILE"
log_info "Created backup: $BACKUP_FILE"

# Update status field
CURRENT_DATE=$(date +%Y-%m-%d)
CURRENT_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Update status
sed -i "s/^status: .*/status: $NEW_STATUS/" "$SPEC_FILE"

# Update updated field
sed -i "s/^updated: .*/updated: $CURRENT_DATE/" "$SPEC_FILE"

# Add status history to spec (append to end of file)
if ! grep -q "^## Status History" "$SPEC_FILE"; then
    cat >> "$SPEC_FILE" <<EOF

## Status History

| Date | From | To | Comment |
|------|------|----|---------|
EOF
fi

# Append to status history
COMMENT_ESCAPED="${COMMENT:-Status updated}"
echo "| $CURRENT_TIMESTAMP | $CURRENT_STATUS | $NEW_STATUS | $COMMENT_ESCAPED |" >> "$SPEC_FILE"

log_success "Updated status: $CURRENT_STATUS → $NEW_STATUS"

if [[ -n "$COMMENT" ]]; then
    log_info "Comment: $COMMENT"
fi

# Show next recommended actions based on new status
echo ""
log_info "Recommended next actions:"
case "$NEW_STATUS" in
    draft)
        echo "  - Complete all required sections"
        echo "  - Run validation: validate-spec.sh $SPEC_FILE"
        ;;
    in-progress)
        echo "  - Break down tasks in detail"
        echo "  - Assign task owners"
        echo "  - Update progress regularly"
        ;;
    review)
        echo "  - Request team review"
        echo "  - Address review comments"
        echo "  - Update based on feedback"
        ;;
    approved)
        echo "  - Begin implementation"
        echo "  - Track task completion"
        echo "  - Update status to implemented when done"
        ;;
    implemented)
        echo "  - Verify success criteria met"
        echo "  - Archive spec if needed"
        echo "  - Document lessons learned"
        ;;
    rejected)
        echo "  - Document rejection reason"
        echo "  - Consider archiving spec"
        echo "  - Review alternatives"
        ;;
esac

# Cleanup backup on success
trash-put "$BACKUP_FILE" 2>/dev/null || rm -f "$BACKUP_FILE"

echo ""
log_success "Status update complete"

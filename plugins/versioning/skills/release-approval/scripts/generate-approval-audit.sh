#!/bin/bash
# Generate comprehensive approval audit record for a release
# Usage: bash generate-approval-audit.sh <version> <decision> [output-file]

set -euo pipefail

VERSION="${1:-}"
DECISION="${2:-}"
OUTPUT_FILE="${3:-.github/releases/approvals/v${VERSION}.json}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate inputs
validate_inputs() {
    if [ -z "$VERSION" ]; then
        log_error "Version is required"
        echo "Usage: bash generate-approval-audit.sh <version> <decision> [output-file]"
        echo "Example: bash generate-approval-audit.sh 1.2.3 approved"
        exit 1
    fi

    if [ -z "$DECISION" ]; then
        log_error "Decision is required"
        echo "Valid decisions: approved, approved_with_conditions, rejected, pending"
        exit 1
    fi

    if [[ ! "$DECISION" =~ ^(approved|approved_with_conditions|rejected|pending)$ ]]; then
        log_error "Invalid decision: $DECISION"
        echo "Valid decisions: approved, approved_with_conditions, rejected, pending"
        exit 1
    fi
}

# Create output directory
create_output_directory() {
    local dir=$(dirname "$OUTPUT_FILE")
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    fi
}

# Parse GitHub issue for approvals
parse_github_approvals() {
    local version="$1"
    local approvals='[]'

    # Check if GitHub CLI is available
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI not found. Skipping GitHub approval parsing."
        echo "$approvals"
        return
    fi

    # Find approval issue
    local issue_title="Release Approval: v$version"
    local issue_number=$(gh issue list --label "release,approval-required" --search "$issue_title" --json number --jq '.[0].number' 2>/dev/null || echo "")

    if [ -z "$issue_number" ] || [ "$issue_number" = "null" ]; then
        log_warn "No GitHub approval issue found"
        echo "$approvals"
        return
    fi

    log_info "Found approval issue: #$issue_number"

    # Parse comments for approval decisions
    if command -v jq &> /dev/null; then
        approvals=$(gh issue view "$issue_number" --json comments --jq '[
          .comments[] |
          select(.body | test("/approve|/reject")) |
          {
            stage: "github",
            approver: .author.login,
            decision: (if (.body | contains("/approve")) then "approved" elif (.body | contains("/reject")) then "rejected" else "pending" end),
            timestamp: .createdAt,
            comments: .body
          }
        ]' 2>/dev/null || echo '[]')
    fi

    echo "$approvals"
}

# Build approval record JSON
build_approval_record() {
    local version="$1"
    local decision="$2"
    local github_approvals="$3"

    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local git_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    local git_branch=$(git branch --show-current 2>/dev/null || echo "unknown")

    # Build base record
    local record='{
  "version": "'"$version"'",
  "requested_at": "'"$current_time"'",
  "completed_at": "'"$(if [ "$decision" != "pending" ]; then echo "$current_time"; else echo "null"; fi)"'",
  "final_decision": "'"$decision"'",
  "metadata": {
    "git_commit": "'"$git_commit"'",
    "git_branch": "'"$git_branch"'",
    "generated_by": "generate-approval-audit.sh",
    "generated_at": "'"$current_time"'"
  },
  "approvals": '"$github_approvals"',
  "conditions": []
}'

    # Add conditions if approved with conditions
    if [ "$decision" = "approved_with_conditions" ]; then
        if command -v jq &> /dev/null; then
            record=$(echo "$record" | jq '.conditions = ["Monitor post-release issues", "Review performance metrics", "Verify rollback procedures"]')
        fi
    fi

    echo "$record"
}

# Format and save record
save_approval_record() {
    local record="$1"
    local output_file="$2"

    # Format JSON if jq is available
    if command -v jq &> /dev/null; then
        echo "$record" | jq '.' > "$output_file"
    else
        echo "$record" > "$output_file"
    fi

    log_info "Saved approval record: $output_file"
}

# Display summary
display_summary() {
    local version="$1"
    local decision="$2"
    local output_file="$3"

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "           APPROVAL AUDIT RECORD GENERATED"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    log_info "Version:  v$version"
    log_info "Decision: $decision"
    log_info "File:     $output_file"
    echo ""

    # Display file content
    if command -v jq &> /dev/null && [ -f "$output_file" ]; then
        log_info "Record content:"
        echo ""
        jq '.' "$output_file"
    else
        cat "$output_file"
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo ""
    log_info "Next steps:"
    echo ""
    echo "  1. Commit approval record:"
    echo "     git add $output_file"
    echo "     git commit -m \"docs(release): approval record for v$version\""
    echo ""
    echo "  2. View approval status:"
    echo "     bash scripts/check-approval-status.sh $version"
    echo ""
    echo "  3. Proceed with release (if approved):"
    echo "     git push --tags"
    echo ""
}

# Main execution
main() {
    log_info "Generating approval audit record for v$VERSION"

    validate_inputs
    create_output_directory

    # Parse approvals from GitHub
    local github_approvals=$(parse_github_approvals "$VERSION")

    # Build approval record
    local approval_record=$(build_approval_record "$VERSION" "$DECISION" "$github_approvals")

    # Save record
    save_approval_record "$approval_record" "$OUTPUT_FILE"

    # Display summary
    display_summary "$VERSION" "$DECISION" "$OUTPUT_FILE"

    log_info "Audit record generation complete"
}

main

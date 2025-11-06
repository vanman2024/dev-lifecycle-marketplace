#!/bin/bash
# Check approval status for a specific release version
# Usage: bash check-approval-status.sh <version>

set -euo pipefail

VERSION="${1:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

log_status() {
    echo -e "${CYAN}$1${NC}"
}

# Validate inputs
validate_inputs() {
    if [ -z "$VERSION" ]; then
        log_error "Version is required"
        echo "Usage: bash check-approval-status.sh <version>"
        echo "Example: bash check-approval-status.sh 1.2.3"
        exit 1
    fi
}

# Check if approval record exists
check_approval_record() {
    local version="$1"
    local approval_file=".github/releases/approvals/v${version}.json"

    if [ -f "$approval_file" ]; then
        log_info "Found approval record: $approval_file"
        return 0
    else
        log_warn "No approval record found: $approval_file"
        return 1
    fi
}

# Parse approval record
parse_approval_record() {
    local version="$1"
    local approval_file=".github/releases/approvals/v${version}.json"

    if [ ! -f "$approval_file" ]; then
        return
    fi

    log_status ""
    log_status "═══════════════════════════════════════════════════════"
    log_status "               APPROVAL RECORD: v$version"
    log_status "═══════════════════════════════════════════════════════"

    # Parse JSON using basic tools (in production, use jq)
    # For now, display file content if it exists
    if command -v jq &> /dev/null; then
        local requested_at=$(jq -r '.requested_at' "$approval_file" 2>/dev/null || echo "N/A")
        local completed_at=$(jq -r '.completed_at' "$approval_file" 2>/dev/null || echo "Pending")
        local final_decision=$(jq -r '.final_decision' "$approval_file" 2>/dev/null || echo "Pending")
        local approval_count=$(jq '.approvals | length' "$approval_file" 2>/dev/null || echo "0")

        log_status ""
        log_status "📦 Version:      v$version"
        log_status "📅 Requested:    $requested_at"
        log_status "✅ Completed:    $completed_at"
        log_status "🎯 Decision:     $final_decision"
        log_status "📝 Approvals:    $approval_count"
        log_status ""

        # Display individual approvals
        if [ "$approval_count" -gt 0 ]; then
            log_status "───────────────────────────────────────────────────────"
            log_status "                   APPROVAL DETAILS"
            log_status "───────────────────────────────────────────────────────"

            jq -r '.approvals[] | "
Stage:     \(.stage)
Approver:  \(.approver)
Decision:  \(.decision)
Timestamp: \(.timestamp)
Comments:  \(.comments // "None")
───────────────────────────────────────────────────────"' "$approval_file"
        fi
    else
        log_status ""
        log_status "📄 Approval Record Content:"
        log_status ""
        cat "$approval_file"
        log_status ""
        log_warn "Install jq for formatted output: apt-get install jq"
    fi

    log_status "═══════════════════════════════════════════════════════"
}

# Check GitHub approval issue
check_github_issue() {
    local version="$1"

    # Check if GitHub CLI is available
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI (gh) not found. Skipping GitHub issue check."
        return
    fi

    # Check if authenticated
    if ! gh auth status &> /dev/null 2>&1; then
        log_warn "GitHub CLI not authenticated. Skipping GitHub issue check."
        return
    fi

    log_status ""
    log_status "═══════════════════════════════════════════════════════"
    log_status "              GITHUB APPROVAL ISSUE STATUS"
    log_status "═══════════════════════════════════════════════════════"

    local issue_title="Release Approval: v$version"
    local issue_data=$(gh issue list --label "release,approval-required" --search "$issue_title" --json number,title,state,comments --limit 1)

    if [ -z "$issue_data" ] || [ "$issue_data" = "[]" ]; then
        log_warn "No GitHub approval issue found for v$version"
        log_info "Create one with: bash scripts/request-approval.sh $version <stage> github"
        return
    fi

    local issue_number=$(echo "$issue_data" | jq -r '.[0].number' 2>/dev/null || echo "N/A")
    local issue_state=$(echo "$issue_data" | jq -r '.[0].state' 2>/dev/null || echo "N/A")
    local comment_count=$(echo "$issue_data" | jq '.[0].comments | length' 2>/dev/null || echo "0")

    log_status ""
    log_status "🔖 Issue:        #$issue_number"
    log_status "📊 State:        $issue_state"
    log_status "💬 Comments:     $comment_count"
    log_status ""

    if [ "$comment_count" -gt 0 ]; then
        log_status "───────────────────────────────────────────────────────"
        log_status "                  RECENT COMMENTS"
        log_status "───────────────────────────────────────────────────────"

        # Show last 5 comments
        gh issue view "$issue_number" --json comments --jq '.comments[-5:] | .[] | "
Author:  \(.author.login)
Date:    \(.createdAt)
Comment: \(.body | split("\n")[0] | .[0:80])
───────────────────────────────────────────────────────"'
    fi

    log_status ""
    log_status "🔗 View issue: gh issue view $issue_number"
    log_status "═══════════════════════════════════════════════════════"
}

# Generate approval summary
generate_summary() {
    local version="$1"
    local has_record=$2

    log_status ""
    log_status "═══════════════════════════════════════════════════════"
    log_status "                  APPROVAL SUMMARY"
    log_status "═══════════════════════════════════════════════════════"
    log_status ""

    if [ "$has_record" = true ]; then
        local approval_file=".github/releases/approvals/v${version}.json"

        if command -v jq &> /dev/null && [ -f "$approval_file" ]; then
            local final_decision=$(jq -r '.final_decision' "$approval_file" 2>/dev/null || echo "pending")

            case "$final_decision" in
                approved)
                    log_status "✅ Status: APPROVED"
                    log_status ""
                    log_status "🎉 All required approvals obtained!"
                    log_status ""
                    log_status "Next steps:"
                    log_status "  1. Push tags: git push --tags"
                    log_status "  2. Monitor CI: gh run list"
                    log_status "  3. Verify deployment"
                    ;;
                approved_with_conditions)
                    log_status "⚠️  Status: APPROVED WITH CONDITIONS"
                    log_status ""
                    log_status "Release approved but requires monitoring:"
                    jq -r '.conditions[]? // empty | "  • \(.)"' "$approval_file"
                    log_status ""
                    log_status "Next steps:"
                    log_status "  1. Review conditions carefully"
                    log_status "  2. Push tags: git push --tags"
                    log_status "  3. Monitor conditions post-release"
                    ;;
                rejected)
                    log_status "❌ Status: REJECTED"
                    log_status ""
                    log_status "Release rejected. Review reasons:"
                    jq -r '.approvals[] | select(.decision == "rejected") | "  • \(.stage): \(.comments)"' "$approval_file"
                    log_status ""
                    log_status "Next steps:"
                    log_status "  1. Address rejection reasons"
                    log_status "  2. Request re-approval: /versioning:approve-release $version"
                    ;;
                *)
                    log_status "⏳ Status: PENDING"
                    log_status ""
                    log_status "Waiting for approvals..."
                    log_status ""
                    local pending_stages=$(jq -r '.approvals[] | select(.decision == "pending") | .stage' "$approval_file" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
                    if [ -n "$pending_stages" ]; then
                        log_status "Pending stages: $pending_stages"
                    fi
                    ;;
            esac
        else
            log_status "⏳ Status: IN PROGRESS"
            log_status ""
            log_status "Approval workflow active. Check back later."
        fi
    else
        log_status "⚠️  Status: NOT STARTED"
        log_status ""
        log_status "No approval record found for v$version"
        log_status ""
        log_status "Start approval workflow:"
        log_status "  /versioning:approve-release $version"
    fi

    log_status ""
    log_status "═══════════════════════════════════════════════════════"
}

# Main execution
main() {
    log_info "Checking approval status for release v$VERSION"

    validate_inputs

    local has_record=false
    if check_approval_record "$VERSION"; then
        has_record=true
        parse_approval_record "$VERSION"
    fi

    check_github_issue "$VERSION"
    generate_summary "$VERSION" "$has_record"

    log_info ""
    log_info "Approval status check complete."
}

main

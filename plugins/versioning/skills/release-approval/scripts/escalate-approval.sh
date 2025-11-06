#!/bin/bash
# Handle approval timeout escalation
# Usage: bash escalate-approval.sh <version> <stage> <timeout-hours>

set -euo pipefail

VERSION="${1:-}"
STAGE="${2:-}"
TIMEOUT_HOURS="${3:-24}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_escalate() {
    echo -e "${RED}[ESCALATE]${NC} $1"
}

# Validate inputs
validate_inputs() {
    if [ -z "$VERSION" ]; then
        log_error "Version is required"
        echo "Usage: bash escalate-approval.sh <version> <stage> <timeout-hours>"
        echo "Example: bash escalate-approval.sh 1.2.3 development 24"
        exit 1
    fi

    if [ -z "$STAGE" ]; then
        log_error "Stage is required"
        exit 1
    fi

    if ! [[ "$TIMEOUT_HOURS" =~ ^[0-9]+$ ]]; then
        log_error "Timeout hours must be a number"
        exit 1
    fi
}

# Load approval gates configuration
load_escalation_config() {
    local config_file=".github/releases/approval-gates.yml"

    if [ ! -f "$config_file" ]; then
        log_warn "Approval gates configuration not found"
        # Return default escalation targets
        echo "@engineering-manager @cto"
        return
    fi

    # In production, parse YAML for escalation targets
    # For now, return default
    echo "@engineering-manager @cto"
}

# Check if approval has timed out
check_timeout() {
    local version="$1"
    local stage="$2"
    local timeout_hours="$3"

    log_info "Checking timeout for v$version ($stage stage)..."

    # Find approval tracking issue
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI not found. Cannot check timeout status."
        return 1
    fi

    local issue_title="Release Approval: v$version"
    local issue_data=$(gh issue list --label "release,approval-required" --search "$issue_title" --json number,createdAt --limit 1)

    if [ -z "$issue_data" ] || [ "$issue_data" = "[]" ]; then
        log_warn "No approval issue found"
        return 1
    fi

    local created_at=$(echo "$issue_data" | jq -r '.[0].createdAt')
    local created_timestamp=$(date -d "$created_at" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created_at" +%s 2>/dev/null || echo 0)
    local current_timestamp=$(date +%s)
    local elapsed_hours=$(( (current_timestamp - created_timestamp) / 3600 ))

    log_info "Approval requested $elapsed_hours hours ago (timeout: $timeout_hours hours)"

    if [ "$elapsed_hours" -ge "$timeout_hours" ]; then
        log_escalate "⏰ TIMEOUT: Approval has exceeded $timeout_hours hour threshold"
        return 0
    else
        local remaining_hours=$(( timeout_hours - elapsed_hours ))
        log_info "No timeout. $remaining_hours hours remaining."
        return 1
    fi
}

# Send escalation notification
send_escalation_notification() {
    local version="$1"
    local stage="$2"
    local escalation_targets="$3"
    local timeout_hours="$4"

    log_escalate "Sending escalation notification..."

    # GitHub notification
    if command -v gh &> /dev/null; then
        local issue_title="Release Approval: v$version"
        local issue_number=$(gh issue list --label "release,approval-required" --search "$issue_title" --json number --jq '.[0].number')

        if [ -n "$issue_number" ] && [ "$issue_number" != "null" ]; then
            local escalation_comment="### ⏰ ESCALATION: Approval Timeout

**Stage**: $stage
**Timeout**: $timeout_hours hours exceeded
**Escalated to**: $escalation_targets
**Time**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

---

$escalation_targets - This approval has exceeded the timeout threshold. Please review urgently or delegate to another approver.

**Action Required**: Comment with \`/approve\` or \`/reject <reason>\`"

            gh issue comment "$issue_number" --body "$escalation_comment"
            log_info "Posted escalation comment to GitHub issue #$issue_number"
        fi
    fi

    # Slack notification (if configured)
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
        if [[ ! "$SLACK_WEBHOOK_URL" =~ YOUR_WEBHOOK_HERE|YOUR/WEBHOOK/HERE ]]; then
            bash "$(dirname "$0")/notify-slack.sh" "approval-timeout" "$version" \
                "⏰ *Approval Timeout Escalation*\n\nStage: $stage\nTimeout: $timeout_hours hours\nEscalated to: $escalation_targets\n\nAction required: Review approval issue in GitHub." \
                2>/dev/null || log_warn "Failed to send Slack escalation"
        fi
    fi
}

# Suggest alternative approvers
suggest_alternatives() {
    local stage="$1"

    log_info "Alternative approvers for $stage stage:"
    echo ""

    case "$stage" in
        development)
            echo "  • @senior-dev-2"
            echo "  • @tech-architect"
            echo "  • @engineering-manager"
            ;;
        qa)
            echo "  • @senior-qa-engineer"
            echo "  • @qa-manager"
            ;;
        security)
            echo "  • @security-engineer"
            echo "  • @security-manager"
            echo "  • @ciso"
            ;;
        release)
            echo "  • @engineering-director"
            echo "  • @cto"
            ;;
        *)
            echo "  • @engineering-manager"
            echo "  • @release-manager"
            ;;
    esac

    echo ""
    log_info "To delegate approval:"
    echo "  bash scripts/request-approval.sh $VERSION $stage github"
}

# Display escalation summary
display_summary() {
    local version="$1"
    local stage="$2"
    local escalation_targets="$3"

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "              ESCALATION SUMMARY"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    log_info "Version:    v$version"
    log_info "Stage:      $stage"
    log_info "Escalated:  $escalation_targets"
    log_info "Time:       $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo ""
    log_info "Actions taken:"
    echo "  ✓ Escalation notification sent to GitHub"
    echo "  ✓ Escalation targets notified"
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
        echo "  ✓ Slack alert sent"
    fi
    echo ""
    log_info "Next steps:"
    echo "  1. Wait for escalation response"
    echo "  2. Consider alternative approvers (see suggestions above)"
    echo "  3. Monitor approval status:"
    echo "     bash scripts/check-approval-status.sh $version"
    echo ""
}

# Main execution
main() {
    log_info "Checking approval timeout escalation for v$VERSION ($STAGE)"

    validate_inputs

    # Check if timeout has occurred
    if ! check_timeout "$VERSION" "$STAGE" "$TIMEOUT_HOURS"; then
        log_info "No escalation needed at this time"
        exit 0
    fi

    # Load escalation configuration
    local escalation_targets=$(load_escalation_config)
    log_info "Escalation targets: $escalation_targets"

    # Send escalation notifications
    send_escalation_notification "$VERSION" "$STAGE" "$escalation_targets" "$TIMEOUT_HOURS"

    # Suggest alternatives
    suggest_alternatives "$STAGE"

    # Display summary
    display_summary "$VERSION" "$STAGE" "$escalation_targets"

    log_escalate "Escalation complete"
}

main

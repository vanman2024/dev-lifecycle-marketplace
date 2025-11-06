#!/bin/bash
# Request approval from stakeholders for a specific release
# Usage: bash request-approval.sh <version> <stage> [method]

set -euo pipefail

VERSION="${1:-}"
STAGE="${2:-}"
METHOD="${3:-github}"  # github, slack, or both

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

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Validate inputs
validate_inputs() {
    if [ -z "$VERSION" ]; then
        log_error "Version is required"
        echo "Usage: bash request-approval.sh <version> <stage> [method]"
        echo "Example: bash request-approval.sh 1.2.3 development github"
        exit 1
    fi

    if [ -z "$STAGE" ]; then
        log_error "Stage is required"
        echo "Valid stages: development, qa, security, release"
        exit 1
    fi

    if [[ ! "$METHOD" =~ ^(github|slack|both)$ ]]; then
        log_error "Invalid method: $METHOD"
        echo "Valid methods: github, slack, both"
        exit 1
    fi
}

# Load approval gates configuration
load_approval_config() {
    local config_file=".github/releases/approval-gates.yml"

    if [ ! -f "$config_file" ]; then
        log_error "Approval gates configuration not found: $config_file"
        log_info "Run: bash scripts/setup-approval-gates.sh"
        exit 1
    fi

    log_info "Loading approval configuration from: $config_file"
    # In production, parse YAML with yq or similar
    # For now, just verify existence
}

# Get approvers for stage
get_approvers_for_stage() {
    local stage="$1"

    # This would parse the YAML config in production
    # For now, return example approvers
    case "$stage" in
        development)
            echo "@tech-lead @senior-dev"
            ;;
        qa)
            echo "@qa-lead"
            ;;
        security)
            echo "@security-team-lead"
            ;;
        release)
            echo "@release-manager @product-owner"
            ;;
        *)
            log_error "Unknown stage: $stage"
            exit 1
            ;;
    esac
}

# Request approval via GitHub
request_approval_github() {
    local version="$1"
    local stage="$2"
    local approvers="$3"

    log_info "Requesting GitHub approval for v$version (stage: $stage)"

    # Check if GitHub CLI is available
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) not found. Install from: https://cli.github.com/"
        exit 1
    fi

    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI not authenticated. Run: gh auth login"
        exit 1
    fi

    # Create or update approval tracking issue
    local issue_title="Release Approval: v$version"
    local existing_issue=$(gh issue list --label "release,approval-required" --search "$issue_title" --json number --jq '.[0].number')

    if [ -n "$existing_issue" ] && [ "$existing_issue" != "null" ]; then
        log_info "Found existing approval issue: #$existing_issue"

        # Add comment requesting approval for this stage
        local comment_body="### 🔔 Approval Requested: $stage

**Stage**: $stage
**Approvers**: $approvers
**Requested**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

**Action Required**: Please review and comment with \`/approve\` or \`/reject <reason>\`

---
$approvers - Your approval is needed for the $stage stage."

        gh issue comment "$existing_issue" --body "$comment_body"
        log_info "Posted approval request comment to issue #$existing_issue"
    else
        log_info "Creating new approval tracking issue"

        local issue_body="# Release Approval: v$version

## 📋 Approval Status

### $stage (Current)
- **Status**: ⏳ Pending
- **Approvers**: $approvers
- **Requested**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## 📦 Version Information

**Version**: v$version
**Branch**: $(git branch --show-current 2>/dev/null || echo "unknown")
**Commit**: $(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

## 🚀 Instructions

**For Approvers**: Comment with:
- \`/approve\` - Approve this stage
- \`/approve-with-conditions <conditions>\` - Approve with noted conditions
- \`/reject <reason>\` - Reject with justification

## 📝 Approval Workflow

1. Development Team Review
2. QA Team Validation
3. Security Team Assessment
4. Release Management Sign-off

---

Current Stage: **$stage**

$approvers - Your review is requested."

        local new_issue=$(gh issue create \
            --title "$issue_title" \
            --body "$issue_body" \
            --label "release,approval-required" \
            --json number --jq '.number')

        log_info "Created approval tracking issue: #$new_issue"
    fi
}

# Request approval via Slack
request_approval_slack() {
    local version="$1"
    local stage="$2"
    local approvers="$3"

    log_info "Requesting Slack approval for v$version (stage: $stage)"

    # Check if Slack webhook URL is configured
    if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
        log_warn "SLACK_WEBHOOK_URL not set. Skipping Slack notification."
        log_info "Set webhook URL: export SLACK_WEBHOOK_URL='https://hooks.slack.com/services/YOUR/WEBHOOK/HERE'"
        return
    fi

    # Verify webhook URL is not a placeholder
    if [[ "$SLACK_WEBHOOK_URL" == *"YOUR_WEBHOOK_HERE"* ]] || [[ "$SLACK_WEBHOOK_URL" == *"YOUR/WEBHOOK/HERE"* ]]; then
        log_warn "SLACK_WEBHOOK_URL is a placeholder. Skipping Slack notification."
        log_info "Configure real webhook URL in environment or GitHub Secrets"
        return
    fi

    local slack_message='{
  "text": "🔔 Release Approval Requested",
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "🚀 Release Approval Requested"
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": "*Version:*\nv'"$version"'"
        },
        {
          "type": "mrkdwn",
          "text": "*Stage:*\n'"$stage"'"
        },
        {
          "type": "mrkdwn",
          "text": "*Approvers:*\n'"$approvers"'"
        },
        {
          "type": "mrkdwn",
          "text": "*Requested:*\n'"$(date -u +"%Y-%m-%d %H:%M:%S UTC")"'"
        }
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "Please review and approve in GitHub.\n\n*Required Action:* Comment `/approve` or `/reject <reason>` on the approval issue."
      }
    }
  ]
}'

    # Send to Slack
    local response=$(curl -s -X POST "$SLACK_WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -d "$slack_message")

    if [ "$response" = "ok" ]; then
        log_info "Slack notification sent successfully"
    else
        log_error "Failed to send Slack notification. Response: $response"
    fi
}

# Main execution
main() {
    log_info "Requesting approval for release v$VERSION (stage: $STAGE, method: $METHOD)"

    validate_inputs
    load_approval_config

    local approvers=$(get_approvers_for_stage "$STAGE")
    log_info "Approvers for $STAGE stage: $approvers"

    case "$METHOD" in
        github)
            request_approval_github "$VERSION" "$STAGE" "$approvers"
            ;;
        slack)
            request_approval_slack "$VERSION" "$STAGE" "$approvers"
            ;;
        both)
            request_approval_github "$VERSION" "$STAGE" "$approvers"
            request_approval_slack "$VERSION" "$STAGE" "$approvers"
            ;;
    esac

    log_info ""
    log_info "✅ Approval request sent successfully!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Approvers will receive notifications"
    log_info "2. Monitor approval status: bash scripts/check-approval-status.sh $VERSION"
    log_info "3. View approval issue: gh issue list --label release"
}

main

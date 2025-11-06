#!/bin/bash
# Send Slack notification for approval events
# Usage: bash notify-slack.sh <event-type> <version> <message> [details-json]

set -euo pipefail

EVENT_TYPE="${1:-}"
VERSION="${2:-}"
MESSAGE="${3:-}"
DETAILS_JSON="${4:-}"

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
    if [ -z "$EVENT_TYPE" ]; then
        log_error "Event type is required"
        echo "Usage: bash notify-slack.sh <event-type> <version> <message> [details-json]"
        echo "Event types: approval-requested, approval-granted, approval-denied, approval-timeout, approval-complete"
        exit 1
    fi

    if [ -z "$VERSION" ]; then
        log_error "Version is required"
        exit 1
    fi

    if [ -z "$MESSAGE" ]; then
        log_error "Message is required"
        exit 1
    fi

    # Validate event type
    if [[ ! "$EVENT_TYPE" =~ ^(approval-requested|approval-granted|approval-denied|approval-timeout|approval-complete)$ ]]; then
        log_error "Invalid event type: $EVENT_TYPE"
        echo "Valid types: approval-requested, approval-granted, approval-denied, approval-timeout, approval-complete"
        exit 1
    fi
}

# Check Slack webhook configuration
check_slack_config() {
    if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
        log_error "SLACK_WEBHOOK_URL environment variable not set"
        log_info "Set webhook URL: export SLACK_WEBHOOK_URL='https://hooks.slack.com/services/YOUR/WEBHOOK/HERE'"
        exit 1
    fi

    # Verify webhook URL is not a placeholder
    if [[ "$SLACK_WEBHOOK_URL" == *"YOUR_WEBHOOK_HERE"* ]] || [[ "$SLACK_WEBHOOK_URL" == *"YOUR/WEBHOOK/HERE"* ]]; then
        log_error "SLACK_WEBHOOK_URL is a placeholder value"
        log_info "Configure real webhook URL in environment or GitHub Secrets"
        exit 1
    fi

    # Validate webhook URL format
    if [[ ! "$SLACK_WEBHOOK_URL" =~ ^https://hooks\.slack\.com/services/.+ ]]; then
        log_warn "SLACK_WEBHOOK_URL does not match expected Slack webhook format"
    fi
}

# Get emoji for event type
get_event_emoji() {
    case "$1" in
        approval-requested) echo "🔔" ;;
        approval-granted) echo "✅" ;;
        approval-denied) echo "❌" ;;
        approval-timeout) echo "⏰" ;;
        approval-complete) echo "🎉" ;;
        *) echo "📢" ;;
    esac
}

# Get color for event type
get_event_color() {
    case "$1" in
        approval-requested) echo "#36a64f" ;;  # Green
        approval-granted) echo "#2eb886" ;;    # Bright green
        approval-denied) echo "#dc3545" ;;     # Red
        approval-timeout) echo "#ffc107" ;;    # Yellow
        approval-complete) echo "#17a2b8" ;;   # Blue
        *) echo "#6c757d" ;;                   # Gray
    esac
}

# Format event title
get_event_title() {
    local emoji=$(get_event_emoji "$1")
    case "$1" in
        approval-requested) echo "$emoji Release Approval Requested" ;;
        approval-granted) echo "$emoji Approval Granted" ;;
        approval-denied) echo "$emoji Approval Denied" ;;
        approval-timeout) echo "$emoji Approval Timeout" ;;
        approval-complete) echo "$emoji All Approvals Complete" ;;
        *) echo "$emoji Release Approval Notification" ;;
    esac
}

# Build Slack message payload
build_slack_payload() {
    local event_type="$1"
    local version="$2"
    local message="$3"
    local details_json="$4"

    local title=$(get_event_title "$event_type")
    local color=$(get_event_color "$event_type")
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

    # Start building JSON payload
    local payload='{
  "text": "'"$title"'",
  "attachments": [
    {
      "color": "'"$color"'",
      "blocks": [
        {
          "type": "header",
          "text": {
            "type": "plain_text",
            "text": "'"$title"'"
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
              "text": "*Time:*\n'"$timestamp"'"
            }
          ]
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "'"$message"'"
          }
        }'

    # Add details section if provided
    if [ -n "$details_json" ] && [ "$details_json" != "null" ]; then
        # Parse details and add to payload
        # In production, use jq to properly format JSON
        if command -v jq &> /dev/null; then
            local details_formatted=$(echo "$details_json" | jq -r 'to_entries | map("*\(.key):* \(.value)") | join("\n")')
            payload+='
        ,{
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "'"$details_formatted"'"
          }
        }'
        fi
    fi

    # Add action buttons based on event type
    if [ "$event_type" = "approval-requested" ]; then
        payload+='
        ,{
          "type": "actions",
          "elements": [
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "text": "View in GitHub"
              },
              "url": "https://github.com/'"${GITHUB_REPOSITORY:-owner/repo}"'/issues?q=is%3Aopen+label%3Arelease",
              "style": "primary"
            }
          ]
        }'
    fi

    # Close JSON structure
    payload+='
      ]
    }
  ]
}'

    echo "$payload"
}

# Send to Slack
send_to_slack() {
    local payload="$1"

    log_info "Sending notification to Slack..."

    # Send POST request
    local response=$(curl -s -w "\n%{http_code}" -X POST "$SLACK_WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -d "$payload")

    # Parse response
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n-1)

    if [ "$http_code" = "200" ] && [ "$body" = "ok" ]; then
        log_info "✅ Slack notification sent successfully"
        return 0
    else
        log_error "Failed to send Slack notification"
        log_error "HTTP Code: $http_code"
        log_error "Response: $body"
        return 1
    fi
}

# Main execution
main() {
    log_info "Preparing Slack notification..."
    log_info "Event: $EVENT_TYPE"
    log_info "Version: v$VERSION"

    validate_inputs
    check_slack_config

    local payload=$(build_slack_payload "$EVENT_TYPE" "$VERSION" "$MESSAGE" "$DETAILS_JSON")

    if send_to_slack "$payload"; then
        log_info "Notification sent successfully"
        exit 0
    else
        log_error "Failed to send notification"
        exit 1
    fi
}

main

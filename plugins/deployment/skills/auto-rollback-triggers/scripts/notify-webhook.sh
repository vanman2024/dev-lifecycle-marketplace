#!/usr/bin/env bash
set -euo pipefail

# notify-webhook.sh
# Webhook notification delivery with retry logic and templating
#
# Usage: notify-webhook.sh <webhook_url> <message> [--slack|--discord] [--retry=N]
#
# Arguments:
#   webhook_url  - Webhook URL (e.g., Slack, Discord, custom)
#   message      - Notification message
#   --slack      - Format for Slack webhook (default)
#   --discord    - Format for Discord webhook
#   --retry=N    - Number of retries (default: 3)
#
# Exit Codes:
#   0 - Notification sent successfully
#   2 - Invalid arguments
#   5 - Webhook notification failed after retries

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_dependencies() {
    local missing_deps=()
    for cmd in curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit 2
    fi
}

validate_arguments() {
    if [ $# -lt 2 ]; then
        log_error "Usage: $0 <webhook_url> <message> [--slack|--discord] [--retry=N]"
        log_error "Example: $0 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL' 'Deployment failed' --slack"
        exit 2
    fi
}

format_slack_message() {
    local message="$1"
    local title="${2:-Deployment Notification}"
    local color="${3:-#ff0000}"  # Default red for alerts

    cat <<EOF
{
  "attachments": [
    {
      "color": "$color",
      "title": "$title",
      "text": "$message",
      "footer": "Auto-Rollback System",
      "ts": $(date +%s)
    }
  ]
}
EOF
}

format_slack_detailed() {
    local title="$1"
    local message="$2"
    local error_rate="${3:-N/A}"
    local threshold="${4:-N/A}"
    local deployment_id="${5:-N/A}"

    cat <<EOF
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "$title"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "$message"
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": "*Error Rate:*\n$error_rate%"
        },
        {
          "type": "mrkdwn",
          "text": "*Threshold:*\n$threshold%"
        },
        {
          "type": "mrkdwn",
          "text": "*Deployment:*\n$deployment_id"
        },
        {
          "type": "mrkdwn",
          "text": "*Time:*\n$(date -u +'%Y-%m-%d %H:%M:%S UTC')"
        }
      ]
    }
  ]
}
EOF
}

format_discord_message() {
    local message="$1"
    local title="${2:-Deployment Notification}"
    local color="${3:-16711680}"  # Default red (decimal)

    cat <<EOF
{
  "embeds": [
    {
      "title": "$title",
      "description": "$message",
      "color": $color,
      "footer": {
        "text": "Auto-Rollback System"
      },
      "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%S.000Z')"
    }
  ]
}
EOF
}

send_webhook() {
    local url="$1"
    local payload="$2"
    local max_retries="${3:-3}"
    local timeout=10

    local attempt=1

    while [ $attempt -le $max_retries ]; do
        log_info "Sending webhook notification (attempt $attempt/$max_retries)..."

        local http_code
        http_code=$(curl -sf -w "%{http_code}" -o /dev/null \
            --max-time "$timeout" \
            -X POST \
            -H "Content-Type: application/json" \
            -d "$payload" \
            "$url" 2>&1) || {
            log_warn "Webhook request failed (attempt $attempt)"

            if [ $attempt -lt $max_retries ]; then
                local backoff=$((attempt * 2))
                log_info "Retrying in ${backoff}s..."
                sleep $backoff
                attempt=$((attempt + 1))
                continue
            else
                log_error "All webhook delivery attempts failed"
                return 5
            fi
        }

        # Check HTTP status code
        if [[ "$http_code" =~ ^2 ]]; then
            log_info "✓ Webhook notification sent successfully (HTTP $http_code)"
            return 0
        else
            log_warn "Webhook returned non-2xx status: $http_code"

            if [ $attempt -lt $max_retries ]; then
                local backoff=$((attempt * 2))
                log_info "Retrying in ${backoff}s..."
                sleep $backoff
                attempt=$((attempt + 1))
                continue
            else
                log_error "Webhook delivery failed after $max_retries attempts"
                return 5
            fi
        fi
    done

    return 5
}

main() {
    check_dependencies
    validate_arguments "$@"

    local webhook_url="$1"
    local message="$2"
    local webhook_type="slack"
    local max_retries=3

    # Parse optional flags
    shift 2
    while [ $# -gt 0 ]; do
        case "$1" in
            --slack)
                webhook_type="slack"
                shift
                ;;
            --discord)
                webhook_type="discord"
                shift
                ;;
            --retry=*)
                max_retries="${1#*=}"
                shift
                ;;
            *)
                log_warn "Unknown option: $1"
                shift
                ;;
        esac
    done

    log_info "=== Webhook Notification ==="
    log_info "Type: $webhook_type"
    log_info "Message: $message"
    log_info "Max Retries: $max_retries"

    # Check if URL is a placeholder
    if [[ "$webhook_url" =~ your_webhook_url_here ]] || [[ "$webhook_url" =~ example\.com ]]; then
        log_error "Webhook URL appears to be a placeholder"
        log_error "Please replace with actual webhook URL"
        log_error "Current URL: $webhook_url"
        exit 2
    fi

    # Format payload based on webhook type
    local payload
    case "$webhook_type" in
        slack)
            payload=$(format_slack_message "$message" "Auto-Rollback Alert" "#ff0000")
            ;;
        discord)
            payload=$(format_discord_message "$message" "Auto-Rollback Alert" "16711680")
            ;;
        *)
            log_error "Unsupported webhook type: $webhook_type"
            exit 2
            ;;
    esac

    # Send webhook
    send_webhook "$webhook_url" "$payload" "$max_retries"
    exit $?
}

main "$@"

# Slack Webhook Integration

Complete guide to integrating Slack notifications with auto-rollback triggers.

## Overview

Send real-time notifications to Slack for:
- Error rate threshold exceeded
- SLO violations detected
- Rollback triggered
- Rollback completed or failed

## Setup Steps

### 1. Create Slack Webhook

1. Go to https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. Name your app (e.g., "Deployment Monitor")
4. Select your workspace
5. Click "Incoming Webhooks" → Enable
6. Click "Add New Webhook to Workspace"
7. Select channel (e.g., #deployments)
8. Copy the webhook URL

**Webhook URL Format:**
```
https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX
```

### 2. Store Webhook URL Securely

**For GitHub Actions:**

```bash
gh secret set SLACK_WEBHOOK_URL -b "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

**For Local/CI Use:**

```bash
# Add to .env file (DO NOT COMMIT)
echo "SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL" >> .env

# Add to gitignore
echo ".env" >> .gitignore
```

**For GitLab CI:**

```bash
# Set as GitLab CI/CD variable
# Settings → CI/CD → Variables → Add Variable
# Key: SLACK_WEBHOOK_URL
# Value: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
# Protected: Yes
# Masked: Yes
```

### 3. Send Test Notification

```bash
bash scripts/notify-webhook.sh \
  "$SLACK_WEBHOOK_URL" \
  "Test notification from auto-rollback system" \
  --slack
```

Expected output in Slack:
> Auto-Rollback Alert
> Test notification from auto-rollback system
> Auto-Rollback System • timestamp

## Notification Patterns

### Error Rate Alert

```bash
ERROR_RATE="6.5"
THRESHOLD="5.0"

bash scripts/notify-webhook.sh \
  "$SLACK_WEBHOOK_URL" \
  "Error rate ${ERROR_RATE}% exceeded threshold ${THRESHOLD}%" \
  --slack
```

### SLO Violation

```bash
bash scripts/notify-webhook.sh \
  "$SLACK_WEBHOOK_URL" \
  "SLO violation: Availability 98.5% below target 99.9%" \
  --slack
```

### Rollback Triggered

```bash
DEPLOYMENT_ID="dpl_abc123xyz"

bash scripts/notify-webhook.sh \
  "$SLACK_WEBHOOK_URL" \
  "Auto-rollback triggered for deployment $DEPLOYMENT_ID" \
  --slack
```

### Rollback Complete

```bash
bash scripts/notify-webhook.sh \
  "$SLACK_WEBHOOK_URL" \
  "Rollback completed successfully - service restored" \
  --slack
```

### Critical Alert

```bash
bash scripts/notify-webhook.sh \
  "$SLACK_WEBHOOK_URL" \
  "CRITICAL: Rollback failed - Manual intervention required" \
  --slack
```

## Advanced Slack Integration

### Rich Formatted Messages

Create custom notification script:

```bash
#!/bin/bash
# notify-slack-advanced.sh

WEBHOOK_URL="$1"
DEPLOYMENT_ID="$2"
ERROR_RATE="$3"
THRESHOLD="$4"
DEPLOYMENT_URL="$5"

curl -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d @- << EOF
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "🚨 Auto-Rollback Triggered"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Deployment failed error rate check and was automatically rolled back.*"
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": "*Error Rate:*\n${ERROR_RATE}%"
        },
        {
          "type": "mrkdwn",
          "text": "*Threshold:*\n${THRESHOLD}%"
        },
        {
          "type": "mrkdwn",
          "text": "*Deployment:*\n\`${DEPLOYMENT_ID}\`"
        },
        {
          "type": "mrkdwn",
          "text": "*Time:*\n$(date -u +'%Y-%m-%d %H:%M:%S UTC')"
        }
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "<${DEPLOYMENT_URL}|View Deployment>"
      }
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": "Auto-Rollback System"
        }
      ]
    }
  ]
}
EOF
```

Usage:

```bash
bash notify-slack-advanced.sh \
  "$SLACK_WEBHOOK_URL" \
  "dpl_abc123xyz" \
  "6.5" \
  "5.0" \
  "https://vercel.com/dashboard/deployments/abc123"
```

### Slack Threads for Related Events

Track deployment lifecycle in thread:

```bash
#!/bin/bash
# notify-slack-thread.sh

WEBHOOK_URL="$1"
MESSAGE="$2"
THREAD_TS="$3"  # Optional: Thread timestamp to reply to

PAYLOAD=$(cat <<EOF
{
  "text": "$MESSAGE",
  "thread_ts": "$THREAD_TS"
}
EOF
)

if [ -z "$THREAD_TS" ]; then
  # Remove thread_ts if not provided
  PAYLOAD=$(echo "$PAYLOAD" | jq 'del(.thread_ts)')
fi

RESPONSE=$(curl -sf -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d "$PAYLOAD")

# Extract thread_ts from response for subsequent replies
echo "$RESPONSE" | jq -r '.ts'
```

Usage:

```bash
# Initial deployment notification
THREAD_TS=$(bash notify-slack-thread.sh \
  "$SLACK_WEBHOOK_URL" \
  "Deployment started: dpl_abc123xyz")

# Reply in thread with monitoring results
bash notify-slack-thread.sh \
  "$SLACK_WEBHOOK_URL" \
  "Monitoring: Error rate 2.5% - within threshold" \
  "$THREAD_TS"

# Reply with rollback if needed
bash notify-slack-thread.sh \
  "$SLACK_WEBHOOK_URL" \
  "Error rate spiked to 6.5% - triggering rollback" \
  "$THREAD_TS"
```

### Color-Coded Alerts

```bash
#!/bin/bash
# notify-slack-colored.sh

WEBHOOK_URL="$1"
MESSAGE="$2"
SEVERITY="${3:-info}"  # info, warning, error, critical

# Map severity to colors
case "$SEVERITY" in
  info)
    COLOR="#36a64f"  # Green
    EMOJI=":white_check_mark:"
    ;;
  warning)
    COLOR="#ff9900"  # Orange
    EMOJI=":warning:"
    ;;
  error)
    COLOR="#ff0000"  # Red
    EMOJI=":x:"
    ;;
  critical)
    COLOR="#990000"  # Dark red
    EMOJI=":rotating_light:"
    ;;
  *)
    COLOR="#808080"  # Gray
    EMOJI=":information_source:"
    ;;
esac

curl -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d @- << EOF
{
  "attachments": [
    {
      "color": "$COLOR",
      "text": "$EMOJI $MESSAGE",
      "footer": "Auto-Rollback System",
      "ts": $(date +%s)
    }
  ]
}
EOF
```

Usage:

```bash
# Info notification
bash notify-slack-colored.sh \
  "$SLACK_WEBHOOK_URL" \
  "Deployment monitoring passed" \
  "info"

# Warning notification
bash notify-slack-colored.sh \
  "$SLACK_WEBHOOK_URL" \
  "Error rate approaching threshold" \
  "warning"

# Error notification
bash notify-slack-colored.sh \
  "$SLACK_WEBHOOK_URL" \
  "Error rate exceeded - rolling back" \
  "error"

# Critical notification
bash notify-slack-colored.sh \
  "$SLACK_WEBHOOK_URL" \
  "Rollback failed - manual intervention required" \
  "critical"
```

## GitHub Actions Integration

### Workflow with Slack Notifications

```yaml
name: Deploy with Slack Notifications

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Notify deployment started
        run: |
          bash scripts/notify-webhook.sh \
            "${{ secrets.SLACK_WEBHOOK_URL }}" \
            "Deployment started for commit ${{ github.sha }}" \
            --slack

      - name: Deploy application
        run: |
          # Your deployment commands here
          echo "Deploying..."

      - name: Monitor deployment
        id: monitor
        run: |
          bash scripts/monitor-error-rate.sh \
            https://api.example.com/metrics \
            5.0 \
            300

      - name: Notify success
        if: steps.monitor.outcome == 'success'
        run: |
          bash scripts/notify-webhook.sh \
            "${{ secrets.SLACK_WEBHOOK_URL }}" \
            "✓ Deployment successful - monitoring passed" \
            --slack

      - name: Notify failure
        if: steps.monitor.outcome == 'failure'
        run: |
          bash scripts/notify-webhook.sh \
            "${{ secrets.SLACK_WEBHOOK_URL }}" \
            "✗ Deployment failed monitoring - rollback triggered" \
            --slack
```

## Testing

### Test Webhook Delivery

```bash
# Test basic notification
bash scripts/notify-webhook.sh \
  "$SLACK_WEBHOOK_URL" \
  "Test message" \
  --slack

# Verify delivery in Slack channel
```

### Test Retry Logic

```bash
# Test with invalid webhook (should retry 3 times)
bash scripts/notify-webhook.sh \
  "https://hooks.slack.com/services/INVALID/URL" \
  "Test retry" \
  --slack \
  --retry=3
```

Expected:
- Attempt 1: Failed, retrying in 2s
- Attempt 2: Failed, retrying in 4s
- Attempt 3: Failed
- Exit code: 5

## Troubleshooting

### Webhook Not Delivering

**Problem**: Notifications not appearing in Slack

**Solutions**:
1. Verify webhook URL is correct
2. Check webhook URL is not a placeholder
3. Verify Slack app has permission to post
4. Check channel still exists
5. Test webhook with curl:

```bash
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d '{"text":"Test from curl"}'
```

### Rate Limiting

**Problem**: Some notifications not delivered

**Solutions**:
- Slack allows 1 message per second per webhook
- Implement notification batching
- Add delays between notifications
- Use Slack API (not webhooks) for higher limits

### Message Formatting Issues

**Problem**: Messages appear malformed

**Solutions**:
- Escape special characters in JSON
- Use proper JSON formatting
- Test with Slack Block Kit Builder: https://app.slack.com/block-kit-builder

## Best Practices

1. **Use Meaningful Messages**: Include context (deployment ID, error rate, threshold)
2. **Color Code by Severity**: Help team identify critical issues quickly
3. **Link to Resources**: Include links to dashboards, logs, deployments
4. **Avoid Spam**: Batch related notifications, use threads
5. **Test Regularly**: Verify webhooks work before relying on them
6. **Have Fallbacks**: Configure email fallback if webhook fails
7. **Secure Webhook URLs**: Never commit webhook URLs to git

## Next Steps

- Set up Discord webhooks (see `discord-webhook-integration.md`)
- Implement PagerDuty integration for critical alerts
- Add metrics dashboards with links in notifications
- Set up notification routing based on severity

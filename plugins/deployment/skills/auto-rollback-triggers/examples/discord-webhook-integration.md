# Discord Webhook Integration

Complete guide to integrating Discord notifications with auto-rollback triggers.

## Overview

Send deployment notifications to Discord for:
- Error rate monitoring alerts
- SLO violations
- Rollback triggers and completion
- Team coordination during incidents

## Setup Steps

### 1. Create Discord Webhook

1. Open Discord server
2. Right-click channel → "Edit Channel"
3. Go to "Integrations" → "Webhooks"
4. Click "New Webhook" or "Create Webhook"
5. Name your webhook (e.g., "Deployment Monitor")
6. Optionally set an avatar
7. Copy the webhook URL

**Webhook URL Format:**
```
https://discord.com/api/webhooks/1234567890/ABCDEFGHIJKLMNOPQRSTUVWXYZ
```

### 2. Store Webhook URL Securely

**For GitHub Actions:**

```bash
gh secret set DISCORD_WEBHOOK_URL -b "https://discord.com/api/webhooks/YOUR/WEBHOOK/URL"
```

**For Local/CI Use:**

```bash
# Add to .env file (DO NOT COMMIT)
echo "DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR/WEBHOOK/URL" >> .env

# Add to gitignore
echo ".env" >> .gitignore
```

### 3. Send Test Notification

```bash
bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "Test notification from auto-rollback system" \
  --discord
```

Expected output in Discord:
> **Auto-Rollback Alert**
> Test notification from auto-rollback system
> *Auto-Rollback System* • timestamp

## Notification Patterns

### Error Rate Alert

```bash
ERROR_RATE="6.5"
THRESHOLD="5.0"

bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "⚠️ Error rate ${ERROR_RATE}% exceeded threshold ${THRESHOLD}%" \
  --discord
```

### SLO Violation

```bash
bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "📉 SLO violation: Availability 98.5% below target 99.9%" \
  --discord
```

### Rollback Triggered

```bash
DEPLOYMENT_ID="dpl_abc123xyz"

bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "🔄 Auto-rollback triggered for deployment $DEPLOYMENT_ID" \
  --discord
```

### Rollback Complete

```bash
bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "✅ Rollback completed successfully - service restored" \
  --discord
```

### Critical Alert

```bash
bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "🚨 CRITICAL: Rollback failed - Manual intervention required @here" \
  --discord
```

## Advanced Discord Integration

### Rich Embed Messages

Create custom Discord notification script:

```bash
#!/bin/bash
# notify-discord-advanced.sh

WEBHOOK_URL="$1"
DEPLOYMENT_ID="$2"
ERROR_RATE="$3"
THRESHOLD="$4"
DEPLOYMENT_URL="$5"

# Discord color (decimal): Red = 16711680, Green = 65280, Orange = 16744192
COLOR=16711680  # Red

curl -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d @- << EOF
{
  "embeds": [
    {
      "title": "🚨 Auto-Rollback Triggered",
      "description": "Deployment failed error rate check and was automatically rolled back.",
      "color": $COLOR,
      "fields": [
        {
          "name": "Error Rate",
          "value": "${ERROR_RATE}%",
          "inline": true
        },
        {
          "name": "Threshold",
          "value": "${THRESHOLD}%",
          "inline": true
        },
        {
          "name": "Deployment ID",
          "value": "\`${DEPLOYMENT_ID}\`",
          "inline": false
        },
        {
          "name": "Deployment URL",
          "value": "[View Deployment](${DEPLOYMENT_URL})",
          "inline": false
        }
      ],
      "footer": {
        "text": "Auto-Rollback System"
      },
      "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
    }
  ]
}
EOF
```

Usage:

```bash
bash notify-discord-advanced.sh \
  "$DISCORD_WEBHOOK_URL" \
  "dpl_abc123xyz" \
  "6.5" \
  "5.0" \
  "https://vercel.com/dashboard/deployments/abc123"
```

### Color-Coded Embeds

```bash
#!/bin/bash
# notify-discord-colored.sh

WEBHOOK_URL="$1"
TITLE="$2"
MESSAGE="$3"
SEVERITY="${4:-info}"  # info, warning, error, critical

# Map severity to Discord colors (decimal)
case "$SEVERITY" in
  info)
    COLOR=65280      # Green
    EMOJI="✅"
    ;;
  warning)
    COLOR=16744192   # Orange
    EMOJI="⚠️"
    ;;
  error)
    COLOR=16711680   # Red
    EMOJI="❌"
    ;;
  critical)
    COLOR=10038562   # Dark red
    EMOJI="🚨"
    ;;
  *)
    COLOR=8421504    # Gray
    EMOJI="ℹ️"
    ;;
esac

curl -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d @- << EOF
{
  "embeds": [
    {
      "title": "$EMOJI $TITLE",
      "description": "$MESSAGE",
      "color": $COLOR,
      "footer": {
        "text": "Auto-Rollback System"
      },
      "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
    }
  ]
}
EOF
```

Usage:

```bash
# Info notification
bash notify-discord-colored.sh \
  "$DISCORD_WEBHOOK_URL" \
  "Deployment Success" \
  "Deployment monitoring passed" \
  "info"

# Warning notification
bash notify-discord-colored.sh \
  "$DISCORD_WEBHOOK_URL" \
  "Elevated Error Rate" \
  "Error rate approaching threshold" \
  "warning"

# Error notification
bash notify-discord-colored.sh \
  "$DISCORD_WEBHOOK_URL" \
  "Rollback Triggered" \
  "Error rate exceeded - rolling back" \
  "error"

# Critical notification
bash notify-discord-colored.sh \
  "$DISCORD_WEBHOOK_URL" \
  "Manual Intervention Required" \
  "Rollback failed - @here" \
  "critical"
```

### Discord Mentions

```bash
# Mention @everyone (use sparingly)
bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "@everyone Critical deployment failure - immediate action required" \
  --discord

# Mention @here (online users only)
bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "@here Rollback triggered - monitoring required" \
  --discord

# Mention specific role
bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "<@&ROLE_ID> Deployment needs review" \
  --discord

# Mention specific user
bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "<@USER_ID> Your deployment was rolled back" \
  --discord
```

### Multi-Field Status Updates

```bash
#!/bin/bash
# notify-discord-status.sh

WEBHOOK_URL="$1"

curl -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d @- << EOF
{
  "embeds": [
    {
      "title": "Deployment Status Report",
      "color": 65280,
      "fields": [
        {
          "name": "📊 Error Rate",
          "value": "2.5% (Threshold: 5.0%)",
          "inline": true
        },
        {
          "name": "⏱️ Latency P95",
          "value": "350ms (Target: <500ms)",
          "inline": true
        },
        {
          "name": "✅ Availability",
          "value": "99.95% (Target: 99.9%)",
          "inline": true
        },
        {
          "name": "🎯 SLO Status",
          "value": "All SLOs met ✅",
          "inline": false
        },
        {
          "name": "🚀 Deployment",
          "value": "\`dpl_abc123xyz\`",
          "inline": true
        },
        {
          "name": "⏰ Duration",
          "value": "5 minutes",
          "inline": true
        }
      ],
      "footer": {
        "text": "Auto-Rollback System"
      },
      "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
    }
  ]
}
EOF
```

## GitHub Actions Integration

### Workflow with Discord Notifications

```yaml
name: Deploy with Discord Notifications

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Notify deployment started
        run: |
          bash scripts/notify-webhook.sh \
            "${{ secrets.DISCORD_WEBHOOK_URL }}" \
            "🚀 Deployment started for commit ${{ github.sha }}" \
            --discord

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
            "${{ secrets.DISCORD_WEBHOOK_URL }}" \
            "✅ Deployment successful - monitoring passed" \
            --discord

      - name: Notify failure
        if: steps.monitor.outcome == 'failure'
        run: |
          bash scripts/notify-webhook.sh \
            "${{ secrets.DISCORD_WEBHOOK_URL }}" \
            "❌ Deployment failed monitoring - rollback triggered @here" \
            --discord
```

## Discord vs Slack Comparison

| Feature | Discord | Slack |
|---------|---------|-------|
| Setup Complexity | Easier | Moderate |
| Rich Formatting | Embeds | Blocks |
| Color Support | Yes | Yes |
| Mentions | @everyone, @here, roles | @channel, @here |
| Rate Limits | 30 req/min | 1 req/sec |
| Threading | Limited | Excellent |
| Best For | Gaming/Community | Enterprise |

## Testing

### Test Webhook Delivery

```bash
# Test basic notification
bash scripts/notify-webhook.sh \
  "$DISCORD_WEBHOOK_URL" \
  "Test message" \
  --discord

# Verify delivery in Discord channel
```

### Test Rich Embeds

```bash
curl -X POST "$DISCORD_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d '{
    "embeds": [{
      "title": "Test Embed",
      "description": "Testing rich embeds",
      "color": 65280
    }]
  }'
```

## Troubleshooting

### Webhook Not Delivering

**Problem**: Notifications not appearing in Discord

**Solutions**:
1. Verify webhook URL is correct
2. Check webhook wasn't deleted
3. Ensure channel still exists
4. Test with curl:

```bash
curl -X POST "$DISCORD_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d '{"content":"Test from curl"}'
```

### Rate Limiting

**Problem**: Some notifications not delivered

**Solutions**:
- Discord allows 30 requests per minute per webhook
- Batch related notifications
- Add delays between notifications (2-3 seconds)
- Use separate webhooks for different notification types

### Mention Not Working

**Problem**: @here or @everyone not notifying

**Solutions**:
- Check webhook permissions in Discord
- Ensure "Mention Everyone" permission enabled
- Use proper mention syntax: `@everyone`, `@here`
- For roles: Get role ID and use `<@&ROLE_ID>`

## Best Practices

1. **Use Embeds for Important Alerts**: Rich formatting helps visibility
2. **Color Code by Severity**: Green (info), Orange (warning), Red (error)
3. **Include Context**: Deployment ID, metrics, timestamps
4. **Strategic Mentions**: Use @here for urgent, avoid @everyone spam
5. **Test Regularly**: Verify webhook works before relying on it
6. **Monitor Rate Limits**: Don't exceed 30 requests/minute
7. **Secure Webhook URLs**: Never commit to git, use secrets

## Next Steps

- Combine Slack and Discord notifications
- Add PagerDuty for critical alerts
- Implement notification routing by severity
- Set up metrics dashboard links in embeds

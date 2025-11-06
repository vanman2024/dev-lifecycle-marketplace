# Complete Slack Integration Example

End-to-end Slack notification setup for release approvals.

## Setup

### 1. Create Slack App and Webhook

```bash
# Run interactive setup script
bash plugins/versioning/skills/release-approval/scripts/setup-slack-webhook.sh
```

**Script will guide you through:**
1. Creating Slack app at https://api.slack.com/apps
2. Enabling Incoming Webhooks
3. Selecting notification channel
4. Copying webhook URL
5. Testing webhook connection
6. Saving to environment variables
7. Configuring GitHub Secrets

**Output:**
```
═══════════════════════════════════════════════════════
       Slack Webhook Setup for Release Approvals
═══════════════════════════════════════════════════════

[STEP] Step 1: Create Slack Incoming Webhook
  1. Go to: https://api.slack.com/apps
  ...

[STEP] Step 2: Enter Slack Webhook URL
Paste your Slack webhook URL: https://hooks.slack.com/services/T012.../B034.../xyz123...

[INFO] Testing webhook connection...
[INFO] ✅ Webhook test successful! Check your Slack channel.

[STEP] Step 3: Save webhook configuration
[INFO] Updated SLACK_WEBHOOK_URL in .env
[INFO] Updated .env.example with placeholder
[INFO] Added .env to .gitignore

[STEP] Step 4: Save to GitHub Secrets
[INFO] Saving SLACK_WEBHOOK_URL to GitHub Secrets...
[INFO] ✅ Secret saved successfully

Setup Complete!
```

### 2. Configure Notification Channels

Edit `.env`:
```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T012.../B034.../xyz123...
SLACK_CHANNEL_RELEASES=#releases
SLACK_CHANNEL_URGENT=#urgent-releases
SLACK_MENTION_CHANNEL=true
```

## Notification Types

### 1. Approval Requested

**Trigger**: Approval workflow starts

```bash
bash plugins/versioning/skills/release-approval/scripts/notify-slack.sh \
  approval-requested \
  1.2.3 \
  "Release approval requested for v1.2.3. All stakeholders please review."
```

**Slack Message:**
```
🔔 Release Approval Requested

Version: v1.2.3
Time: 2025-01-15 10:00:00 UTC

Release approval requested for v1.2.3. All stakeholders please review.

[View in GitHub]
```

### 2. Approval Granted

**Trigger**: Stakeholder approves

```bash
bash plugins/versioning/skills/release-approval/scripts/notify-slack.sh \
  approval-granted \
  1.2.3 \
  "Development team approved by @tech-lead. QA review next."
```

**Slack Message:**
```
✅ Approval Granted

Version: v1.2.3
Time: 2025-01-15 11:00:00 UTC

Development team approved by @tech-lead. QA review next.
```

### 3. Approval Denied

**Trigger**: Stakeholder rejects

```bash
bash plugins/versioning/skills/release-approval/scripts/notify-slack.sh \
  approval-denied \
  1.2.3 \
  "Security team rejected: Critical vulnerability CVE-2024-1234 found."
```

**Slack Message:**
```
❌ Approval Denied

Version: v1.2.3
Time: 2025-01-15 14:00:00 UTC

Security team rejected: Critical vulnerability CVE-2024-1234 found.

@release-manager
```

### 4. Approval Timeout

**Trigger**: Approval exceeds timeout threshold

```bash
bash plugins/versioning/skills/release-approval/scripts/escalate-approval.sh \
  1.2.3 \
  security \
  24
```

**Slack Message:**
```
⏰ Approval Timeout

Version: v1.2.3
Time: 2025-01-16 10:00:00 UTC

⏰ APPROVAL TIMEOUT

Stage: security
Timeout: 24 hours exceeded
Escalated to: @engineering-manager @cto

@engineering-manager @cto - This approval has exceeded the timeout threshold. Please review urgently.
```

### 5. Approval Complete

**Trigger**: All approvals obtained

```bash
bash plugins/versioning/skills/release-approval/scripts/notify-slack.sh \
  approval-complete \
  1.2.3 \
  "🎉 All approvals complete for v1.2.3! Ready for release."
```

**Slack Message:**
```
🎉 All Approvals Complete

Version: v1.2.3
Time: 2025-01-15 15:00:00 UTC

🎉 All approvals complete for v1.2.3! Ready for release.

@channel
```

## GitHub Actions Integration

### Workflow with Slack Notifications

Use `templates/github-actions-approval-slack.yml`:

```yaml
name: Release Approval with Slack

on:
  workflow_dispatch:
    inputs:
      version:
        required: true

jobs:
  initialize:
    runs-on: ubuntu-latest
    steps:
      - name: Notify Slack - Workflow Started
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        run: |
          bash scripts/notify-slack.sh approval-requested ${{ inputs.version }} \
            "Release approval workflow started for v${{ inputs.version }}"

  request-development-approval:
    runs-on: ubuntu-latest
    steps:
      - name: Request and notify
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        run: |
          bash scripts/request-approval.sh ${{ inputs.version }} development both

  finalize:
    runs-on: ubuntu-latest
    steps:
      - name: Notify completion
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        run: |
          bash scripts/notify-slack.sh approval-complete ${{ inputs.version }} \
            "🎉 All approvals complete! Ready for deployment."
```

## Full Workflow Example

### Real-Time Slack Timeline

```
10:00 🔔 Release Approval Requested
      Version: v1.2.3
      Approvers: @tech-lead @senior-dev @qa-lead @security-team @release-manager
      [View in GitHub]

11:00 ✅ Approval Granted
      Development team approved by @tech-lead (1/2)
      Waiting for: @senior-dev

11:30 ✅ Approval Granted
      Development team approved by @senior-dev (2/2)
      Stage complete! Moving to QA...

13:00 ✅ Approval Granted
      QA team approved by @qa-lead
      Stage complete! Moving to security...

14:30 ✅ Approval Granted
      Security team approved by @security-team-lead
      All parallel stages complete! Moving to release...

15:00 ✅ Approval Granted
      Release management approved by @release-manager (1/2)
      Waiting for: @product-owner

15:15 ✅ Approval Granted
      Release management approved by @product-owner (2/2)

15:16 🎉 All Approvals Complete
      Version: v1.2.3 fully approved!
      Ready for production deployment 🚀
      @channel
```

## Advanced: Rich Message Formatting

### Custom Slack Block Kit Messages

Create enhanced notifications with buttons, fields, and formatting:

```bash
# Send rich message via curl
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d '{
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "🚀 Release Approval: v1.2.3"
        }
      },
      {
        "type": "section",
        "fields": [
          {"type": "mrkdwn", "text": "*Status:*\nPending"},
          {"type": "mrkdwn", "text": "*Approvals:*\n3 of 6"},
          {"type": "mrkdwn", "text": "*Stage:*\nSecurity Review"},
          {"type": "mrkdwn", "text": "*ETA:*\n2 hours"}
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*Progress:*\n✅ Development (2/2)\n✅ QA (1/1)\n⏳ Security (0/1)\n⏸️  Release (0/2)"
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {"type": "plain_text", "text": "View in GitHub"},
            "url": "https://github.com/owner/repo/issues/123",
            "style": "primary"
          },
          {
            "type": "button",
            "text": {"type": "plain_text", "text": "View Changelog"},
            "url": "https://github.com/owner/repo/blob/main/CHANGELOG.md"
          }
        ]
      }
    ]
  }'
```

## Environment Variable Management

### Local Development

```bash
# .env (never commit!)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T012.../B034.../xyz123...

# .env.example (commit this!)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/HERE

# Load environment
export $(cat .env | xargs)

# Test notification
bash scripts/notify-slack.sh approval-requested 1.0.0 "Test message"
```

### GitHub Actions

```bash
# Set secret via GitHub CLI
echo "https://hooks.slack.com/services/T012.../B034.../xyz123..." | \
  gh secret set SLACK_WEBHOOK_URL

# Or via GitHub UI:
# Settings → Secrets and variables → Actions → New repository secret
```

## Troubleshooting

### Webhook Returns "invalid_payload"

**Problem**: JSON formatting error

**Solution**:
```bash
# Validate JSON before sending
echo '{"text": "test"}' | jq .

# Use single quotes for JSON, double quotes for strings inside
curl -X POST "$SLACK_WEBHOOK_URL" \
  -d '{"text": "valid message"}'
```

### No Slack Notifications Received

**Checklist:**
1. ✅ Webhook URL correct and not a placeholder
2. ✅ `SLACK_WEBHOOK_URL` environment variable set
3. ✅ Slack app installed in workspace
4. ✅ Webhook has permission to post to channel
5. ✅ Channel exists and app has access

### Rate Limiting

**Problem**: `rate_limited` response from Slack

**Solution**: Implement backoff
```bash
send_with_retry() {
  local max_retries=3
  local retry_delay=2

  for i in $(seq 1 $max_retries); do
    response=$(curl -s -X POST "$SLACK_WEBHOOK_URL" -d "$1")
    if [ "$response" = "ok" ]; then
      return 0
    fi
    sleep $retry_delay
    retry_delay=$((retry_delay * 2))
  done
  return 1
}
```

## Next Steps

- Implement automated gating: See `automated-gating.md`
- Add approval audit trails: See `approval-audit-trail.md`
- Customize notification templates: See `slack-webhook-config.json`

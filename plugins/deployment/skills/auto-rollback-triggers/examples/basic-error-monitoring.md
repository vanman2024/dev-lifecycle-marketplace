# Basic Error Monitoring

Simple error rate monitoring setup for automated rollback triggers.

## Overview

This example demonstrates a basic error monitoring workflow that:
- Monitors application error rates
- Triggers rollback when threshold exceeded
- Sends notifications to team

## Prerequisites

- Application with metrics endpoint (`/metrics`)
- Deployment platform API access (Vercel, DigitalOcean, Railway)
- Slack webhook URL (optional, for notifications)

## Setup Steps

### 1. Configure Error Thresholds

Create error threshold configuration:

```bash
cp templates/error-threshold-config.json config/error-thresholds.json
```

Edit `config/error-thresholds.json`:

```json
{
  "error_thresholds": {
    "thresholds": {
      "high": {
        "error_rate_percent": 5.0,
        "time_window_seconds": 300,
        "action": "rollback_after_monitoring"
      }
    }
  }
}
```

### 2. Run Error Rate Monitoring

Monitor error rate for 5 minutes:

```bash
bash scripts/monitor-error-rate.sh \
  https://api.example.com/metrics \
  5.0 \
  300
```

**Expected Output:**

```
[INFO] === Error Rate Monitor ===
[INFO] Metrics URL: https://api.example.com/metrics
[INFO] Threshold: 5.0%
[INFO] Time Window: 300s
[INFO] Monitoring for 300 seconds (5.0 minutes)
[INFO] Check 1: Error rate = 2.3%
[INFO] Check 2: Error rate = 2.5%
[INFO] Check 3: Error rate = 6.2%
[WARN] Threshold exceeded! (6.2% > 5.0%)
[INFO] Monitoring complete:
[INFO]   Total checks: 10
[INFO]   Violations: 4
[INFO]   Violation rate: 40.00%
[INFO] ✓ Error rate within acceptable bounds
```

### 3. Trigger Rollback on Threshold Exceeded

If error rate exceeds threshold:

```bash
# Trigger rollback
bash scripts/trigger-rollback.sh \
  vercel \
  my-project \
  dpl_previous123xyz \
  $VERCEL_TOKEN
```

### 4. Send Notification

Notify team via Slack:

```bash
bash scripts/notify-webhook.sh \
  "https://hooks.slack.com/services/YOUR/WEBHOOK/URL" \
  "Auto-rollback triggered: Error rate 6.2% exceeded threshold 5.0%" \
  --slack
```

## GitHub Actions Integration

### Basic Workflow

Copy the error monitoring workflow:

```bash
cp templates/github-actions-error-monitoring.yml \
   .github/workflows/error-monitoring.yml
```

Configure secrets:

```bash
gh secret set PRODUCTION_METRICS_URL -b "https://api.example.com/metrics"
gh secret set SLACK_WEBHOOK_URL -b "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

### Manual Workflow Dispatch

Trigger monitoring manually:

```bash
gh workflow run error-monitoring.yml \
  -f metrics_url="https://api.example.com/metrics"
```

## Metrics Endpoint Format

Your application should expose metrics in one of these formats:

### Format 1: Direct Error Rate

```json
{
  "error_rate": 2.3,
  "total_requests": 10000,
  "timestamp": "2025-11-05T12:00:00Z"
}
```

### Format 2: Request Counts

```json
{
  "total_requests": 10000,
  "error_requests": 230,
  "success_requests": 9770
}
```

### Format 3: Success Rate

```json
{
  "success_rate": 97.7,
  "total": 10000
}
```

## Testing

### Test with Mock Metrics

Create a mock metrics endpoint for testing:

```bash
# Start simple HTTP server with mock metrics
mkdir -p /tmp/mock-metrics
cat > /tmp/mock-metrics/metrics <<EOF
{
  "error_rate": 2.5,
  "total_requests": 1000,
  "error_requests": 25
}
EOF

cd /tmp/mock-metrics && python3 -m http.server 8080 &
```

Test monitoring:

```bash
bash scripts/monitor-error-rate.sh \
  http://localhost:8080/metrics \
  5.0 \
  60
```

Expected: Monitoring passes (error rate 2.5% < 5.0%)

### Test with High Error Rate

Update mock metrics:

```bash
cat > /tmp/mock-metrics/metrics <<EOF
{
  "error_rate": 7.5,
  "total_requests": 1000,
  "error_requests": 75
}
EOF
```

Test monitoring:

```bash
bash scripts/monitor-error-rate.sh \
  http://localhost:8080/metrics \
  5.0 \
  60
```

Expected: Monitoring fails (error rate 7.5% > 5.0%), exit code 1

## Troubleshooting

### Metrics Endpoint Unreachable

**Problem**: `Failed to fetch metrics from https://api.example.com/metrics`

**Solutions**:
- Verify endpoint URL is correct
- Check network connectivity
- Ensure endpoint is public or authentication is configured
- Verify endpoint returns valid JSON

### False Positive Rollbacks

**Problem**: Rollbacks triggered by transient error spikes

**Solutions**:
- Increase time window (e.g., 300s → 600s)
- Increase error rate threshold (e.g., 5.0% → 7.0%)
- Require multiple consecutive violations
- Filter out expected errors (404s, rate limits)

### Script Dependencies Missing

**Problem**: `Missing required dependencies: jq bc`

**Solution**:
```bash
# Ubuntu/Debian
sudo apt-get install -y curl jq bc coreutils

# macOS
brew install jq bc coreutils
```

## Best Practices

1. **Start Conservative**: Begin with higher thresholds and adjust based on actual error patterns
2. **Monitor Gradually**: Start with 5-minute windows, extend to 15+ minutes for production
3. **Test in Staging**: Validate monitoring and rollback in staging before production
4. **Log Everything**: Keep detailed logs of all monitoring runs and rollback decisions
5. **Review Regularly**: Review triggered rollbacks weekly to improve thresholds

## Next Steps

- Set up SLO-based monitoring (see `slo-based-rollback.md`)
- Add Slack webhook integration (see `slack-webhook-integration.md`)
- Implement multi-platform rollback (see `multi-platform-rollback.md`)
- Add advanced APM integration (see `advanced-monitoring.md`)

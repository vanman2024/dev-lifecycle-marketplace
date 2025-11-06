# SLO-Based Rollback

SLO (Service Level Objective) violation detection and automated rollback.

## Overview

This example demonstrates SLO-based rollback triggers that:
- Validate multiple SLO metrics (availability, latency, error rate)
- Trigger rollback only when SLOs are violated
- Provide comprehensive SLO reporting

## SLO Definitions

### Common SLO Targets

| Metric | Target | Violation Trigger |
|--------|--------|-------------------|
| Availability | 99.9% | < 99.0% |
| P95 Latency | < 500ms | > 2000ms |
| P99 Latency | < 1000ms | > 5000ms |
| Error Rate | < 1.0% | > 5.0% |
| Success Rate | > 99.0% | < 95.0% |

## Setup Steps

### 1. Create SLO Configuration

```bash
cp templates/slo-config.json config/slo.json
```

Edit SLO targets:

```json
{
  "slo": {
    "objectives": {
      "availability": {
        "target_percent": 99.9,
        "measurement_window_hours": 24
      },
      "latency_p95": {
        "target_ms": 500,
        "measurement_window_minutes": 15
      },
      "error_rate": {
        "max_percent": 1.0,
        "measurement_window_minutes": 10
      }
    }
  }
}
```

### 2. Check SLO Compliance

Run comprehensive SLO validation:

```bash
bash scripts/check-slo.sh \
  https://api.example.com/health \
  99.9 \
  config/slo.json
```

**Expected Output:**

```
[INFO] === SLO Validation ===
[INFO] Health URL: https://api.example.com/health
[INFO] SLO Target: 99.9%
[INFO] Step 1: Checking endpoint health...
[INFO] ✓ Endpoint is healthy
[INFO] Step 2: Fetching health metrics...
[INFO] Step 3: Calculating availability...
[INFO] Current availability: 99.95%
[INFO] ✓ Availability SLO met (99.95% >= 99.9%)
[INFO] Step 4: Checking additional SLO metrics...
[INFO] P95 Latency: 350ms (target: <500ms)
[INFO] ✓ Latency SLO met
[INFO] Error Rate: 0.5% (target: <1.0%)
[INFO] ✓ Error rate SLO met
[INFO] Step 5: Time-based SLO monitoring...
[INFO] Monitoring SLO for 300 seconds...
[INFO] Check 1: ✓ Healthy
[INFO] Check 2: ✓ Healthy
[INFO] SLO Check Results:
[INFO]   Total checks: 10
[INFO]   Successful: 10
[INFO]   Failed: 0
[INFO]   Actual availability: 100.00%
[INFO] ✓ SLO met (100.00% >= 99.9%)
[INFO] === SLO Validation Summary ===
[INFO] ✓ All SLO checks passed
```

### 3. Handle SLO Violations

If SLO validation fails, trigger rollback:

```bash
# Check exit code
if ! bash scripts/check-slo.sh https://api.example.com/health 99.9; then
  echo "SLO violated - triggering rollback"

  bash scripts/trigger-rollback.sh \
    vercel \
    my-project \
    dpl_previous123xyz \
    $VERCEL_TOKEN

  bash scripts/notify-webhook.sh \
    "$SLACK_WEBHOOK_URL" \
    "Auto-rollback triggered: SLO violation detected" \
    --slack
fi
```

## GitHub Actions Workflow

### Complete SLO Validation Workflow

Copy the SLO check workflow:

```bash
cp templates/github-actions-slo-check.yml \
   .github/workflows/slo-validation.yml
```

Configure secrets:

```bash
gh secret set PRODUCTION_HEALTH_URL -b "https://api.example.com/health"
gh secret set SLACK_WEBHOOK_URL -b "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

### Workflow Features

The workflow:
1. Waits 30s for deployment stabilization
2. Checks SLO compliance
3. Collects detailed metrics
4. Uploads metrics as artifacts
5. Notifies team of results
6. Fails if SLO violated

### Manual Trigger

```bash
gh workflow run slo-validation.yml \
  -f health_url="https://api.example.com/health" \
  -f slo_target="99.9"
```

## Health Endpoint Format

Your application should expose health data:

### Minimal Format

```json
{
  "status": "healthy",
  "uptime": 99.95,
  "timestamp": "2025-11-05T12:00:00Z"
}
```

### Comprehensive Format

```json
{
  "status": "healthy",
  "uptime": 99.95,
  "availability": 99.95,
  "latency_p95": 350,
  "latency_p99": 800,
  "error_rate": 0.5,
  "success_rate": 99.5,
  "total_requests": 100000,
  "successful_requests": 99500,
  "failed_requests": 500,
  "timestamp": "2025-11-05T12:00:00Z"
}
```

### Metrics Endpoint Format

Separate metrics endpoint at `/metrics`:

```json
{
  "error_rate": 0.5,
  "latency_p95": 350,
  "latency_p99": 800,
  "total_requests": 100000,
  "error_requests": 500,
  "success_rate": 99.5
}
```

## Multi-SLO Validation

### Check Multiple SLOs Simultaneously

Create combined validation script:

```bash
#!/bin/bash
set -e

HEALTH_URL="https://api.example.com/health"
METRICS_URL="https://api.example.com/metrics"

echo "=== Multi-SLO Validation ==="

# Check availability SLO
echo "1. Checking availability SLO..."
bash scripts/check-slo.sh "$HEALTH_URL" 99.9 || {
  echo "Availability SLO failed"
  exit 1
}

# Check error rate SLO
echo "2. Checking error rate SLO..."
bash scripts/monitor-error-rate.sh "$METRICS_URL" 1.0 300 || {
  echo "Error rate SLO failed"
  exit 1
}

echo "✓ All SLO checks passed"
```

## Testing SLO Validation

### Test with Mock Health Endpoint

```bash
# Create mock health endpoint
mkdir -p /tmp/mock-health
cat > /tmp/mock-health/health <<EOF
{
  "status": "healthy",
  "uptime": 99.95,
  "latency_p95": 350,
  "error_rate": 0.5
}
EOF

cd /tmp/mock-health && python3 -m http.server 8080 &

# Test SLO validation
bash scripts/check-slo.sh http://localhost:8080/health 99.9
```

Expected: SLO validation passes

### Test with SLO Violation

```bash
# Update mock to violate SLO
cat > /tmp/mock-health/health <<EOF
{
  "status": "degraded",
  "uptime": 98.5,
  "latency_p95": 2500,
  "error_rate": 6.5
}
EOF

# Test SLO validation
bash scripts/check-slo.sh http://localhost:8080/health 99.9
```

Expected: SLO validation fails, exit code 1

## Advanced SLO Patterns

### Graduated Rollback Based on SLO Severity

```bash
#!/bin/bash

HEALTH_URL="https://api.example.com/health"
AVAILABILITY=$(curl -sf "$HEALTH_URL" | jq -r '.uptime')

if (( $(echo "$AVAILABILITY < 95.0" | bc -l) )); then
  echo "Critical SLO violation - immediate rollback"
  bash scripts/trigger-rollback.sh vercel my-project previous_id
elif (( $(echo "$AVAILABILITY < 99.0" | bc -l) )); then
  echo "Moderate SLO violation - monitor for 5 minutes"
  sleep 300
  # Re-check and rollback if still violated
elif (( $(echo "$AVAILABILITY < 99.9" | bc -l) )); then
  echo "Minor SLO violation - alert team"
  bash scripts/notify-webhook.sh "$SLACK_WEBHOOK_URL" "SLO degraded"
else
  echo "SLO met - no action needed"
fi
```

### Time-Window Based SLO

```bash
# Check SLO over 15-minute window
bash scripts/check-slo.sh \
  https://api.example.com/health \
  99.9 \
  config/slo-15min.json
```

## Troubleshooting

### SLO Data Not Available

**Problem**: Health endpoint doesn't provide SLO metrics

**Solutions**:
- Add metrics collection to your application
- Use monitoring service API (Datadog, New Relic)
- Calculate SLO from logs/traces
- Start with simple availability checks

### Flaky SLO Checks

**Problem**: SLO validation randomly fails

**Solutions**:
- Increase measurement window
- Require consecutive violations (3+ failures)
- Add grace period after deployment (60s)
- Filter out deployment-related transients

## Best Practices

1. **Define Clear SLOs**: Document SLO targets and measurement windows
2. **Start Loose, Tighten Gradually**: Begin with achievable targets (99.0%), increase to stretch goals (99.9%)
3. **Monitor Multiple Metrics**: Don't rely on single metric - use availability + latency + error rate
4. **Grace Periods**: Allow 60-120s stabilization after deployment
5. **Review SLO History**: Track SLO violations over time to improve reliability

## Next Steps

- Add advanced monitoring (see `advanced-monitoring.md`)
- Implement canary deployment protection (see `gradual-rollout-protection.md`)
- Set up multi-platform rollback (see `multi-platform-rollback.md`)

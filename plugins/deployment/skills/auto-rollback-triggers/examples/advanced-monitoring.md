# Advanced Monitoring

Integration with APM tools (Datadog, New Relic, Sentry) for comprehensive auto-rollback monitoring.

## Overview

Advanced monitoring patterns using:
- **Datadog**: Metrics, logs, APM traces
- **New Relic**: Application performance monitoring
- **Sentry**: Error tracking and alerting
- **Prometheus**: Time-series metrics
- **Custom monitoring**: Application-specific metrics

## Datadog Integration

### Setup Datadog Monitoring

```bash
# Install Datadog CLI (optional)
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=your_datadog_api_key_here \
  bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
```

### Query Datadog Metrics

```bash
#!/bin/bash
# query-datadog-metrics.sh

DD_API_KEY="your_datadog_api_key_here"
DD_APP_KEY="your_datadog_app_key_here"
DD_SITE="datadoghq.com"

QUERY="avg:trace.express.request.errors{env:production}"
FROM=$(date -u -d '10 minutes ago' +%s)
TO=$(date -u +%s)

curl -s -X GET \
  "https://api.${DD_SITE}/api/v1/query" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -G \
  --data-urlencode "query=${QUERY}" \
  --data-urlencode "from=${FROM}" \
  --data-urlencode "to=${TO}" | jq '.'
```

### Monitor Datadog Error Rate

```bash
#!/bin/bash
# monitor-datadog-errors.sh

DD_API_KEY="your_datadog_api_key_here"
DD_APP_KEY="your_datadog_app_key_here"
THRESHOLD=5.0

# Query error rate from Datadog
ERROR_RATE=$(curl -s -X GET \
  "https://api.datadoghq.com/api/v1/query" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -G \
  --data-urlencode "query=avg:trace.express.request.errors{env:production}" \
  --data-urlencode "from=$(date -u -d '5 minutes ago' +%s)" \
  --data-urlencode "to=$(date -u +%s)" | \
  jq -r '.series[0].pointlist[-1][1] // 0')

echo "Current error rate: ${ERROR_RATE}%"

if (( $(echo "$ERROR_RATE > $THRESHOLD" | bc -l) )); then
  echo "Error rate exceeds threshold - triggering rollback"
  exit 1
else
  echo "Error rate within threshold"
  exit 0
fi
```

### Datadog Auto-Rollback Trigger

```bash
#!/bin/bash
# datadog-rollback-trigger.sh

set -e

DD_API_KEY="your_datadog_api_key_here"
DD_APP_KEY="your_datadog_app_key_here"
THRESHOLD=5.0

# Monitor Datadog metrics
if ! bash monitor-datadog-errors.sh; then
  echo "Datadog metrics indicate high error rate"

  # Trigger rollback
  bash scripts/trigger-rollback.sh \
    vercel \
    my-project \
    previous-deployment \
    "$VERCEL_TOKEN"

  # Create Datadog event
  curl -X POST "https://api.datadoghq.com/api/v1/events" \
    -H "DD-API-KEY: ${DD_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
      "title": "Auto-Rollback Triggered",
      "text": "Deployment rolled back due to high error rate",
      "priority": "normal",
      "tags": ["env:production", "service:deployment"],
      "alert_type": "error"
    }'
fi
```

## New Relic Integration

### Query New Relic Metrics

```bash
#!/bin/bash
# query-newrelic-metrics.sh

NR_API_KEY="your_newrelic_api_key_here"
NR_ACCOUNT_ID="your_account_id_here"

NRQL="SELECT percentage(count(*), WHERE error IS true) \
      FROM Transaction \
      WHERE appName = 'my-app' \
      SINCE 5 minutes ago"

curl -s -X POST \
  "https://api.newrelic.com/graphql" \
  -H "API-Key: ${NR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"query\": \"{ actor { account(id: ${NR_ACCOUNT_ID}) { nrql(query: \\\"${NRQL}\\\") { results } } } }\"
  }" | jq '.data.actor.account.nrql.results[0].result'
```

### New Relic Error Rate Monitor

```bash
#!/bin/bash
# monitor-newrelic-errors.sh

NR_API_KEY="your_newrelic_api_key_here"
NR_ACCOUNT_ID="your_account_id_here"
THRESHOLD=5.0

NRQL="SELECT percentage(count(*), WHERE error IS true) \
      FROM Transaction \
      WHERE appName = 'my-app' \
      SINCE 5 minutes ago"

ERROR_RATE=$(curl -s -X POST \
  "https://api.newrelic.com/graphql" \
  -H "API-Key: ${NR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"query\": \"{ actor { account(id: ${NR_ACCOUNT_ID}) { nrql(query: \\\"${NRQL}\\\") { results } } } }\"
  }" | jq -r '.data.actor.account.nrql.results[0].result // 0')

echo "Current error rate: ${ERROR_RATE}%"

if (( $(echo "$ERROR_RATE > $THRESHOLD" | bc -l) )); then
  echo "Error rate exceeds threshold"
  exit 1
else
  echo "Error rate within threshold"
  exit 0
fi
```

## Sentry Integration

### Monitor Sentry Issues

```bash
#!/bin/bash
# monitor-sentry-issues.sh

SENTRY_AUTH_TOKEN="your_sentry_auth_token_here"
SENTRY_ORG="your_org"
SENTRY_PROJECT="your_project"
THRESHOLD=10  # Number of new issues

# Get issues in last 5 minutes
ISSUES=$(curl -s \
  "https://sentry.io/api/0/projects/${SENTRY_ORG}/${SENTRY_PROJECT}/issues/" \
  -H "Authorization: Bearer ${SENTRY_AUTH_TOKEN}" \
  -G \
  --data-urlencode "query=is:unresolved firstSeen:>$(date -u -d '5 minutes ago' --iso-8601=seconds)" | \
  jq '. | length')

echo "New issues in last 5 minutes: $ISSUES"

if [ "$ISSUES" -gt "$THRESHOLD" ]; then
  echo "Too many new issues - triggering rollback"
  exit 1
else
  echo "Issue count within threshold"
  exit 0
fi
```

### Sentry Crash Rate Monitor

```bash
#!/bin/bash
# monitor-sentry-crashes.sh

SENTRY_AUTH_TOKEN="your_sentry_auth_token_here"
SENTRY_ORG="your_org"
SENTRY_PROJECT="your_project"
CRASH_THRESHOLD=1.0  # 1% crash rate

# Get crash statistics
STATS=$(curl -s \
  "https://sentry.io/api/0/projects/${SENTRY_ORG}/${SENTRY_PROJECT}/stats/" \
  -H "Authorization: Bearer ${SENTRY_AUTH_TOKEN}" \
  -G \
  --data-urlencode "stat=crashed" \
  --data-urlencode "since=$(date -u -d '5 minutes ago' +%s)" \
  --data-urlencode "until=$(date -u +%s)")

CRASHES=$(echo "$STATS" | jq '[.[][][1]] | add // 0')
TOTAL=$(echo "$STATS" | jq '[.[][][1]] | length')

if [ "$TOTAL" -gt 0 ]; then
  CRASH_RATE=$(echo "scale=2; ($CRASHES / $TOTAL) * 100" | bc)
else
  CRASH_RATE=0
fi

echo "Crash rate: ${CRASH_RATE}%"

if (( $(echo "$CRASH_RATE > $CRASH_THRESHOLD" | bc -l) )); then
  echo "Crash rate exceeds threshold"
  exit 1
else
  echo "Crash rate within threshold"
  exit 0
fi
```

## Prometheus Integration

### Query Prometheus Metrics

```bash
#!/bin/bash
# query-prometheus-metrics.sh

PROMETHEUS_URL="http://prometheus.example.com:9090"
QUERY='rate(http_requests_total{status=~"5.."}[5m])'

curl -s -G \
  "${PROMETHEUS_URL}/api/v1/query" \
  --data-urlencode "query=${QUERY}" | jq '.data.result[0].value[1]'
```

### Prometheus Error Rate Monitor

```bash
#!/bin/bash
# monitor-prometheus-errors.sh

PROMETHEUS_URL="http://prometheus.example.com:9090"
THRESHOLD=0.05  # 5%

# Query error rate
ERROR_RATE=$(curl -s -G \
  "${PROMETHEUS_URL}/api/v1/query" \
  --data-urlencode 'query=rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])' | \
  jq -r '.data.result[0].value[1] // "0"')

ERROR_RATE_PERCENT=$(echo "scale=2; $ERROR_RATE * 100" | bc)

echo "Error rate: ${ERROR_RATE_PERCENT}%"

if (( $(echo "$ERROR_RATE > $THRESHOLD" | bc -l) )); then
  echo "Error rate exceeds threshold"
  exit 1
else
  echo "Error rate within threshold"
  exit 0
fi
```

## Multi-Source Monitoring

### Aggregate Metrics from Multiple Sources

```bash
#!/bin/bash
# aggregate-monitoring.sh

set -e

echo "=== Aggregated Monitoring ==="

# 1. Check Datadog
echo "1. Checking Datadog..."
bash monitor-datadog-errors.sh || DATADOG_FAILED=1

# 2. Check New Relic
echo "2. Checking New Relic..."
bash monitor-newrelic-errors.sh || NEWRELIC_FAILED=1

# 3. Check Sentry
echo "3. Checking Sentry..."
bash monitor-sentry-issues.sh || SENTRY_FAILED=1

# 4. Check Prometheus
echo "4. Checking Prometheus..."
bash monitor-prometheus-errors.sh || PROMETHEUS_FAILED=1

# Aggregate results
FAILURES=0
[ "${DATADOG_FAILED:-0}" -eq 1 ] && ((FAILURES++))
[ "${NEWRELIC_FAILED:-0}" -eq 1 ] && ((FAILURES++))
[ "${SENTRY_FAILED:-0}" -eq 1 ] && ((FAILURES++))
[ "${PROMETHEUS_FAILED:-0}" -eq 1 ] && ((FAILURES++))

echo ""
echo "=== Results ==="
echo "Failed checks: $FAILURES / 4"

# Trigger rollback if 2+ sources indicate issues
if [ "$FAILURES" -ge 2 ]; then
  echo "Multiple monitoring sources indicate issues - triggering rollback"
  exit 1
else
  echo "Monitoring passed"
  exit 0
fi
```

## Custom Application Metrics

### Application-Specific Health Check

```bash
#!/bin/bash
# check-app-health.sh

APP_URL="https://api.example.com"

# Custom business metrics
ACTIVE_USERS=$(curl -sf "${APP_URL}/metrics/users/active" | jq -r '.count')
ORDER_SUCCESS_RATE=$(curl -sf "${APP_URL}/metrics/orders/success_rate" | jq -r '.rate')
PAYMENT_ERRORS=$(curl -sf "${APP_URL}/metrics/payments/errors" | jq -r '.count')

echo "Active users: $ACTIVE_USERS"
echo "Order success rate: ${ORDER_SUCCESS_RATE}%"
echo "Payment errors: $PAYMENT_ERRORS"

# Check business metric thresholds
if [ "$ACTIVE_USERS" -lt 100 ]; then
  echo "Warning: Low active user count"
  exit 1
fi

if (( $(echo "$ORDER_SUCCESS_RATE < 95.0" | bc -l) )); then
  echo "Error: Order success rate too low"
  exit 1
fi

if [ "$PAYMENT_ERRORS" -gt 10 ]; then
  echo "Error: Too many payment errors"
  exit 1
fi

echo "All application health checks passed"
exit 0
```

## Best Practices

1. **Use Multiple Monitoring Sources**: Don't rely on single APM tool
2. **Set Appropriate Thresholds**: Calibrate based on historical data
3. **Monitor Business Metrics**: Technical + business metrics together
4. **Implement Gradual Checks**: Quick checks first, detailed analysis if needed
5. **Log All Monitoring Results**: Keep audit trail of checks
6. **Test Monitoring Integrations**: Verify API access regularly
7. **Secure API Keys**: Use environment variables, never commit keys

## Troubleshooting

### APM API Rate Limits

**Problem**: Monitoring queries hit rate limits

**Solutions**:
- Cache monitoring results
- Reduce query frequency
- Use batch queries
- Implement exponential backoff

### Conflicting Signals

**Problem**: Different APM tools show different metrics

**Solutions**:
- Use weighted voting (trust most reliable source)
- Investigate discrepancies
- Standardize metric definitions
- Prefer application-native metrics

## Next Steps

- Set up grafana dashboards
- Implement predictive rollback (ML-based)
- Add cost-based rollback decisions
- Create comprehensive monitoring runbooks

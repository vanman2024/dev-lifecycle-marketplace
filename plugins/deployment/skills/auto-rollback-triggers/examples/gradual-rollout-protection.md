# Gradual Rollout Protection

Canary deployment protection with auto-rollback for gradual traffic shifting.

## Overview

Gradual rollout patterns:
- **Canary Deployment**: Route small percentage of traffic to new version
- **Blue-Green Deployment**: Switch between two identical environments
- **Progressive Delivery**: Gradually increase traffic to new version
- **Feature Flags**: Control feature rollout independent of deployment

## Canary Deployment

### Basic Canary Pattern

```bash
#!/bin/bash
# canary-deploy.sh

CANARY_PERCENT=10
CANARY_DURATION=600  # 10 minutes

echo "=== Canary Deployment ==="
echo "Canary traffic: ${CANARY_PERCENT}%"
echo "Duration: ${CANARY_DURATION}s"

# Deploy canary version
echo "1. Deploying canary..."
# Your deployment commands here

# Monitor canary metrics
echo "2. Monitoring canary..."
sleep 60  # Stabilization period

# Compare canary vs stable metrics
CANARY_ERROR_RATE=$(curl -sf "https://api.example.com/metrics?version=canary" | \
  jq -r '.error_rate')
STABLE_ERROR_RATE=$(curl -sf "https://api.example.com/metrics?version=stable" | \
  jq -r '.error_rate')

echo "Canary error rate: ${CANARY_ERROR_RATE}%"
echo "Stable error rate: ${STABLE_ERROR_RATE}%"

# Calculate difference
DIFFERENCE=$(echo "$CANARY_ERROR_RATE - $STABLE_ERROR_RATE" | bc)

if (( $(echo "$DIFFERENCE > 2.0" | bc -l) )); then
  echo "Canary shows significantly higher error rate - rolling back"
  bash scripts/trigger-rollback.sh vercel my-project stable-deployment "$VERCEL_TOKEN"
  exit 1
else
  echo "Canary metrics acceptable - promoting"
  # Promote canary to full traffic
  exit 0
fi
```

### Progressive Traffic Shift

```bash
#!/bin/bash
# progressive-canary.sh

STEPS=(10 25 50 75 100)
STEP_DURATION=300  # 5 minutes per step

for PERCENT in "${STEPS[@]}"; do
  echo "=== Shifting ${PERCENT}% traffic to new version ==="

  # Update traffic split (platform-specific)
  # Example: vercel-cli set-traffic new=$PERCENT stable=$((100-PERCENT))

  # Wait for stabilization
  sleep 60

  # Monitor for step duration
  START_TIME=$(date +%s)
  END_TIME=$((START_TIME + STEP_DURATION))

  while [ $(date +%s) -lt $END_TIME ]; do
    # Check error rate
    ERROR_RATE=$(curl -sf "https://api.example.com/metrics?version=new" | \
      jq -r '.error_rate')

    echo "$(date -u +%H:%M:%S) - Traffic: ${PERCENT}%, Error rate: ${ERROR_RATE}%"

    if (( $(echo "$ERROR_RATE > 5.0" | bc -l) )); then
      echo "Error rate exceeded threshold - rolling back"
      # Shift all traffic back to stable
      exit 1
    fi

    sleep 30
  done

  echo "Step ${PERCENT}% completed successfully"
done

echo "✓ Progressive rollout complete - 100% on new version"
```

### Automated Canary Decision

```bash
#!/bin/bash
# canary-decision.sh

CANARY_URL="https://api-canary.example.com"
STABLE_URL="https://api-stable.example.com"
DURATION=600

echo "=== Automated Canary Analysis ==="

# Collect metrics over duration
collect_metrics() {
  local url="$1"
  local version="$2"

  local error_count=0
  local success_count=0
  local latency_sum=0
  local checks=0

  for i in $(seq 1 20); do
    local response
    response=$(curl -sf -w "%{http_code}:%{time_total}" "$url/health" | tail -1)

    local http_code latency
    IFS=':' read -r http_code latency <<< "$response"

    checks=$((checks + 1))

    if [[ "$http_code" =~ ^2 ]]; then
      success_count=$((success_count + 1))
    else
      error_count=$((error_count + 1))
    fi

    latency_sum=$(echo "$latency_sum + $latency * 1000" | bc)

    sleep $((DURATION / 20))
  done

  local error_rate=$(echo "scale=2; ($error_count / $checks) * 100" | bc)
  local avg_latency=$(echo "scale=0; $latency_sum / $checks" | bc)

  echo "$error_rate:$avg_latency"
}

# Collect canary metrics
echo "Monitoring canary version..."
CANARY_METRICS=$(collect_metrics "$CANARY_URL" "canary")
CANARY_ERROR_RATE=$(echo "$CANARY_METRICS" | cut -d: -f1)
CANARY_LATENCY=$(echo "$CANARY_METRICS" | cut -d: -f2)

# Collect stable metrics
echo "Monitoring stable version..."
STABLE_METRICS=$(collect_metrics "$STABLE_URL" "stable")
STABLE_ERROR_RATE=$(echo "$STABLE_METRICS" | cut -d: -f1)
STABLE_LATENCY=$(echo "$STABLE_METRICS" | cut -d: -f2)

echo ""
echo "=== Metrics Comparison ==="
echo "Canary: Error rate ${CANARY_ERROR_RATE}%, Latency ${CANARY_LATENCY}ms"
echo "Stable: Error rate ${STABLE_ERROR_RATE}%, Latency ${STABLE_LATENCY}ms"

# Decision logic
DECISION="promote"

# Check error rate regression
ERROR_DIFF=$(echo "$CANARY_ERROR_RATE - $STABLE_ERROR_RATE" | bc)
if (( $(echo "$ERROR_DIFF > 2.0" | bc -l) )); then
  echo "❌ Canary error rate significantly higher (+${ERROR_DIFF}%)"
  DECISION="rollback"
fi

# Check latency regression
LATENCY_DIFF=$(echo "$CANARY_LATENCY - $STABLE_LATENCY" | bc)
if (( $(echo "$LATENCY_DIFF > 200" | bc -l) )); then
  echo "❌ Canary latency significantly higher (+${LATENCY_DIFF}ms)"
  DECISION="rollback"
fi

# Execute decision
echo ""
echo "=== Decision: $DECISION ==="

if [ "$DECISION" = "rollback" ]; then
  echo "Rolling back canary deployment"
  bash scripts/trigger-rollback.sh vercel my-project stable "$VERCEL_TOKEN"
  exit 1
else
  echo "Promoting canary to production"
  # Promotion logic here
  exit 0
fi
```

## Vercel Deployment Protection

### Vercel Checks Integration

```json
{
  "checks": [
    {
      "name": "Error Rate Check",
      "path": "/api/check-error-rate",
      "schedule": "after_deploy",
      "blocking": true
    },
    {
      "name": "Performance Check",
      "path": "/api/check-performance",
      "schedule": "after_deploy",
      "blocking": true
    }
  ],
  "deployment": {
    "protection": {
      "enabled": true,
      "preview": {
        "enabled": true,
        "allowedPaths": ["/preview/*"]
      }
    }
  }
}
```

### Vercel Deployment Check API

```typescript
// pages/api/check-error-rate.ts
export default async function handler(req, res) {
  const deploymentUrl = req.headers['x-vercel-deployment-url'];

  // Fetch metrics
  const response = await fetch(`https://${deploymentUrl}/api/metrics`);
  const metrics = await response.json();

  const errorRate = metrics.error_rate || 0;
  const threshold = 5.0;

  if (errorRate > threshold) {
    return res.status(400).json({
      status: 'failed',
      conclusion: 'Error rate exceeds threshold',
      details: {
        error_rate: errorRate,
        threshold: threshold
      }
    });
  }

  return res.status(200).json({
    status: 'passed',
    conclusion: 'Error rate within acceptable limits',
    details: {
      error_rate: errorRate,
      threshold: threshold
    }
  });
}
```

## Feature Flags

### Feature Flag Controlled Rollout

```bash
#!/bin/bash
# feature-flag-rollout.sh

FEATURE_FLAG="new_checkout_flow"
ROLLOUT_STEPS=(1 5 10 25 50 100)

for PERCENT in "${ROLLOUT_STEPS[@]}"; do
  echo "=== Rolling out to ${PERCENT}% of users ==="

  # Update feature flag percentage
  curl -X PATCH \
    "https://api.featureflag.com/flags/$FEATURE_FLAG" \
    -H "Authorization: Bearer $FEATURE_FLAG_TOKEN" \
    -d "{\"percentage\": $PERCENT}"

  # Monitor for 10 minutes
  echo "Monitoring for 10 minutes..."

  if ! bash scripts/monitor-error-rate.sh \
    "https://api.example.com/metrics?feature=$FEATURE_FLAG" \
    5.0 \
    600; then
    echo "Feature flag rollout failed - disabling feature"

    # Disable feature flag
    curl -X PATCH \
      "https://api.featureflag.com/flags/$FEATURE_FLAG" \
      -H "Authorization: Bearer $FEATURE_FLAG_TOKEN" \
      -d '{"enabled": false}'

    exit 1
  fi

  echo "Step ${PERCENT}% successful"
done

echo "✓ Feature flag fully rolled out"
```

## Blue-Green Deployment

### Blue-Green Traffic Switch

```bash
#!/bin/bash
# blue-green-switch.sh

GREEN_URL="https://green.example.com"
BLUE_URL="https://blue.example.com"  # Current production

echo "=== Blue-Green Deployment ==="

# Step 1: Deploy green environment
echo "1. Green environment ready at $GREEN_URL"

# Step 2: Validate green environment
echo "2. Validating green environment..."

if ! bash scripts/check-slo.sh "$GREEN_URL/health" 99.9; then
  echo "Green environment failed SLO check"
  exit 1
fi

# Step 3: Monitor green under synthetic load
echo "3. Running synthetic traffic..."
# Load testing commands here

# Step 4: Switch traffic to green
echo "4. Switching traffic to green..."
# DNS/load balancer switch commands here

# Step 5: Monitor green in production
echo "5. Monitoring green in production..."

if ! bash scripts/monitor-error-rate.sh \
  "$GREEN_URL/metrics" \
  5.0 \
  600; then
  echo "Green environment failed under production load - switching back to blue"
  # Switch back to blue
  exit 1
fi

echo "✓ Blue-green deployment successful"
echo "Blue (old) environment can be decommissioned"
```

## Best Practices

1. **Start Small**: Begin with 1-5% canary traffic
2. **Automated Decisions**: Don't rely on manual promotion
3. **Statistical Significance**: Ensure enough traffic for meaningful metrics
4. **Multiple Metrics**: Check error rate, latency, business metrics
5. **Rollback Speed**: Instant rollback for safety
6. **Monitoring Duration**: 10-30 minutes per canary stage
7. **Documentation**: Document rollout strategy and thresholds

## Troubleshooting

### Insufficient Canary Traffic

**Problem**: Not enough requests to canary for statistically significant results

**Solutions**:
- Increase canary percentage (10% → 25%)
- Extend monitoring duration
- Use synthetic traffic for testing
- Consider blue-green instead

### Flaky Canary Metrics

**Problem**: Canary metrics vary significantly

**Solutions**:
- Extend stabilization period
- Filter out cold start issues
- Use rolling averages
- Require consecutive violations

## Next Steps

- Implement ML-based anomaly detection
- Add automated A/B testing integration
- Set up gradual feature flag rollout
- Create canary analysis reports

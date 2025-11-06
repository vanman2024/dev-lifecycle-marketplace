# Example: Basic Canary Deployment to Vercel

This example demonstrates a simple canary deployment workflow for a Next.js application deployed on Vercel with 10% canary traffic.

## Scenario

**Project**: E-commerce web app built with Next.js
**Change**: Update product recommendation algorithm
**Risk Level**: Medium
**Strategy**: Start with 10% canary traffic, monitor for 30 minutes, then proceed with gradual rollout

## Prerequisites

- Next.js app already deployed to Vercel
- Vercel CLI installed and authenticated
- Edge Config created in Vercel Dashboard
- Middleware configured (see `templates/vercel-middleware-canary.ts`)

## Step 1: Initial Canary Deployment

Deploy the new version as a canary with 10% traffic:

```bash
cd /path/to/nextjs-app

# Deploy canary version
./scripts/canary-deploy-vercel.sh . 10
```

**Expected Output**:
```
🚀 Starting Vercel Canary Deployment
   Project: /path/to/nextjs-app
   Canary Traffic: 10%

📦 Detected project name: my-ecommerce-app
🔍 Fetching current production deployment...
✅ Current production: https://my-ecommerce-app.vercel.app

📦 Deploying canary version...
✅ Canary deployed: https://my-ecommerce-app-xyz123.vercel.app

🏥 Running health check on canary...
✅ Health check passed (HTTP 200)

⚙️  Configuring traffic split...
✅ Edge Config created: /tmp/edge-config-my-ecommerce-app.json

📊 Deployment Summary:
   Production: https://my-ecommerce-app.vercel.app
   Canary:     https://my-ecommerce-app-xyz123.vercel.app
   Traffic:    10% to canary, 90% to production
```

## Step 2: Update Edge Config

Upload the Edge Config to enable traffic splitting:

```bash
# View generated Edge Config
cat /tmp/edge-config-my-ecommerce-app.json
```

```json
{
  "canary": {
    "enabled": true,
    "percentage": 10,
    "canaryUrl": "https://my-ecommerce-app-xyz123.vercel.app",
    "productionUrl": "https://my-ecommerce-app.vercel.app",
    "deployedAt": "2025-11-05T18:00:00Z"
  }
}
```

**In Vercel Dashboard**:
1. Go to https://vercel.com/dashboard/stores
2. Select your Edge Config
3. Update `canary` item with the JSON above
4. Save changes

Traffic splitting is now active! 10% of requests route to canary.

## Step 3: Monitor Canary Health

Monitor the canary deployment for 30 minutes:

```bash
# Start continuous monitoring (runs every 60s)
./scripts/monitor-canary.sh vercel my-ecommerce-app
```

**Sample Output**:
```
🔍 Starting Canary Health Monitor
   Platform: vercel
   Project: my-ecommerce-app
   Check Interval: 60s
   Error Threshold: 5%
   Mode: Continuous monitoring (Ctrl+C to stop)

[2025-11-05 18:05:00] Checking Vercel deployment...
   Production: HTTP 200 | 0.234s
   Canary:     HTTP 200 | 0.241s
✅ Health check passed | Error rate: 2%

⏱️  Next check in 60s...

[2025-11-05 18:06:00] Checking Vercel deployment...
   Production: HTTP 200 | 0.228s
   Canary:     HTTP 200 | 0.239s
✅ Health check passed | Error rate: 1%

⏱️  Next check in 60s...
```

## Step 4: Verify Traffic Split in Analytics

In Vercel Analytics Dashboard:
- Navigate to https://vercel.com/dashboard/analytics
- Select your project
- View deployment traffic split:
  - Production: ~90% of requests
  - Canary: ~10% of requests

Monitor key metrics:
- Error rates (should be comparable)
- Latency (P95, P99)
- Request volume
- Conversion rates

## Step 5: Gradual Rollout (Optional)

After 30 minutes of stable canary traffic, proceed with automated gradual rollout:

```bash
# Execute standard rollout schedule
# 10% → 25% → 50% → 100% (15 min intervals)
./scripts/gradual-rollout.sh vercel my-ecommerce-app standard
```

**Expected Output**:
```
🚀 Starting Gradual Canary Rollout
   Platform: vercel
   Project: my-ecommerce-app
   Schedule: standard
   Error Threshold: 5%

📋 Rollout Plan:
   Stage 1: 10% traffic → already deployed
   Stage 2: 25% traffic → wait 15 minutes
   Stage 3: 50% traffic → wait 15 minutes
   Stage 4: 100% traffic → complete

═══════════════════════════════════════
Stage 2: Deploying 25% canary traffic
═══════════════════════════════════════

⚠️  Manual step: Update Edge Config to 25% canary traffic
📊 Stage 2: 25% canary traffic deployed for my-ecommerce-app

⏱️  Waiting 60 seconds for traffic to stabilize...
🏥 Running health check at 25% canary traffic...
✅ Health check passed: Error rate 3%

⏱️  Waiting 15 minutes before next stage...
   Monitoring canary health during wait period
```

## Step 6: Manual Rollback (If Needed)

If issues are detected during rollout:

```bash
# Instant rollback to production
./scripts/rollback-canary.sh vercel my-ecommerce-app
```

**Expected Output**:
```
↩️  Starting Canary Rollback
   Platform: vercel
   Project: my-ecommerce-app

🔍 Finding stable deployment...
✅ Stable deployment: https://my-ecommerce-app.vercel.app

⚙️  Routing 100% traffic to stable version...
✅ Rollback configuration saved: /tmp/edge-config-rollback-my-ecommerce-app.json
   Update Edge Config in Vercel Dashboard to apply rollback

📋 Recent Deployments:
   https://my-ecommerce-app.vercel.app (PRODUCTION)
   https://my-ecommerce-app-xyz123.vercel.app
   ...

✅ Rollback complete!
   All traffic routed to: https://my-ecommerce-app.vercel.app
```

## Results

**Successful Deployment**:
- Canary ran for 30 minutes at 10% traffic
- No significant error rate increase
- Latency comparable to production
- Gradual rollout completed to 100%
- New algorithm now serves all traffic

**Key Metrics**:
- Total rollout time: 75 minutes (30 min canary + 45 min gradual rollout)
- Zero downtime
- Risk minimized by progressive traffic increase
- Rollback capability maintained throughout

## Best Practices Demonstrated

1. **Start Small**: 10% initial canary traffic limits impact
2. **Monitor Continuously**: Real-time health checks throughout rollout
3. **Progressive Rollout**: Automated gradual increase reduces risk
4. **Fast Rollback**: Instant reversion if issues detected
5. **Metrics-Driven**: Decision based on actual error rates and latency

## Variations

### Faster Rollout (Low Risk)
```bash
# Use fast schedule: 10% → 50% → 100% (5 min intervals)
./scripts/gradual-rollout.sh vercel my-ecommerce-app fast
```

### Safer Rollout (High Risk)
```bash
# Use safe schedule: 5% → 10% → 25% → 50% → 75% → 100% (30 min intervals)
./scripts/gradual-rollout.sh vercel my-ecommerce-app safe
```

### Manual Traffic Adjustment
```bash
# Increase to 25% manually
./scripts/canary-deploy-vercel.sh . 25

# Monitor for desired duration
./scripts/monitor-canary.sh vercel my-ecommerce-app

# Increase to 50%
./scripts/canary-deploy-vercel.sh . 50
```

## Troubleshooting

### Edge Config Not Updating
**Issue**: Traffic split not taking effect
**Solution**: Ensure Edge Config is properly linked to your project:
```bash
vercel env ls
# Verify EDGE_CONFIG environment variable is set
```

### Canary Health Check Failing
**Issue**: HTTP 5xx errors on canary
**Solution**:
1. Check Vercel deployment logs: `vercel logs <canary-url>`
2. Identify error cause
3. Rollback immediately: `./scripts/rollback-canary.sh vercel my-ecommerce-app`
4. Fix issues before re-deploying

### Sticky Sessions Not Working
**Issue**: Users switching between canary and production
**Solution**: Verify middleware is correctly setting cookies (see `templates/vercel-middleware-canary.ts`)

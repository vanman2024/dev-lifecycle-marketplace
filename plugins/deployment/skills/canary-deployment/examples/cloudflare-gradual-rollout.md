# Example: Automated Gradual Rollout on Cloudflare Workers

This example demonstrates an automated multi-stage canary rollout for a Cloudflare Worker with continuous health monitoring and automatic rollback capabilities.

## Scenario

**Project**: REST API for mobile app backend
**Platform**: Cloudflare Workers
**Change**: Database query optimization and caching layer
**Risk Level**: Medium-High
**Strategy**: Automated gradual rollout with 5% → 25% → 50% → 100% stages

## Prerequisites

- Cloudflare Worker already deployed
- Wrangler CLI installed and authenticated
- KV namespace created for canary state
- Traffic splitting Worker deployed (see `templates/cloudflare-worker-canary.js`)

## Architecture

```
User Request → Traffic Splitting Worker → {
  - Stable Worker (my-api-stable)
  - Canary Worker (my-api-canary)
}
```

The traffic splitting Worker reads canary state from KV and routes requests accordingly.

## Step 1: Deploy Initial Canary

Deploy the new Worker version as canary:

```bash
cd /path/to/worker

# Deploy canary with 5% traffic
./scripts/canary-deploy-cloudflare.sh . 5
```

**Expected Output**:
```
🚀 Starting Cloudflare Canary Deployment
   Project: /path/to/worker
   Canary Traffic: 5%

📦 Detected worker name: my-api
🔍 Checking for stable worker...
✅ Stable worker found: my-api-stable

📦 Deploying canary worker...
✅ Canary worker deployed: my-api-canary

✅ Stable URL: https://my-api-stable.workers.dev
✅ Canary URL: https://my-api-canary.workers.dev

💾 Storing canary state in KV...
✅ Canary state stored in KV

📊 Deployment Summary:
   Stable:  https://my-api-stable.workers.dev
   Canary:  https://my-api-canary.workers.dev
   Traffic: 5% to canary, 95% to stable
```

## Step 2: Verify KV State

Check that canary state is stored correctly:

```bash
# Get canary state from KV
wrangler kv:key get --namespace-id=<namespace-id> canary-state
```

**Expected Output**:
```json
{
  "enabled": true,
  "percentage": 5,
  "canaryWorker": "my-api-canary",
  "stableWorker": "my-api-stable",
  "canaryUrl": "https://my-api-canary.workers.dev",
  "stableUrl": "https://my-api-stable.workers.dev",
  "deployedAt": "2025-11-05T19:00:00Z"
}
```

## Step 3: Start Automated Gradual Rollout

Execute the automated gradual rollout with standard schedule:

```bash
# Standard schedule: 5% → 25% → 50% → 100% (15 min intervals)
./scripts/gradual-rollout.sh cloudflare my-api standard
```

**Expected Output**:
```
🚀 Starting Gradual Canary Rollout
   Platform: cloudflare
   Project: my-api
   Schedule: standard
   Error Threshold: 5%

📋 Rollout Plan:
   Stage 1: 5% traffic → wait 15 minutes
   Stage 2: 25% traffic → wait 15 minutes
   Stage 3: 50% traffic → wait 15 minutes
   Stage 4: 100% traffic → complete

═══════════════════════════════════════
Stage 1: Deploying 5% canary traffic
═══════════════════════════════════════

⚠️  Manual step: Update KV canary-state to 5% traffic
📊 Stage 1: 5% canary traffic deployed for my-api

⏱️  Waiting 60 seconds for traffic to stabilize...
🏥 Running health check at 5% canary traffic...
✅ Health check passed: Error rate 1%

⏱️  Waiting 15 minutes before next stage...
   Monitoring canary health during wait period

🔍 Health check (60/900 seconds)...
✅ Health check passed: Error rate 2%

🔍 Health check (120/900 seconds)...
✅ Health check passed: Error rate 1%

... (continues monitoring every 60 seconds)

🔍 Health check (900/900 seconds)...
✅ Health check passed: Error rate 2%

✅ Stage 1 stable for 15 minutes

═══════════════════════════════════════
Stage 2: Deploying 25% canary traffic
═══════════════════════════════════════

⚠️  Manual step: Update KV canary-state to 25% traffic
📊 Stage 2: 25% canary traffic deployed for my-api

⏱️  Waiting 60 seconds for traffic to stabilize...
🏥 Running health check at 25% canary traffic...
✅ Health check passed: Error rate 3%

⏱️  Waiting 15 minutes before next stage...
   Monitoring canary health during wait period

... (continues monitoring)

✅ Stage 2 stable for 15 minutes

═══════════════════════════════════════
Stage 3: Deploying 50% canary traffic
═══════════════════════════════════════

... (similar output)

═══════════════════════════════════════
Stage 4: Deploying 100% canary traffic
═══════════════════════════════════════

⚠️  Manual step: Update KV canary-state to 100% traffic
📊 Stage 4: 100% canary traffic deployed for my-api

⏱️  Waiting 60 seconds for traffic to stabilize...
🏥 Running health check at 100% canary traffic...
✅ Health check passed: Error rate 2%

═══════════════════════════════════════
✅ Gradual Rollout Complete!
═══════════════════════════════════════

📊 Final Status:
   Platform: cloudflare
   Project: my-api
   Stages Completed: 4
   Final Traffic: 100% canary

✅ Canary is now production!
```

## Step 4: Update KV at Each Stage

The script prompts for manual KV updates. Automate with:

```bash
# Stage 1: 5% traffic
echo '{"enabled":true,"percentage":5,"canaryWorker":"my-api-canary","stableWorker":"my-api-stable"}' | \
  wrangler kv:key put --namespace-id=<namespace-id> canary-state --path=-

# Stage 2: 25% traffic
echo '{"enabled":true,"percentage":25,"canaryWorker":"my-api-canary","stableWorker":"my-api-stable"}' | \
  wrangler kv:key put --namespace-id=<namespace-id> canary-state --path=-

# Stage 3: 50% traffic
echo '{"enabled":true,"percentage":50,"canaryWorker":"my-api-canary","stableWorker":"my-api-stable"}' | \
  wrangler kv:key put --namespace-id=<namespace-id> canary-state --path=-

# Stage 4: 100% traffic
echo '{"enabled":true,"percentage":100,"canaryWorker":"my-api-canary","stableWorker":"my-api-stable"}' | \
  wrangler kv:key put --namespace-id=<namespace-id> canary-state --path=-
```

## Step 5: Monitor with Cloudflare Analytics

During rollout, monitor in Cloudflare Dashboard:

**Analytics Dashboard** (https://dash.cloudflare.com/analytics):
- Worker invocations by version
- Error rates
- CPU time
- Duration (latency)
- Request count

**KV Analytics**:
- Read operations
- Write operations
- State updates

## Rollout Timeline

```
19:00 - Deploy canary (5% traffic)
19:01 - Health check passed
19:02-19:15 - Monitor continuously (all checks pass)
19:15 - Increase to 25% traffic
19:16 - Health check passed
19:17-19:30 - Monitor continuously (all checks pass)
19:30 - Increase to 50% traffic
19:31 - Health check passed
19:32-19:45 - Monitor continuously (all checks pass)
19:45 - Increase to 100% traffic
19:46 - Health check passed
19:47 - Rollout complete
```

**Total Duration**: 47 minutes

## Automatic Rollback Example

If health checks fail during rollout, automatic rollback triggers:

```
═══════════════════════════════════════
Stage 2: Deploying 25% canary traffic
═══════════════════════════════════════

🏥 Running health check at 25% canary traffic...
❌ Health check failed: Error rate 7% > threshold 5%

🔍 Health check (120/900 seconds)...
❌ Health check failed: Error rate 8% > threshold 5%

❌ Health degraded during stage 2
   Initiating rollback...

↩️  Starting Canary Rollback
   Platform: cloudflare
   Project: my-api

🔍 Verifying stable worker...
✅ Stable worker: my-api-stable

💾 Disabling canary in KV...
✅ Canary disabled in KV

🔄 Routing all traffic to stable worker...
✅ Rollback complete!
   All traffic routed to: my-api-stable

📝 Rollback logged
```

## Results

**Successful Rollout**:
- 4 stages completed without issues
- Continuous health monitoring at each stage
- Error rates remained < 5% throughout
- Latency improved by 15% (query optimization working)
- Zero downtime during rollout

**Key Metrics**:
- Total rollout time: 47 minutes
- Stages monitored: 4
- Health checks performed: ~48 (every 60 seconds)
- Health check failures: 0
- Rollback triggers: 0

## Comparison: Before vs After

**Before Canary Deployment**:
- Average latency: 120ms
- P95 latency: 350ms
- Error rate: 0.5%

**After 100% Canary**:
- Average latency: 102ms (-15%)
- P95 latency: 295ms (-16%)
- Error rate: 0.4%

Database query optimization successful!

## Best Practices Demonstrated

1. **Automated Rollout**: No manual intervention required (except KV updates)
2. **Continuous Monitoring**: Health checks every 60 seconds
3. **Automatic Rollback**: Immediate reversion on health degradation
4. **Progressive Stages**: Risk minimized with gradual traffic increase
5. **Observability**: Complete audit trail in KV and logs

## Alternative Schedules

### Fast Rollout (Low Risk)
```bash
# 10% → 50% → 100% (5 min intervals)
./scripts/gradual-rollout.sh cloudflare my-api fast
```
**Total Duration**: ~15 minutes

### Safe Rollout (High Risk)
```bash
# 5% → 10% → 25% → 50% → 75% → 100% (30 min intervals)
./scripts/gradual-rollout.sh cloudflare my-api safe
```
**Total Duration**: ~2.5 hours

### Custom Rollout
```bash
# Custom stages: 5%, 15%, 35%, 65%, 100%
ROLLOUT_STAGES="5,15,35,65,100" STAGE_WAIT_TIME=600 \
  ./scripts/gradual-rollout.sh cloudflare my-api custom
```
**Total Duration**: ~40 minutes (10 min per stage)

## Troubleshooting

### KV Namespace Not Found
**Issue**: Worker can't read canary state
**Solution**:
```bash
# Create KV namespace
wrangler kv:namespace create CANARY_STATE

# Update wrangler.toml with namespace ID
# [[kv_namespaces]]
# binding = "CANARY_STATE"
# id = "<namespace-id>"

# Redeploy Worker
wrangler deploy
```

### Traffic Not Splitting
**Issue**: All traffic going to stable
**Solution**:
1. Verify canary state in KV: `wrangler kv:key get canary-state`
2. Check traffic splitting Worker logs: `wrangler tail my-api`
3. Ensure Worker correctly implements routing logic

### High Error Rate During Rollout
**Issue**: Error rate spikes to 8%
**Solution**:
1. Automatic rollback will trigger
2. Check Worker logs for errors
3. Identify root cause (database connection, API timeout, etc.)
4. Fix issues before re-deploying
5. Consider using "safe" schedule for retry

## Next Steps

After successful rollout:
1. **Promote Canary to Stable**: Rename `my-api-canary` → `my-api-stable`
2. **Clean Up**: Delete old stable Worker
3. **Update Documentation**: Record rollout metrics and learnings
4. **Disable Canary Mode**: Update KV to disable canary routing

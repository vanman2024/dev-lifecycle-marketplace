---
name: canary-deployment
description: Vercel and Cloudflare canary deployment patterns with traffic splitting, gradual rollout automation, and rollback strategies. Use when deploying with canary releases, implementing progressive rollouts, managing traffic splitting, configuring A/B deployments, or when user mentions canary deployment, blue-green deployment, gradual rollout, traffic shifting, or deployment rollback.
allowed-tools: Bash, Read, Write, Edit
---

# Canary Deployment Skill

This skill provides comprehensive canary deployment capabilities for Vercel and Cloudflare platforms, enabling gradual traffic shifting, deployment validation, and automated rollback strategies.

## Overview

Canary deployment is a progressive rollout strategy that reduces deployment risk by gradually shifting traffic from the stable version to the new version. This skill covers:

1. **Traffic Splitting** - Configure percentage-based traffic routing between versions
2. **Gradual Rollout** - Automated progressive traffic increase (5% → 25% → 50% → 100%)
3. **Health Monitoring** - Real-time metrics and error rate tracking during rollout
4. **Automated Rollback** - Instant reversion if error thresholds are exceeded
5. **A/B Testing Integration** - Use canary deployments for controlled experiments

## Supported Platforms

### Vercel
- **Edge Config** for traffic splitting rules
- **Deployment Protection** for staged rollouts
- **Analytics Integration** for real-time monitoring
- **Instant Rollback** via deployment promotion/demotion

### Cloudflare
- **Workers** for traffic splitting logic
- **KV Storage** for deployment state
- **Analytics Engine** for metrics collection
- **Gradual Rollout** via route weight configuration

## Available Scripts

### 1. Canary Deploy to Vercel

**Script**: `scripts/canary-deploy-vercel.sh <project-path> <canary-percentage>`

**Purpose**: Deploy new version to Vercel and configure canary traffic split

**Actions**:
- Validates Vercel CLI authentication
- Deploys new version to preview environment
- Creates Edge Config for traffic splitting
- Configures percentage-based routing rules
- Monitors deployment health metrics
- Provides rollback command if needed

**Usage**:
```bash
# Deploy with 10% canary traffic
./scripts/canary-deploy-vercel.sh /path/to/app 10

# Deploy with 25% canary traffic
./scripts/canary-deploy-vercel.sh /path/to/app 25

# Skip health check (for testing)
SKIP_HEALTH_CHECK=true ./scripts/canary-deploy-vercel.sh /path/to/app 10

# Use custom project name
PROJECT_NAME=my-app ./scripts/canary-deploy-vercel.sh /path/to/app 10
```

**Environment Variables**:
- `VERCEL_TOKEN`: Vercel authentication token (required)
- `VERCEL_ORG_ID`: Organization ID (optional for personal accounts)
- `PROJECT_NAME`: Custom project name (auto-detected if not set)
- `SKIP_HEALTH_CHECK`: Set to `true` to skip initial health validation

**Exit Codes**:
- `0`: Canary deployment successful
- `1`: Deployment failed or validation errors

### 2. Canary Deploy to Cloudflare

**Script**: `scripts/canary-deploy-cloudflare.sh <project-path> <canary-percentage>`

**Purpose**: Deploy new version to Cloudflare Workers and configure traffic split

**Actions**:
- Validates Cloudflare credentials (API token, account ID)
- Deploys new Worker version
- Updates KV storage with deployment metadata
- Configures route weights for traffic splitting
- Sets up analytics tracking
- Monitors error rates and latency

**Usage**:
```bash
# Deploy with 10% canary traffic
./scripts/canary-deploy-cloudflare.sh /path/to/worker 10

# Deploy with custom worker name
WORKER_NAME=my-worker ./scripts/canary-deploy-cloudflare.sh /path/to/worker 15

# Skip route update (manual routing)
SKIP_ROUTES=true ./scripts/canary-deploy-cloudflare.sh /path/to/worker 20
```

**Environment Variables**:
- `CLOUDFLARE_API_TOKEN`: Cloudflare API token (required)
- `CLOUDFLARE_ACCOUNT_ID`: Account ID (required)
- `WORKER_NAME`: Custom worker name (auto-detected from wrangler.toml)
- `SKIP_ROUTES`: Set to `true` to skip automatic route configuration

**Exit Codes**:
- `0`: Canary deployment successful
- `1`: Deployment failed or credential errors

### 3. Gradual Rollout

**Script**: `scripts/gradual-rollout.sh <platform> <project-name> <schedule>`

**Purpose**: Automate progressive traffic increase according to schedule

**Actions**:
- Executes multi-stage rollout plan (e.g., 5% → 25% → 50% → 100%)
- Monitors health metrics at each stage
- Automatic rollback if error rate exceeds threshold
- Configurable wait time between stages
- Sends notifications at each stage

**Rollout Schedules**:
- `fast`: 10% → 50% → 100% (5 min intervals)
- `standard`: 5% → 25% → 50% → 100% (15 min intervals)
- `safe`: 5% → 10% → 25% → 50% → 75% → 100% (30 min intervals)
- `custom`: Custom stages via environment variable

**Usage**:
```bash
# Standard rollout to Vercel
./scripts/gradual-rollout.sh vercel my-app standard

# Fast rollout to Cloudflare
./scripts/gradual-rollout.sh cloudflare my-worker fast

# Safe rollout with monitoring
./scripts/gradual-rollout.sh vercel my-app safe

# Custom rollout schedule
ROLLOUT_STAGES="5,15,35,65,100" ./scripts/gradual-rollout.sh vercel my-app custom

# Custom error threshold (default: 5%)
ERROR_THRESHOLD=3 ./scripts/gradual-rollout.sh vercel my-app standard
```

**Environment Variables**:
- `ROLLOUT_STAGES`: Comma-separated percentage stages for custom schedule
- `STAGE_WAIT_TIME`: Minutes to wait between stages (default varies by schedule)
- `ERROR_THRESHOLD`: Error rate percentage triggering automatic rollback (default: 5)
- `SLACK_WEBHOOK`: Slack webhook URL for notifications (optional)

**Exit Codes**:
- `0`: Rollout completed successfully
- `1`: Rollout failed or rollback triggered
- `2`: Health check failure during rollout

### 4. Rollback Canary

**Script**: `scripts/rollback-canary.sh <platform> <project-name>`

**Purpose**: Instantly rollback canary deployment to previous stable version

**Actions**:
- Identifies current canary and stable deployments
- Routes 100% traffic back to stable version
- Updates Edge Config or Worker routes
- Captures rollback event for audit trail
- Preserves canary deployment for investigation

**Usage**:
```bash
# Rollback Vercel deployment
./scripts/rollback-canary.sh vercel my-app

# Rollback Cloudflare Worker
./scripts/rollback-canary.sh cloudflare my-worker

# Rollback and delete canary
DELETE_CANARY=true ./scripts/rollback-canary.sh vercel my-app

# Rollback with notification
SLACK_WEBHOOK=your_webhook_url_here ./scripts/rollback-canary.sh vercel my-app
```

**Environment Variables**:
- `DELETE_CANARY`: Set to `true` to delete canary deployment after rollback
- `SLACK_WEBHOOK`: Slack webhook URL for rollback notifications

**Exit Codes**:
- `0`: Rollback successful
- `1`: Rollback failed
- `2`: Unable to identify stable version

### 5. Monitor Canary

**Script**: `scripts/monitor-canary.sh <platform> <project-name>`

**Purpose**: Real-time monitoring of canary deployment health metrics

**Actions**:
- Fetches error rates, latency, and request volume
- Compares canary metrics vs stable version
- Alerts if metrics exceed threshold
- Logs metrics history for analysis
- Provides rollback recommendation if needed

**Usage**:
```bash
# Monitor Vercel deployment (runs continuously)
./scripts/monitor-canary.sh vercel my-app

# Monitor with custom interval
MONITOR_INTERVAL=30 ./scripts/monitor-canary.sh cloudflare my-worker

# One-time health check
ONE_SHOT=true ./scripts/monitor-canary.sh vercel my-app

# Monitor with custom error threshold
ERROR_THRESHOLD=3 ./scripts/monitor-canary.sh vercel my-app
```

**Environment Variables**:
- `MONITOR_INTERVAL`: Seconds between health checks (default: 60)
- `ERROR_THRESHOLD`: Error rate percentage triggering alert (default: 5)
- `ONE_SHOT`: Set to `true` for single health check instead of continuous monitoring

**Exit Codes**:
- `0`: Metrics within acceptable range
- `1`: Metrics exceed threshold (rollback recommended)

## Available Templates

### 1. Vercel Edge Config

**File**: `templates/vercel-edge-config.json`

**Purpose**: Edge Config template for traffic splitting rules

**Features**:
- Percentage-based traffic routing
- Deployment version tracking
- Rollout state management
- Feature flag integration

**Template Variables**:
- `{{CANARY_PERCENTAGE}}`: Traffic percentage for canary (0-100)
- `{{CANARY_DEPLOYMENT_URL}}`: Canary deployment URL
- `{{STABLE_DEPLOYMENT_URL}}`: Stable deployment URL
- `{{ROLLOUT_STAGE}}`: Current rollout stage identifier

### 2. Cloudflare Worker Canary Logic

**File**: `templates/cloudflare-worker-canary.js`

**Purpose**: Cloudflare Worker with traffic splitting logic

**Features**:
- Request-based routing algorithm
- Sticky sessions with cookies
- A/B testing support
- Analytics integration
- Automatic failover

**Template Variables**:
- `{{CANARY_PERCENTAGE}}`: Traffic percentage for canary
- `{{CANARY_WORKER_NAME}}`: Name of canary worker
- `{{STABLE_WORKER_NAME}}`: Name of stable worker
- `{{KV_NAMESPACE}}`: KV namespace for state storage

### 3. Vercel Middleware Canary

**File**: `templates/vercel-middleware-canary.ts`

**Purpose**: Next.js middleware for canary traffic splitting

**Features**:
- Edge runtime execution
- Cookie-based sticky sessions
- Geographic routing support
- Custom routing rules

**Template Variables**:
- `{{CANARY_PERCENTAGE}}`: Traffic percentage for canary
- `{{CANARY_REWRITE_URL}}`: URL to rewrite canary traffic to
- `{{ENABLE_STICKY_SESSIONS}}`: Enable/disable sticky sessions

### 4. Health Check Configuration

**File**: `templates/health-check-config.json`

**Purpose**: Health check thresholds and monitoring configuration

**Features**:
- Error rate thresholds
- Latency limits
- Request volume requirements
- Rollback trigger rules

**Template Variables**:
- `{{ERROR_RATE_THRESHOLD}}`: Max error rate percentage (default: 5)
- `{{LATENCY_P95_THRESHOLD}}`: Max P95 latency in ms (default: 1000)
- `{{MIN_REQUEST_VOLUME}}`: Minimum requests before validation (default: 100)

### 5. Rollout Schedule Configuration

**File**: `templates/rollout-schedule.json`

**Purpose**: Predefined and custom rollout schedule templates

**Schedules**:
- Fast: 10% → 50% → 100% (5 min intervals)
- Standard: 5% → 25% → 50% → 100% (15 min intervals)
- Safe: 5% → 10% → 25% → 50% → 75% → 100% (30 min intervals)

**Template Variables**:
- `{{SCHEDULE_NAME}}`: Schedule identifier (fast/standard/safe/custom)
- `{{STAGES}}`: Array of percentage stages
- `{{WAIT_TIMES}}`: Array of wait times between stages

### 6. Cloudflare KV Schema

**File**: `templates/cloudflare-kv-schema.json`

**Purpose**: KV storage schema for deployment state

**Data Structure**:
- Deployment metadata (versions, URLs, timestamps)
- Traffic split configuration
- Health check results
- Rollback history

## Available Examples

### 1. Basic Canary Deployment

**File**: `examples/vercel-basic-canary.md`

**Purpose**: Simple canary deployment to Vercel with 10% traffic

**Demonstrates**:
- Initial canary deployment
- Health monitoring
- Manual traffic adjustment
- Rollback procedure

### 2. Automated Gradual Rollout

**File**: `examples/cloudflare-gradual-rollout.md`

**Purpose**: Automated multi-stage rollout to Cloudflare Workers

**Demonstrates**:
- Configuring rollout schedule
- Automated stage progression
- Health check integration
- Automatic rollback on errors

### 3. A/B Testing with Canary

**File**: `examples/ab-testing-canary.md`

**Purpose**: Using canary deployments for A/B experiments

**Demonstrates**:
- Feature flag integration
- User segmentation
- Metrics collection
- Experiment analysis

### 4. Multi-Region Canary

**File**: `examples/multi-region-rollout.md`

**Purpose**: Progressive rollout across geographic regions

**Demonstrates**:
- Region-based traffic splitting
- Staged regional rollout
- Cross-region failover
- Global traffic management

## Deployment Workflows

### Initial Canary Deployment

```bash
# Step 1: Deploy canary with 10% traffic
./scripts/canary-deploy-vercel.sh /path/to/app 10

# Step 2: Monitor health for 15 minutes
./scripts/monitor-canary.sh vercel my-app

# Step 3: If healthy, proceed with gradual rollout
./scripts/gradual-rollout.sh vercel my-app standard

# Step 4: If issues detected, rollback immediately
./scripts/rollback-canary.sh vercel my-app
```

### Automated Gradual Rollout

```bash
# Deploy canary and execute automated rollout
./scripts/canary-deploy-vercel.sh /path/to/app 5 && \
./scripts/gradual-rollout.sh vercel my-app standard

# Rollout proceeds automatically:
# - 5% → wait 15 min → health check
# - 25% → wait 15 min → health check
# - 50% → wait 15 min → health check
# - 100% → complete

# Automatic rollback if error rate > 5% at any stage
```

### Emergency Rollback

```bash
# Instant rollback to stable version
./scripts/rollback-canary.sh vercel my-app

# Rollback completes in seconds:
# - Traffic routed 100% to stable
# - Canary deployment preserved for debugging
# - Audit trail logged
```

## Best Practices

### Traffic Split Strategy

1. **Start Small**: Begin with 5-10% canary traffic
2. **Progressive Increase**: Double traffic at each stage (5% → 10% → 25% → 50% → 100%)
3. **Minimum Dwell Time**: Wait at least 15 minutes at each stage
4. **Monitor Continuously**: Track error rates, latency, and request volume

### Health Check Thresholds

1. **Error Rate**: Rollback if > 5% above baseline
2. **Latency P95**: Rollback if > 2x baseline
3. **Request Volume**: Require minimum 100 requests for validation
4. **Comparison Window**: Compare last 5 minutes canary vs last 15 minutes stable

### Rollback Triggers

**Automatic Rollback When**:
- Error rate exceeds threshold for 2 consecutive checks
- P95 latency > 2x baseline for 3 consecutive checks
- Critical alert from monitoring system
- Manual trigger via rollback script

**Preserve Canary After Rollback**:
- Keep deployment for investigation
- Analyze logs and metrics
- Identify root cause before re-deploying

### Monitoring and Alerting

1. **Real-Time Dashboards**: Vercel Analytics or Cloudflare Analytics
2. **Alert Channels**: Slack, PagerDuty, or email notifications
3. **Metric Collection**: Log all health checks to external system
4. **Audit Trail**: Record all deployment and rollback events

## Platform-Specific Features

### Vercel

**Edge Config Advantages**:
- Ultra-low latency routing decisions (<1ms)
- Global propagation in seconds
- No code deployment required for traffic changes
- Native Next.js middleware integration

**Deployment Protection**:
- Preview deployments isolated from production
- Instant promotion/demotion
- Automatic HTTPS and DNS management

**Analytics Integration**:
- Real-time request metrics
- Error tracking by deployment
- Custom event tracking

### Cloudflare

**Workers Advantages**:
- Edge compute in 300+ locations
- Sub-millisecond routing logic
- KV storage for persistent state
- Analytics Engine for detailed metrics

**Gradual Rollout**:
- Route weight configuration
- Version-based routing
- A/B testing support

**Durable Objects** (Advanced):
- Stateful canary coordination
- Cross-region synchronization
- Consistent traffic splitting

## Security Considerations

1. **API Token Storage**: Always use environment variables, never hardcode
2. **Access Control**: Limit deployment permissions to authorized users
3. **Audit Logging**: Record all deployment and rollback actions
4. **Secrets Management**: Use platform secret stores (Vercel Secrets, Cloudflare Secrets)
5. **Preview Protection**: Password-protect canary deployments if needed

## Troubleshooting

### Vercel Edge Config Not Updating

```bash
# Check Edge Config status
vercel env ls

# Verify Edge Config connection
# Check middleware.ts has correct Edge Config import

# Force refresh
vercel env pull
```

### Cloudflare Worker Routing Issues

```bash
# Check Worker routes
wrangler routes list

# Verify KV namespace binding
wrangler kv:namespace list

# Test Worker directly
curl https://my-worker.workers.dev
```

### Gradual Rollout Stuck

```bash
# Check monitor process status
ps aux | grep monitor-canary

# View rollout logs
tail -f /tmp/gradual-rollout-*.log

# Manual stage progression
./scripts/canary-deploy-vercel.sh /path/to/app 50
```

### Health Check False Positives

```bash
# Increase error threshold temporarily
ERROR_THRESHOLD=8 ./scripts/monitor-canary.sh vercel my-app

# Adjust latency threshold
LATENCY_THRESHOLD=2000 ./scripts/monitor-canary.sh vercel my-app

# Require more requests before validation
MIN_REQUESTS=500 ./scripts/monitor-canary.sh vercel my-app
```

## Cost Considerations

### Vercel
- **Free Tier**: 100GB bandwidth, sufficient for small canaries
- **Pro Tier**: $20/month, required for Edge Config in production
- **Edge Config**: Included in Pro tier
- **Additional Bandwidth**: $40/TB

### Cloudflare
- **Free Tier**: 100k requests/day on Workers
- **Paid Tier**: $5/month for 10M requests
- **KV Storage**: $0.50/GB/month
- **Analytics Engine**: Included in paid tier

## Integration with Dev Lifecycle

This skill integrates with:
- `/deployment:deploy` - Execute canary deployment strategy
- `/deployment:validate` - Pre-deployment health check validation
- `/deployment:rollback` - Emergency rollback orchestration
- Deployment agents for automated canary management

## Platform CLI Commands Reference

### Vercel

```bash
# Edge Config management
vercel env add EDGE_CONFIG
vercel env pull

# Deployment management
vercel list
vercel inspect <url>
vercel promote <url>
vercel rollback
```

### Cloudflare

```bash
# Worker deployment
wrangler publish
wrangler tail

# KV management
wrangler kv:namespace create <name>
wrangler kv:key put <key> <value>
wrangler kv:key get <key>

# Route management
wrangler routes list
wrangler routes add <route> <worker>
```

## Requirements

- Vercel CLI (`npm install -g vercel`) for Vercel deployments
- Cloudflare Wrangler CLI (`npm install -g wrangler`) for Cloudflare deployments
- Valid authentication tokens stored as environment variables
- Project must be deployed at least once before canary rollout
- Monitoring tools or analytics configured for health checks

---

**Skill Location**: /home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/canary-deployment/
**Version**: 1.0.0

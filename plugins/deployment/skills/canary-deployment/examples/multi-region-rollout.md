# Example: Multi-Region Canary Rollout

This example demonstrates a sophisticated canary deployment strategy that progressively rolls out across geographic regions, minimizing global impact while validating changes regionally.

## Scenario

**Project**: Global e-commerce platform
**Platform**: Vercel + Cloudflare (hybrid approach)
**Change**: Payment processing API integration update
**Risk Level**: High
**Regions**: US-West → US-East → Europe → Asia-Pacific
**Strategy**: Progressive regional rollout with 24-hour soak time per region

## Use Case

For globally distributed applications serving users across multiple regions, a single global canary deployment may expose too many users to potential issues. Regional rollout allows:

- **Risk Isolation**: Issues contained to single region
- **Regional Validation**: Test performance in each region's network conditions
- **Timezone Optimization**: Deploy during low-traffic hours per region
- **Compliance**: Address region-specific requirements progressively

## Architecture

```
User Request → Edge Network Router → {
  US-West:  [Canary ←→ Stable]
  US-East:  [Canary ←→ Stable]
  Europe:   [Canary ←→ Stable]
  APAC:     [Canary ←→ Stable]
}
```

## Prerequisites

- Multi-region deployment capability (Vercel Edge Network or Cloudflare Workers)
- Geographic routing configuration
- Regional monitoring and alerting
- Rollback automation per region

## Step 1: Deploy Global Canary

First, deploy the canary version globally but with routing disabled:

```bash
cd /path/to/ecommerce-app

# Deploy canary (not routed yet)
./scripts/canary-deploy-vercel.sh . 0
```

**Result**: Canary deployed but receives 0% traffic globally.

## Step 2: Configure Regional Edge Config

Create Edge Config with regional routing rules:

```json
{
  "canary": {
    "enabled": true,
    "globalPercentage": 0,
    "canaryUrl": "https://ecommerce-app-canary.vercel.app",
    "productionUrl": "https://ecommerce-app.vercel.app",
    "deployedAt": "2025-11-05T08:00:00Z"
  },
  "regionalRollout": {
    "enabled": true,
    "currentRegion": "us-west",
    "schedule": [
      {
        "region": "us-west",
        "percentage": 100,
        "startTime": "2025-11-05T08:00:00Z",
        "soakTime": "24h",
        "status": "in-progress"
      },
      {
        "region": "us-east",
        "percentage": 0,
        "startTime": "2025-11-06T08:00:00Z",
        "soakTime": "24h",
        "status": "pending"
      },
      {
        "region": "eu",
        "percentage": 0,
        "startTime": "2025-11-07T08:00:00Z",
        "soakTime": "24h",
        "status": "pending"
      },
      {
        "region": "apac",
        "percentage": 0,
        "startTime": "2025-11-08T08:00:00Z",
        "soakTime": "24h",
        "status": "pending"
      }
    ]
  }
}
```

## Step 3: Enhanced Middleware with Regional Routing

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';
import { get } from '@vercel/edge-config';

export async function middleware(request: NextRequest) {
  const config = await get<CanaryConfig>('canary');
  const regionalConfig = await get<RegionalRollout>('regionalRollout');

  if (!config || !regionalConfig?.enabled) {
    return NextResponse.next();
  }

  // Get user's region from Vercel geolocation
  const userRegion = getUserRegion(request.geo);

  // Find regional configuration
  const regionConfig = regionalConfig.schedule.find(
    r => r.region === userRegion && r.status === 'in-progress'
  );

  // If user's region not in active rollout, use production
  if (!regionConfig || regionConfig.percentage === 0) {
    return NextResponse.next();
  }

  // Check sticky session
  const variantCookie = request.cookies.get('regional_variant');

  let shouldUseCanary: boolean;

  if (variantCookie?.value === 'canary') {
    shouldUseCanary = true;
  } else if (variantCookie?.value === 'stable') {
    shouldUseCanary = false;
  } else {
    // New user - route based on regional percentage
    shouldUseCanary = Math.random() < (regionConfig.percentage / 100);
  }

  // Route to canary or production
  const response = shouldUseCanary
    ? NextResponse.rewrite(new URL(config.canaryUrl))
    : NextResponse.next();

  // Set sticky session cookie
  response.cookies.set({
    name: 'regional_variant',
    value: shouldUseCanary ? 'canary' : 'stable',
    maxAge: 7 * 24 * 60 * 60,
    httpOnly: true,
    secure: true,
  });

  // Add regional headers
  response.headers.set('X-User-Region', userRegion);
  response.headers.set('X-Regional-Rollout', regionConfig.region);
  response.headers.set('X-Canary-Percentage', String(regionConfig.percentage));

  return response;
}

function getUserRegion(geo: NextRequest['geo']): string {
  const country = geo?.country;

  // Map countries to regions
  if (['US', 'CA', 'MX'].includes(country || '')) {
    const region = geo?.region;
    // Differentiate US-West vs US-East
    if (country === 'US') {
      const westStates = ['CA', 'OR', 'WA', 'NV', 'AZ'];
      return westStates.includes(region || '') ? 'us-west' : 'us-east';
    }
    return 'us-west'; // Canada/Mexico default to US-West
  }

  if (['GB', 'FR', 'DE', 'ES', 'IT', 'NL', 'BE', 'CH', 'AT'].includes(country || '')) {
    return 'eu';
  }

  if (['JP', 'CN', 'KR', 'SG', 'AU', 'NZ', 'IN'].includes(country || '')) {
    return 'apac';
  }

  return 'us-east'; // Default fallback
}

interface CanaryConfig {
  enabled: boolean;
  canaryUrl: string;
  productionUrl: string;
}

interface RegionalRollout {
  enabled: boolean;
  currentRegion: string;
  schedule: Array<{
    region: string;
    percentage: number;
    startTime: string;
    soakTime: string;
    status: 'pending' | 'in-progress' | 'completed' | 'rolled-back';
  }>;
}
```

## Regional Rollout Timeline

### Day 1: US-West Region (Nov 5, 08:00 PST)

**08:00 PST** - Enable canary for US-West:

```bash
# Update Edge Config to enable US-West region
# Set us-west percentage to 100%, status to 'in-progress'
```

**08:05 PST** - Monitor US-West metrics:

```
Region: US-West
Traffic: 100% canary
Sessions: 2,341 (morning low-traffic period)
Error Rate: 0.3% (baseline: 0.2%)
Latency P95: 245ms (baseline: 240ms)
Payment Success Rate: 98.7% (baseline: 98.5%)

Status: ✅ Healthy
```

**12:00 PST** - Midday check:

```
Region: US-West
Sessions: 12,456
Error Rate: 0.2%
Latency P95: 238ms
Payment Success Rate: 98.8%

Status: ✅ Healthy - performing better than baseline
```

**20:00 PST** - Evening peak check:

```
Region: US-West
Sessions: 34,789
Error Rate: 0.3%
Latency P95: 252ms
Payment Success Rate: 98.6%

Status: ✅ Healthy - stable through peak traffic
```

**Decision**: US-West rollout successful, proceed to US-East

### Day 2: US-East Region (Nov 6, 08:00 EST)

**08:00 EST** - Enable canary for US-East:

```bash
# Update Edge Config
# Set us-west status to 'completed'
# Set us-east percentage to 100%, status to 'in-progress'
```

**Results After 24 Hours**:

```
Region: US-East
Total Sessions: 45,678
Error Rate: 0.25%
Latency P95: 228ms (improved!)
Payment Success Rate: 98.9%

Status: ✅ Healthy
```

**US-West Still Monitored**:

```
Region: US-West (Day 2)
Sessions: 38,123
Error Rate: 0.2%
Status: ✅ Stable
```

**Decision**: US-East rollout successful, proceed to Europe

### Day 3: Europe Region (Nov 7, 08:00 CET)

**08:00 CET** - Enable canary for Europe:

```bash
# Update Edge Config
# Set us-east status to 'completed'
# Set eu percentage to 100%, status to 'in-progress'
```

**Results After 24 Hours**:

```
Region: Europe
Total Sessions: 28,934
Error Rate: 0.3%
Latency P95: 198ms (EU edge location optimized)
Payment Success Rate: 98.7%

Status: ✅ Healthy
```

**Decision**: Europe rollout successful, proceed to APAC

### Day 4: APAC Region (Nov 8, 08:00 JST)

**08:00 JST** - Enable canary for APAC:

```bash
# Update Edge Config
# Set eu status to 'completed'
# Set apac percentage to 100%, status to 'in-progress'
```

**Results After 24 Hours**:

```
Region: APAC
Total Sessions: 19,456
Error Rate: 0.2%
Latency P95: 189ms
Payment Success Rate: 98.9%

Status: ✅ Healthy
```

### Day 5: Global Rollout Complete (Nov 9)

All regions successfully on canary version:

```
Global Summary:
- US-West: ✅ Completed (120k sessions)
- US-East: ✅ Completed (145k sessions)
- Europe:  ✅ Completed (95k sessions)
- APAC:    ✅ Completed (67k sessions)

Total Sessions: 427k
Overall Error Rate: 0.25% (baseline: 0.3%)
Overall Payment Success: 98.8%
Zero rollbacks required

Status: ✅ Global rollout successful
```

## Regional Rollback Scenario

**Hypothetical**: Europe rollout encounters issues

**Day 3, 14:00 CET** - Alert triggered:

```
Region: Europe
Error Rate: 8.2% (threshold: 5%)
Payment Failures: 15.3%
Root Cause: Regional payment processor integration issue

Decision: Rollback Europe region immediately
```

**Rollback Procedure**:

```bash
# Update Edge Config - disable EU canary
# Set eu percentage to 0%, status to 'rolled-back'

# Europe traffic immediately routes to stable version
# Other regions (US-West, US-East) remain on canary
```

**Rollback Results**:

```
14:05 CET - Rollback initiated
14:06 CET - Edge Config propagated globally
14:07 CET - Europe traffic on stable version

Europe Impact:
- Duration: 6 hours on faulty version
- Affected Sessions: ~7,000
- Other regions: Unaffected

Action: Fix payment processor issue for EU region
```

**After Fix**:

```bash
# Re-deploy EU-specific fix
# Re-enable EU canary after validation

# Day 4, 08:00 CET - Retry Europe rollout
# Set eu percentage to 100%, status to 'in-progress'
```

## Monitoring Dashboard

**Regional Health Overview**:

```
╔════════════════════════════════════════════════════╗
║        Multi-Region Canary Dashboard               ║
╠════════════════════════════════════════════════════╣
║ Region    │ Status      │ Traffic │ Error Rate    ║
╠═══════════╪═════════════╪═════════╪═══════════════╣
║ US-West   │ ✅ Complete │ Canary  │ 0.2%         ║
║ US-East   │ ✅ Complete │ Canary  │ 0.25%        ║
║ Europe    │ 🟡 Active   │ Canary  │ 0.3%         ║
║ APAC      │ ⏸️  Pending  │ Stable  │ 0.25%        ║
╚═══════════╧═════════════╧═════════╧═══════════════╝
```

## Best Practices for Regional Rollout

1. **Deploy During Low Traffic**: Start regional rollout during off-peak hours
2. **24-Hour Soak Time**: Allow full daily cycle for each region
3. **Regional Isolation**: Issues in one region don't affect others
4. **Timezone Awareness**: Schedule rollouts during optimal local times
5. **Regional Monitoring**: Track metrics separately per region
6. **Fast Regional Rollback**: Ability to rollback single region instantly

## Cost Considerations

**Vercel**:
- Edge Config: $20/mo (Pro plan)
- Multi-region traffic: No additional cost (included)
- Extended monitoring: ~5 days vs 1 day for global canary

**Benefit**: Reduced global risk justifies extended timeline

## Results Summary

**Timeline**: 5 days (vs 1 day for global canary)
**Total Sessions**: 427k across all regions
**Rollbacks**: 0 (or 1 if Europe scenario occurred)
**Risk Exposure**: Maximum 25% of global traffic at any time
**Outcome**: Successful global rollout with minimal risk

Multi-region canary deployment provided confidence through progressive regional validation!

## Alternative Strategies

### Parallel Regional Rollout

Deploy to multiple regions simultaneously (higher risk):

```json
{
  "regionalRollout": {
    "parallel": true,
    "regions": {
      "us-west": { "percentage": 50 },
      "us-east": { "percentage": 50 },
      "eu": { "percentage": 0 },
      "apac": { "percentage": 0 }
    }
  }
}
```

### Gradual Regional Percentage

Progressive percentage increase per region:

```
US-West:  10% → 50% → 100% (over 24 hours)
US-East:  10% → 50% → 100% (next 24 hours)
Europe:   10% → 50% → 100% (next 24 hours)
APAC:     10% → 50% → 100% (next 24 hours)
```

Total duration: 4 days with intra-regional gradual rollout

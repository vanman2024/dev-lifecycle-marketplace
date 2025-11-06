# Example: A/B Testing with Canary Deployments

This example demonstrates using canary deployments for controlled A/B experiments, enabling data-driven decisions before full rollout.

## Scenario

**Project**: SaaS dashboard application
**Platform**: Vercel (Next.js)
**Experiment**: New dashboard layout with redesigned navigation
**Goal**: Compare user engagement metrics between old and new designs
**Duration**: 7 days with 50/50 traffic split
**Decision Criteria**: Conversion rate, time on page, bounce rate

## Use Case

Traditional canary deployments focus on error rates and performance. A/B testing canaries focus on **business metrics** to validate feature effectiveness before full rollout.

## Architecture

```
User Request → Middleware → {
  - Variant A (Production): Current dashboard layout
  - Variant B (Canary): New dashboard layout
}
                    ↓
              Analytics Tracking
                    ↓
        Business Metrics Collection
```

## Prerequisites

- Next.js app with analytics integration (Vercel Analytics, Google Analytics, or Mixpanel)
- Feature flag system (optional, but recommended)
- User segmentation capability
- Conversion tracking configured

## Step 1: Deploy A/B Test Canary

Deploy the new dashboard design as canary with 50% traffic:

```bash
cd /path/to/dashboard-app

# Deploy with 50/50 split for A/B testing
./scripts/canary-deploy-vercel.sh . 50
```

**Expected Output**:
```
🚀 Starting Vercel Canary Deployment
   Project: /path/to/dashboard-app
   Canary Traffic: 50%

📦 Detected project name: saas-dashboard
✅ Current production: https://saas-dashboard.vercel.app
✅ Canary deployed: https://saas-dashboard-abc456.vercel.app

📊 Deployment Summary:
   Production (Variant A): https://saas-dashboard.vercel.app
   Canary (Variant B):     https://saas-dashboard-abc456.vercel.app
   Traffic:                50% to each variant
```

## Step 2: Configure Edge Config for A/B Testing

Update Edge Config with A/B testing metadata:

```json
{
  "canary": {
    "enabled": true,
    "percentage": 50,
    "canaryUrl": "https://saas-dashboard-abc456.vercel.app",
    "productionUrl": "https://saas-dashboard.vercel.app",
    "deployedAt": "2025-11-05T20:00:00Z",
    "stage": "ab-test"
  },
  "features": {
    "stickySession": true,
    "geoRouting": false,
    "abTesting": true
  },
  "experiment": {
    "name": "dashboard-redesign-v2",
    "hypothesis": "New dashboard layout will increase user engagement by 20%",
    "startDate": "2025-11-05T20:00:00Z",
    "endDate": "2025-11-12T20:00:00Z",
    "variants": {
      "control": {
        "name": "Current Dashboard",
        "url": "https://saas-dashboard.vercel.app",
        "traffic": 50
      },
      "treatment": {
        "name": "New Dashboard Layout",
        "url": "https://saas-dashboard-abc456.vercel.app",
        "traffic": 50
      }
    },
    "metrics": {
      "primary": "conversion_rate",
      "secondary": ["time_on_page", "bounce_rate", "feature_adoption"]
    }
  }
}
```

## Step 3: Enhanced Middleware with Analytics Tracking

Update middleware to track variant assignments:

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';
import { get } from '@vercel/edge-config';

export async function middleware(request: NextRequest) {
  const config = await get<CanaryConfig>('canary');

  if (!config || !config.enabled) {
    return NextResponse.next();
  }

  // Check for existing variant assignment (sticky session)
  const variantCookie = request.cookies.get('experiment_variant');

  let variant: 'control' | 'treatment';
  let shouldUseCanary: boolean;

  if (variantCookie) {
    // User already assigned to variant
    variant = variantCookie.value as 'control' | 'treatment';
    shouldUseCanary = variant === 'treatment';
  } else {
    // New user - randomly assign to variant (50/50 split)
    shouldUseCanary = Math.random() < (config.percentage / 100);
    variant = shouldUseCanary ? 'treatment' : 'control';
  }

  // Create response
  const response = shouldUseCanary
    ? NextResponse.rewrite(new URL(config.canaryUrl))
    : NextResponse.next();

  // Set variant assignment cookie (sticky session)
  response.cookies.set({
    name: 'experiment_variant',
    value: variant,
    maxAge: 7 * 24 * 60 * 60, // 7 days
    httpOnly: true,
    secure: true,
    sameSite: 'lax',
  });

  // Add analytics headers
  response.headers.set('X-Experiment-Name', 'dashboard-redesign-v2');
  response.headers.set('X-Experiment-Variant', variant);
  response.headers.set('X-Canary-Version', shouldUseCanary ? 'canary' : 'stable');

  return response;
}

interface CanaryConfig {
  enabled: boolean;
  percentage: number;
  canaryUrl: string;
  productionUrl: string;
  features?: {
    stickySession?: boolean;
    abTesting?: boolean;
  };
}
```

## Step 4: Track Business Metrics

Integrate with analytics to track variant performance:

```typescript
// app/layout.tsx or analytics component
import { useEffect } from 'react';
import { usePathname } from 'next/navigation';
import { analytics } from '@/lib/analytics';

export function AnalyticsProvider({ children }) {
  const pathname = usePathname();

  useEffect(() => {
    // Get variant from cookie
    const variant = document.cookie
      .split('; ')
      .find(row => row.startsWith('experiment_variant='))
      ?.split('=')[1];

    // Track page view with variant
    analytics.page({
      variant: variant || 'unknown',
      experiment: 'dashboard-redesign-v2',
      path: pathname,
    });

    // Track variant exposure (user saw this variant)
    analytics.track('Experiment Viewed', {
      experiment: 'dashboard-redesign-v2',
      variant: variant || 'unknown',
    });
  }, [pathname]);

  return <>{children}</>;
}
```

## Step 5: Monitor A/B Test Metrics

### Daily Metrics Review

**Day 1** (Nov 5, 2025):
```
Variant A (Control):
  - Sessions: 5,234
  - Conversion Rate: 12.3%
  - Avg Time on Page: 3:45
  - Bounce Rate: 42%

Variant B (Treatment):
  - Sessions: 5,189
  - Conversion Rate: 14.8% (+20%)
  - Avg Time on Page: 4:12 (+12%)
  - Bounce Rate: 38% (-10%)
```

**Day 3** (Nov 7, 2025):
```
Variant A (Control):
  - Sessions: 15,678
  - Conversion Rate: 12.1%
  - Avg Time on Page: 3:42
  - Bounce Rate: 43%

Variant B (Treatment):
  - Sessions: 15,542
  - Conversion Rate: 15.2% (+26%)
  - Avg Time on Page: 4:18 (+16%)
  - Bounce Rate: 37% (-14%)

Statistical Significance: 95% (sufficient for decision)
```

**Day 7** (Nov 12, 2025) - Final Results:
```
Variant A (Control):
  - Sessions: 36,789
  - Conversion Rate: 12.0%
  - Avg Time on Page: 3:43
  - Bounce Rate: 42%
  - Revenue per Session: $4.20

Variant B (Treatment):
  - Sessions: 36,512
  - Conversion Rate: 15.4% (+28%)
  - Avg Time on Page: 4:21 (+17%)
  - Bounce Rate: 36% (-14%)
  - Revenue per Session: $5.35 (+27%)

Statistical Significance: 99%
Winner: Variant B (Treatment)
```

## Step 6: Decision and Full Rollout

Based on 7 days of data, Variant B (new dashboard) significantly outperforms:

**Decision**: Proceed with full rollout to 100% of users

```bash
# Promote canary to 100% traffic
./scripts/canary-deploy-vercel.sh . 100

# Or use gradual rollout
./scripts/gradual-rollout.sh vercel saas-dashboard fast
```

## Step 7: Cleanup After Experiment

Once at 100% canary:

1. **Update Production**: Make canary the new production
2. **Remove Experiment Tracking**: Clean up experiment cookies and headers
3. **Archive Results**: Document experiment results and learnings
4. **Disable A/B Config**: Update Edge Config to disable experiment mode

```json
{
  "canary": {
    "enabled": false,
    "percentage": 0
  },
  "experiment": {
    "name": "dashboard-redesign-v2",
    "status": "completed",
    "winner": "treatment",
    "results": {
      "conversionRateIncrease": 28,
      "revenueImpact": 27,
      "statisticalSignificance": 99
    }
  }
}
```

## Alternative Scenarios

### Negative Results (Variant B Loses)

If Variant B underperforms:

```
Day 3 Results:
Variant B (Treatment):
  - Conversion Rate: 10.8% (-11%)
  - Bounce Rate: 48% (+14%)

Decision: Rollback immediately, keep Variant A
```

```bash
# Immediate rollback
./scripts/rollback-canary.sh vercel saas-dashboard
```

### Neutral Results (No Clear Winner)

If results are statistically insignificant after 7 days:

```
Day 7 Results:
Variant B (Treatment):
  - Conversion Rate: 12.3% (+2.5%)
  - Statistical Significance: 60% (insufficient)

Decision: Extend test to 14 days or increase traffic
```

## User Segmentation A/B Testing

**Advanced**: Test with specific user segments

```typescript
// middleware.ts - Enhanced with segmentation
export async function middleware(request: NextRequest) {
  const userId = request.cookies.get('user_id')?.value;
  const userTier = await getUserTier(userId);

  // Only test with premium users
  if (userTier !== 'premium') {
    return NextResponse.next(); // Control group only
  }

  // Premium users get A/B test
  const shouldUseCanary = Math.random() < 0.5;
  // ... rest of logic
}
```

## Best Practices for A/B Testing Canaries

1. **Sticky Sessions**: Essential for accurate metrics (user sees same variant throughout experiment)
2. **Statistical Significance**: Wait for 95%+ confidence before making decisions
3. **Minimum Duration**: Run for at least 7 days to capture weekly patterns
4. **Sample Size**: Ensure sufficient traffic (>1000 conversions per variant)
5. **Single Metric Focus**: Choose one primary metric to optimize for
6. **Document Everything**: Record hypothesis, results, and learnings

## Metrics Tracking Checklist

✅ Variant assignment tracked in cookie
✅ Variant exposure logged in analytics
✅ Page views tracked by variant
✅ Conversions tracked by variant
✅ Time on page tracked by variant
✅ Bounce rate tracked by variant
✅ Revenue tracked by variant
✅ Statistical significance calculated
✅ Results documented

## Integration with Popular Analytics

### Vercel Analytics
```typescript
import { track } from '@vercel/analytics';

track('Experiment Viewed', {
  experiment: 'dashboard-redesign-v2',
  variant: variant,
});
```

### Google Analytics
```typescript
gtag('event', 'experiment_impression', {
  experiment_id: 'dashboard-redesign-v2',
  variant_id: variant,
});
```

### Mixpanel
```typescript
mixpanel.track('Experiment Viewed', {
  experiment: 'dashboard-redesign-v2',
  variant: variant,
});
```

## Cost Considerations

**Vercel**:
- Edge Config: Included in Pro ($20/mo)
- Additional bandwidth: Minimal impact for A/B testing
- Analytics: $10/mo for advanced features

**Estimated Total**: $20-30/month for A/B testing infrastructure

## Results Summary

**Investment**: 7 days, 50/50 traffic split
**Outcome**: +28% conversion rate, +27% revenue per session
**Decision**: Full rollout of new dashboard design
**ROI**: Projected $50k/month additional revenue

A/B testing with canary deployments enabled data-driven decision-making with minimal risk!

# Platform Recommendation Flow

This document explains the decision tree and scoring logic used to recommend deployment platforms.

## Overview

Platform recommendation uses a multi-criteria scoring algorithm that considers:
1. Project type (MCP server, API, frontend, static site)
2. Framework detected (FastMCP, Next.js, FastAPI, etc.)
3. Configuration files (Dockerfile, build scripts)
4. Special requirements (serverless, edge computing, containerization)

## Decision Tree

```
┌─────────────────────────────────────┐
│    Detect Project Type              │
│  (MCP, API, Frontend, Static, etc.) │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Detect Framework                 │
│  (FastMCP, Next.js, FastAPI, etc.)  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Analyze Configuration            │
│  (Docker, build scripts, configs)   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Calculate Platform Scores        │
│  (Apply routing rules & weights)    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Filter by Threshold              │
│  (Remove platforms below minimum)   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Select Highest Score             │
│  (Use priority as tiebreaker)       │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Return Recommendation            │
│  (Platform name + reasoning)        │
└─────────────────────────────────────┘
```

## Scoring Algorithm

### Base Scores (from platform-routing-rules.json)

Each platform has routing rules with base scores for project types:

**FastMCP Cloud**:
- `mcp-server`: 100 points
- Others: 0 points

**DigitalOcean**:
- `api`: 90 points
- `mcp-server`: 85 points
- `monorepo`: 70 points

**Vercel**:
- `frontend`: 100 points
- `static-site`: 60 points

**Netlify**:
- `static-site`: 90 points
- `frontend`: 75 points

**Cloudflare Pages**:
- `static-site`: 95 points
- `frontend`: 70 points

### Framework Bonuses

Additional points based on framework detection:

**FastMCP Cloud**:
- FastMCP (Python): +100
- FastMCP (TypeScript): +100

**Vercel**:
- Next.js: +100
- Astro: +90
- Nuxt.js: +90
- React (Vite): +85

**DigitalOcean**:
- FastAPI: +85
- Flask: +85
- Django: +85
- Express: +85

### Feature Bonuses

**Docker Support** (+20 for DigitalOcean):
- Detects Dockerfile in project root
- Prioritizes container-based platforms

**Serverless Functions** (+10 for Vercel/Netlify):
- Detects serverless function patterns
- API routes in Next.js
- Functions directory in Netlify

**Static Only** (+15 for Cloudflare Pages):
- No server-side dependencies
- Pure HTML/CSS/JS

## Example Calculations

### Example 1: Next.js Application

**Input**:
- Project Type: `frontend`
- Framework: `Next.js 14.2.0`
- Has Dockerfile: `false`
- Has Serverless: `true`

**Calculation**:

**Vercel**:
```
Base (frontend):       100
Framework (Next.js):   100
Serverless bonus:       10
─────────────────────────
Total:                 210
```

**Netlify**:
```
Base (frontend):        75
Framework (Next.js):    70
Serverless bonus:       10
─────────────────────────
Total:                 155
```

**Cloudflare Pages**:
```
Base (frontend):        70
Framework (Next.js):    70
─────────────────────────
Total:                 140
```

**Result**: Vercel (210 points) - Highest score, optimized for Next.js

---

### Example 2: FastAPI Backend with Docker

**Input**:
- Project Type: `api`
- Framework: `FastAPI 0.110.0`
- Has Dockerfile: `true`
- Has Serverless: `false`

**Calculation**:

**DigitalOcean**:
```
Base (api):            90
Framework (FastAPI):   85
Docker bonus:          20
─────────────────────────
Total:                195
```

**Vercel**:
```
Base (api):             0  (no API base score)
Framework (FastAPI):    0  (not supported)
─────────────────────────
Total:                  0  (below threshold)
```

**Result**: DigitalOcean (195 points) - Docker support + API specialization

---

### Example 3: FastMCP Server

**Input**:
- Project Type: `mcp-server`
- Framework: `FastMCP (Python) 1.0.0`
- Has .mcp.json: `true`

**Calculation**:

**FastMCP Cloud**:
```
Base (mcp-server):        100
Framework (FastMCP):      100
Required file bonus:       10
─────────────────────────────
Total:                    210
```

**DigitalOcean**:
```
Base (mcp-server):         85
Framework (custom):         0
─────────────────────────────
Total:                     85
```

**Result**: FastMCP Cloud (210 points) - Purpose-built for FastMCP

---

### Example 4: Static HTML Site

**Input**:
- Project Type: `static-site`
- Framework: `unknown`
- Has package.json: `false`
- Static only: `true`

**Calculation**:

**Cloudflare Pages**:
```
Base (static-site):        95
Static-only bonus:         15
─────────────────────────────
Total:                    110
```

**Netlify**:
```
Base (static-site):        90
─────────────────────────────
Total:                     90
```

**Vercel**:
```
Base (static-site):        60
─────────────────────────────
Total:                     60
```

**Result**: Cloudflare Pages (110 points) - Best CDN for simple static sites

---

## Tiebreaker Rules

When multiple platforms have the same score, use **priority** values:

1. **Priority 1** (Highest): FastMCP Cloud, Vercel
2. **Priority 2**: DigitalOcean, Netlify
3. **Priority 3**: Cloudflare Pages
4. **Priority 4** (Lowest): Hostinger

### Tiebreaker Example

**Input**: Astro site with SSR disabled

**Scores**:
- Vercel: 175 (frontend: 100, Astro: 85, serverless: -10)
- Netlify: 175 (static: 90, Astro: 85)

**Priority**:
- Vercel: Priority 1
- Netlify: Priority 2

**Result**: Vercel wins due to higher priority

---

## Special Cases

### Case 1: Monorepo

**Detection**: Multiple package.json or workspace configuration

**Recommendation**: `multiple-platforms`

**Strategy**:
```bash
# Analyze each service independently
for service in apps/*; do
    platform=$(bash recommend-platform.sh "$service")
    echo "$service -> $platform"
done
```

### Case 2: Unknown Framework with Docker

**Detection**: No recognized framework, but has Dockerfile

**Recommendation**: DigitalOcean

**Reasoning**: Container support handles any application

### Case 3: Next.js with Custom Backend

**Detection**: Next.js + API routes + separate backend

**Options**:
1. **Single platform (Vercel)**: Deploy everything to Vercel with API routes
2. **Dual platform**: Frontend to Vercel, Backend to DigitalOcean

**Decision factors**:
- API complexity
- Database requirements
- Scaling needs

### Case 4: Hybrid Rendering (Astro)

**Config Detection**:
```javascript
// astro.config.mjs
export default defineConfig({
  output: 'server'  // SSR mode
});
```

**Recommendation**: Vercel or Netlify (both support SSR)

**vs**:

```javascript
export default defineConfig({
  output: 'static'  // Static mode
});
```

**Recommendation**: Cloudflare Pages (optimized for static)

---

## Platform Comparison Matrix

| Platform | MCP | API | Frontend | Static | Docker | Cost |
|----------|-----|-----|----------|--------|--------|------|
| **FastMCP Cloud** | ⭐⭐⭐ | ❌ | ❌ | ❌ | ✓ | $$$ |
| **DigitalOcean** | ⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐ | ✓ | $$ |
| **Vercel** | ❌ | ⭐ | ⭐⭐⭐ | ⭐⭐ | ❌ | $-$$$ |
| **Netlify** | ❌ | ❌ | ⭐⭐ | ⭐⭐⭐ | ❌ | $-$$ |
| **Cloudflare** | ❌ | ❌ | ⭐⭐ | ⭐⭐⭐ | ❌ | $ |
| **Hostinger** | ❌ | ❌ | ⭐ | ⭐⭐ | ❌ | $ |

**Legend**:
- ⭐⭐⭐ = Excellent (optimized)
- ⭐⭐ = Good (supported)
- ⭐ = Basic (possible)
- ❌ = Not supported
- $ = Low cost, $$$ = High cost

---

## Customizing Recommendations

### Override Platform Selection

```bash
#!/bin/bash
# custom-recommendation.sh

# Get default recommendation
DEFAULT=$(bash recommend-platform.sh .)

# Apply custom logic
if [ "$DEFAULT" = "vercel" ] && [ "$REQUIRE_DOCKER" = "true" ]; then
    echo "digitalocean"  # Override to support Docker
    echo "REASON: Custom requirement for Docker support" >&2
else
    echo "$DEFAULT"
fi
```

### Add Custom Scoring Rules

Edit `templates/platform-routing-rules.json`:

```json
{
  "platforms": {
    "custom-platform": {
      "name": "Custom Platform",
      "routing_rules": {
        "project_type": {
          "api": 95
        },
        "custom_requirement": {
          "true": 50
        }
      },
      "priority": 1,
      "match_threshold": 100
    }
  }
}
```

---

## Validation After Recommendation

Always validate the recommended platform:

```bash
PLATFORM=$(bash recommend-platform.sh .)

# Validate requirements
if bash validate-platform-requirements.sh . "$PLATFORM"; then
    echo "✓ Ready to deploy to $PLATFORM"
else
    echo "✗ Platform validation failed"
    echo "Consider alternative platform or fix requirements"
fi
```

---

## Next Steps

- See `basic-detection.md` for simple examples
- See `integration-with-deploy-commands.md` for automation
- See `error-handling.md` for troubleshooting failed recommendations

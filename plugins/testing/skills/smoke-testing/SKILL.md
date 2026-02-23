---
name: Smoke Testing
description: Health endpoint and critical path smoke testing patterns. Use when running quick validation tests, checking health endpoints, verifying critical paths respond correctly, or when user mentions smoke testing, health checks, quick validation, sanity checks.
---

# Smoke Testing

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Provides scripts, templates, and patterns for smoke testing - quick validation that critical endpoints and pages are responding correctly before running full test suites.

## Instructions

### 1. What is Smoke Testing?

Smoke tests are the fastest, most basic tests that verify:
- The application starts and responds
- Health check endpoints return 200
- Critical user-facing pages load without errors
- Key API endpoints are reachable

They run before unit/integration/E2E tests to catch deployment failures early.

### 2. Running Smoke Tests

**Full smoke test orchestrator:**
```bash
bash scripts/run-smoke-tests.sh [base-url] [project-path]
```

**Individual checks:**
```bash
bash scripts/check-health-endpoint.sh [health-url]
bash scripts/verify-critical-paths.sh [base-url] [paths-file]
```

### 3. Configuration

Smoke test configuration lives in `.claude/project.json`:
```json
{
  "testing": {
    "smoke": {
      "health_endpoint": "/api/health",
      "critical_paths": ["/", "/login", "/dashboard"],
      "base_url": "http://localhost:3000",
      "timeout_seconds": 10
    }
  }
}
```

Or use a standalone config file:
```json
// smoke-test-config.json
{
  "base_url": "http://localhost:3000",
  "health_endpoint": "/api/health",
  "timeout_seconds": 10,
  "critical_paths": [
    { "path": "/", "expected_status": 200 },
    { "path": "/login", "expected_status": 200 },
    { "path": "/api/health", "expected_status": 200, "expected_body": "ok" }
  ]
}
```

### 4. Health Check Endpoint Patterns

**Next.js App Router:**
```typescript
// src/app/api/health/route.ts
export async function GET() {
  return Response.json({ status: 'ok', timestamp: new Date().toISOString() })
}
```

**Express:**
```javascript
app.get('/health', (req, res) => {
  res.json({ status: 'ok' })
})
```

**FastAPI:**
```python
@app.get("/health")
async def health():
    return {"status": "ok"}
```

**Go:**
```go
http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
})
```

### 5. CI/CD Integration

Smoke tests should run:
- After deployment to verify the deploy succeeded
- Before E2E tests as a gating check
- On every PR as a quick validation

## Available Scripts

1. **run-smoke-tests.sh** - Orchestrator that runs all smoke checks
2. **check-health-endpoint.sh** - Hit a health endpoint and verify response
3. **verify-critical-paths.sh** - Verify critical pages respond with 200

## Available Templates

1. **smoke-test-config.json** - Configuration file template
2. **health-check-test.sh** - Reusable health check function

## Available Examples

1. **basic-smoke-test.md** - Simple health check smoke test
2. **critical-path-smoke.md** - Testing critical user paths
3. **ci-smoke-integration.md** - Adding smoke tests to CI pipeline

## Requirements

- `curl` for HTTP requests
- `jq` for JSON parsing (optional)
- Running application server (or ability to start one)

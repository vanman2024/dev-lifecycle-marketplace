# Basic Smoke Test Example

## Scenario

Verify a Next.js application is running and responding after deployment.

## Steps

### 1. Check Health Endpoint

```bash
bash scripts/check-health-endpoint.sh http://localhost:3000/api/health
```

Output:
```
Checking health: http://localhost:3000/api/health (timeout: 10s)
PASS: Health endpoint returned 200
Response: {"status":"ok","timestamp":"2024-01-15T10:30:00Z"}
```

### 2. Verify Homepage

```bash
bash scripts/verify-critical-paths.sh http://localhost:3000 /
```

Output:
```
Verifying 1 critical paths against http://localhost:3000

  PASS: / -> 200

Results: 1/1 passed, 0/1 failed
```

### 3. Full Smoke Suite

```bash
bash scripts/run-smoke-tests.sh http://localhost:3000
```

Output:
```
=== Smoke Tests ===
Base URL: http://localhost:3000

--- Health Check: /api/health ---
  PASS: /api/health -> 200

--- Critical Paths ---
  PASS: / -> 200
  PASS: /login -> 200

=== Smoke Test Results ===
Passed: 3 / 3
Failed: 0 / 3
```

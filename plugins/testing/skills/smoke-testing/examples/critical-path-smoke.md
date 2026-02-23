# Critical Path Smoke Test Example

## Scenario

Verify all critical user paths are accessible for an e-commerce application.

## Configuration

In `.claude/project.json`:
```json
{
  "testing": {
    "smoke": {
      "health_endpoint": "/api/health",
      "critical_paths": [
        "/",
        "/products",
        "/cart",
        "/login",
        "/signup",
        "/api/products"
      ]
    }
  }
}
```

## Running

```bash
bash scripts/run-smoke-tests.sh http://localhost:3000
```

## Expected Output

```
=== Smoke Tests ===
Base URL: http://localhost:3000

--- Health Check: /api/health ---
  PASS: /api/health -> 200

--- Critical Paths ---
  PASS: / -> 200
  PASS: /products -> 200
  PASS: /cart -> 302        # Redirects to login (expected)
  PASS: /login -> 200
  PASS: /signup -> 200
  PASS: /api/products -> 200

=== Smoke Test Results ===
Passed: 7 / 7
Failed: 0 / 7
```

## Notes

- 301/302 redirects are treated as PASS (expected for auth-protected pages)
- Add more critical paths as the application grows
- Run smoke tests before E2E tests as a gating check

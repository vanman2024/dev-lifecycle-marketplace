# CI Smoke Test Integration Example

## GitHub Actions Workflow

```yaml
name: Smoke Tests

on:
  deployment_status:

jobs:
  smoke-test:
    if: github.event.deployment_status.state == 'success'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run smoke tests
        run: |
          DEPLOY_URL="${{ github.event.deployment_status.target_url }}"
          bash plugins/testing/skills/smoke-testing/scripts/run-smoke-tests.sh "$DEPLOY_URL"

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: smoke-test-results
          path: test-results/smoke/
```

## Post-Deploy Smoke Test

Add to existing deploy workflow:

```yaml
  deploy:
    # ... deployment steps ...

  smoke-test:
    needs: deploy
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Wait for deployment
        run: sleep 30

      - name: Health check
        run: |
          bash plugins/testing/skills/smoke-testing/scripts/check-health-endpoint.sh \
            "https://my-app.vercel.app/api/health"

      - name: Critical paths
        run: |
          bash plugins/testing/skills/smoke-testing/scripts/verify-critical-paths.sh \
            "https://my-app.vercel.app" / /login /dashboard
```

## Gating E2E Tests

Run smoke tests before E2E to fail fast:

```yaml
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Start app
        run: npm start &

      - name: Wait for ready
        run: npx wait-on http://localhost:3000/api/health --timeout 60000

      - name: Smoke tests (gate)
        run: bash plugins/testing/skills/smoke-testing/scripts/run-smoke-tests.sh

      - name: E2E tests (only if smoke passes)
        run: npx playwright test
```

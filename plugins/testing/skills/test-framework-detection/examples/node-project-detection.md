# Node.js Project Detection Example

## Scenario

A Next.js project with Vitest for unit tests and Playwright for E2E.

## Input

**package.json** (relevant parts):
```json
{
  "scripts": {
    "test": "vitest",
    "test:e2e": "playwright test"
  },
  "devDependencies": {
    "vitest": "^2.0.0",
    "@vitest/coverage-v8": "^2.0.0",
    "@playwright/test": "^1.45.0",
    "@testing-library/react": "^16.0.0",
    "@ai-sdk/openai": "^1.0.0"
  }
}
```

**Files present:**
- `vitest.config.ts`
- `playwright.config.ts`
- `.github/workflows/test.yml`

## Running Detection

```bash
bash scripts/detect-test-frameworks.sh /path/to/project
```

## Output

```
=== Test Framework Detection ===
Project: /path/to/project

[+] Detected: Node.js project (package.json)

--- Running node detector ---
  [+] Vitest: HIGH confidence (dep + config)
  [+] Test command: vitest
  [+] Playwright E2E: HIGH confidence (dep + config)
  [+] Coverage: v8/c8

--- Running CI workflow detector ---
  [+] GitHub Actions workflows directory found
    [+] Test workflow: test.yml
      - Unit tests
      - E2E tests
      - Coverage reporting

[+] AI framework detected in package.json

=== Detection Complete ===
```

## Result in project.json

```json
{
  "testing": {
    "unit": {
      "framework": "vitest",
      "config": "vitest.config.ts",
      "command": "npm run test"
    },
    "api_contract": {
      "framework": null,
      "collections": [],
      "auth_strategy": "none"
    },
    "e2e": {
      "framework": "playwright",
      "config": "playwright.config.ts"
    },
    "smoke": {
      "health_endpoint": null,
      "critical_paths": []
    },
    "coverage": {
      "tool": "v8",
      "threshold": 80
    },
    "ci_workflows": [".github/workflows/test.yml"],
    "ai_detected": true,
    "llm_evals_plugin": "llm-evals"
  }
}
```

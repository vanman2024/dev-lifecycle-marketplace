# Multi-Stack Project Detection Example

## Scenario

A monorepo with a Node.js frontend and Go backend.

## Input

**Root structure:**
```
project/
├── frontend/
│   ├── package.json          # Next.js + Vitest
│   ├── vitest.config.ts
│   └── playwright.config.ts
├── backend/
│   ├── go.mod                # Go + testify
│   └── handler_test.go
├── .github/
│   └── workflows/
│       ├── frontend-tests.yml
│       └── backend-tests.yml
└── package.json              # Root workspace
```

## Running Detection

```bash
bash scripts/detect-test-frameworks.sh /path/to/project
```

## Output

```
=== Test Framework Detection ===
Project: /path/to/project

[+] Detected: Node.js project (package.json)
[+] Detected: Go project (go.mod)

--- Running node detector ---
  [+] Vitest: HIGH confidence (dep + config)
  [+] Playwright E2E: HIGH confidence (dep + config)
  [+] Coverage: v8 (vitest default)

--- Running go detector ---
  [+] go test: HIGH confidence (test files found)
  [+] testify: detected as test helper library

--- Running CI workflow detector ---
  [+] GitHub Actions workflows directory found
    [+] Test workflow: frontend-tests.yml
      - Unit tests
      - E2E tests
    [+] Test workflow: backend-tests.yml
      - Unit tests
      - Coverage reporting

=== Detection Complete ===
```

## Notes

- In multi-stack projects, detection aggregates across all languages
- The `unit` key in project.json reflects the primary stack
- CI workflow detection captures all test workflows regardless of language
- Each sub-project may need its own test configuration

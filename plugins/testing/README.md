# Testing Plugin

Comprehensive testing wizard: auto-detection, generation, and execution across unit, smoke, API contract, and E2E testing for any tech stack.

## Overview

The testing plugin provides a complete testing lifecycle:
1. **Detect** what test frameworks your project uses
2. **Generate** tests for uncovered code
3. **Run** tests across all layers (unit -> smoke -> API -> E2E)
4. **Generate CI** pipelines to automate testing

Works with any language: JavaScript/TypeScript, Python, Go, Rust.

## Commands

| Command | Description |
|---------|-------------|
| `/testing:test [scope]` | Run tests (unit, smoke, api, e2e, or all) |
| `/testing:test-frontend` | Run frontend-specific tests (component, visual, a11y, performance) |
| `/testing:generate-tests [path]` | Generate test suites for uncovered code |
| `/testing:generate-ci` | Generate GitHub Actions test workflow |

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `test-framework-detector` | haiku | Detect test frameworks, coverage tools, CI config |
| `test-runner` | inherit | Execute tests across all frameworks with aggregation |
| `test-generator` | inherit | Generate unit/integration tests (any language) |
| `test-suite-generator` | inherit | Generate complete test suites from package.json analysis |
| `frontend-test-generator` | inherit | Generate React/Next.js component, visual, a11y, and performance tests |

## Skills

| Skill | Purpose |
|-------|---------|
| `test-framework-detection` | Detection scripts for Jest, Vitest, pytest, go test, cargo test, CI workflows |
| `smoke-testing` | Health endpoint and critical path validation |
| `api-contract-testing` | OpenAPI -> Portman -> Newman pipeline with auth injection |
| `newman-runner` | Newman test execution and analysis |
| `playwright-e2e` | Playwright E2E testing patterns and page objects |
| `frontend-testing` | Frontend component, visual regression, a11y, performance testing |

## Usage

### Quick Start

```bash
# Run all tests (auto-detects frameworks on first run)
/testing:test

# Run specific test type
/testing:test unit
/testing:test e2e
/testing:test smoke
/testing:test api

# Generate tests for uncovered code
/testing:generate-tests

# Generate CI pipeline
/testing:generate-ci
```

### Testing Pyramid

Tests run in pyramid order for fastest feedback:

```
          /\
         /E2E\        <- Slowest, most comprehensive
        /------\
       /  API   \     <- Contract tests with Newman
      /----------\
     /   Smoke    \   <- Quick health checks
    /--------------\
   /    Unit Tests  \  <- Fastest, most numerous
  /------------------\
```

### Framework Detection

On first run, the plugin auto-detects your testing setup:

| Language | Frameworks Detected |
|----------|-------------------|
| Node.js/TS | Vitest, Jest, Mocha, AVA, Playwright, Cypress |
| Python | pytest, unittest, nose2, coverage.py |
| Go | go test, testify, gomock |
| Rust | cargo test, criterion, tarpaulin |

Detection results are stored in `.claude/project.json` under the `testing` key.

### API Contract Testing

Full pipeline from OpenAPI spec to tested collection:

```bash
# 1. Convert OpenAPI to Postman collection
bash plugins/testing/skills/api-contract-testing/scripts/openapi-to-collection.sh openapi.yaml

# 2. Inject auth strategy
bash plugins/testing/skills/api-contract-testing/scripts/inject-auth.sh collection.json supabase_cookie

# 3. Run tests
bash plugins/testing/skills/api-contract-testing/scripts/run-api-contract-tests.sh collection.json
```

Supported auth strategies: `supabase_cookie`, `clerk_jwt`, `auth0_token`, `bearer_token`, `api_key`.

### CI-Awareness

The plugin detects existing CI workflows and avoids duplication:
- Scans `.github/workflows/` for test-related workflows
- `/testing:generate-ci` only creates jobs for test types NOT already in CI
- Use `--force` to regenerate everything

### AI Framework Detection

When AI frameworks are detected (Vercel AI SDK, LangChain, OpenAI, etc.):
- Unit/E2E tests focus on **deterministic behavior** (loading states, error handling, UI rendering)
- LLM output quality testing is deferred to the `llm-evals` plugin
- Run `/llm-evals:add promptfoo` for prompt regression testing

## Dependencies

- **Required**: curl, jq, bash
- **Unit tests**: Framework-specific (vitest, jest, pytest, etc.)
- **API tests**: Newman (`npm install -g newman`)
- **E2E tests**: Playwright (`npm install -D @playwright/test`)
- **OpenAPI pipeline**: Portman (`npm install -g @apideck/portman`)

## Configuration

Testing configuration in `.claude/project.json`:

```json
{
  "testing": {
    "unit": { "framework": "vitest", "config": "vitest.config.ts", "command": "npm run test" },
    "api_contract": { "framework": "newman", "collections": [], "auth_strategy": "supabase_cookie" },
    "e2e": { "framework": "playwright", "config": "playwright.config.ts" },
    "smoke": { "health_endpoint": "/api/health", "critical_paths": ["/", "/login"] },
    "coverage": { "tool": "v8", "threshold": 80 },
    "ci_workflows": [".github/workflows/test.yml"],
    "ai_detected": false,
    "llm_evals_plugin": "llm-evals"
  }
}
```

## Status

Active - v2.1.0

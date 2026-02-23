---
name: Test Framework Detection
description: Detection scripts and patterns for identifying test frameworks across all supported languages. Use when detecting test infrastructure, analyzing project testing setup, identifying coverage tools, or when user mentions test detection, framework identification, testing setup analysis.
---

# Test Framework Detection

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Provides detection scripts and patterns for identifying installed test frameworks, coverage tools, CI workflows, and testing infrastructure across JavaScript/TypeScript, Python, Go, and Rust projects.

## Instructions

### 1. Detection Strategy

Detection uses a **confidence scoring** approach (mirrors `stack-detector` pattern):
- **Evidence file exists** + **dependency declared** = high confidence match
- **Evidence file only** = medium confidence (may be leftover)
- **Dependency only** = low confidence (installed but not configured)

### 2. Running Detection

**Full detection orchestrator:**
```bash
bash scripts/detect-test-frameworks.sh [project-path]
```

**Language-specific detection:**
```bash
bash scripts/detect-node-testing.sh [project-path]    # Jest, Vitest, Mocha, AVA
bash scripts/detect-python-testing.sh [project-path]   # pytest, unittest, nose2
bash scripts/detect-go-testing.sh [project-path]       # go test, testify
bash scripts/detect-rust-testing.sh [project-path]     # cargo test, criterion
bash scripts/detect-ci-workflows.sh [project-path]     # GitHub Actions, GitLab CI
```

### 3. Detection Patterns

**JavaScript/TypeScript:**
| Framework | Evidence Files | Dependencies |
|-----------|---------------|--------------|
| Vitest | `vitest.config.ts`, `vitest.config.js` | `vitest` in devDependencies |
| Jest | `jest.config.js`, `jest.config.ts`, `jest.config.mjs` | `jest` in devDependencies |
| Mocha | `.mocharc.yml`, `.mocharc.json`, `.mocharc.js` | `mocha` in devDependencies |
| AVA | `ava.config.js`, `ava.config.cjs` | `ava` in devDependencies |
| Playwright | `playwright.config.ts`, `playwright.config.js` | `@playwright/test` in devDependencies |

**Python:**
| Framework | Evidence Files | Dependencies |
|-----------|---------------|--------------|
| pytest | `pytest.ini`, `pyproject.toml` [tool.pytest], `setup.cfg` [tool:pytest], `conftest.py` | `pytest` in requirements/pyproject |
| unittest | `test_*.py` files with `import unittest` | stdlib (always available) |
| nose2 | `unittest.cfg`, `setup.cfg` [unittest] | `nose2` in requirements |

**Go:**
| Framework | Evidence Files | Dependencies |
|-----------|---------------|--------------|
| go test | `*_test.go` files | stdlib (always available) |
| testify | `*_test.go` with `testify` imports | `github.com/stretchr/testify` in go.mod |

**Rust:**
| Framework | Evidence Files | Dependencies |
|-----------|---------------|--------------|
| cargo test | `#[cfg(test)]` modules, `tests/` directory | stdlib (always available) |
| criterion | `benches/` directory | `criterion` in Cargo.toml dev-dependencies |

### 4. Coverage Tool Detection

| Tool | Language | Evidence |
|------|----------|----------|
| v8/c8 | Node.js | `c8` in devDependencies or `--coverage` in test script |
| istanbul/nyc | Node.js | `nyc` in devDependencies |
| coverage.py | Python | `coverage` in requirements, `.coveragerc` |
| go cover | Go | Built-in, `go test -cover` |
| tarpaulin | Rust | `cargo-tarpaulin` installed |

### 5. Output Format

Detection writes an expanded `testing` key to `.claude/project.json`:

```json
{
  "testing": {
    "unit": {
      "framework": "vitest",
      "config": "vitest.config.ts",
      "command": "npm run test"
    },
    "api_contract": {
      "framework": "newman",
      "collections": [],
      "auth_strategy": "none"
    },
    "e2e": {
      "framework": "playwright",
      "config": "playwright.config.ts"
    },
    "smoke": {
      "health_endpoint": "/api/health",
      "critical_paths": ["/", "/login"]
    },
    "coverage": {
      "tool": "v8",
      "threshold": 80
    },
    "ci_workflows": [".github/workflows/test.yml"],
    "ai_detected": false,
    "llm_evals_plugin": "llm-evals"
  }
}
```

### 6. CI Workflow Detection

Scans `.github/workflows/*.yml` and `.gitlab-ci.yml` to identify:
- Which test types are already running in CI
- Test commands used in CI vs local
- Coverage reporting in CI
- Test result artifact storage

### 7. AI Framework Detection

Flags `ai_detected: true` when any of these are found:
- `@ai-sdk/` packages in dependencies
- `langchain` in dependencies
- `openai` SDK in dependencies
- `@anthropic-ai/sdk` in dependencies
- `transformers` in Python dependencies

When AI is detected, notes that LLM eval testing should use the `llm-evals` plugin.

## Available Scripts

1. **detect-test-frameworks.sh** - Main orchestrator that runs all detectors
2. **detect-node-testing.sh** - Detect Jest, Vitest, Mocha, AVA, Playwright for Node.js
3. **detect-python-testing.sh** - Detect pytest, unittest, nose2 for Python
4. **detect-go-testing.sh** - Detect go test, testify for Go
5. **detect-rust-testing.sh** - Detect cargo test, criterion for Rust
6. **detect-ci-workflows.sh** - Detect GitHub Actions and GitLab CI test workflows

## Available Templates

1. **project-json-testing-schema.json** - JSON schema for the expanded testing key
2. **detection-report.md** - Template for detection result reporting

## Available Examples

1. **node-project-detection.md** - Example detection for a Node.js/TypeScript project
2. **python-project-detection.md** - Example detection for a Python project
3. **multi-stack-detection.md** - Example detection for a multi-language project

## Requirements

- bash shell for running detection scripts
- jq for JSON processing
- Access to project root directory

## Progressive Disclosure

- Read `examples/node-project-detection.md` for Node.js detection walkthrough
- Read `examples/python-project-detection.md` for Python detection walkthrough
- Read `templates/project-json-testing-schema.json` for the complete schema definition

# Python Project Detection Example

## Scenario

A FastAPI project with pytest and coverage.py.

## Input

**pyproject.toml** (relevant parts):
```toml
[project]
dependencies = [
    "fastapi>=0.100.0",
    "uvicorn>=0.23.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
    "coverage[toml]>=7.0.0",
    "httpx>=0.27.0",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"

[tool.coverage.run]
source = ["src"]
omit = ["tests/*"]

[tool.coverage.report]
fail_under = 80
```

**Files present:**
- `conftest.py`
- `tests/test_api.py`
- `tests/test_models.py`

## Running Detection

```bash
bash scripts/detect-test-frameworks.sh /path/to/project
```

## Output

```
=== Test Framework Detection ===
Project: /path/to/project

[+] Detected: Python project

--- Running python detector ---
  [+] pytest: HIGH confidence (pyproject.toml config)
  [+] Coverage: coverage.py (pyproject.toml config)

--- Running CI workflow detector ---
  [!] No CI test workflows detected

=== Detection Complete ===
```

## Result

```json
{
  "testing": {
    "unit": {
      "framework": "pytest",
      "config": "pyproject.toml",
      "command": "pytest"
    },
    "coverage": {
      "tool": "coverage.py",
      "threshold": 80
    },
    "ci_workflows": [],
    "ai_detected": false
  }
}
```

## Recommendations
- No CI workflow detected - run `/testing:generate-ci` to create one

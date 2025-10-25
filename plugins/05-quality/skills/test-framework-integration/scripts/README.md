# Test Framework Integration Scripts

Mechanical helper scripts for test detection and execution.

## Scripts

### detect-test-framework.sh
**Purpose**: Detect which test framework is configured
**Returns**: JSON with framework name and test command
**Usage**: `./detect-test-framework.sh`

### run-tests.sh
**Purpose**: Execute test suite with appropriate framework
**Usage**: `./run-tests.sh [--watch|--coverage]`

### generate-coverage.sh
**Purpose**: Generate test coverage reports
**Returns**: Coverage percentage and report location
**Usage**: `./generate-coverage.sh`

### scaffold-test.sh
**Purpose**: Create test file scaffold from template
**Usage**: `./scaffold-test.sh <source-file>`

## Implementation Guidelines

- All scripts should be executable (`chmod +x`)
- Use `set -euo pipefail` for bash scripts
- Return JSON for structured output
- Exit codes: 0=success, 1=error, 2=warning
- Detect framework from package.json, requirements.txt, Cargo.toml, etc.

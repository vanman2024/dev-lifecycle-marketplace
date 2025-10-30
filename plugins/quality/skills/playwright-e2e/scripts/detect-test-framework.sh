#!/usr/bin/env bash
set -euo pipefail

# Detect which test framework is configured in the project
# Returns: JSON with framework name and test command

# Detect Node.js test frameworks
if test -f package.json; then
  if grep -q '"jest"' package.json; then
    echo '{"framework": "jest", "command": "npm test", "language": "javascript"}'
    exit 0
  elif grep -q '"vitest"' package.json; then
    echo '{"framework": "vitest", "command": "npm test", "language": "javascript"}'
    exit 0
  elif grep -q '"mocha"' package.json; then
    echo '{"framework": "mocha", "command": "npm test", "language": "javascript"}'
    exit 0
  fi
fi

# Detect Python test frameworks
if test -f requirements.txt || test -f pyproject.toml; then
  if grep -q "pytest" requirements.txt 2>/dev/null || grep -q "pytest" pyproject.toml 2>/dev/null; then
    echo '{"framework": "pytest", "command": "python -m pytest", "language": "python"}'
    exit 0
  fi
fi

# Detect Rust
if test -f Cargo.toml; then
  echo '{"framework": "cargo-test", "command": "cargo test", "language": "rust"}'
  exit 0
fi

# No framework detected
echo '{"framework": "none", "command": null, "language": "unknown"}' >&2
exit 1

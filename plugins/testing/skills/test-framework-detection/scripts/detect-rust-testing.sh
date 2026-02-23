#!/usr/bin/env bash
# detect-rust-testing.sh - Detect Rust test frameworks
# Usage: bash detect-rust-testing.sh [project-path] [result-file]

set -euo pipefail

PROJECT_DIR="${1:-.}"
RESULT_FILE="${2:-$PROJECT_DIR/.claude/test-detection-result.json}"

FRAMEWORK=""
COMMAND=""

if [ ! -f "$PROJECT_DIR/Cargo.toml" ]; then
  echo "  [!] No Cargo.toml found"
  exit 0
fi

# Check for test modules in source files
TEST_MODULES=$(grep -rl '#\[cfg(test)\]' "$PROJECT_DIR/src/" 2>/dev/null | head -3)
TEST_DIR=$([ -d "$PROJECT_DIR/tests" ] && echo "yes" || echo "no")

if [ -n "$TEST_MODULES" ] || [ "$TEST_DIR" = "yes" ]; then
  FRAMEWORK="cargo-test"
  COMMAND="cargo test"
  echo "  [+] cargo test: HIGH confidence"

  if [ -n "$TEST_MODULES" ]; then
    echo "  [+] Unit test modules found in src/"
  fi
  if [ "$TEST_DIR" = "yes" ]; then
    echo "  [+] Integration tests found in tests/"
  fi
fi

# Check for criterion (benchmarking)
if grep -q 'criterion' "$PROJECT_DIR/Cargo.toml" 2>/dev/null; then
  echo "  [+] criterion: benchmark framework detected"
fi

# Check for tarpaulin (coverage)
COVERAGE_TOOL=""
if command -v cargo-tarpaulin &>/dev/null; then
  COVERAGE_TOOL="tarpaulin"
  echo "  [+] Coverage: cargo-tarpaulin"
fi

# --- Update result file ---
if command -v jq &>/dev/null && [ -f "$RESULT_FILE" ]; then
  tmp=$(mktemp)
  jq \
    --arg fw "$FRAMEWORK" \
    --arg cmd "$COMMAND" \
    --arg cov "$COVERAGE_TOOL" \
    '
    .unit.framework = (if $fw != "" then $fw else .unit.framework end) |
    .unit.command = (if $cmd != "" then $cmd else .unit.command end) |
    .coverage.tool = (if $cov != "" then $cov else .coverage.tool end)
    ' "$RESULT_FILE" > "$tmp" && mv "$tmp" "$RESULT_FILE"
fi

if [ -z "$FRAMEWORK" ]; then
  echo "  [!] Cargo.toml found but no test code detected"
fi

#!/usr/bin/env bash
# detect-go-testing.sh - Detect Go test frameworks
# Usage: bash detect-go-testing.sh [project-path] [result-file]

set -euo pipefail

PROJECT_DIR="${1:-.}"
RESULT_FILE="${2:-$PROJECT_DIR/.claude/test-detection-result.json}"

FRAMEWORK=""
CONFIG=""
COMMAND=""

if [ ! -f "$PROJECT_DIR/go.mod" ]; then
  echo "  [!] No go.mod found"
  exit 0
fi

# Go always has built-in testing
TEST_FILES=$(find "$PROJECT_DIR" -maxdepth 4 -name "*_test.go" 2>/dev/null | head -5)
if [ -n "$TEST_FILES" ]; then
  FRAMEWORK="go-test"
  COMMAND="go test ./..."
  echo "  [+] go test: HIGH confidence (test files found)"

  # Check for testify
  if grep -q 'github.com/stretchr/testify' "$PROJECT_DIR/go.mod" 2>/dev/null; then
    echo "  [+] testify: detected as test helper library"
  fi

  # Check for gomock
  if grep -q 'go.uber.org/mock\|github.com/golang/mock' "$PROJECT_DIR/go.mod" 2>/dev/null; then
    echo "  [+] gomock: detected for mock generation"
  fi
else
  echo "  [!] go.mod found but no test files detected"
fi

# --- Update result file ---
if command -v jq &>/dev/null && [ -f "$RESULT_FILE" ]; then
  tmp=$(mktemp)
  jq \
    --arg fw "$FRAMEWORK" \
    --arg cmd "$COMMAND" \
    '
    .unit.framework = (if $fw != "" then $fw else .unit.framework end) |
    .unit.command = (if $cmd != "" then $cmd else .unit.command end) |
    .coverage.tool = (if $fw == "go-test" then "go-cover" else .coverage.tool end)
    ' "$RESULT_FILE" > "$tmp" && mv "$tmp" "$RESULT_FILE"
fi

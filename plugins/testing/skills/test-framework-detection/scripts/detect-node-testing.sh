#!/usr/bin/env bash
# detect-node-testing.sh - Detect Node.js test frameworks
# Usage: bash detect-node-testing.sh [project-path] [result-file]

set -euo pipefail

PROJECT_DIR="${1:-.}"
RESULT_FILE="${2:-$PROJECT_DIR/.claude/test-detection-result.json}"
PKG="$PROJECT_DIR/package.json"

if [ ! -f "$PKG" ]; then
  echo "[!] No package.json found"
  exit 0
fi

PKG_CONTENT=$(cat "$PKG")
FRAMEWORK=""
CONFIG=""
COMMAND=""
COVERAGE_TOOL=""

# --- Unit Test Framework Detection ---

# Check Vitest (highest priority for modern projects)
if echo "$PKG_CONTENT" | grep -q '"vitest"'; then
  if [ -f "$PROJECT_DIR/vitest.config.ts" ]; then
    FRAMEWORK="vitest"; CONFIG="vitest.config.ts"
    echo "  [+] Vitest: HIGH confidence (dep + config)"
  elif [ -f "$PROJECT_DIR/vitest.config.js" ]; then
    FRAMEWORK="vitest"; CONFIG="vitest.config.js"
    echo "  [+] Vitest: HIGH confidence (dep + config)"
  else
    FRAMEWORK="vitest"; CONFIG=""
    echo "  [+] Vitest: MEDIUM confidence (dep only)"
  fi
fi

# Check Jest (if Vitest not found)
if [ -z "$FRAMEWORK" ] && echo "$PKG_CONTENT" | grep -q '"jest"'; then
  for cfg in jest.config.js jest.config.ts jest.config.mjs jest.config.cjs; do
    if [ -f "$PROJECT_DIR/$cfg" ]; then
      FRAMEWORK="jest"; CONFIG="$cfg"
      echo "  [+] Jest: HIGH confidence (dep + config)"
      break
    fi
  done
  if [ -z "$FRAMEWORK" ]; then
    # Check for jest config in package.json
    if echo "$PKG_CONTENT" | grep -q '"jest"' | grep -q '"transform"\|"testMatch"' 2>/dev/null; then
      FRAMEWORK="jest"; CONFIG="package.json"
      echo "  [+] Jest: HIGH confidence (dep + inline config)"
    else
      FRAMEWORK="jest"; CONFIG=""
      echo "  [+] Jest: MEDIUM confidence (dep only)"
    fi
  fi
fi

# Check Mocha
if [ -z "$FRAMEWORK" ] && echo "$PKG_CONTENT" | grep -q '"mocha"'; then
  for cfg in .mocharc.yml .mocharc.json .mocharc.js .mocharc.cjs; do
    if [ -f "$PROJECT_DIR/$cfg" ]; then
      FRAMEWORK="mocha"; CONFIG="$cfg"
      echo "  [+] Mocha: HIGH confidence (dep + config)"
      break
    fi
  done
  if [ -z "$FRAMEWORK" ]; then
    FRAMEWORK="mocha"; CONFIG=""
    echo "  [+] Mocha: MEDIUM confidence (dep only)"
  fi
fi

# Check AVA
if [ -z "$FRAMEWORK" ] && echo "$PKG_CONTENT" | grep -q '"ava"'; then
  FRAMEWORK="ava"
  echo "  [+] AVA: MEDIUM confidence (dep)"
fi

# --- Detect test command from scripts ---
if command -v jq &>/dev/null; then
  TEST_SCRIPT=$(echo "$PKG_CONTENT" | jq -r '.scripts.test // empty' 2>/dev/null || true)
  if [ -n "$TEST_SCRIPT" ] && [ "$TEST_SCRIPT" != "null" ]; then
    COMMAND="npm run test"
    echo "  [+] Test command: $TEST_SCRIPT"
  fi
fi

# --- E2E Detection (Playwright) ---
E2E_FRAMEWORK=""
E2E_CONFIG=""
if echo "$PKG_CONTENT" | grep -q '"@playwright/test"'; then
  if [ -f "$PROJECT_DIR/playwright.config.ts" ]; then
    E2E_FRAMEWORK="playwright"; E2E_CONFIG="playwright.config.ts"
    echo "  [+] Playwright E2E: HIGH confidence (dep + config)"
  elif [ -f "$PROJECT_DIR/playwright.config.js" ]; then
    E2E_FRAMEWORK="playwright"; E2E_CONFIG="playwright.config.js"
    echo "  [+] Playwright E2E: HIGH confidence (dep + config)"
  else
    E2E_FRAMEWORK="playwright"
    echo "  [+] Playwright E2E: MEDIUM confidence (dep only)"
  fi
fi

# Check Cypress as alternative
if [ -z "$E2E_FRAMEWORK" ] && echo "$PKG_CONTENT" | grep -q '"cypress"'; then
  if [ -f "$PROJECT_DIR/cypress.config.ts" ] || [ -f "$PROJECT_DIR/cypress.config.js" ]; then
    E2E_FRAMEWORK="cypress"; E2E_CONFIG="cypress.config.ts"
    echo "  [+] Cypress E2E: HIGH confidence (dep + config)"
  fi
fi

# --- Coverage Tool Detection ---
if echo "$PKG_CONTENT" | grep -q '"c8"' || echo "$PKG_CONTENT" | grep -q '"@vitest/coverage-v8"'; then
  COVERAGE_TOOL="v8"
  echo "  [+] Coverage: v8/c8"
elif echo "$PKG_CONTENT" | grep -q '"nyc"' || echo "$PKG_CONTENT" | grep -q '"istanbul"'; then
  COVERAGE_TOOL="istanbul"
  echo "  [+] Coverage: istanbul/nyc"
elif [ "$FRAMEWORK" = "vitest" ]; then
  COVERAGE_TOOL="v8"
  echo "  [+] Coverage: v8 (vitest default)"
fi

# --- Update result file ---
if command -v jq &>/dev/null && [ -f "$RESULT_FILE" ]; then
  tmp=$(mktemp)
  jq \
    --arg fw "$FRAMEWORK" \
    --arg cfg "$CONFIG" \
    --arg cmd "$COMMAND" \
    --arg e2e_fw "$E2E_FRAMEWORK" \
    --arg e2e_cfg "$E2E_CONFIG" \
    --arg cov "$COVERAGE_TOOL" \
    '
    .unit.framework = (if $fw != "" then $fw else null end) |
    .unit.config = (if $cfg != "" then $cfg else null end) |
    .unit.command = (if $cmd != "" then $cmd else null end) |
    .e2e.framework = (if $e2e_fw != "" then $e2e_fw else null end) |
    .e2e.config = (if $e2e_cfg != "" then $e2e_cfg else null end) |
    .coverage.tool = (if $cov != "" then $cov else null end)
    ' "$RESULT_FILE" > "$tmp" && mv "$tmp" "$RESULT_FILE"
fi

if [ -z "$FRAMEWORK" ]; then
  echo "  [!] No Node.js test framework detected"
fi

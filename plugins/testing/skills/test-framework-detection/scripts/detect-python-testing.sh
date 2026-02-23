#!/usr/bin/env bash
# detect-python-testing.sh - Detect Python test frameworks
# Usage: bash detect-python-testing.sh [project-path] [result-file]

set -euo pipefail

PROJECT_DIR="${1:-.}"
RESULT_FILE="${2:-$PROJECT_DIR/.claude/test-detection-result.json}"

FRAMEWORK=""
CONFIG=""
COMMAND=""
COVERAGE_TOOL=""

# --- pytest Detection ---
# Check pyproject.toml for pytest config
if [ -f "$PROJECT_DIR/pyproject.toml" ]; then
  if grep -q '\[tool\.pytest' "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
    FRAMEWORK="pytest"; CONFIG="pyproject.toml"
    echo "  [+] pytest: HIGH confidence (pyproject.toml config)"
  elif grep -q 'pytest' "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
    FRAMEWORK="pytest"; CONFIG="pyproject.toml"
    echo "  [+] pytest: MEDIUM confidence (dep in pyproject.toml)"
  fi
fi

# Check pytest.ini
if [ -z "$FRAMEWORK" ] && [ -f "$PROJECT_DIR/pytest.ini" ]; then
  FRAMEWORK="pytest"; CONFIG="pytest.ini"
  echo "  [+] pytest: HIGH confidence (pytest.ini)"
fi

# Check setup.cfg
if [ -z "$FRAMEWORK" ] && [ -f "$PROJECT_DIR/setup.cfg" ]; then
  if grep -q '\[tool:pytest\]' "$PROJECT_DIR/setup.cfg" 2>/dev/null; then
    FRAMEWORK="pytest"; CONFIG="setup.cfg"
    echo "  [+] pytest: HIGH confidence (setup.cfg config)"
  fi
fi

# Check conftest.py
if [ -z "$FRAMEWORK" ] && find "$PROJECT_DIR" -maxdepth 2 -name "conftest.py" 2>/dev/null | grep -q .; then
  FRAMEWORK="pytest"; CONFIG="conftest.py"
  echo "  [+] pytest: HIGH confidence (conftest.py found)"
fi

# Check requirements for pytest
if [ -z "$FRAMEWORK" ]; then
  for req_file in requirements.txt requirements-dev.txt requirements/dev.txt requirements/test.txt; do
    if [ -f "$PROJECT_DIR/$req_file" ] && grep -qi 'pytest' "$PROJECT_DIR/$req_file" 2>/dev/null; then
      FRAMEWORK="pytest"; CONFIG=""
      echo "  [+] pytest: MEDIUM confidence (in $req_file)"
      break
    fi
  done
fi

# --- unittest Detection (fallback) ---
if [ -z "$FRAMEWORK" ]; then
  UNITTEST_FILES=$(find "$PROJECT_DIR" -maxdepth 3 -name "test_*.py" -exec grep -l "import unittest" {} \; 2>/dev/null | head -1)
  if [ -n "$UNITTEST_FILES" ]; then
    FRAMEWORK="unittest"
    echo "  [+] unittest: MEDIUM confidence (test files with unittest import)"
  fi
fi

# --- nose2 Detection ---
if [ -z "$FRAMEWORK" ]; then
  for req_file in requirements.txt requirements-dev.txt; do
    if [ -f "$PROJECT_DIR/$req_file" ] && grep -qi 'nose2' "$PROJECT_DIR/$req_file" 2>/dev/null; then
      FRAMEWORK="nose2"
      echo "  [+] nose2: MEDIUM confidence (in $req_file)"
      break
    fi
  done
fi

# --- Determine test command ---
if [ "$FRAMEWORK" = "pytest" ]; then
  COMMAND="pytest"
  # Check for pytest in pyproject.toml scripts
  if [ -f "$PROJECT_DIR/pyproject.toml" ] && grep -q 'test.*=.*pytest' "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
    COMMAND="python -m pytest"
  fi
elif [ "$FRAMEWORK" = "unittest" ]; then
  COMMAND="python -m unittest discover"
elif [ "$FRAMEWORK" = "nose2" ]; then
  COMMAND="nose2"
fi

# --- Coverage Detection ---
if [ -f "$PROJECT_DIR/.coveragerc" ]; then
  COVERAGE_TOOL="coverage.py"
  echo "  [+] Coverage: coverage.py (.coveragerc found)"
elif [ -f "$PROJECT_DIR/pyproject.toml" ] && grep -q '\[tool\.coverage\]' "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
  COVERAGE_TOOL="coverage.py"
  echo "  [+] Coverage: coverage.py (pyproject.toml config)"
fi

# --- Update result file ---
if command -v jq &>/dev/null && [ -f "$RESULT_FILE" ]; then
  tmp=$(mktemp)
  jq \
    --arg fw "$FRAMEWORK" \
    --arg cfg "$CONFIG" \
    --arg cmd "$COMMAND" \
    --arg cov "$COVERAGE_TOOL" \
    '
    .unit.framework = (if $fw != "" then $fw else .unit.framework end) |
    .unit.config = (if $cfg != "" then $cfg else .unit.config end) |
    .unit.command = (if $cmd != "" then $cmd else .unit.command end) |
    .coverage.tool = (if $cov != "" then $cov else .coverage.tool end)
    ' "$RESULT_FILE" > "$tmp" && mv "$tmp" "$RESULT_FILE"
fi

if [ -z "$FRAMEWORK" ]; then
  echo "  [!] No Python test framework detected"
fi

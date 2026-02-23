#!/usr/bin/env bash
# detect-ci-workflows.sh - Detect CI/CD test workflows
# Usage: bash detect-ci-workflows.sh [project-path] [result-file]

set -euo pipefail

PROJECT_DIR="${1:-.}"
RESULT_FILE="${2:-$PROJECT_DIR/.claude/test-detection-result.json}"

CI_WORKFLOWS=()

# --- GitHub Actions ---
GHA_DIR="$PROJECT_DIR/.github/workflows"
if [ -d "$GHA_DIR" ]; then
  echo "  [+] GitHub Actions workflows directory found"
  for wf in "$GHA_DIR"/*.yml "$GHA_DIR"/*.yaml; do
    [ -f "$wf" ] || continue
    WF_NAME=$(basename "$wf")

    # Check if workflow contains test-related steps
    if grep -qiE 'npm test|npx jest|npx vitest|pytest|go test|cargo test|newman|playwright|cypress' "$wf" 2>/dev/null; then
      CI_WORKFLOWS+=(".github/workflows/$WF_NAME")
      echo "    [+] Test workflow: $WF_NAME"

      # Identify which test types run in this workflow
      if grep -qiE 'jest|vitest|pytest|go test|cargo test|npm test|npm run test' "$wf" 2>/dev/null; then
        echo "      - Unit tests"
      fi
      if grep -qiE 'playwright|cypress' "$wf" 2>/dev/null; then
        echo "      - E2E tests"
      fi
      if grep -qiE 'newman|postman' "$wf" 2>/dev/null; then
        echo "      - API tests"
      fi
      if grep -qiE 'coverage|codecov|coveralls' "$wf" 2>/dev/null; then
        echo "      - Coverage reporting"
      fi
    fi
  done
fi

# --- GitLab CI ---
if [ -f "$PROJECT_DIR/.gitlab-ci.yml" ]; then
  echo "  [+] GitLab CI configuration found"
  if grep -qiE 'test|jest|vitest|pytest|newman|playwright' "$PROJECT_DIR/.gitlab-ci.yml" 2>/dev/null; then
    CI_WORKFLOWS+=(".gitlab-ci.yml")
    echo "    [+] Test stages detected in .gitlab-ci.yml"
  fi
fi

# --- CircleCI ---
if [ -f "$PROJECT_DIR/.circleci/config.yml" ]; then
  echo "  [+] CircleCI configuration found"
  if grep -qiE 'test|jest|vitest|pytest' "$PROJECT_DIR/.circleci/config.yml" 2>/dev/null; then
    CI_WORKFLOWS+=(".circleci/config.yml")
    echo "    [+] Test jobs detected in CircleCI config"
  fi
fi

# --- Update result file ---
if command -v jq &>/dev/null && [ -f "$RESULT_FILE" ] && [ ${#CI_WORKFLOWS[@]} -gt 0 ]; then
  CI_JSON=$(printf '%s\n' "${CI_WORKFLOWS[@]}" | jq -R -s 'split("\n") | map(select(. != ""))')
  tmp=$(mktemp)
  jq --argjson ci "$CI_JSON" '.ci_workflows = $ci' "$RESULT_FILE" > "$tmp" && mv "$tmp" "$RESULT_FILE"
fi

if [ ${#CI_WORKFLOWS[@]} -eq 0 ]; then
  echo "  [!] No CI test workflows detected"
fi

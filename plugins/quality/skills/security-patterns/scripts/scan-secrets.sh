#!/usr/bin/env bash
set -euo pipefail

# Scan for exposed secrets and credentials
# Returns: JSON with found secrets

TARGET_DIR="${1:-.}"

# Secret patterns
PATTERNS=(
  "api[_-]?key"
  "password"
  "secret"
  "token"
  "bearer"
  "AKIA[0-9A-Z]{16}"
)

FINDINGS=()

for pattern in "${PATTERNS[@]}"; do
  matches=$(grep -rIn "$pattern" "$TARGET_DIR" \
    --include="*.js" --include="*.ts" --include="*.py" --include="*.env" \
    --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=.git \
    2>/dev/null || true)

  if [ -n "$matches" ]; then
    FINDINGS+=("$matches")
  fi
done

if [ ${#FINDINGS[@]} -gt 0 ]; then
  echo "${FINDINGS[@]}"
  exit 1
else
  echo "No secrets found"
  exit 0
fi

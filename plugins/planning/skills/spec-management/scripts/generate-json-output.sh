#!/bin/bash
# Generate JSON output for a single spec directory
# Usage: ./generate-json-output.sh <spec-directory-path>

set -e

SPEC_DIR="$1"

if [ -z "$SPEC_DIR" ]; then
  echo "Error: Spec directory path required" >&2
  echo "Usage: $0 <spec-directory-path>" >&2
  exit 1
fi

if [ ! -d "$SPEC_DIR" ]; then
  echo "Error: Directory does not exist: $SPEC_DIR" >&2
  exit 1
fi

# Extract spec number and name from directory
BASENAME=$(basename "$SPEC_DIR")
SPEC_NUMBER=$(echo "$BASENAME" | cut -d'-' -f1)
SPEC_NAME=$(echo "$BASENAME" | cut -d'-' -f2-)

# Get absolute path
SPEC_PATH=$(cd "$SPEC_DIR" && pwd)

# Check which files exist
HAS_SPEC="false"
HAS_PLAN="false"
HAS_TASKS="false"

[ -f "$SPEC_PATH/spec.md" ] && HAS_SPEC="true"
[ -f "$SPEC_PATH/plan.md" ] && HAS_PLAN="true"
[ -f "$SPEC_PATH/tasks.md" ] && HAS_TASKS="true"

# Determine status
if [ "$HAS_SPEC" = "true" ] && [ "$HAS_PLAN" = "true" ] && [ "$HAS_TASKS" = "true" ]; then
  STATUS="complete"
elif [ "$HAS_SPEC" = "true" ]; then
  STATUS="spec-only"
else
  STATUS="incomplete"
fi

# Output JSON
cat <<EOF
{
  "number": "$SPEC_NUMBER",
  "name": "$SPEC_NAME",
  "path": "$SPEC_PATH",
  "files": {
    "spec": "$SPEC_PATH/spec.md",
    "plan": "$SPEC_PATH/plan.md",
    "tasks": "$SPEC_PATH/tasks.md"
  },
  "exists": {
    "spec": $HAS_SPEC,
    "plan": $HAS_PLAN,
    "tasks": $HAS_TASKS
  },
  "status": "$STATUS"
}
EOF

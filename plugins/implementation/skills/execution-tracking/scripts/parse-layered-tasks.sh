#!/usr/bin/env bash
# Parse layered-tasks.md and populate execution status file with task structure
# Usage: parse-layered-tasks.sh <spec-id>

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

usage() {
  cat << EOF
Usage: $0 <spec-id>

Parse layered-tasks.md file and populate execution status file with task structure.

Example:
  $0 F001

This will:
  1. Read specs/F001/layered-tasks.md
  2. Extract all tasks from each layer (L0, L1, L2, L3)
  3. Update .claude/execution/F001.json with task definitions
  4. Calculate total task count
  5. Set initial task statuses to "pending"

Exit Codes:
  0 - Success
  1 - Invalid arguments
  2 - File not found
  4 - Parsing error
EOF
  exit 1
}

# Validate inputs
if [[ $# -lt 1 ]]; then
  usage
fi

SPEC="$1"
LAYERED_TASKS="specs/${SPEC}/layered-tasks.md"
STATUS_FILE=".claude/execution/${SPEC}.json"

# Check files exist
if [[ ! -f "$LAYERED_TASKS" ]]; then
  log_error "Layered tasks file not found: $LAYERED_TASKS"
  exit 2
fi

if [[ ! -f "$STATUS_FILE" ]]; then
  log_error "Status file not found: $STATUS_FILE (run 'update-status.sh init $SPEC' first)"
  exit 2
fi

log_info "Parsing layered tasks from: $LAYERED_TASKS"

# Parse tasks for each layer
parse_layer_tasks() {
  local layer="$1"
  local layer_name="$2"

  # Extract tasks for this layer
  # Format: - Task description (`/command`, agent-name, complexity)
  local tasks_json="[]"
  local task_idx=0

  # Find layer section and extract tasks
  while IFS= read -r line; do
    # Match task line: - Description (`/command`, agent, complexity)
    if [[ "$line" =~ ^-[[:space:]]*(.+)[[:space:]]*\(\`(.+)\`,[[:space:]]*([^,]+),[[:space:]]*([^)]+)\) ]]; then
      local description="${BASH_REMATCH[1]}"
      local command="${BASH_REMATCH[2]}"
      local agent="${BASH_REMATCH[3]}"
      local complexity="${BASH_REMATCH[4]}"

      # Create task object
      local task_json=$(cat <<EOF
{
  "index": ${task_idx},
  "description": "${description}",
  "command": "${command}",
  "agent": "${agent}",
  "complexity": "${complexity}",
  "dependencies": [],
  "status": "pending",
  "started_at": null,
  "completed_at": null,
  "duration_ms": null,
  "output": null,
  "files_created": [],
  "files_modified": [],
  "error": null
}
EOF
)

      # Add to tasks array
      tasks_json=$(echo "$tasks_json" | jq --argjson task "$task_json" '. += [$task]')
      ((task_idx++))
    fi
  done < <(sed -n "/^## Layer ${layer#L}:/,/^## Layer/p" "$LAYERED_TASKS")

  echo "$tasks_json"
}

# Parse all layers
log_info "Parsing Layer 0 (Infrastructure)..."
L0_TASKS=$(parse_layer_tasks "L0" "Infrastructure")
L0_COUNT=$(echo "$L0_TASKS" | jq 'length')
log_info "Found $L0_COUNT tasks in L0"

log_info "Parsing Layer 1 (Core Services)..."
L1_TASKS=$(parse_layer_tasks "L1" "Core Services")
L1_COUNT=$(echo "$L1_TASKS" | jq 'length')
log_info "Found $L1_COUNT tasks in L1"

log_info "Parsing Layer 2 (Features)..."
L2_TASKS=$(parse_layer_tasks "L2" "Features")
L2_COUNT=$(echo "$L2_TASKS" | jq 'length')
log_info "Found $L2_COUNT tasks in L2"

log_info "Parsing Layer 3 (Integration)..."
L3_TASKS=$(parse_layer_tasks "L3" "Integration")
L3_COUNT=$(echo "$L3_TASKS" | jq 'length')
log_info "Found $L3_COUNT tasks in L3"

# Calculate total
TOTAL_TASKS=$((L0_COUNT + L1_COUNT + L2_COUNT + L3_COUNT))
log_info "Total tasks: $TOTAL_TASKS"

# Update status file
jq --argjson l0_tasks "$L0_TASKS" \
   --argjson l1_tasks "$L1_TASKS" \
   --argjson l2_tasks "$L2_TASKS" \
   --argjson l3_tasks "$L3_TASKS" \
   --argjson total "$TOTAL_TASKS" \
   --argjson l0_count "$L0_COUNT" \
   --argjson l1_count "$L1_COUNT" \
   --argjson l2_count "$L2_COUNT" \
   --argjson l3_count "$L3_COUNT" \
   '
   .total_tasks = $total |
   .layers.L0 = {
     "name": "Infrastructure",
     "status": "pending",
     "total_tasks": $l0_count,
     "completed_tasks": 0,
     "failed_tasks": 0,
     "started_at": null,
     "completed_at": null,
     "duration_ms": null,
     "tasks": $l0_tasks
   } |
   .layers.L1 = {
     "name": "Core Services",
     "status": "pending",
     "total_tasks": $l1_count,
     "completed_tasks": 0,
     "failed_tasks": 0,
     "started_at": null,
     "completed_at": null,
     "duration_ms": null,
     "tasks": $l1_tasks
   } |
   .layers.L2 = {
     "name": "Features",
     "status": "pending",
     "total_tasks": $l2_count,
     "completed_tasks": 0,
     "failed_tasks": 0,
     "started_at": null,
     "completed_at": null,
     "duration_ms": null,
     "tasks": $l2_tasks
   } |
   .layers.L3 = {
     "name": "Integration",
     "status": "pending",
     "total_tasks": $l3_count,
     "completed_tasks": 0,
     "failed_tasks": 0,
     "started_at": null,
     "completed_at": null,
     "duration_ms": null,
     "tasks": $l3_tasks
   }
   ' "$STATUS_FILE" > "${STATUS_FILE}.tmp" && mv "${STATUS_FILE}.tmp" "$STATUS_FILE"

log_success "Updated status file with $TOTAL_TASKS tasks across 4 layers"
log_info "Status file: $STATUS_FILE"

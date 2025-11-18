#!/usr/bin/env bash
# Execution status file management script
# Handles initialization, updates, layer completion, error logging, and reporting

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function to print colored output
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Get current timestamp in ISO 8601 format
get_timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Get milliseconds since epoch (for duration calculation)
get_timestamp_ms() {
  date +%s%3N
}

# Calculate duration in milliseconds
calculate_duration() {
  local start_ms="$1"
  local end_ms="$2"
  echo $((end_ms - start_ms))
}

# Usage information
usage() {
  cat << EOF
Usage: $0 <command> [arguments]

Commands:
  init <spec-id>                           Initialize execution tracking for a spec
  update <spec> <layer> <task-idx> <status> Update task status
  complete-layer <spec> <layer>            Mark layer as complete
  error <spec> <layer> <task-idx> <msg>    Log execution error
  report <spec>                            Generate progress report
  pause <spec>                             Pause execution
  resume <spec>                            Resume execution

Examples:
  $0 init F001
  $0 update F001 L1 2 complete
  $0 complete-layer F001 L0
  $0 error F001 L1 3 "Database connection timeout"
  $0 report F001
  $0 pause F001

Exit Codes:
  0 - Success
  1 - Invalid arguments
  2 - File not found
  3 - Invalid status
  4 - JSON parsing error
  5 - Write permission error
EOF
  exit 1
}

# Validate spec file exists
validate_spec() {
  local spec="$1"
  local layered_tasks="specs/${spec}/layered-tasks.md"

  if [[ ! -f "$layered_tasks" ]]; then
    log_error "Layered tasks file not found: $layered_tasks"
    exit 2
  fi
}

# Initialize execution status file
init_status() {
  local spec="$1"
  validate_spec "$spec"

  local status_file=".claude/execution/${spec}.json"
  local layered_tasks="specs/${spec}/layered-tasks.md"

  # Create execution directory if needed
  mkdir -p .claude/execution

  # Extract feature name from layered tasks
  local feature_name
  feature_name=$(grep -m 1 "^# Feature:" "$layered_tasks" | sed 's/^# Feature: //' || echo "Unknown Feature")

  # Initialize status file
  cat > "$status_file" << EOF
{
  "feature": "${spec}",
  "feature_name": "${feature_name}",
  "started_at": "$(get_timestamp)",
  "last_updated": "$(get_timestamp)",
  "status": "pending",
  "current_layer": "L0",
  "total_tasks": 0,
  "completed_tasks": 0,
  "failed_tasks": 0,
  "skipped_tasks": 0,
  "completion_percentage": 0,
  "average_task_duration_ms": 0,
  "estimated_remaining_ms": 0,
  "layers": {},
  "errors": [],
  "warnings": [],
  "next_action": "Start execution with /implementation:execute ${spec}"
}
EOF

  log_success "Initialized execution tracking: $status_file"
  log_info "Next: Parse layered-tasks.md to populate task structure"
}

# Update task status
update_task_status() {
  local spec="$1"
  local layer="$2"
  local task_idx="$3"
  local status="$4"

  local status_file=".claude/execution/${spec}.json"

  if [[ ! -f "$status_file" ]]; then
    log_error "Status file not found: $status_file"
    exit 2
  fi

  # Validate status
  case "$status" in
    complete|failed|skipped|in_progress) ;;
    *)
      log_error "Invalid status: $status (must be: complete, failed, skipped, in_progress)"
      exit 3
      ;;
  esac

  local timestamp
  timestamp=$(get_timestamp)

  # Update using jq
  jq --arg layer "$layer" \
     --arg idx "$task_idx" \
     --arg status "$status" \
     --arg timestamp "$timestamp" \
     '
     .layers[$layer].tasks[($idx | tonumber)].status = $status |
     .layers[$layer].tasks[($idx | tonumber)].completed_at = (if $status == "complete" then $timestamp else null end) |
     .last_updated = $timestamp |
     # Recalculate layer metrics
     .layers[$layer].completed_tasks = ([.layers[$layer].tasks[] | select(.status == "complete")] | length) |
     .layers[$layer].failed_tasks = ([.layers[$layer].tasks[] | select(.status == "failed")] | length) |
     # Recalculate overall metrics
     .completed_tasks = ([.layers[].tasks[] | select(.status == "complete")] | length) |
     .failed_tasks = ([.layers[].tasks[] | select(.status == "failed")] | length) |
     .skipped_tasks = ([.layers[].tasks[] | select(.status == "skipped")] | length) |
     .completion_percentage = ((.completed_tasks / .total_tasks) * 100 | floor)
     ' "$status_file" > "${status_file}.tmp" && mv "${status_file}.tmp" "$status_file"

  log_success "Updated ${spec} ${layer} task ${task_idx} to status: ${status}"
}

# Mark layer complete
complete_layer() {
  local spec="$1"
  local layer="$2"

  local status_file=".claude/execution/${spec}.json"

  if [[ ! -f "$status_file" ]]; then
    log_error "Status file not found: $status_file"
    exit 2
  fi

  local timestamp
  timestamp=$(get_timestamp)

  # Determine next layer
  local next_layer
  case "$layer" in
    L0) next_layer="L1" ;;
    L1) next_layer="L2" ;;
    L2) next_layer="L3" ;;
    L3) next_layer="complete" ;;
    *) next_layer="unknown" ;;
  esac

  # Update using jq
  jq --arg layer "$layer" \
     --arg timestamp "$timestamp" \
     --arg next_layer "$next_layer" \
     '
     .layers[$layer].status = "complete" |
     .layers[$layer].completed_at = $timestamp |
     .current_layer = $next_layer |
     .last_updated = $timestamp
     ' "$status_file" > "${status_file}.tmp" && mv "${status_file}.tmp" "$status_file"

  log_success "Marked ${spec} ${layer} as complete. Next layer: ${next_layer}"
}

# Log execution error
log_execution_error() {
  local spec="$1"
  local layer="$2"
  local task_idx="$3"
  local error_msg="$4"

  local status_file=".claude/execution/${spec}.json"

  if [[ ! -f "$status_file" ]]; then
    log_error "Status file not found: $status_file"
    exit 2
  fi

  local timestamp
  timestamp=$(get_timestamp)

  # Add error to errors array
  jq --arg layer "$layer" \
     --arg idx "$task_idx" \
     --arg error "$error_msg" \
     --arg timestamp "$timestamp" \
     '
     .errors += [{
       "layer": $layer,
       "task_index": ($idx | tonumber),
       "error": $error,
       "timestamp": $timestamp,
       "severity": "high"
     }] |
     .last_updated = $timestamp |
     # Mark task as failed
     .layers[$layer].tasks[($idx | tonumber)].status = "failed"
     ' "$status_file" > "${status_file}.tmp" && mv "${status_file}.tmp" "$status_file"

  log_error "Logged error for ${spec} ${layer} task ${task_idx}: ${error_msg}"
}

# Generate progress report
generate_report() {
  local spec="$1"
  local status_file=".claude/execution/${spec}.json"

  if [[ ! -f "$status_file" ]]; then
    log_error "Status file not found: $status_file"
    exit 2
  fi

  # Read status file
  local feature_name total_tasks completed_tasks completion_pct status
  feature_name=$(jq -r '.feature_name' "$status_file")
  total_tasks=$(jq -r '.total_tasks' "$status_file")
  completed_tasks=$(jq -r '.completed_tasks' "$status_file")
  completion_pct=$(jq -r '.completion_percentage' "$status_file")
  status=$(jq -r '.status' "$status_file")

  # Generate report
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Feature ${spec}: ${feature_name}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Overall Progress: ${completion_pct}% (${completed_tasks}/${total_tasks} tasks)"
  echo "Status: ${status}"
  echo ""

  # Layer breakdown
  for layer in L0 L1 L2 L3; do
    local layer_status layer_total layer_complete layer_name icon
    layer_status=$(jq -r ".layers.${layer}.status // \"pending\"" "$status_file")
    layer_total=$(jq -r ".layers.${layer}.total_tasks // 0" "$status_file")
    layer_complete=$(jq -r ".layers.${layer}.completed_tasks // 0" "$status_file")
    layer_name=$(jq -r ".layers.${layer}.name // \"Unknown\"" "$status_file")

    case "$layer_status" in
      complete) icon="✅" ;;
      in_progress) icon="🔄" ;;
      pending) icon="⏳" ;;
      failed) icon="❌" ;;
      *) icon="❓" ;;
    esac

    printf "Layer %s (%s): %s %s (%d/%d tasks)\n" "$layer" "$layer_name" "$icon" "$layer_status" "$layer_complete" "$layer_total"
  done

  echo ""

  # Errors
  local error_count
  error_count=$(jq '.errors | length' "$status_file")
  echo "Errors: ${error_count}"

  if [[ "$error_count" -gt 0 ]]; then
    echo ""
    echo "Recent Errors:"
    jq -r '.errors[-3:] | .[] | "  - [\(.layer)] \(.error)"' "$status_file"
  fi

  echo ""
  echo "Status File: ${status_file}"
  echo ""

  # Next action
  local next_action
  next_action=$(jq -r '.next_action' "$status_file")
  echo "Next Action: ${next_action}"
  echo ""
}

# Pause execution
pause_execution() {
  local spec="$1"
  local status_file=".claude/execution/${spec}.json"

  if [[ ! -f "$status_file" ]]; then
    log_error "Status file not found: $status_file"
    exit 2
  fi

  jq '.status = "paused" | .last_updated = "'"$(get_timestamp)"'"' "$status_file" > "${status_file}.tmp" && mv "${status_file}.tmp" "$status_file"
  log_warning "Execution paused for ${spec}"
}

# Resume execution
resume_execution() {
  local spec="$1"
  local status_file=".claude/execution/${spec}.json"

  if [[ ! -f "$status_file" ]]; then
    log_error "Status file not found: $status_file"
    exit 2
  fi

  jq '.status = "in_progress" | .last_updated = "'"$(get_timestamp)"'"' "$status_file" > "${status_file}.tmp" && mv "${status_file}.tmp" "$status_file"
  log_success "Execution resumed for ${spec}"
}

# Main command dispatcher
main() {
  if [[ $# -lt 1 ]]; then
    usage
  fi

  local command="$1"
  shift

  case "$command" in
    init)
      [[ $# -lt 1 ]] && usage
      init_status "$1"
      ;;
    update)
      [[ $# -lt 4 ]] && usage
      update_task_status "$1" "$2" "$3" "$4"
      ;;
    complete-layer)
      [[ $# -lt 2 ]] && usage
      complete_layer "$1" "$2"
      ;;
    error)
      [[ $# -lt 4 ]] && usage
      log_execution_error "$1" "$2" "$3" "$4"
      ;;
    report)
      [[ $# -lt 1 ]] && usage
      generate_report "$1"
      ;;
    pause)
      [[ $# -lt 1 ]] && usage
      pause_execution "$1"
      ;;
    resume)
      [[ $# -lt 1 ]] && usage
      resume_execution "$1"
      ;;
    *)
      log_error "Unknown command: $command"
      usage
      ;;
  esac
}

main "$@"

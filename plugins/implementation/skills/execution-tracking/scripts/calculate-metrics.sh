#!/usr/bin/env bash
# Calculate execution metrics from status file
# Usage: calculate-metrics.sh <spec-id>

set -euo pipefail

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

usage() {
  cat << EOF
Usage: $0 <spec-id>

Calculate and display execution metrics for a feature.

Metrics calculated:
  - Overall completion percentage
  - Average task duration
  - Estimated time remaining
  - Success rate
  - Layer-by-layer breakdown
  - Performance metrics

Example:
  $0 F001

Exit Codes:
  0 - Success
  2 - File not found
EOF
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

SPEC="$1"
STATUS_FILE=".claude/execution/${SPEC}.json"

if [[ ! -f "$STATUS_FILE" ]]; then
  echo "Error: Status file not found: $STATUS_FILE" >&2
  exit 2
fi

# Read metrics from status file
read_metrics() {
  log_info "Reading execution metrics for ${SPEC}..."

  local total_tasks completed_tasks completion_pct
  total_tasks=$(jq -r '.total_tasks' "$STATUS_FILE")
  completed_tasks=$(jq -r '.completed_tasks' "$STATUS_FILE")
  completion_pct=$(jq -r '.completion_percentage' "$STATUS_FILE")

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Execution Metrics for ${SPEC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Overall metrics
  echo "📊 Overall Progress:"
  echo "   Completion: ${completion_pct}%"
  echo "   Tasks: ${completed_tasks}/${total_tasks}"
  echo ""

  # Calculate average duration
  local avg_duration_ms durations_sum durations_count
  durations_sum=$(jq '[.layers[].tasks[] | select(.duration_ms != null) | .duration_ms] | add // 0' "$STATUS_FILE")
  durations_count=$(jq '[.layers[].tasks[] | select(.duration_ms != null)] | length' "$STATUS_FILE")

  if [[ "$durations_count" -gt 0 ]]; then
    avg_duration_ms=$((durations_sum / durations_count))
    avg_duration_sec=$((avg_duration_ms / 1000))
    avg_duration_min=$((avg_duration_sec / 60))

    echo "⏱️  Average Task Duration:"
    echo "   ${avg_duration_min}m ${avg_duration_sec}s (${avg_duration_ms}ms)"
    echo ""

    # Estimate remaining time
    local remaining_tasks estimated_ms estimated_min
    remaining_tasks=$((total_tasks - completed_tasks))
    estimated_ms=$((remaining_tasks * avg_duration_ms))
    estimated_min=$((estimated_ms / 60000))

    echo "⏳ Estimated Time Remaining:"
    echo "   ${estimated_min} minutes"
    echo "   (${remaining_tasks} tasks × ${avg_duration_min}m avg)"
    echo ""
  fi

  # Success rate
  local failed_tasks attempted_tasks success_rate
  failed_tasks=$(jq -r '.failed_tasks // 0' "$STATUS_FILE")
  attempted_tasks=$((completed_tasks + failed_tasks))

  if [[ "$attempted_tasks" -gt 0 ]]; then
    success_rate=$(( (completed_tasks * 100) / attempted_tasks ))
    echo "✅ Success Rate:"
    echo "   ${success_rate}% (${completed_tasks} succeeded, ${failed_tasks} failed)"
    echo ""
  fi

  # Layer breakdown
  echo "📂 Layer Breakdown:"
  for layer in L0 L1 L2 L3; do
    local layer_name layer_total layer_complete layer_pct
    layer_name=$(jq -r ".layers.${layer}.name // \"Unknown\"" "$STATUS_FILE")
    layer_total=$(jq -r ".layers.${layer}.total_tasks // 0" "$STATUS_FILE")
    layer_complete=$(jq -r ".layers.${layer}.completed_tasks // 0" "$STATUS_FILE")

    if [[ "$layer_total" -gt 0 ]]; then
      layer_pct=$(( (layer_complete * 100) / layer_total ))
      printf "   %s (%s): %d%% (%d/%d tasks)\n" "$layer" "$layer_name" "$layer_pct" "$layer_complete" "$layer_total"
    fi
  done
  echo ""

  # Fastest/slowest tasks
  local fastest_task slowest_task
  fastest_task=$(jq -r '[.layers[].tasks[] | select(.duration_ms != null)] | sort_by(.duration_ms) | .[0] | "\(.description) (\(.duration_ms)ms)"' "$STATUS_FILE")
  slowest_task=$(jq -r '[.layers[].tasks[] | select(.duration_ms != null)] | sort_by(.duration_ms) | .[-1] | "\(.description) (\(.duration_ms)ms)"' "$STATUS_FILE")

  if [[ "$fastest_task" != "null" ]]; then
    echo "🏃 Performance:"
    echo "   Fastest task: ${fastest_task}"
    echo "   Slowest task: ${slowest_task}"
    echo ""
  fi

  # Errors
  local error_count
  error_count=$(jq '.errors | length' "$STATUS_FILE")
  echo "❌ Errors: ${error_count}"
  echo ""
}

# Export metrics to JSON
export_metrics_json() {
  local output_file="${1:-.claude/execution/${SPEC}-metrics.json}"

  jq '{
    spec: .feature,
    completion_percentage: .completion_percentage,
    total_tasks: .total_tasks,
    completed_tasks: .completed_tasks,
    failed_tasks: .failed_tasks,
    average_duration_ms: ([.layers[].tasks[] | select(.duration_ms != null) | .duration_ms] | add / length),
    estimated_remaining_ms: (((.total_tasks - .completed_tasks) * ([.layers[].tasks[] | select(.duration_ms != null) | .duration_ms] | add / length)) // 0),
    success_rate: ((.completed_tasks / (.completed_tasks + .failed_tasks)) * 100),
    layer_metrics: [
      .layers[] | {
        name: .name,
        completion_percentage: ((.completed_tasks / .total_tasks) * 100),
        total_tasks: .total_tasks,
        completed_tasks: .completed_tasks,
        failed_tasks: .failed_tasks
      }
    ],
    error_count: (.errors | length)
  }' "$STATUS_FILE" > "$output_file"

  log_success "Metrics exported to: $output_file"
}

# Main
read_metrics

# Optional: export to JSON
if [[ "${2:-}" == "--export" ]]; then
  export_metrics_json
fi

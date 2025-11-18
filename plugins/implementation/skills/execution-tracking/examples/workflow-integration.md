# Workflow Integration Examples

This document shows how to integrate execution tracking into the implementation workflow.

## Complete Workflow: From Spec to Completion

### Step 1: Initialize Tracking

```bash
# After creating layered tasks, initialize execution tracking
bash scripts/update-status.sh init F001

# Parse layered tasks to populate status file
bash scripts/parse-layered-tasks.sh F001
```

**Result:**
- Creates `.claude/execution/F001.json`
- Populates with all tasks from `specs/F001/layered-tasks.md`
- Sets all tasks to "pending" status

---

### Step 2: Start Layer 0 Execution

```bash
# /implementation:execute command starts execution
# Before executing first task, update layer status
jq '.layers.L0.status = "in_progress" | .layers.L0.started_at = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' \
  .claude/execution/F001.json > .claude/execution/F001.json.tmp && \
  mv .claude/execution/F001.json.tmp .claude/execution/F001.json
```

**Execute tasks:**

```bash
# Task L0.0: Setup database schema
bash scripts/update-status.sh update F001 L0 0 in_progress
# ... execute command ...
bash scripts/update-status.sh update F001 L0 0 complete

# Task L0.1: Initialize API structure
bash scripts/update-status.sh update F001 L0 1 in_progress
# ... execute command ...
bash scripts/update-status.sh update F001 L0 1 complete

# Mark L0 complete
bash scripts/update-status.sh complete-layer F001 L0
```

---

### Step 3: Generate Progress Report

```bash
# After completing a layer, generate report
bash scripts/update-status.sh report F001
```

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature F001: AI Chat Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Progress: 15% (2/13 tasks)
Status: in_progress

Layer L0 (Infrastructure): ✅ complete (2/2 tasks)
Layer L1 (Core Services):   ⏳ pending (0/5 tasks)
Layer L2 (Features):        ⏳ pending (0/4 tasks)
Layer L3 (Integration):     ⏳ pending (0/2 tasks)

Errors: 0

Next Action: Continue with L1 execution
```

---

### Step 4: Continue with Remaining Layers

```bash
# L1 execution
bash scripts/update-status.sh update F001 L1 0 in_progress
# ... execute ...
bash scripts/update-status.sh update F001 L1 0 complete

# Continue for all L1 tasks
# ...

bash scripts/update-status.sh complete-layer F001 L1

# Repeat for L2, L3
```

---

### Step 5: Handle Errors

```bash
# If a task fails
bash scripts/update-status.sh error F001 L1 3 "Database connection timeout"

# Check error count
error_count=$(jq '.errors | length' .claude/execution/F001.json)

# Decide: retry, skip, or pause
if [ "$error_count" -gt 3 ]; then
  bash scripts/update-status.sh pause F001
  echo "Too many errors, pausing execution"
fi
```

---

### Step 6: Calculate Metrics

```bash
# Get detailed metrics
bash scripts/calculate-metrics.sh F001

# Export metrics to JSON
bash scripts/calculate-metrics.sh F001 --export
```

---

### Step 7: Final Completion

```bash
# When all layers complete
bash scripts/update-status.sh complete-layer F001 L3

# Verify 100% completion
bash scripts/update-status.sh report F001
```

**Final Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature F001: AI Chat Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Progress: 100% (13/13 tasks) ✅
Status: complete
Total Duration: 2 hours

Layer L0 (Infrastructure): ✅ complete (2/2 tasks)
Layer L1 (Core Services):   ✅ complete (5/5 tasks)
Layer L2 (Features):        ✅ complete (4/4 tasks)
Layer L3 (Integration):     ✅ complete (2/2 tasks)

Errors: 0

Next Action: Run tests with /testing:test F001
```

---

## Integration with Agents

### progress-tracker Agent

The `progress-tracker` agent reads status files and generates real-time reports:

```python
# In progress-tracker agent
def check_progress(spec_id):
    status_file = f".claude/execution/{spec_id}.json"

    with open(status_file) as f:
        status = json.load(f)

    # Calculate current progress
    progress = status['completion_percentage']
    current_layer = status['current_layer']

    # Generate report
    report = generate_report(status)

    # Return to user
    return report
```

### error-handler Agent

The `error-handler` agent logs errors and suggests recovery:

```python
# In error-handler agent
def handle_error(spec_id, layer, task_idx, error_msg):
    # Log error
    subprocess.run([
        "bash", "scripts/update-status.sh", "error",
        spec_id, layer, str(task_idx), error_msg
    ])

    # Suggest recovery
    recovery = suggest_recovery(error_msg)

    # Pause if critical
    if is_critical_error(error_msg):
        subprocess.run([
            "bash", "scripts/update-status.sh", "pause", spec_id
        ])
```

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Track Implementation Progress

on:
  workflow_dispatch:
    inputs:
      spec_id:
        description: 'Spec ID (e.g., F001)'
        required: true

jobs:
  track-progress:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Generate Progress Report
        run: |
          bash plugins/implementation/skills/execution-tracking/scripts/update-status.sh report ${{ github.event.inputs.spec_id }}

      - name: Calculate Metrics
        run: |
          bash plugins/implementation/skills/execution-tracking/scripts/calculate-metrics.sh ${{ github.event.inputs.spec_id }} --export

      - name: Upload Metrics
        uses: actions/upload-artifact@v3
        with:
          name: execution-metrics
          path: .claude/execution/${{ github.event.inputs.spec_id }}-metrics.json
```

---

## Real-Time Monitoring

### Watch Script

```bash
#!/usr/bin/env bash
# watch-progress.sh - Real-time progress monitoring

SPEC="$1"
INTERVAL="${2:-5}"  # Default: 5 seconds

while true; do
  clear
  bash scripts/update-status.sh report "$SPEC"
  sleep "$INTERVAL"
done
```

**Usage:**
```bash
bash watch-progress.sh F001 5
```

---

## Status Webhooks

### Send Updates to Slack

```bash
#!/usr/bin/env bash
# notify-slack.sh - Send progress to Slack

SPEC="$1"
STATUS_FILE=".claude/execution/${SPEC}.json"

# Extract data
completion=$(jq -r '.completion_percentage' "$STATUS_FILE")
status=$(jq -r '.status' "$STATUS_FILE")

# Send to Slack
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d "{
    \"text\": \"Feature $SPEC: ${completion}% complete (status: ${status})\"
  }"
```

---

## Best Practices

### 1. Update After Each Task
```bash
# Always update immediately after task completion
execute_task && update_status complete
```

### 2. Generate Reports Regularly
```bash
# After each layer completion
bash scripts/update-status.sh complete-layer F001 L0
bash scripts/update-status.sh report F001
```

### 3. Monitor Errors
```bash
# Check error count before continuing
error_count=$(jq '.errors | length' .claude/execution/F001.json)
if [ "$error_count" -gt 0 ]; then
  echo "Errors detected, review before continuing"
fi
```

### 4. Archive Completed Executions
```bash
# After completion, archive status file
mkdir -p .claude/execution/archive
cp .claude/execution/F001.json .claude/execution/archive/F001-$(date +%Y%m%d).json
```

---

## Troubleshooting

### Status File Corrupted
```bash
# Restore from backup
cp .claude/execution/F001.json.bak .claude/execution/F001.json

# Or re-initialize
bash scripts/update-status.sh init F001
bash scripts/parse-layered-tasks.sh F001
```

### Metrics Not Calculating
```bash
# Ensure tasks have duration_ms
jq '.layers.L0.tasks[0].duration_ms' .claude/execution/F001.json

# Recalculate manually
bash scripts/calculate-metrics.sh F001
```

### Report Generation Fails
```bash
# Check jq is installed
which jq

# Validate JSON syntax
jq empty .claude/execution/F001.json

# Check file permissions
chmod 644 .claude/execution/F001.json
```

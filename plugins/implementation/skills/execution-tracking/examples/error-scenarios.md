# Error Scenarios and Recovery Patterns

This document describes common error scenarios during execution and recommended recovery patterns.

## Scenario 1: Database Connection Timeout

### Error Details
```json
{
  "layer": "L1",
  "task_index": 2,
  "error": "Database connection timeout after 30 seconds",
  "timestamp": "2025-11-17T12:25:00Z",
  "severity": "high"
}
```

### Symptoms
- Task status: `failed`
- Task output: `null`
- Error logged in `errors` array
- Execution continues to next task (non-blocking)

### Recovery Steps

1. **Diagnose the issue:**
```bash
# Check database connection string
cat .env | grep DATABASE_URL

# Test connection manually
psql $DATABASE_URL -c "SELECT 1;"
```

2. **Fix the issue:**
```bash
# Update connection string if incorrect
echo "DATABASE_URL=postgresql://user:pass@localhost:5432/db" >> .env

# Or restart database if down
docker restart postgres-db
```

3. **Retry the failed task:**
```bash
# Reset task status to pending
jq '.layers.L1.tasks[2].status = "pending" |
    .layers.L1.tasks[2].error = null |
    .failed_tasks = (.failed_tasks - 1)' \
  .claude/execution/F001.json > .claude/execution/F001.json.tmp && \
  mv .claude/execution/F001.json.tmp .claude/execution/F001.json

# Re-execute the task
bash scripts/update-status.sh update F001 L1 2 in_progress
# ... execute command ...
bash scripts/update-status.sh update F001 L1 2 complete
```

---

## Scenario 2: API Key Missing

### Error Details
```json
{
  "layer": "L2",
  "task_index": 1,
  "error": "OPENAI_API_KEY environment variable not set",
  "timestamp": "2025-11-17T13:15:00Z",
  "severity": "critical"
}
```

### Symptoms
- Execution paused (critical error)
- Status: `paused`
- Task status: `failed`
- Error severity: `critical`

### Recovery Steps

1. **Set the missing API key:**
```bash
# Add to .env
echo "OPENAI_API_KEY=your_openai_key_here" >> .env

# Reload environment
source .env
```

2. **Resume execution:**
```bash
# Reset failed task
jq '.layers.L2.tasks[1].status = "pending" |
    .layers.L2.tasks[1].error = null' \
  .claude/execution/F001.json > .claude/execution/F001.json.tmp && \
  mv .claude/execution/F001.json.tmp .claude/execution/F001.json

# Resume execution
bash scripts/update-status.sh resume F001

# Re-execute task
bash scripts/update-status.sh update F001 L2 1 in_progress
# ... execute command ...
bash scripts/update-status.sh update F001 L2 1 complete
```

---

## Scenario 3: Dependency Task Failed

### Error Details
```json
{
  "layer": "L1",
  "task_index": 4,
  "error": "Cannot execute: dependency task L1.3 failed",
  "timestamp": "2025-11-17T12:30:00Z",
  "severity": "medium"
}
```

### Symptoms
- Task status: `skipped`
- Dependency task status: `failed`
- Task not executed
- Execution continues with independent tasks

### Recovery Steps

1. **Fix the dependency task first:**
```bash
# Fix and retry dependency (L1.3)
# ... fix issue ...
bash scripts/update-status.sh update F001 L1 3 pending
bash scripts/update-status.sh update F001 L1 3 in_progress
# ... execute command ...
bash scripts/update-status.sh update F001 L1 3 complete
```

2. **Retry the skipped task:**
```bash
# Reset skipped task
jq '.layers.L1.tasks[4].status = "pending" |
    .skipped_tasks = (.skipped_tasks - 1)' \
  .claude/execution/F001.json > .claude/execution/F001.json.tmp && \
  mv .claude/execution/F001.json.tmp .claude/execution/F001.json

# Execute task
bash scripts/update-status.sh update F001 L1 4 in_progress
# ... execute command ...
bash scripts/update-status.sh update F001 L1 4 complete
```

---

## Scenario 4: File Permission Error

### Error Details
```json
{
  "layer": "L0",
  "task_index": 1,
  "error": "Permission denied: cannot write to backend/app/main.py",
  "timestamp": "2025-11-17T12:08:00Z",
  "severity": "high"
}
```

### Symptoms
- Task status: `failed`
- File creation/modification blocked
- Execution continues

### Recovery Steps

1. **Fix permissions:**
```bash
# Check current permissions
ls -la backend/app/

# Fix permissions
chmod 644 backend/app/main.py
# Or for directory
chmod 755 backend/app/

# Check ownership
sudo chown $USER:$USER backend/app/main.py
```

2. **Retry task:**
```bash
# Reset and retry
bash scripts/update-status.sh update F001 L0 1 pending
bash scripts/update-status.sh update F001 L0 1 in_progress
# ... execute command ...
bash scripts/update-status.sh update F001 L0 1 complete
```

---

## Scenario 5: Command Not Found

### Error Details
```json
{
  "layer": "L2",
  "task_index": 0,
  "error": "Command not found: /nextjs-frontend:add-component",
  "timestamp": "2025-11-17T13:00:00Z",
  "severity": "critical"
}
```

### Symptoms
- Execution paused
- Status: `paused`
- Task status: `failed`
- Missing plugin or command

### Recovery Steps

1. **Install missing plugin:**
```bash
# Check enabled plugins
cat ~/.claude/settings.json | jq '.enabledPlugins'

# Enable plugin if not enabled
# ... enable nextjs-frontend plugin ...

# Verify command exists
# /nextjs-frontend:add-component --help
```

2. **Resume execution:**
```bash
# Reset failed task
bash scripts/update-status.sh update F001 L2 0 pending

# Resume
bash scripts/update-status.sh resume F001

# Execute task
bash scripts/update-status.sh update F001 L2 0 in_progress
# ... execute command ...
bash scripts/update-status.sh update F001 L2 0 complete
```

---

## Scenario 6: Too Many Errors (Auto-Pause)

### Error Details
```json
{
  "errors": [
    {"layer": "L1", "task_index": 2, "error": "..."},
    {"layer": "L1", "task_index": 3, "error": "..."},
    {"layer": "L1", "task_index": 4, "error": "..."},
    {"layer": "L2", "task_index": 0, "error": "..."}
  ]
}
```

### Symptoms
- 3+ errors in short time
- Execution auto-paused
- Status: `paused`
- Multiple failed tasks

### Recovery Steps

1. **Review all errors:**
```bash
# List all errors
jq -r '.errors[] | "[\(.layer)] Task \(.task_index): \(.error)"' .claude/execution/F001.json
```

2. **Identify common cause:**
```bash
# Check for patterns
jq -r '.errors[].error' .claude/execution/F001.json | sort | uniq -c
```

3. **Fix root cause:**
```bash
# Example: All errors are database-related
# Fix database connection
# Update .env
# Restart database
```

4. **Reset all failed tasks:**
```bash
# Reset all failed tasks to pending
jq '.layers[].tasks[] |= (if .status == "failed" then .status = "pending" | .error = null else . end) |
    .failed_tasks = 0 |
    .errors = []' \
  .claude/execution/F001.json > .claude/execution/F001.json.tmp && \
  mv .claude/execution/F001.json.tmp .claude/execution/F001.json

# Resume execution
bash scripts/update-status.sh resume F001
```

---

## Error Severity Levels

### Critical (Execution Paused)
- Missing API keys
- Missing dependencies/plugins
- File system full
- Permission denied (critical files)

**Action:** Pause execution, require manual intervention

### High (Log and Continue)
- Database connection timeout
- API rate limit exceeded
- Network timeout
- File not found

**Action:** Log error, continue with next task, allow manual retry

### Medium (Skip Dependent Tasks)
- Dependency task failed
- Optional feature unavailable
- Non-critical configuration missing

**Action:** Skip task, log warning, continue

### Low (Warning Only)
- Slow task execution
- Large file generated
- Deprecated API used

**Action:** Log warning, continue normally

---

## Error Recovery Patterns

### Pattern 1: Retry with Exponential Backoff
```bash
#!/usr/bin/env bash
# retry-task.sh

SPEC="$1"
LAYER="$2"
TASK_IDX="$3"
MAX_RETRIES=3

for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i of $MAX_RETRIES"

  bash scripts/update-status.sh update "$SPEC" "$LAYER" "$TASK_IDX" in_progress
  # ... execute command ...

  if [ $? -eq 0 ]; then
    bash scripts/update-status.sh update "$SPEC" "$LAYER" "$TASK_IDX" complete
    exit 0
  else
    sleep $((2 ** i))  # Exponential backoff
  fi
done

bash scripts/update-status.sh error "$SPEC" "$LAYER" "$TASK_IDX" "Failed after $MAX_RETRIES attempts"
exit 1
```

### Pattern 2: Fallback to Alternative
```bash
#!/usr/bin/env bash
# fallback-task.sh

SPEC="$1"
LAYER="$2"
TASK_IDX="$3"
PRIMARY_COMMAND="$4"
FALLBACK_COMMAND="$5"

# Try primary
bash scripts/update-status.sh update "$SPEC" "$LAYER" "$TASK_IDX" in_progress
eval "$PRIMARY_COMMAND"

if [ $? -ne 0 ]; then
  echo "Primary command failed, trying fallback..."
  eval "$FALLBACK_COMMAND"

  if [ $? -eq 0 ]; then
    bash scripts/update-status.sh update "$SPEC" "$LAYER" "$TASK_IDX" complete
    echo "Fallback succeeded"
    exit 0
  fi
fi

bash scripts/update-status.sh error "$SPEC" "$LAYER" "$TASK_IDX" "Both primary and fallback failed"
exit 1
```

### Pattern 3: Partial Success
```bash
#!/usr/bin/env bash
# partial-success.sh

SPEC="$1"
LAYER="$2"
TASK_IDX="$3"

# Execute task
bash scripts/update-status.sh update "$SPEC" "$LAYER" "$TASK_IDX" in_progress
# ... execute command ...

# Check result
if [ -f "output.json" ]; then
  success_count=$(jq '.successful | length' output.json)
  failed_count=$(jq '.failed | length' output.json)

  if [ "$failed_count" -gt 0 ]; then
    # Partial success - log warning but mark complete
    jq --arg msg "Partial success: $success_count succeeded, $failed_count failed" \
       '.warnings += [{"message": $msg, "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'", "severity": "medium"}]' \
       .claude/execution/${SPEC}.json > .claude/execution/${SPEC}.json.tmp && \
       mv .claude/execution/${SPEC}.json.tmp .claude/execution/${SPEC}.json

    bash scripts/update-status.sh update "$SPEC" "$LAYER" "$TASK_IDX" complete
  else
    bash scripts/update-status.sh update "$SPEC" "$LAYER" "$TASK_IDX" complete
  fi
fi
```

---

## Prevention Best Practices

1. **Validate before execution:**
   - Check environment variables
   - Verify file permissions
   - Test database connections
   - Confirm plugins enabled

2. **Use idempotent commands:**
   - Commands should be safe to re-run
   - Check if resource exists before creating
   - Use `--force` flags carefully

3. **Log everything:**
   - Capture stdout and stderr
   - Save to task `output` field
   - Keep detailed error messages

4. **Test in development first:**
   - Run execution in dev environment
   - Identify errors early
   - Fix before production run

5. **Set up monitoring:**
   - Watch execution in real-time
   - Alert on errors
   - Review logs regularly

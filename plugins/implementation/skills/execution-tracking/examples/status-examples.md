# Execution Status Examples

This document shows example status files at different stages of feature implementation.

## Example 1: Just Initialized (0% Complete)

**Status:** `pending`
**Progress:** 0/13 tasks (0%)
**Current Layer:** L0

```json
{
  "feature": "F001",
  "feature_name": "AI Chat Interface",
  "started_at": "2025-11-17T12:00:00Z",
  "last_updated": "2025-11-17T12:00:00Z",
  "status": "pending",
  "current_layer": "L0",
  "total_tasks": 13,
  "completed_tasks": 0,
  "failed_tasks": 0,
  "skipped_tasks": 0,
  "completion_percentage": 0,
  "average_task_duration_ms": 0,
  "estimated_remaining_ms": 0,
  "layers": {
    "L0": {"status": "pending", "total_tasks": 2, "completed_tasks": 0},
    "L1": {"status": "pending", "total_tasks": 5, "completed_tasks": 0},
    "L2": {"status": "pending", "total_tasks": 4, "completed_tasks": 0},
    "L3": {"status": "pending", "total_tasks": 2, "completed_tasks": 0}
  },
  "errors": [],
  "warnings": [],
  "next_action": "Start execution with /implementation:execute F001"
}
```

**Console Report:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature F001: AI Chat Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Progress: 0% (0/13 tasks)
Status: pending

Layer L0 (Infrastructure): ⏳ pending (0/2 tasks)
Layer L1 (Core Services):   ⏳ pending (0/5 tasks)
Layer L2 (Features):        ⏳ pending (0/4 tasks)
Layer L3 (Integration):     ⏳ pending (0/2 tasks)

Errors: 0

Next Action: Start execution with /implementation:execute F001
```

---

## Example 2: L0 In Progress (8% Complete)

**Status:** `in_progress`
**Progress:** 1/13 tasks (8%)
**Current Layer:** L0

```json
{
  "feature": "F001",
  "feature_name": "AI Chat Interface",
  "started_at": "2025-11-17T12:00:00Z",
  "last_updated": "2025-11-17T12:05:00Z",
  "status": "in_progress",
  "current_layer": "L0",
  "total_tasks": 13,
  "completed_tasks": 1,
  "failed_tasks": 0,
  "skipped_tasks": 0,
  "completion_percentage": 8,
  "average_task_duration_ms": 300000,
  "estimated_remaining_ms": 3600000,
  "layers": {
    "L0": {
      "status": "in_progress",
      "total_tasks": 2,
      "completed_tasks": 1,
      "tasks": [
        {
          "index": 0,
          "description": "Setup database schema",
          "status": "complete",
          "completed_at": "2025-11-17T12:05:00Z",
          "duration_ms": 300000
        },
        {
          "index": 1,
          "description": "Initialize API structure",
          "status": "in_progress",
          "started_at": "2025-11-17T12:05:00Z"
        }
      ]
    }
  },
  "errors": [],
  "warnings": [],
  "next_action": "Continue L0: Task 1 in progress"
}
```

**Console Report:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature F001: AI Chat Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Progress: 8% (1/13 tasks)
Status: in_progress
Time Elapsed: 5 minutes
Estimated Remaining: 60 minutes

Layer L0 (Infrastructure): 🔄 in_progress (1/2 tasks)
Layer L1 (Core Services):   ⏳ pending (0/5 tasks)
Layer L2 (Features):        ⏳ pending (0/4 tasks)
Layer L3 (Integration):     ⏳ pending (0/2 tasks)

Currently Executing:
- Initialize API structure (fastapi-agent, easy) - Started 0m ago

Errors: 0

Next Action: Continue L0: Task 1 in progress
```

---

## Example 3: L0 Complete, L1 In Progress (38% Complete)

**Status:** `in_progress`
**Progress:** 5/13 tasks (38%)
**Current Layer:** L1

```json
{
  "feature": "F001",
  "feature_name": "AI Chat Interface",
  "started_at": "2025-11-17T12:00:00Z",
  "last_updated": "2025-11-17T12:30:00Z",
  "status": "in_progress",
  "current_layer": "L1",
  "total_tasks": 13,
  "completed_tasks": 5,
  "failed_tasks": 0,
  "skipped_tasks": 0,
  "completion_percentage": 38,
  "average_task_duration_ms": 360000,
  "estimated_remaining_ms": 2880000,
  "layers": {
    "L0": {
      "status": "complete",
      "total_tasks": 2,
      "completed_tasks": 2,
      "completed_at": "2025-11-17T12:10:00Z",
      "duration_ms": 600000
    },
    "L1": {
      "status": "in_progress",
      "total_tasks": 5,
      "completed_tasks": 3,
      "tasks": [
        {"index": 0, "status": "complete"},
        {"index": 1, "status": "complete"},
        {"index": 2, "status": "complete"},
        {"index": 3, "status": "in_progress", "started_at": "2025-11-17T12:25:00Z"},
        {"index": 4, "status": "pending"}
      ]
    }
  },
  "errors": [],
  "warnings": [],
  "next_action": "Continue L1: 2 tasks remaining"
}
```

**Console Report:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature F001: AI Chat Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Progress: 38% (5/13 tasks)
Status: in_progress
Time Elapsed: 30 minutes
Estimated Remaining: 48 minutes

Layer L0 (Infrastructure): ✅ complete (2/2 tasks)
Layer L1 (Core Services):   🔄 in_progress (3/5 tasks)
Layer L2 (Features):        ⏳ pending (0/4 tasks)
Layer L3 (Integration):     ⏳ pending (0/2 tasks)

Currently Executing:
- Create conversation management (fastapi-agent, medium) - Started 5m ago

Next 2 Pending Tasks:
1. [L1] Add real-time subscriptions (supabase-agent, hard)
2. [L2] Build chat UI component (react-agent, hard)

Errors: 0

Next Action: Continue L1: 2 tasks remaining
```

---

## Example 4: Execution with Errors (31% Complete)

**Status:** `in_progress`
**Progress:** 4/13 tasks (31%)
**Current Layer:** L1
**Errors:** 1

```json
{
  "feature": "F001",
  "feature_name": "AI Chat Interface",
  "started_at": "2025-11-17T12:00:00Z",
  "last_updated": "2025-11-17T12:30:00Z",
  "status": "in_progress",
  "current_layer": "L1",
  "total_tasks": 13,
  "completed_tasks": 4,
  "failed_tasks": 1,
  "skipped_tasks": 0,
  "completion_percentage": 31,
  "layers": {
    "L0": {"status": "complete", "total_tasks": 2, "completed_tasks": 2},
    "L1": {
      "status": "in_progress",
      "total_tasks": 5,
      "completed_tasks": 2,
      "failed_tasks": 1,
      "tasks": [
        {"index": 0, "status": "complete"},
        {"index": 1, "status": "complete"},
        {"index": 2, "status": "failed", "error": "Database connection timeout"},
        {"index": 3, "status": "pending"},
        {"index": 4, "status": "pending"}
      ]
    }
  },
  "errors": [
    {
      "layer": "L1",
      "task_index": 2,
      "error": "Database connection timeout after 30s",
      "timestamp": "2025-11-17T12:25:00Z",
      "severity": "high"
    }
  ],
  "warnings": [],
  "next_action": "Fix L1 task 2 error before continuing"
}
```

**Console Report:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature F001: AI Chat Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Progress: 31% (4/13 tasks, 1 failed)
Status: in_progress
Time Elapsed: 30 minutes

Layer L0 (Infrastructure): ✅ complete (2/2 tasks)
Layer L1 (Core Services):   🔄 in_progress (2/5 tasks, 1 failed)
Layer L2 (Features):        ⏳ pending (0/4 tasks)
Layer L3 (Integration):     ⏳ pending (0/2 tasks)

Errors: 1

Recent Errors:
  - [L1] Database connection timeout after 30s

Next Action: Fix L1 task 2 error before continuing
```

---

## Example 5: Execution Paused (54% Complete)

**Status:** `paused`
**Progress:** 7/13 tasks (54%)
**Current Layer:** L2

```json
{
  "feature": "F001",
  "feature_name": "AI Chat Interface",
  "started_at": "2025-11-17T12:00:00Z",
  "last_updated": "2025-11-17T13:00:00Z",
  "status": "paused",
  "current_layer": "L2",
  "total_tasks": 13,
  "completed_tasks": 7,
  "failed_tasks": 0,
  "skipped_tasks": 0,
  "completion_percentage": 54,
  "layers": {
    "L0": {"status": "complete", "total_tasks": 2, "completed_tasks": 2},
    "L1": {"status": "complete", "total_tasks": 5, "completed_tasks": 5},
    "L2": {"status": "in_progress", "total_tasks": 4, "completed_tasks": 0}
  },
  "errors": [],
  "warnings": [
    {
      "message": "Execution paused by user",
      "timestamp": "2025-11-17T13:00:00Z",
      "severity": "info"
    }
  ],
  "next_action": "Resume with /implementation:execute F001 --resume"
}
```

**Console Report:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature F001: AI Chat Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Progress: 54% (7/13 tasks)
Status: ⏸️  paused
Time Elapsed: 60 minutes

Layer L0 (Infrastructure): ✅ complete (2/2 tasks)
Layer L1 (Core Services):   ✅ complete (5/5 tasks)
Layer L2 (Features):        🔄 in_progress (0/4 tasks)
Layer L3 (Integration):     ⏳ pending (0/2 tasks)

Errors: 0

Next Action: Resume with /implementation:execute F001 --resume
```

---

## Example 6: Complete (100%)

**Status:** `complete`
**Progress:** 13/13 tasks (100%)
**Current Layer:** complete

```json
{
  "feature": "F001",
  "feature_name": "AI Chat Interface",
  "started_at": "2025-11-17T12:00:00Z",
  "last_updated": "2025-11-17T14:00:00Z",
  "status": "complete",
  "current_layer": "complete",
  "total_tasks": 13,
  "completed_tasks": 13,
  "failed_tasks": 0,
  "skipped_tasks": 0,
  "completion_percentage": 100,
  "average_task_duration_ms": 554000,
  "total_duration_ms": 7200000,
  "layers": {
    "L0": {"status": "complete", "total_tasks": 2, "completed_tasks": 2},
    "L1": {"status": "complete", "total_tasks": 5, "completed_tasks": 5},
    "L2": {"status": "complete", "total_tasks": 4, "completed_tasks": 4},
    "L3": {"status": "complete", "total_tasks": 2, "completed_tasks": 2}
  },
  "errors": [],
  "warnings": [],
  "next_action": "Run tests with /testing:test F001"
}
```

**Console Report:**
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

## Status File Lifecycle

```
pending (0%)
    ↓
in_progress (1-99%)
    ↓ (optional)
paused
    ↓
in_progress
    ↓
complete (100%)
```

## Common Status Transitions

1. **Init → Start Execution**
   - `pending` → `in_progress`
   - `current_layer` = "L0"
   - First task starts

2. **Layer Complete**
   - Layer status: `in_progress` → `complete`
   - `current_layer` advances: L0 → L1 → L2 → L3

3. **Error Encountered**
   - Task status: `in_progress` → `failed`
   - Error added to errors array
   - Execution can continue or pause

4. **Pause Execution**
   - Overall status: `in_progress` → `paused`
   - Current task remains `in_progress`

5. **Resume Execution**
   - Overall status: `paused` → `in_progress`
   - Continue from paused task

6. **Final Completion**
   - All layers: `complete`
   - Overall: `in_progress` → `complete`
   - `current_layer` = "complete"

## Using Status Files

### Initialize
```bash
bash scripts/update-status.sh init F001
```

### Update Task
```bash
bash scripts/update-status.sh update F001 L1 2 complete
```

### Complete Layer
```bash
bash scripts/update-status.sh complete-layer F001 L1
```

### Log Error
```bash
bash scripts/update-status.sh error F001 L1 3 "Connection timeout"
```

### Generate Report
```bash
bash scripts/update-status.sh report F001
```

### Pause/Resume
```bash
bash scripts/update-status.sh pause F001
bash scripts/update-status.sh resume F001
```

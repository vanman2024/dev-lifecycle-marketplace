---
description: Monitor agent progress and task completion during development
argument-hint: <spec-name> [--test]
---

**Arguments**: $ARGUMENTS

## Goal

Mid-work monitoring to track agent progress, identify stuck agents, and validate ongoing compliance with task assignments.

## Phase 1: Discovery

Actions:
- Parse spec name and flags from $ARGUMENTS
- Check if --test flag provided (runs tests in worktrees)
- Verify spec directory and layered-tasks.md exist
- Get list of active worktrees

## Phase 2: Progress Monitoring

Actions:
- Run mid monitoring script: !{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/supervisor/skills/worktree-orchestration/scripts/mid-monitoring.sh $ARGUMENTS}
- Parse monitoring results
- Calculate completion percentages
- Identify stale or blocked agents
- If --test flag: Run tests in each worktree and collect results

## Phase 3: Status Dashboard

Display:
- Progress: X/Y tasks completed (Z%)
- Agent status table (agent, worktree, tasks complete, status)
- Stale agents (no commits in X hours)
- Test results if --test flag used

## Phase 4: Recommendations

Actions:
- Suggest interventions for stuck agents
- Recommend priority tasks
- Next check: Re-run /supervisor:mid in 1-2 hours

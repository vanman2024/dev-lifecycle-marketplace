---
description: Verify agent setup and worktree readiness before work begins
argument-hint: <spec-name>
---

**Arguments**: $ARGUMENTS

## Goal

Pre-work verification to ensure all agents have proper worktree setup, task assignments, and branch isolation before beginning parallel development.

## Phase 1: Discovery

Actions:
- Parse spec name: $ARGUMENTS
- Verify spec directory: specs/$ARGUMENTS
- Check layered-tasks.md exists and is readable
- Verify worktrees exist for this spec

## Phase 2: Verification

Actions:
- Run start verification script: !{bash plugins/supervisor/skills/worktree-orchestration/scripts/start-verification.sh $ARGUMENTS}
- Parse verification results (JSON or human-readable)
- Check worktree status for each agent
- Verify git state is clean
- Count tasks assigned per agent

## Phase 3: Status Report

Display:
- Overall status: READY or BLOCKED
- Active worktrees count
- Task assignments per agent
- Any blockers found
- Fix commands if blocked

## Phase 4: Next Steps

If READY:
- Agents can begin work in their worktrees
- Monitor progress with /supervisor:mid

If BLOCKED:
- Show fix commands
- Re-run /supervisor:start after fixes

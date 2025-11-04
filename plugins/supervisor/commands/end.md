---
allowed-tools: Bash, Read, Write
description: Validate completion and generate PR commands before creating pull requests
argument-hint: <spec-name>
---

**Arguments**: $ARGUMENTS

## Goal

Pre-PR validation to ensure all work is complete, tests pass, code quality is met, and main branch is protected. Generates commands for pushing branches and creating PRs.

## Phase 1: Discovery

Actions:
- Parse spec name: $ARGUMENTS
- Verify spec directory and layered-tasks.md
- Get list of active worktrees for this spec

## Phase 2: Completion Validation

Actions:
- Run end verification script: !{bash plugins/supervisor/skills/worktree-orchestration/scripts/end-verification.sh $ARGUMENTS}
- Check all tasks marked complete in layered-tasks.md
- Verify no uncommitted work in worktrees
- Validate main branch has no agent commits (protection check)
- Check PR readiness status

## Phase 3: PR Generation

If READY:
- Generate push commands for each worktree
- Generate gh pr create commands with proper titles/bodies
- Generate worktree cleanup commands (for after merge)

If BLOCKED:
- Show blockers (incomplete tasks, failing tests, main polluted)
- Provide fix recommendations

## Phase 4: Summary

Display:
- Overall status: READY or BLOCKED
- Task completion: X/Y (Z%)
- PR readiness per agent
- Generated commands to execute
- Worktree cleanup commands for after PR merge

Next Steps:
- If READY: Execute PR commands, then clean up worktrees after merge
- If BLOCKED: Fix issues and re-run /supervisor:end

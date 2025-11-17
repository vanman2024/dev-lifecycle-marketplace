---
description: Validate completion and generate PR commands before creating pull requests
argument-hint: <spec-name>
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

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
- Run end verification script: !{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/supervisor/skills/worktree-orchestration/scripts/end-verification.sh $ARGUMENTS}
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

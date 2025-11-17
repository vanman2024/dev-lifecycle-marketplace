---
description: Verify agent setup and worktree readiness before work begins
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

Pre-work verification to ensure all agents have proper worktree setup, task assignments, and branch isolation before beginning parallel development.

## Phase 1: Discovery

Actions:
- Parse spec name: $ARGUMENTS
- Verify spec directory: specs/$ARGUMENTS
- Check layered-tasks.md exists and is readable
- Verify worktrees exist for this spec

## Phase 2: Verification

Actions:
- Run start verification script: !{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/supervisor/skills/worktree-orchestration/scripts/start-verification.sh $ARGUMENTS}
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

---
description: "[DEPRECATED] Use /planning:add-feature instead - adds spec with similarity checking and complete planning sync"
argument-hint: <feature-description>
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

⚠️ **DEPRECATED COMMAND**

This command has been deprecated in favor of `/planning:add-feature`.

## Why This Changed

**The Problem:**
- `/planning:add-spec` created specs without checking for duplicates
- No similarity detection → overlapping/duplicate specs
- No roadmap sync → planning docs out of sync
- No ADR creation → architecture decisions not tracked

**The Solution:**
Use `/planning:add-feature` instead, which:
- ✅ Similarity checking (prevents duplicates)
- ✅ Updates ROADMAP.md automatically
- ✅ Creates ADRs for architecture decisions
- ✅ Updates architecture docs
- ✅ Keeps all planning in sync

## Migration

**Old way (DEPRECATED):**
```bash
/planning:add-spec "email notifications"
→ Blindly creates spec 021
→ Might duplicate existing notification spec
```

**New way (RECOMMENDED):**
```bash
/planning:add-feature "email notifications"
→ Checks similarity with existing specs
→ Finds spec 003 "notification system" (87% match)
→ Asks: New feature or enhancement?
→ Routes correctly, no duplicates
```

## Automatic Redirect

This command will automatically redirect you to `/planning:add-feature`.

Phase 1: Deprecation Warning
Goal: Inform user and redirect

Actions:
- Display deprecation warning
- Explain why `/planning:add-feature` is better
- Ask user confirmation to proceed with redirect

Phase 2: Redirect
Goal: Route to correct command

Actions:
- Display: "Redirecting to /planning:add-feature with your description..."
- Display: "Please run: /planning:add-feature $ARGUMENTS"
- Explain what the new command will do:
  - Check for similar existing specs
  - Ask priority, phase, dependencies
  - Update roadmap automatically
  - Create ADRs if needed
  - Keep all docs in sync
- Exit (user should run /planning:add-feature)

## For Documentation

**Command Status:** DEPRECATED as of 2025-11-05
**Replacement:** `/planning:add-feature`
**Reason:** Similarity checking required to prevent duplicate specs
**Breaking Change:** No - command still exists but redirects

---
allowed-tools: Bash, Read
description: Reorganize .bashrc into clean, deduplicated sections with backup
argument-hint: none
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


**Bashrc Organizer**

Reorganizes your .bashrc into clean, logical sections:
1. System Defaults (Ubuntu/Debian defaults)
2. Environment Variables (deduplicated)
3. PATH Configuration (consolidated, no duplicates)
4. Aliases (deduplicated)
5. Functions (organized)
6. Tool Loaders (NVM, Google Cloud, etc.)
7. Application Secrets (.env loaders)

## What it does:

- ✅ Removes ALL duplicate PATH entries
- ✅ Removes ALL duplicate exports
- ✅ Removes ALL duplicate aliases
- ✅ Removes "moved to" comment lines (dead code)
- ✅ Consolidates NVM loading (single location)
- ✅ Organizes into clear sections
- ✅ Creates timestamped backup

## Execute Organization

!{bash plugins/01-core/skills/bashrc-management/scripts/bashrc-organize.sh}

**IMPORTANT**: This will prompt you before replacing your .bashrc.
You can preview the organized version and compare with diff first.

## After organizing:

Apply changes:
```bash
source ~/.bashrc
```

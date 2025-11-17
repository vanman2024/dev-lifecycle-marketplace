---
allowed-tools: Bash, Read
description: Analyze .bashrc for duplicates, conflicts, and organization issues
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


**Bashrc Analysis Tool**

Analyzes your .bashrc file to detect:
- Duplicate PATH entries
- Duplicate exports and aliases
- Loading conflicts (NVM, env files, etc.)
- Commented/dead code
- Organization issues

## Execute Analysis

!{bash plugins/01-core/skills/bashrc-management/scripts/bashrc-analyze.sh}

Shows detailed report with line numbers and recommendations.

## Next Steps

After reviewing the analysis, run:
```
/01-core:bashrc-organize
```

This will create an organized version with automatic backup.

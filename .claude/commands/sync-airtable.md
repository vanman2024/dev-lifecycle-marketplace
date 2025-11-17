---
description: Sync Airtable database with current filesystem state and validate
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


**Goal**: Update Airtable with latest plugin changes and validate data accuracy

## Phase 1: Sync Filesystem to Airtable

Run sync script:
```bash
cd /home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace
python3 scripts/sync-airtable.py
```

Expected output:
- Found X agents, Y commands, Z skills
- Updates for changed components
- Re-linking relationships

## Phase 2: Validate Data Accuracy

Run validation:
```bash
python3 scripts/validate-airtable.py
```

Expected output:
- Total Errors count
- Total Warnings count
- VALIDATION PASSED or FAILED

## Phase 3: Report Summary

Provide user with:
- Number of components synced
- Any errors or warnings found
- Whether validation passed
- Link to Airtable: https://airtable.com/appHbSB7WhT1TxEQb

## When to Use This Command

Run this after:
- Creating new agents, commands, or skills
- Modifying frontmatter in existing components
- Moving or renaming plugin files
- Major refactoring of plugin structure
- Before populating other marketplaces

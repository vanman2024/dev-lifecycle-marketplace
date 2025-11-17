---
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
description: Manage development notes and decision logs
argument-hint: <add|view|search> [query]
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

## Step 1: Parse Action

Determine what action to take:

!{bash echo "$ARGUMENTS" | cut -d' ' -f1}

## Step 2: Initialize Notes Directory

Ensure notes directory exists:

!{bash mkdir -p docs/notes && echo "✅ Notes directory ready"}

## Step 3: Execute Action

### If action is "add":

Create new note with timestamp:

!{bash DATE=$(date +%Y%m%d-%H%M%S) && echo "Creating note: docs/notes/$DATE.md"}

Prompt user for note content and create file.

### If action is "view":

List all notes:

!{bash ls -lt docs/notes/*.md 2>/dev/null | head -10}

Show recent notes:

!{bash for note in $(ls -t docs/notes/*.md 2>/dev/null | head -5); do echo "=== $note ==="; cat "$note"; echo ""; done}

### If action is "search":

Search notes for query:

!{bash QUERY=$(echo "$ARGUMENTS" | cut -d' ' -f2-) && grep -r "$QUERY" docs/notes/ 2>/dev/null}

## Step 4: Display Summary

Show notes statistics:

!{bash echo "Total notes: $(ls docs/notes/*.md 2>/dev/null | wc -l)"}
!{bash echo "Latest note: $(ls -t docs/notes/*.md 2>/dev/null | head -1)"}

**Note Actions:**
- `/03-planning:notes add` - Create new development note
- `/03-planning:notes view` - View recent notes
- `/03-planning:notes search <query>` - Search through notes

**Note Format Structure:**

# Note Title - YYYY-MM-DD
## Context - What's happening in the project
## Decision/Discussion - What was decided or discussed
## Action Items - Checkbox tasks
## References - Related specs and ADRs

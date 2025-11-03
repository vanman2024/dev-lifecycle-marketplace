---
description: Capture technical notes and development journal
argument-hint: [note-topic]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Capture technical notes, decisions, learnings, and development journal entries

Core Principles:
- Quick capture - low friction for note-taking
- Searchable - easy to find past notes
- Dated - timestamped entries
- Organized - categorized by topic

## Phase 1: Discovery
Goal: Understand note request

Actions:
- Parse $ARGUMENTS for note topic or search query
- Check for notes directory
- Example: !{bash test -d docs/notes && echo "exists" || mkdir -p docs/notes}
- Determine action (create, search, list)

## Phase 2: Validation
Goal: Prepare for note operation

Actions:
- For create: If topic not provided, ask user for note content
- For search: Parse search terms
- For list: Determine sorting (date, topic)

## Phase 3: Execution
Goal: Perform note operation

Actions:
- For create:
  - Create timestamped note file
  - Example: docs/notes/YYYY-MM-DD-topic.md
  - Add frontmatter with metadata
  - Write note content

- For search:
  - Search note contents
  - Example: !{bash grep -r "$ARGUMENTS" docs/notes/}

- For list:
  - List all notes with summaries
  - Example: !{bash ls -lt docs/notes/*.md | head -20}

## Phase 4: Summary
Goal: Report note operation result

Actions:
- For create: "Note created: docs/notes/{filename}"
- For search: "Found {count} notes matching query"
- For list: "Showing {count} notes"
- Suggest: "Use /planning:notes search <term> to find notes"

---
description: Sync documentation relationships to Mem0 for intelligent tracking
argument-hint: [project-name]
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

Goal: Populate Mem0 with documentation relationships from specs, architecture docs, and ADRs

Core Principles:
- Scan all specs for architecture references and dependencies
- Create natural language memories in Mem0
- Build derivation chains (what needs updating when X changes)
- Project isolation using user_id

## Available Skills

This command has access to the following skills from the planning plugin:

- **doc-sync**: Documentation synchronization using Mem0 for tracking relationships between specs, architecture, ADRs, and roadmap. Use when syncing documentation, querying documentation relationships, finding impact of changes, validating doc consistency, or when user mentions doc sync, documentation tracking, spec dependencies, architecture references, or impact analysis.

**To use a skill:**
```
!{skill doc-sync}
```

---

## Phase 1: Prerequisites Check

Goal: Ensure Mem0 is available

Actions:
- Check if Mem0 virtual environment exists at `/tmp/mem0-env`
- If not found:
  - Display installation instructions:
    ```bash
    python -m venv /tmp/mem0-env
    source /tmp/mem0-env/bin/activate
    pip install mem0ai
    ```
  - Exit with helpful error
- If found: Continue to Phase 2

## Phase 2: Scan Documentation

Goal: Find all specs and extract relationships

Actions:
- Navigate to project root
- Count specs: `ls -d specs/*/ 2>/dev/null | wc -l`
- Display: "🔍 Found {count} specifications to sync"
- Load doc-sync skill for reference

## Phase 3: Run Sync Script

Goal: Execute Mem0 sync

Actions:
- Activate Mem0 environment
- Run sync script:
  ```bash
  source /tmp/mem0-env/bin/activate
  python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py
  ```
- Capture output
- Display results

## Phase 4: Summary

Goal: Show sync results

Actions:
- Parse sync output for statistics
- Display:
  ```
  ✅ Documentation Synced to Mem0

  📊 Results:
  - Specs scanned: {count}
  - Architecture references: {count}
  - ADR references: {count}
  - Memories created: {count}

  🔍 Next Steps:
  - Query impact: /planning:impact-analysis <doc-path>
  - Validate docs: /planning:validate-docs
  - View relationships in Mem0
  ```

## Error Handling

Handle common issues:
- Mem0 not installed → Show install instructions
- No specs found → Suggest creating specs first
- Script fails → Display error and troubleshooting guide

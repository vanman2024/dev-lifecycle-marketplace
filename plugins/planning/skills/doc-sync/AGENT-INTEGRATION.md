# Agent Integration Guide for Doc-Sync

## Overview

The doc-sync system tracks relationships between documentation (specs, architecture, ADRs, roadmap) using Mem0 with ChromaDB for persistent storage.

**Storage Location:** `~/.claude/mem0-chroma/`
**Persistence:** ✅ Fully persistent across sessions
**Technology:** Mem0 OSS + ChromaDB + OpenAI embeddings

## Which Agents Should Use Doc-Sync?

### Planning Plugin Agents

#### 1. **spec-writer** (Creates Specs)
**When:** After creating/updating a spec
**Action:** Auto-run sync
**Integration:**
```python
# At end of spec-writer agent
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet}
```

**Why:** New specs need to be registered with their architecture references and dependencies.

---

#### 2. **architecture-designer** (Creates Architecture Docs)
**When:** After creating/updating architecture documents
**Action:** Run sync + query affected specs
**Integration:**
```python
# After architecture changes
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet}

# Query which specs are affected
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What specs reference [architecture-file].md?"}
```

**Why:** When architecture changes, need to identify which specs must be reviewed/updated.

---

#### 3. **decision-documenter** (Creates ADRs)
**When:** After creating/updating ADRs
**Action:** Run sync + query implementing specs
**Integration:**
```python
# After ADR creation
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet}

# Find specs implementing this ADR
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What specs implement ADR-[number]?"}
```

**Why:** Need to track which specs are affected by architectural decisions.

---

#### 4. **roadmap-planner** (Creates Roadmap)
**When:** Before generating roadmap
**Action:** Query dependencies
**Integration:**
```python
# Before roadmap generation
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet}

# Query all spec dependencies
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "List all spec dependencies"}
```

**Why:** Roadmap needs accurate dependency information to sequence features correctly.

---

#### 5. **spec-analyzer** (Analyzes Project Completeness)
**When:** At start of analysis
**Action:** Sync first, then query for gaps
**Integration:**
```python
# Sync before analysis
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet}

# Check for orphaned specs or broken references
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What specs have no architecture references?"}
```

**Why:** Analysis needs complete picture of documentation relationships.

---

### Iterate Plugin Agents

#### 6. **sync-analyzer** (Syncs Specs with Implementation)
**When:** Before comparing specs to code
**Action:** Query spec relationships
**Integration:**
```python
# Query spec details before comparison
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What does spec [number] reference?"}
```

**Why:** Need to understand spec's architectural dependencies when checking implementation.

---

#### 7. **feature-enhancer** (Enhances Features)
**When:** Before enhancement
**Action:** Query related specs
**Integration:**
```python
# Find related specs
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What specs depend on [feature-name]?"}
```

**Why:** Enhancements might affect dependent specs.

---

### Quality Plugin Agents

#### 8. **test-generator** (Generates Tests)
**When:** Before generating tests
**Action:** Query spec requirements
**Integration:**
```python
# Get spec context for test generation
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What are the requirements for spec [number]?"}
```

**Why:** Tests should cover all architecture decisions and dependencies.

---

## Integration Patterns

### Pattern 1: Auto-Sync After Creation
**Use When:** Agent creates/modifies documentation
```bash
# Silent sync in background
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet 2>/dev/null && echo "✅ Synced"}
```

### Pattern 2: Sync + Impact Query
**Use When:** Changes might affect other docs
```bash
# Sync then query
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet}
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What specs are affected by [change]?"}
```

### Pattern 3: Query Before Action
**Use When:** Need context before proceeding
```bash
# Query without sync
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "[natural language query]"}
```

---

## Command Integration

### Commands That Should Auto-Sync

#### `/planning:spec` (After spec creation)
Add to final phase:
```markdown
## Phase 5: Sync Documentation
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet}
```

#### `/planning:decide` (After ADR creation)
Add to final phase:
```markdown
## Phase 4: Sync and Report Impact
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet}
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What specs implement ADR-{number}?"}
```

#### `/planning:architecture` (After architecture update)
Add to final phase:
```markdown
## Phase 4: Sync and Check Impact
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py --quiet}
!{source /tmp/mem0-env/bin/activate && python plugins/planning/skills/doc-sync/scripts/query-docs.py "What specs reference [architecture-file]?"}
```

---

## Query Examples

### Find Affected Specs
```bash
python query-docs.py "What specs reference security.md?"
python query-docs.py "What specs implement ADR-0015?"
```

### Find Dependencies
```bash
python query-docs.py "What does spec 005 depend on?"
python query-docs.py "What specs depend on authentication?"
```

### Find Context/Reasoning
```bash
python query-docs.py "Why does spec 001 use OAuth?"
python query-docs.py "Why was ADR-0005 created?"
```

### Find Gaps
```bash
python query-docs.py "What specs have no architecture references?"
python query-docs.py "What architecture docs are not referenced?"
```

---

## Installation Requirements

Agents using doc-sync must have access to:
- `/tmp/mem0-env/` - Virtual environment with mem0ai and chromadb
- `~/.claude/mem0-chroma/` - Persistent storage directory
- `OPENAI_API_KEY` environment variable (for embeddings)

---

## Implementation Priority

**High Priority (Implement First):**
1. spec-writer - Most frequently used, creates foundation
2. architecture-designer - Critical for tracking architecture changes
3. decision-documenter - ADRs drive many specs

**Medium Priority:**
4. roadmap-planner - Needs dependencies but less frequent
5. spec-analyzer - Useful for completeness checks

**Low Priority (Future Enhancement):**
6. sync-analyzer - Nice to have
7. feature-enhancer - Edge case
8. test-generator - Can work without it initially

---

## Testing Integration

After integrating with an agent:

1. **Create test documentation** (spec/arch/ADR)
2. **Verify sync runs** (check output)
3. **Test queries** (verify results)
4. **Check persistence** (restart and query again)

---

## Troubleshooting

### "Module mem0 not found"
```bash
# Ensure venv is activated in inline commands
source /tmp/mem0-env/bin/activate
```

### "No results found"
```bash
# Check if sync has run recently
python sync-to-mem0.py
# Then retry query
```

### "ChromaDB permission error"
```bash
# Check storage directory permissions
ls -la ~/.claude/mem0-chroma/
chmod -R u+rw ~/.claude/mem0-chroma/
```

---

**Last Updated:** 2025-11-03
**Status:** ✅ Tested and Working
**Storage:** ChromaDB (persistent across sessions)

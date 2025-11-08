# Airtable Plugin Management System - Architecture

## Overview

This Airtable database tracks all components across the Claude Code plugin marketplaces, providing a visual, relational view of how agents, commands, skills, and MCP servers interconnect.

**Purpose**:
- Organize and track all plugin components across marketplaces
- Understand relationships between components
- Enable validation of component dependencies
- Support "mix and match" reusability across projects
- Identify missing documentation or improper configurations

## Database Structure

### 6 Core Tables

```
┌─────────────────┐
│  Marketplaces   │
│  (3 records)    │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│    Plugins      │
│  (5+ records)   │
└────┬───┬───┬────┘
     │   │   │
     │   │   └─────────────────┐
     │   │                     │
     │   │ 1:N           1:N   │ 1:N
     ▼   ▼                     ▼
┌─────┐ ┌─────────┐      ┌─────────┐
│Agent│ │Commands │      │ Skills  │
│(40+)│ │ (58+)   │      │ (32+)   │
└──┬──┘ └────┬────┘      └────┬────┘
   │         │                │
   │         │                │
   └────┬────┴────────────────┘
        │
        │ N:N
        ▼
┌─────────────────┐
│  MCP Servers    │
│  (16 records)   │
└─────────────────┘
```

---

## Table Details

### 1. Marketplaces Table

**Purpose**: Top-level collections of related plugins

| Field | Type | Description |
|-------|------|-------------|
| Marketplace Name | Text | dev-lifecycle-marketplace, ai-dev-marketplace, ai-tech-stack-1 |
| Description | Long Text | Purpose of the marketplace |
| Directory Path | Text | `/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace` |
| Purpose | Long Text | What problem domain this marketplace addresses |
| Plugins | Linked Records | Links to Plugins table (1:N) |
| Plugin Count | Count | Formula counting linked plugins |

**Current Records**: 3 marketplaces

---

### 2. Plugins Table

**Purpose**: Individual plugins within marketplaces (foundation, planning, iterate, quality, deployment)

| Field | Type | Description |
|-------|------|-------------|
| Name | Text | Plugin name (e.g., "foundation", "quality") |
| Marketplace Link | Linked Records | Links to Marketplaces table |
| Description | Long Text | Plugin purpose and scope |
| Directory Path | Text | Relative path within marketplace |
| Status | Single Select | Active, Deprecated, In Development |
| Agents | Linked Records | Links to Agents table (1:N) |
| Commands | Linked Records | Links to Commands table (1:N) |
| Skills | Linked Records | Links to Skills table (1:N) |
| Agent Count | Count | Formula counting agents |
| Command Count | Count | Formula counting commands |
| Skills Count | Count | Formula counting skills |

**Current Records**: 5+ plugins from dev-lifecycle marketplace

---

### 3. Agents Table

**Purpose**: Autonomous agents that execute complex workflows

| Field | Type | Description |
|-------|------|-------------|
| Agent Name | Text | Name from frontmatter (e.g., "stack-detector") |
| Plugin | Linked Records | Links to Plugins table |
| File Path | Text | Relative path to agent markdown file |
| Purpose | Long Text | Description from frontmatter |
| Has Slash Commands Section | Checkbox | Does agent doc have slash commands section? |
| Has MCP Section | Checkbox | Does agent doc have MCP section? |
| Has Skills Section | Checkbox | Does agent doc have skills section? |
| Status | Single Select | Complete, Missing Documentation, Needs Update |
| **Invoked By Commands** | Linked Records | **REVERSE LINK**: Commands that invoke this agent |
| **Uses Commands** | Linked Records | **PRIMARY**: Slash commands this agent calls |
| Skills | Linked Records | Skills this agent references with Skill() |
| MCP Servers Linked | Linked Records | MCP servers this agent uses |

**Current Records**: 40+ agents from dev-lifecycle marketplace

#### Agent Relationship Directions

```
Commands ──[invokes]──> Agent ──[uses]──> Commands
         └─[reverse]──┘       └─[primary]─┘
```

**Example**:
- `/quality:validate-tasks` command **invokes** `task-validator` agent → Shows in "Invoked By Commands"
- `deployment-deployer` agent **uses** `/deployment:setup-monitoring` command → Shows in "Uses Commands"

---

### 4. Commands Table

**Purpose**: Slash commands users execute (e.g., `/foundation:detect`)

| Field | Type | Description |
|-------|------|-------------|
| Command Name | Text | Full command name (e.g., "/planning:spec") |
| Plugin | Linked Records | Links to Plugins table |
| Description | Long Text | What the command does |
| File Path | Text | Relative path to command markdown file |
| Argument Hint | Text | Expected arguments |
| **Invokes Agent** | Linked Records | **PRIMARY**: Which agent this command calls |
| Registered in Settings | Checkbox | Is command registered in plugin.json? |
| **Used By Agents** | Linked Records | **REVERSE LINK**: Agents that reference this command |

**Current Records**: 58+ commands from dev-lifecycle marketplace

#### Command Relationship Directions

```
Command ──[invokes]──> Agent
        ──[used by]──> Agent
```

---

### 5. Skills Table

**Purpose**: Progressive disclosure knowledge modules with scripts/templates/examples

| Field | Type | Description |
|-------|------|-------------|
| Skill Name | Text | Short name (e.g., "newman-testing") |
| Plugin | Linked Records | Links to Plugins table |
| Description | Long Text | What knowledge this skill provides |
| Directory Path | Text | Path to skill directory |
| Has SKILL.md | Checkbox | Core instruction file exists? |
| Has Scripts | Checkbox | Automation scripts exist? |
| Has Templates | Checkbox | Reusable templates exist? |
| Has Examples | Checkbox | Usage examples exist? |
| Used By Agents | Linked Records | REVERSE LINK: Agents that invoke this skill |

**Current Records**: 32+ skills from dev-lifecycle marketplace

---

### 6. MCP Servers Table

**Purpose**: External MCP server integrations available to agents

| Field | Type | Description |
|-------|------|-------------|
| MCP Server Name | Text | Server name (e.g., "mcp__supabase") |
| Description | Long Text | What the MCP server provides |
| Purpose | Long Text | Use cases and capabilities |
| Source Marketplace | Text | Where this MCP server is defined |
| Agents | Linked Records | REVERSE LINK: Agents that use this server |

**Current Records**: 16 MCP servers

**Available MCP Servers**:
- mcp__supabase - Database operations
- mcp__github - GitHub API integration
- mcp__airtable - Airtable API integration
- mcp__postman - API testing with Postman
- mcp__playwright - Browser automation
- mcp__shadcn - UI component registry
- mcp__context7 - Documentation search
- mcp__memory - Persistent memory
- mcp__filesystem - File operations
- Plus 7 more...

---

## Relationship Map

### Primary Relationships (Forward Links)

These are the **intentional, primary relationships** we created:

```
Marketplaces ──1:N──> Plugins
                        │
                        ├──1:N──> Agents
                        ├──1:N──> Commands
                        └──1:N──> Skills

Commands ──1:1──> Invokes Agent

Agents ──N:N──> Uses Commands
       ──N:N──> Skills
       ──N:N──> MCP Servers
```

### Reverse Links (Auto-Created)

These fields were **automatically created by Airtable** when we made primary links:

```
Agent.Commands ← Created when we made Command.Invokes Agent
Command.Agents ← Created when we made Agent.Uses Commands
Skill.Used By Agents ← Created when we made Agent.Skills
MCP Server.Agents ← Created when we made Agent.MCP Servers
```

**Why This Is Confusing**:
- Airtable auto-creates reverse links with generic names
- Results in duplicate-looking fields (e.g., "Commands" and "Uses Commands" in Agents table)
- Field names don't clearly indicate direction

**Proposed Renaming**:
- Agent."Commands" → "Invoked By Commands" (clearer reverse direction)
- Command."Agents" → "Used By Agents" (clearer reverse direction)

---

## Data Population Flow

### How Scripts Populate the Database

```
┌─────────────────────────────────────┐
│  1. populate-airtable.py            │
│  - Scans plugin directories         │
│  - Extracts frontmatter from .md    │
│  - Creates Agents/Commands/Skills   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  2. populate-mcp-servers.py         │
│  - Creates 16 MCP Server records    │
│  - Adds descriptions and purposes   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  3. migrate-mcp-links.py            │
│  - Reads agent files for MCP refs   │
│  - Links Agents to MCP Servers      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  4. link-agent-commands.py          │
│  - Extracts slash command refs      │
│  - Links Agents to Commands (Uses)  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  5. link-agent-skills.py            │
│  - Extracts Skill() invocations     │
│  - Links Agents to Skills           │
└─────────────────────────────────────┘
```

### Extraction Patterns

**Frontmatter Extraction**:
```yaml
---
name: agent-name
description: Agent purpose
model: inherit
color: blue
---
```

**Slash Command Extraction**:
```python
# Patterns:
/planning:spec
SlashCommand(/deployment:deploy)
```

**Skill Extraction**:
```python
# Pattern:
Skill(quality:newman-testing)
```

**MCP Server Extraction**:
```python
# Pattern in agent files:
Uses: mcp__supabase, mcp__github
```

---

## Current Data Status

### dev-lifecycle-marketplace (Populated ✅)

| Component | Count | Status |
|-----------|-------|--------|
| Plugins | 5 | Complete |
| Agents | 40+ | Complete |
| Commands | 58+ | Complete |
| Skills | 32+ | Complete |
| Agent → Command Links | 36 | Complete |
| Agent → Skill Links | 33 | Complete |
| Agent → MCP Links | 33 | Complete |

### ai-dev-marketplace (Pending ⏳)

| Component | Estimated Count | Status |
|-----------|----------------|--------|
| Agents | 86 | Not yet populated |
| Commands | ? | Not yet populated |
| Skills | ? | Not yet populated |

### ai-tech-stack-1 (Pending ⏳)

| Component | Estimated Count | Status |
|-----------|----------------|--------|
| Agents | ? | Not yet populated |
| Commands | ? | Not yet populated |
| Skills | ? | Not yet populated |

---

## Validation Checklist

### Agent Validation
- [ ] All agents have proper frontmatter (name, description, model, color)
- [ ] File paths are correct and relative to marketplace directory
- [ ] Purpose field is populated from description
- [ ] Status is set appropriately
- [ ] Linked to correct plugin
- [ ] Command/Skill/MCP relationships are accurate

### Command Validation
- [ ] All commands have descriptions
- [ ] File paths are correct
- [ ] Properly linked to plugins
- [ ] "Invokes Agent" is set for commands that call agents
- [ ] Registered in Settings checkbox matches plugin.json

### Skills Validation
- [ ] Directory paths are correct
- [ ] Has SKILL.md checkbox matches filesystem
- [ ] Has Scripts/Templates/Examples match filesystem
- [ ] Linked to correct plugins

### MCP Server Validation
- [ ] All 16 MCP servers have descriptions
- [ ] Purpose field is comprehensive
- [ ] Agent relationships are complete

---

## Known Issues

### 1. Duplicate-Looking Fields ⚠️

**Problem**: Reverse links create confusing duplicate fields
- Agents table: "Commands" (reverse) vs "Uses Commands" (primary)
- Commands table: "Invokes Agent" (primary) vs "Agents" (reverse)

**Solution**: Rename reverse links to clarify direction
- "Commands" → "Invoked By Commands"
- "Agents" → "Used By Agents"

### 2. Missing Frontmatter (Fixed ✅)

**Problem**: 4 agents had old `allowed-tools` frontmatter instead of proper format

**Agents Fixed**:
- version-bumper
- version-rollback-executor
- deployment-preparer
- monitoring-setup-executor

**Status**: All fixed and committed

### 3. Skills Field Visibility

**Problem**: Skills field appears blank in UI for some agents

**Explanation**:
- Skills ARE linked (33 agents have skills)
- UI only shows skills for agents that actually reference them
- Not a data problem, just UI behavior

---

## Mix and Match Strategy

### Goal
Enable reusable deployment components across any project, regardless of tech stack.

### How Relationships Enable This

1. **Find Deployment Agents**:
   ```
   Filter Agents by Plugin = "deployment"
   → Shows: deployment-detector, deployment-deployer, deployment-validator
   ```

2. **See What Each Agent Needs**:
   ```
   Agent → Uses Commands → See all slash commands it calls
   Agent → Skills → See what knowledge it requires
   Agent → MCP Servers → See what external integrations it needs
   ```

3. **Validate Cross-Project Compatibility**:
   ```
   - Does target project have required MCP servers?
   - Can we install missing skills?
   - Are command dependencies available?
   ```

4. **Bundle for Reuse**:
   ```
   Package: "Vercel Deployment Kit"
   - Agent: deployment-deployer
   - Commands: /deployment:deploy, /deployment:validate
   - Skills: platform-detection, deployment-scripts
   - MCP Servers: mcp__vercel, mcp__github
   ```

### Example Use Case

**Goal**: Use deployment plugin in a Python FastAPI project

**Query Airtable**:
1. Find all deployment agents
2. Check their MCP server dependencies
3. Verify required skills exist
4. See what commands they invoke
5. Package everything needed

**Result**: Can confidently copy deployment plugin to new marketplace, knowing all dependencies.

---

## Usage Guide

### Navigate Relationships

**Find all agents in the quality plugin**:
```
Plugins table → Filter Name = "quality" → Click Agents link
```

**See what commands an agent uses**:
```
Agents table → Select agent → Look at "Uses Commands" field
```

**Find which agents use Supabase MCP**:
```
MCP Servers table → Filter Name = "mcp__supabase" → Click Agents link
```

**See which skills a plugin provides**:
```
Plugins table → Select plugin → Click Skills link
```

### Validate Data

**Check for agents missing descriptions**:
```
Agents table → Filter Purpose is empty
```

**Find commands not linked to plugins**:
```
Commands table → Filter Plugin is empty
```

**Identify skills without SKILL.md**:
```
Skills table → Filter Has SKILL.md = unchecked
```

---

## Next Steps

### Immediate (Before Populating More Data)

1. **Rename reverse link fields** for clarity
   - Agent."Commands" → "Invoked By Commands"
   - Command."Agents" → "Used By Agents"

2. **Validate dev-lifecycle data** is 100% accurate
   - Check random sample of agent relationships
   - Verify file paths are correct
   - Ensure all frontmatter is proper

3. **Create validation queries**
   - Agents without descriptions
   - Commands not registered in plugin.json
   - Skills missing documentation

### Future (After Validation)

4. **Populate ai-dev-marketplace** (86 agents)
5. **Populate ai-tech-stack-1 marketplace**
6. **Create mix-and-match bundles** for common scenarios
7. **Build dependency checker** to validate cross-project compatibility

---

## Automation & Maintenance

### How to Keep Airtable Updated

**Manual Workflow (Recommended)**:
```bash
# After making any changes to agents, commands, or skills:
cd /home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace
python3 scripts/sync-airtable.py
python3 scripts/validate-airtable.py
```

This is the **most reliable approach** because:
- Claude Code doesn't support background file watching reliably
- Manual trigger ensures you review changes before syncing
- Validation runs immediately to catch errors

### Automation Scripts

#### 1. `sync-airtable.py` - Keep Data Fresh

**What it does**:
- Scans filesystem for all agents/commands/skills
- Compares with existing Airtable records
- Creates new records for new components
- Updates changed records (descriptions, file paths, etc.)
- Re-links all relationships (commands, skills, MCP servers)
- Skips archived directories (`archived`, `.archive`)
- Handles duplicate skill names across plugins

**When to run**:
- After creating new agents/commands/skills
- After modifying frontmatter
- After moving/renaming files
- After restructuring plugin directories

**Output**:
```
🔄 Syncing dev-lifecycle marketplace...
  Found 40 agents, 58 commands, 32 skills
  ✓ All agents up to date
  🔄 Update skill: iterate/worktree-orchestration
  ✅ Full sync complete!
```

#### 2. `validate-airtable.py` - Verify Accuracy

**What it does**:
- Checks all file paths exist on filesystem
- Verifies frontmatter matches Airtable data
- Validates relationship links are correct
- Identifies missing documentation
- Generates comprehensive error reports

**When to run**:
- After running sync script
- Before populating other marketplaces
- When troubleshooting data issues
- As part of CI/CD (future)

**Output**:
```
✅ Total Errors: 0
⚠️  Total Warnings: 1
✅ VALIDATION PASSED - Data is accurate!
```

### Integration Points

#### Option 1: Git Hooks (Recommended for Automation)

Create `.git/hooks/post-commit` to auto-sync after commits:

```bash
#!/bin/bash
# .git/hooks/post-commit
# Auto-sync Airtable after commits that modify plugins

MARKETPLACE_DIR="/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace"

# Check if commit modified plugin files
if git diff-tree --no-commit-id --name-only -r HEAD | grep -q "^plugins/"; then
    echo "🔄 Plugin files changed - syncing Airtable..."
    cd "$MARKETPLACE_DIR"
    python3 scripts/sync-airtable.py

    # Validate
    if python3 scripts/validate-airtable.py; then
        echo "✅ Airtable sync complete and validated"
    else
        echo "⚠️  Validation found issues - review output"
    fi
fi
```

Make executable:
```bash
chmod +x .git/hooks/post-commit
```

**Pros**: Automatic, runs after every commit
**Cons**: Adds time to commit process, may fail on API errors

#### Option 2: Slash Command Integration

Add to `.claude/commands/sync-airtable.md`:

```markdown
---
description: Sync Airtable database with current filesystem state and validate
---

## Phase 1: Sync

Run sync script:
```bash
cd /home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace
python3 scripts/sync-airtable.py
```

## Phase 2: Validate

Run validation:
```bash
python3 scripts/validate-airtable.py
```

## Phase 3: Summary

Report sync and validation results to user.
```

Usage: `/sync-airtable`

**Pros**: Easy to remember, manual control
**Cons**: Requires user to remember to run it

#### Option 3: GitHub Actions (Future CI/CD)

Create `.github/workflows/sync-airtable.yml`:

```yaml
name: Sync Airtable

on:
  push:
    paths:
      - 'plugins/**/*.md'
      - 'plugins/**/plugin.json'

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: pip install pyairtable pyyaml

      - name: Sync Airtable
        env:
          AIRTABLE_API_KEY: ${{ secrets.AIRTABLE_API_KEY }}
        run: python3 scripts/sync-airtable.py

      - name: Validate
        run: python3 scripts/validate-airtable.py
```

**Pros**: Automatic on push, runs in CI
**Cons**: Requires GitHub, needs secret configuration

### Why File Watching Doesn't Work in Claude Code

**The Problem**:
- Claude Code runs in a container/sandbox environment
- File system watchers (inotify, FSEvents) don't reliably trigger in sandboxes
- Background processes are isolated and may not have persistent access
- Resource constraints limit long-running background tasks

**Workarounds**:
1. **Git Hooks** - Trigger on git events (commit, push)
2. **Manual Triggers** - Run scripts when you know changes occurred
3. **Slash Commands** - Convenient manual triggering
4. **CI/CD** - Run on push to remote repository

### Recommended Workflow

**For Daily Development**:
```bash
# 1. Make changes to agents/commands/skills
# 2. Commit changes (with git hook, auto-syncs)
git add plugins/quality/agents/new-agent.md
git commit -m "feat(quality): Add new-agent for API testing"
# → Git hook runs sync-airtable.py automatically

# 3. OR manually sync if no git hook:
python3 scripts/sync-airtable.py && python3 scripts/validate-airtable.py
```

**For Major Changes**:
```bash
# 1. Sync all marketplaces
python3 scripts/sync-airtable.py

# 2. Validate
python3 scripts/validate-airtable.py

# 3. Review Airtable UI to verify
# Visit: https://airtable.com/appHbSB7WhT1TxEQb
```

### Monitoring & Alerts

**Current Status**: Manual monitoring via validation script

**Future Enhancements**:
- Slack webhook notifications on validation failures
- Daily automated sync report
- Airtable automation to flag stale records
- Dashboard view showing last sync timestamp

---

## Technical Notes

### API Limitations
- Batch operations limited to 10 records per call
- Rate limiting on Airtable API (5 requests/second)
- Must paginate for large result sets

### Script Maintenance
- All scripts in `/scripts/` directory
- Use PyAirtable library (`pip install pyairtable`)
- Base ID: `appHbSB7WhT1TxEQb`
- API key stored in script (SHOULD MOVE to environment variable)

### Security Considerations
- **CRITICAL**: API key is hardcoded in scripts
- **TODO**: Move to environment variable: `AIRTABLE_API_KEY`
- Set in `~/.bashrc`: `export AIRTABLE_API_KEY="your_key_here"`
- Update scripts to use: `os.getenv("AIRTABLE_API_KEY")`
- Add to `.gitignore` if not already

### Performance
- Full sync takes ~10-30 seconds
- Validation takes ~5-10 seconds
- Scales linearly with number of components

---

## Summary

This Airtable database provides a **complete relational map** of all plugin components across marketplaces. It enables:

✅ **Visibility**: See all agents, commands, skills, and MCP servers in one place
✅ **Relationships**: Understand how components depend on each other
✅ **Validation**: Identify missing documentation or configuration errors
✅ **Reusability**: Package components for use across different projects
✅ **Planning**: Use data to inform architectural decisions
✅ **Automation**: Keep data fresh with sync scripts and git hooks

**Current Status**:
- ✅ dev-lifecycle marketplace fully populated and validated (40 agents, 58 commands, 32 skills)
- ✅ Sync and validation scripts working
- ⏳ Git hook integration pending
- ⏳ ai-dev-marketplace pending (86 agents)
- ⏳ ai-tech-stack-1 pending

**Recommended Next Step**: Set up git hook for automatic syncing after commits.

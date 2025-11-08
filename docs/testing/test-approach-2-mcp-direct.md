# APPROACH 2: MCP Server Direct

## Concept
Single agent does EVERYTHING:
- Queries Airtable itself
- Resolves linked Plugin records
- Constructs file paths
- Reads files
- Analyzes
- Writes findings back

## Single Task Call

Copy this into Claude Code (fresh conversation):

```
Task(
    description="Audit 10 ai-tech-stack-1 commands using MCP direct",
    subagent_type="quality:agent-auditor",
    prompt="""You will audit ai-tech-stack-1 commands using MCP server directly.

WORKFLOW:

1. Query Airtable for Commands
   Use: mcp__airtable__list_records

   Input:
     baseId: appHbSB7WhT1TxEQb
     tableId: Commands
     filterByFormula: "FIND('ai-tech-stack-1', {Plugin}) > 0"
     maxRecords: 10

   You will get records like:
   {
     "id": "recABC123",
     "fields": {
       "Name": "build-full-stack-phase-0",
       "Plugin": ["recPLUGIN123"],  // Linked record ID
       "Description": "..."
     }
   }

2. For EACH command record:

   a) Resolve Plugin linked record
      Use: mcp__airtable__get_record

      Input:
        baseId: appHbSB7WhT1TxEQb
        tableId: Plugins
        recordId: <extract from Plugin field>

      This gives you the plugin name: "ai-tech-stack-1"

   b) Construct file path
      plugins/{plugin_name}/commands/{command_name}.md

   c) Read file from filesystem
      Use: Read tool

   d) Analyze for anti-patterns
      Count !{slashcommand ...} patterns
      If 3+, it's an anti-pattern

   e) Write findings to Airtable
      Use: mcp__airtable__update_records

      Input:
        baseId: appHbSB7WhT1TxEQb
        tableId: Commands
        records: [{
          id: <record_id>,
          fields: {
            Notes: "⚠️ AUDIT FINDINGS:\\n\\n🚨 ANTI-PATTERN: ..."
          }
        }]

3. Report summary of all 10 commands audited

API CALLS NEEDED:
- 1 call to list Commands (get 10 records)
- 10 calls to get Plugin record (resolve linked records)
- 10 calls to update Notes (write findings)
= 21 total API calls

WORK AUTONOMOUSLY. You have all the tools you need via MCP.
"""
)
```

## What This Tests

**Complexity**: Agent must:
- ✅ Query Airtable itself
- ✅ Understand linked record structure
- ✅ Resolve 10 linked Plugin records
- ✅ Construct 10 file paths
- ✅ Read 10 files
- ✅ Analyze 10 files
- ✅ Write 10 updates back

**API Efficiency**:
- 21 API calls total
- All within single agent execution

**Autonomy**:
- Agent figures everything out
- No pre-populated data
- True autonomous operation

## Expected Result

Agent should write to each command's Notes field:

```
⚠️ AUDIT FINDINGS:

COMMAND CHAINING:
🚨 ANTI-PATTERN: Chains 14 slash commands - should spawn agents using Task() instead
⚡ Parallelization opportunity - spawn agents in parallel, not sequential commands

Commands found: /foundation:detect, /foundation:env-check, ...

RECOMMENDED REFACTOR:
Replace with parallel agent orchestration
```

## Comparison After Testing

| Metric | Python Script | MCP Direct |
|--------|--------------|------------|
| Setup complexity | Medium (run script) | Low (1 Task call) |
| Agent complexity | Low (spoon-fed) | High (autonomous) |
| API calls | 1 (script) + 10 (agents) | 21 (all in agent) |
| Parallel execution | ✅ 10 agents | ❌ 1 agent, sequential |
| Time | ~2-3 min (parallel) | ~5-7 min (sequential) |
| Reliability | Higher (pre-validated) | Lower (agent must resolve) |
| Flexibility | Lower (script hardcoded) | Higher (agent adapts) |

## Which is Better?

**Test both and see!**

After running both approaches, compare:
1. ✅ Did both successfully write findings to Airtable?
2. ⏱️ Which was faster?
3. 🎯 Which had better quality findings?
4. 🔧 Which was easier to debug if something went wrong?
5. 📈 Which would scale better to 141 agents + 215 commands?

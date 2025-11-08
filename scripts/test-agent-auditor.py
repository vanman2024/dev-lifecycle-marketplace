#!/usr/bin/env python3
"""
Test agent-auditor on first 10 commands from ai-tech-stack-1 plugin
"""

import os
from pyairtable import Api

# Configuration
AIRTABLE_TOKEN = os.getenv("AIRTABLE_TOKEN")
BASE_ID = "appHbSB7WhT1TxEQb"
COMMANDS_TABLE = "Commands"

def main():
    """Query Airtable and prepare test data for agent-auditor"""

    print("🔍 Testing agent-auditor workflow\n")

    # Step 1: Connect to Airtable
    print("📊 Step 1: Connecting to Airtable...")
    api = Api(AIRTABLE_TOKEN)
    table = api.table(BASE_ID, COMMANDS_TABLE)

    # Step 2: Get ai-tech-stack-1 commands
    print("📋 Step 2: Querying ai-tech-stack-1 commands...\n")

    # Filter for ai-tech-stack-1 plugin
    formula = "FIND('ai-tech-stack-1', {Plugin}) > 0"
    commands = table.all(formula=formula)

    print(f"Found {len(commands)} ai-tech-stack-1 commands\n")

    # Step 3: Show first 10
    print("📝 Step 3: First 10 commands to audit:\n")

    test_commands = commands[:10]

    for i, cmd in enumerate(test_commands, 1):
        fields = cmd['fields']
        name = fields.get('Name', 'Unknown')
        plugin = fields.get('Plugin', ['Unknown'])[0] if fields.get('Plugin') else 'Unknown'
        record_id = cmd['id']

        print(f"{i}. {name}")
        print(f"   Plugin: {plugin}")
        print(f"   Record ID: {record_id}")
        print(f"   File: plugins/{plugin}/commands/{name}.md")
        print()

    # Step 4: Generate Task() invocations for Claude
    print("\n" + "="*80)
    print("🤖 Step 4: TASK INVOCATIONS FOR CLAUDE CODE")
    print("="*80 + "\n")
    print("Copy and paste these Task() calls into Claude Code:\n")

    for i, cmd in enumerate(test_commands, 1):
        fields = cmd['fields']
        name = fields.get('Name', 'Unknown')
        plugin = fields.get('Plugin', ['Unknown'])[0] if fields.get('Plugin') else 'Unknown'
        record_id = cmd['id']
        file_path = f"plugins/{plugin}/commands/{name}.md"

        print(f"""Task(
    description="Audit command {i}/10: {name}",
    subagent_type="quality:agent-auditor",
    prompt='''
Audit COMMAND file: {name}
Record ID: {record_id}
Plugin: {plugin}
Type: COMMAND (check for slash command chaining anti-pattern)

File path: {file_path}

Instructions:
1. Read file from filesystem
2. Check if this is a COMMAND file (commands/ directory)
3. Scan for !{{slashcommand /...}} patterns
4. Count total slash commands chained
5. If 3+ chained: FLAG as anti-pattern
6. Write findings to Airtable Notes field for record: {record_id}

Use mcp__airtable__update_records to write findings to Notes field.
'''
)""")
        print()

    # Step 5: Expected output
    print("\n" + "="*80)
    print("📊 Step 5: EXPECTED OUTPUT")
    print("="*80 + "\n")

    print("Each agent-auditor will:")
    print("1. Read the command file")
    print("2. Detect slash command chaining")
    print("3. Write to Airtable Notes field\n")

    print("Example output for build-full-stack-phase-0.md:")
    print("""
⚠️ AUDIT FINDINGS:

COMMAND CHAINING:
🚨 ANTI-PATTERN: Chains 7 slash commands - should spawn 7 agents using Task() instead
⚡ Parallelization opportunity - spawn agents in parallel, not sequential commands
Commands found: /planning:analyze-project, /supervisor:init (×3), /foundation:detect, /foundation:env-check, /foundation:github-init

RECOMMENDED REFACTOR:
Replace with parallel agent orchestration using Task()
    """)

    print("\n" + "="*80)
    print("✅ Test data ready!")
    print("="*80 + "\n")

    return test_commands

if __name__ == "__main__":
    if not AIRTABLE_TOKEN:
        print("❌ ERROR: AIRTABLE_TOKEN environment variable not set")
        print("Run: export AIRTABLE_TOKEN=your_token_here")
        exit(1)

    main()

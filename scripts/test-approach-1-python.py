#!/usr/bin/env python3
"""
APPROACH 1: Python Script Orchestration
- Script queries Airtable
- Script resolves linked records
- Script constructs file paths
- Script generates Task() calls with ALL info pre-populated
- Agents just: Read → Analyze → Write
"""

import os
from pyairtable import Api

# Configuration
AIRTABLE_TOKEN = os.getenv("AIRTABLE_TOKEN")
BASE_ID = "appHbSB7WhT1TxEQb"

def get_plugin_info(api, plugin_record_id):
    """Resolve linked Plugin record to get name AND marketplace"""
    plugins_table = api.table(BASE_ID, "Plugins")
    plugin = plugins_table.get(plugin_record_id)
    fields = plugin['fields']

    plugin_name = fields.get('Name', 'unknown')

    # Resolve Marketplace linked record
    marketplace_ids = fields.get('Marketplace Link', [])
    if marketplace_ids:
        marketplace = get_marketplace_name(api, marketplace_ids[0])
    else:
        marketplace = 'unknown'

    return plugin_name, marketplace

def get_marketplace_name(api, marketplace_record_id):
    """Resolve linked Marketplace record to get name"""
    marketplaces_table = api.table(BASE_ID, "Marketplaces")
    marketplace = marketplaces_table.get(marketplace_record_id)
    return marketplace['fields'].get('Marketplace Name', 'unknown')

def main():
    """Query Airtable, resolve all linked records, generate Task() calls"""

    if not AIRTABLE_TOKEN:
        print("❌ ERROR: Set AIRTABLE_TOKEN environment variable")
        print("\nExample output (if you had credentials):")
        print_example_output()
        return

    print("=" * 80)
    print("APPROACH 1: Python Script Orchestration")
    print("=" * 80)
    print()

    api = Api(AIRTABLE_TOKEN)
    commands_table = api.table(BASE_ID, "Commands")

    # Query ai-tech-stack-1 commands
    print("📋 Querying Airtable for ai-tech-stack-1 commands...")
    formula = "FIND('ai-tech-stack-1', {Plugin}) > 0"
    commands = commands_table.all(formula=formula, max_records=10)

    print(f"Found {len(commands)} commands\n")

    # Resolve all linked records and prepare data
    prepared_data = []
    for cmd in commands:
        fields = cmd['fields']
        name = fields.get('Name', 'unknown')

        # Resolve linked Plugin record (gets plugin name AND marketplace)
        plugin_ids = fields.get('Plugin', [])
        if plugin_ids:
            plugin_name, marketplace = get_plugin_info(api, plugin_ids[0])
        else:
            plugin_name = 'unknown'
            marketplace = 'unknown'

        # Construct full file path with marketplace
        # From: /home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace
        # To:   /home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/ai-tech-stack-1/commands/build-full-stack-phase-0.md
        file_path = f"../{marketplace}/plugins/{plugin_name}/commands/{name}.md"

        prepared_data.append({
            'record_id': cmd['id'],
            'name': name,
            'plugin': plugin_name,
            'marketplace': marketplace,
            'file_path': file_path
        })

    # Generate Task() calls
    print("\n" + "=" * 80)
    print("✅ All info resolved! Copy these Task() calls into Claude Code:")
    print("=" * 80)
    print()

    for i, data in enumerate(prepared_data, 1):
        print(f"""Task(
    description="Audit command {i}/10: {data['name']}",
    subagent_type="quality:agent-auditor",
    prompt='''Audit this COMMAND file:

Record ID: {data['record_id']}
Marketplace: {data['marketplace']}
Plugin: {data['plugin']}
Name: {data['name']}
File: {data['file_path']}

Steps:
1. Read file from filesystem
2. Count !{{slashcommand ...}} patterns
3. If 3+, flag as anti-pattern
4. Write findings to Airtable Notes (record: {data['record_id']})

Base ID: {BASE_ID}
Table: Commands
'''
)
""")

    print("\n" + "=" * 80)
    print(f"✅ Ready to spawn {len(prepared_data)} agents in parallel!")
    print("=" * 80)

def print_example_output():
    """Show what output would look like"""
    print("""
Task(
    description="Audit command 1/10: build-full-stack-phase-0",
    subagent_type="quality:agent-auditor",
    prompt='''Audit this COMMAND file:

Record ID: recABC123
Marketplace: ai-dev-marketplace
Plugin: ai-tech-stack-1
Name: build-full-stack-phase-0
File: ../ai-dev-marketplace/plugins/ai-tech-stack-1/commands/build-full-stack-phase-0.md

Steps:
1. Read file from filesystem
2. Count !{slashcommand ...} patterns
3. If 3+, flag as anti-pattern
4. Write findings to Airtable Notes (record: recABC123)

Base ID: appHbSB7WhT1TxEQb
Table: Commands
'''
)

... (9 more tasks)
    """)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Migrate MCP Servers from multi-select to linked records
"""

import os
from pyairtable import Api

# Airtable configuration
AIRTABLE_TOKEN = os.getenv("AIRTABLE_TOKEN")
if not AIRTABLE_TOKEN:
    print("❌ ERROR: AIRTABLE_TOKEN environment variable not set")
    print("   Export it: export AIRTABLE_TOKEN=your_key_here")
    exit(1)
BASE_ID = "appHbSB7WhT1TxEQb"

# Initialize Airtable API
api = Api(AIRTABLE_TOKEN)
base = api.base(BASE_ID)
agents_table = base.table("Agents")
mcp_servers_table = base.table("MCP Servers")

def migrate_mcp_links():
    """Migrate MCP Server multi-select to linked records"""
    print("🔄 Migrating MCP Server links...")

    # Get all MCP Server records to create name→ID mapping
    mcp_records = mcp_servers_table.all()
    mcp_map = {rec['fields']['MCP Server Name']: rec['id'] for rec in mcp_records}
    print(f"📊 Found {len(mcp_map)} MCP servers")

    # Get all agents
    agents = agents_table.all()
    print(f"📊 Found {len(agents)} agents")

    # Migrate each agent
    updates = []
    for agent in agents:
        agent_id = agent['id']
        agent_name = agent['fields'].get('Agent Name', 'Unknown')

        # Get MCP Servers from multi-select field
        mcp_servers = agent['fields'].get('MCP Servers', [])

        if not mcp_servers:
            continue

        # Map MCP names to record IDs
        mcp_record_ids = []
        for mcp_name in mcp_servers:
            if mcp_name in mcp_map:
                mcp_record_ids.append(mcp_map[mcp_name])
            else:
                print(f"  ⚠️  {agent_name}: MCP '{mcp_name}' not found in MCP Servers table")

        if mcp_record_ids:
            updates.append({
                'id': agent_id,
                'fields': {
                    'MCP Servers Linked': mcp_record_ids
                }
            })
            print(f"  ✓ {agent_name}: Linking {len(mcp_record_ids)} MCP servers")

    # Batch update
    if updates:
        print(f"\n📝 Updating {len(updates)} agents...")
        batch_size = 10
        for i in range(0, len(updates), batch_size):
            batch = updates[i:i+batch_size]
            agents_table.batch_update(batch)
            print(f"  ✓ Updated {min(i+batch_size, len(updates))}/{len(updates)} agents")
    else:
        print("✓ No agents to update")

    print("\n✅ Migration complete!")
    print(f"   Updated {len(updates)} agents with MCP Server links")

if __name__ == "__main__":
    migrate_mcp_links()

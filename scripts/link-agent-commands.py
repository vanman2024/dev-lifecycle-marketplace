#!/usr/bin/env python3
"""
Link agents to the slash commands they use
Reads agent files to find slash command references
"""

import os
import re
from pathlib import Path
from pyairtable import Api

# Airtable configuration
AIRTABLE_API_KEY = os.getenv("AIRTABLE_API_KEY")
if not AIRTABLE_API_KEY:
    print("❌ ERROR: AIRTABLE_API_KEY environment variable not set")
    print("   Export it: export AIRTABLE_API_KEY=your_key_here")
    exit(1)
BASE_ID = "appHbSB7WhT1TxEQb"

# Initialize Airtable API
api = Api(AIRTABLE_API_KEY)
base = api.base(BASE_ID)
agents_table = base.table("Agents")
commands_table = base.table("Commands")

MARKETPLACES = {
    "dev-lifecycle": "/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace",
}

def extract_slash_commands(content):
    """Extract slash command references from content"""
    # Pattern: /plugin:command or SlashCommand(/plugin:command)
    patterns = [
        r'/([a-z0-9-]+:[a-z0-9-]+)',
        r'SlashCommand\(/([a-z0-9-]+:[a-z0-9-]+)\)',
    ]
    commands = set()
    for pattern in patterns:
        matches = re.findall(pattern, content)
        commands.update(matches)
    return list(commands)

def link_agent_commands():
    """Link agents to commands they reference"""
    print("🔗 Linking agents to commands...")

    # Get all commands and create name→ID mapping
    command_records = commands_table.all()
    command_map = {}
    for rec in command_records:
        cmd_name = rec['fields'].get('Command Name', '')
        # Normalize: "/plugin:cmd" format
        if cmd_name:
            command_map[cmd_name] = rec['id']
            # Also store without leading slash
            if cmd_name.startswith('/'):
                command_map[cmd_name[1:]] = rec['id']

    print(f"📊 Found {len(command_records)} commands")

    # Get all agents
    agent_records = agents_table.all()
    print(f"📊 Found {len(agent_records)} agents")

    # Process each agent
    updates = []
    for agent_rec in agent_records:
        agent_id = agent_rec['id']
        agent_name = agent_rec['fields'].get('Agent Name', 'Unknown')
        file_path = agent_rec['fields'].get('File Path', '')

        if not file_path:
            continue

        # Read agent file
        full_path = Path(MARKETPLACES["dev-lifecycle"]) / file_path
        if not full_path.exists():
            continue

        try:
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"  ⚠️  {agent_name}: Error reading file: {e}")
            continue

        # Extract slash commands
        slash_commands = extract_slash_commands(content)

        if not slash_commands:
            continue

        # Map to command record IDs
        command_ids = []
        for cmd in slash_commands:
            # Try with and without leading slash
            cmd_id = command_map.get(f"/{cmd}") or command_map.get(cmd)
            if cmd_id:
                command_ids.append(cmd_id)
            else:
                print(f"  ℹ️  {agent_name}: Command '/{cmd}' not found in Commands table")

        if command_ids:
            # Remove duplicates
            command_ids = list(set(command_ids))
            updates.append({
                'id': agent_id,
                'fields': {
                    'Uses Commands': command_ids
                }
            })
            print(f"  ✓ {agent_name}: Linking {len(command_ids)} commands")

    # Batch update
    if updates:
        print(f"\n📝 Updating {len(updates)} agents...")
        batch_size = 10
        for i in range(0, len(updates), batch_size):
            batch = updates[i:i+batch_size]
            agents_table.batch_update(batch)
            print(f"  ✓ Updated {min(i+batch_size, len(updates))}/{len(updates)} agents")
    else:
        print("✓ No agent-command links to create")

    print("\n✅ Linking complete!")
    print(f"   Updated {len(updates)} agents with command links")

if __name__ == "__main__":
    link_agent_commands()

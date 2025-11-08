#!/usr/bin/env python3
"""
Populate Agent Issues based on audit findings
Creates "Issues" field (multi-select) and tags each agent with their data quality issues
"""

import os
import re
from pathlib import Path
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

MARKETPLACES = {
    "dev-lifecycle": "/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace",
    "ai-dev": "/home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace",
    "mcp-servers": "/home/gotime2022/.claude/plugins/marketplaces/mcp-servers-marketplace",
    "domain-plugin-builder": "/home/gotime2022/.claude/plugins/marketplaces/domain-plugin-builder",
}

def scan_agent_file(file_path):
    """Scan agent file for sections"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        return None

    # Check for section markers (case insensitive)
    has_slash_section = bool(re.search(r'(?:## Slash Commands|## Commands|### Slash Commands)', content, re.IGNORECASE))
    has_mcp_section = bool(re.search(r'(?:## MCP (?:Servers?|Tools)|### MCP)', content, re.IGNORECASE))
    has_skills_section = bool(re.search(r'(?:## Skills|### Skills)', content, re.IGNORECASE))

    return {
        'has_slash_section': has_slash_section,
        'has_mcp_section': has_mcp_section,
        'has_skills_section': has_skills_section,
    }

def main():
    print("🏷️  POPULATING AGENT ISSUES")
    print("=" * 80)

    # Get all agents from Airtable
    print("\n📊 Loading agents from Airtable...")
    agents = agents_table.all()
    print(f"  ✓ Loaded {len(agents)} agents")

    # Scan all agent files and determine issues
    print("\n🔍 Scanning files and determining issues...")
    updates = []

    for agent in agents:
        agent_id = agent['id']
        agent_name = agent['fields'].get('Agent Name')
        file_path = agent['fields'].get('File Path')

        if not file_path:
            continue

        # Find marketplace path
        marketplace_path = None
        for mp_path in MARKETPLACES.values():
            full_path = Path(mp_path) / file_path
            if full_path.exists():
                marketplace_path = full_path
                break

        if not marketplace_path:
            continue

        # Scan file
        scan_result = scan_agent_file(marketplace_path)
        if not scan_result:
            continue

        # Determine issues
        issues = []

        # Check section flags
        airtable_has_slash = agent['fields'].get('Has Slash Commands Section', False)
        airtable_has_mcp = agent['fields'].get('Has MCP Section', False)
        airtable_has_skills = agent['fields'].get('Has Skills Section', False)

        if scan_result['has_slash_section'] and not airtable_has_slash:
            issues.append('Missing Slash Commands Section')

        if scan_result['has_mcp_section'] and not airtable_has_mcp:
            issues.append('Missing MCP Section')

        if scan_result['has_skills_section'] and not airtable_has_skills:
            issues.append('Missing Skills Section')

        # Check if relationship fields are empty
        if not agent['fields'].get('Uses Commands'):
            issues.append('Missing Uses Commands Links')

        if not agent['fields'].get('Skills'):
            issues.append('Missing Skills Links')

        if not agent['fields'].get('MCP Servers Linked'):
            issues.append('Missing MCP Server Links')

        # Add to updates if there are issues
        if issues:
            updates.append({
                'id': agent_id,
                'fields': {
                    'Issues': issues
                }
            })
            print(f"  {agent_name}: {len(issues)} issues")

    # Apply updates
    if updates:
        print(f"\n📝 Updating {len(updates)} agents with issue tags...")

        batch_size = 10
        for i in range(0, len(updates), batch_size):
            batch = updates[i:i+batch_size]
            try:
                agents_table.batch_update(batch)
                print(f"  Updated {min(i+batch_size, len(updates))}/{len(updates)}")
            except Exception as e:
                print(f"  Error updating batch: {e}")
                # Try to create the field if it doesn't exist
                print(f"  Note: If 'Issues' field doesn't exist, create it manually as Multi-select")
                return

        print("\n✅ All agents tagged with issues!")
    else:
        print("\n✅ No issues found!")

    # Summary
    print("\n" + "=" * 80)
    print("📊 SUMMARY")
    print("=" * 80)
    print(f"\nTotal Agents: {len(agents)}")
    print(f"Agents with Issues: {len(updates)}")
    print(f"Agents Clean: {len(agents) - len(updates)}")

if __name__ == "__main__":
    main()

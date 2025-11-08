#!/usr/bin/env python3
"""
Link agents to the skills they reference
Reads agent files to find Skill() invocations
"""

import os
import re
from pathlib import Path
from pyairtable import Api

# Airtable configuration
AIRTABLE_API_KEY = os.getenv("AIRTABLE_API_KEY", "pat6Wdcb4Uj6AtcFr.60698f69f01ab1e1a13d50558fdf7edbe80201d7279cde9531ed816984779ce9")
BASE_ID = "appHbSB7WhT1TxEQb"

# Initialize Airtable API
api = Api(AIRTABLE_API_KEY)
base = api.base(BASE_ID)
agents_table = base.table("Agents")
skills_table = base.table("Skills")

MARKETPLACES = {
    "dev-lifecycle": "/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace",
}

def extract_skills(content):
    """Extract skill references from content"""
    # Pattern: Skill(plugin:skill-name)
    pattern = r'Skill\(([a-z0-9-]+:[a-z0-9-]+)\)'
    matches = re.findall(pattern, content)
    return list(set(matches))

def link_agent_skills():
    """Link agents to skills they reference"""
    print("🔗 Linking agents to skills...")

    # Get all skills and create name→ID mapping
    skill_records = skills_table.all()
    skill_map = {}
    for rec in skill_records:
        skill_name = rec['fields'].get('Skill Name', '')
        if skill_name:
            skill_map[skill_name] = rec['id']

    print(f"📊 Found {len(skill_records)} skills")

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

        # Extract skills
        skill_refs = extract_skills(content)

        if not skill_refs:
            continue

        # Map to skill record IDs
        skill_ids = []
        for skill_ref in skill_refs:
            # skill_ref is like "quality:newman-testing"
            # But skill_name in table is just "newman-testing"
            skill_short_name = skill_ref.split(':')[1] if ':' in skill_ref else skill_ref

            skill_id = skill_map.get(skill_short_name)
            if skill_id:
                skill_ids.append(skill_id)
            else:
                print(f"  ℹ️  {agent_name}: Skill '{skill_ref}' not found in Skills table")

        if skill_ids:
            # Remove duplicates
            skill_ids = list(set(skill_ids))
            updates.append({
                'id': agent_id,
                'fields': {
                    'Skills': skill_ids
                }
            })
            print(f"  ✓ {agent_name}: Linking {len(skill_ids)} skills")

    # Batch update
    if updates:
        print(f"\n📝 Updating {len(updates)} agents...")
        batch_size = 10
        for i in range(0, len(updates), batch_size):
            batch = updates[i:i+batch_size]
            agents_table.batch_update(batch)
            print(f"  ✓ Updated {min(i+batch_size, len(updates))}/{len(updates)} agents")
    else:
        print("✓ No agent-skill links to create")

    print("\n✅ Linking complete!")
    print(f"   Updated {len(updates)} agents with skill links")

if __name__ == "__main__":
    link_agent_skills()

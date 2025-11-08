#!/usr/bin/env python3
"""
Populate Plugins table in Airtable from all marketplaces
This needs to run FIRST before populating agents/commands/skills
"""

import os
import json
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
marketplaces_table = base.table("Marketplaces")
plugins_table = base.table("Plugins")

MARKETPLACES = {
    "dev-lifecycle": "/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace",
    "ai-dev": "/home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace",
    "mcp-servers": "/home/gotime2022/.claude/plugins/marketplaces/mcp-servers-marketplace",
}

def get_or_create_marketplace(marketplace_name, marketplace_path):
    """Get or create marketplace record"""
    # Check if exists
    existing = marketplaces_table.all()
    for rec in existing:
        if rec['fields'].get('Marketplace Name') == marketplace_name:
            print(f"  ✓ Marketplace '{marketplace_name}' exists")
            return rec['id']

    # Create new
    print(f"  ➕ Creating marketplace: {marketplace_name}")
    record = marketplaces_table.create({
        'Marketplace Name': marketplace_name,
        'Directory Path': marketplace_path,
        'Description': f"{marketplace_name} marketplace",
    })
    return record['id']

def populate_plugins_for_marketplace(marketplace_name, marketplace_path, marketplace_id):
    """Populate all plugins for a marketplace"""
    print(f"\n📦 Populating plugins for {marketplace_name}...")

    plugins_dir = Path(marketplace_path) / "plugins"
    if not plugins_dir.exists():
        print(f"  ⚠️  No plugins directory found")
        return

    # Get existing plugins
    existing_plugins = plugins_table.all()
    # Create composite key: (name, marketplace_id)
    existing_map = {}
    for rec in existing_plugins:
        if 'Name' in rec['fields']:
            name = rec['fields']['Name']
            marketplace_links = rec['fields'].get('Marketplace Link', [])
            # Store by name with list of marketplace IDs
            if name not in existing_map:
                existing_map[name] = {'marketplaces': set(), 'records': []}
            existing_map[name]['marketplaces'].update(marketplace_links)
            existing_map[name]['records'].append(rec)

    created_count = 0
    skipped_count = 0

    # Scan for plugins
    for plugin_dir in plugins_dir.iterdir():
        if not plugin_dir.is_dir():
            continue

        # Skip archived directories
        if plugin_dir.name.startswith('archived') or plugin_dir.name.startswith('.archive'):
            continue

        plugin_name = plugin_dir.name

        # Check if plugin already exists IN THIS MARKETPLACE
        if plugin_name in existing_map:
            if marketplace_id in existing_map[plugin_name]['marketplaces']:
                print(f"  ✓ Plugin '{plugin_name}' exists in this marketplace")
                skipped_count += 1
                continue
            else:
                # Plugin exists but in DIFFERENT marketplace - this is a duplicate!
                other_marketplaces = existing_map[plugin_name]['marketplaces']
                print(f"  ⚠️  WARNING: Plugin '{plugin_name}' already exists in other marketplace(s)")
                print(f"      This marketplace: {marketplace_name}")
                print(f"      Other marketplace(s): {other_marketplaces}")
                print(f"      SKIPPING - plugins must have unique names across all marketplaces")
                skipped_count += 1
                continue

        # Read plugin.json if exists
        plugin_json = plugin_dir / ".claude-plugin" / "plugin.json"
        description = ""
        if plugin_json.exists():
            try:
                with open(plugin_json, 'r', encoding='utf-8') as f:
                    plugin_data = json.load(f)
                    description = plugin_data.get('description', '')
            except:
                pass

        # Create plugin record
        print(f"  ➕ Creating plugin: {plugin_name}")
        plugins_table.create({
            'Name': plugin_name,
            'Marketplace Link': [marketplace_id],
            'Description': description,
            'Directory Path': f"plugins/{plugin_name}",
            'Status': 'Active',
        })
        created_count += 1

    print(f"\n  Created: {created_count}")
    print(f"  Skipped (already exists): {skipped_count}")

if __name__ == "__main__":
    print("🔄 Populating Plugins and Marketplaces...")

    for marketplace_name, marketplace_path in MARKETPLACES.items():
        # Get or create marketplace
        marketplace_id = get_or_create_marketplace(marketplace_name, marketplace_path)

        # Populate plugins
        populate_plugins_for_marketplace(marketplace_name, marketplace_path, marketplace_id)

    print("\n✅ Plugins population complete!")

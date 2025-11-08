#!/usr/bin/env python3
"""
Fix Directory Path values in Plugins table
They should be "plugins/{name}" not "{marketplace}/{name}"
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
plugins_table = base.table("Plugins")

print("🔧 Fixing Directory Path values in Plugins table...")

# Get all plugins
plugins = plugins_table.all()

updates = []

for plugin in plugins:
    plugin_id = plugin['id']
    name = plugin['fields'].get('Name')
    current_path = plugin['fields'].get('Directory Path', '')

    # Expected format
    expected_path = f"plugins/{name}"

    if current_path != expected_path:
        print(f"  Fixing: {name}")
        print(f"    Current: {current_path}")
        print(f"    Fixed:   {expected_path}")

        updates.append({
            'id': plugin_id,
            'fields': {
                'Directory Path': expected_path
            }
        })

if updates:
    print(f"\n📝 Updating {len(updates)} records...")

    # Batch update (10 at a time)
    batch_size = 10
    for i in range(0, len(updates), batch_size):
        batch = updates[i:i+batch_size]
        plugins_table.batch_update(batch)
        print(f"  Updated {min(i+batch_size, len(updates))}/{len(updates)}")

    print("\n✅ All Directory Paths fixed!")
else:
    print("\n✅ All Directory Paths are already correct!")

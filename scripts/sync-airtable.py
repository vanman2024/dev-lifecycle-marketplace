#!/usr/bin/env python3
"""
Sync Airtable with filesystem - detect changes and update automatically

This script:
1. Scans the filesystem for all agents/commands/skills
2. Compares with existing Airtable records
3. Creates new records for new components
4. Updates changed records
5. Marks deleted components as deprecated
6. Re-links all relationships

Run this script after any plugin changes to keep Airtable in sync.
"""

import os
import re
from pathlib import Path
from pyairtable import Api
import yaml

# Airtable configuration
AIRTABLE_API_KEY = os.getenv("AIRTABLE_API_KEY", "pat6Wdcb4Uj6AtcFr.60698f69f01ab1e1a13d50558fdf7edbe80201d7279cde9531ed816984779ce9")
BASE_ID = "appHbSB7WhT1TxEQb"

# Initialize Airtable API
api = Api(AIRTABLE_API_KEY)
base = api.base(BASE_ID)
marketplaces_table = base.table("Marketplaces")
plugins_table = base.table("Plugins")
agents_table = base.table("Agents")
commands_table = base.table("Commands")
skills_table = base.table("Skills")
mcp_servers_table = base.table("MCP Servers")

MARKETPLACES = {
    "dev-lifecycle": "/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace",
    "ai-dev": "/home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace",
    "mcp-servers": "/home/gotime2022/.claude/plugins/marketplaces/mcp-servers-marketplace",
    "domain-plugin-builder": "/home/gotime2022/.claude/plugins/marketplaces/domain-plugin-builder",
}

def extract_frontmatter(file_path):
    """Extract YAML frontmatter from markdown file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Match YAML frontmatter
        match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
        if match:
            frontmatter_text = match.group(1)

            # Fix argument-hint lines with square brackets (YAML parsing issue)
            # Replace unquoted lines containing [ with quoted versions
            lines = frontmatter_text.split('\n')
            fixed_lines = []
            for line in lines:
                # If line contains argument-hint with [ and isn't already quoted
                if 'argument-hint:' in line and '[' in line:
                    if not (line.strip().endswith('"') or line.strip().endswith("'")):
                        # Extract the value part after the colon
                        parts = line.split(':', 1)
                        if len(parts) == 2:
                            key = parts[0]
                            value = parts[1].strip()
                            # Quote the value
                            line = f'{key}: "{value}"'
                fixed_lines.append(line)

            frontmatter_text = '\n'.join(fixed_lines)
            return yaml.safe_load(frontmatter_text)
        return None
    except Exception as e:
        print(f"  ⚠️  Error reading {file_path}: {e}")
        return None

def get_existing_records_map(table):
    """Create a map of existing records by name (or composite key for skills)"""
    records = table.all()
    record_map = {}

    # Determine name field based on table
    name_fields = {
        'Agents': 'Agent Name',
        'Commands': 'Command Name',
        'Skills': 'Skill Name',
        'Plugins': 'Name',
    }

    # Get table name from table object
    table_name = None
    for key, val in name_fields.items():
        # Try to identify table by checking first record
        if records and val in records[0]['fields']:
            table_name = key
            break

    if not table_name:
        return {}

    name_field = name_fields[table_name]

    for rec in records:
        if name_field in rec['fields']:
            # For skills, use composite key: plugin:skill-name
            if table_name == 'Skills' and 'Plugin' in rec['fields']:
                plugin_ids = rec['fields']['Plugin']
                skill_name = rec['fields'][name_field]
                # Use composite key to handle duplicate skill names across plugins
                for plugin_id in plugin_ids:
                    composite_key = f"{plugin_id}:{skill_name}"
                    record_map[composite_key] = {
                        'id': rec['id'],
                        'fields': rec['fields']
                    }
            else:
                name = rec['fields'][name_field]
                record_map[name] = {
                    'id': rec['id'],
                    'fields': rec['fields']
                }

    return record_map

def scan_filesystem_agents(marketplace_name, marketplace_path):
    """Scan filesystem for all agents"""
    agents = []
    plugins_dir = Path(marketplace_path) / "plugins"

    for plugin_dir in plugins_dir.iterdir():
        if not plugin_dir.is_dir():
            continue

        # Skip archived directories
        if plugin_dir.name.startswith('archived') or plugin_dir.name.startswith('.archive'):
            continue

        plugin_name = plugin_dir.name
        agents_dir = plugin_dir / "agents"

        if not agents_dir.exists():
            continue

        for agent_file in agents_dir.glob("*.md"):
            frontmatter = extract_frontmatter(agent_file)

            if not frontmatter:
                print(f"  ⚠️  {agent_file.name}: No frontmatter found")
                continue

            if 'name' not in frontmatter:
                print(f"  ⚠️  {agent_file.name}: Missing 'name' in frontmatter")
                continue

            agents.append({
                'name': frontmatter['name'],
                'plugin': plugin_name,
                'description': frontmatter.get('description', ''),
                'file_path': f"plugins/{plugin_name}/agents/{agent_file.name}",
                'model': frontmatter.get('model', 'inherit'),
                'color': frontmatter.get('color', 'blue'),
            })

    return agents

def scan_filesystem_commands(marketplace_name, marketplace_path):
    """Scan filesystem for all commands"""
    commands = []
    plugins_dir = Path(marketplace_path) / "plugins"

    for plugin_dir in plugins_dir.iterdir():
        if not plugin_dir.is_dir():
            continue

        # Skip archived directories
        if plugin_dir.name.startswith('archived') or plugin_dir.name.startswith('.archive'):
            continue

        plugin_name = plugin_dir.name
        commands_dir = plugin_dir / "commands"

        if not commands_dir.exists():
            continue

        for cmd_file in commands_dir.glob("*.md"):
            frontmatter = extract_frontmatter(cmd_file)

            if not frontmatter:
                print(f"  ⚠️  {cmd_file.name}: No frontmatter found")
                continue

            # Command name is /plugin:command-name
            cmd_name = f"/{plugin_name}:{cmd_file.stem}"

            commands.append({
                'name': cmd_name,
                'plugin': plugin_name,
                'description': frontmatter.get('description', ''),
                'file_path': f"plugins/{plugin_name}/commands/{cmd_file.name}",
                'argument_hint': frontmatter.get('argument-hint', ''),
            })

    return commands

def scan_filesystem_skills(marketplace_name, marketplace_path):
    """Scan filesystem for all skills"""
    skills = []
    plugins_dir = Path(marketplace_path) / "plugins"

    for plugin_dir in plugins_dir.iterdir():
        if not plugin_dir.is_dir():
            continue

        # Skip archived directories
        if plugin_dir.name.startswith('archived') or plugin_dir.name.startswith('.archive'):
            continue

        plugin_name = plugin_dir.name
        skills_dir = plugin_dir / "skills"

        if not skills_dir.exists():
            continue

        for skill_dir in skills_dir.iterdir():
            if not skill_dir.is_dir():
                continue

            skill_name = skill_dir.name
            skill_md = skill_dir / "SKILL.md"

            # Extract description from SKILL.md if it exists
            description = ""
            if skill_md.exists():
                try:
                    with open(skill_md, 'r', encoding='utf-8') as f:
                        content = f.read()
                        # Try to get first paragraph as description
                        lines = [l.strip() for l in content.split('\n') if l.strip() and not l.startswith('#')]
                        if lines:
                            description = lines[0]
                except:
                    pass

            skills.append({
                'name': skill_name,
                'plugin': plugin_name,
                'description': description,
                'directory_path': f"plugins/{plugin_name}/skills/{skill_name}",
                'has_skill_md': skill_md.exists(),
                'has_scripts': (skill_dir / "scripts").exists(),
                'has_templates': (skill_dir / "templates").exists(),
                'has_examples': (skill_dir / "examples").exists(),
            })

    return skills

def sync_components(marketplace_name, marketplace_path):
    """Sync all components for a marketplace"""
    print(f"\n🔄 Syncing {marketplace_name} marketplace...")

    # Get plugin record map
    plugins_map = get_existing_records_map(plugins_table)

    # Scan filesystem
    print("\n📂 Scanning filesystem...")
    fs_agents = scan_filesystem_agents(marketplace_name, marketplace_path)
    fs_commands = scan_filesystem_commands(marketplace_name, marketplace_path)
    fs_skills = scan_filesystem_skills(marketplace_name, marketplace_path)

    print(f"  Found {len(fs_agents)} agents")
    print(f"  Found {len(fs_commands)} commands")
    print(f"  Found {len(fs_skills)} skills")

    # Get existing Airtable records
    print("\n📊 Loading existing Airtable records...")
    existing_agents = get_existing_records_map(agents_table)
    existing_commands = get_existing_records_map(commands_table)
    existing_skills = get_existing_records_map(skills_table)

    print(f"  Existing agents: {len(existing_agents)}")
    print(f"  Existing commands: {len(existing_commands)}")
    print(f"  Existing skills: {len(existing_skills)}")

    # Sync agents
    print("\n🔄 Syncing agents...")
    sync_agents(fs_agents, existing_agents, plugins_map)

    # Sync commands
    print("\n🔄 Syncing commands...")
    sync_commands(fs_commands, existing_commands, plugins_map)

    # Sync skills
    print("\n🔄 Syncing skills...")
    sync_skills(fs_skills, existing_skills, plugins_map)

    print("\n✅ Sync complete!")

def sync_agents(fs_agents, existing_agents, plugins_map):
    """Sync agents - create new, update changed, mark deleted"""
    creates = []
    updates = []

    for agent in fs_agents:
        agent_name = agent['name']
        plugin_name = agent['plugin']

        # Get plugin record ID
        if plugin_name not in plugins_map:
            print(f"  ⚠️  Plugin '{plugin_name}' not found for agent '{agent_name}'")
            continue

        plugin_id = plugins_map[plugin_name]['id']

        if agent_name not in existing_agents:
            # Create new agent
            creates.append({
                'Agent Name': agent_name,
                'Plugin': [plugin_id],
                'File Path': agent['file_path'],
                'Purpose': agent['description'],
                'Status': 'Complete' if agent['description'] else 'Missing Documentation',
            })
            print(f"  ➕ New agent: {agent_name}")
        else:
            # Check if update needed
            existing = existing_agents[agent_name]
            needs_update = False

            updates_fields = {}

            if existing['fields'].get('Purpose') != agent['description']:
                updates_fields['Purpose'] = agent['description']
                needs_update = True

            if existing['fields'].get('File Path') != agent['file_path']:
                updates_fields['File Path'] = agent['file_path']
                needs_update = True

            if needs_update:
                updates.append({
                    'id': existing['id'],
                    'fields': updates_fields
                })
                print(f"  🔄 Update agent: {agent_name}")

    # Batch create
    if creates:
        print(f"\n  Creating {len(creates)} new agents...")
        batch_size = 10
        for i in range(0, len(creates), batch_size):
            batch = creates[i:i+batch_size]
            agents_table.batch_create(batch)
            print(f"    Created {min(i+batch_size, len(creates))}/{len(creates)}")

    # Batch update
    if updates:
        print(f"\n  Updating {len(updates)} agents...")
        batch_size = 10
        for i in range(0, len(updates), batch_size):
            batch = updates[i:i+batch_size]
            agents_table.batch_update(batch)
            print(f"    Updated {min(i+batch_size, len(updates))}/{len(updates)}")

    if not creates and not updates:
        print("  ✓ All agents up to date")

def sync_commands(fs_commands, existing_commands, plugins_map):
    """Sync commands - create new, update changed"""
    creates = []
    updates = []

    for command in fs_commands:
        cmd_name = command['name']
        plugin_name = command['plugin']

        # Get plugin record ID
        if plugin_name not in plugins_map:
            print(f"  ⚠️  Plugin '{plugin_name}' not found for command '{cmd_name}'")
            continue

        plugin_id = plugins_map[plugin_name]['id']

        if cmd_name not in existing_commands:
            # Create new command
            creates.append({
                'Command Name': cmd_name,
                'Plugin': [plugin_id],
                'Description': command['description'],
                'File Path': command['file_path'],
                'Argument Hint': command['argument_hint'],
            })
            print(f"  ➕ New command: {cmd_name}")
        else:
            # Check if update needed
            existing = existing_commands[cmd_name]
            needs_update = False

            updates_fields = {}

            if existing['fields'].get('Description') != command['description']:
                updates_fields['Description'] = command['description']
                needs_update = True

            if existing['fields'].get('File Path') != command['file_path']:
                updates_fields['File Path'] = command['file_path']
                needs_update = True

            if needs_update:
                updates.append({
                    'id': existing['id'],
                    'fields': updates_fields
                })
                print(f"  🔄 Update command: {cmd_name}")

    # Batch create/update (same as agents)
    if creates:
        print(f"\n  Creating {len(creates)} new commands...")
        batch_size = 10
        for i in range(0, len(creates), batch_size):
            batch = creates[i:i+batch_size]
            commands_table.batch_create(batch)
            print(f"    Created {min(i+batch_size, len(creates))}/{len(creates)}")

    if updates:
        print(f"\n  Updating {len(updates)} commands...")
        batch_size = 10
        for i in range(0, len(updates), batch_size):
            batch = updates[i:i+batch_size]
            commands_table.batch_update(batch)
            print(f"    Updated {min(i+batch_size, len(updates))}/{len(updates)}")

    if not creates and not updates:
        print("  ✓ All commands up to date")

def sync_skills(fs_skills, existing_skills, plugins_map):
    """Sync skills - create new, update changed"""
    creates = []
    updates = []
    updated_ids = set()  # Track which records we've already updated

    for skill in fs_skills:
        skill_name = skill['name']
        plugin_name = skill['plugin']

        # Get plugin record ID
        if plugin_name not in plugins_map:
            print(f"  ⚠️  Plugin '{plugin_name}' not found for skill '{skill_name}'")
            continue

        plugin_id = plugins_map[plugin_name]['id']

        # Use composite key to look up existing skill
        composite_key = f"{plugin_id}:{skill_name}"

        if composite_key not in existing_skills:
            # Create new skill
            creates.append({
                'Skill Name': skill_name,
                'Plugin': [plugin_id],
                'Description': skill['description'],
                'Directory Path': skill['directory_path'],
                'Has SKILL.md': skill['has_skill_md'],
                'Has Scripts': skill['has_scripts'],
                'Has Templates': skill['has_templates'],
                'Has Examples': skill['has_examples'],
            })
            print(f"  ➕ New skill: {plugin_name}/{skill_name}")
        else:
            # Check if update needed
            existing = existing_skills[composite_key]
            record_id = existing['id']

            # Skip if we've already updated this record
            if record_id in updated_ids:
                continue

            needs_update = False
            updates_fields = {}

            if existing['fields'].get('Description') != skill['description']:
                updates_fields['Description'] = skill['description']
                needs_update = True

            if existing['fields'].get('Has SKILL.md') != skill['has_skill_md']:
                updates_fields['Has SKILL.md'] = skill['has_skill_md']
                needs_update = True

            if needs_update:
                updates.append({
                    'id': record_id,
                    'fields': updates_fields
                })
                updated_ids.add(record_id)
                print(f"  🔄 Update skill: {plugin_name}/{skill_name}")

    # Batch create/update (same as agents)
    if creates:
        print(f"\n  Creating {len(creates)} new skills...")
        batch_size = 10
        for i in range(0, len(creates), batch_size):
            batch = creates[i:i+batch_size]
            skills_table.batch_create(batch)
            print(f"    Created {min(i+batch_size, len(creates))}/{len(creates)}")

    if updates:
        print(f"\n  Updating {len(updates)} skills...")
        batch_size = 10
        for i in range(0, len(updates), batch_size):
            batch = updates[i:i+batch_size]
            skills_table.batch_update(batch)
            print(f"    Updated {min(i+batch_size, len(updates))}/{len(updates)}")

    if not creates and not updates:
        print("  ✓ All skills up to date")

def resync_relationships():
    """Re-run all relationship linking scripts"""
    print("\n🔗 Re-syncing relationships...")

    # Import and run existing linking scripts
    import subprocess
    import sys

    scripts_dir = Path(__file__).parent

    scripts = [
        'migrate-mcp-links.py',
        'link-agent-commands.py',
        'link-agent-skills.py',
    ]

    for script in scripts:
        script_path = scripts_dir / script
        if script_path.exists():
            print(f"\n  Running {script}...")
            subprocess.run([sys.executable, str(script_path)])

if __name__ == "__main__":
    import sys

    # Check if specific marketplace requested
    if len(sys.argv) > 1:
        marketplace_name = sys.argv[1]
        if marketplace_name in MARKETPLACES:
            sync_components(marketplace_name, MARKETPLACES[marketplace_name])
        else:
            print(f"Unknown marketplace: {marketplace_name}")
            print(f"Available: {', '.join(MARKETPLACES.keys())}")
            sys.exit(1)
    else:
        # Sync all marketplaces
        for marketplace_name, marketplace_path in MARKETPLACES.items():
            sync_components(marketplace_name, marketplace_path)

    # Re-sync all relationships
    resync_relationships()

    print("\n✅ Full sync complete!")
    print("\nNext steps:")
    print("  1. Review changes in Airtable")
    print("  2. Validate data accuracy")
    print("  3. Run this script after any plugin modifications")

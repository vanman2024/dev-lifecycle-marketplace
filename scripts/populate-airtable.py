#!/usr/bin/env python3
"""
Populate Airtable with all plugins, agents, commands, skills, and MCP servers
Extracts data from actual plugin files and creates records with relationships
"""

import os
import json
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

# Table references
marketplaces_table = base.table("Marketplaces")
plugins_table = base.table("Plugins")
agents_table = base.table("Agents")
commands_table = base.table("Commands")
skills_table = base.table("Skills")
mcp_servers_table = base.table("MCP Servers")

# Marketplace paths
MARKETPLACES = {
    "dev-lifecycle": "/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace",
    "ai-dev": "/home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace",
    "ai-tech-stack-1": "/home/gotime2022/.claude/plugins/marketplaces/ai-tech-stack-1",
}

def extract_frontmatter(file_path):
    """Extract YAML frontmatter from markdown files"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Match YAML frontmatter between --- markers
        match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
        if match:
            frontmatter_text = match.group(1)
            frontmatter = {}
            for line in frontmatter_text.split('\n'):
                if ':' in line:
                    key, value = line.split(':', 1)
                    frontmatter[key.strip()] = value.strip()
            return frontmatter, content
        return {}, content
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return {}, ""

def has_section(content, section_name):
    """Check if markdown content has a specific section"""
    patterns = [
        f"## {section_name}",
        f"### {section_name}",
        f"**{section_name}**",
    ]
    return any(pattern in content for pattern in patterns)

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

def extract_mcp_servers(content):
    """Extract MCP server references from content"""
    # Pattern: mcp__servername
    pattern = r'mcp__([a-z0-9_-]+)'
    matches = re.findall(pattern, content)
    return list(set([f"mcp__{m}" for m in matches]))

def extract_skills(content):
    """Extract skill references from content"""
    # Pattern: Skill(plugin:skill-name)
    pattern = r'Skill\(([a-z0-9-]+:[a-z0-9-]+)\)'
    matches = re.findall(pattern, content)
    return list(set(matches))

def scan_agents(marketplace_name, plugin_path, plugin_record_id):
    """Scan all agents in a plugin"""
    agents_dir = Path(plugin_path) / "agents"
    if not agents_dir.exists():
        return []

    # Valid MCP servers from our predefined list
    VALID_MCP_SERVERS = {
        "mcp__supabase", "mcp__github", "mcp__airtable", "mcp__postman",
        "mcp__playwright", "mcp__shadcn", "mcp__context7", "mcp__memory", "mcp__filesystem"
    }

    agents_data = []
    for agent_file in agents_dir.glob("*.md"):
        frontmatter, content = extract_frontmatter(agent_file)

        # Extract data
        agent_name = frontmatter.get('name', agent_file.stem)
        description = frontmatter.get('description', '')

        # Check for sections
        has_slash_cmds = has_section(content, "Slash Commands Available") or has_section(content, "Available Tools & Resources")
        has_mcp = has_section(content, "MCP Servers Available") or "mcp__" in content
        has_skills_section = has_section(content, "Skills Available")

        # Extract references
        slash_commands = extract_slash_commands(content)
        mcp_servers = extract_mcp_servers(content)
        skills_used = extract_skills(content)

        # Filter to only valid MCP servers
        valid_mcps = [m for m in mcp_servers if m in VALID_MCP_SERVERS]

        # Determine status
        if has_slash_cmds and has_mcp and has_skills_section:
            status = "Complete"
        elif not has_slash_cmds or not has_mcp:
            status = "Missing Documentation"
        else:
            status = "Needs Update"

        agents_data.append({
            "Agent Name": agent_name,
            "Plugin": [plugin_record_id],
            "File Path": str(agent_file.relative_to(MARKETPLACES[marketplace_name])),
            "Purpose": description,
            "Has Slash Commands Section": has_slash_cmds,
            "Has MCP Section": has_mcp,
            "Has Skills Section": has_skills_section,
            "Status": status,
            "MCP Servers": valid_mcps if valid_mcps else [],  # Only valid MCPs
            "_slash_commands": slash_commands,  # Store for later linking
            "_skills": skills_used,  # Store for later linking
        })

    return agents_data

def scan_commands(marketplace_name, plugin_path, plugin_record_id):
    """Scan all commands in a plugin"""
    commands_dir = Path(plugin_path) / "commands"
    if not commands_dir.exists():
        return []

    commands_data = []
    for cmd_file in commands_dir.glob("*.md"):
        frontmatter, content = extract_frontmatter(cmd_file)

        # Extract command name from filename
        command_name = f"/{cmd_file.stem}"
        if '/' not in cmd_file.stem:
            # Get plugin name from path
            plugin_name = Path(plugin_path).name
            command_name = f"/{plugin_name}:{cmd_file.stem}"

        commands_data.append({
            "Command Name": command_name,
            "Plugin": [plugin_record_id],
            "Description": frontmatter.get('description', ''),
            "File Path": str(cmd_file.relative_to(MARKETPLACES[marketplace_name])),
            "Argument Hint": frontmatter.get('argument-hint', ''),
            "Registered in Settings": True,  # Assume registered
        })

    return commands_data

def scan_skills(marketplace_name, plugin_path, plugin_record_id):
    """Scan all skills in a plugin"""
    skills_dir = Path(plugin_path) / "skills"
    if not skills_dir.exists():
        return []

    skills_data = []
    for skill_dir in skills_dir.iterdir():
        if not skill_dir.is_dir():
            continue

        skill_md = skill_dir / "SKILL.md"
        has_skill_md = skill_md.exists()

        # Check for subdirectories
        has_scripts = (skill_dir / "scripts").exists()
        has_templates = (skill_dir / "templates").exists()
        has_examples = (skill_dir / "examples").exists()

        # Extract description if SKILL.md exists
        description = ""
        if has_skill_md:
            _, content = extract_frontmatter(skill_md)
            # Get first paragraph as description
            lines = content.split('\n')
            for line in lines:
                if line.strip() and not line.startswith('#'):
                    description = line.strip()
                    break

        skills_data.append({
            "Skill Name": skill_dir.name,
            "Plugin": [plugin_record_id],
            "Description": description,
            "Directory Path": str(skill_dir.relative_to(MARKETPLACES[marketplace_name])),
            "Has SKILL.md": has_skill_md,
            "Has Scripts": has_scripts,
            "Has Templates": has_templates,
            "Has Examples": has_examples,
        })

    return skills_data

def get_existing_plugin_records():
    """Get existing plugin records to map names to IDs"""
    records = plugins_table.all()
    plugin_map = {}
    for rec in records:
        # Skip records without Name field
        if 'Name' not in rec['fields']:
            continue
        name = rec['fields']['Name']
        plugin_map[name] = rec['id']
    return plugin_map

def populate_all_data():
    """Main function to populate all tables"""
    print("🚀 Starting Airtable population...")

    # Get existing plugins mapping
    plugin_map = get_existing_plugin_records()
    print(f"📦 Found {len(plugin_map)} existing plugins")

    all_agents = []
    all_commands = []
    all_skills = []

    # Scan dev-lifecycle marketplace
    print("\n📊 Scanning dev-lifecycle marketplace...")
    dev_lifecycle_path = MARKETPLACES["dev-lifecycle"]
    plugins_path = Path(dev_lifecycle_path) / "plugins"

    for plugin_dir in plugins_path.iterdir():
        if not plugin_dir.is_dir() or plugin_dir.name.startswith('.'):
            continue

        plugin_name = plugin_dir.name
        if plugin_name not in plugin_map:
            print(f"  ⚠️  Plugin {plugin_name} not in Airtable, skipping")
            continue

        plugin_id = plugin_map[plugin_name]
        print(f"  📁 Scanning {plugin_name}...")

        # Scan agents
        agents = scan_agents("dev-lifecycle", plugin_dir, plugin_id)
        all_agents.extend(agents)
        print(f"    ✓ Found {len(agents)} agents")

        # Scan commands
        commands = scan_commands("dev-lifecycle", plugin_dir, plugin_id)
        all_commands.extend(commands)
        print(f"    ✓ Found {len(commands)} commands")

        # Scan skills
        skills = scan_skills("dev-lifecycle", plugin_dir, plugin_id)
        all_skills.extend(skills)
        print(f"    ✓ Found {len(skills)} skills")

    # TODO: Add AI-dev and ai-tech-stack-1 scanning

    # Bulk create agents
    print(f"\n📝 Creating {len(all_agents)} agent records...")
    if all_agents:
        batch_size = 10
        for i in range(0, len(all_agents), batch_size):
            batch = all_agents[i:i+batch_size]
            # Remove temporary fields
            clean_batch = []
            for agent in batch:
                clean_agent = {k: v for k, v in agent.items() if not k.startswith('_')}
                clean_batch.append(clean_agent)
            agents_table.batch_create(clean_batch)
            print(f"  ✓ Created {min(i+batch_size, len(all_agents))}/{len(all_agents)} agents")

    # Bulk create commands
    print(f"\n📝 Creating {len(all_commands)} command records...")
    if all_commands:
        batch_size = 10
        for i in range(0, len(all_commands), batch_size):
            batch = all_commands[i:i+batch_size]
            commands_table.batch_create(batch)
            print(f"  ✓ Created {min(i+batch_size, len(all_commands))}/{len(all_commands)} commands")

    # Bulk create skills
    print(f"\n📝 Creating {len(all_skills)} skill records...")
    if all_skills:
        batch_size = 10
        for i in range(0, len(all_skills), batch_size):
            batch = all_skills[i:i+batch_size]
            skills_table.batch_create(batch)
            print(f"  ✓ Created {min(i+batch_size, len(all_skills))}/{len(all_skills)} skills")

    print("\n✅ Population complete!")
    print(f"   📊 Total: {len(all_agents)} agents, {len(all_commands)} commands, {len(all_skills)} skills")

if __name__ == "__main__":
    populate_all_data()

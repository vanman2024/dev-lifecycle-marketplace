#!/usr/bin/env python3
"""
Sync Airtable database to GitHub repository files
Generates markdown and JSON files from Airtable records
"""

import os
import json
from datetime import datetime
from pathlib import Path
from pyairtable import Api

# Configuration
AIRTABLE_TOKEN = os.getenv("AIRTABLE_TOKEN")
AIRTABLE_BASE_ID = os.getenv("AIRTABLE_BASE_ID", "appHbSB7WhT1TxEQb")

# Output directories
SYNC_DIR = Path("airtable-sync")
AGENTS_DIR = SYNC_DIR / "agents"
COMMANDS_DIR = SYNC_DIR / "commands"
SKILLS_DIR = SYNC_DIR / "skills"
PLUGINS_DIR = SYNC_DIR / "plugins"
MCP_SERVERS_DIR = SYNC_DIR / "mcp-servers"

def setup_directories():
    """Create output directories"""
    for directory in [SYNC_DIR, AGENTS_DIR, COMMANDS_DIR, SKILLS_DIR, PLUGINS_DIR, MCP_SERVERS_DIR]:
        directory.mkdir(parents=True, exist_ok=True)

def clean_field_value(value):
    """Clean field values for safe serialization"""
    if isinstance(value, list):
        return [clean_field_value(v) for v in value]
    elif isinstance(value, dict):
        return {k: clean_field_value(v) for k, v in value.items()}
    else:
        return value

def sync_table_to_json(api, table_name, output_file):
    """Sync entire table to JSON file"""
    table = api.table(AIRTABLE_BASE_ID, table_name)
    records = table.all()

    # Extract just the fields with cleaned values
    data = [
        {
            "id": record["id"],
            "fields": {k: clean_field_value(v) for k, v in record["fields"].items()}
        }
        for record in records
    ]

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ Synced {len(data)} records from {table_name} to {output_file}")
    return data

def sync_agents_to_markdown(agents_data):
    """Generate markdown files for each agent"""
    for agent in agents_data:
        fields = agent["fields"]
        agent_name = fields.get("Agent Name", "unknown")

        # Create markdown content
        md_content = f"""# {agent_name}

**Plugin**: {', '.join(fields.get("Plugin", []))}
**File Path**: `{fields.get("File Path", "N/A")}`
**Status**: {fields.get("Progress Status", "Unknown")}

## Purpose

{fields.get("Purpose", "No description provided")}

## Capabilities

- Has Slash Commands Section: {"✅" if fields.get("Has Slash Commands Section") else "❌"}
- Has MCP Section: {"✅" if fields.get("Has MCP Section") else "❌"}
- Has Skills Section: {"✅" if fields.get("Has Skills Section") else "❌"}

## Related Resources

**Skills**: {', '.join(fields.get("Skills", [])) if fields.get("Skills") else "None"}
**Commands**: {', '.join(fields.get("Uses Commands", [])) if fields.get("Uses Commands") else "None"}
**MCP Servers**: {', '.join(fields.get("MCP Servers Linked", [])) if fields.get("MCP Servers Linked") else "None"}

## Notes

{fields.get("Notes", "No notes")}

## Issues

{chr(10).join(f"- {issue}" for issue in fields.get("Issues", [])) if fields.get("Issues") else "None"}

---
*Last synced: {datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")}*
*Airtable Record ID: {agent["id"]}*
"""

        # Write to file
        filename = AGENTS_DIR / f"{agent_name.lower().replace(' ', '-')}.md"
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(md_content)

    print(f"✅ Generated {len(agents_data)} agent markdown files")

def sync_commands_to_markdown(commands_data):
    """Generate markdown files for each command"""
    for command in commands_data:
        fields = command["fields"]
        command_name = fields.get("Command Name", "unknown")

        md_content = f"""# {command_name}

**Plugin**: {', '.join(fields.get("Plugin", []))}
**File Path**: `{fields.get("File Path", "N/A")}`

## Description

{fields.get("Description", "No description provided")}

## Usage

**Argument Hint**: `{fields.get("Argument Hint", "")}`

## Agent Invocation

**Invokes Agent**: {', '.join(fields.get("Invokes Agent", [])) if fields.get("Invokes Agent") else "None"}

## Metadata

- Registered in Settings: {"✅" if fields.get("Registered in Settings") else "❌"}

## Notes

{fields.get("Notes", "No notes")}

---
*Last synced: {datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")}*
*Airtable Record ID: {command["id"]}*
"""

        filename = COMMANDS_DIR / f"{command_name.lower().replace(' ', '-').replace('/', '-')}.md"
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(md_content)

    print(f"✅ Generated {len(commands_data)} command markdown files")

def sync_skills_to_markdown(skills_data):
    """Generate markdown files for each skill"""
    for skill in skills_data:
        fields = skill["fields"]
        skill_name = fields.get("Skill Name", "unknown")

        md_content = f"""# {skill_name}

**Plugin**: {', '.join(fields.get("Plugin", []))}
**Directory Path**: `{fields.get("Directory Path", "N/A")}`

## Description

{fields.get("Description", "No description provided")}

## Components

- Has SKILL.md: {"✅" if fields.get("Has SKILL.md") else "❌"}
- Has Scripts: {"✅" if fields.get("Has Scripts") else "❌"}
- Has Templates: {"✅" if fields.get("Has Templates") else "❌"}
- Has Examples: {"✅" if fields.get("Has Examples") else "❌"}

## Used By Agents

{', '.join(fields.get("Used By Agents", [])) if fields.get("Used By Agents") else "None"}

## Notes

{fields.get("Notes", "No notes")}

---
*Last synced: {datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")}*
*Airtable Record ID: {skill["id"]}*
"""

        filename = SKILLS_DIR / f"{skill_name.lower().replace(' ', '-')}.md"
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(md_content)

    print(f"✅ Generated {len(skills_data)} skill markdown files")

def generate_summary_report(plugins_data, agents_data, commands_data, skills_data):
    """Generate comprehensive summary report"""
    report = f"""# Airtable Sync Report

**Last Updated**: {datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")}

## Overview

- **Plugins**: {len(plugins_data)}
- **Agents**: {len(agents_data)}
- **Commands**: {len(commands_data)}
- **Skills**: {len(skills_data)}

## Plugins

{chr(10).join(f"- {p['fields'].get('Name', 'Unknown')}: {p['fields'].get('Status', 'Unknown')}" for p in plugins_data)}

## Agents by Status

"""

    # Count agents by status
    status_counts = {}
    for agent in agents_data:
        status = agent["fields"].get("Progress Status", "Unknown")
        status_counts[status] = status_counts.get(status, 0) + 1

    for status, count in sorted(status_counts.items()):
        report += f"- **{status}**: {count}\n"

    report += f"""
## Files Generated

- Agent markdown files: {len(agents_data)}
- Command markdown files: {len(commands_data)}
- Skill markdown files: {len(skills_data)}
- JSON exports: 5 tables

---
*Generated automatically by Airtable sync workflow*
"""

    with open(SYNC_DIR / "SYNC-REPORT.md", 'w', encoding='utf-8') as f:
        f.write(report)

    print("✅ Generated summary report")

def main():
    """Main sync function"""
    print("🚀 Starting Airtable to GitHub sync...")

    if not AIRTABLE_TOKEN:
        print("❌ Error: AIRTABLE_TOKEN environment variable not set")
        return 1

    # Initialize Airtable API
    api = Api(AIRTABLE_TOKEN)

    # Setup directories
    setup_directories()

    # Sync tables to JSON
    print("\n📥 Syncing tables to JSON...")
    plugins_data = sync_table_to_json(api, "Plugins", SYNC_DIR / "plugins.json")
    agents_data = sync_table_to_json(api, "Agents", SYNC_DIR / "agents.json")
    commands_data = sync_table_to_json(api, "Commands", SYNC_DIR / "commands.json")
    skills_data = sync_table_to_json(api, "Skills", SYNC_DIR / "skills.json")
    mcp_data = sync_table_to_json(api, "MCP Servers", SYNC_DIR / "mcp-servers.json")

    # Generate markdown files
    print("\n📝 Generating markdown files...")
    sync_agents_to_markdown(agents_data)
    sync_commands_to_markdown(commands_data)
    sync_skills_to_markdown(skills_data)

    # Generate summary report
    print("\n📊 Generating summary report...")
    generate_summary_report(plugins_data, agents_data, commands_data, skills_data)

    print("\n✅ Sync completed successfully!")
    return 0

if __name__ == "__main__":
    exit(main())

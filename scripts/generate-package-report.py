#!/usr/bin/env python3
"""
Generate packaging reports showing what each component needs to work

This helps identify:
- Which MCP servers are needed for a component
- Which commands a component uses
- Which skills a component needs
- Complete dependency tree for packaging

Use this to create reusable "bundles" for other projects.
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
agents_table = base.table("Agents")
commands_table = base.table("Commands")
skills_table = base.table("Skills")
mcp_servers_table = base.table("MCP Servers")
plugins_table = base.table("Plugins")

def get_all_mcp_servers():
    """Get list of all available MCP servers"""
    servers = mcp_servers_table.all()
    return {rec['id']: rec['fields'] for rec in servers}

def get_all_skills():
    """Get list of all available skills"""
    skills = skills_table.all()
    return {rec['id']: rec['fields'] for rec in skills}

def get_all_commands():
    """Get list of all available commands"""
    commands = commands_table.all()
    return {rec['id']: rec['fields'] for rec in commands}

def get_all_agents():
    """Get list of all agents with dependencies"""
    agents = agents_table.all()
    return {rec['id']: rec['fields'] for rec in agents}

def get_all_plugins():
    """Get list of all plugins"""
    plugins = plugins_table.all()
    return {rec['id']: rec['fields'] for rec in plugins}

def build_agent_package(agent_id, agent_data, all_commands, all_skills, all_mcps):
    """Build complete package info for an agent"""
    package = {
        'agent_name': agent_data.get('Agent Name'),
        'description': agent_data.get('Purpose', ''),
        'file_path': agent_data.get('File Path', ''),
        'dependencies': {
            'commands': [],
            'skills': [],
            'mcp_servers': []
        }
    }

    # Get commands this agent uses
    uses_commands = agent_data.get('Uses Commands', [])
    for cmd_id in uses_commands:
        if cmd_id in all_commands:
            package['dependencies']['commands'].append({
                'name': all_commands[cmd_id].get('Command Name'),
                'description': all_commands[cmd_id].get('Description', '')
            })

    # Get skills this agent uses
    skills_used = agent_data.get('Skills', [])
    for skill_id in skills_used:
        if skill_id in all_skills:
            package['dependencies']['skills'].append({
                'name': all_skills[skill_id].get('Skill Name'),
                'description': all_skills[skill_id].get('Description', ''),
                'has_scripts': all_skills[skill_id].get('Has Scripts', False),
                'has_templates': all_skills[skill_id].get('Has Templates', False),
            })

    # Get MCP servers this agent uses
    mcp_servers = agent_data.get('MCP Servers Linked', [])
    for mcp_id in mcp_servers:
        if mcp_id in all_mcps:
            package['dependencies']['mcp_servers'].append({
                'name': all_mcps[mcp_id].get('MCP Server Name'),
                'description': all_mcps[mcp_id].get('Description', ''),
                'purpose': all_mcps[mcp_id].get('Purpose', '')
            })

    return package

def generate_all_mcp_list():
    """Generate list of all MCP servers"""
    print("\n" + "="*80)
    print("ALL AVAILABLE MCP SERVERS")
    print("="*80)

    servers = get_all_mcp_servers()

    print(f"\nTotal MCP Servers: {len(servers)}\n")

    for server_id, server_data in sorted(servers.items(), key=lambda x: x[1].get('MCP Server Name', '')):
        name = server_data.get('MCP Server Name')
        description = server_data.get('Description', 'No description')
        purpose = server_data.get('Purpose', 'No purpose specified')

        print(f"📦 {name}")
        print(f"   Description: {description}")
        print(f"   Purpose: {purpose}")
        print()

    return servers

def generate_plugin_packages(plugin_filter=None):
    """Generate packaging report for plugins"""
    print("\n" + "="*80)
    print("PLUGIN PACKAGING REPORT")
    print("="*80)

    # Get all data
    all_mcps = get_all_mcp_servers()
    all_skills = get_all_skills()
    all_commands = get_all_commands()
    all_agents = get_all_agents()
    all_plugins = get_all_plugins()

    # Filter plugins if specified
    plugins_to_process = {}
    for plugin_id, plugin_data in all_plugins.items():
        plugin_name = plugin_data.get('Name', '')
        if plugin_filter is None or plugin_filter in plugin_name:
            plugins_to_process[plugin_id] = plugin_data

    # Process each plugin
    for plugin_id, plugin_data in sorted(plugins_to_process.items(), key=lambda x: x[1].get('Name', '')):
        plugin_name = plugin_data.get('Name')

        print(f"\n{'='*80}")
        print(f"PLUGIN: {plugin_name}")
        print(f"{'='*80}")

        # Get agents in this plugin
        plugin_agents = []
        for agent_id, agent_data in all_agents.items():
            agent_plugin_ids = agent_data.get('Plugin', [])
            if plugin_id in agent_plugin_ids:
                plugin_agents.append((agent_id, agent_data))

        print(f"\n📊 Total Agents: {len(plugin_agents)}\n")

        # Build package for each agent
        for agent_id, agent_data in sorted(plugin_agents, key=lambda x: x[1].get('Agent Name', '')):
            package = build_agent_package(agent_id, agent_data, all_commands, all_skills, all_mcps)

            print(f"🤖 {package['agent_name']}")
            print(f"   {package['description'][:100]}...")

            if package['dependencies']['commands']:
                print(f"\n   📋 Uses Commands ({len(package['dependencies']['commands'])}):")
                for cmd in package['dependencies']['commands']:
                    print(f"      • {cmd['name']}")

            if package['dependencies']['skills']:
                print(f"\n   🎯 Uses Skills ({len(package['dependencies']['skills'])}):")
                for skill in package['dependencies']['skills']:
                    flags = []
                    if skill['has_scripts']:
                        flags.append('scripts')
                    if skill['has_templates']:
                        flags.append('templates')
                    flag_str = f" [{', '.join(flags)}]" if flags else ""
                    print(f"      • {skill['name']}{flag_str}")

            if package['dependencies']['mcp_servers']:
                print(f"\n   🔌 Uses MCP Servers ({len(package['dependencies']['mcp_servers'])}):")
                for mcp in package['dependencies']['mcp_servers']:
                    print(f"      • {mcp['name']}")

            print()

def generate_deployment_package():
    """Generate special report for deployment plugin (most likely to be reused)"""
    print("\n" + "="*80)
    print("DEPLOYMENT PLUGIN - REUSABLE PACKAGE")
    print("="*80)
    print("\nThis package can be copied to any project for deployment capabilities\n")

    # Get all data
    all_mcps = get_all_mcp_servers()
    all_skills = get_all_skills()
    all_commands = get_all_commands()
    all_agents = get_all_agents()
    all_plugins = get_all_plugins()

    # Find deployment plugin
    deployment_plugin_id = None
    for plugin_id, plugin_data in all_plugins.items():
        if plugin_data.get('Name') == 'deployment':
            deployment_plugin_id = plugin_id
            break

    if not deployment_plugin_id:
        print("⚠️  Deployment plugin not found")
        return

    # Collect all dependencies
    all_mcps_needed = set()
    all_skills_needed = set()
    all_commands_needed = set()

    # Get agents in deployment plugin
    deployment_agents = []
    for agent_id, agent_data in all_agents.items():
        agent_plugin_ids = agent_data.get('Plugin', [])
        if deployment_plugin_id in agent_plugin_ids:
            deployment_agents.append((agent_id, agent_data))

            # Collect dependencies
            all_mcps_needed.update(agent_data.get('MCP Servers Linked', []))
            all_skills_needed.update(agent_data.get('Skills', []))
            all_commands_needed.update(agent_data.get('Uses Commands', []))

    print(f"📦 Package Contents:")
    print(f"   • {len(deployment_agents)} agents")
    print(f"   • {len(all_commands_needed)} commands")
    print(f"   • {len(all_skills_needed)} skills")
    print(f"   • {len(all_mcps_needed)} MCP servers")

    print(f"\n🔌 Required MCP Servers:")
    for mcp_id in sorted(all_mcps_needed):
        if mcp_id in all_mcps:
            print(f"   • {all_mcps[mcp_id].get('MCP Server Name')}")

    print(f"\n🎯 Required Skills:")
    for skill_id in sorted(all_skills_needed):
        if skill_id in all_skills:
            skill_name = all_skills[skill_id].get('Skill Name')
            print(f"   • {skill_name}")

    print(f"\n📋 Required Commands:")
    for cmd_id in sorted(all_commands_needed):
        if cmd_id in all_commands:
            print(f"   • {all_commands[cmd_id].get('Command Name')}")

    print(f"\n📝 Installation Instructions:")
    print(f"   1. Copy plugins/deployment/ directory")
    print(f"   2. Copy required skills to plugins/deployment/skills/")
    print(f"   3. Install required MCP servers in .mcp.json")
    print(f"   4. Register commands in .claude/commands/")
    print(f"   5. Update plugin.json with deployment plugin")

def generate_json_export():
    """Export all packaging data as JSON for programmatic use"""
    output_file = Path("packaging-data.json")

    all_mcps = get_all_mcp_servers()
    all_skills = get_all_skills()
    all_commands = get_all_commands()
    all_agents = get_all_agents()
    all_plugins = get_all_plugins()

    # Build complete export
    export_data = {
        'mcp_servers': {mcp_id: data for mcp_id, data in all_mcps.items()},
        'skills': {skill_id: data for skill_id, data in all_skills.items()},
        'commands': {cmd_id: data for cmd_id, data in all_commands.items()},
        'agents': {agent_id: data for agent_id, data in all_agents.items()},
        'plugins': {plugin_id: data for plugin_id, data in all_plugins.items()},
    }

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(export_data, f, indent=2)

    print(f"\n✅ Exported packaging data to {output_file}")
    return output_file

if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == "mcp-list":
            # List all MCP servers
            generate_all_mcp_list()

        elif command == "plugin":
            # Generate report for specific plugin
            plugin_name = sys.argv[2] if len(sys.argv) > 2 else None
            generate_plugin_packages(plugin_filter=plugin_name)

        elif command == "deployment":
            # Generate deployment package report
            generate_deployment_package()

        elif command == "export":
            # Export JSON
            generate_json_export()

        elif command == "all":
            # Generate all reports
            generate_all_mcp_list()
            generate_plugin_packages()
            generate_deployment_package()
            generate_json_export()

        else:
            print("Unknown command")
            print("\nUsage:")
            print("  python3 generate-package-report.py mcp-list      # List all MCP servers")
            print("  python3 generate-package-report.py plugin [name] # Report for plugin")
            print("  python3 generate-package-report.py deployment    # Deployment package")
            print("  python3 generate-package-report.py export        # Export JSON")
            print("  python3 generate-package-report.py all           # All reports")
    else:
        # Default: show deployment package (most useful)
        generate_deployment_package()

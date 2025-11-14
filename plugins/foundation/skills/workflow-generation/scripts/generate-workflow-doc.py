#!/usr/bin/env python3

"""
generate-workflow-doc.py
Queries Airtable and validates commands, returns JSON data
Usage: python3 generate-workflow-doc.py "AI Tech Stack 1" --json-only
"""

import os
import sys
import json
import requests

# Configuration
AIRTABLE_TOKEN = os.getenv("AIRTABLE_TOKEN") or os.getenv("MCP_AIRTABLE_TOKEN")
BASE_ID = "appHbSB7WhT1TxEQb"
MARKETPLACE_ROOT = "/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace"

# Table IDs
TECH_STACKS_TABLE = "tblG07GusbRMJ9h1I"
PLUGINS_TABLE = "tblVEI2x2xArVx9ID"
COMMANDS_TABLE = "tblWKaSceuRJrBFC1"
AGENTS_TABLE = "tblNngn8hglFXZKnl"
SKILLS_TABLE = "tblWJSyghUzEiV1Cc"

def get_tech_stack(stack_name):
    """Query tech stack by name"""
    url = f"https://api.airtable.com/v0/{BASE_ID}/{TECH_STACKS_TABLE}"
    headers = {"Authorization": f"Bearer {AIRTABLE_TOKEN}"}
    params = {"filterByFormula": f'{{Stack Name}}="{stack_name}"'}

    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()

    data = response.json()
    if not data.get("records"):
        return None

    return data["records"][0]

def get_plugin(plugin_id):
    """Get plugin details by ID"""
    url = f"https://api.airtable.com/v0/{BASE_ID}/{PLUGINS_TABLE}/{plugin_id}"
    headers = {"Authorization": f"Bearer {AIRTABLE_TOKEN}"}

    response = requests.get(url, headers=headers)
    response.raise_for_status()

    return response.json()

def get_commands_batch(command_ids):
    """Get multiple command details in batch using filterByFormula"""
    if not command_ids:
        return []

    # Build OR formula for batch query
    id_conditions = [f'RECORD_ID()="{cmd_id}"' for cmd_id in command_ids[:100]]  # Airtable limit
    formula = f'OR({",".join(id_conditions)})'

    url = f"https://api.airtable.com/v0/{BASE_ID}/{COMMANDS_TABLE}"
    headers = {"Authorization": f"Bearer {AIRTABLE_TOKEN}"}
    params = {"filterByFormula": formula}

    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()

    return response.json().get("records", [])

def extract_plugin_ids(tech_stack_record):
    """Extract all plugin IDs from tech stack record"""
    fields = tech_stack_record.get("fields", {})
    plugin_fields = [
        "Foundation", "Planning", "Iteration", "Quality", "Deployment",
        "Versioning", "Supervision", "Security", "Testing",
        "Frontend Framework", "Backend Framework", "Database",
        "AI Framework", "Memory Layer", "Payments", "Authentication"
    ]

    plugin_ids = []
    for field in plugin_fields:
        if field in fields and isinstance(fields[field], list):
            plugin_ids.extend(fields[field])

    # Remove duplicates
    return list(set(plugin_ids))

def validate_commands(plugins_data):
    """Validate that Airtable commands exist in marketplace filesystem"""
    warnings = []

    for plugin_data in plugins_data:
        plugin_name = plugin_data['name']
        commands_dir = f"{MARKETPLACE_ROOT}/plugins/{plugin_name}/commands"

        # Check if plugin directory exists
        if not os.path.exists(commands_dir):
            warnings.append(f"⚠️  Plugin directory not found: {commands_dir}")
            continue

        # Get commands on disk
        try:
            disk_command_files = [f.replace('.md', '') for f in os.listdir(commands_dir) if f.endswith('.md')]
        except Exception as e:
            warnings.append(f"⚠️  Error reading {commands_dir}: {str(e)}")
            continue

        # Check Airtable commands exist on disk
        airtable_command_names = [cmd['name'] for cmd in plugin_data['commands']]
        for cmd_name in airtable_command_names:
            if cmd_name not in disk_command_files:
                warnings.append(f"⚠️  Command in Airtable but not found in filesystem: {plugin_name}:{cmd_name}")

        # Check disk commands exist in Airtable
        for disk_cmd in disk_command_files:
            if disk_cmd not in airtable_command_names:
                warnings.append(f"⚠️  Command exists in filesystem but not in Airtable: {plugin_name}:{disk_cmd}")

    return warnings

def get_workflow_data(tech_stack_name):
    """Get workflow data from Airtable and validate"""

    if not AIRTABLE_TOKEN:
        return {
            "error": "AIRTABLE_TOKEN or MCP_AIRTABLE_TOKEN environment variable not set",
            "message": "Export it: export MCP_AIRTABLE_TOKEN=your_token_here"
        }

    # Query tech stack
    tech_stack = get_tech_stack(tech_stack_name)

    if not tech_stack:
        return {
            "error": f"Tech stack not found: {tech_stack_name}"
        }

    fields = tech_stack.get("fields", {})
    stack_name = fields.get("Stack Name")
    description = fields.get("Description", "")
    use_cases = fields.get("Detailed Use Cases", [])

    # Extract plugin IDs
    plugin_ids = extract_plugin_ids(tech_stack)

    # Query plugins table to get plugin details
    plugins_data = []

    for plugin_id in plugin_ids:
        plugin = get_plugin(plugin_id)
        plugin_name = plugin.get("fields", {}).get("Name")
        command_ids = plugin.get("fields", {}).get("Commands", [])
        agent_ids = plugin.get("fields", {}).get("Agents", [])
        skill_ids = plugin.get("fields", {}).get("Skills", [])

        plugin_entry = {
            "name": plugin_name,
            "command_ids": command_ids,
            "agent_ids": agent_ids,
            "skill_ids": skill_ids,
            "commands": [],
            "agents": [],
            "skills": []
        }
        plugins_data.append(plugin_entry)

    # Get ALL command details using batch queries
    all_command_ids = []
    for plugin_data in plugins_data:
        all_command_ids.extend(plugin_data["command_ids"])

    # Fetch in batches of 100 (Airtable limit)
    all_commands = {}
    for i in range(0, len(all_command_ids), 100):
        batch_ids = all_command_ids[i:i+100]
        batch_commands = get_commands_batch(batch_ids)
        for cmd in batch_commands:
            all_commands[cmd["id"]] = cmd

    # Map commands back to plugins
    for plugin_data in plugins_data:
        for command_id in plugin_data["command_ids"]:
            if command_id in all_commands:
                command_fields = all_commands[command_id].get("fields", {})
                plugin_data["commands"].append({
                    "name": command_fields.get("Command Name", ""),
                    "description": command_fields.get("Description", "")
                })

    # Validate commands exist in filesystem
    validation_warnings = validate_commands(plugins_data)

    # Return JSON data
    return {
        "tech_stack": {
            "name": stack_name,
            "description": description,
            "use_cases": use_cases
        },
        "plugins": plugins_data,
        "validation": {
            "warnings": validation_warnings,
            "total_plugins": len(plugins_data),
            "total_commands": sum(len(p["commands"]) for p in plugins_data)
        }
    }

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({
            "error": "Tech stack name required",
            "usage": f"python3 {sys.argv[0]} \"AI Tech Stack 1\" --json-only"
        }, indent=2))
        sys.exit(1)

    tech_stack_name = sys.argv[1]
    result = get_workflow_data(tech_stack_name)

    # Output JSON
    print(json.dumps(result, indent=2))

    # Exit with error code if there was an error
    if "error" in result:
        sys.exit(1)

    sys.exit(0)

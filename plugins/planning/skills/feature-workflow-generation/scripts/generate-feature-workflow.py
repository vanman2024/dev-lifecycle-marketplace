#!/usr/bin/env python3

"""
generate-feature-workflow.py
Queries Airtable for tech stack commands and matches them to features from features.json
Usage: python3 generate-feature-workflow.py
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

def get_tech_stack_from_project_json():
    """Read tech stack name from .claude/project.json"""
    project_json_path = ".claude/project.json"

    if not os.path.exists(project_json_path):
        return None

    with open(project_json_path, 'r') as f:
        project_data = json.load(f)

    return project_data.get("techStack", {}).get("name")

def get_features_from_features_json():
    """Read features from features.json"""
    features_json_path = "features.json"

    if not os.path.exists(features_json_path):
        return []

    with open(features_json_path, 'r') as f:
        features_data = json.load(f)

    return features_data.get("features", [])

def read_spec_files(features):
    """Read spec.md files for each feature"""
    for feature in features:
        feature_id = feature.get("id")
        spec_path = f"specs/{feature_id}/spec.md"

        if os.path.exists(spec_path):
            with open(spec_path, 'r') as f:
                feature["spec_content"] = f.read()
        else:
            feature["spec_content"] = ""

    return features

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
        "Foundation", "Planning", "Iteration", "Implementation", "Quality", "Testing",
        "Deployment", "Versioning", "Supervision", "Security",
        "Frontend Framework", "Backend Framework", "Database",
        "AI Framework", "Memory Layer", "Payments", "Authentication"
    ]

    plugin_ids = []
    for field in plugin_fields:
        if field in fields and isinstance(fields[field], list):
            plugin_ids.extend(fields[field])

    # Remove duplicates
    return list(set(plugin_ids))

def get_tech_stack_commands(stack_name):
    """Get all commands available for a tech stack"""

    if not AIRTABLE_TOKEN:
        return {
            "error": "AIRTABLE_TOKEN or MCP_AIRTABLE_TOKEN environment variable not set",
            "message": "Export it: export MCP_AIRTABLE_TOKEN=your_token_here"
        }

    # Query tech stack
    tech_stack = get_tech_stack(stack_name)

    if not tech_stack:
        return {
            "error": f"Tech stack not found: {stack_name}"
        }

    # Extract plugin IDs
    plugin_ids = extract_plugin_ids(tech_stack)

    # Query plugins table to get plugin details
    plugins_data = []

    for plugin_id in plugin_ids:
        plugin = get_plugin(plugin_id)
        plugin_name = plugin.get("fields", {}).get("Name")
        plugin_phase = plugin.get("fields", {}).get("Lifecycle Phase", "Other")
        command_ids = plugin.get("fields", {}).get("Commands", [])

        plugin_entry = {
            "name": plugin_name,
            "phase": plugin_phase,
            "command_ids": command_ids,
            "commands": []
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
                    "description": command_fields.get("Description", ""),
                    "plugin": plugin_data["name"],
                    "phase": plugin_data["phase"]
                })

    return {
        "plugins": plugins_data,
        "all_commands": [cmd for plugin in plugins_data for cmd in plugin["commands"]]
    }

def generate_feature_workflow_data():
    """Generate feature workflow data combining features.json + Airtable commands"""

    # Read tech stack from project.json
    tech_stack_name = get_tech_stack_from_project_json()

    if not tech_stack_name:
        return {
            "error": "Tech stack not found in .claude/project.json",
            "message": "Run /foundation:detect first to populate project.json"
        }

    # Read features from features.json
    features = get_features_from_features_json()

    if not features:
        return {
            "error": "No features found in features.json",
            "message": "Run /planning:add-feature first to create features"
        }

    # Read spec files
    features = read_spec_files(features)

    # Get available commands from Airtable
    commands_data = get_tech_stack_commands(tech_stack_name)

    if "error" in commands_data:
        return commands_data

    # Return combined data
    return {
        "tech_stack": tech_stack_name,
        "features": features,
        "available_commands": commands_data["all_commands"],
        "plugins": commands_data["plugins"]
    }

if __name__ == "__main__":
    result = generate_feature_workflow_data()

    # Output JSON
    print(json.dumps(result, indent=2))

    # Exit with error code if there was an error
    if "error" in result:
        sys.exit(1)

    sys.exit(0)

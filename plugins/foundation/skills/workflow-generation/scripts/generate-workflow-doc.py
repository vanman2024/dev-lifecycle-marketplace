#!/usr/bin/env python3

"""
generate-workflow-doc.py
Generates complete workflow document from Airtable using Web API
Usage: python3 generate-workflow-doc.py "AI Tech Stack 1"
"""

import os
import sys
import requests
from datetime import datetime

# Configuration
AIRTABLE_TOKEN = os.getenv("AIRTABLE_TOKEN") or os.getenv("MCP_AIRTABLE_TOKEN")
BASE_ID = "appHbSB7WhT1TxEQb"

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

def generate_workflow(tech_stack_name):
    """Generate complete workflow document"""

    if not AIRTABLE_TOKEN:
        print("❌ Error: AIRTABLE_TOKEN or MCP_AIRTABLE_TOKEN environment variable not set")
        print("   Export it: export MCP_AIRTABLE_TOKEN=your_token_here")
        return 1

    # Output file
    safe_filename = tech_stack_name.lower().replace(" ", "-")
    output_file = f"/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/{safe_filename}-WORKFLOW.md"

    print(f"Generating workflow for: {tech_stack_name}")
    print(f"Output file: {output_file}")

    # Query tech stack
    print("Querying Tech Stacks table...")
    tech_stack = get_tech_stack(tech_stack_name)

    if not tech_stack:
        print(f"❌ Error: Tech stack not found: {tech_stack_name}")
        return 1

    fields = tech_stack.get("fields", {})
    stack_name = fields.get("Stack Name")
    description = fields.get("Description", "")
    use_cases = fields.get("Detailed Use Cases", [])

    # Extract plugin IDs
    plugin_ids = extract_plugin_ids(tech_stack)
    print(f"Found tech stack: {stack_name}")
    print(f"Plugin IDs: {len(plugin_ids)} plugins")

    # Query plugins table to get plugin details
    print("Querying Plugins table...")
    plugins_data = {}

    for plugin_id in plugin_ids:
        plugin = get_plugin(plugin_id)
        plugin_name = plugin.get("fields", {}).get("Name")  # Field is "Name" not "Plugin Name"
        command_ids = plugin.get("fields", {}).get("Commands", [])
        agent_ids = plugin.get("fields", {}).get("Agents", [])
        skill_ids = plugin.get("fields", {}).get("Skills", [])

        plugins_data[plugin_id] = {
            "name": plugin_name,
            "command_ids": command_ids,
            "agent_ids": agent_ids,
            "skill_ids": skill_ids,
            "commands": [],
            "agents": [],
            "skills": []
        }

        print(f"  - {plugin_name}: {len(command_ids)} commands, {len(agent_ids)} agents, {len(skill_ids)} skills")

    # Get ALL command details using batch queries (efficient!)
    print("Fetching ALL command details in batches...")
    all_command_ids = []
    for plugin_data in plugins_data.values():
        all_command_ids.extend(plugin_data["command_ids"])

    # Fetch in batches of 100 (Airtable limit)
    all_commands = {}
    for i in range(0, len(all_command_ids), 100):
        batch_ids = all_command_ids[i:i+100]
        batch_commands = get_commands_batch(batch_ids)
        for cmd in batch_commands:
            all_commands[cmd["id"]] = cmd

    print(f"Fetched {len(all_commands)} total commands")

    # Map commands back to plugins
    for plugin_id, plugin_data in plugins_data.items():
        for command_id in plugin_data["command_ids"]:
            if command_id in all_commands:
                command_fields = all_commands[command_id].get("fields", {})
                plugins_data[plugin_id]["commands"].append({
                    "name": command_fields.get("Command Name", ""),
                    "description": command_fields.get("Description", "")
                })

    # Generate workflow markdown
    print("Generating workflow document...")

    with open(output_file, "w") as f:
        f.write(f"# {stack_name} - Complete Development Workflow\n\n")
        f.write(f"**Auto-generated from Airtable** | Last Updated: {datetime.now().strftime('%Y-%m-%d')}\n\n")

        # Stack Overview
        f.write("## Stack Overview\n\n")
        f.write(f"**Description**: {description}\n\n")

        if use_cases:
            f.write(f"**Use Cases**: {', '.join(use_cases)}\n\n")

        f.write("---\n\n")

        # Prerequisites
        f.write("## Prerequisites\n\n")
        f.write("Before starting, ensure you have:\n")
        f.write("- Node.js 18+ and pnpm installed\n")
        f.write("- Python 3.11+ installed\n")
        f.write("- GitHub account and `gh` CLI installed\n")
        f.write("- Required API keys (see environment setup)\n\n")
        f.write("---\n\n")

        # Group commands by lifecycle phase
        foundation_commands = []
        planning_commands = []
        implementation_commands = []
        quality_commands = []
        deployment_commands = []
        iteration_commands = []
        other_commands = []

        for plugin_data in plugins_data.values():
            plugin_name = plugin_data['name'].lower()

            for command in plugin_data["commands"]:
                cmd_entry = {
                    "plugin": plugin_data['name'],
                    "name": command["name"],
                    "description": command["description"]
                }

                # Categorize by plugin name
                if 'foundation' in plugin_name:
                    foundation_commands.append(cmd_entry)
                elif 'planning' in plugin_name:
                    planning_commands.append(cmd_entry)
                elif 'quality' in plugin_name or 'testing' in plugin_name or 'security' in plugin_name:
                    quality_commands.append(cmd_entry)
                elif 'deployment' in plugin_name or 'deploy' in plugin_name:
                    deployment_commands.append(cmd_entry)
                elif 'iterate' in plugin_name or 'iteration' in plugin_name:
                    iteration_commands.append(cmd_entry)
                else:
                    implementation_commands.append(cmd_entry)

        # Phase 1: Foundation
        f.write("## Phase 1: Foundation & Project Setup\n\n")
        f.write("### 1.1 Project Initialization\n\n")
        f.write("```bash\n")
        f.write("# Create project directory\n")
        f.write("cd ~/Projects\n")
        f.write("mkdir my-ai-app && cd my-ai-app\n\n")

        for cmd in foundation_commands:
            if any(keyword in cmd["name"].lower() for keyword in ["start", "init", "detect", "env-check", "env-vars"]):
                f.write(f"# {cmd['description']}\n")
                f.write(f"/{cmd['plugin']}:{cmd['name']}\n\n")

        f.write("```\n\n")

        f.write("### 1.2 Tech Stack Setup\n\n")
        f.write("Initialize your tech stack components:\n\n")
        f.write("```bash\n")

        for cmd in implementation_commands:
            if "init" in cmd["name"].lower() or "setup" in cmd["name"].lower():
                f.write(f"# {cmd['description']}\n")
                f.write(f"/{cmd['plugin']}:{cmd['name']}\n\n")

        f.write("```\n\n")

        # Phase 2: Planning
        f.write("---\n\n")
        f.write("## Phase 2: Planning & Architecture\n\n")
        f.write("### 2.1 Requirements & Specifications\n\n")
        f.write("```bash\n")

        for cmd in planning_commands:
            if any(keyword in cmd["name"].lower() for keyword in ["wizard", "spec", "roadmap"]):
                f.write(f"# {cmd['description']}\n")
                f.write(f"/{cmd['plugin']}:{cmd['name']}\n\n")

        f.write("```\n\n")

        f.write("### 2.2 Architecture Design\n\n")
        f.write("```bash\n")

        for cmd in planning_commands:
            if any(keyword in cmd["name"].lower() for keyword in ["architecture", "decide"]):
                f.write(f"# {cmd['description']}\n")
                f.write(f"/{cmd['plugin']}:{cmd['name']}\n\n")

        f.write("```\n\n")

        # Phase 3: Implementation
        f.write("---\n\n")
        f.write("## Phase 3: Implementation\n\n")
        f.write("### 3.1 Task Layering\n\n")
        f.write("```bash\n")

        for cmd in iteration_commands:
            if "tasks" in cmd["name"].lower():
                f.write(f"# {cmd['description']}\n")
                f.write(f"/{cmd['plugin']}:{cmd['name']}\n\n")

        f.write("```\n\n")

        f.write("### 3.2 Feature Development\n\n")
        f.write("Build features layer by layer following your layered-tasks.md:\n\n")
        f.write("```bash\n")

        for cmd in implementation_commands:
            if any(keyword in cmd["name"].lower() for keyword in ["add", "integrate", "create"]) and \
               not any(keyword in cmd["name"].lower() for keyword in ["init", "setup"]):
                f.write(f"# {cmd['description']}\n")
                f.write(f"/{cmd['plugin']}:{cmd['name']}\n\n")

        f.write("```\n\n")

        # Phase 4: Quality
        f.write("---\n\n")
        f.write("## Phase 4: Quality & Testing\n\n")
        f.write("### 4.1 Testing & Validation\n\n")
        f.write("```bash\n")

        for cmd in quality_commands:
            f.write(f"# {cmd['description']}\n")
            f.write(f"/{cmd['plugin']}:{cmd['name']}\n\n")

        f.write("```\n\n")

        # Phase 5: Deployment
        f.write("---\n\n")
        f.write("## Phase 5: Deployment\n\n")
        f.write("### 5.1 Deployment Process\n\n")
        f.write("```bash\n")

        for cmd in deployment_commands:
            f.write(f"# {cmd['description']}\n")
            f.write(f"/{cmd['plugin']}:{cmd['name']}\n\n")

        f.write("```\n\n")

        # Phase 6: Iteration
        f.write("---\n\n")
        f.write("## Phase 6: Iteration & Enhancement\n\n")
        f.write("### 6.1 Feature Enhancement & Refactoring\n\n")
        f.write("```bash\n")

        for cmd in iteration_commands:
            if "tasks" not in cmd["name"].lower():  # Already showed tasks earlier
                f.write(f"# {cmd['description']}\n")
                f.write(f"/{cmd['plugin']}:{cmd['name']}\n\n")

        f.write("```\n\n")

        # Complete Command Reference
        f.write("---\n\n")
        f.write("## Complete Command Reference\n\n")

        for plugin_data in plugins_data.values():
            f.write(f"### {plugin_data['name']}\n\n")
            if plugin_data["commands"]:
                for command in plugin_data["commands"]:
                    f.write(f"- `/{plugin_data['name']}:{command['name']}` - {command['description']}\n")
            else:
                f.write("- No commands\n")
            f.write("\n")

        # Critical Rules
        f.write("---\n\n")
        f.write("## Critical Rules\n\n")
        f.write("### 🚨 ALWAYS: Spec → Layer → Build\n\n")
        f.write("**NEVER build features randomly!**\n\n")
        f.write("```bash\n")
        f.write("# ❌ WRONG\n")
        f.write("/nextjs-frontend:add-component Button  # Random creation = technical debt\n\n")
        f.write("# ✅ CORRECT\n")
        f.write("/planning:add-feature \"Improved button system\"\n")
        f.write("/iterate:tasks F001\n")
        f.write("# Build layer by layer following layered-tasks.md\n")
        f.write("```\n\n")
        f.write("---\n\n")

        # Regeneration command
        f.write(f"**This workflow was auto-generated from Airtable on {datetime.now().strftime('%Y-%m-%d')}**\n\n")
        f.write("To regenerate with latest Airtable data:\n")
        f.write("```bash\n")
        f.write(f"/foundation:generate-workflow \"{tech_stack_name}\"\n")
        f.write("```\n")

    print("")
    print("✅ Workflow document generated successfully!")
    print(f"📄 File: {output_file}")
    with open(output_file, "r") as f:
        print(f"📊 Size: {len(f.readlines())} lines")
    print("")
    print(f'View with: cat "{output_file}"')

    return 0

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Error: Tech stack name required")
        print(f"Usage: {sys.argv[0]} \"AI Tech Stack 1\"")
        sys.exit(1)

    tech_stack_name = sys.argv[1]
    sys.exit(generate_workflow(tech_stack_name))

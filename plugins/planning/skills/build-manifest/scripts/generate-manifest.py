#!/usr/bin/env python3
"""
Generate BUILD-GUIDE.json and BUILD-GUIDE.md from Airtable plugin index

This script:
1. Reads architecture docs to detect tech stack
2. Queries Airtable for plugins matching detected technologies
3. Queries Airtable for commands in those plugins
4. Organizes commands into layers
5. Detects gaps (tech mentioned but no plugin exists)
6. Generates both .json and .md files

Usage:
    python generate-manifest.py --architecture docs/architecture/README.md --output BUILD-GUIDE
"""

import os
import sys
import json
import argparse
from datetime import datetime
from pathlib import Path
from pyairtable import Api

# Airtable configuration
AIRTABLE_TOKEN = os.getenv("AIRTABLE_TOKEN")
if not AIRTABLE_TOKEN:
    print("❌ ERROR: AIRTABLE_TOKEN environment variable not set")
    print("   Export it: export AIRTABLE_TOKEN=your_airtable_token_here")
    sys.exit(1)

BASE_ID = "appHbSB7WhT1TxEQb"

# Initialize Airtable API
api = Api(AIRTABLE_TOKEN)


def read_architecture_docs(arch_path):
    """Extract tech stack from architecture documentation"""
    import os

    print(f"📖 Reading architecture docs: {arch_path}")

    tech_stack = []
    content = ""

    # Check if path is a directory or file
    if os.path.isdir(arch_path):
        # Walk through directory and read all .md files
        print(f"   📂 Scanning directory for markdown files...")
        for root, dirs, files in os.walk(arch_path):
            for file in files:
                if file.endswith('.md'):
                    file_path = os.path.join(root, file)
                    print(f"      📄 Reading: {file}")
                    with open(file_path, 'r') as f:
                        content += f.read() + "\n"
    else:
        # Read single file
        with open(arch_path, 'r') as f:
            content = f.read()

    # Simple tech detection (can be enhanced with better parsing)
    tech_keywords = {
        "Next.js": "nextjs-frontend",
        "FastAPI": "fastapi-backend",
        "Supabase": "supabase",
        "Vercel AI SDK": "vercel-ai-sdk",
        "OpenRouter": "openrouter",
        "Mem0": "mem0",
        "Redis": "redis",
        "PostgreSQL": "supabase",
        "MongoDB": "mongodb"
    }

    for keyword, plugin in tech_keywords.items():
        if keyword in content:
            if plugin not in tech_stack:
                tech_stack.append(plugin)

    print(f"   ✓ Detected technologies: {', '.join(tech_stack)}")
    return tech_stack


def query_plugins_for_tech(tech_stack):
    """Query Airtable for plugins matching detected tech stack"""
    print(f"\n🔍 Querying Airtable for plugins...")

    plugins_table = api.table(BASE_ID, "Plugins")
    matched_plugins = {}

    # ALWAYS include dev-lifecycle-marketplace core plugins
    core_plugins = ["foundation", "planning", "supervisor", "iterate", "quality", "deployment", "versioning"]

    print(f"   📦 Adding core dev-lifecycle plugins...")
    for core_plugin in core_plugins:
        formula = f"LOWER({{Name}})='{core_plugin}'"
        records = plugins_table.all(formula=formula)
        if records:
            for record in records:
                plugin_name = record['fields'].get('Name')
                matched_plugins[plugin_name] = record['id']
                print(f"   ✓ Found core plugin: {plugin_name}")

    # Query for detected tech stack plugins
    print(f"   📦 Adding detected tech stack plugins...")
    for tech in tech_stack:
        # Query for plugin by name (fuzzy match)
        formula = f"FIND('{tech}', LOWER({{Name}}))"
        records = plugins_table.all(formula=formula)

        if records:
            for record in records:
                plugin_name = record['fields'].get('Name')
                if plugin_name not in matched_plugins:  # Avoid duplicates
                    matched_plugins[plugin_name] = record['id']
                    print(f"   ✓ Found tech plugin: {plugin_name}")
        else:
            print(f"   ⚠️  No plugin found for: {tech}")

    return matched_plugins


def query_commands_for_plugins(plugin_ids):
    """Query Airtable for all commands in matched plugins"""
    print(f"\n📋 Querying commands for plugins...")

    commands_table = api.table(BASE_ID, "Commands")

    # Fetch all commands at once (more efficient than per-plugin queries)
    all_records = commands_table.all()

    # Group commands by plugin
    all_commands = {plugin_name: [] for plugin_name in plugin_ids.keys()}

    for record in all_records:
        # Get the linked plugin IDs (array of record IDs)
        plugin_links = record['fields'].get('Plugin', [])

        # Check if this command belongs to any of our target plugins
        for plugin_name, plugin_id in plugin_ids.items():
            if plugin_id in plugin_links:
                cmd = {
                    "command": record['fields'].get('Command Name'),
                    "plugin": plugin_name,
                    "description": record['fields'].get('Description'),
                    "airtableId": record['id'],
                    "available": True
                }
                all_commands[plugin_name].append(cmd)

    # Print summary
    for plugin_name in plugin_ids.keys():
        count = len(all_commands[plugin_name])
        print(f"   ✓ {plugin_name}: {count} commands")

    return all_commands


def detect_gaps(detected_tech, matched_plugins):
    """Detect technologies mentioned in arch docs but no plugin exists"""
    print(f"\n🔎 Detecting gaps...")

    gaps = []
    for tech in detected_tech:
        # Check if any plugin name contains this tech
        found = any(tech.lower() in plugin.lower() for plugin in matched_plugins.keys())
        if not found:
            gaps.append({
                "technology": tech,
                "reason": f"No {tech} plugin found in any marketplace",
                "suggestion": f"Create {tech} plugin with /domain-plugin-builder:build-plugin {tech}"
            })
            print(f"   ⚠️  Gap detected: {tech}")

    return gaps


def organize_into_layers(all_commands):
    """Organize commands into execution layers"""
    print(f"\n📊 Organizing commands into layers...")

    layers = {
        "layer1": {
            "name": "Infrastructure Foundation",
            "plugins": ["foundation", "planning", "supervisor"],
            "commands": []
        },
        "layer2": {
            "name": "Tech Stack Initialization",
            "plugins": [],
            "commands": []
        },
        "layer3": {
            "name": "Feature Implementation",
            "plugins": [],
            "commands": []
        },
        "layer4": {
            "name": "Quality & Deployment",
            "plugins": ["quality", "deployment", "versioning"],
            "commands": []
        }
    }

    # Layer 1: Foundation, planning, supervisor commands
    for plugin in ["foundation", "planning", "supervisor", "iterate"]:
        if plugin in all_commands:
            for cmd in all_commands[plugin]:
                layers["layer1"]["commands"].append(cmd)

    # Layer 2: Init commands from tech stack plugins
    for plugin, commands in all_commands.items():
        if plugin not in ["foundation", "planning", "supervisor", "iterate", "quality", "deployment", "versioning"]:
            for cmd in commands:
                if ':init' in cmd['command']:
                    if plugin not in layers["layer2"]["plugins"]:
                        layers["layer2"]["plugins"].append(plugin)
                    layers["layer2"]["commands"].append(cmd)

    # Layer 3: All other tech stack commands (non-init, non-lifecycle)
    for plugin, commands in all_commands.items():
        if plugin not in ["foundation", "planning", "supervisor", "iterate", "quality", "deployment", "versioning"]:
            for cmd in commands:
                if ':init' not in cmd['command']:
                    if plugin not in layers["layer3"]["plugins"]:
                        layers["layer3"]["plugins"].append(plugin)
                    layers["layer3"]["commands"].append(cmd)

    # Layer 4: Quality, deployment, versioning commands
    for plugin in ["quality", "deployment", "versioning"]:
        if plugin in all_commands:
            for cmd in all_commands[plugin]:
                layers["layer4"]["commands"].append(cmd)

    print(f"   ✓ Layer 1: {len(layers['layer1']['commands'])} commands")
    print(f"   ✓ Layer 2: {len(layers['layer2']['commands'])} commands")
    print(f"   ✓ Layer 3: {len(layers['layer3']['commands'])} commands")
    print(f"   ✓ Layer 4: {len(layers['layer4']['commands'])} commands")

    return layers


def generate_json(project_name, tech_stack, layers, gaps, output_path):
    """Generate BUILD-GUIDE.json"""
    print(f"\n📝 Generating BUILD-GUIDE.json...")

    manifest = {
        "project": project_name,
        "generated": datetime.utcnow().isoformat() + "Z",
        "techStack": {
            "detected": tech_stack,
            "source": "docs/architecture/README.md",
            "marketplaces": [
                "dev-lifecycle-marketplace",
                "ai-dev-marketplace",
                "mcp-servers-marketplace"
            ]
        },
        "buildLayers": [
            {
                "layer": 1,
                "name": layers["layer1"]["name"],
                "plugins": layers["layer1"]["plugins"],
                "commands": layers["layer1"]["commands"],
                "executionOrder": "sequential"
            },
            {
                "layer": 2,
                "name": layers["layer2"]["name"],
                "plugins": layers["layer2"]["plugins"],
                "commands": layers["layer2"]["commands"],
                "executionOrder": "parallel",
                "gaps": gaps
            },
            {
                "layer": 3,
                "name": layers["layer3"]["name"],
                "plugins": layers["layer3"]["plugins"],
                "commands": layers["layer3"]["commands"],
                "executionOrder": "spec-driven"
            },
            {
                "layer": 4,
                "name": layers["layer4"]["name"],
                "plugins": layers["layer4"]["plugins"],
                "commands": layers["layer4"]["commands"],
                "executionOrder": "sequential"
            }
        ],
        "gaps": gaps,
        "metadata": {
            "totalCommands": sum(len(layer["commands"]) for layer in layers.values()),
            "totalPlugins": len(set(sum([layer["plugins"] for layer in layers.values()], []))),
            "missingPlugins": len(gaps),
            "airtableBaseId": BASE_ID,
            "generatedBy": "build-manifest-generator agent"
        }
    }

    json_path = f"{output_path}.json"
    with open(json_path, 'w') as f:
        json.dump(manifest, f, indent=2)

    print(f"   ✓ Created: {json_path}")
    return manifest


def generate_markdown(manifest, output_path):
    """Generate BUILD-GUIDE.md"""
    print(f"\n📝 Generating BUILD-GUIDE.md...")

    # Generate markdown from manifest (simplified version)
    md_content = f"""# Build Command Reference

**Project**: {manifest['project']}
**Generated**: {manifest['generated']}
**Source**: Architecture detected from `{manifest['techStack']['source']}`

## Tech Stack

{chr(10).join(f"- {tech}" for tech in manifest['techStack']['detected'])}

## Build Layers

{chr(10).join(_format_layer(layer) for layer in manifest['buildLayers'])}

## Summary

**Total Commands**: {manifest['metadata']['totalCommands']}
**Total Plugins**: {manifest['metadata']['totalPlugins']}
**Missing Plugins**: {manifest['metadata']['missingPlugins']}
"""

    md_path = f"{output_path}.md"
    with open(md_path, 'w') as f:
        f.write(md_content)

    print(f"   ✓ Created: {md_path}")


def _format_layer(layer):
    """Helper to format a layer for markdown"""
    return f"""
### Layer {layer['layer']}: {layer['name']}

**Plugins**: {', '.join(layer['plugins'])}
**Commands**: {len(layer['commands'])} available

```bash
{chr(10).join(cmd['command'] + f"  # {cmd.get('description', '')}" for cmd in layer['commands'][:5])}
```
"""


def main():
    parser = argparse.ArgumentParser(description='Generate BUILD-GUIDE from Airtable')
    parser.add_argument('--architecture', required=True, help='Path to architecture docs')
    parser.add_argument('--output', default='BUILD-GUIDE', help='Output file prefix')
    parser.add_argument('--project', default='my-project', help='Project name')

    args = parser.parse_args()

    print("="*80)
    print("🏗️  BUILD-GUIDE Generator")
    print("="*80)

    # Step 1: Read architecture docs
    tech_stack = read_architecture_docs(args.architecture)

    # Step 2: Query Airtable for plugins
    matched_plugins = query_plugins_for_tech(tech_stack)

    # Step 3: Query commands for matched plugins
    all_commands = query_commands_for_plugins(matched_plugins)

    # Step 4: Detect gaps
    gaps = detect_gaps(tech_stack, matched_plugins)

    # Step 5: Organize into layers
    layers = organize_into_layers(all_commands)

    # Step 6: Generate JSON
    manifest = generate_json(args.project, tech_stack, layers, gaps, args.output)

    # Step 7: Generate Markdown
    generate_markdown(manifest, args.output)

    print("\n" + "="*80)
    print("✅ BUILD-GUIDE generation complete!")
    print("="*80)
    print(f"   JSON: {args.output}.json")
    print(f"   Markdown: {args.output}.md")


if __name__ == "__main__":
    main()

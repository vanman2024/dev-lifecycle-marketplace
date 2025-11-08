#!/usr/bin/env python3
"""
Comprehensive Agent Audit Script

Scans all agent files to extract:
- Slash commands used
- Skills invoked
- MCP servers used

Compares with Airtable and generates a detailed report.
Does NOT modify Airtable - just reports findings.
"""

import os
import re
from pathlib import Path
from pyairtable import Api

# Airtable configuration
AIRTABLE_API_KEY = os.getenv("AIRTABLE_API_KEY", "pat6Wdcb4Uj6AtcFr.60698f69f01ab1e1a13d50558fdf7edbe80201d7279cde9531ed816984779ce9")
BASE_ID = "appHbSB7WhT1TxEQb"

# Initialize Airtable API
api = Api(AIRTABLE_API_KEY)
base = api.base(BASE_ID)
agents_table = base.table("Agents")
commands_table = base.table("Commands")
skills_table = base.table("Skills")

MARKETPLACES = {
    "dev-lifecycle": "/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace",
    "ai-dev": "/home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace",
    "mcp-servers": "/home/gotime2022/.claude/plugins/marketplaces/mcp-servers-marketplace",
    "domain-plugin-builder": "/home/gotime2022/.claude/plugins/marketplaces/domain-plugin-builder",
}

def scan_agent_file(file_path):
    """Scan agent file for slash commands, skills, and MCP servers"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        return None

    # Extract slash commands
    # Pattern 1: /plugin:command or /command
    slash_commands = set()
    for match in re.finditer(r'/([a-z0-9-]+(?::[a-z0-9-]+)?)', content):
        cmd = match.group(1)
        # Filter out common false positives
        if not any(x in cmd for x in ['http', 'https', 'path', 'home', 'usr', 'bin']):
            slash_commands.add(cmd)

    # Pattern 2: SlashCommand() references
    for match in re.finditer(r'SlashCommand\(["\']([^"\']+)["\']', content):
        slash_commands.add(match.group(1))

    # Extract skills
    # Pattern: Skill('skill-name') or @skill-name
    skills = set()
    for match in re.finditer(r'Skill\(["\']([^"\']+)["\']', content):
        skills.add(match.group(1))

    # Extract MCP servers
    # Pattern: mcp__server_name__tool
    mcp_servers = set()
    for match in re.finditer(r'mcp__([a-z0-9_-]+)__', content):
        server = match.group(1).replace('_', '-')
        mcp_servers.add(server)

    # Check for section markers
    has_slash_section = bool(re.search(r'(?:Slash Commands|Available Commands|Commands to Use)', content, re.IGNORECASE))
    has_mcp_section = bool(re.search(r'(?:MCP (?:Servers?|Tools)|Available MCP)', content, re.IGNORECASE))
    has_skills_section = bool(re.search(r'(?:Skills|Available Skills)', content, re.IGNORECASE))

    return {
        'slash_commands': slash_commands,
        'skills': skills,
        'mcp_servers': mcp_servers,
        'has_slash_section': has_slash_section,
        'has_mcp_section': has_mcp_section,
        'has_skills_section': has_skills_section,
    }

def main():
    print("🔍 COMPREHENSIVE AGENT AUDIT")
    print("=" * 80)

    # Get all agents from Airtable
    print("\n📊 Loading Airtable data...")
    agents = agents_table.all()
    commands = {c['fields'].get('Command Name'): c['id'] for c in commands_table.all()}
    skills_data = {s['fields'].get('Skill Name'): s['id'] for s in skills_table.all()}

    print(f"  ✓ Loaded {len(agents)} agents")
    print(f"  ✓ Loaded {len(commands)} commands")
    print(f"  ✓ Loaded {len(skills_data)} skills")

    # Scan all agent files
    print("\n🔎 Scanning agent files...")
    findings = []

    for agent in agents:
        agent_name = agent['fields'].get('Agent Name')
        file_path = agent['fields'].get('File Path')

        if not file_path:
            continue

        # Find marketplace path
        marketplace_path = None
        for mp_name, mp_path in MARKETPLACES.items():
            full_path = Path(mp_path) / file_path
            if full_path.exists():
                marketplace_path = full_path
                break

        if not marketplace_path:
            continue

        # Scan file
        scan_result = scan_agent_file(marketplace_path)
        if not scan_result:
            continue

        # Compare with Airtable
        airtable_has_slash = agent['fields'].get('Has Slash Commands Section', False)
        airtable_has_mcp = agent['fields'].get('Has MCP Section', False)
        airtable_has_skills = agent['fields'].get('Has Skills Section', False)
        airtable_uses_commands = agent['fields'].get('Uses Commands', [])
        airtable_skills = agent['fields'].get('Skills', [])
        airtable_mcp = agent['fields'].get('MCP Servers Linked', [])

        # Find discrepancies
        discrepancies = []

        # Check section flags
        if scan_result['has_slash_section'] != airtable_has_slash:
            discrepancies.append(f"Has Slash Commands Section: File={scan_result['has_slash_section']}, Airtable={airtable_has_slash}")

        if scan_result['has_mcp_section'] != airtable_has_mcp:
            discrepancies.append(f"Has MCP Section: File={scan_result['has_mcp_section']}, Airtable={airtable_has_mcp}")

        if scan_result['has_skills_section'] != airtable_has_skills:
            discrepancies.append(f"Has Skills Section: File={scan_result['has_skills_section']}, Airtable={airtable_has_skills}")

        # Check slash commands
        found_commands = scan_result['slash_commands']
        if found_commands:
            linked_count = len(airtable_uses_commands)
            if linked_count < len(found_commands):
                discrepancies.append(f"Slash Commands: Found {len(found_commands)} in file, only {linked_count} linked in Airtable")
                discrepancies.append(f"  Found: {', '.join(sorted(found_commands))}")

        # Check skills
        found_skills = scan_result['skills']
        if found_skills:
            linked_count = len(airtable_skills)
            if linked_count < len(found_skills):
                discrepancies.append(f"Skills: Found {len(found_skills)} in file, only {linked_count} linked in Airtable")
                discrepancies.append(f"  Found: {', '.join(sorted(found_skills))}")

        # Check MCP servers
        found_mcp = scan_result['mcp_servers']
        if found_mcp:
            linked_count = len(airtable_mcp)
            if linked_count < len(found_mcp):
                discrepancies.append(f"MCP Servers: Found {len(found_mcp)} in file, only {linked_count} linked in Airtable")
                discrepancies.append(f"  Found: {', '.join(sorted(found_mcp))}")

        if discrepancies:
            findings.append({
                'agent': agent_name,
                'discrepancies': discrepancies,
                'file_path': file_path,
                'scan_result': scan_result
            })

    # Generate report
    print("\n" + "=" * 80)
    print("📋 AUDIT REPORT")
    print("=" * 80)

    if not findings:
        print("\n✅ All agents are up-to-date!")
    else:
        print(f"\n⚠️  Found {len(findings)} agents with discrepancies:\n")

        for i, finding in enumerate(findings, 1):
            print(f"{i}. {finding['agent']}")
            print(f"   File: {finding['file_path']}")
            for disc in finding['discrepancies']:
                print(f"   • {disc}")
            print()

    # Summary statistics
    print("\n" + "=" * 80)
    print("📊 SUMMARY STATISTICS")
    print("=" * 80)

    total_agents = len(agents)
    agents_with_issues = len(findings)

    print(f"\nTotal Agents: {total_agents}")
    print(f"Agents with Discrepancies: {agents_with_issues} ({agents_with_issues/total_agents*100:.1f}%)")
    print(f"Agents Up-to-Date: {total_agents - agents_with_issues} ({(total_agents-agents_with_issues)/total_agents*100:.1f}%)")

    # Breakdown by issue type
    section_issues = sum(1 for f in findings if any('Section' in d for d in f['discrepancies']))
    command_issues = sum(1 for f in findings if any('Slash Commands' in d for d in f['discrepancies']))
    skill_issues = sum(1 for f in findings if any('Skills:' in d for d in f['discrepancies']))
    mcp_issues = sum(1 for f in findings if any('MCP Servers' in d for d in f['discrepancies']))

    print(f"\nIssue Breakdown:")
    print(f"  Section Flags Incorrect: {section_issues}")
    print(f"  Missing Command Links: {command_issues}")
    print(f"  Missing Skill Links: {skill_issues}")
    print(f"  Missing MCP Server Links: {mcp_issues}")

    print("\n" + "=" * 80)
    print("\n💡 Next Steps:")
    print("  1. Review the discrepancies above")
    print("  2. Run update script to fix Airtable (if you want to auto-fix)")
    print("  3. Or manually update specific agents in Airtable")
    print("\n" + "=" * 80)

if __name__ == "__main__":
    main()

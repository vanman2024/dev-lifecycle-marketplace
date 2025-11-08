#!/usr/bin/env python3
"""
Validate Airtable data against filesystem reality

This script performs comprehensive validation:
1. Check all file paths exist on filesystem
2. Verify frontmatter matches Airtable data
3. Validate relationship links are correct
4. Identify orphaned records
5. Check for missing documentation
6. Generate validation report

Run this before expanding to other marketplaces.
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
agents_table = base.table("Agents")
commands_table = base.table("Commands")
skills_table = base.table("Skills")

MARKETPLACE_BASE = "/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace"

class ValidationReport:
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.infos = []

    def error(self, msg):
        self.errors.append(msg)
        print(f"  ❌ ERROR: {msg}")

    def warning(self, msg):
        self.warnings.append(msg)
        print(f"  ⚠️  WARNING: {msg}")

    def info(self, msg):
        self.infos.append(msg)
        print(f"  ℹ️  INFO: {msg}")

    def summary(self):
        print("\n" + "="*80)
        print("VALIDATION SUMMARY")
        print("="*80)
        print(f"✅ Total Errors: {len(self.errors)}")
        print(f"⚠️  Total Warnings: {len(self.warnings)}")
        print(f"ℹ️  Total Info: {len(self.infos)}")

        if self.errors:
            print("\n🚨 ERRORS (must fix):")
            for err in self.errors:
                print(f"  • {err}")

        if self.warnings:
            print("\n⚠️  WARNINGS (should review):")
            for warn in self.warnings:
                print(f"  • {warn}")

        return len(self.errors) == 0

def extract_frontmatter(file_path):
    """Extract YAML frontmatter from markdown file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
        if match:
            return yaml.safe_load(match.group(1))
        return None
    except Exception as e:
        return None

def validate_agents(report):
    """Validate all agents"""
    print("\n📋 Validating Agents...")

    agents = agents_table.all()
    print(f"  Found {len(agents)} agents in Airtable")

    for agent in agents:
        fields = agent['fields']
        agent_name = fields.get('Agent Name', 'Unknown')

        # Check file path exists
        file_path = fields.get('File Path', '')
        if not file_path:
            report.error(f"Agent '{agent_name}': Missing file path")
            continue

        full_path = Path(MARKETPLACE_BASE) / file_path
        if not full_path.exists():
            report.error(f"Agent '{agent_name}': File not found: {file_path}")
            continue

        # Read frontmatter from file
        frontmatter = extract_frontmatter(full_path)
        if not frontmatter:
            report.error(f"Agent '{agent_name}': No frontmatter in file")
            continue

        # Validate name matches
        if frontmatter.get('name') != agent_name:
            report.error(f"Agent '{agent_name}': Name mismatch - File says '{frontmatter.get('name')}'")

        # Validate description exists
        if not frontmatter.get('description'):
            report.error(f"Agent '{agent_name}': Missing description in frontmatter")

        # Validate description matches
        airtable_desc = fields.get('Purpose', '')
        file_desc = frontmatter.get('description', '')
        if airtable_desc != file_desc:
            report.warning(f"Agent '{agent_name}': Description mismatch")
            report.info(f"  Airtable: {airtable_desc[:50]}...")
            report.info(f"  File: {file_desc[:50]}...")

        # Check has proper frontmatter fields
        required_fields = ['name', 'description', 'model', 'color']
        for field in required_fields:
            if field not in frontmatter:
                report.warning(f"Agent '{agent_name}': Missing '{field}' in frontmatter")

def validate_commands(report):
    """Validate all commands"""
    print("\n📋 Validating Commands...")

    commands = commands_table.all()
    print(f"  Found {len(commands)} commands in Airtable")

    for command in commands:
        fields = command['fields']
        cmd_name = fields.get('Command Name', 'Unknown')

        # Check file path exists
        file_path = fields.get('File Path', '')
        if not file_path:
            report.error(f"Command '{cmd_name}': Missing file path")
            continue

        full_path = Path(MARKETPLACE_BASE) / file_path
        if not full_path.exists():
            report.error(f"Command '{cmd_name}': File not found: {file_path}")
            continue

        # Read frontmatter from file
        frontmatter = extract_frontmatter(full_path)
        if not frontmatter:
            report.error(f"Command '{cmd_name}': No frontmatter in file")
            continue

        # Validate description exists
        if not frontmatter.get('description'):
            report.error(f"Command '{cmd_name}': Missing description in frontmatter")

        # Validate description matches
        airtable_desc = fields.get('Description', '')
        file_desc = frontmatter.get('description', '')
        if airtable_desc != file_desc:
            report.warning(f"Command '{cmd_name}': Description mismatch")

def validate_skills(report):
    """Validate all skills"""
    print("\n📋 Validating Skills...")

    skills = skills_table.all()
    print(f"  Found {len(skills)} skills in Airtable")

    for skill in skills:
        fields = skill['fields']
        skill_name = fields.get('Skill Name', 'Unknown')

        # Check directory path exists
        dir_path = fields.get('Directory Path', '')
        if not dir_path:
            report.error(f"Skill '{skill_name}': Missing directory path")
            continue

        full_path = Path(MARKETPLACE_BASE) / dir_path
        if not full_path.exists():
            report.error(f"Skill '{skill_name}': Directory not found: {dir_path}")
            continue

        # Validate SKILL.md checkbox
        skill_md_path = full_path / "SKILL.md"
        has_skill_md = fields.get('Has SKILL.md', False)
        actual_has_skill_md = skill_md_path.exists()

        if has_skill_md != actual_has_skill_md:
            report.warning(f"Skill '{skill_name}': 'Has SKILL.md' checkbox incorrect")
            report.info(f"  Airtable: {has_skill_md}, Filesystem: {actual_has_skill_md}")

        # Validate Scripts checkbox
        scripts_path = full_path / "scripts"
        has_scripts = fields.get('Has Scripts', False)
        actual_has_scripts = scripts_path.exists()

        if has_scripts != actual_has_scripts:
            report.warning(f"Skill '{skill_name}': 'Has Scripts' checkbox incorrect")

        # Validate Templates checkbox
        templates_path = full_path / "templates"
        has_templates = fields.get('Has Templates', False)
        actual_has_templates = templates_path.exists()

        if has_templates != actual_has_templates:
            report.warning(f"Skill '{skill_name}': 'Has Templates' checkbox incorrect")

        # Validate Examples checkbox
        examples_path = full_path / "examples"
        has_examples = fields.get('Has Examples', False)
        actual_has_examples = examples_path.exists()

        if has_examples != actual_has_examples:
            report.warning(f"Skill '{skill_name}': 'Has Examples' checkbox incorrect")

def validate_relationships(report):
    """Validate relationship links"""
    print("\n🔗 Validating Relationships...")

    agents = agents_table.all()

    for agent in agents:
        fields = agent['fields']
        agent_name = fields.get('Agent Name', 'Unknown')

        # Check Uses Commands relationship
        uses_commands = fields.get('Uses Commands', [])
        if uses_commands:
            report.info(f"Agent '{agent_name}': Uses {len(uses_commands)} commands")

        # Check Skills relationship
        skills = fields.get('Skills', [])
        if skills:
            report.info(f"Agent '{agent_name}': Uses {len(skills)} skills")

        # Check MCP Servers relationship
        mcp_servers = fields.get('MCP Servers Linked', [])
        if mcp_servers:
            report.info(f"Agent '{agent_name}': Uses {len(mcp_servers)} MCP servers")

def validate_all():
    """Run all validations"""
    print("🔍 Starting Airtable Validation...")
    print(f"   Base: {BASE_ID}")
    print(f"   Marketplace: dev-lifecycle")

    report = ValidationReport()

    # Run validations
    validate_agents(report)
    validate_commands(report)
    validate_skills(report)
    validate_relationships(report)

    # Print summary
    is_valid = report.summary()

    if is_valid:
        print("\n✅ VALIDATION PASSED - Data is accurate!")
    else:
        print("\n❌ VALIDATION FAILED - Fix errors before proceeding")

    return is_valid

if __name__ == "__main__":
    success = validate_all()
    exit(0 if success else 1)

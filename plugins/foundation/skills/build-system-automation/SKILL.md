# Build System Automation Skill

## Purpose

Provides scripts and templates for automated build system management, command registration, and plugin maintenance. These are battle-tested scripts that automate repetitive infrastructure tasks.

## When to Use

- **Command Registration**: Automatically register all commands in settings.json
- **Command Discovery**: Build registries of available commands with descriptions
- **Plugin Maintenance**: Scan and validate plugin structures
- **Build System Setup**: Initialize build automation for new projects

## Core Scripts

### 1. register-all-commands.sh

**Purpose**: Register all active commands in `~/.claude/settings.json`

**What it does**:
- Scans all marketplaces for command files
- Excludes archived, test, and template directories
- Rebuilds permissions.allow array with ALL commands
- Preserves hooks, enabledPlugins, alwaysThinkingEnabled sections
- Creates timestamped backups before modification

**Usage**:
```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/build-system-automation/scripts/register-all-commands.sh
```

**Expected Output**:
```
🔍 Registering all active commands in /home/user/.claude/settings.json
📦 Creating backup: /home/user/.claude/settings.json.backup.20251105-230619
🔎 Scanning for active commands...
📊 Found 218 active commands
📊 Currently registered: 173 commands

➕ Missing commands (first 20):
/claude-agent-sdk:add-cost-tracking
...

✅ Registration complete!
📊 Now registered: 219 commands
```

**When to run**:
- After creating new commands with domain-plugin-builder
- After installing new plugins
- After updating plugin marketplaces
- If slash commands aren't showing up in autocomplete

### 2. build-command-registry.sh

**Purpose**: Build comprehensive JSON registry of all commands with descriptions

**What it does**:
- Scans all command files
- Extracts descriptions from frontmatter
- Generates `/tmp/command-registry.json` with metadata
- Provides statistics by marketplace and plugin

**Usage**:
```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/build-system-automation/scripts/build-command-registry.sh
```

**Output Format** (`/tmp/command-registry.json`):
```json
{
  "commands": {
    "/foundation:github-init": {
      "description": "Complete GitHub repository initialization with gh CLI",
      "plugin": "foundation",
      "marketplace": "dev-lifecycle-marketplace",
      "file": "/path/to/commands/github-init.md"
    }
  }
}
```

**When to run**:
- Before generating documentation
- For command discovery analysis
- When creating BUILD-GUIDE templates
- For plugin auditing

## Integration with BUILD-GUIDE

These scripts are essential for BUILD-GUIDE template creation:

1. **Command Discovery**: `build-command-registry.sh` generates complete command list
2. **Template Generation**: Parse registry to group commands by phase
3. **Validation**: Ensure all referenced commands exist and are registered

## Exclusion Patterns

Both scripts exclude:
- `.archive/` - Old archived commands (v1.x numbered plugins)
- `/archived/` - Plugin-specific archives
- `dev-lifecycle-test-agent-001/` - Test marketplace duplicates
- `/templates/` - Template files in domain-plugin-builder
- `/docs/frameworks/` - Documentation examples

## Maintenance Notes

### Adding New Exclusions

If you create new test marketplaces or archive patterns, update the grep pattern in both scripts:

```bash
grep -v -E '(\.archive|/archived/|dev-lifecycle-test-agent-001|/templates/|/docs/frameworks/|YOUR_NEW_PATTERN)'
```

### Verifying Command Count

Expected counts (as of 2025-01-05):
- **218 active commands** across all marketplaces
- **62 archived** (.archive directories)
- **74 test marketplace** (dev-lifecycle-test-agent-001)
- **1 template** (domain-plugin-builder templates)

To verify current count:
```bash
find ~/.claude/plugins/marketplaces -path "*/commands/*.md" -type f 2>/dev/null | \
  grep -v -E '(\.archive|/archived/|dev-lifecycle-test-agent-001|/templates/|/docs/frameworks/)' | \
  wc -l
```

## Troubleshooting

### Commands Not Appearing After Registration

1. Restart Claude Code editor/terminal
2. Check settings.json is valid JSON: `jq -e . ~/.claude/settings.json`
3. Verify command count: `grep -c 'SlashCommand' ~/.claude/settings.json`
4. Check backup files: `ls -lh ~/.claude/settings.json.backup.*`

### Script Hangs or Fails

1. Check for permission errors: `ls -la ~/.claude/settings.json`
2. Verify temp directory accessible: `ls -la /tmp/`
3. Run with debug: `bash -x script.sh`
4. Check for malformed command files (missing frontmatter)

## Related Skills

- **foundation:project-detection** - Tech stack detection patterns
- **foundation:mcp-configuration** - MCP server config management
- **planning:spec-management** - Spec file organization

## Future Enhancements

- [ ] Auto-run registration after domain-plugin-builder creates commands
- [ ] Generate BUILD-GUIDE templates from command registry
- [ ] Validate command descriptions follow standards
- [ ] Create command usage analytics
- [ ] Build command dependency graphs

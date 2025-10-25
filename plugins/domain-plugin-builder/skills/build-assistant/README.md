
## Build Scripts

The skill includes helper scripts for creating plugin and skill structures:

### create-plugin-structure.py
Creates the mechanical directory structure for a new Claude Code plugin with manifest.

**Usage:**
```bash
python .claude/skills/build-assistant/scripts/create-plugin-structure.py <plugin-name>
```

**Creates:**
- `.claude-plugin/plugin.json` - Plugin manifest
- `commands/`, `skills/`, `agents/`, `hooks/` directories
- Basic README.md

### create-skill-structures.py
Creates skill directory structures for existing plugins.

**Usage:**
```bash
python .claude/skills/build-assistant/scripts/create-skill-structures.py [--dry-run]
```

**What it does:**
- Scans marketplace plugins
- Creates `skills/<skill-name>/` directories
- Sets up proper structure for SKILL.md

### Validation Scripts

- `validate-agent.sh` - Validates agent frontmatter and structure
- `validate-command.sh` - Validates slash command format
- `validate-skill.sh` - Validates SKILL.md structure
- `validate-plugin.sh` - Validates plugin manifest and directories
- `test-build-system.sh` - Comprehensive build system tests

## Template Structure

All templates follow standardized patterns:

```
templates/
├── agents/
│   ├── agent.md.template          # Agent template
│   └── agent-example.md           # Example agent
├── commands/
│   ├── command.md.template        # Command template
│   └── command-example.md         # Example command
├── skills/
│   ├── SKILL.md.template          # Skill template
│   └── skill-example/SKILL.md     # Example skill
└── plugins/
    ├── plugin.json.template       # Plugin manifest template
    └── example-plugin/            # Complete plugin example
```

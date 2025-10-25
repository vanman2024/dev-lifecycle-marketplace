# Bashrc Management Skill

**Plugin**: 01-core
**Skill**: bashrc-management

## Overview

Comprehensive tools for analyzing and organizing your `.bashrc` file to remove duplicates, dead code, and improve organization.

## Features

### 1. Analysis (`bashrc-analyze.sh`)
Detects issues in your `.bashrc`:
- ✅ Duplicate PATH entries
- ✅ Duplicate environment variable exports
- ✅ Duplicate aliases
- ✅ Multiple tool loadings (NVM, etc.)
- ✅ Dead/commented code
- ✅ Organization problems

### 2. Organization (`bashrc-organize.sh`)
Reorganizes `.bashrc` into clean sections:
1. **System Defaults** - Ubuntu/Debian defaults (preserved)
2. **Environment Variables** - All exports deduplicated
3. **PATH Configuration** - Consolidated, no duplicates
4. **Aliases** - All aliases together, deduplicated
5. **Functions** - WSL helpers, screenshot tools, trash functions
6. **Tool Loaders** - NVM, Google Cloud SDK, MCP servers
7. **Application Secrets** - .env file loaders

## Usage

### Via Slash Commands

```bash
# Analyze your .bashrc for issues
/01-core:bashrc-analyze

# Organize and clean up your .bashrc
/01-core:bashrc-organize
```

### Direct Script Usage

```bash
# Analyze
bash plugins/01-core/skills/bashrc-management/scripts/bashrc-analyze.sh

# Organize
bash plugins/01-core/skills/bashrc-management/scripts/bashrc-organize.sh
```

## What Gets Cleaned Up

### Duplicates Removed
- PATH entries (e.g., `$HOME/bin` added multiple times)
- Environment variables (e.g., `NVM_DIR`, `GEMINI_MODEL`)
- Aliases (e.g., `rm`, `del`, `trash`, `codex`)
- Tool loadings (e.g., NVM loaded 2-3 times)

### Dead Code Removed
- "moved to" comment lines (configs already moved elsewhere)
- Commented-out hardcoded paths
- Disabled exports
- Orphaned comments

### Organization Improvements
- Scattered exports consolidated into one section
- PATH modifications grouped together
- Aliases no longer mixed throughout file
- Clear section headers
- Logical flow

## Safety Features

1. **Automatic Backup**: Creates timestamped backup before any changes
2. **Preview Before Apply**: Shows organized version before replacing
3. **Interactive Confirmation**: Asks before making changes
4. **Diff Available**: Can compare with original using `diff`

## Example Results

**Before**:
- 385 lines total
- 14 PATH modifications (with duplicates)
- 10+ duplicate exports
- 40+ aliases (with duplicates)
- Scattered across 7+ sections
- "moved to" comments littering the file

**After**:
- 334 lines total (51 lines removed!)
- 10 unique PATH modifications
- 8 unique exports
- 35 unique aliases
- Organized into 7 clear sections
- No dead code

## Workflow

1. **Analyze first**: Run `/01-core:bashrc-analyze` to see what issues exist
2. **Review output**: Check the detailed report with line numbers
3. **Organize**: Run `/01-core:bashrc-organize` to clean up
4. **Preview**: Review the organized version at `/tmp/bashrc-organized-TIMESTAMP`
5. **Compare**: Use `diff` to see exactly what changed
6. **Apply**: Confirm to replace your .bashrc
7. **Reload**: Run `source ~/.bashrc` to apply changes

## File Structure

```
plugins/01-core/skills/bashrc-management/
├── README.md                    (this file)
├── scripts/
│   ├── bashrc-analyze.sh       (analysis tool)
│   └── bashrc-organize.sh      (organization tool)
├── templates/
│   └── (future: bashrc templates)
└── docs/
    └── (future: detailed documentation)
```

## Commands

```
/01-core:bashrc-analyze    - Analyze .bashrc for issues
/01-core:bashrc-organize   - Reorganize .bashrc with backup
```

## Integration with Core Plugin

This skill is part of the `01-core` plugin's foundation setup tools. It complements:
- `/01-core:init` - Project initialization
- `/01-core:mcp-setup` - MCP server configuration
- `/01-core:git-setup` - Git workflow setup

## Notes

- **Non-destructive**: Always creates backup before changes
- **Preserves system defaults**: Ubuntu/Debian defaults kept intact
- **Maintains functionality**: All working code preserved
- **Manual review recommended**: Preview before applying
- **Revertible**: Backup file can restore original

## Future Enhancements

- [ ] Template-based bashrc generation for new systems
- [ ] Plugin system for modular bashrc sections
- [ ] Auto-detection of shell type (bash/zsh/fish)
- [ ] Integration with dotfiles management
- [ ] Cloud sync support

---

**Created**: 2025-10-22
**Last Updated**: 2025-10-22
**Status**: Production Ready

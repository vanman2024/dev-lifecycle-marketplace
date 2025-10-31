---
allowed-tools: Bash, Read
description: Reorganize .bashrc into clean, deduplicated sections with backup
argument-hint: none
---

**Bashrc Organizer**

Reorganizes your .bashrc into clean, logical sections:
1. System Defaults (Ubuntu/Debian defaults)
2. Environment Variables (deduplicated)
3. PATH Configuration (consolidated, no duplicates)
4. Aliases (deduplicated)
5. Functions (organized)
6. Tool Loaders (NVM, Google Cloud, etc.)
7. Application Secrets (.env loaders)

## What it does:

- ✅ Removes ALL duplicate PATH entries
- ✅ Removes ALL duplicate exports
- ✅ Removes ALL duplicate aliases
- ✅ Removes "moved to" comment lines (dead code)
- ✅ Consolidates NVM loading (single location)
- ✅ Organizes into clear sections
- ✅ Creates timestamped backup

## Execute Organization

!{bash plugins/01-core/skills/bashrc-management/scripts/bashrc-organize.sh}

**IMPORTANT**: This will prompt you before replacing your .bashrc.
You can preview the organized version and compare with diff first.

## After organizing:

Apply changes:
```bash
source ~/.bashrc
```

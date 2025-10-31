---
allowed-tools: Bash, Read
description: Analyze .bashrc for duplicates, conflicts, and organization issues
argument-hint: none
---

**Bashrc Analysis Tool**

Analyzes your .bashrc file to detect:
- Duplicate PATH entries
- Duplicate exports and aliases
- Loading conflicts (NVM, env files, etc.)
- Commented/dead code
- Organization issues

## Execute Analysis

!{bash plugins/01-core/skills/bashrc-management/scripts/bashrc-analyze.sh}

Shows detailed report with line numbers and recommendations.

## Next Steps

After reviewing the analysis, run:
```
/01-core:bashrc-organize
```

This will create an organized version with automatic backup.

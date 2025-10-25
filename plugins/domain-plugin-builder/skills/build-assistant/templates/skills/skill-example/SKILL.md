---
name: Git Commit Helper
description: Generate clear commit messages from git diffs. Use when writing commit messages or reviewing staged changes.
---

# Git Commit Helper

## Instructions

1. Run `git diff --staged` to see changes
2. Analyze the changes to understand:
   - What was added, modified, or removed
   - Why the changes were made
   - What components are affected
3. Suggest a commit message with:
   - Summary under 50 characters (present tense)
   - Detailed description explaining what and why
   - List of affected components

## Examples

**Example 1: Feature Addition**
```
Summary: Add user authentication system

Details:
- Implemented JWT-based authentication
- Added login and register endpoints
- Created middleware for route protection

Components: auth/, middleware/, routes/
```

**Example 2: Bug Fix**
```
Summary: Fix memory leak in data processor

Details:
- Cleared event listeners after processing
- Added proper cleanup in destructor
- Prevents memory buildup over time

Components: core/processor.js
```

## Best Practices

- Use present tense ("Add feature" not "Added feature")
- Explain what and why, not how
- Keep summary under 50 characters
- Use bullet points for multiple changes
- Reference issue numbers if applicable

---

**Generated from**: multiagent_core/templates/$([ -f "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/build-system" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/build-system" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-build-system" -type d -path "*/skills/*" -name "build-system" 2>/dev/null | head -1)/templates/skills" ] && echo "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/build-system" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/build-system" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-build-system" -type d -path "*/skills/*" -name "build-system" 2>/dev/null | head -1)/templates/skills" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-build-system/skills/*/templates" -name "skills" -type f 2>/dev/null | head -1)/SKILL.md.template
**Template Version**: 1.0.0
**Example**: Complete working skill following all standards

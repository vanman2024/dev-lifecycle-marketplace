---
allowed-tools: Bash, Read, Write, Edit, Task
description: Rollback to previous version by removing tag and resetting files
argument-hint: [version]
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Safely rollback a version release by removing git tag and restoring previous version files

Core Principles:
- Verify version tag exists
- Check if version was pushed to remote
- Delegate rollback execution to agent
- Provide guidance for remote cleanup

## Available Skills

This commands has access to the following skills from the versioning plugin:

- **version-manager**:

**To use a skill:**
```
!{skill skill-name}
```

Use skills when you need:
- Domain-specific templates and examples
- Validation scripts and automation
- Best practices and patterns
- Configuration generators

Skills provide pre-built resources to accelerate your work.

---


## Phase 1: Parse and Validate

Parse target version:

Actions:
- Extract version from $ARGUMENTS
- Add 'v' prefix if not present: v1.2.3
- Verify git repository: !{bash git rev-parse --git-dir}
- Check if tag exists locally: !{bash git tag -l <version_tag>}
  - If not found, exit with error: "Tag <version_tag> does not exist"
- Check if tag exists on remote: !{bash git ls-remote --tags origin <version_tag>}
- Display status:
  - "⚠️  Tag exists on remote - will require manual cleanup"
  - "✓ Tag only exists locally - safe to remove"

## Phase 2: Check Working Tree

Verify clean state:

Actions:
- Check working tree: !{bash git status --porcelain}
- If dirty, exit with error: "Uncommitted changes detected. Commit or stash first."

## Phase 3: Execute Rollback via Agent

Delegate to version-rollback-executor agent:

Actions:
- Invoke version-rollback-executor agent with parameters:
  - version_tag: from Phase 1
  - version_tag_exists: true (verified in Phase 1)
  - tag_on_remote: true|false (from Phase 1)
- Agent will:
  - Find previous version to restore
  - Remove local git tag
  - Reset VERSION, pyproject.toml, package.json to previous version
  - Handle release commit (reset if local, return instructions if pushed)
  - Stage changes for commit

Use Task() to invoke agent:
```
Task(agent="version-rollback-executor", parameters={
  "version_tag": "<version_tag>",
  "version_tag_exists": true,
  "tag_on_remote": <true|false>
})
```

## Phase 4: Create Rollback Commit

Commit the rollback:

Actions:
- Parse agent response JSON
- If agent status is "success":
  - Create commit with previous version:
    !{bash git commit -m "chore: rollback to version <previous_version>"}
  - Display commit hash

## Phase 5: Display Rollback Summary

Show results and next steps:

Actions:
- Display summary:
```
✅ Rollback Complete

Rolled back from: <target_version>
Restored to: <previous_version>

📝 Changes:
  - Tag <version_tag> removed locally
  - VERSION file updated
  - pyproject.toml updated (if exists)
  - package.json updated (if exists)
  - Commit created: <commit_hash>
```

If tag was on remote:
```
⚠️  Remote Cleanup Required

1. Remove remote tag:
   git push origin --delete <version_tag>

2. GitHub release cleanup:
   gh release delete <version_tag> --yes

3. PyPI/npm packages cannot be deleted
   - PyPI: Yanked versions remain visible
   - npm: Use `npm unpublish <package>@<version>` (24hr window only)
```

If release commit was pushed:
```
⚠️  Release Commit Pushed

Revert the release commit:
   git revert <commit_hash>
   git push origin main
```

Display next steps:
```
🚀 Next Steps:

1. Push rollback commit:
   git push origin main

2. Verify version:
   /versioning:info status

3. If needed, create new release:
   /versioning:bump patch
```

## Error Handling

Handle edge cases:

- Tag doesn't exist → Exit with "Tag not found" error
- No previous version → Exit with "Cannot rollback from initial version"
- Working tree dirty → Exit with "Uncommitted changes detected"
- Agent error → Display error message with details

Provide clear guidance for each error scenario.

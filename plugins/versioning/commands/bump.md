---
description: Increment semantic version and create git tag with changelog
argument-hint: "[major|minor|patch] [--dry-run] [--force]"
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

Goal: Increment semantic version (major/minor/patch), update version files, generate changelog, and create annotated git tag

Core Principles:
- Parse bump type from arguments
- Validate git repository state
- Delegate version bump execution to agent
- Provide push instructions or auto-push

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


## Phase 1: Parse Arguments and Validate

Parse bump type and flags:

Actions:
- Extract bump type from first argument: major, minor, or patch
- Check for `--dry-run` flag (preview only, no changes)
- Check for `--force` flag (auto-push without confirmation)
- If no bump type provided, default to patch
- Validate bump type is one of: major, minor, patch

Validate prerequisites:
- Verify git repository: !{bash git rev-parse --git-dir}
- Check working tree is clean: !{bash git status --porcelain}
  - If dirty, exit with error: "Uncommitted changes detected. Commit or stash first."
- Verify VERSION file exists: !{bash test -f VERSION && echo "exists" || echo "missing"}
  - If not found, exit with error: "Run /versioning:setup first"
- Verify git user configured: !{bash git config user.name && git config user.email}

## Phase 2: Read Current Version

Load current version:

Actions:
- Read VERSION file: @VERSION
- Parse JSON to extract current version string
- Validate version format matches semantic versioning: `MAJOR.MINOR.PATCH`
- Display current version: "Current version: X.Y.Z"

## Phase 3: Execute Version Bump via Agent

Delegate to version-bumper agent:

Actions:
- Invoke version-bumper agent with parameters:
  - bump_type: major|minor|patch
  - current_version: from Phase 2
  - dry_run: true|false
  - force_push: true|false
- Agent will:
  - Calculate new version
  - Generate changelog from commits
  - Update VERSION, pyproject.toml, package.json
  - Create git commit and tag
  - Handle push (if --force) or return status

Use Task() to invoke agent:
```
Task(agent="version-bumper", parameters={
  "bump_type": "<major|minor|patch>",
  "current_version": "<current_version>",
  "dry_run": <true|false>,
  "force_push": <true|false>
})
```

## Phase 4: Display Results

Show results based on agent status:

Actions:
- Parse agent response JSON
- Display results based on status:

**If status is "dry_run_complete":**
```
DRY RUN - No changes made

Would bump: <old_version> → <new_version>

Changelog Preview:
<changelog>
```

**If status is "pushed":**
```
✅ Version bumped and pushed: <old_version> → <new_version>

Tag: <tag_name>
Commit: <commit_hash>

Monitor release: gh run list --workflow=version-management.yml
```

**If status is "ready_to_push":**
```
✅ Version bumped: <old_version> → <new_version>

📝 Changes:
  - VERSION: ✓
  - pyproject.toml: ✓ (if exists)
  - package.json: ✓ (if exists)
  - Commit: <commit_hash>
  - Tag: <tag_name>

📋 Changelog:
<changelog>

🚀 To complete the release:

1. Push changes and tags:
   git push && git push --tags

2. GitHub Actions will:
   - Create GitHub release
   - Publish to PyPI/npm (if configured)
   - Update CHANGELOG.md

3. Monitor release:
   gh run list --workflow=version-management.yml

📌 Rollback (if needed):
   /versioning:rollback <new_version>
```

**If status is "error":**
- Display error message
- Provide suggested fixes based on error type

## Error Handling

Handle failures from agent:

- Working tree dirty → Exit with uncommitted changes error
- VERSION file missing → Exit with "run /versioning:setup" error
- Invalid bump type → Exit with valid options (major/minor/patch)
- Git tag already exists → Exit with "tag v<version> already exists"
- No commits since last tag → Exit with "no changes to release"

Display error context and suggested fixes for each error type.

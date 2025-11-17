---
description: Create pre-release versions (alpha, beta, RC)
argument-hint: "[alpha|beta|rc] [--dry-run]"
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

---


**Arguments**: $ARGUMENTS

Goal: Create pre-release version with alpha, beta, or RC suffix for testing before official release

Core Principles:
- Support alpha, beta, and rc pre-release identifiers
- Auto-increment pre-release number (e.g., 1.0.0-alpha.1, 1.0.0-alpha.2)
- Generate changelog from commits since last version
- Create annotated git tag for pre-release

## Phase 1: Parse Arguments and Validate

Parse pre-release type and flags:

Actions:
- Extract pre-release type from first argument: alpha, beta, or rc
- Check for `--dry-run` flag (preview only, no changes)
- If no type provided, default to alpha
- Validate type is one of: alpha, beta, rc
- Normalize: alpha/Alpha/ALPHA → alpha

Validate prerequisites:
- Verify git repository: `git rev-parse --git-dir`
- Check working tree is clean: `git status --porcelain`
  - If dirty, exit with error: "Uncommitted changes detected. Commit or stash first."
- Verify VERSION file exists
  - If not found, exit with error: "Run /versioning:setup first"
- Verify git user configured: `git config user.name` and `git config user.email`

## Phase 2: Read Current Version

Load and parse current version:

Actions:
- Read VERSION file
- Parse JSON to extract current version string
- Check if current version is already a pre-release:
  - Pattern: `X.Y.Z-TYPE.N` (e.g., 1.0.0-alpha.1)
  - Extract base version, pre-release type, and number
- If stable version (X.Y.Z):
  - Use as base for new pre-release
  - Start at .1 (e.g., 1.0.0 → 1.0.0-alpha.1)
- Display current version: "Current version: X.Y.Z"

## Phase 3: Calculate Pre-Release Version

Compute new pre-release version:

Actions:
- **Same pre-release type** (e.g., alpha → alpha):
  - Increment pre-release number: 1.0.0-alpha.1 → 1.0.0-alpha.2
  - Keep base version unchanged
- **Different pre-release type** (e.g., alpha → beta):
  - Keep base version, change type, reset to .1
  - Example: 1.0.0-alpha.3 → 1.0.0-beta.1
- **Stable to pre-release** (e.g., 1.0.0 → 1.0.0-alpha.1):
  - Add pre-release suffix with .1
  - Example: 1.0.0 → 1.0.0-alpha.1
- Construct new version: `{major}.{minor}.{patch}-{type}.{number}`
- Display: "New pre-release version: X.Y.Z-TYPE.N"

## Phase 4: Generate Changelog

Extract commits for pre-release:

Actions:
- Find last version tag: !{bash git describe --tags --abbrev=0 --match "v*" 2>/dev/null}
- If no tags exist, use initial commit
- Get commit range with format: hash|subject|author
- Categorize by conventional commit types: feat, fix, BREAKING CHANGE, chore
- Format changelog with pre-release header noting test-only status

## Phase 5: Update Version Files

Update version references (skip if --dry-run):

Actions:
- Update VERSION file with new version, current commit SHA, ISO timestamp, build_type: "prerelease"
- Update pyproject.toml if exists: version field
- Update package.json if exists: version field
- Pre-release versions follow semver: X.Y.Z-prerelease.N

## Phase 6: Commit Pre-Release Changes

Create commit (skip if --dry-run):

Actions:
- Stage version files: `git add VERSION pyproject.toml package.json`
- Create commit: `git commit -m "chore(release): pre-release <new_version>"`
- Get commit hash for reference
- Display: "Committed: <commit_hash>"

## Phase 7: Create Pre-Release Tag

Create annotated tag (skip if --dry-run):

Actions:
- Create tag: !{bash git tag -a v<VERSION> -m "<CHANGELOG>"}
- Verify tag exists and show details without patch content

## Phase 8: Summary and Instructions

Display completion summary:

Actions:
- If dry-run: Show what would be created and exit
- Otherwise display:
  - Pre-release created: old → new version
  - Files updated: VERSION, pyproject.toml (if exists), package.json (if exists)
  - Commit hash and tag created
  - Formatted pre-release changelog
  - Next steps:
    1. Test thoroughly
    2. Push: git push && git push --tags
    3. Create another pre-release: /versioning:prerelease [type]
    4. Promote to stable: /versioning:bump [type]
  - Warning: Pre-releases NOT for production registries
  - Rollback option: /versioning:rollback [version]

## Error Handling

Handle failures gracefully:

- Working tree dirty → Exit with uncommitted changes error
- VERSION file missing → Exit with "run /versioning:setup" error
- Invalid pre-release type → Exit with valid options (alpha/beta/rc)
- Git tag already exists → Exit with "tag v<version> already exists"
- No commits since last tag → Exit with "no changes for pre-release"

Display error context and suggested fixes for each error type.

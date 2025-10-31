---
allowed-tools: Bash(*), Read(*), Write(*), Edit(*)
description: Increment semantic version and create git tag with changelog
argument-hint: [major|minor|patch] [--dry-run] [--force]
---

**Arguments**: $ARGUMENTS

Goal: Increment semantic version (major/minor/patch), update version files, generate changelog, and create annotated git tag

Core Principles:
- Parse bump type from arguments
- Validate git repository state
- Calculate new version
- Generate changelog from commits
- Update all version files
- Create git tag with changelog
- Provide push instructions

## Phase 1: Parse Arguments and Validate

Parse bump type and flags:

Actions:
- Extract bump type from first argument: major, minor, or patch
- Check for `--dry-run` flag (preview only, no changes)
- Check for `--force` flag (auto-push without confirmation)
- If no bump type provided, default to patch
- Validate bump type is one of: major, minor, patch

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
- Validate version format matches semantic versioning: `MAJOR.MINOR.PATCH`
- Split into components: major, minor, patch numbers
- Display current version: "Current version: X.Y.Z"

## Phase 3: Calculate New Version

Compute new version based on bump type:

Actions:
- **major**: Increment MAJOR, reset MINOR and PATCH to 0
  - Example: 1.4.2 → 2.0.0
- **minor**: Increment MINOR, reset PATCH to 0
  - Example: 1.4.2 → 1.5.0  
- **patch**: Increment PATCH only
  - Example: 1.4.2 → 1.4.3
- Construct new version string: `{major}.{minor}.{patch}`
- Display: "New version: X.Y.Z"

## Phase 4: Generate Changelog

Extract commits since last version tag:

Actions:
- Find last version tag: `git describe --tags --abbrev=0 --match "v*" 2>/dev/null`
  - If no tags exist, use initial commit: `git rev-list --max-parents=0 HEAD`
- Get commit range: `git log <last_tag>..HEAD --pretty=format:"%h|%s|%an|%ae"`
- Categorize commits by type:
  - **Features**: Commits starting with `feat:` or `feat(`
  - **Bug Fixes**: Commits starting with `fix:` or `fix(`
  - **Breaking Changes**: Commits with `BREAKING CHANGE:` or `!:`
  - **Chores**: Commits starting with `chore:`, `docs:`, `ci:`, `test:`
- Format changelog:
  ```
  ## [X.Y.Z] - YYYY-MM-DD
  
  ### Features
  - feat: description (commit_hash)
  
  ### Bug Fixes
  - fix: description (commit_hash)
  
  ### Breaking Changes
  - BREAKING: description (commit_hash)
  ```

## Phase 5: Update Version Files

Update all version references (skip if --dry-run):

Actions:
- Update VERSION file:
  ```json
  {
    "version": "<new_version>",
    "commit": "<current_git_sha>",
    "build_date": "<current_iso_timestamp>",
    "build_type": "release"
  }
  ```
- Check for pyproject.toml:
  - If exists, update: `version = "<new_version>"`
- Check for package.json:
  - If exists, update: `"version": "<new_version>"`
- Verify all files updated successfully

## Phase 6: Commit Version Bump

Create commit with version changes (skip if --dry-run):

Actions:
- Stage version files: `git add VERSION pyproject.toml package.json CHANGELOG.md`
- Create commit: `git commit -m "chore(release): bump version to <new_version>"`
- Get commit hash for reference
- Display: "Committed: <commit_hash>"

## Phase 7: Create Git Tag

Create annotated tag with changelog (skip if --dry-run):

Actions:
- Create annotated tag with full changelog:
  ```bash
  git tag -a v<new_version> -m "<changelog_content>"
  ```
- Verify tag created: `git tag -l v<new_version>`
- Display tag details: `git show v<new_version> --no-patch`

## Phase 8: Confirm Push or Auto-Push

Handle push confirmation:

Actions:
- If `--dry-run` flag:
  - Display: "DRY RUN - No changes made"
  - Show what would be pushed
  - Exit
  
- If `--force` flag:
  - Auto-push: `git push && git push --tags`
  - Display: "Pushed to remote"
  - Exit

- Otherwise, display push instructions:
  ```
  ✅ Version bumped: <old_version> → <new_version>
  
  📝 Changes:
    - VERSION: ✓
    - pyproject.toml: ✓ (if exists)
    - package.json: ✓ (if exists)
    - Commit: <commit_hash>
    - Tag: v<new_version>
  
  📋 Changelog Preview:
  <formatted_changelog>
  
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

## Error Handling

Handle failures gracefully:

- Working tree dirty → Exit with uncommitted changes error
- VERSION file missing → Exit with "run /versioning:setup" error
- Invalid bump type → Exit with valid options (major/minor/patch)
- Git tag already exists → Exit with "tag v<version> already exists"
- No commits since last tag → Exit with "no changes to release"

Display error context and suggested fixes for each error type.

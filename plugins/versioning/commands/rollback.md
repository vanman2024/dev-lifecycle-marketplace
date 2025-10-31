---
allowed-tools: Bash(*), Read(*), Write(*), Edit(*)
description: Rollback to previous version by removing tag and resetting files
argument-hint: [version]
---

**Arguments**: $ARGUMENTS

Goal: Safely rollback a version release by removing git tag and restoring previous version files

Core Principles:
- Verify version tag exists
- Check if version was pushed to remote
- Remove local tag
- Reset version files to previous state
- Provide guidance for remote cleanup

## Phase 1: Parse and Validate

Parse target version:

Actions:
- Extract version from $ARGUMENTS
- Add 'v' prefix if not present: v1.2.3
- Verify git repository: `git rev-parse --git-dir`
- Check if tag exists: `git tag -l <version_tag>`
  - If not found, exit with error: "Tag <version_tag> does not exist"

## Phase 2: Check Remote Status

Determine if version was pushed:

Actions:
- Check if tag exists on remote: `git ls-remote --tags origin <version_tag>`
- Check if release commit was pushed: `git branch -r --contains <version_tag>`
- Display status:
  - "⚠️  Tag exists on remote - will require force push"
  - "✓ Tag only exists locally - safe to remove"

## Phase 3: Find Previous Version

Locate the version to restore:

Actions:
- List all version tags: `git tag -l "v*" --sort=-version:refname`
- Find tag before target version
- If no previous version exists, use initial state (0.1.0 or from manifest)
- Display: "Will rollback from <current> to <previous>"

## Phase 4: Remove Git Tag

Delete the version tag:

Actions:
- Remove local tag: `git tag -d <version_tag>`
- Verify tag removed: `git tag -l <version_tag>` should return empty
- Display: "Removed local tag: <version_tag>"

If tag exists on remote:
- Display remote removal command:
  ```
  ⚠️  To remove from remote (DESTRUCTIVE):
  git push origin --delete <version_tag>
  ```
- Do not auto-execute (requires manual confirmation)

## Phase 5: Reset Version Files

Restore previous version in files:

Actions:
- Get previous version number
- Update VERSION file:
  ```json
  {
    "version": "<previous_version>",
    "commit": "<current_git_sha>",
    "build_date": "<current_iso_timestamp>",
    "build_type": "development"
  }
  ```
- If pyproject.toml exists:
  - Update: `version = "<previous_version>"`
- If package.json exists:
  - Update: `"version": "<previous_version>"`
- Verify all files updated

## Phase 6: Reset Release Commit

Handle the release commit:

Actions:
- Find the release commit: `git log --grep="chore(release): bump version to <version>" --format="%H" -1`
- Check if commit was pushed to remote
- If commit exists and is local only:
  - Reset commit: `git reset --soft HEAD~1`
  - Display: "Reset release commit (changes staged)"
- If commit was pushed:
  - Display: "⚠️  Release commit was pushed - requires git revert or force push"
  - Provide revert command:
    ```
    git revert <commit_hash>
    git push origin main
    ```

## Phase 7: Display Rollback Summary

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
  
  ⚠️  If version was published:
  
  1. Remote tag cleanup (if pushed):
     git push origin --delete <version_tag>
  
  2. PyPI/npm packages cannot be deleted
     - PyPI: Yanked versions remain visible
     - npm: Use `npm unpublish <package>@<version>` (24hr window only)
  
  3. GitHub release cleanup:
     gh release delete <version_tag> --yes
  
  🚀 Next Steps:
  
  1. Commit rollback:
     git add VERSION pyproject.toml package.json
     git commit -m "chore: rollback to version <previous_version>"
  
  2. Push changes:
     git push origin main
  
  3. Verify version:
     /versioning:info status
  ```

## Error Handling

Handle edge cases:

- Tag doesn't exist → Exit with "Tag not found" error
- No previous version → Exit with "Cannot rollback from initial version"
- Working tree dirty → Exit with "Uncommitted changes detected"
- Published to registry → Display warning about permanent packages

Provide clear guidance for each error scenario.

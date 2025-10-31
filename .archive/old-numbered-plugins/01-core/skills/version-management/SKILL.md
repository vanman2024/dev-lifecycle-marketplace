---
name: Version Management
description: Semantic versioning helpers and release scripts. Use when managing versions, bumping version numbers, creating releases, generating changelogs, or when user mentions versioning, semantic versioning, release management, version bumps, or semver.
allowed-tools: Read, Write, Edit, Bash
---

# Version Management

This skill provides semantic versioning helpers, version bump scripts, changelog generation, and release management tools.

## What This Skill Provides

### 1. Version Bump Scripts
- `bump-version.sh` - Increment version (major/minor/patch)
- `get-version.sh` - Extract current version from project files
- `set-version.sh` - Update version across all files

### 2. Changelog Generation
- `generate-changelog.sh` - Create changelog from git commits
- Conventional commit parsing
- Categorized changes (feat, fix, docs, etc.)

### 3. Release Scripts
- `create-release.sh` - Tag and prepare release
- `validate-release.sh` - Check release readiness
- Git tag creation with annotations

### 4. Version File Templates
- package.json version field
- pyproject.toml version field
- Cargo.toml version field
- VERSION file template

## Instructions

### Bumping Version

When user wants to increment version:

1. Detect current version from project files
2. Parse semantic version (MAJOR.MINOR.PATCH)
3. Increment appropriate component:
   - major: Breaking changes (1.0.0 → 2.0.0)
   - minor: New features (1.0.0 → 1.1.0)
   - patch: Bug fixes (1.0.0 → 1.0.1)
4. Update all version files

Execute:

!{bash plugins/01-core/skills/version-management/scripts/bump-version.sh major}
!{bash plugins/01-core/skills/version-management/scripts/bump-version.sh minor}
!{bash plugins/01-core/skills/version-management/scripts/bump-version.sh patch}

### Generating Changelog

When user wants changelog:

1. Get commits since last tag
2. Parse conventional commit messages
3. Categorize by type (feat, fix, docs, etc.)
4. Format as markdown with links

Execute:

!{bash plugins/01-core/skills/version-management/scripts/generate-changelog.sh}

### Creating Release

When user wants to create release:

1. Validate no uncommitted changes
2. Bump version
3. Update changelog
4. Create git commit
5. Create git tag
6. Display next steps (push, publish)

## Semantic Versioning Rules

**MAJOR** (X.0.0):
- Breaking changes
- Incompatible API changes
- Major refactoring

**MINOR** (x.Y.0):
- New features
- Backward-compatible additions
- Deprecations

**PATCH** (x.y.Z):
- Bug fixes
- Performance improvements
- Documentation updates

## Success Criteria

- ✅ Version follows semver format
- ✅ All version files updated consistently
- ✅ Changelog generated from commits
- ✅ Git tag created with version
- ✅ Release is reproducible

---

**Plugin**: 01-core
**Skill Type**: Helper + Generator
**Auto-invocation**: Yes (via description matching)

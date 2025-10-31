# Versioning Plugin

Semantic versioning automation with changelog generation and CI/CD integration for Python and TypeScript/JavaScript projects.

## Overview

The versioning plugin provides comprehensive version management using semantic versioning and conventional commits. It automates version bumping, changelog generation, git tagging, and GitHub Actions CI/CD integration with package registry publishing.

## Features

- ✅ Automatic version bumping (major/minor/patch) based on conventional commits
- ✅ Changelog generation from git commit history
- ✅ Git tag creation with annotated changelogs
- ✅ GitHub Actions CI/CD workflows for automated releases
- ✅ PyPI and npm package publishing automation
- ✅ Version consistency validation across project files
- ✅ Support for Python (pyproject.toml) and TypeScript/JavaScript (package.json)
- ✅ Rollback capabilities for failed releases

## Components

### Commands

- **`/versioning:setup`** - Setup semantic versioning with GitHub Actions workflow
- **`/versioning:bump`** - Increment version and create git tag
- **`/versioning:rollback`** - Rollback to previous version
- **`/versioning:info`** - Display version status, validate configuration, show history

### Agents

- **changelog-generator** - Generate formatted changelogs from git commits
- **release-validator** - Validate releases for completeness and readiness

### Skills

- **version-manager** - Scripts, templates, and examples for version management
  - 5 functional bash scripts (detect, bump, changelog, validate, tag)
  - GitHub Actions workflow templates
  - VERSION file and configuration templates
  - Conventional commit examples

## Quick Start

### 1. Setup Version Management

```bash
/versioning:setup
```

This will:
- Detect project type (Python/TypeScript/JavaScript)
- Create VERSION file
- Install GitHub Actions workflow
- Provide instructions for GitHub secrets configuration

### 2. Configure GitHub Secrets

Add package registry token to GitHub:
- For Python: Add `PYPI_TOKEN` from https://pypi.org/manage/account/token/
- For TypeScript/JavaScript: Add `NPM_TOKEN` from https://www.npmjs.com/settings/tokens

Go to: `https://github.com/<owner>/<repo>/settings/secrets/actions`

### 3. Use Conventional Commits

```bash
# Feature (minor version bump)
git commit -m "feat: add user authentication"

# Bug fix (patch version bump)
git commit -m "fix: resolve memory leak"

# Breaking change (major version bump)
git commit -m "feat!: redesign API

BREAKING CHANGE: All endpoints now use /api/v2/"
```

### 4. Bump Version

```bash
# Preview changes (dry run)
/versioning:bump patch --dry-run

# Bump version
/versioning:bump patch

# Push to trigger CI/CD release
git push && git push --tags
```

### 5. Monitor Release

```bash
# Check version status
/versioning:info status

# View version history
/versioning:info history

# Validate configuration
/versioning:info validate
```

## Usage

### Bumping Versions

```bash
# Patch bump (X.Y.Z → X.Y.Z+1)
/versioning:bump patch

# Minor bump (X.Y.Z → X.Y+1.0)
/versioning:bump minor

# Major bump (X.Y.Z → X+1.0.0)
/versioning:bump major

# Dry run (preview only)
/versioning:bump minor --dry-run

# Auto-push to remote
/versioning:bump patch --force
```

### Version Information

```bash
# Show current status
/versioning:info status

# Validate configuration
/versioning:info validate

# Show version history
/versioning:info history
```

### Rollback

```bash
# Rollback to previous version
/versioning:rollback 1.2.3
```

## Conventional Commits

The plugin uses [Conventional Commits](https://www.conventionalcommits.org/) format:

### Version Bump Types

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `feat:` | Minor | `feat: add OAuth support` |
| `fix:` | Patch | `fix: resolve memory leak` |
| `perf:` | Patch | `perf: optimize queries` |
| `feat!:` or `BREAKING CHANGE:` | Major | `feat!: redesign API` |

### No Version Bump

These commit types don't trigger releases:
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes
- `test:` - Test updates
- `style:` - Code formatting
- `refactor:` - Code restructuring

### Commit Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Examples:**

```bash
# Feature with scope
git commit -m "feat(auth): add JWT token refresh mechanism"

# Bug fix with issue reference
git commit -m "fix: resolve CORS configuration (#456)"

# Breaking change
git commit -m "feat!: remove deprecated API v1

BREAKING CHANGE: API v1 endpoints removed.
All clients must migrate to v2."
```

## Workflow

1. **Develop** - Make changes and commit using conventional format
2. **Validate** - Run `/versioning:info validate` to check readiness
3. **Bump** - Run `/versioning:bump <type>` to create new version
4. **Review** - Check changelog and version changes
5. **Push** - Push commits and tags to trigger CI/CD
6. **Monitor** - GitHub Actions automatically:
   - Updates VERSION and manifest files
   - Generates CHANGELOG.md
   - Creates GitHub release
   - Publishes to PyPI/npm
7. **Pull** - Pull release commit back to local

## File Structure

```
plugins/versioning/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── setup.md
│   ├── bump.md
│   ├── rollback.md
│   └── info.md
├── agents/
│   ├── changelog-generator.md
│   └── release-validator.md
├── skills/
│   └── version-manager/
│       ├── SKILL.md
│       ├── reference.md
│       ├── scripts/
│       │   ├── detect-project-type.sh
│       │   ├── bump-version.sh
│       │   ├── generate-changelog.sh
│       │   ├── validate-version.sh
│       │   └── create-git-tag.sh
│       ├── templates/
│       │   ├── VERSION.json
│       │   ├── CHANGELOG.md
│       │   └── commit-templates.md
│       └── examples/
│           ├── conventional-commits.md
│           └── bump-scenarios.md
└── README.md
```

## Integration with Dev Lifecycle

The versioning plugin integrates with other dev-lifecycle-marketplace plugins:

- **planning** - Version planning and release roadmaps
- **quality** - Pre-release validation and testing
- **deployment** - Coordinated version bumps with deployments
- **iterate** - Version tracking in task management

## Troubleshooting

### Version Mismatch

```bash
# Validate and see mismatches
/versioning:info validate

# Fix manually or re-bump
/versioning:bump patch
```

### Failed Release

```bash
# Check GitHub Actions logs
gh run list --workflow=version-management.yml

# Rollback if needed
/versioning:rollback <version>
```

### Tag Already Exists

```bash
# Delete local tag
git tag -d v1.2.3

# Delete remote tag (if pushed)
git push origin --delete v1.2.3
```

## Best Practices

1. **Always use conventional commits** for automatic changelog generation
2. **Validate before bumping** with `/versioning:info validate`
3. **Test in CI/CD** before pushing tags
4. **Pull after releases** to sync local with remote changes
5. **Document breaking changes** prominently in commit messages
6. **Review changelogs** before releases
7. **Keep VERSION file** in sync with manifests

## See Also

- @plugins/versioning/commands/ - Command documentation
- @plugins/versioning/agents/ - Agent documentation
- @plugins/versioning/skills/version-manager/SKILL.md - Skill usage guide
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

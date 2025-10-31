# Version-Manager Skill

Comprehensive version management utilities for semantic versioning automation.

## Overview

This skill provides scripts, templates, and examples for automated version management using semantic versioning and conventional commits. It supports both Python and TypeScript/JavaScript projects with GitHub Actions CI/CD integration.

## Components

### Scripts

Functional bash scripts for version management operations:

- **detect-project-type.sh** - Detect Python vs TypeScript/JavaScript projects
- **bump-version.sh** - Calculate and update version in all files  
- **generate-changelog.sh** - Extract commits and format changelog
- **validate-version.sh** - Verify version consistency across files
- **create-git-tag.sh** - Create annotated tag with changelog

### Templates

Production-ready configuration templates:

- **github-workflows/** - GitHub Actions workflows for Python and TypeScript
- **VERSION.json** - VERSION file template with metadata structure
- **releaserc.json** - Semantic-release configuration
- **CHANGELOG.md** - Keep a Changelog format template
- **commit-templates.md** - Conventional commit message templates

### Examples

Realistic examples for common scenarios:

- **conventional-commits.md** - Example commit messages (feat, fix, breaking)
- **changelog-entries.md** - Example changelog formatting
- **version-file.json** - Example VERSION file with metadata
- **workflow-outputs.md** - Example GitHub Actions outputs
- **bump-scenarios.md** - Example version bump cases

## Usage

### Detecting Project Type

```bash
bash plugins/versioning/skills/version-manager/scripts/detect-project-type.sh <project_dir> <output_file>
```

Output format (JSON):
```json
{
  "project_type": "python|typescript|javascript",
  "manifest_file": "pyproject.toml|package.json",
  "has_typescript": true|false
}
```

### Bumping Version

```bash
bash plugins/versioning/skills/version-manager/scripts/bump-version.sh <bump_type> <current_version>
```

Bump types: major, minor, patch

Returns: New version string

### Generating Changelog

```bash
bash plugins/versioning/skills/version-manager/scripts/generate-changelog.sh <from_tag> <to_ref> <version>
```

Outputs formatted changelog to stdout.

### Validating Version Consistency

```bash
bash plugins/versioning/skills/version-manager/scripts/validate-version.sh <project_dir>
```

Checks VERSION file, pyproject.toml, package.json for consistency.

Exit codes:
- 0: All versions consistent
- 1: Version mismatch detected
- 2: Missing required files

### Creating Git Tag

```bash
bash plugins/versioning/skills/version-manager/scripts/create-git-tag.sh <version> <changelog_file>
```

Creates annotated git tag with changelog as message.

## Templates Usage

### GitHub Actions Workflow

Copy appropriate workflow template:

**Python:**
```bash
cp plugins/versioning/skills/version-manager/templates/github-workflows/python-version-management.yml .github/workflows/version-management.yml
```

**TypeScript:**
```bash
cp plugins/versioning/skills/version-manager/templates/github-workflows/typescript-version-management.yml .github/workflows/version-management.yml
```

### Semantic-Release Configuration

Copy .releaserc.json template:
```bash
cp plugins/versioning/skills/version-manager/templates/releaserc.json .releaserc.json
```

Customize branches, plugins, and assets as needed.

## Integration with Commands

This skill is used by versioning plugin commands:

- **/versioning:setup** - Uses detect-project-type.sh and workflow templates
- **/versioning:bump** - Uses bump-version.sh, generate-changelog.sh, create-git-tag.sh
- **/versioning:info** - Uses validate-version.sh
- **/versioning:rollback** - Uses version validation scripts

## Integration with Agents

This skill provides utilities for versioning plugin agents:

- **changelog-generator** - Uses generate-changelog.sh for commit analysis
- **release-validator** - Uses validate-version.sh for consistency checks

## Best Practices

1. **Always validate** before bumping versions
2. **Use conventional commits** for accurate changelog generation
3. **Test workflows** in CI/CD before releasing
4. **Keep VERSION file** in sync with manifests
5. **Document breaking changes** prominently in commits

## Troubleshooting

### Version Mismatch

If validation fails with version mismatch:
```bash
# Check all version locations
grep -r "version" VERSION pyproject.toml package.json

# Manually sync if needed
bash plugins/versioning/skills/version-manager/scripts/bump-version.sh patch $(cat VERSION | jq -r '.version')
```

### Changelog Generation Issues

If changelog is empty or incorrect:
```bash
# Verify commit format
git log --oneline --grep="^feat:" --grep="^fix:" -E

# Check tag exists
git tag -l "v*"

# Regenerate manually
bash plugins/versioning/skills/version-manager/scripts/generate-changelog.sh v1.0.0 HEAD 1.1.0
```

### Git Tag Creation Fails

If tag creation fails:
```bash
# Check if tag already exists
git tag -l v1.2.3

# Remove existing tag if needed
git tag -d v1.2.3

# Recreate tag
bash plugins/versioning/skills/version-manager/scripts/create-git-tag.sh 1.2.3 CHANGELOG.md
```

## See Also

- @plugins/versioning/skills/version-manager/reference.md - Full API reference
- @plugins/versioning/skills/version-manager/examples/ - Complete examples
- @plugins/versioning/commands/ - Versioning commands documentation
- @plugins/versioning/agents/ - Versioning agents documentation

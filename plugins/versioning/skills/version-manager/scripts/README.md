# Version Manager Scripts

Functional bash scripts for semantic versioning automation.

## Scripts

- **detect-project-type.sh** - Detect Python vs TypeScript/JavaScript
- **bump-version.sh** - Calculate new version (major/minor/patch)
- **generate-changelog.sh** - Generate formatted changelog from commits
- **validate-version.sh** - Verify version consistency across files
- **create-git-tag.sh** - Create annotated git tag with changelog

## Usage

All scripts are executable and self-contained. Run with `--help` or see reference.md for full documentation.

```bash
# Detect project type
bash detect-project-type.sh . output.json

# Bump version
bash bump-version.sh patch 1.2.3

# Generate changelog
bash generate-changelog.sh v1.2.0 HEAD 1.3.0

# Validate versions
bash validate-version.sh .

# Create git tag
bash create-git-tag.sh 1.3.0 CHANGELOG.md
```

## Dependencies

- bash 4.0+
- git 2.0+
- jq 1.5+

## See Also

- @../reference.md - Full API reference
- @../SKILL.md - Skill documentation

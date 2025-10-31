# Version-Manager - API Reference

## Scripts

### detect-project-type.sh

**Synopsis:**
```bash
detect-project-type.sh [PROJECT_DIR] [OUTPUT_FILE]
```

**Parameters:**
- `PROJECT_DIR` - Project directory to analyze (default: current directory)
- `OUTPUT_FILE` - Output JSON file path (default: stdout)

**Output:**
```json
{
  "project_type": "python|typescript|javascript",
  "manifest_file": "pyproject.toml|package.json",
  "has_typescript": true|false
}
```

**Exit Codes:**
- 0: Success
- 1: Could not detect project type

### bump-version.sh

**Synopsis:**
```bash
bump-version.sh <BUMP_TYPE> [CURRENT_VERSION]
```

**Parameters:**
- `BUMP_TYPE` - Version bump type: major, minor, or patch (required)
- `CURRENT_VERSION` - Current version string (optional, reads from VERSION file if not provided)

**Output:**
New version string to stdout

**Exit Codes:**
- 0: Success
- 1: Invalid arguments or version format

**Examples:**
```bash
bump-version.sh patch 1.2.3  # Output: 1.2.4
bump-version.sh minor 1.2.4  # Output: 1.3.0
bump-version.sh major 1.3.0  # Output: 2.0.0
```

### generate-changelog.sh

**Synopsis:**
```bash
generate-changelog.sh <FROM_TAG> [TO_REF] [VERSION]
```

**Parameters:**
- `FROM_TAG` - Starting git tag or commit (required)
- `TO_REF` - Ending git ref (default: HEAD)
- `VERSION` - Version number for changelog header (optional)

**Output:**
Formatted changelog in Markdown to stdout

**Exit Codes:**
- 0: Success
- 1: No commits found in range

**Examples:**
```bash
generate-changelog.sh v1.2.0 HEAD 1.3.0
generate-changelog.sh v1.2.0
```

### validate-version.sh

**Synopsis:**
```bash
validate-version.sh [PROJECT_DIR]
```

**Parameters:**
- `PROJECT_DIR` - Project directory to validate (default: current directory)

**Checks:**
- VERSION file exists and is valid JSON
- Version format matches semver (X.Y.Z)
- pyproject.toml version matches (if exists)
- package.json version matches (if exists)
- Reports git tag status (informational)

**Output:**
Validation messages to stderr

**Exit Codes:**
- 0: All versions consistent
- 1: Version mismatch detected
- 2: Missing required files or parse errors

**Examples:**
```bash
validate-version.sh
validate-version.sh /path/to/project
```

### create-git-tag.sh

**Synopsis:**
```bash
create-git-tag.sh <VERSION> [CHANGELOG_FILE]
```

**Parameters:**
- `VERSION` - Version number (v prefix added if missing) (required)
- `CHANGELOG_FILE` - File containing changelog for tag annotation (optional)

**Output:**
Tag name to stdout, details to stderr

**Exit Codes:**
- 0: Tag created successfully
- 1: Tag already exists or creation failed

**Examples:**
```bash
create-git-tag.sh 1.3.0 CHANGELOG.md
create-git-tag.sh v1.3.0
```

## Templates

### VERSION.json
JSON structure for version metadata:
```json
{
  "version": "X.Y.Z",
  "commit": "git-sha",
  "build_date": "ISO-8601-timestamp",
  "build_type": "development|production"
}
```

### CHANGELOG.md
Keep a Changelog format template with sections:
- Unreleased
- Version entries with date
- Added/Changed/Deprecated/Removed/Fixed/Security sections

### commit-templates.md
Conventional commit format examples:
- feat: (minor bump)
- fix: (patch bump)
- BREAKING CHANGE: (major bump)
- perf/docs/chore/ci/test (no bump)

## Integration

### With Commands

**setup command:**
```markdown
- Detect project type: detect-project-type.sh
- Create VERSION file from template
- Copy workflow templates
```

**bump command:**
```markdown
- Calculate new version: bump-version.sh
- Generate changelog: generate-changelog.sh
- Validate consistency: validate-version.sh
- Create git tag: create-git-tag.sh
```

**info command:**
```markdown
- Validate versions: validate-version.sh
- Display status and history
```

### With Agents

**changelog-generator agent:**
```markdown
- Uses generate-changelog.sh for commit parsing
- Formats output for releases
```

**release-validator agent:**
```markdown
- Uses validate-version.sh for consistency checks
- Verifies all prerequisites
```

## Error Handling

All scripts follow consistent error handling:
- Exit code 0 = success
- Exit code 1 = validation/logic errors
- Exit code 2 = missing prerequisites
- Errors output to stderr
- Results output to stdout
- Informational messages to stderr

## Dependencies

### Required

- bash (4.0+)
- git (2.0+)
- jq (1.5+) - JSON parsing

### Optional

- grep (for validation)
- sed (for text processing)

## See Also

- @plugins/versioning/skills/version-manager/SKILL.md - Usage guide
- @plugins/versioning/skills/version-manager/examples/ - Complete examples
- @plugins/versioning/commands/ - Versioning commands

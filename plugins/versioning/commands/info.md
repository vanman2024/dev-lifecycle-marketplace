---
allowed-tools: Bash, Read, Grep, Glob
description: Display version information and validate configuration
argument-hint: [status|validate|history]
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

Goal: Provide comprehensive version information, validate setup, and display version history

Core Principles:
- Display current version status
- Validate version management configuration
- Show version history and changelog
- Detect issues and suggest fixes

## Phase 1: Parse Action

Determine what information to display:

Actions:
- Parse $ARGUMENTS for action: status, validate, or history
- Default to "status" if no argument provided
- Validate action is one of: status, validate, history

## Phase 2: Execute Action

### Action: status

Display current version information:

Actions:
- Check if VERSION file exists
  - If not: Display "❌ Version management not setup - run /versioning:setup"
  - Exit if not found

- Read and parse VERSION file:
  ```json
  {
    "version": "1.2.3",
    "commit": "abc123",
    "build_date": "2025-01-15T10:30:00Z",
    "build_type": "production"
  }
  ```

- Check for version consistency:
  - If pyproject.toml exists: Extract version field
  - If package.json exists: Extract version field
  - Compare all versions - flag mismatches

- Check git tags:
  - Get latest tag: `git describe --tags --abbrev=0 --match "v*" 2>/dev/null`
  - Compare with VERSION file version
  - Check if local is behind remote: `git fetch --tags && git tag -l`

- Check for pending commits:
  - Count commits since last tag: `git rev-list <last_tag>..HEAD --count`
  - Categorize by type (feat:, fix:, etc.)

- Display formatted status:
  ```
  📦 Version Status
  
  Current Version: 1.2.3
  Build Type: production
  Last Build: 2025-01-15 10:30:00 UTC
  Git Commit: abc123 (short)
  
  📊 Version Consistency:
  ✓ VERSION file: 1.2.3
  ✓ pyproject.toml: 1.2.3
  ✓ package.json: 1.2.3
  ✓ Latest git tag: v1.2.3
  
  📝 Pending Changes:
  - 3 commits since last release
    - 2 feat: (minor bump ready)
    - 1 fix: (patch bump ready)
  
  💡 Next Release: 1.3.0 (minor)
  
  🔗 Workflow:
  - Status: https://github.com/<owner>/<repo>/actions/workflows/version-management.yml
  
  Commands:
  - Bump version: /versioning:bump minor
  - View history: /versioning:info history
  - Validate setup: /versioning:info validate
  ```

### Action: validate

Validate version management configuration:

Actions:
- Check VERSION file:
  - Exists ✓/✗
  - Valid JSON ✓/✗
  - Has required fields (version, commit, build_date, build_type) ✓/✗
  - Version matches semver format ✓/✗

- Check project manifests:
  - pyproject.toml version field ✓/✗
  - package.json version field ✓/✗
  - Versions match VERSION file ✓/✗

- Check GitHub Actions:
  - `.github/workflows/version-management.yml` exists ✓/✗
  - Workflow has correct triggers (push to main/master) ✓/✗
  - Has semantic-release configuration ✓/✗

- Check git configuration:
  - Is git repository ✓/✗
  - Git user.name configured ✓/✗
  - Git user.email configured ✓/✗
  - Has at least one commit ✓/✗
  - Remote origin configured ✓/✗

- Check GitHub secrets (via workflow runs):
  - PYPI_TOKEN or NPM_TOKEN configured ✓/✗/⚠️  (check last workflow run)
  - GITHUB_TOKEN available ✓

- Display validation report:
  ```
  🔍 Version Management Validation
  
  ✅ Core Setup (4/4)
  ✓ VERSION file exists and valid
  ✓ Project manifest has version field
  ✓ Versions are consistent
  ✓ Git repository configured
  
  ✅ GitHub Actions (3/3)
  ✓ Workflow file exists
  ✓ Correct triggers configured
  ✓ Semantic-release setup
  
  ⚠️  Secrets Configuration (1/2)
  ✓ GITHUB_TOKEN available
  ✗ PYPI_TOKEN not configured or failing
    → Add at: https://github.com/<owner>/<repo>/settings/secrets/actions
  
  Overall Status: ⚠️  PARTIAL - Secrets needed
  
  🔧 Required Actions:
  1. Add PYPI_TOKEN secret to GitHub
  2. Test workflow: git push (with feat: or fix: commit)
  
  📚 Documentation:
  - Setup guide: /versioning:setup --help
  - PyPI tokens: https://pypi.org/manage/account/token/
  ```

### Action: history

Display version history:

Actions:
- Get all version tags: `git tag -l "v*" --sort=-version:refname`
- For each tag (limit to last 10):
  - Get tag date: `git log -1 --format=%ai <tag>`
  - Get tag annotation: `git tag -n9 <tag>`
  - Extract changelog summary from annotation
  - Format display

- Show commit timeline:
  - Group by version tag
  - Show commits between tags
  - Categorize by type (feat, fix, etc.)

- Display formatted history:
  ```
  📜 Version History
  
  v1.2.3 - 2025-01-15
  │ Features:
  │  - Add user authentication
  │  - Implement rate limiting
  │ Bug Fixes:
  │  - Fix memory leak in connections
  │ Commits: 5
  
  v1.2.2 - 2025-01-10
  │ Bug Fixes:
  │  - Resolve CORS issues
  │  - Fix validation error
  │ Commits: 2
  
  v1.2.1 - 2025-01-08
  │ Bug Fixes:
  │  - Patch security vulnerability
  │ Commits: 1
  
  v1.2.0 - 2025-01-05
  │ Features:
  │  - Add API versioning
  │  - Implement caching layer
  │ Bug Fixes:
  │  - Fix timeout handling
  │ Commits: 8
  
  ... (6 more versions)
  
  📊 Statistics:
  - Total versions: 10
  - Total commits: 127
  - Average commits per release: 12.7
  - Time span: 45 days
  - Release frequency: ~4 days
  
  Commands:
  - View tag details: git show <tag>
  - Compare versions: git diff v1.2.0..v1.2.3
  ```

## Error Handling

Handle missing components gracefully:

- VERSION file missing → Suggest /versioning:setup
- Not a git repository → Suggest git init
- No git tags → Display "No releases yet"
- Workflow file missing → Suggest /versioning:setup
- Unable to parse VERSION → Display parse error and expected format

Provide helpful error messages with suggested fixes for each scenario.

---
allowed-tools: Bash(*), Read(*), Write(*), Edit(*), Grep(*), Glob(*), AskUserQuestion(*)
description: Setup semantic versioning with validation and templates for Python and TypeScript projects
argument-hint: [python|typescript|javascript]
---

**Arguments**: $ARGUMENTS

Goal: Setup automated semantic versioning with GitHub Actions, conventional commits, and package publishing

Core Principles:
- Detect project type or accept user override
- Validate prerequisites before setup
- Copy appropriate workflow templates
- Create VERSION file and sync with project manifests
- Provide clear next steps for completion

## Phase 1: Detect Project Type

Determine the project type from existing files:

Actions:
- Check for Python indicators:
  - `pyproject.toml` file exists
  - `setup.py` file exists
  - `requirements.txt` file exists
- Check for TypeScript/JavaScript indicators:
  - `package.json` file exists
  - `tsconfig.json` file exists (TypeScript)
  - No tsconfig = JavaScript
- If $ARGUMENTS provided, use that as override
- If no indicators found, ask user which type

## Phase 2: Validate Prerequisites

Check that required components exist:

Actions:
- Verify this is a git repository: `git rev-parse --git-dir`
- Check git configuration:
  - `git config user.name` - must be set
  - `git config user.email` - must be set
- For Python projects:
  - Verify `pyproject.toml` exists with `[project]` section
  - Check for `version` field in pyproject.toml
- For TypeScript/JavaScript projects:
  - Verify `package.json` exists
  - Check for `version` field in package.json
- Verify no existing VERSION file (or ask to overwrite)
- Check if `.github/workflows` directory exists (create if not)

If any prerequisite fails, display error and exit with guidance.

## Phase 3: Create VERSION File

Initialize version tracking:

Actions:
- Read current version from project manifest:
  - Python: Extract from `pyproject.toml` version field
  - TypeScript/JavaScript: Extract from `package.json` version field
  - Default to "0.1.0" if not found
- Create VERSION file with JSON structure:
  ```json
  {
    "version": "<current_version>",
    "commit": "initial",
    "build_date": "<current_iso_timestamp>",
    "build_type": "development"
  }
  ```
- Verify VERSION file created successfully

## Phase 4: Create GitHub Actions Workflow

Copy and configure the appropriate workflow template:

Actions:
- Create `.github/workflows` directory if it doesn't exist
- For Python projects:
  - Create `.github/workflows/version-management.yml` with Python/PyPI workflow
  - Workflow includes: semantic-release, version bump, PyPI upload
- For TypeScript/JavaScript projects:
  - Create `.github/workflows/version-management.yml` with npm workflow
  - Workflow includes: semantic-release, version bump, npm publish

Workflow content based on project type:

**Python Workflow Template:**
```yaml
name: Version Management

on:
  push:
    branches: [ main, master ]

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'

    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
        token: ${{ secrets.GITHUB_TOKEN }}

    - uses: actions/setup-node@v4
      with:
        node-version: '20'

    - uses: actions/setup-python@v4
      with:
        python-version: '3.9'

    - name: Install semantic-release
      run: |
        npm install --no-save \
          semantic-release \
          @semantic-release/changelog \
          @semantic-release/git \
          @semantic-release/github \
          @semantic-release/exec

    - name: Update VERSION and release
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
      run: |
        cat > .releaserc.json << 'RELEASE_EOF'
        {
          "branches": ["main", "master"],
          "plugins": [
            "@semantic-release/commit-analyzer",
            "@semantic-release/release-notes-generator",
            [
              "@semantic-release/exec",
              {
                "prepareCmd": "node -e \"const fs = require('fs'); const versionData = { version: '${nextRelease.version}', commit: process.env.GITHUB_SHA, build_date: new Date().toISOString(), build_type: 'production' }; fs.writeFileSync('VERSION', JSON.stringify(versionData, null, 2)); const pyproject = fs.readFileSync('pyproject.toml', 'utf8'); const updatedPyproject = pyproject.replace(/version = \\\".+\\\"/, 'version = \\\"${nextRelease.version}\\\"'); fs.writeFileSync('pyproject.toml', updatedPyproject);\"",
                "publishCmd": "pip install --upgrade pip build twine && python -m build && python -m twine upload dist/* --username __token__ --password $PYPI_TOKEN"
              }
            ],
            [
              "@semantic-release/git",
              {
                "assets": ["VERSION", "pyproject.toml", "CHANGELOG.md"],
                "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
              }
            ],
            "@semantic-release/changelog",
            "@semantic-release/github"
          ]
        }
        RELEASE_EOF
        
        npx semantic-release
```

**TypeScript/JavaScript Workflow Template:**
```yaml
name: Version Management

on:
  push:
    branches: [ main, master ]

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'

    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
        token: ${{ secrets.GITHUB_TOKEN }}

    - uses: actions/setup-node@v4
      with:
        node-version: '20'

    - name: Install dependencies
      run: npm ci

    - name: Install semantic-release
      run: |
        npm install --no-save \
          semantic-release \
          @semantic-release/changelog \
          @semantic-release/git \
          @semantic-release/github \
          @semantic-release/npm

    - name: Update VERSION and release
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
      run: |
        cat > .releaserc.json << 'RELEASE_EOF'
        {
          "branches": ["main", "master"],
          "plugins": [
            "@semantic-release/commit-analyzer",
            "@semantic-release/release-notes-generator",
            [
              "@semantic-release/exec",
              {
                "prepareCmd": "node -e \"const fs = require('fs'); const versionData = { version: '${nextRelease.version}', commit: process.env.GITHUB_SHA, build_date: new Date().toISOString(), build_type: 'production' }; fs.writeFileSync('VERSION', JSON.stringify(versionData, null, 2));\""
              }
            ],
            "@semantic-release/npm",
            [
              "@semantic-release/git",
              {
                "assets": ["VERSION", "package.json", "package-lock.json", "CHANGELOG.md"],
                "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
              }
            ],
            "@semantic-release/changelog",
            "@semantic-release/github"
          ]
        }
        RELEASE_EOF
        
        npx semantic-release
```

## Phase 5: Display Setup Summary

Show results and next steps:

Actions:
- Display setup confirmation:
  ```
  ✅ Version Management Setup Complete

  Project Type: <detected_type>
  Initial Version: <current_version>

  📦 Files Created:
  - VERSION
  - .github/workflows/version-management.yml

  ⚠️  Manual Configuration Required:
  
  1. Add GitHub Secret for package publishing:
     - For Python: Add PYPI_TOKEN
     - For TypeScript/JavaScript: Add NPM_TOKEN
     
  2. Go to: https://github.com/<owner>/<repo>/settings/secrets/actions
     - Click "New repository secret"
     - Name: PYPI_TOKEN (or NPM_TOKEN)
     - Value: Your token from PyPI.org or npmjs.com
  
  3. Configure git to handle releases:
     git config --local pull.rebase false
  
  📖 Commit Message Format:
  - feat: New feature (minor version bump)
  - fix: Bug fix (patch version bump)
  - BREAKING CHANGE: Breaking change (major version bump)
  - docs/chore/ci: No version bump
  
  🚀 Next Steps:
  1. Commit setup files:
     git add VERSION .github/workflows/version-management.yml
     git commit -m "feat: setup automated version management"
  
  2. Push to trigger first release:
     git push origin main
  
  3. Check workflow status:
     gh run list --workflow=version-management.yml
  
  4. Use version commands:
     /versioning:info status
     /versioning:bump patch --dry-run
  
  📚 Documentation:
  - Conventional Commits: https://www.conventionalcommits.org/
  - Semantic Release: https://semantic-release.gitbook.io/
  ```

## Error Handling

If any step fails:
- Display clear error message with context
- Provide troubleshooting guidance
- Suggest corrective actions
- Exit gracefully without partial setup

Common errors:
- Not a git repository → Run `git init`
- Missing git config → Run `git config user.name/email`
- No project manifest → Create pyproject.toml or package.json first
- VERSION file exists → Use `--force` flag or remove manually

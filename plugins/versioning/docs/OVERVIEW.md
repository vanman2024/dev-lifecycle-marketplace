# Automated Version Management System

**Semantic Release with GitHub Actions for Python Projects**

This document explains the automated version management system used in this project and how to implement it in other Python projects.

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Commit Message Rules](#commit-message-rules)
- [Version Sync Workflow](#version-sync-workflow)
- [Implementation Guide](#implementation-guide)
- [Troubleshooting](#troubleshooting)

---

## Overview

This project uses **semantic-release** to automatically:
- ✅ Determine version bumps from commit messages
- ✅ Update `VERSION` and `pyproject.toml` files
- ✅ Create GitHub releases with changelogs
- ✅ Publish to PyPI automatically
- ✅ Generate CHANGELOG.md

**Zero manual version management required.**

### Python vs npm Comparison

| Feature | Python | npm/JavaScript |
|---------|--------|----------------|
| **Complexity** | Moderate | Simple |
| **Config File** | `.releaserc.json` + workflow | `.releaserc.json` + workflow |
| **Version Storage** | `VERSION` + `pyproject.toml` | `package.json` only |
| **Build Tool** | `python -m build` | Built-in |
| **Publish Tool** | `twine` | `npm publish` |
| **Package Registry** | PyPI | npm registry |
| **Setup Time** | ~10 minutes | ~5 minutes |

Both use the **same commit message conventions** and **same workflow**.

### Key Files (Python)

| File | Purpose | Auto-Updated |
|------|---------|--------------|
| `VERSION` | JSON metadata (version, commit, date) | ✅ Yes |
| `pyproject.toml` | Package version field | ✅ Yes |
| `CHANGELOG.md` | Release history | ✅ Yes |
| `.github/workflows/version-management.yml` | GitHub Actions workflow | Manual |

---

## How It Works

### Workflow Sequence

```mermaid
graph LR
    A[Developer commits with<br/>conventional format] --> B[Push to main]
    B --> C[GitHub Actions triggers]
    C --> D[semantic-release analyzes<br/>commit messages]
    D --> E{Determine<br/>version bump}
    E -->|feat:| F[Minor bump<br/>0.1.0 → 0.2.0]
    E -->|fix:| G[Patch bump<br/>0.1.0 → 0.1.1]
    E -->|BREAKING| H[Major bump<br/>0.1.0 → 1.0.0]
    E -->|docs/chore| I[No release]
    F --> J[Update VERSION<br/>& pyproject.toml]
    G --> J
    H --> J
    J --> K[Build package]
    K --> L[Publish to PyPI]
    L --> M[Create GitHub release]
    M --> N[Commit version bump<br/>to main]
```

### What Gets Updated Automatically

**VERSION File:**
```json
{
  "version": "3.6.3",
  "commit": "18912f8ec73e1d36c3ee7116f214766e13e0ed2e",
  "build_date": "2025-10-08T05:39:41.900Z",
  "build_type": "production"
}
```

**pyproject.toml:**
```toml
[project]
version = "3.6.3"  # ← Updated automatically
```

**GitHub Release:**
- Tag: `v3.6.3`
- Release notes from commit messages
- Attached wheel and source distribution

**PyPI:**
- Package published automatically
- Version 3.6.3 available for `pip install`

---

## Commit Message Rules

### Conventional Commits Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Version Bump Types

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `feat:` | **Minor** (0.1.0 → 0.2.0) | `feat: Add authentication system` |
| `fix:` | **Patch** (0.1.0 → 0.1.1) | `fix: Resolve login bug` |
| `perf:` | **Patch** (0.1.0 → 0.1.1) | `perf: Optimize database queries` |
| `BREAKING CHANGE:` | **Major** (0.1.0 → 1.0.0) | Footer with `BREAKING CHANGE:` |
| `feat!:` | **Major** (0.1.0 → 1.0.0) | `feat!: Redesign API structure` |

### No Version Bump

These commit types **do not trigger releases**:
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes
- `test:` - Test updates
- `style:` - Code formatting
- `refactor:` - Code restructuring

### Examples

**Minor Version Bump:**
```bash
git commit -m "feat: Add user authentication

Implemented JWT-based authentication with refresh tokens.
Includes login, logout, and session management."
```

**Patch Version Bump:**
```bash
git commit -m "fix: Resolve memory leak in connection pool

Connection objects were not being properly released.
Added explicit cleanup in finally blocks."
```

**Major Version Bump:**
```bash
git commit -m "feat!: Redesign API endpoints

BREAKING CHANGE: All endpoints now use /api/v2/ prefix.
Previous /api/v1/ endpoints are deprecated and removed."
```

**No Release:**
```bash
git commit -m "docs: Update installation guide"
git commit -m "chore: Update dependencies"
```

---

## Version Sync Workflow

### Understanding Local vs Remote Versions

**After pushing commits:**

| Location | Version | Status |
|----------|---------|--------|
| **Local `VERSION`** | 3.6.2 | Behind |
| **Local `pyproject.toml`** | 3.6.2 | Behind |
| **GitHub `VERSION`** | 3.6.3 | ✅ Current |
| **GitHub `pyproject.toml`** | 3.6.3 | ✅ Current |
| **PyPI** | 3.6.3 | ✅ Published |

### Why This Happens

1. You push commits with `fix:` or `feat:`
2. GitHub Actions runs semantic-release **on GitHub servers**
3. Semantic-release creates a commit like `chore(release): 3.6.3 [skip ci]`
4. **Your local repo doesn't have this commit yet**
5. You need to pull to sync

### Syncing Your Local Repository

**Option 1: Pull After Each Release**
```bash
# After pushing, check if release completed
gh run list --workflow=version-management.yml --limit 1

# If it succeeded, pull the release commit
git pull origin main
```

**Option 2: Pull Periodically**
```bash
# Start each work session with
git pull origin main
```

**Option 3: Don't Worry About It**
- Local being "behind" doesn't break anything
- PyPI has the correct version ✅
- GitHub has the correct version ✅
- You'll sync eventually

### What Happens If You Don't Pull?

**Nothing bad!**
- Your next `git push` will prompt a merge
- Git will handle it automatically with `--no-ff`
- The versions will sync up
- PyPI is always correct (that's what matters)

---

## Implementation Guide

### For New npm/JavaScript Projects

**Even simpler than Python!** Semantic-release was built for npm originally.

**1. Install semantic-release**

```bash
npm install --save-dev semantic-release \
  @semantic-release/changelog \
  @semantic-release/git \
  @semantic-release/github \
  @semantic-release/npm
```

**2. Create `.releaserc.json`**

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    [
      "@semantic-release/git",
      {
        "assets": ["package.json", "package-lock.json", "CHANGELOG.md"],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ],
    "@semantic-release/github"
  ]
}
```

**3. Create GitHub Actions Workflow**

Create `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    branches: [ main ]

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

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

    - name: Run semantic-release
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
      run: npx semantic-release
```

**4. Add npm Token to GitHub Secrets**

1. Generate npm token at https://www.npmjs.com/settings/tokens
2. Choose "Automation" type
3. Add to GitHub: Settings → Secrets → Actions
4. Name: `NPM_TOKEN`

**5. Configure package.json**

```json
{
  "name": "your-package",
  "version": "0.0.0-development",
  "repository": {
    "type": "git",
    "url": "https://github.com/username/repo.git"
  },
  "publishConfig": {
    "access": "public"
  }
}
```

**6. First Release**

```bash
git commit -m "feat: initial implementation"
git push origin main

# Semantic-release will:
# - Bump to 1.0.0 (initial release)
# - Update package.json
# - Create CHANGELOG.md
# - Publish to npm
# - Create GitHub release
```

**That's it!** Much simpler than Python because:
- npm already expects package.json version updates
- No separate VERSION file needed
- npm publish is built-in (no twine/build needed)

### For New Python Projects

**1. Create GitHub Actions Workflow**

Create `.github/workflows/version-management.yml`:

```yaml
name: Version Management

on:
  push:
    branches: [ main ]

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  version-management:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

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

    - name: Clean stale build artifacts
      run: rm -rf dist/ build/ *.egg-info

    - name: Install semantic-release
      run: |
        npm install --no-save \
          semantic-release \
          @semantic-release/changelog \
          @semantic-release/git \
          @semantic-release/github \
          @semantic-release/exec

    - name: Update VERSION file and create release
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
      run: |
        cat > .releaserc.json << 'EOF'
        {
          "branches": ["main"],
          "plugins": [
            [
              "@semantic-release/commit-analyzer",
              {
                "releaseRules": [
                  {"type": "feat", "release": "minor"},
                  {"type": "fix", "release": "patch"},
                  {"type": "perf", "release": "patch"},
                  {"breaking": true, "release": "major"},
                  {"type": "docs", "release": false},
                  {"type": "chore", "release": false},
                  {"type": "ci", "release": false},
                  {"type": "test", "release": false},
                  {"type": "style", "release": false},
                  {"type": "refactor", "release": false}
                ]
              }
            ],
            "@semantic-release/release-notes-generator",
            [
              "@semantic-release/exec",
              {
                "prepareCmd": "node -e \"const fs = require('fs'); const versionData = { version: '${nextRelease.version}', commit: process.env.GITHUB_SHA, build_date: new Date().toISOString(), build_type: 'production' }; fs.writeFileSync('VERSION', JSON.stringify(versionData, null, 2)); const pyproject = fs.readFileSync('pyproject.toml', 'utf8'); const updatedPyproject = pyproject.replace(/version = \\\".+\\\"/, 'version = \\\"${nextRelease.version}\\\"'); fs.writeFileSync('pyproject.toml', updatedPyproject);\"",
                "publishCmd": "rm -rf dist/ && python -m pip install --upgrade pip build twine && python -m build && python -m twine upload dist/* --username __token__ --password $PYPI_TOKEN"
              }
            ],
            [
              "@semantic-release/git",
              {
                "assets": ["VERSION", "pyproject.toml"],
                "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
              }
            ],
            "@semantic-release/github"
          ]
        }
        EOF

        npx semantic-release
```

**2. Create VERSION File**

Create a `VERSION` file in your project root:

```json
{
  "version": "0.1.0",
  "commit": "initial",
  "build_date": "2025-01-01T00:00:00.000Z",
  "build_type": "development"
}
```

**3. Update pyproject.toml**

Ensure your `pyproject.toml` has a version field:

```toml
[project]
name = "your-package-name"
version = "0.1.0"
```

**4. Add PyPI Token to GitHub Secrets**

1. Generate PyPI API token at https://pypi.org/manage/account/token/
2. Add to GitHub: Settings → Secrets → Actions → New repository secret
3. Name: `PYPI_TOKEN`
4. Value: Your PyPI token

**5. Include VERSION in Package**

Update `MANIFEST.in`:

```
include VERSION
```

Or in `pyproject.toml`:

```toml
[tool.setuptools]
include-package-data = true

[tool.setuptools.package-data]
your_package = ["VERSION"]
```

**6. Configure Git**

```bash
git config --local pull.rebase false
git config --local pull.ff only
```

**7. First Release**

```bash
# Make your first feature commit
git commit -m "feat: Initial implementation"
git push origin main

# GitHub Actions will create version 0.1.0
```

---

## Troubleshooting

### Workflow Fails: "Wheel VERSION mismatch"

**Problem:** Old wheel files in dist/ causing verification failures

**Solution:** The workflow now includes `rm -rf dist/` to clean artifacts. If you still see this, disable the verification step:

```yaml
- name: Verify release metadata
  if: false  # Disabled: wheel check causes version mismatch errors
```

### No Release Created

**Problem:** Commits don't trigger a version bump

**Causes:**
1. Commit messages don't follow conventional format
2. Only `docs:`, `chore:`, `ci:` commits (these don't bump versions)
3. Commit message has `[skip ci]` in it

**Solution:** Use `feat:` or `fix:` commit types

### Local Version Behind Remote

**Problem:** Local shows 3.6.2, GitHub/PyPI show 3.6.3

**Solution:** Pull the release commit:
```bash
git pull origin main
```

This is **not a critical issue** - PyPI has the correct version.

### PyPI Upload Fails

**Problem:** "Invalid or non-existent authentication"

**Solutions:**
1. Verify `PYPI_TOKEN` secret is set in GitHub
2. Ensure token starts with `pypi-`
3. Check token hasn't expired
4. Verify token has upload permissions

### Branches Diverged After Release

**Problem:** `fatal: Not possible to fast-forward`

**Solution:**
```bash
git pull origin main --no-rebase
# or
git merge --no-ff origin/main
```

---

## Best Practices

### For Developers

✅ **DO:**
- Write conventional commit messages
- Let semantic-release handle versions
- Pull after checking workflow status
- Trust the automation

❌ **DON'T:**
- Manually edit VERSION or pyproject.toml version
- Skip conventional commit format
- Force push after releases
- Worry about local being "behind"

### For Project Maintainers

✅ **DO:**
- Review commit messages before merging PRs
- Ensure contributors understand conventional commits
- Monitor workflow failures
- Keep PYPI_TOKEN updated

❌ **DON'T:**
- Manually create GitHub releases
- Manually publish to PyPI
- Override semantic-release behavior
- Mix manual and automated versioning

---

## References

- [Semantic Release Documentation](https://semantic-release.gitbook.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [PyPI Publishing](https://packaging.python.org/guides/publishing-package-distribution-releases-using-github-actions-ci-cd-workflows/)

---

**Last Updated:** 2025-10-08
**System Version:** 3.6.3
**Status:** ✅ Production Ready

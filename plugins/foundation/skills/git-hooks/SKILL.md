# Git Hooks Skill

Standardized git hooks for security and quality enforcement across all projects.

## Description

Provides pre-configured git hooks that enforce:
- **Secret scanning**: Prevents committing API keys, tokens, passwords
- **Commit message validation**: Enforces conventional commit format
- **Security checks**: Runs dependency audits before pushing

## Hook Templates

Located in `templates/` directory:
- `pre-commit` - Secret and key scanning
- `commit-msg` - Conventional commit format validation
- `pre-push` - Security scans (npm audit, safety check)

## Installation Script

Use `scripts/install-hooks.sh` to install hooks into any git repository.

## Usage

```bash
# Install all hooks
bash plugins/foundation/skills/git-hooks/scripts/install-hooks.sh

# Install to specific project
bash plugins/foundation/skills/git-hooks/scripts/install-hooks.sh /path/to/project
```

## What Gets Checked

### Secret Scanning (pre-commit)
- AWS Access Keys (AKIA...)
- OpenAI API Keys (sk-...)
- Bearer Tokens
- Database Connection Strings
- Private Keys
- Generic API Keys and Secrets

### Commit Message (commit-msg)
Format: `type(scope): description`

Valid types:
- feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert

### Security Checks (pre-push)
- npm audit (Node.js projects)
- safety check (Python projects)
- Debug statement detection

## Bypass

Hooks can be bypassed when necessary:
```bash
git commit --no-verify
git push --no-verify
```

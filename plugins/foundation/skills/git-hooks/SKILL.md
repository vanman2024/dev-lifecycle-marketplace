# Git Hooks Skill

Standardized git hooks for security and quality enforcement across all projects.

## Description

Provides two-layer security protection:

**Layer 1: Local Git Hooks** (runs on developer machine)
- **Secret scanning**: Prevents committing API keys, tokens, passwords
- **Commit message validation**: Enforces conventional commit format
- **Security checks**: Runs dependency audits before pushing

**Layer 2: GitHub Actions Workflow** (runs on server)
- **Automated security scanning**: Runs on every push/PR
- **Weekly scheduled scans**: Mondays at 2 AM
- **Cannot be bypassed**: Server-side enforcement
- **Comprehensive reporting**: Generates security reports and PR comments

## Components

### Local Hook Templates

Located in `templates/` directory:
- `pre-commit` - Secret and key scanning
- `commit-msg` - Conventional commit format validation
- `pre-push` - Security scans (npm audit, safety check)

### GitHub Actions Workflow

Located in `templates/`:
- `github-security-workflow.yml` - Automated security scanning pipeline

### Security Scripts Integration

The GitHub workflow uses security scanning scripts from:
**Source:** `plugins/quality/skills/security-patterns/scripts/`

The installation script copies these to the project's `scripts/` directory:
- `scan-secrets.sh` - Comprehensive secret detection
- `scan-dependencies.sh` - Dependency vulnerability scanning
- `scan-owasp.sh` - OWASP security pattern detection
- `generate-security-report.sh` - Security report generation

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

### Secret Scanning (Local Hooks + GitHub Actions)

**AI/ML Platform Keys:**
- Airtable API Keys (key*, pat*)
- Anthropic API Keys (sk-ant-...)
- OpenAI API Keys (sk-...)
- Context7 API Keys (ctx7-...)

**Cloud Provider Keys:**
- AWS Access Keys (AKIA..., ASIA...)
- Google Cloud API Keys (AIza...)
- Azure Connection Strings

**Source Control:**
- GitHub Personal Access Tokens (ghp_...)
- GitHub OAuth Tokens (gho_...)
- GitHub App Secrets (ghs_...)

**Database:**
- PostgreSQL Connection Strings
- MySQL Connection Strings
- MongoDB Connection Strings
- Supabase Keys (supabase_...)

**Payment/Communication:**
- Stripe API Keys (sk_live_...)
- Slack Tokens & Webhooks
- Twilio API Keys
- SendGrid API Keys
- Mailgun API Keys

**Other:**
- JWT Tokens
- Private Keys (RSA, SSH, PGP, EC)
- Bearer Tokens
- Generic API Keys and Secrets
- NPM/PyPI Tokens

### Commit Message (commit-msg)
Format: `type(scope): description`

Valid types:
- feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert

### Security Checks (pre-push)
- npm audit (Node.js projects)
- safety check (Python projects)
- Debug statement detection

## Safe Placeholders

The secret scanner intelligently skips safe placeholder patterns:

✅ **Allowed patterns:**
```bash
AIRTABLE_API_KEY=your_airtable_key_here
OPENAI_API_KEY=your_key_here
API_KEY=placeholder
SECRET_TOKEN=example
DATABASE_URL=TODO
```

❌ **Blocked patterns (examples of what NOT to commit):**
```bash
# Example of blocked pattern - DO NOT use real keys:
AIRTABLE_API_KEY=your_airtable_key_here
OPENAI_API_KEY=your_openai_key_here
```

Files ending in `.env.example` are treated leniently if they contain placeholder indicators.

## Bypass

**Local hooks** can be bypassed when necessary (not recommended):
```bash
git commit --no-verify
git push --no-verify
```

**GitHub Actions** cannot be bypassed - they run on the server for every push/PR.

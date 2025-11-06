---
description: Complete GitHub repository initialization with gh CLI - creates repo, configures settings, branch protection, templates, and integrates with hooks-setup and CI/CD
argument-hint: [repo-name] [--public|--private] [--org=org-name]
allowed-tools: Bash, Read, Write, Glob, Grep, AskUserQuestion, TodoWrite
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

Goal: Complete GitHub repository initialization and configuration using gh CLI, creating a production-ready repository with security, quality, and deployment automation

Core Principles:
- GitHub CLI first - automate everything possible with gh
- Security by default - hooks, scanning, branch protection
- Integration ready - connects with hooks-setup and CI/CD
- Detect and adapt - use existing project structure if present

## Available Skills

This command has access to the following skills from the foundation plugin:

- **environment-setup**: Environment verification, tool checking, version validation, and path configuration. Use when checking system requirements, verifying tool installations, validating versions, checking PATH configuration, or when user mentions environment setup, system check, tool verification, version check, missing tools, or installation requirements.
- **project-detection**: Comprehensive tech stack detection, framework identification, dependency analysis, and project.json generation. Use when analyzing project structure, detecting frameworks, identifying dependencies, discovering AI stack components, detecting databases, or when user mentions project detection, tech stack analysis, framework discovery, or project.json generation.

**To use a skill:**
```
!{skill skill-name}
```

---

Phase 1: Prerequisites Check
Goal: Verify gh CLI is installed and authenticated

Actions:
- Create comprehensive todo list using TodoWrite for all phases
- Check if gh CLI is installed:
  - !{bash which gh && echo "✓ gh CLI installed" || echo "✗ gh CLI not installed"}
- If gh not installed, provide installation instructions:
  - macOS: `brew install gh`
  - Linux: `curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && sudo apt update && sudo apt install gh`
- Check gh authentication status:
  - !{bash gh auth status 2>&1}
- If not authenticated, inform user to run: `gh auth login`
- Update todos

Phase 2: Project Discovery
Goal: Understand current project state and gather repository details

Actions:
- Parse $ARGUMENTS for:
  - Repository name (required if not in git repo)
  - Visibility flag: --public or --private (default: ask user)
  - Organization: --org=org-name (optional)
- Check if already in a git repository:
  - !{bash git rev-parse --is-inside-work-tree 2>/dev/null && echo "Yes" || echo "No"}
- If in git repo, check for remote:
  - !{bash git remote -v}
- If remote exists, check if it's a GitHub repo:
  - !{bash gh repo view --json nameWithOwner 2>/dev/null || echo "No GitHub repo"}
- Get current directory name as default repo name:
  - !{bash basename "$(pwd)"}
- Detect project tech stack:
  - !{bash ls -1 package.json pyproject.toml Cargo.toml go.mod pom.xml build.gradle 2>/dev/null}
- Update todos

Phase 3: Gather Repository Configuration
Goal: Collect necessary information for repository creation

Actions:
- If repository name not provided in $ARGUMENTS, use directory name or ask user
- If visibility not specified in $ARGUMENTS, use AskUserQuestion:
  - "Should this repository be public or private?"
  - Options: "Public (open source)", "Private (restricted access)"
- If --org flag provided, validate organization access:
  - !{bash gh api orgs/$ORG_NAME 2>/dev/null && echo "✓ Access to $ORG_NAME" || echo "✗ No access to $ORG_NAME"}
- Confirm repository details with user before creating
- Update todos

Phase 4: Repository Creation
Goal: Create GitHub repository or link existing project

Actions:
- If not in a git repo or no remote exists:
  - Initialize git if needed: !{bash git init}
  - Create GitHub repository with gh CLI:
    - !{bash gh repo create "$REPO_NAME" --$VISIBILITY --description "$DESCRIPTION" --source=. --remote=origin --push}
  - If --org flag provided, use: !{bash gh repo create "$ORG_NAME/$REPO_NAME" ...}
- If in git repo with non-GitHub remote, ask user if they want to:
  - Add GitHub as additional remote
  - Replace existing remote
  - Skip GitHub creation
- Verify repository created:
  - !{bash gh repo view --json nameWithOwner,url,visibility}
- Update todos

Phase 5: Generate .gitignore
Goal: Create comprehensive .gitignore based on detected tech stack

Actions:
- Check if .gitignore already exists:
  - !{bash test -f .gitignore && echo "Exists" || echo "Not found"}
- If doesn't exist or user wants to update:
  - Generate .gitignore based on detected tech stack:
    - Node.js: node_modules/, .env, .env.local, dist/, build/
    - Python: __pycache__/, *.pyc, .venv/, venv/, .env
    - Go: vendor/, *.exe, *.test
    - Rust: target/, Cargo.lock
    - General: .DS_Store, *.log, .vscode/, .idea/
  - **CRITICAL: Always include .env protection:**
    ```
    .env
    .env.local
    .env.*.local
    .env.development
    .env.staging
    .env.production
    !.env.example
    ```
- Create .gitignore with Write tool
- Update todos

Phase 6: Create Repository Templates
Goal: Add issue and PR templates for better collaboration

Actions:
- Create .github/ISSUE_TEMPLATE directory:
  - !{bash mkdir -p .github/ISSUE_TEMPLATE}
- Create bug report template (.github/ISSUE_TEMPLATE/bug_report.md)
- Create feature request template (.github/ISSUE_TEMPLATE/feature_request.md)
- Create pull request template (.github/pull_request_template.md)
- Templates should include:
  - Clear sections (Description, Steps to Reproduce, Expected Behavior)
  - Checkboxes for requirements
  - Labels suggestions
- Update todos

Phase 7: Configure Branch Protection
Goal: Set up branch protection rules for main branch

Actions:
- Get default branch name:
  - !{bash gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'}
- Configure branch protection using gh CLI:
  - !{bash gh api repos/{owner}/{repo}/branches/{branch}/protection -X PUT --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": []
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF}
- Verify protection enabled:
  - !{bash gh api repos/{owner}/{repo}/branches/{branch}/protection}
- Update todos

Phase 8: Repository Settings
Goal: Configure repository settings and features

Actions:
- Enable/disable repository features using gh API:
  - !{bash gh api repos/{owner}/{repo} -X PATCH -f has_issues=true -f has_wiki=false -f has_projects=true -f has_discussions=false}
- Set repository topics based on detected tech stack:
  - Node.js: "nodejs", "javascript", "typescript"
  - Python: "python"
  - Add relevant framework topics
  - !{bash gh repo edit --add-topic topic1 --add-topic topic2}
- Update repository description if not set:
  - !{bash gh repo edit --description "Project description"}
- Update todos

Phase 9: Integration with Foundation Tools
Goal: Set up git hooks and security scanning

Actions:
- Run hooks-setup command to install:
  - Local git hooks (pre-commit, commit-msg, pre-push)
  - GitHub Actions security workflow
  - !{bash bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/git-hooks/scripts/install-hooks.sh}
- Verify hooks installed:
  - !{bash ls -lh .git/hooks/pre-commit .git/hooks/commit-msg .git/hooks/pre-push 2>/dev/null}
- Verify GitHub workflow created:
  - !{bash test -f .github/workflows/security-scan.yml && echo "✓ Security workflow created"}
- Update todos

Phase 10: Initial Commit and Push
Goal: Commit all setup files and push to GitHub

Actions:
- Stage all created files:
  - !{bash git add .gitignore .github/ .env.example 2>/dev/null}
- Check for changes:
  - !{bash git status --short}
- Create initial commit:
  - !{bash git commit -m "chore: Initialize GitHub repository with templates and security

- Add comprehensive .gitignore for detected tech stack
- Add issue and PR templates
- Configure branch protection rules
- Install git hooks and security scanning
- Add .env.example with placeholders

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"}
- Push to GitHub:
  - !{bash git push -u origin $(git branch --show-current)}
- Verify push successful:
  - !{bash gh repo view --web --json url --jq '.url'}
- Update todos

Phase 11: Summary & Next Steps
Goal: Provide comprehensive setup summary and guide

Actions:
- Mark all todos complete
- Display repository setup summary:
  - **Repository:** owner/name
  - **URL:** https://github.com/owner/name
  - **Visibility:** public/private
  - **Default Branch:** main/master
  - **Branch Protection:** ✓ Enabled
  - **Security Scanning:** ✓ Enabled
  - **Git Hooks:** ✓ Installed

- Show what was created:
  - `.gitignore` - Tech stack specific ignore patterns
  - `.env.example` - Environment variable template
  - `.github/ISSUE_TEMPLATE/` - Bug and feature request templates
  - `.github/pull_request_template.md` - PR template
  - `.github/workflows/security-scan.yml` - Security scanning workflow
  - `.git/hooks/` - pre-commit, commit-msg, pre-push hooks

- Branch protection rules:
  - ✓ Require pull request reviews (1 approval)
  - ✓ Dismiss stale reviews
  - ✓ Block force pushes
  - ✓ Block branch deletion

- Next steps:
  1. **Set up CI/CD**: Run `/deployment:setup-cicd` to add deployment automation
  2. **Detect tech stack**: Run `/foundation:detect` to populate .claude/project.json
  3. **Configure environment**: Add your API keys to `.env` (never commit this file)
  4. **Add collaborators**: `gh repo add-collaborator username`
  5. **Create first issue**: `gh issue create --title "Setup project" --body "Initial setup"`
  6. **Enable Discussions** (optional): `gh repo edit --enable-discussions`

- Repository management commands:
  - View repo: `gh repo view --web`
  - List issues: `gh issue list`
  - Create PR: `gh pr create --fill`
  - View workflows: `gh workflow list`
  - Monitor actions: `gh run watch`

- Security features active:
  - Local hooks scan for secrets before commit
  - GitHub Actions runs security scans on push/PR
  - Branch protection prevents accidental force pushes
  - PR reviews required before merging

Your GitHub repository is now fully configured and production-ready! 🚀

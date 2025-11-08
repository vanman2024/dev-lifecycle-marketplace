---
description: Complete GitHub repository initialization with gh CLI - creates repo, configures settings, branch protection, templates, and integrates with hooks-setup and CI/CD
argument-hint: "[repo-name] [--public|--private] [--org=org-name]"
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Arguments**: $ARGUMENTS

Goal: Complete GitHub repository initialization using gh CLI with security, templates, and branch protection

Core Principles:
- GitHub CLI first - automate with gh commands
- Security by default - hooks, scanning, protection
- Integration ready - works with hooks-setup and CI/CD

Phase 1: Prerequisites
Goal: Verify gh CLI installed and authenticated

Actions:
- Create todo list using TodoWrite
- Check gh CLI: !{bash which gh && echo "✓ Installed" || echo "✗ Not installed"}
- Check auth: !{bash gh auth status 2>&1 | grep -q "Logged in" && echo "✓ Authenticated" || echo "✗ Not authenticated"}
- If missing, provide install/auth instructions
- Update todos

Phase 2: Discovery
Goal: Understand project state and gather details

Actions:
- Parse $ARGUMENTS for: repo name, --public/--private, --org=name
- Check git repo: !{bash git rev-parse --is-inside-work-tree 2>/dev/null && echo "Yes" || echo "No"}
- Check remote: !{bash git remote -v 2>/dev/null || echo "None"}
- Get directory name: !{bash basename "$(pwd)"}
- Detect tech stack: !{bash ls -1 package.json pyproject.toml Cargo.toml go.mod 2>/dev/null}
- Update todos

Phase 3: Configuration
Goal: Collect repository information

Actions:
- Use directory name as default repo name if not in $ARGUMENTS
- If visibility not specified, use AskUserQuestion: "Public or Private repository?"
- If --org provided, verify access: !{bash gh api orgs/$ORG 2>/dev/null && echo "✓" || echo "✗"}
- Confirm details with user
- Update todos

Phase 4: Repository Setup
Goal: Create or connect GitHub repository

Actions:
- Check if GitHub repo exists: !{bash gh repo view "$OWNER/$NAME" --json nameWithOwner 2>/dev/null && echo "Exists" || echo "Not found"}
- If repo exists:
  - Ask user: "Repository exists. Connect to it, or skip creation?"
  - If connect: !{bash git remote add origin "https://github.com/$OWNER/$NAME.git" || git remote set-url origin "https://github.com/$OWNER/$NAME.git"}
  - Skip to Phase 5
- If repo doesn't exist:
  - If no git repo: !{bash git init}
  - Create GitHub repo: !{bash gh repo create "$NAME" --$VISIBILITY --description "$DESC" --source=. --remote=origin}
  - If --org: !{bash gh repo create "$ORG/$NAME" --$VISIBILITY --source=.}
- Verify connection: !{bash gh repo view --json nameWithOwner,url}
- Update todos

Phase 5: Generate .gitignore
Goal: Merge comprehensive security-first .gitignore template

Actions:
- Check existing: !{bash test -f .gitignore && echo "Exists" || echo "None"}
- Run smart merge script: !{bash bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/git-hooks/scripts/merge-gitignore.sh}
- Script automatically:
  - Preserves ALL existing entries (no deletions)
  - Adds missing security patterns (.mcp.json, .env, secrets, keys)
  - Creates backup if .gitignore exists
  - Displays what was added
- CRITICAL: .mcp.json, .env, credentials protected
- Update todos

Phase 6: Templates
Goal: Add issue and PR templates

Actions:
- Create directory: !{bash mkdir -p .github/ISSUE_TEMPLATE}
- Create bug_report.md template
- Create feature_request.md template
- Create pull_request_template.md
- Update todos

Phase 7: Branch Protection
Goal: Configure branch protection rules

Actions:
- Get default branch: !{bash gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'}
- Enable protection via gh API:
  - Require PR reviews (1 approval)
  - Dismiss stale reviews
  - Block force pushes and deletions
- Verify: !{bash gh api repos/{owner}/{repo}/branches/{branch}/protection}
- Update todos

Phase 8: Repository Settings
Goal: Configure features and topics

Actions:
- Enable features: !{bash gh api repos/{owner}/{repo} -X PATCH -f has_issues=true -f has_wiki=false}
- Add topics: !{bash gh repo edit --add-topic nodejs --add-topic typescript}
- Update description: !{bash gh repo edit --description "$DESC"}
- Update todos

Phase 9: Security Integration
Goal: Install git hooks and security scanning

Actions:
- Run hooks install script: !{bash bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/git-hooks/scripts/install-hooks.sh}
- Verify hooks: !{bash ls -lh .git/hooks/pre-commit .git/hooks/commit-msg 2>/dev/null}
- Verify workflow: !{bash test -f .github/workflows/security-scan.yml && echo "✓"}
- Update todos

Phase 10: Initial Commit
Goal: Commit setup files and push

Actions:
- Stage files: !{bash git add .gitignore .github/ .env.example 2>/dev/null}
- Check status: !{bash git status --short}
- Commit with message including Claude attribution
- Push: !{bash git push -u origin $(git branch --show-current)}
- Update todos

Phase 11: Summary
Goal: Report setup status and next steps

Actions:
- Mark todos complete
- Display summary:
  - Repository URL and visibility
  - Created files (.gitignore, templates, hooks, workflow)
  - Branch protection status
  - Security features enabled
- Next steps:
  - /deployment:setup-cicd for CI/CD
  - /foundation:detect for tech stack
  - Add API keys to .env
  - gh repo add-collaborator username
- Repository management commands:
  - gh repo view --web
  - gh issue list
  - gh pr create --fill

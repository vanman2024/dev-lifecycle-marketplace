---
allowed-tools: Read, Write, Bash, AskUserQuestion
description: Configure git workflows and conventions
argument-hint: [--hooks] [--templates]
---

**Arguments**: $ARGUMENTS

## Step 1: Check Git Status

Verify git is initialized:

!{git rev-parse --git-dir 2>/dev/null || echo "NOT_GIT_REPO"}

**If NOT_GIT_REPO:**
- Ask user: "Git not initialized. Initialize now?"
- If yes: !{git init}
- If no: Exit with message "Run 'git init' first"

## Step 2: Check Current Configuration

Display current git config:

!{git config --list --local}

## Step 3: Ask User for Workflow Preferences

AskUserQuestion:
- Branch strategy? (feature-branch, git-flow, trunk-based, github-flow)
- Commit convention? (conventional-commits, semantic, custom)
- Setup git hooks? (yes/no)
- Create branch protection? (yes/no)

## Step 4: Configure Branch Strategy

**Feature Branch Workflow:**
- Default branch: main or master
- Feature branches: feature/name
- Hotfix branches: hotfix/name

**Git Flow:**
- Main branches: main, develop
- Feature: feature/name
- Release: release/version
- Hotfix: hotfix/name

**Trunk-Based:**
- Single main branch
- Short-lived feature branches

Set default branch:

!{git symbolic-ref HEAD refs/heads/main 2>/dev/null || echo "Branch already set"}

## Step 5: Setup Commit Convention

**If Conventional Commits chosen:**

Create .gitmessage template:

Write .gitmessage with format:
- type(scope): subject
- Types: feat, fix, docs, style, refactor, test, chore
- Max 50 chars subject
- Blank line, then body
- Blank line, then footer

Configure git to use template:

!{git config --local commit.template .gitmessage}

## Step 6: Create .gitignore

Check if .gitignore exists:

!{test -f .gitignore && echo "EXISTS" || echo "MISSING"}

**If MISSING or --templates flag:**

Detect project type from .claude/project.json if available:

@.claude/project.json

Create .gitignore based on detected framework:
- Node.js: node_modules, .env, dist, build
- Python: __pycache__, .venv, .env, *.pyc
- Rust: target/, Cargo.lock (for apps)
- Go: bin/, vendor/
- Common: .DS_Store, .vscode, .idea, .claude/cache

## Step 7: Setup Git Hooks (Optional)

**If --hooks flag OR user selected yes:**

Create .git/hooks directory structure:

!{mkdir -p .git/hooks}

Create pre-commit hook for:
- Prevent commits to main/master
- Run linter if available
- Check for secrets/API keys

Create commit-msg hook for:
- Validate commit message format
- Enforce character limits

Make hooks executable:

!{chmod +x .git/hooks/pre-commit .git/hooks/commit-msg}

## Step 8: Configure Branch Protection

**If user selected branch protection:**

Display: "Branch protection rules (for GitHub/GitLab):"
- Require pull request reviews
- Require status checks to pass
- Require up-to-date branches
- No force pushes to main

Note: These must be configured in GitHub/GitLab UI or via API

## Step 9: Setup Git Aliases

Configure useful aliases:

!{git config --local alias.co checkout}
!{git config --local alias.br branch}
!{git config --local alias.ci commit}
!{git config --local alias.st status}
!{git config --local alias.unstage 'reset HEAD --'}
!{git config --local alias.last 'log -1 HEAD'}
!{git config --local alias.visual 'log --graph --oneline --all'}

## Step 10: Display Setup Summary

Show configured settings:
- Branch strategy selected
- Commit convention configured
- Git hooks installed (if applicable)
- Aliases created
- .gitignore created/updated

**Configuration complete!**

Next steps:
- Review .gitignore for project-specific needs
- Customize git hooks in .git/hooks/
- Set up remote: git remote add origin URL
- Push to remote: git push -u origin main

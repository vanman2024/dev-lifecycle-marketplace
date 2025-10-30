---
name: Git Workflows
description: Git commit patterns, branch helpers, and workflow automation. Use when working with git, creating commits, managing branches, setting up git hooks, or when user mentions git workflows, commit conventions, branch management, or git automation.
allowed-tools: Read(*), Bash(git:*), Write(*)
---

# Git Workflows

This skill provides git workflow patterns, commit message templates, branch management helpers, and git hook scripts.

## What This Skill Provides

### 1. Commit Message Templates
- Conventional commits format
- Semantic commit structure
- Custom commit templates

### 2. Branch Management Scripts
- `create-branch.sh` - Create feature/hotfix/release branches
- `check-branch.sh` - Validate branch naming conventions
- `sync-branch.sh` - Sync branches with remote

### 3. Git Hook Templates
- pre-commit: Lint, format, secret scanning
- commit-msg: Message format validation
- pre-push: Test execution

### 4. Workflow Patterns
- Feature branch workflow
- Git Flow
- Trunk-based development
- GitHub Flow

## Instructions

### For Commit Messages

When user asks for commit message help:

1. Analyze staged changes with: git diff --staged
2. Use conventional commit format:
   - feat: New feature
   - fix: Bug fix
   - docs: Documentation
   - style: Formatting
   - refactor: Code restructuring
   - test: Testing
   - chore: Maintenance

3. Format: type(scope): subject (max 50 chars)

### For Branch Management

Execute branch helper scripts:

!{bash plugins/01-core/skills/git-workflows/scripts/create-branch.sh feature my-feature}
!{bash plugins/01-core/skills/git-workflows/scripts/check-branch.sh}

### For Git Hooks

Provide hook templates from templates/ directory:
- Copy to .git/hooks/
- Make executable
- Customize for project needs

## Conventional Commit Examples

**Feature:**
feat(auth): add JWT authentication system

**Bug Fix:**
fix(api): resolve memory leak in data processor

**Documentation:**
docs(readme): update installation instructions

**Refactoring:**
refactor(db): optimize query performance

## Success Criteria

- ✅ Commit messages follow conventions
- ✅ Branch names are valid and descriptive
- ✅ Git hooks prevent bad commits
- ✅ Workflow matches team standards

---

**Plugin**: 01-core
**Skill Type**: Helper + Templates
**Auto-invocation**: Yes (via description matching)

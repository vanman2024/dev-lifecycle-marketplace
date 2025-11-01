---
description: Install standardized git hooks (secret scanning, commit message validation, security checks)
argument-hint: [project-path]
allowed-tools: Read, Write, Bash, Glob
---

**Arguments**: $ARGUMENTS

Goal: Install standardized git hooks into the project to enforce security best practices (secret scanning), commit message conventions (conventional commits), and basic code security checks

Core Principles:
- Security first - prevent secrets from being committed
- Enforce conventions - validate commit messages
- Tech-agnostic - works with any language/framework
- Non-invasive - hooks can be bypassed with --no-verify if needed

## Phase 1: Discovery

Goal: Understand the project and git repository setup

Actions:
- Parse $ARGUMENTS for project path (default: current directory)
- Check if this is a git repository:
  - !{bash git rev-parse --git-dir 2>/dev/null || echo "Not a git repo"}
- Locate .git/hooks directory:
  - !{bash ls -la .git/hooks/ 2>/dev/null | head -10}
- Check for existing hooks that might be overwritten:
  - !{bash ls .git/hooks/pre-commit .git/hooks/commit-msg .git/hooks/pre-push 2>/dev/null || echo "No existing hooks"}

## Phase 2: Execution

Goal: Install git hook scripts using installation script

Actions:
- Get the marketplace plugin directory to locate hook templates
- Run the installation script:
  - !{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/git-hooks/scripts/install-hooks.sh}
- Installation script will:
  - Copy hook templates from skills/git-hooks/templates/
  - Install pre-commit, commit-msg, and pre-push hooks
  - Make them executable
  - Display confirmation

## Phase 3: Verification

Goal: Verify hooks are properly installed

Actions:
- List installed hooks:
  - !{bash ls -lh .git/hooks/pre-commit .git/hooks/commit-msg .git/hooks/pre-push 2>/dev/null}
- Verify hooks are executable:
  - !{bash test -x .git/hooks/pre-commit && echo "✓ pre-commit is executable" || echo "✗ pre-commit not executable"}
  - !{bash test -x .git/hooks/commit-msg && echo "✓ commit-msg is executable" || echo "✗ commit-msg not executable"}
  - !{bash test -x .git/hooks/pre-push && echo "✓ pre-push is executable" || echo "✗ pre-push not executable"}

## Phase 4: Summary

Goal: Report installation status and usage

Actions:
- Display success message with installed hooks
- Explain what each hook does:
  - **pre-commit**: Scans staged files for API keys, tokens, passwords, and secrets
  - **commit-msg**: Validates commit messages follow conventional commits format (feat|fix|docs|style|refactor|test|chore|perf|ci|build)
  - **pre-push**: Runs security scans before pushing (npm audit, safety check)
- Show how to bypass hooks if needed:
  - "Use `git commit --no-verify` to bypass hooks (not recommended)"
  - "Use `git push --no-verify` to bypass pre-push hook"
- Suggest testing the hooks:
  - "Test pre-commit: Try committing a file with 'password=secret123'"
  - "Test commit-msg: Try committing with message 'fixed bug' (should fail)"
- Next steps:
  - "Hooks are now active for all commits and pushes"
  - "Run /foundation:env-check to verify other tools"

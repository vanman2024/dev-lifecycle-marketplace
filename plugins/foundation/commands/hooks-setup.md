---
description: Install standardized git hooks (secret scanning, commit message validation, security checks)
argument-hint: [project-path]
allowed-tools: Read, Write, Bash, Glob, AskUserQuestion
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
  - !{bash git rev-parse --git-dir 2>/dev/null}
- If not a git repo, ask user if they want to initialize one
- Locate .git/hooks directory:
  - !{bash ls -la .git/hooks/}
- Check for existing hooks that might be overwritten

## Phase 2: Planning

Goal: Determine which hooks to install

Actions:
- Standard hooks to install:
  1. **pre-commit** - Secret/key scanning + basic security
  2. **commit-msg** - Conventional commit format validation
  3. **pre-push** - Full security scan (optional)
- If existing hooks found, ask user:
  - Overwrite existing hooks?
  - Backup existing hooks first?
- Explain what each hook does

## Phase 3: Implementation

Goal: Create and install git hook scripts

Actions:
- Create pre-commit hook for secret scanning:
  - !{bash cat > .git/hooks/pre-commit << 'HOOK_EOF'
#!/usr/bin/env bash
# pre-commit hook: Secret and key scanning

echo "🔍 Scanning for secrets and API keys..."

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
  echo -e "${GREEN}✓${NC} No files to scan"
  exit 0
fi

# Secret patterns to detect
declare -a PATTERNS=(
  "AKIA[0-9A-Z]{16}"                    # AWS Access Key
  "api[_-]?key['\"]?\s*[:=]\s*['\"]?[a-zA-Z0-9]{20,}"  # Generic API key
  "sk-[a-zA-Z0-9]{32,}"                 # OpenAI API key
  "Bearer [a-zA-Z0-9_\-\.]{20,}"        # Bearer token
  "password['\"]?\s*[:=]\s*['\"]?[^ '\"]+" # Password
  "secret['\"]?\s*[:=]\s*['\"]?[^ '\"]+"   # Secret
  "token['\"]?\s*[:=]\s*['\"]?[a-zA-Z0-9]{20,}" # Token
  "-----BEGIN (RSA |DSA )?PRIVATE KEY-----" # Private key
  "postgres://[^ '\"]*:[^ '\"]*@"       # Database connection string
  "mongodb(\+srv)?://[^ '\"]*:[^ '\"]*@" # MongoDB connection string
)

FOUND_SECRETS=0

for file in $STAGED_FILES; do
  # Skip binary files
  if file "$file" | grep -q "binary"; then
    continue
  fi

  # Skip common safe files
  if [[ "$file" == "package-lock.json" ]] || [[ "$file" == "yarn.lock" ]] || [[ "$file" == "*.md" ]]; then
    continue
  fi

  for pattern in "${PATTERNS[@]}"; do
    if grep -qE "$pattern" "$file" 2>/dev/null; then
      echo -e "${RED}✗${NC} Potential secret found in: $file"
      echo -e "${YELLOW}  Pattern matched: $pattern${NC}"
      FOUND_SECRETS=1
    fi
  done
done

if [ $FOUND_SECRETS -eq 1 ]; then
  echo ""
  echo -e "${RED}ERROR: Potential secrets detected!${NC}"
  echo "Please remove secrets before committing or use --no-verify to bypass (not recommended)"
  exit 1
fi

echo -e "${GREEN}✓${NC} No secrets detected"
exit 0
HOOK_EOF
}
  - !{bash chmod +x .git/hooks/pre-commit}

- Create commit-msg hook for conventional commits:
  - !{bash cat > .git/hooks/commit-msg << 'HOOK_EOF'
#!/usr/bin/env bash
# commit-msg hook: Validate conventional commit format

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📝 Validating commit message format..."

# Conventional commit pattern
# Format: type(scope): description
# Example: feat(api): add user authentication
PATTERN="^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .{1,100}"

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
  echo -e "${RED}✗${NC} Invalid commit message format"
  echo ""
  echo "Commit message must follow conventional commits format:"
  echo -e "${YELLOW}type(scope): description${NC}"
  echo ""
  echo "Valid types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
  echo ""
  echo "Examples:"
  echo "  feat(auth): add user login"
  echo "  fix(api): resolve null pointer error"
  echo "  docs(readme): update installation steps"
  echo ""
  echo "Your commit message:"
  echo "  $COMMIT_MSG"
  echo ""
  echo "Use --no-verify to bypass this check (not recommended)"
  exit 1
fi

echo -e "${GREEN}✓${NC} Commit message format valid"
exit 0
HOOK_EOF
}
  - !{bash chmod +x .git/hooks/commit-msg}

- Create pre-push hook for security scanning (optional):
  - !{bash cat > .git/hooks/pre-push << 'HOOK_EOF'
#!/usr/bin/env bash
# pre-push hook: Full security scan before push

echo "🛡️  Running security checks before push..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# Check for common security issues based on project type

# Node.js projects
if [ -f "package.json" ]; then
  echo "  Checking Node.js dependencies..."
  if command -v npm &> /dev/null; then
    npm audit --audit-level=high > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo -e "${YELLOW}⚠${NC}  High severity vulnerabilities found (run: npm audit)"
      # Don't block push, just warn
    fi
  fi
fi

# Python projects
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo "  Checking Python dependencies..."
  if command -v safety &> /dev/null; then
    safety check > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo -e "${YELLOW}⚠${NC}  Vulnerabilities found in Python packages (run: safety check)"
    fi
  fi
fi

# Check for debug statements
echo "  Checking for debug statements..."
DEBUG_PATTERNS="console\.log|debugger|pdb\.set_trace|binding\.pry"
if git diff origin/$(git rev-parse --abbrev-ref HEAD)..HEAD | grep -qE "$DEBUG_PATTERNS"; then
  echo -e "${YELLOW}⚠${NC}  Debug statements found in commits"
fi

if [ $ERRORS -eq 1 ]; then
  echo -e "${RED}ERROR: Security checks failed${NC}"
  echo "Fix issues or use --no-verify to bypass (not recommended)"
  exit 1
fi

echo -e "${GREEN}✓${NC} Security checks passed"
exit 0
HOOK_EOF
}
  - !{bash chmod +x .git/hooks/pre-push}

## Phase 4: Verification

Goal: Verify hooks are properly installed

Actions:
- List installed hooks:
  - !{bash ls -lh .git/hooks/pre-commit .git/hooks/commit-msg .git/hooks/pre-push 2>/dev/null}
- Verify hooks are executable:
  - !{bash test -x .git/hooks/pre-commit && echo "✓ pre-commit is executable" || echo "✗ pre-commit not executable"}
  - !{bash test -x .git/hooks/commit-msg && echo "✓ commit-msg is executable" || echo "✗ commit-msg not executable"}
  - !{bash test -x .git/hooks/pre-push && echo "✓ pre-push is executable" || echo "✗ pre-push not executable"}

## Phase 5: Summary

Goal: Report installation status and usage

Actions:
- Display success message with installed hooks
- Explain what each hook does:
  - **pre-commit**: Scans staged files for API keys, tokens, passwords, and secrets
  - **commit-msg**: Validates commit messages follow conventional commits format
  - **pre-push**: Runs security scans before pushing (npm audit, safety check)
- Show how to bypass hooks if needed:
  - "Use `git commit --no-verify` to bypass hooks (not recommended)"
  - "Use `git push --no-verify` to bypass pre-push hook"
- Suggest testing the hooks:
  - "Test pre-commit: Try committing a file with 'password=secret123'"
  - "Test commit-msg: Try committing with message 'fixed bug'"
- Next steps:
  - "Hooks are now active for all commits and pushes"
  - "Run /foundation:env-check to verify other tools"
  - "Run /planning:spec to start feature planning"

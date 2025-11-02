#!/usr/bin/env bash
# Install standardized git hooks

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(dirname "$SCRIPT_DIR")/templates"

# Target directory (default: current directory, or first argument)
TARGET_DIR="${1:-.}"

# Check if target is a git repository
if [ ! -d "$TARGET_DIR/.git" ]; then
  echo "Error: $TARGET_DIR is not a git repository"
  exit 1
fi

echo "Installing git hooks to: $TARGET_DIR"

# Install each hook
for hook in pre-commit commit-msg pre-push; do
  if [ -f "$TEMPLATES_DIR/$hook" ]; then
    cp "$TEMPLATES_DIR/$hook" "$TARGET_DIR/.git/hooks/$hook"
    chmod +x "$TARGET_DIR/.git/hooks/$hook"
    echo "✓ Installed $hook"
  else
    echo "⚠ Template not found: $TEMPLATES_DIR/$hook"
  fi
done

# Install GitHub Actions workflow
echo ""
echo "Installing GitHub Actions workflow..."
WORKFLOWS_DIR="$TARGET_DIR/.github/workflows"
mkdir -p "$WORKFLOWS_DIR"

if [ -f "$TEMPLATES_DIR/github-security-workflow.yml" ]; then
  cp "$TEMPLATES_DIR/github-security-workflow.yml" "$WORKFLOWS_DIR/security-scan.yml"
  echo "✓ Installed GitHub Actions security workflow"
else
  echo "⚠ GitHub workflow template not found"
fi

echo ""
echo "Git hooks and GitHub workflow installed successfully!"
echo ""
echo "Installed local hooks:"
echo "  - pre-commit: Secret and key scanning"
echo "  - commit-msg: Conventional commit format validation"
echo "  - pre-push: Security scans"
echo ""
echo "Installed GitHub workflow:"
echo "  - .github/workflows/security-scan.yml: Server-side security checks"
echo ""
echo "To bypass local hooks: git commit --no-verify"

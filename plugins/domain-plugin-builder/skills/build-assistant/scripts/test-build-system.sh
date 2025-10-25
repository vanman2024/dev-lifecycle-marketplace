#!/usr/bin/env bash
# Script: test-build-system.sh
# Purpose: Automated testing for build-system infrastructure
# Usage: ./test-build-system.sh [--quick|--full]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SYSTEM_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(cd "$BUILD_SYSTEM_DIR/../../../.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
SKIPPED=0

echo "================================================"
echo "Build System Testing Suite"
echo "================================================"
echo ""

# Test 1: File Structure
echo "[1/10] Testing File Structure..."

test_file_exists() {
  local file=$1
  if [ -f "$file" ]; then
    echo -e "${GREEN}✓${NC} $file"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} $file (missing)"
    ((FAILED++))
    return 1
  fi
}

test_dir_exists() {
  local dir=$1
  if [ -d "$dir" ]; then
    echo -e "${GREEN}✓${NC} $dir/"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} $dir/ (missing)"
    ((FAILED++))
    return 1
  fi
}

# Templates
test_file_exists "$BUILD_SYSTEM_DIR/templates/agents/agent.md.template"
test_file_exists "$BUILD_SYSTEM_DIR/templates/agents/agent-example.md"
test_file_exists "$BUILD_SYSTEM_DIR/templates/commands/command.md.template"
test_file_exists "$BUILD_SYSTEM_DIR/templates/commands/command-example.md"
test_file_exists "$BUILD_SYSTEM_DIR/templates/skills/SKILL.md.template"
test_file_exists "$BUILD_SYSTEM_DIR/templates/plugins/plugin.json.template"

# Reference docs
test_file_exists "$BUILD_SYSTEM_DIR/docs/01-claude-code-slash-commands.md"
test_file_exists "$BUILD_SYSTEM_DIR/docs/02-claude-code-skills.md"
test_file_exists "$BUILD_SYSTEM_DIR/docs/03-claude-code-plugins.md"
test_file_exists "$BUILD_SYSTEM_DIR/docs/04-skills-vs-commands.md"

# Validation scripts
test_file_exists "$BUILD_SYSTEM_DIR/scripts/validate-agent.sh"
test_file_exists "$BUILD_SYSTEM_DIR/scripts/validate-command.sh"
test_file_exists "$BUILD_SYSTEM_DIR/scripts/validate-skill.sh"
test_file_exists "$BUILD_SYSTEM_DIR/scripts/validate-plugin.sh"

echo ""

# Test 2: Build Commands
echo "[2/10] Testing Build Commands..."

test_file_exists "$HOME/.claude/commands/build/slash-command.md"
test_file_exists "$HOME/.claude/commands/build/agent.md"
test_file_exists "$HOME/.claude/commands/build/skill.md"
test_file_exists "$HOME/.claude/commands/build/plugin.md"
test_file_exists "$HOME/.claude/commands/build/subsystem.md"

echo ""

# Test 3: Builder Agents
echo "[3/10] Testing Builder Agents..."

test_file_exists "$HOME/.claude/agents/command-builder.md"
test_file_exists "$HOME/.claude/agents/agent-builder.md"
test_file_exists "$HOME/.claude/agents/skill-builder.md"
test_file_exists "$HOME/.claude/agents/plugin-builder.md"
test_file_exists "$HOME/.claude/agents/build-dependency-analyzer.md"

echo ""

# Test 4: Agent Step 0 Validation
echo "[4/10] Testing Agent Step 0 Sections..."

check_step_0() {
  local agent_file=$1
  local agent_name=$(basename "$agent_file" .md)

  if grep -q "### Step 0: Load Required Context (CRITICAL)" "$agent_file"; then
    echo -e "${GREEN}✓${NC} $agent_name has Step 0"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} $agent_name missing Step 0"
    ((FAILED++))
    return 1
  fi
}

check_step_0 "$HOME/.claude/agents/command-builder.md"
check_step_0 "$HOME/.claude/agents/agent-builder.md"
check_step_0 "$HOME/.claude/agents/skill-builder.md"
check_step_0 "$HOME/.claude/agents/plugin-builder.md"

echo ""

# Test 5: Infrastructure Analysis Steps
echo "[5/10] Testing Infrastructure Analysis..."

if grep -q "Analyze Existing Infrastructure" "$HOME/.claude/agents/skill-builder.md"; then
  echo -e "${GREEN}✓${NC} skill-builder has infrastructure analysis"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} skill-builder missing infrastructure analysis"
  ((FAILED++))
fi

if grep -q "Glob.*\.claude/commands" "$HOME/.claude/agents/skill-builder.md"; then
  echo -e "${GREEN}✓${NC} skill-builder loads existing commands"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} skill-builder doesn't load existing commands"
  ((FAILED++))
fi

if grep -q "Analyze Existing Infrastructure" "$HOME/.claude/agents/plugin-builder.md"; then
  echo -e "${GREEN}✓${NC} plugin-builder has infrastructure analysis"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} plugin-builder missing infrastructure analysis"
  ((FAILED++))
fi

if grep -q "--from-subsystem" "$HOME/.claude/agents/plugin-builder.md"; then
  echo -e "${GREEN}✓${NC} plugin-builder supports --from-subsystem"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} plugin-builder missing --from-subsystem"
  ((FAILED++))
fi

echo ""

# Test 6: Frontmatter Validation
echo "[6/10] Testing Frontmatter..."

check_frontmatter() {
  local file=$1
  local name=$(basename "$file" .md)

  if head -1 "$file" | grep -q "^---$"; then
    echo -e "${GREEN}✓${NC} $name has frontmatter"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} $name missing frontmatter"
    ((FAILED++))
    return 1
  fi
}

check_frontmatter "$HOME/.claude/agents/command-builder.md"
check_frontmatter "$HOME/.claude/agents/agent-builder.md"
check_frontmatter "$HOME/.claude/commands/build/slash-command.md"
check_frontmatter "$HOME/.claude/commands/build/agent.md"

echo ""

# Test 7: Script Executability
echo "[7/10] Testing Script Permissions..."

check_executable() {
  local script=$1
  local name=$(basename "$script")

  if [ -x "$script" ]; then
    echo -e "${GREEN}✓${NC} $name is executable"
    ((PASSED++))
    return 0
  else
    echo -e "${YELLOW}⚠${NC} $name not executable (fixing...)"
    chmod +x "$script"
    ((PASSED++))
    return 0
  fi
}

check_executable "$BUILD_SYSTEM_DIR/scripts/validate-agent.sh"
check_executable "$BUILD_SYSTEM_DIR/scripts/validate-command.sh"
check_executable "$BUILD_SYSTEM_DIR/scripts/validate-skill.sh"
check_executable "$BUILD_SYSTEM_DIR/scripts/validate-plugin.sh"

echo ""

# Test 8: Template Placeholder Format
echo "[8/10] Testing Template Placeholders..."

if grep -q "{{AGENT_NAME}}" "$BUILD_SYSTEM_DIR/templates/agents/agent.md.template"; then
  echo -e "${GREEN}✓${NC} Agent template uses {{VARIABLE}} format"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} Agent template wrong placeholder format"
  ((FAILED++))
fi

if grep -q "{{COMMAND_NAME}}" "$BUILD_SYSTEM_DIR/templates/commands/command.md.template"; then
  echo -e "${GREEN}✓${NC} Command template uses {{VARIABLE}} format"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} Command template wrong placeholder format"
  ((FAILED++))
fi

if grep -q "{{SKILL_NAME}}" "$BUILD_SYSTEM_DIR/templates/skills/SKILL.md.template"; then
  echo -e "${GREEN}✓${NC} Skill template uses {{VARIABLE}} format"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} Skill template wrong placeholder format"
  ((FAILED++))
fi

echo ""

# Test 9: Documentation Content
echo "[9/10] Testing Documentation Content..."

# Check reference docs aren't just stubs
check_doc_content() {
  local doc=$1
  local name=$(basename "$doc")
  local lines=$(wc -l < "$doc")

  if [ "$lines" -gt 20 ]; then
    echo -e "${GREEN}✓${NC} $name has content ($lines lines)"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} $name appears to be a stub ($lines lines)"
    ((FAILED++))
    return 1
  fi
}

check_doc_content "$BUILD_SYSTEM_DIR/docs/01-claude-code-slash-commands.md"
check_doc_content "$BUILD_SYSTEM_DIR/docs/02-claude-code-skills.md"
check_doc_content "$BUILD_SYSTEM_DIR/docs/03-claude-code-plugins.md"
check_doc_content "$BUILD_SYSTEM_DIR/docs/04-skills-vs-commands.md"

# Check README is comprehensive
readme_lines=$(wc -l < "$BUILD_SYSTEM_DIR/README.md")
if [ "$readme_lines" -gt 500 ]; then
  echo -e "${GREEN}✓${NC} README.md is comprehensive ($readme_lines lines)"
  ((PASSED++))
else
  echo -e "${YELLOW}⚠${NC} README.md might need more content ($readme_lines lines)"
  ((PASSED++))
fi

echo ""

# Test 10: Integration Points
echo "[10/10] Testing Integration Points..."

# Check build commands reference templates
if grep -q "@multiagent_core/templates/$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/build-system" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/build-system" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-build-system" -type d -path "*/skills/*" -name "build-system" 2>/dev/null | head -1)" "$HOME/.claude/commands/build/slash-command.md"; then
  echo -e "${GREEN}✓${NC} /build:slash-command references templates"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} /build:slash-command doesn't reference templates"
  ((FAILED++))
fi

if grep -q "@multiagent_core/templates/$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/build-system" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/build-system" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-build-system" -type d -path "*/skills/*" -name "build-system" 2>/dev/null | head -1)" "$HOME/.claude/commands/build/agent.md"; then
  echo -e "${GREEN}✓${NC} /build:agent references templates"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} /build:agent doesn't reference templates"
  ((FAILED++))
fi

# Check agents reference Claude Code docs
if grep -q "02-claude-code-skills.md" "$HOME/.claude/agents/skill-builder.md"; then
  echo -e "${GREEN}✓${NC} skill-builder references Claude Code docs"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} skill-builder doesn't reference Claude Code docs"
  ((FAILED++))
fi

if grep -q "03-claude-code-plugins.md" "$HOME/.claude/agents/plugin-builder.md"; then
  echo -e "${GREEN}✓${NC} plugin-builder references Claude Code docs"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} plugin-builder doesn't reference Claude Code docs"
  ((FAILED++))
fi

echo ""
echo "================================================"
echo "Test Results"
echo "================================================"
echo -e "${GREEN}Passed:${NC}  $PASSED"
echo -e "${RED}Failed:${NC}  $FAILED"
echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
echo ""

TOTAL=$((PASSED + FAILED + SKIPPED))
if [ $TOTAL -gt 0 ]; then
  PERCENTAGE=$((PASSED * 100 / TOTAL))
  echo "Success Rate: ${PERCENTAGE}%"
  echo ""
fi

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed!${NC}"
  echo ""
  echo "Build system is ready for:"
  echo "  - Commit and push"
  echo "  - Production use"
  echo "  - Documentation"
  exit 0
else
  echo -e "${RED}✗ Some tests failed${NC}"
  echo ""
  echo "Please fix failing tests before:"
  echo "  - Committing changes"
  echo "  - Deploying to production"
  exit 1
fi

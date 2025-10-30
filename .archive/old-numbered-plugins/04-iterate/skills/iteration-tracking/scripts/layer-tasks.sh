#!/bin/bash

# layer-tasks.sh - Transform tasks into non-blocking parallel structure using template
# Usage: layer-tasks.sh <spec-number-or-name>
# Example: layer-tasks.sh 005  OR  layer-tasks.sh 005-documentation-management-system

set -e

SPEC_INPUT="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/../templates/task-layering.template.md"

if [[ -z "$SPEC_INPUT" ]]; then
    echo "Usage: layer-tasks.sh <spec-number-or-name>"
    echo "Example: layer-tasks.sh 005"
    echo "Example: layer-tasks.sh 005-documentation-management-system"
    exit 1
fi

# If input is just a number, find the matching spec directory
if [[ "$SPEC_INPUT" =~ ^[0-9]+$ ]]; then
    SPEC_DIR=$(find specs -maxdepth 1 -type d -name "${SPEC_INPUT}-*" | head -1)
    if [[ -z "$SPEC_DIR" ]]; then
        echo "ERROR: No spec directory found matching number: $SPEC_INPUT"
        exit 1
    fi
    SPEC_NAME=$(basename "$SPEC_DIR")
    echo "Found spec: $SPEC_NAME"
else
    SPEC_NAME="$SPEC_INPUT"
    SPEC_DIR="specs/$SPEC_NAME"
fi

AGENT_TASKS_DIR="$SPEC_DIR/agent-tasks"
ORIGINAL_TASKS="$SPEC_DIR/tasks.md"
LAYERED_TASKS="$AGENT_TASKS_DIR/layered-tasks.md"

echo "Processing spec: $SPEC_NAME"
echo "Template: $TEMPLATE_FILE"
echo "Input: $ORIGINAL_TASKS"
echo "Output: $LAYERED_TASKS"

# Validate inputs
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "ERROR: Template not found: $TEMPLATE_FILE"
    exit 1
fi

if [[ ! -f "$ORIGINAL_TASKS" ]]; then
    echo "ERROR: No tasks.md found in $SPEC_DIR"
    exit 1
fi

# Create agent-tasks directory
mkdir -p "$AGENT_TASKS_DIR"

echo "=== Loading Template ==="
echo "Template loaded from: $TEMPLATE_FILE"

echo "=== Script creates STRUCTURE ONLY - Claude does intelligent assignment ==="

# Just count tasks for reporting
TOTAL_TASKS=$(grep -c '^- \[.\] T[0-9]' "$ORIGINAL_TASKS" || echo 0)
echo "Total tasks found: $TOTAL_TASKS"
echo "Claude will intelligently assign all $TOTAL_TASKS tasks after reading:"
echo "  1. Original tasks.md"
echo "  2. agent-responsibilities.yaml"
echo "  3. Task complexity and scope"

# Set placeholder values - Claude will replace these
AGENT_SPECIALIZATIONS="{{AGENT_SPECIALIZATIONS}}"
AGENT_TASK_SECTIONS="{{AGENT_TASK_SECTIONS}}"

echo "=== Applying Template with Placeholders ==="

# Load template and replace placeholders
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

# Use sed to replace placeholders
sed -e "s|{{SPEC_NAME}}|$SPEC_NAME|g" \
    -e "s|{{TIMESTAMP}}|$TIMESTAMP|g" \
    -e "s|{{COORDINATOR_AGENT}}|@claude|g" \
    "$TEMPLATE_FILE" > "$LAYERED_TASKS"

# Replace multi-line placeholders using awk
awk -v agent_spec="$AGENT_SPECIALIZATIONS" -v agent_sections="$AGENT_TASK_SECTIONS" '
{
    if ($0 ~ /{{AGENT_SPECIALIZATIONS}}/) {
        print agent_spec
    } else if ($0 ~ /{{AGENT_TASK_SECTIONS}}/) {
        print agent_sections
    } else {
        print $0
    }
}
' "$LAYERED_TASKS" > "$LAYERED_TASKS.tmp" && mv "$LAYERED_TASKS.tmp" "$LAYERED_TASKS"

echo "=== Creating Layering Info File ==="

cat > "$AGENT_TASKS_DIR/layering-info.md" << EOF
# Task Layering Information

**Spec**: $SPEC_NAME
**Layered**: $TIMESTAMP
**Original Tasks**: tasks.md
**Layered Tasks**: layered-tasks.md

## Layering Applied
- Non-blocking parallel structure
- All agents work simultaneously
- Zero dependencies between agents
- Integration via Git PRs

## Key Changes
- **Before**: Sequential tasks with unclear dependencies
- **After**: Agent-grouped tasks with immediate start capability
- **Result**: Maximum parallelism - all agents work at once

## Usage
Agents should read from layered-tasks.md instead of tasks.md for non-blocking parallel work.

## Refresh
Re-run: /iterate:tasks $SPEC_NAME
EOF

# No temp files to clean up - script only creates structure

echo "=== Symlink Setup Available ==="

# Script stays in $HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate/scripts/ - agents run it from there
SYMLINK_SCRIPT="$SCRIPT_DIR/setup-worktree-symlinks.sh"

if [[ -f "$SYMLINK_SCRIPT" ]]; then
    echo "✅ Symlink setup script available at: $SYMLINK_SCRIPT"
else
    echo "⚠️  WARNING: Symlink script not found at: $SYMLINK_SCRIPT"
fi

# Update layering-info.md with symlink instructions
cat >> "$AGENT_TASKS_DIR/layering-info.md" << EOF

## Symlink Setup for Agent Worktrees

When agents create their worktrees, they can link to the main repo's layered-tasks.md:

\`\`\`bash
# From your agent worktree root
$([ -f "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate" -type d -path "*/skills/*" -name "iterate" 2>/dev/null | head -1)/scripts/setup-worktree-symlinks.sh" ] && echo "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate" -type d -path "*/skills/*" -name "iterate" 2>/dev/null | head -1)/scripts/setup-worktree-symlinks.sh" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate/skills/*/scripts" -name "setup-worktree-symlinks.sh" -type f 2>/dev/null | head -1) $SPEC_NAME
\`\`\`

This creates a symlink at \`specs/$SPEC_NAME/layered-tasks-main.md\` pointing to main's layered-tasks.md.

**Benefits**:
- Real-time visibility into task progress from main repo
- Agents can check tasks off in their worktree
- Updates instantly visible in main branch
- No conflicts (each agent has their own worktree)

**Script location**: \`$([ -f "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate" -type d -path "*/skills/*" -name "iterate" 2>/dev/null | head -1)/scripts/setup-worktree-symlinks.sh" ] && echo "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate" -type d -path "*/skills/*" -name "iterate" 2>/dev/null | head -1)/scripts/setup-worktree-symlinks.sh" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate/skills/*/scripts" -name "setup-worktree-symlinks.sh" -type f 2>/dev/null | head -1)\`
EOF

echo "✅ **Task Layering Complete**"
echo ""
echo "📁 **Spec**: $SPEC_NAME"
echo "📋 **Files Generated**:"
echo "  - agent-tasks/layered-tasks.md: Non-blocking parallel task structure"
echo "  - agent-tasks/layering-info.md: Layering metadata and usage"
echo "  - agent-tasks/setup-worktree-symlinks.sh: Symlink setup for agents"
echo ""
echo "🔗 **Symlink Support**:"
echo "  - Agents can link to main's layered-tasks.md"
echo "  - Real-time task visibility from main repo"
echo "  - Run setup script from agent worktree"
echo ""
echo "🚀 **Non-Blocking Architecture**:"
echo "  - All agents start immediately"
echo "  - Zero blocking dependencies"
echo "  - Work in parallel worktrees"
echo "  - Integrate via Git PRs"
echo ""
echo "⚡ **Refresh**: Re-run /iterate:tasks $SPEC_NAME to update layering"
echo ""
echo "🌳 **Setup Agent Worktrees**: $([ -f "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate" -type d -path "*/skills/*" -name "iterate" 2>/dev/null | head -1)/scripts/setup-spec-worktrees.sh" ] && echo "$([ -d "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" ] && echo "$HOME/.claude/marketplaces/multiagent-dev/plugins/*/skills/*/iterate" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate" -type d -path "*/skills/*" -name "iterate" 2>/dev/null | head -1)/scripts/setup-spec-worktrees.sh" || find "$HOME/.claude/marketplaces/multiagent-dev/plugins/multiagent-iterate/skills/*/scripts" -name "setup-spec-worktrees.sh" -type f 2>/dev/null | head -1) $SPEC_NAME"
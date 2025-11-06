#!/bin/bash
# Add worktree discovery section to all agents

MARKETPLACE_DIR="/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace"

# The worktree discovery section to add
WORKTREE_SECTION='
## Worktree Discovery

**IMPORTANT**: Before starting any work, check if you'\''re working on a spec in an isolated worktree.

**Steps:**
1. Look at your task - is there a spec number mentioned? (e.g., "spec 001", "001-red-seal-ai", working in `specs/001-*/`)
2. If yes, query Mem0 for the worktree:
   ```bash
   python plugins/planning/skills/doc-sync/scripts/register-worktree.py query --query "worktree for spec {number}"
   ```
3. If Mem0 returns a worktree:
   - Parse the path (e.g., `Path: ../RedAI-001`)
   - Change to that directory: `cd {path}`
   - Verify branch: `git branch --show-current` (should show `spec-{number}`)
   - Continue your work in this isolated worktree
4. If no worktree found: work in main repository (normal flow)

**Why this matters:**
- Worktrees prevent conflicts when multiple agents work simultaneously
- Changes are isolated until merged via PR
- Dependencies are installed fresh per worktree

'

echo "Adding worktree discovery to all agents..."
echo ""

# Find all active agents (not archived)
find "$MARKETPLACE_DIR/plugins" -type f -path "*/agents/*.md" ! -path "*/archived/*" | while read -r agent_file; do
    # Check if worktree discovery already exists
    if grep -q "## Worktree Discovery" "$agent_file"; then
        echo "⏭️  Skipping $agent_file (already has worktree discovery)"
        continue
    fi

    echo "Processing: $agent_file"

    # Create temp file
    temp_file=$(mktemp)

    # Read the file and add worktree discovery after frontmatter
    awk '
        BEGIN { in_frontmatter = 0; frontmatter_ended = 0; }
        /^---$/ {
            in_frontmatter++;
            print;
            if (in_frontmatter == 2) {
                frontmatter_ended = 1;
                print "'"${WORKTREE_SECTION}"'";
            }
            next;
        }
        { print; }
    ' "$agent_file" > "$temp_file"

    # Replace original file
    mv "$temp_file" "$agent_file"

    echo "  ✅ Added worktree discovery"
done

echo ""
echo "Done! All agents now have worktree discovery instructions."

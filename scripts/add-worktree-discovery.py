#!/usr/bin/env python3
"""
Add worktree discovery section to all agents
"""

import os
from pathlib import Path

# The worktree discovery section to add
WORKTREE_SECTION = """
## Worktree Discovery

**IMPORTANT**: Before starting any work, check if you're working on a spec in an isolated worktree.

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

"""

def add_worktree_discovery(agent_file: Path):
    """Add worktree discovery section after frontmatter"""

    # Read the file
    with open(agent_file, 'r') as f:
        content = f.read()

    # Check if already has worktree discovery
    if '## Worktree Discovery' in content:
        print(f"⏭️  Skipping {agent_file.name} (already has worktree discovery)")
        return False

    # Split by frontmatter (between first two --- markers)
    parts = content.split('---', 2)

    if len(parts) < 3:
        print(f"⚠️  Skipping {agent_file.name} (no frontmatter found)")
        return False

    # Reconstruct with worktree discovery after frontmatter
    new_content = f"---{parts[1]}---{WORKTREE_SECTION}{parts[2]}"

    # Write back
    with open(agent_file, 'w') as f:
        f.write(new_content)

    print(f"  ✅ Added worktree discovery to {agent_file.name}")
    return True

def main():
    marketplace_dir = Path(__file__).parent.parent

    print("Adding worktree discovery to all agents...")
    print("")

    # Find all active agents (not archived)
    agent_files = sorted(marketplace_dir.glob("plugins/*/agents/*.md"))
    agent_files = [f for f in agent_files if '/archived/' not in str(f)]

    count = 0
    for agent_file in agent_files:
        if add_worktree_discovery(agent_file):
            count += 1

    print("")
    print(f"Done! Added worktree discovery to {count} agents.")

if __name__ == "__main__":
    main()

---
description: Launch visual documentation registry viewer
argument-hint: none
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

---
**Arguments**: $ARGUMENTS

Goal: Launch the documentation registry web viewer to visualize all documentation relationships

## Phase 1: Check Prerequisites

Goal: Verify viewer components exist

Actions:
- Check if API server exists:
  !{bash test -f ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/doc-sync/scripts/serve-viewer.py && echo "✅ API server found" || echo "❌ API server missing"}
- Check if HTML viewer exists:
  !{bash test -f ~/.claude/doc-viewer.html && echo "✅ Viewer found" || echo "❌ Viewer missing"}
- Check if mem0 venv exists:
  !{bash test -d /tmp/mem0-env && echo "✅ Mem0 environment ready" || echo "❌ Mem0 not installed"}

## Phase 2: Launch Viewer

Goal: Start API server and open viewer in browser

Actions:
- Launch viewer using script:
  !{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/doc-sync/scripts/view-docs.sh}

This will:
1. Start API server on http://localhost:8765
2. Open viewer HTML in your browser
3. Display all documentation relationships

Press Ctrl+C to stop the server when done.

## Phase 3: Usage Instructions

Goal: Explain how to use the viewer

Actions:
- Display viewer features:
  - **Graph View**: Visual network of all documentation relationships
    - Specs (green nodes)
    - Architecture docs (blue nodes)
    - ADRs (orange nodes)
    - Click and drag to explore
    - Hover over nodes for details

  - **List View**: Organized list of all documentation
    - Stats showing counts
    - Expandable sections
    - Full memory text visible

  - **Project Selector**: Switch between different projects (dropdown at top)

- Suggest workflow:
  - Use Graph View to understand overall structure
  - Use List View for detailed reading
  - Keep viewer open while working on specs
  - Refresh browser to see latest changes after running sync

## Phase 4: Summary

Goal: Confirm viewer launched

Actions:
- Display:
  - "✅ Documentation viewer launched"
  - "🌐 API: http://localhost:8765"
  - "📊 Viewer: file://~/.claude/doc-viewer.html"
  - "⏹️  Press Ctrl+C in terminal to stop server"

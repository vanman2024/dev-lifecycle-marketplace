---
description: Consolidate auto-generated documentation into proper locations (specs, architecture, ADRs, contracts)
argument-hint: [target-directory]
allowed-tools: Task, Read, Bash(*), Glob, Grep, TodoWrite
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

Goal: Discover, classify, and organize scattered auto-generated documentation files into their proper locations within the project structure (specs/, docs/architecture/, docs/adrs/, contracts/).

Core Principles:
- Scan comprehensively - find all markdown files
- Classify accurately - determine proper location for each doc
- Consolidate intelligently - merge duplicates, split massive files
- Preserve carefully - ask before deleting anything important
- Track systematically - use TodoWrite to show progress

Phase 1: Discovery
Goal: Understand the scope of documentation to consolidate

Actions:
- Create todo list for consolidation workflow
- If $ARGUMENTS provided, use as target directory
- If no arguments, default to current project root
- Scan for all markdown files:
  !{bash find ${ARGUMENTS:-.} -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/vendor/*" -type f}
- List existing documentation directories:
  !{bash ls -la specs/ docs/architecture/ docs/adrs/ contracts/ 2>/dev/null || echo "No standard doc directories found"}
- Show count of files found and directories that exist
- Update todos

Phase 2: Analysis
Goal: Classify documentation and identify consolidation needs

Actions:

Launch the doc-consolidator agent to analyze and classify all discovered documentation.

Provide the agent with:
- Target directory from $ARGUMENTS or current directory
- List of markdown files found in Phase 1
- Existing documentation structure

The agent will:
- Read and classify each markdown file by content type
- Identify duplicates and overlapping documentation
- Detect gaps in documentation
- Create consolidation plan with file operations

Expected output:
- Classification report (specs, architecture, ADRs, contracts, general)
- List of duplicates to merge
- List of files to move/reorganize
- Recommended new documentation to create
- Detailed consolidation plan

Phase 3: Review and Approval
Goal: Present plan and get user confirmation

Actions:
- Display the consolidation plan from doc-consolidator agent
- Show:
  - Files to be consolidated (merged)
  - Files to be moved to proper locations
  - Files to be archived
  - Files to be deleted (if any)
  - New documentation to create
- Ask user to review and approve plan before proceeding
- If user wants changes, allow them to specify modifications
- Update todos

Phase 4: Summary
Goal: Report consolidation results

Actions:
- Mark all todos complete
- Summarize consolidation actions taken:
  - Number of files processed
  - Files moved to specs/
  - Files moved to docs/architecture/
  - Files moved to docs/adrs/
  - Files moved to contracts/
  - Files archived
  - New documentation created
- Show before/after organization structure
- Suggest next steps:
  - Review consolidated documentation
  - Update cross-references
  - Run /planning:spec list to verify specs recognized
  - Consider running documentation validation

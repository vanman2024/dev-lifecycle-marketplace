---
description: Sync specs with implementation - update specs, tasks, and docs to match current code state
argument-hint: [feature-area]
---
## Available Skills

This commands has access to the following skills from the iterate plugin:

- **sync-patterns**: Compare specs with implementation state, update spec status, and generate sync reports. Use when syncing specs, checking implementation status, marking tasks complete, generating sync reports, or when user mentions spec sync, status updates, or implementation tracking.

**To use a skill:**
```
!{skill skill-name}
```

Use skills when you need:
- Domain-specific templates and examples
- Validation scripts and automation
- Best practices and patterns
- Configuration generators

Skills provide pre-built resources to accelerate your work.

---



## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Synchronize specification documents with actual implementation state

Core Principles:
- Reality is source of truth - code state determines spec state
- Update specs to reflect what actually exists
- Mark tasks complete that are implemented
- Keep documentation current with codebase

Phase 1: Discovery
Goal: Identify what needs to be synced

Actions:
- Parse $ARGUMENTS for target feature area or scope
- Locate relevant spec files in current project
- Example: !{bash find . -name "*.spec.md" -o -name "spec.md" -o -name "*-spec.md" 2>/dev/null | grep -v node_modules | head -20}
- Identify task tracking files (.tasks.md, TODO.md, etc.)
- Example: !{bash find . -name ".tasks.md" -o -name "TODO.md" -o -name "TASKS.md" 2>/dev/null | grep -v node_modules | head -20}

Phase 2: Load Context
Goal: Understand current spec and implementation state

Actions:
- Read identified spec files to understand documented features
- Read task files to see tracked items
- Scan implementation files in target area
- Example: !{bash if [ -n "$ARGUMENTS" ]; then find . -path "*/$ARGUMENTS/*" -type f 2>/dev/null | grep -v node_modules | head -30; else find . -name "*.ts" -o -name "*.js" -o -name "*.py" 2>/dev/null | grep -v node_modules | head -30; fi}
- Load documentation files if present
- Example: @README.md

Phase 3: Analysis
Goal: Identify gaps between specs and reality

Actions:

Task(description="Sync specs with implementation", subagent_type="iterate:sync-analyzer", prompt="You are the sync-analyzer agent. Sync specifications with implementation for $ARGUMENTS.

Your mission: Update spec documents to accurately reflect current code state.

Context Provided:
- Spec files found
- Task tracking files
- Implementation files in scope
- Documentation

Actions Required:
1. Compare spec claims vs actual implementation
2. Identify completed features that are still marked pending
3. Find implemented features not documented in specs
4. Detect spec items that were abandoned or changed
5. Update spec files with current status
6. Mark completed tasks as done
7. Add new implemented features to specs
8. Archive or update abandoned spec items
9. Refresh documentation to match reality
10. Provide summary of sync changes made

Deliverable: Updated spec files with accurate implementation state, completed task markers, and refreshed documentation")

Phase 4: Verification
Goal: Ensure sync is complete and accurate

Actions:
- Review updated spec files
- Verify task states match implementation
- Check that documentation reflects changes
- Example: !{bash git diff --stat 2>/dev/null || echo "No git changes to display"}

Phase 5: Summary
Goal: Report sync results

Actions:
- Display what was synchronized:
  - Specs updated
  - Tasks marked complete
  - New features documented
  - Abandoned items handled
- Show file modification summary
- Suggest next steps (e.g., commit changes, review TODOs)

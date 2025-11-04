---
description: Adjust implementation based on feedback - make targeted changes based on user feedback or requirements
argument-hint: feedback-or-requirements
allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
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

Goal: Make targeted adjustments to existing implementation based on user feedback, requirements changes, or improvement suggestions.

Core Principles:
- Understand the feedback thoroughly before making changes
- Preserve existing functionality while incorporating feedback
- Make surgical changes rather than broad rewrites
- Validate changes don't break existing features

Phase 1: Discovery
Goal: Parse and understand the feedback or requirements

Actions:
- If $ARGUMENTS is unclear or too brief, use AskUserQuestion to gather:
  - What specific feedback needs to be addressed?
  - Which files or features are affected?
  - What is the expected outcome?
  - Are there any constraints or priorities?
- Parse $ARGUMENTS to extract feedback details
- Identify scope of adjustments needed

Phase 2: Context Loading
Goal: Understand current implementation state

Actions:
- Locate relevant files mentioned in feedback
- If no specific files mentioned, find related code:
  - !{bash find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" \) | grep -v node_modules | grep -v .next | head -20}
- Load key files to understand current implementation
- Review existing patterns and conventions

Phase 3: Planning
Goal: Design the adjustment approach

Actions:
- Analyze gap between current state and desired state
- Identify specific changes needed
- Plan which files need modification
- Consider potential side effects
- Present plan to user if changes are significant

Phase 4: Implementation
Goal: Execute adjustments with specialized agent

Actions:

Task(description="Adjust implementation based on feedback", subagent_type="iterate:implementation-adjuster", prompt="You are the implementation-adjuster agent. Adjust the implementation based on: $ARGUMENTS

Your mission: Make targeted changes that address the feedback while preserving existing functionality.

Actions:
- Review the feedback and understand what needs to change
- Read affected files to understand current implementation
- Make precise, surgical changes to address feedback
- Preserve existing functionality not mentioned in feedback
- Follow existing code patterns and conventions
- Add comments explaining changes if needed
- Ensure code quality and consistency

Constraints:
- Don't rewrite code unnecessarily
- Maintain backward compatibility unless explicitly asked to break it
- Follow the existing architecture and patterns
- Test changes mentally for edge cases

Deliverable: Modified files with feedback incorporated, preserving existing functionality and following codebase conventions")

Phase 5: Verification
Goal: Ensure changes work correctly

Actions:
- Review modified files for correctness
- Check if changes address the original feedback
- Run type checking if TypeScript project:
  - !{bash if [ -f "tsconfig.json" ]; then npm run typecheck 2>/dev/null || npx tsc --noEmit; fi}
- Run tests if test suite exists:
  - !{bash if [ -f "package.json" ] && grep -q "\"test\"" package.json; then npm test; fi}
- Verify no regressions introduced

Phase 6: Summary
Goal: Report what was adjusted

Actions:
- Summarize changes made:
  - Files modified
  - What was changed and why
  - How feedback was addressed
  - Any trade-offs or considerations
- Highlight any remaining items if feedback only partially addressed
- Suggest next steps if applicable

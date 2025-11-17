---
description: Enhance existing features with improvements and optimizations
argument-hint: [feature-or-file]
allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
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

Goal: Add improvements, optimizations, and new capabilities to existing features while maintaining stability

Core Principles:
- Build on existing - extend, don't rebuild
- Add value - meaningful improvements
- Maintain stability - don't break working code
- Document enhancements - clear upgrade path

## Phase 1: Discovery
Goal: Understand what needs enhancement

Actions:
- If no arguments provided, ask user:
  - "What feature needs enhancement?" (feature name, file, or module)
  - "What improvements do you want?" (performance, capabilities, UX, etc.)
  - "What's the enhancement goal?" (faster, more features, better UX, etc.)
- If arguments provided, parse for:
  - Feature name (enhance specific feature)
  - File path (enhance code in file)
  - Module name (enhance entire module)
- Load project context:
  @.claude/project.json

## Phase 2: Analysis
Goal: Understand current state and enhancement opportunities

Actions:
- If feature name provided:
  - Find feature implementation: !{bash grep -r "$ARGUMENTS" --include="*.ts" --include="*.js" --include="*.py" --exclude-dir=node_modules --exclude-dir=.next | head -20}
  - Locate related files: !{bash find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) | xargs grep -l "$ARGUMENTS" 2>/dev/null | head -10}
- If file path provided:
  - Validate file exists: !{bash test -f "$ARGUMENTS" && echo "✅ Found" || echo "❌ Not found"}
  - Read current implementation: @$ARGUMENTS
  - Find dependencies: !{bash grep -E "import|require|from" "$ARGUMENTS" 2>/dev/null | head -10}
- Load feature specs if available:
  - Check specs directory: !{bash ls -d specs/* 2>/dev/null | grep -i "$ARGUMENTS" | head -5}
  - Load spec: @specs/$(ls specs/ | grep -i "$ARGUMENTS" | head -1)
- Load related tests:
  !{bash find . -type f \( -name "*.test.*" -o -name "*.spec.*" \) | xargs grep -l "$ARGUMENTS" 2>/dev/null | head -10}
- Check current metrics:
  - Performance indicators
  - Feature usage patterns
  - Known limitations

## Phase 3: Planning
Goal: Determine enhancement strategy

Actions:
- Identify enhancement opportunities:
  - Performance optimizations
  - New capabilities to add
  - UX improvements
  - Error handling enhancements
  - Configuration options
  - API expansions
- Assess impact:
  - Backward compatibility
  - Breaking changes (minimize)
  - Performance implications
  - New dependencies needed
- Plan implementation:
  - Incremental enhancements
  - Feature flags if needed
  - Migration path for users
- Plan verification:
  - New tests for enhancements
  - Existing tests still pass
  - Performance benchmarks
  - Manual testing steps

## Phase 4: Enhancement
Goal: Execute enhancements with feature-enhancer agent

Actions:

Launch the feature-enhancer agent to add improvements and new capabilities.

Provide the agent with:
- Context: Current feature implementation from Phase 2
- Enhancement goals: User requirements from Phase 1
- Constraints:
  - Maintain backward compatibility
  - Don't break existing functionality
  - Follow project patterns and style
  - Keep performance in mind
- Enhancement areas:
  - Performance optimizations (caching, lazy loading, etc.)
  - New capabilities (additional features, options)
  - Improved error handling (validation, recovery)
  - Better UX (clearer messages, better defaults)
  - Enhanced configurability (more options, flexibility)
  - API improvements (better interface, more methods)
- Requirements:
  - Add enhancements incrementally
  - Maintain existing behavior by default
  - Add tests for new capabilities
  - Update documentation for enhancements
  - Use feature flags for experimental features
  - Consider upgrade path for users
- Deliverables:
  - Enhanced code with new capabilities
  - New tests for enhancements
  - Updated documentation
  - Performance improvements (if applicable)
  - Summary of enhancements added

## Phase 5: Verification
Goal: Validate enhancements work correctly

Actions:
- Check files were modified:
  !{bash git status --short | grep "^ M"}
- Display enhancement changes:
  !{bash git diff --stat}
- Run full test suite:
  - TypeScript/JavaScript: !{bash npm test 2>/dev/null || echo "No npm tests"}
  - Python: !{bash pytest 2>/dev/null || python -m pytest 2>/dev/null || echo "No pytest"}
- Check build passes with enhancements:
  - TypeScript: !{bash npx tsc --noEmit 2>&1 | head -20}
- Verify backward compatibility:
  - Old tests still pass
  - Existing APIs still work
  - No breaking changes introduced
- Test new enhancements:
  - New capabilities work
  - Performance improvements measurable
  - UX improvements noticeable

## Phase 6: Summary
Goal: Report enhancements and benefits

Actions:
- Display: "Feature enhanced successfully"
- Show files enhanced: !{bash git diff --name-only}
- Summarize enhancements added:
  - New capabilities
  - Performance improvements
  - UX enhancements
  - Configuration options
- Show benefits:
  - Performance metrics (if measurable)
  - New features available
  - Improved user experience
- Suggest next steps:
  - "Review enhancements with: git diff"
  - "Test new capabilities thoroughly"
  - "Update user documentation"
  - "Consider changelog entry"
  - "Commit enhancements when satisfied"
- Note: "Backward compatible - existing code still works"

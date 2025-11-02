---
description: Enhance existing features - add improvements and optimizations to existing features
argument-hint: feature-name
allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Enhance existing features by adding improvements, optimizations, and refinements to make them more robust, performant, and user-friendly.

Core Principles:
- Understand existing implementation before enhancing
- Identify meaningful improvement opportunities
- Maintain backward compatibility when possible
- Test enhancements thoroughly before completion

Phase 1: Discovery
Goal: Identify the feature to enhance and gather context

Actions:
- Parse $ARGUMENTS for feature name/path
- If $ARGUMENTS is unclear, use AskUserQuestion to gather:
  - What feature should be enhanced?
  - What aspects need improvement (performance, UX, reliability)?
  - Are there any specific constraints or requirements?
- Locate feature files using Glob
- Example: !{bash find . -name "*$ARGUMENTS*" -type f 2>/dev/null | head -20}

Phase 2: Analysis
Goal: Understand current implementation

Actions:
- Load the feature's main files identified
- Read related configuration, tests, and documentation
- Understand the feature's purpose, dependencies, and usage patterns
- Document current state and limitations

Phase 3: Enhancement Planning
Goal: Identify improvement opportunities

Actions:
- Review code for optimization opportunities
- Identify edge cases not currently handled
- Look for performance bottlenecks
- Consider UX improvements
- Check for missing error handling
- Present enhancement plan to user for confirmation

Phase 4: Implementation
Goal: Execute enhancements with agent

Actions:

Task(description="Enhance feature", subagent_type="iterate:feature-enhancer", prompt="You are the feature-enhancer agent. Enhance the feature: $ARGUMENTS.

Context: You have analyzed the existing implementation and identified enhancement opportunities.

Your responsibilities:
- Add performance optimizations where beneficial
- Improve error handling and edge case coverage
- Enhance user experience and usability
- Add helpful logging or debugging aids
- Improve code clarity and maintainability
- Update or add relevant tests
- Maintain backward compatibility unless explicitly instructed otherwise

Enhancement guidelines:
- Make incremental, well-tested improvements
- Follow existing code patterns and conventions
- Add comments explaining non-obvious enhancements
- Update documentation if behavior changes
- Ensure all enhancements are tested

Deliverable: Enhanced feature with improvements implemented, tested, and documented")

Phase 5: Verification
Goal: Validate enhancements work correctly

Actions:
- Run tests if they exist
- Example: !{bash npm test 2>/dev/null || pytest 2>/dev/null || echo "No tests found"}
- Run type checking if applicable
- Example: !{bash npm run typecheck 2>/dev/null || mypy . 2>/dev/null || echo "No type checking"}
- Verify the feature still works as expected
- Check for any breaking changes

Phase 6: Summary
Goal: Document completed enhancements

Actions:
- Summarize all improvements made:
  - Performance optimizations applied
  - New edge cases handled
  - UX improvements added
  - Code quality enhancements
- List files modified
- Note any breaking changes or migration steps needed
- Suggest follow-up enhancements if applicable

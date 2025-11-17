---
description: Generate complete test suites automatically by reading package.json and analyzing project structure
argument-hint: "[project-path]"
allowed-tools: ["Read", "Write", "Glob", "Bash", "Task"]
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


Goal: Automatically generate comprehensive test suites (Jest, React Testing Library, Playwright, Newman) by analyzing package.json testing configuration and project structure

## Phase 1: Discovery

Actions:

Read package.json to detect testing configuration:

@package.json

Check for existing test setup files:

!{Glob **/{jest,vitest,playwright}.config.{js,ts}}
!{Glob **/{jest,vitest}.setup.{js,ts}}

Analyze project structure to identify components/routes to test:

!{Glob src/**/*.{ts,tsx,js,jsx}}
!{Glob app/**/*.{ts,tsx,js,jsx}}
!{Glob pages/**/*.{ts,tsx,js,jsx}}

## Phase 2: Generate Test Suites

Actions:

Launch test-suite-generator agent to create comprehensive test files:

Task(description="Generate test suite", subagent_type="testing:test-suite-generator", prompt="Generate complete test suites for this project.

Project path: $ARGUMENTS

Package.json testing config:
@package.json

Existing test setup:
- Configuration files detected
- Testing frameworks detected (Jest/Vitest/Playwright)

Project structure:
- Components/routes to test
- Existing test coverage gaps

Tasks:
1. Analyze testing configuration and dependencies
2. Generate test configuration files (if missing)
3. Create test utilities and setup files
4. Generate test files for all components/routes/utils
5. Set up mocks for external dependencies
6. Configure test coverage thresholds
7. Verify all tests pass

Deliverable: Complete test suite with passing tests and proper coverage")

## Phase 3: Verification

Actions:

After test generation, verify tests pass:

!{bash npm test}

Check test coverage:

!{bash npm test -- --coverage}

## Phase 4: Summary

Actions:

Display results:

**Test Suite Generated:**
- Configuration files created/updated
- Test files generated
- Test utilities created
- Mocks configured
- Coverage thresholds set

**Test Results:**
- All tests passing
- Coverage percentage

**Next Steps:**
- Review generated tests
- Add custom test scenarios as needed
- Run `/testing:test` to execute full suite

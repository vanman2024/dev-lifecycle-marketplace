---
description: Review implementation code quality, security, and test coverage
argument-hint: <spec-number> [--generate-tests]
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

Goal: Validate code quality, verify requirements met, and identify missing tests

Core Principles:
- Security first - scan for hardcoded secrets before anything else
- Requirements-driven - verify all spec requirements implemented
- Test coverage - identify gaps and recommend specific tests

Phase 1: Discovery
Goal: Parse arguments and locate spec

Actions:
- Parse $ARGUMENTS for spec number and flags
- Check for --generate-tests flag
- Find spec directory (phase-nested first, then legacy):
  !{bash find specs/phase-* -type d -name "*$SPEC_NUMBER*" 2>/dev/null | head -1 || find specs/features -type d -name "*$SPEC_NUMBER*" 2>/dev/null | head -1}
- Store as SPEC_DIR
- Verify spec.md exists: !{bash test -f "$SPEC_DIR/spec.md" && echo "✓ Found" || echo "✗ Missing"}

Phase 2: Validation
Goal: Launch code-validator agent

Actions:

Task(description="Validate code quality", subagent_type="quality:code-validator", prompt="You are the code-validator agent. Validate implementation for spec $ARGUMENTS.

**Phase 1: Security Scan**
CRITICAL: Scan for hardcoded API keys, passwords, secrets FIRST.
If any found, STOP and report immediately.

**Phase 2: Requirements Verification**
Load spec.md and verify each functional requirement has:
- Implementation files
- Correct logic
- Error handling
- Input validation

**Phase 3: Test Coverage Analysis**
Find existing tests and identify:
- Untested functions
- Missing edge cases
- Uncovered error paths
- Missing integration tests

**Phase 4: Test Recommendations**
Generate specific test cases for:
- API tests (Newman/Postman format)
- E2E tests (Playwright format)
- Unit tests (framework-specific)

**Phase 5: Report**
Generate comprehensive report with:
- 🔒 Security findings (critical issues first)
- ✅ Requirements status (X/Total implemented)
- 🧪 Test coverage analysis (% coverage, gaps)
- 📝 Recommended test cases (specific, runnable)
- 🎯 Summary (health score, priority actions)

Provide specific file paths, line numbers, and code examples.")

Phase 3: Summary
Goal: Display results and next steps

Actions:
- Display validation report from agent
- Show overall health score
- Highlight critical security issues (if any)
- List priority actions
- If --generate-tests flag provided:
  - Offer to generate test files
  - Ask which test types to create
- Suggest next steps:
  - Fix security violations immediately
  - Implement missing requirements
  - Add recommended tests
  - Run `/quality:test` to verify

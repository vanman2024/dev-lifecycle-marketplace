# Old Test Infrastructure Archive

**Archived:** 2025-10-29
**Reason:** Experimental/testing files superseded by production plugin framework

## What This Was

These files were experimental work for testing Playwright MCP integration. They were created during early exploration of how to integrate Playwright testing with MCP servers at "key moments" in the development workflow.

## Why Archived

1. **Not Part of Plugin Framework**: These are standalone test scripts, not part of the Claude Code plugin architecture
2. **Superseded by Production Skills**: The `quality` plugin now has a proper `playwright-e2e` skill with 16 files and production-ready patterns
3. **Hardcoded Test Scenarios**: These files contain example/demo code rather than reusable plugin components

## Archived Files

### Test Infrastructure
- **`key-moments.sh`** - Script for triggering tests at workflow moments (pre-commit, pre-push, deployment)
- **`test-automation.js`** - Test runner using Playwright MCP
- **`playwright-mcp-wrapper.js`** - JavaScript wrapper for Playwright MCP client
- **`test-real-mcp.js`** - Integration test for MCP server

### Dependencies
- **`package.json`** - Node.js dependencies for test scripts
- **`package-lock.json`** - Locked dependency versions

### Historical Documentation
- **`CONSOLIDATION-PLAN.md`** - Original plan from 28-plugin consolidation to 6 lifecycle plugins (superseded by v2.0 rebuild)

## What Replaced This

The **quality plugin** (`plugins/quality/`) now provides production-ready testing capabilities:

### Playwright E2E Skill
- **Location:** `plugins/quality/skills/playwright-e2e/`
- **Contents:** 16 files with scripts, templates, and examples
- **SKILL.md:** 204 lines of comprehensive documentation
- **Features:**
  - Page Object Model (POM) patterns
  - Visual regression testing
  - CI/CD integration templates
  - Debug and execution scripts
  - Production-ready test structures

### Security Patterns Skill
- **Location:** `plugins/quality/skills/security-patterns/`
- **Contents:** 16 files with comprehensive security scanning
- **SKILL.md:** 226 lines of documentation
- **Features:**
  - Secret detection (50+ types)
  - OWASP Top 10 scanning
  - Multi-language dependency scanning
  - Compliance validation

## If You Need This Code

These archived files remain accessible for reference:
- Study the MCP integration patterns
- Review the test scenario structures
- Reference the git hook integration approach

However, for production use, refer to the **quality plugin skills** which provide properly structured, framework-integrated testing capabilities.

---

**Note:** This archive preserves historical work while keeping the marketplace root directory clean and focused on production documentation.

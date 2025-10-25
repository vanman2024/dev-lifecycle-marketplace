---
allowed-tools: Task(*), Bash(*), Read(*), Grep(*)
description: Security vulnerability scanning and analysis
argument-hint: [--fix]
---

**Arguments**: $ARGUMENTS

## Overview

Scans the project for security vulnerabilities, exposed secrets, and security best practices.

## Step 1: Detect Project Type

!{bash test -f package.json && echo "Node.js" || test -f requirements.txt && echo "Python" || test -f Cargo.toml && echo "Rust" || test -f go.mod && echo "Go" || echo "Unknown"}

## Step 2: Scan for Exposed Secrets

!{bash grep -r "api[_-]key\|password\|secret\|token" . --include="*.js" --include="*.ts" --include="*.py" --include="*.env" 2>/dev/null | grep -v "node_modules" | head -20}

## Step 3: Check Dependencies for Vulnerabilities

Run security audit based on project type:

!{bash if test -f package.json; then npm audit || echo "No vulnerabilities found"; elif test -f requirements.txt; then pip-audit 2>/dev/null || echo "pip-audit not available"; elif test -f Cargo.toml; then cargo audit 2>/dev/null || echo "cargo-audit not available"; fi}

## Step 4: Invoke Security Scanner Agent

Task(
  description="Security analysis",
  subagent_type="security-scanner",
  prompt="Perform comprehensive security analysis of the project.

**Security Checks:**
- Exposed API keys and secrets
- SQL injection vulnerabilities
- XSS vulnerabilities
- Authentication/authorization issues
- Insecure dependencies
- Hardcoded credentials
- Unsafe file operations
- Missing security headers

**Analysis:**
- Scan all code files
- Check configuration files
- Review dependency versions
- Identify security patterns

**Deliverables:**
- Security findings with severity (critical/high/medium/low)
- Specific file locations and line numbers
- Remediation recommendations
- Quick fixes if possible"
)

## Step 5: Apply Fixes (if requested)

If $ARGUMENTS contains --fix:
- Remove exposed secrets
- Update vulnerable dependencies
- Apply security patches

## Step 6: Report Results

Display security report:
- Critical issues found
- High priority vulnerabilities
- Recommended actions
- Dependencies to update

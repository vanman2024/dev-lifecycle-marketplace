---
allowed-tools: Task(*), Bash(*), Read(*), Grep(*)
description: Compliance checking and licensing validation
argument-hint: [--report]
---

**Arguments**: $ARGUMENTS

## Overview

Checks project compliance with licensing requirements, code standards, and regulatory guidelines.

## Step 1: Check License Files

!{bash test -f LICENSE && echo "✅ LICENSE file exists" || echo "⚠️  LICENSE file missing"}
!{bash test -f LICENSE.md && echo "✅ LICENSE.md exists" || echo "INFO: No LICENSE.md"}

## Step 2: Check Dependency Licenses

Scan dependencies for license compliance:

!{bash if test -f package.json; then npx license-checker --summary 2>/dev/null || echo "license-checker not available"; elif test -f requirements.txt; then pip-licenses 2>/dev/null || echo "pip-licenses not available"; fi}

## Step 3: Check Copyright Headers

!{bash find . -name "*.js" -o -name "*.ts" -o -name "*.py" | head -10 | while read f; do head -5 "$f" | grep -q "Copyright" && echo "✅ $f" || echo "⚠️  $f - missing copyright"; done}

## Step 4: Invoke Compliance Checker Agent

Task(
  description="Compliance analysis",
  subagent_type="compliance-checker",
  prompt="Perform comprehensive compliance analysis of the project.

**Compliance Checks:**
- License file presence and validity
- Dependency license compatibility
- Copyright headers in source files
- Attribution requirements met
- Code of conduct presence
- Security policy documented
- Privacy policy if handling user data
- Accessibility compliance (WCAG if web app)

**Regulatory Checks:**
- GDPR compliance (if applicable)
- CCPA compliance (if applicable)
- HIPAA compliance (if healthcare)
- SOC2 requirements (if enterprise)

**Analysis:**
- Scan all license files
- Review dependency licenses
- Check documentation completeness
- Verify compliance artifacts

**Deliverables:**
- Compliance status report
- Missing compliance items
- License conflicts identified
- Remediation recommendations
- Required documentation"
)

## Step 5: Generate Report (if requested)

If $ARGUMENTS contains --report:

!{bash mkdir -p reports && echo "# Compliance Report - $(date)" > reports/compliance-$(date +%Y%m%d).md}

## Step 6: Display Results

Show compliance summary:
- License compliance status
- Missing compliance items
- Dependency license issues
- Required actions

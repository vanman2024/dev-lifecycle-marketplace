---
description: Run security scans and vulnerability checks
argument-hint: [scan-type]
allowed-tools: Task, Read, Bash, Glob, Grep
---

**Arguments**: $ARGUMENTS

Goal: Execute comprehensive security scanning including dependency vulnerabilities, code security issues, and compliance checks

Core Principles:
- Multi-layer security scanning
- Dependency vulnerability detection
- Code security analysis
- Compliance verification
- Clear remediation guidance

## Phase 1: Discovery
Goal: Identify security scanning tools and project structure

Actions:
- Load project context:
  @.claude/project.json
- Check for security tools installed:
  - npm audit: !{bash which npm &>/dev/null && echo "✅ npm available" || echo "❌"}
  - Safety (Python): !{bash which safety &>/dev/null && echo "✅ safety installed" || echo "❌ Install: pip install safety"}
  - Bandit (Python): !{bash which bandit &>/dev/null && echo "✅ bandit installed" || echo "❌"}
  - Snyk: !{bash which snyk &>/dev/null && echo "✅ snyk installed" || echo "❌"}
- Detect project language:
  - Node.js: !{bash test -f package.json && echo "✅ Node.js project"}
  - Python: !{bash test -f requirements.txt -o -f pyproject.toml && echo "✅ Python project"}
  - Both: Multi-language project
- Determine scan scope from arguments:
  - Empty or "all": All security scans
  - "dependencies": Dependency vulnerabilities only
  - "code": Code security issues only
  - "secrets": Secret detection only

## Phase 2: Analysis
Goal: Analyze current security posture

Actions:
- Scan for dependency files:
  !{bash find . -name "package.json" -o -name "requirements.txt" -o -name "pyproject.toml" -o -name "Cargo.toml" 2>/dev/null | head -10}
- Check for existing security reports:
  !{bash find . -name "security-report*" -o -name "audit-report*" 2>/dev/null}
- Identify sensitive files that need protection:
  !{bash find . -name "*.env*" -o -name "*secret*" -o -name "*key*" 2>/dev/null | head -10}
- Count total dependencies to scan:
  - npm: !{bash cat package.json 2>/dev/null | grep -c '"dependencies"\|"devDependencies"' || echo "0"}
  - pip: !{bash cat requirements.txt 2>/dev/null | wc -l || echo "0"}

## Phase 3: Planning
Goal: Prepare security scan strategy

Actions:
- Create security reports directory:
  !{bash mkdir -p security-reports && echo "✅ Created security-reports/"}
- Plan scan execution order:
  1. Dependency vulnerability scans
  2. Code security analysis
  3. Secret detection
  4. Compliance checks
- Allocate report files:
  - security-reports/dependency-scan.json
  - security-reports/code-scan.json
  - security-reports/secrets-scan.json
  - security-reports/summary.md
- Determine severity thresholds for failures

## Phase 4: Implementation
Goal: Invoke security-scanner agent to execute scans

Actions:

Launch the security-scanner agent to perform comprehensive security analysis.

Provide the agent with:
- Context: Scan type from arguments ($ARGUMENTS)
- Project language and structure detected in Phase 1
- Security tools available
- Requirements:
  - Run npm audit for Node.js dependencies
  - Run safety/bandit for Python dependencies and code
  - Scan for secrets in codebase (API keys, tokens)
  - Check for security best practices violations
  - Analyze authentication/authorization code
  - Check for SQL injection, XSS, CSRF vulnerabilities
  - Generate detailed security reports
- Deliverables:
  - security-reports/dependency-scan.json (vulnerability list)
  - security-reports/code-scan.json (code security issues)
  - security-reports/summary.md (executive summary)
  - Remediation recommendations for each finding
  - Severity ratings (Critical, High, Medium, Low)

## Phase 5: Verification
Goal: Validate security scan execution and results

Actions:
- Check security reports created:
  !{bash test -d security-reports && ls -la security-reports/}
- Count security findings by severity:
  !{bash grep -r "CRITICAL\|HIGH" security-reports/ 2>/dev/null | wc -l}
  !{bash grep -r "MEDIUM\|LOW" security-reports/ 2>/dev/null | wc -l}
- Verify all scan types completed successfully
- Check for critical vulnerabilities requiring immediate action

## Phase 6: Summary
Goal: Report security scan results and recommendations

Actions:
- Display security scan summary:
  - Total vulnerabilities found: X
  - Critical: Y
  - High: Z
  - Medium: A
  - Low: B
- Show findings by category:
  - Dependency vulnerabilities: X found
  - Code security issues: Y found
  - Secrets detected: Z found
  - Compliance issues: A found
- Provide remediation guidance:
  - "Update vulnerable dependencies: npm audit fix"
  - "Review critical code security issues in security-reports/code-scan.json"
  - "Remove detected secrets and rotate credentials"
  - "Address compliance violations before deployment"
- Suggest next steps:
  - "Fix critical and high severity issues immediately"
  - "Run /quality:security again after fixes"
  - "Add security scanning to CI/CD pipeline"
  - "Review security-reports/summary.md for details"
- Exit with non-zero code if critical vulnerabilities found

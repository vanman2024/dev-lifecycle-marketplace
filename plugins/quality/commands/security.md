---
description: Run security scans and vulnerability checks
argument-hint: [scan-type]
allowed-tools: Task, Read, Bash, Glob, Grep
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

Goal: Execute comprehensive security scanning including dependency vulnerabilities, code security issues, and compliance checks

Core Principles:
- Multi-layer security scanning
- Dependency vulnerability detection
- Code security analysis
- Compliance verification
- Clear remediation guidance

## Available Skills

This commands has access to the following skills from the quality plugin:

- **api-schema-analyzer**: Analyze OpenAPI and Postman schemas for MCP tool generation. Use when analyzing API specifications, extracting endpoint information, generating tool signatures, or when user mentions OpenAPI, Swagger, API schema, endpoint analysis.
- **newman-runner**: Run and analyze Newman (Postman CLI) tests. Use when running API tests, validating Postman collections, testing HTTP endpoints, or when user mentions Newman, Postman tests, API validation.
- **newman-testing**: Newman/Postman collection testing patterns for API testing with environment variables, test assertions, and reporting. Use when building API tests, running Newman collections, testing REST APIs, validating HTTP responses, creating Postman collections, configuring API test environments, generating test reports, or when user mentions Newman, Postman, API testing, collection runner, integration tests, API validation, test automation, or CI/CD API testing.
- **playwright-e2e**: Playwright end-to-end testing patterns including page object models, test scenarios, visual regression, and CI/CD integration. Use when building E2E tests, testing web applications, automating browser interactions, implementing page objects, running Playwright tests, debugging E2E failures, or when user mentions Playwright, E2E, browser automation, page object model, POM, visual regression, or end-to-end testing.
- **postman-collection-manager**: Import, export, and manage Postman collections. Use when working with Postman collections, importing OpenAPI specs, exporting collections, or when user mentions Postman import, collection management, API collections.
- **security-patterns**: Security vulnerability scanning, secret detection, dependency auditing, and OWASP best practices. Use when performing security audits, scanning for vulnerabilities, detecting exposed secrets, checking dependencies, validating security headers, implementing OWASP patterns, or when user mentions security, vulnerabilities, secrets, CVE, OWASP, npm audit, security headers, or penetration testing.

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

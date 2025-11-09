# Security Plugin

Security infrastructure for projects including git hooks, vulnerability scanning, secret detection, and OWASP best practices.

## Overview

This plugin provides comprehensive security tooling for protecting applications throughout the development lifecycle:
- **Git Hooks**: Pre-commit secret scanning, commit message validation, security checks
- **Vulnerability Scanning**: Dependency auditing, CVE detection, security headers validation
- **Secret Detection**: Prevent hardcoded API keys, credentials from being committed
- **OWASP Patterns**: Implementation of OWASP Top 10 security best practices

## Commands

- `/foundation:hooks-setup` - Install standardized git hooks (secret scanning, commit validation, security checks)
- `/quality:security` - Run comprehensive security scans (vulnerability detection, secret scanning, dependency auditing)

## Skills

- **security-patterns**: Security vulnerability scanning, secret detection, dependency auditing, and OWASP best practices. Use when performing security audits, scanning for vulnerabilities, detecting exposed secrets, checking dependencies, validating security headers, implementing OWASP patterns, or when user mentions security, vulnerabilities, secrets, CVE, OWASP, npm audit, security headers, or penetration testing.

## Agents

None currently - security operations are handled via commands and skills.

## Usage

```bash
# Setup git hooks for security
/foundation:hooks-setup

# Run comprehensive security scan
/quality:security

# Run specific security checks
/quality:security secrets     # Secret detection only
/quality:security deps        # Dependency audit only
/quality:security headers     # Security headers validation
```

## Dependencies

- Git (for hooks)
- npm (for npm audit)
- Python safety (for Python dependency scanning)
- Bandit (for Python security scanning)
- truffleHog or gitleaks (for secret detection)

## Status

Active - Production ready

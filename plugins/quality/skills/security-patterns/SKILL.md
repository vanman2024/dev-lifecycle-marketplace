---
name: Security Scanning
description: Scan for security vulnerabilities and exposed secrets. Use when performing security audits, checking for vulnerabilities, scanning dependencies, detecting exposed secrets, or when user mentions security, vulnerabilities, secrets, API keys, security audit, npm audit, or CVE scanning.
---

# Security Scanning

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Provides security vulnerability scanning, secret detection, dependency auditing, and security best practices validation for projects.

## Instructions

### Secret Detection

1. Scan code files for exposed API keys, passwords, tokens
2. Check environment files for hardcoded credentials
3. Identify potential secret leaks in git history

### Dependency Vulnerability Scanning

1. Use `scripts/scan-dependencies.sh` to check for known vulnerabilities
2. Generate vulnerability reports with severity ratings
3. Provide remediation recommendations

### Security Best Practices

1. Check for common security anti-patterns
2. Validate authentication/authorization implementations
3. Review input validation and sanitization

## Available Scripts

- **scan-secrets.sh**: Detects exposed secrets and credentials
- **scan-dependencies.sh**: Checks dependencies for vulnerabilities
- **check-headers.sh**: Validates security headers
- **generate-security-report.sh**: Creates comprehensive security report

## Templates

- **security-report.template**: Security audit report format
- **secret-patterns.txt**: Regex patterns for secret detection
- **security-checklist.md**: Security best practices checklist

## Requirements

- Scan all code files recursively (excluding node_modules, venv)
- Support multiple languages and frameworks
- Provide severity ratings (critical/high/medium/low)
- Include specific file locations and line numbers
- Generate actionable remediation steps

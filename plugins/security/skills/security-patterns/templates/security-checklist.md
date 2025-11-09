# Comprehensive Security Checklist

Based on OWASP Top 10 2021 and industry best practices.

## A01:2021 - Broken Access Control

### Authorization
- [ ] Authorization checks implemented on all protected routes and endpoints
- [ ] Access control decisions made server-side, not client-side
- [ ] Direct object references (IDs in URLs) validated against user permissions
- [ ] Admin/privileged functions protected with proper authorization
- [ ] API endpoints have proper authentication and authorization
- [ ] File uploads restricted by user permissions
- [ ] CORS configured correctly (not using wildcard * in production)
- [ ] Cross-tenant data access prevented in multi-tenant systems

### Session Management
- [ ] Session IDs regenerated after login
- [ ] Session timeout configured appropriately
- [ ] Logout functionality properly terminates sessions
- [ ] Concurrent session limits enforced where appropriate

## A02:2021 - Cryptographic Failures

### Data Encryption
- [ ] Sensitive data encrypted at rest using strong algorithms (AES-256)
- [ ] All traffic encrypted in transit using TLS 1.2+ (HTTPS)
- [ ] Database connections encrypted
- [ ] API communications use HTTPS exclusively
- [ ] TLS certificates valid and not self-signed in production

### Key Management
- [ ] API keys, passwords, secrets stored in environment variables (never hardcoded)
- [ ] Secrets not committed to version control (.env in .gitignore)
- [ ] Production secrets different from development/staging
- [ ] Key rotation policy in place
- [ ] Secrets management service used (AWS Secrets Manager, HashiCorp Vault, etc.)

### Cryptographic Algorithms
- [ ] Strong cryptographic algorithms used (AES-256, RSA-2048+, SHA-256+)
- [ ] Weak algorithms removed (MD5, SHA1, DES, RC4)
- [ ] Secure random number generators used (not Math.random())
- [ ] Password hashing uses bcrypt, Argon2, or PBKDF2
- [ ] Salts generated uniquely per user for password hashing

## A03:2021 - Injection

### SQL Injection
- [ ] Parameterized queries/prepared statements used exclusively
- [ ] ORM used correctly (avoiding raw queries with concatenation)
- [ ] Input validation on all user inputs
- [ ] Least privilege database accounts (app doesn't use root/admin)
- [ ] Stored procedures validated for injection vulnerabilities

### Command Injection
- [ ] Shell commands avoid user input or use allowlists
- [ ] exec(), eval(), system() calls reviewed and minimized
- [ ] Input sanitization for system commands
- [ ] Child processes spawned with explicit arguments (not shell strings)

### NoSQL Injection
- [ ] NoSQL queries parameterized or sanitized
- [ ] MongoDB operators ($where, $regex) used carefully
- [ ] JSON input validated before database queries

### LDAP/XPath Injection
- [ ] LDAP queries use proper escaping
- [ ] XPath queries parameterized
- [ ] Special characters escaped in directory queries

### Template Injection
- [ ] Template engines configured to escape output by default
- [ ] User input not directly rendered in templates
- [ ] Server-side template injection risks assessed

## A04:2021 - Insecure Design

### Threat Modeling
- [ ] Threat model created for application
- [ ] Attack surface minimized
- [ ] Security requirements defined in design phase
- [ ] Security architecture review completed

### Rate Limiting & Resource Controls
- [ ] Rate limiting implemented on authentication endpoints
- [ ] Rate limiting on API endpoints
- [ ] Request timeouts configured
- [ ] Maximum request size limits enforced
- [ ] Resource quotas prevent denial of service
- [ ] CAPTCHA or similar challenge-response on sensitive actions

### Business Logic
- [ ] Business logic flaws considered (race conditions, workflow bypasses)
- [ ] Transaction atomicity maintained
- [ ] Critical operations require re-authentication
- [ ] Multi-step processes validated at each stage

## A05:2021 - Security Misconfiguration

### Configuration Management
- [ ] Debug mode disabled in production
- [ ] Default credentials changed on all systems
- [ ] Unnecessary features/services disabled
- [ ] Error messages don't leak sensitive information
- [ ] Stack traces disabled in production
- [ ] Directory listing disabled
- [ ] Admin interfaces not publicly accessible

### Dependencies & Updates
- [ ] All dependencies up to date
- [ ] Security patches applied promptly
- [ ] Automated dependency scanning enabled
- [ ] Dependency lock files committed (package-lock.json, Pipfile.lock)

### Security Headers
- [ ] Content-Security-Policy configured
- [ ] Strict-Transport-Security (HSTS) enabled
- [ ] X-Frame-Options set to DENY or SAMEORIGIN
- [ ] X-Content-Type-Options: nosniff
- [ ] Referrer-Policy configured
- [ ] Permissions-Policy restricts browser features
- [ ] CORS headers properly configured

### Cloud Security
- [ ] S3 buckets/blob storage not publicly accessible
- [ ] IAM roles follow least privilege
- [ ] Security groups restrict access appropriately
- [ ] Cloud resource tagging and inventory maintained

## A06:2021 - Vulnerable and Outdated Components

### Dependency Management
- [ ] All dependencies documented and inventoried
- [ ] npm audit / pip-audit / cargo audit run regularly
- [ ] No known vulnerable dependencies (critical/high severity)
- [ ] Unused dependencies removed
- [ ] Dependencies from trusted sources only
- [ ] Subresource Integrity (SRI) used for CDN resources
- [ ] Automated vulnerability scanning in CI/CD

### Version Management
- [ ] Framework versions supported and maintained
- [ ] EOL (End-of-Life) software replaced
- [ ] Regular update schedule established
- [ ] Changelogs reviewed before updates

## A07:2021 - Identification and Authentication Failures

### Password Security
- [ ] Strong password policy enforced (minimum 8 characters, complexity)
- [ ] Password strength meter implemented
- [ ] Passwords hashed with bcrypt/Argon2 (minimum 10 rounds)
- [ ] Compromised password list checked (haveibeenpwned API)
- [ ] Password history prevents reuse of recent passwords

### Multi-Factor Authentication
- [ ] MFA available for all users
- [ ] MFA enforced for administrative accounts
- [ ] TOTP or hardware tokens supported
- [ ] Backup codes provided for account recovery

### Account Security
- [ ] Account enumeration prevented (generic error messages)
- [ ] Brute force protection (account lockout, CAPTCHA)
- [ ] Credential stuffing defenses (rate limiting, behavioral analysis)
- [ ] Session fixation prevented (regenerate session after login)
- [ ] Remember me functionality uses secure tokens
- [ ] Password reset tokens expire quickly (15-30 minutes)
- [ ] Password reset links single-use only

### Authentication Mechanisms
- [ ] OAuth 2.0 / OpenID Connect implemented correctly
- [ ] JWT tokens signed and validated
- [ ] JWT tokens have appropriate expiration
- [ ] Refresh tokens stored securely
- [ ] API keys transmitted securely (Authorization header, not URL)

## A08:2021 - Software and Data Integrity Failures

### Code Integrity
- [ ] Code signing implemented for releases
- [ ] CI/CD pipeline secured
- [ ] Dependencies integrity checked (package lock files)
- [ ] Subresource Integrity for CDN resources
- [ ] Auto-updates from trusted sources only

### Deserialization
- [ ] Deserialization of untrusted data avoided
- [ ] JSON used instead of pickle/serialize when possible
- [ ] Input validation before deserialization
- [ ] Deserialization libraries up to date

### Supply Chain Security
- [ ] Third-party code reviewed before integration
- [ ] npm packages verified before installation
- [ ] Dependency confusion attacks mitigated (private registries)
- [ ] Build reproducibility ensured

## A09:2021 - Security Logging and Monitoring Failures

### Logging
- [ ] Security events logged (login, logout, failed auth, privilege escalation)
- [ ] Authentication failures logged
- [ ] Input validation failures logged
- [ ] High-value transactions logged
- [ ] Log format consistent and parseable
- [ ] Sensitive data NOT logged (passwords, tokens, PII)
- [ ] Logs tamper-resistant (append-only, remote logging)

### Monitoring
- [ ] Real-time alerting on suspicious activities
- [ ] Failed login attempts monitored
- [ ] Unusual API usage detected
- [ ] Error rate thresholds trigger alerts
- [ ] Security dashboard implemented
- [ ] Log retention policy defined and enforced

### Incident Response
- [ ] Incident response plan documented
- [ ] Security team contact information available
- [ ] Backup and recovery procedures tested
- [ ] Post-incident analysis process defined

## A10:2021 - Server-Side Request Forgery (SSRF)

### SSRF Prevention
- [ ] User-supplied URLs validated against allowlist
- [ ] Internal network access from app server restricted
- [ ] URL scheme allowlist enforced (http/https only)
- [ ] IP address validation (block private ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- [ ] Redirect following disabled or restricted
- [ ] DNS rebinding attacks mitigated
- [ ] Cloud metadata endpoints blocked (169.254.169.254)

## Additional Security Controls

### Input Validation
- [ ] All user inputs validated (type, length, format, range)
- [ ] Allowlist validation preferred over blocklist
- [ ] File upload validation (type, size, content)
- [ ] XML external entity (XXE) attacks prevented
- [ ] Null byte injection prevented

### Output Encoding
- [ ] HTML output encoded (XSS prevention)
- [ ] JavaScript context encoding implemented
- [ ] URL encoding for URL parameters
- [ ] SQL encoding for SQL contexts
- [ ] Context-aware output encoding throughout

### API Security
- [ ] API versioning implemented
- [ ] API documentation kept private
- [ ] GraphQL query depth limiting
- [ ] REST API pagination implemented
- [ ] API request/response size limits
- [ ] API authentication required on all endpoints
- [ ] API rate limiting per user/IP

### Cookie Security
- [ ] Cookies use Secure flag (HTTPS only)
- [ ] Cookies use HttpOnly flag (no JavaScript access)
- [ ] SameSite attribute set (Strict or Lax)
- [ ] Cookie expiration set appropriately
- [ ] Sensitive data not stored in cookies

### File Operations
- [ ] File uploads validated (type, size, content)
- [ ] Uploaded files stored outside webroot
- [ ] File permissions restricted (not executable)
- [ ] Virus/malware scanning on uploads
- [ ] Path traversal attacks prevented

### Mobile Security (if applicable)
- [ ] Certificate pinning implemented
- [ ] Biometric authentication supported
- [ ] Root/jailbreak detection
- [ ] Sensitive data not stored in app logs
- [ ] API keys obfuscated in mobile apps

### DevSecOps
- [ ] Security scanning in CI/CD pipeline
- [ ] Pre-commit hooks for secret detection
- [ ] Automated SAST/DAST scans
- [ ] Container image scanning
- [ ] Infrastructure as Code security scanning
- [ ] Security testing in QA environment

## Compliance & Standards

### Regulatory Compliance
- [ ] GDPR compliance (if handling EU data)
- [ ] CCPA compliance (if handling CA data)
- [ ] PCI DSS compliance (if handling payment cards)
- [ ] HIPAA compliance (if handling health data)
- [ ] SOC 2 compliance (if enterprise SaaS)

### Privacy
- [ ] Privacy policy published and up to date
- [ ] Data retention policy enforced
- [ ] User data export functionality (GDPR right to portability)
- [ ] User data deletion functionality (GDPR right to erasure)
- [ ] Consent management implemented
- [ ] Third-party data sharing documented

### Documentation
- [ ] Security architecture documented
- [ ] Data flow diagrams created
- [ ] Security runbooks available
- [ ] Penetration test results documented
- [ ] Security training completed by team

---

**Last Updated:** 2025-10-29
**Version:** 2.0 (OWASP Top 10 2021)
**Review Frequency:** Quarterly or after major changes

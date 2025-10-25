# Security Checklist

## Authentication & Authorization
- [ ] Authentication implemented correctly
- [ ] Authorization checks on all protected routes
- [ ] Session management secure
- [ ] Password storage uses strong hashing (bcrypt, Argon2)
- [ ] Multi-factor authentication available

## Input Validation
- [ ] All user inputs validated and sanitized
- [ ] SQL injection protection in place
- [ ] XSS protection implemented
- [ ] CSRF tokens used for state-changing operations
- [ ] File upload validation and restrictions

## Data Protection
- [ ] Sensitive data encrypted at rest
- [ ] Sensitive data encrypted in transit (HTTPS/TLS)
- [ ] API keys stored in environment variables
- [ ] No hardcoded credentials in code
- [ ] Secrets not committed to version control

## Dependencies
- [ ] All dependencies up to date
- [ ] No known vulnerabilities in dependencies
- [ ] Dependency integrity checks enabled
- [ ] Minimal dependencies (attack surface reduction)

## Headers & Configuration
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options)
- [ ] CORS configured correctly
- [ ] Rate limiting implemented
- [ ] Error messages don't leak sensitive information
- [ ] Debug mode disabled in production

## Infrastructure
- [ ] Firewall rules configured
- [ ] Database access restricted
- [ ] Logs don't contain sensitive data
- [ ] Monitoring and alerting enabled
- [ ] Backup and recovery plan in place

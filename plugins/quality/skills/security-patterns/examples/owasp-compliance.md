# OWASP Top 10 Compliance Example

Validating application compliance against OWASP Top 10 2021 using security pattern detection.

## Scenario

You're preparing for a security audit and need to validate your web application against OWASP Top 10 2021 standards.

## Step 1: Run OWASP Scan

```bash
bash /path/to/scripts/scan-owasp.sh /path/to/codebase > owasp-scan.json
```

## Step 2: Analyze Results by Category

### Example Findings

```json
{
  "total_findings": 12,
  "owasp_categories": {
    "A01": { "name": "Broken Access Control", "count": 3 },
    "A02": { "name": "Cryptographic Failures", "count": 2 },
    "A03": { "name": "Injection", "count": 4 },
    "A05": { "name": "Security Misconfiguration", "count": 2 },
    "A07": { "name": "Authentication Failures", "count": 1 }
  }
}
```

## Step 3: Address Findings by Priority

### A01: Broken Access Control (3 findings)

**Finding 1: Missing Authorization Check**
```javascript
// Vulnerable
app.get('/api/admin/users', async (req, res) => {
  const users = await User.findAll();
  res.json(users);
});

// Fixed
app.get('/api/admin/users', requireAuth, requireAdmin, async (req, res) => {
  const users = await User.findAll();
  res.json(users);
});
```

### A02: Cryptographic Failures (2 findings)

**Finding: Weak Hashing Algorithm**
```python
# Vulnerable
import hashlib
password_hash = hashlib.md5(password.encode()).hexdigest()

# Fixed
import bcrypt
password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))
```

### A03: Injection (4 findings)

**Finding: SQL Injection Risk**
```javascript
// Vulnerable
const query = `SELECT * FROM products WHERE id = ${req.params.id}`;

// Fixed
const query = 'SELECT * FROM products WHERE id = ?';
db.query(query, [req.params.id]);
```

## Step 4: Complete Compliance Checklist

Use `templates/security-checklist.md` to validate all OWASP categories systematically.

### Example Checklist Progress

```
A01: Broken Access Control
  [x] Authorization on protected routes
  [x] Server-side access control
  [ ] Direct object reference validation  ← NEEDS FIX
  [x] CORS properly configured

A02: Cryptographic Failures
  [x] TLS 1.2+ enforced
  [ ] Strong password hashing            ← NEEDS FIX
  [x] Secrets in environment variables
  [x] Database connections encrypted
```

## Step 5: Generate Compliance Report

```bash
bash scripts/generate-security-report.sh ./scan-results html owasp-compliance-report
```

## Step 6: Remediate and Re-scan

After fixes:
```bash
bash scripts/scan-owasp.sh ./codebase > owasp-scan-after.json
```

## Best Practices

1. **Regular scans** - Before each release
2. **Code review checklist** - Include OWASP in PR reviews
3. **Security training** - Educate team on OWASP patterns
4. **Automated testing** - Integrate into CI/CD
5. **Track progress** - Monitor compliance over time

## Resources

- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [Security Checklist](../templates/security-checklist.md)
- [Remediation Guide](../templates/vulnerability-remediation.md)

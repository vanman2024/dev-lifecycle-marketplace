# Basic Secret Scanning Example

Step-by-step walkthrough of scanning a codebase for exposed secrets and credentials.

## Scenario

You have a Node.js application and want to check for exposed API keys, passwords, and tokens before committing to version control.

## Project Structure

```
my-app/
├── src/
│   ├── config/
│   │   ├── database.js      # May contain database credentials
│   │   └── api-keys.js      # May contain API keys
│   ├── services/
│   │   └── payment.js       # May contain Stripe keys
│   └── index.js
├── .env                     # Should be in .gitignore
├── .env.example             # Template with no real values
├── package.json
└── README.md
```

## Step 1: Run Basic Secret Scan

```bash
cd /path/to/my-app
bash /path/to/scripts/scan-secrets.sh . > secrets-scan.json
```

## Step 2: Review Results

### Example Output (secrets-scan.json)

```json
{
  "scan_timestamp": "2025-10-29T14:30:00Z",
  "target_directory": "./my-app",
  "total_findings": 3,
  "severity_breakdown": {
    "critical": 2,
    "high": 1,
    "medium": 0,
    "low": 0
  },
  "findings": [
    {
      "id": 1,
      "type": "aws_access_key",
      "severity": "CRITICAL",
      "file": "./src/config/api-keys.js",
      "line": 5,
      "content": "const awsKey = 'AKIAIOSFODNN7EXAMPLE';",
      "remediation": "Remove hardcoded secret and use environment variables or secret management service"
    },
    {
      "id": 2,
      "type": "stripe_secret",
      "severity": "CRITICAL",
      "file": "./src/services/payment.js",
      "line": 12,
      "content": "const stripeSecret = 'sk_live_1234567890abcdefghijklmn';",
      "remediation": "Remove hardcoded secret and use environment variables or secret management service"
    },
    {
      "id": 3,
      "type": "postgres_url",
      "severity": "HIGH",
      "file": "./src/config/database.js",
      "line": 3,
      "content": "const dbUrl = 'postgres://admin:password123@localhost:5432/mydb';",
      "remediation": "Remove hardcoded secret and use environment variables or secret management service"
    }
  ]
}
```

## Step 3: Understand Findings

### Finding #1: AWS Access Key (CRITICAL)
- **Location:** `src/config/api-keys.js:5`
- **Risk:** If committed, anyone with repo access can use AWS account
- **Impact:** Unauthorized AWS resource access, potential data breach, unexpected charges

### Finding #2: Stripe Secret Key (CRITICAL)
- **Location:** `src/services/payment.js:12`
- **Risk:** Full access to Stripe account and customer payment data
- **Impact:** Fraudulent transactions, customer data exposure, PCI compliance violation

### Finding #3: Database Connection String (HIGH)
- **Location:** `src/config/database.js:3`
- **Risk:** Database credentials exposed
- **Impact:** Unauthorized database access, data theft, data manipulation

## Step 4: Remediate Each Finding

### Fix Finding #1: AWS Access Key

**Before (vulnerable):**
```javascript
// src/config/api-keys.js
const awsKey = 'AKIAIOSFODNN7EXAMPLE';
const awsSecret = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY';

module.exports = { awsKey, awsSecret };
```

**After (secure):**
```javascript
// src/config/api-keys.js
const awsKey = process.env.AWS_ACCESS_KEY_ID;
const awsSecret = process.env.AWS_SECRET_ACCESS_KEY;

if (!awsKey || !awsSecret) {
  throw new Error('AWS credentials not configured. Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables.');
}

module.exports = { awsKey, awsSecret };
```

**Create .env file:**
```bash
# .env (add to .gitignore!)
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**Create .env.example (safe to commit):**
```bash
# .env.example
AWS_ACCESS_KEY_ID=your_aws_access_key_here
AWS_SECRET_ACCESS_KEY=your_aws_secret_key_here
```

### Fix Finding #2: Stripe Secret Key

**Before:**
```javascript
// src/services/payment.js
const stripe = require('stripe')('sk_live_1234567890abcdefghijklmn');
```

**After:**
```javascript
// src/services/payment.js
const stripeSecretKey = process.env.STRIPE_SECRET_KEY;

if (!stripeSecretKey) {
  throw new Error('Stripe secret key not configured. Set STRIPE_SECRET_KEY environment variable.');
}

const stripe = require('stripe')(stripeSecretKey);
```

**Add to .env:**
```bash
STRIPE_SECRET_KEY=sk_live_1234567890abcdefghijklmn
```

### Fix Finding #3: Database Connection String

**Before:**
```javascript
// src/config/database.js
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: 'postgres://admin:password123@localhost:5432/mydb'
});
```

**After:**
```javascript
// src/config/database.js
const { Pool } = require('pg');

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) {
  throw new Error('Database URL not configured. Set DATABASE_URL environment variable.');
}

const pool = new Pool({
  connectionString: databaseUrl,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});
```

**Add to .env:**
```bash
DATABASE_URL=postgres://admin:password123@localhost:5432/mydb
```

## Step 5: Update .gitignore

Ensure secrets are never committed:

```bash
# .gitignore
.env
.env.local
.env.*.local
*.key
*.pem
*.p12
secrets.json
credentials.json
```

## Step 6: Remove Secrets from Git History

If secrets were already committed, remove them from history:

```bash
# Install BFG Repo-Cleaner
brew install bfg  # or download from https://rtyley.github.io/bfg-repo-cleaner/

# Remove secrets from entire history
bfg --replace-text secrets.txt  # File with secrets to remove

# Alternative: git-filter-repo
pip install git-filter-repo
git filter-repo --replace-text secrets.txt

# Force push (WARNING: Coordinate with team!)
git push --force
```

## Step 7: Rotate Compromised Credentials

**Important:** Assume all exposed secrets are compromised!

1. **AWS Keys:** Deactivate old keys in AWS IAM, generate new ones
2. **Stripe Keys:** Rollover secret key in Stripe Dashboard
3. **Database Password:** Change database password immediately

## Step 8: Re-scan to Verify

```bash
# Run scan again
bash /path/to/scripts/scan-secrets.sh . > secrets-scan-after.json

# Expected output
{
  "scan_timestamp": "2025-10-29T15:00:00Z",
  "target_directory": "./my-app",
  "total_findings": 0,
  "severity_breakdown": {
    "critical": 0,
    "high": 0,
    "medium": 0,
    "low": 0
  },
  "findings": []
}
```

## Step 9: Prevent Future Exposure

### Install pre-commit Hook

```bash
# Create .git/hooks/pre-commit
#!/bin/bash
echo "Running secret scan..."
bash scripts/scan-secrets.sh . --quiet

if [ $? -ne 0 ]; then
  echo "ERROR: Secrets detected! Commit aborted."
  echo "Run 'bash scripts/scan-secrets.sh .' to see details."
  exit 1
fi
```

```bash
chmod +x .git/hooks/pre-commit
```

### Use git-secrets

```bash
# Install git-secrets
brew install git-secrets

# Initialize
git secrets --install
git secrets --register-aws

# Scan
git secrets --scan
```

## Best Practices Summary

1. **Never commit secrets to version control**
2. **Use environment variables for configuration**
3. **Keep .env in .gitignore**
4. **Provide .env.example for documentation**
5. **Rotate credentials if exposed**
6. **Use pre-commit hooks to prevent commits**
7. **Regular scans** (weekly minimum)
8. **Use secrets management** (AWS Secrets Manager, HashiCorp Vault)
9. **Educate team** on secret handling
10. **Audit access logs** after exposure

## Next Steps

- [Dependency Scanning Example](./dependency-scanning.md)
- [CI/CD Security Integration](./ci-cd-security-integration.md)
- [Vulnerability Remediation Guide](../templates/vulnerability-remediation.md)

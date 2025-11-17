# PII Protection Example

This example demonstrates automatic PII detection and masking.

## Scenario: Agent Processing User Input

An agent receives user input containing personally identifiable information (PII). Before processing, it must detect and mask PII.

### Step 1: User Provides Input with PII

**User input:**
```
Create a feature spec for user authentication. The admin user should be john.doe@company.com
and they should be able to reset passwords by text to 555-123-4567. We'll use the test SSN
123-45-6789 for development. The server IP is 192.168.1.100.
```

### Step 2: Agent Runs PII Detector

**Command:**
```bash
echo "Create a feature spec for user authentication. The admin user should be john.doe@company.com and they should be able to reset passwords by text to 555-123-4567. We'll use the test SSN 123-45-6789 for development. The server IP is 192.168.1.100." | python plugins/security/skills/security-validation/scripts/validate-pii.py
```

**Output:**
```json
{
  "has_pii": true,
  "masked_content": "Create a feature spec for user authentication. The admin user should be ***@***.*** and they should be able to reset passwords by text to ***-***-****. We'll use the test SSN ***-**-**** for development. The server IP is ***.***.***.***.",
  "pii_detections": [
    {
      "type": "email",
      "value": "john.doe@company.com",
      "line": 1,
      "severity": "medium",
      "masked": true
    },
    {
      "type": "phone_us",
      "value": "555-123-4567",
      "line": 1,
      "severity": "medium",
      "masked": true
    },
    {
      "type": "ssn",
      "value": "123-45-6789",
      "line": 1,
      "severity": "high",
      "masked": true
    },
    {
      "type": "ip_address",
      "value": "192.168.1.100",
      "line": 1,
      "severity": "low",
      "masked": true
    }
  ],
  "pii_types": ["email", "phone_us", "ssn", "ip_address"],
  "summary": {
    "total_detected": 4,
    "by_type": {
      "email": 1,
      "phone_us": 1,
      "ssn": 1,
      "ip_address": 1
    },
    "by_severity": {
      "critical": 0,
      "high": 1,
      "medium": 2,
      "low": 1
    }
  }
}
```

**Exit code:** 0 (non-blocking, always succeeds)

### Step 3: Agent Uses Masked Content

The agent should:
1. ✅ Use `masked_content` for further processing
2. 📝 Log PII detection in audit trail
3. ℹ️ Inform user if high-severity PII detected

**Agent processes masked version:**
```
Create a feature spec for user authentication. The admin user should be ***@***.***
and they should be able to reset passwords by text to ***-***-****. We'll use the
test SSN ***-**-**** for development. The server IP is ***.***.***.***
```

### Step 4: Agent Writes Spec File

The agent writes the spec file using the masked content:

```markdown
# Feature Spec: User Authentication

## Overview
Admin user (***@***.***) can manage authentication...

## Security Requirements
- Password reset via SMS to ***-***-****
- Test environment uses SSN ***-**-**** for development
- Server: ***.***.***.***
```

### Step 5: Log PII Encounter

Record the PII detection for compliance audit:

```bash
python plugins/security/skills/security-validation/scripts/audit-logger.py log \
  --agent="feature-spec-writer" \
  --action="file_write" \
  --path="specs/001/spec.md" \
  --result="success" \
  --security-events='[
    {"type":"pii_detected","severity":"medium","masked":true},
    {"type":"pii_detected","severity":"high","masked":true}
  ]' \
  --risk-level="medium"
```

## PII Types Detected

### Email Addresses

**Pattern:** Standard email format

**Examples:**
- ✅ Detected: `john.doe@company.com`, `user@example.org`
- ❌ Not detected: `email at domain dot com` (obfuscated)

**Masked as:** `***@***.***`

### Phone Numbers

**US Format:**
- `555-123-4567`
- `(555) 123-4567`
- `555.123.4567`
- `+1-555-123-4567`

**International Format:**
- `+44 20 1234 5678`
- `+33 1 23 45 67 89`

**Masked as:** `***-***-****` or `+***********`

### Social Security Numbers

**Pattern:** `XXX-XX-XXXX` format

**Examples:**
- ✅ Detected: `123-45-6789`
- ❌ Not detected: `123456789` (no dashes)

**Masked as:** `***-**-****`

### Credit Card Numbers

**Patterns:**
- `4111 1111 1111 1111` (spaces)
- `4111-1111-1111-1111` (dashes)
- `4111111111111111` (no separators)

**Masked as:** `****-****-****-****`

### IP Addresses

**IPv4 Pattern:** `X.X.X.X`

**Examples:**
- ✅ Detected: `192.168.1.100`, `10.0.0.1`

**Masked as:** `***.***.***.***`

### Street Addresses

**Pattern:** Number + street name + street type

**Examples:**
- ✅ Detected: `123 Main Street`, `456 Oak Avenue`
- ❌ Not detected: `Main Street` (no number)

**Masked as:** `*** *** Street`

## Best Practices

### For Agents

**Before processing user input:**

```markdown
Phase 1: Input Sanitization

1. Receive user input
2. Bash: echo "$USER_INPUT" | python plugins/security/skills/security-validation/scripts/validate-pii.py
3. Parse JSON output
4. Use masked_content for all subsequent operations
5. Log PII encounter if has_pii=true
6. If severity=high or critical: WARN user
```

**Example in agent prompt:**

```markdown
When user provides requirements or specifications:

1. Run PII detector on input
2. ALWAYS use masked_content
3. NEVER use original content with PII
4. Log PII detection for compliance
5. Inform user if high-severity PII detected
```

### For Users

**Avoid including real PII in specifications:**

❌ **Bad:**
```
Admin: john.doe@realcompany.com
Phone: 555-867-5309
SSN: 123-45-6789 for testing
```

✅ **Good:**
```
Admin: admin@example.com
Phone: 555-000-0000
SSN: Use placeholder values for testing
```

## Compliance Audit Trail

PII detections are logged for GDPR, HIPAA, and SOC 2 compliance:

**Audit log entry:**
```json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "agent": "feature-spec-writer",
  "action": "file_write",
  "path": "specs/001/spec.md",
  "security_events": [
    {
      "type": "pii_detected",
      "severity": "medium",
      "pattern": "email",
      "masked": true
    },
    {
      "type": "pii_detected",
      "severity": "high",
      "pattern": "ssn",
      "masked": true
    }
  ],
  "risk_level": "medium"
}
```

This provides:
- Evidence of PII handling
- Proof of automatic masking
- Audit trail for compliance reviews
- Timeline for data processing activities

## Query PII Events

Find all PII detections:

```bash
# Query today's logs for PII events
python plugins/security/skills/security-validation/scripts/audit-logger.py query \
  --date="2025-01-15" | jq '.[] | select(.security_events[]?.type == "pii_detected")'
```

## Testing the PII Detector

Test with sample PII:

```bash
# Test email detection
echo "Contact: john.doe@example.com" | python scripts/validate-pii.py

# Test phone detection
echo "Call: 555-123-4567" | python scripts/validate-pii.py

# Test SSN detection
echo "SSN: 123-45-6789" | python scripts/validate-pii.py

# Test multiple PII types
echo "User john@example.com with SSN 123-45-6789 at 192.168.1.1" | python scripts/validate-pii.py
```

## Multi-line Content

The detector works with multi-line content:

```bash
python scripts/validate-pii.py << EOF
Feature Requirements:

User: alice@company.com
Phone: (555) 987-6543
SSN: 987-65-4321
Server: 10.0.0.50

All PII above should be masked.
EOF
```

**Output includes line numbers:**
```json
{
  "pii_detections": [
    {"type": "email", "line": 3, ...},
    {"type": "phone_us", "line": 4, ...},
    {"type": "ssn", "line": 5, ...},
    {"type": "ip_address", "line": 6, ...}
  ]
}
```

## Summary

✅ **DO:**
- Run PII detector on all user input
- Use masked_content for processing
- Log PII encounters for audit
- Warn users if high-severity PII detected
- Maintain compliance audit trail

❌ **DON'T:**
- Process original content with PII
- Skip PII detection for "small" inputs
- Ignore PII detection results
- Bypass masking "just this once"
- Delete PII audit logs prematurely

## Compliance Benefits

- **GDPR Article 25**: Privacy by design and default (automatic masking)
- **HIPAA**: PHI protection (SSN, medical record number detection)
- **SOC 2**: Access control and audit logging
- **ISO 27001**: Information security management (PII handling)

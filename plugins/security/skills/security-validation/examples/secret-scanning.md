# Secret Scanning Example

This example demonstrates runtime secret detection before file writes.

## Scenario: Agent Writing Configuration File

An agent is about to write a configuration file. Before writing, it must scan for hardcoded secrets.

### Step 1: Agent Prepares Content

```typescript
// config.ts - Content to be written
export const config = {
  apiKey: "sk-ant-api03-abc123def456...",  // ❌ REAL API KEY (will be blocked)
  supabaseUrl: "https://myproject.supabase.co",
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  // ❌ REAL JWT (will be blocked)
};
```

### Step 2: Agent Runs Secret Scanner

**Command:**
```bash
python plugins/security/skills/security-validation/scripts/scan-secrets.py config.ts
```

**Output:**
```json
{
  "blocked": true,
  "violations": [
    {
      "type": "anthropic_api_key",
      "line": 2,
      "pattern": "sk-ant-api03-[A-Za-z0-9_-]{95,}",
      "context": "apiKey: \"sk-ant-api03-abc123def456...\"",
      "severity": "critical"
    },
    {
      "type": "supabase_anon_key",
      "line": 4,
      "pattern": "eyJ[A-Za-z0-9_-]{100,}\\.[A-Za-z0-9_-]{20,}\\.[A-Za-z0-9_-]{40,}",
      "context": "supabaseKey: \"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...\"",
      "severity": "critical"
    }
  ],
  "entropy_scores": [
    {
      "key": "apiKey",
      "entropy": 4.92,
      "line": 2,
      "length": 103
    }
  ],
  "total_violations": 2,
  "critical_violations": 2,
  "high_entropy_detected": 1
}
```

**Exit code:** 1 (blocked)

### Step 3: Agent Response

Since `blocked` is true, the agent must:
1. ❌ STOP - Do not write the file
2. ⚠️ ALERT - Display error to user
3. 📝 LOG - Record security violation in audit log

**Agent Output:**
```
SECURITY VIOLATION: Detected potential API keys in config.ts

Critical violations found:
- Line 2: Anthropic API key pattern detected
- Line 4: Supabase JWT token pattern detected

The file write has been BLOCKED. Please replace secrets with placeholders:

✅ CORRECT:
export const config = {
  apiKey: process.env.ANTHROPIC_API_KEY,
  supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL,
  supabaseKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
};
```

### Step 4: User Fixes Content

User provides corrected content with placeholders:

```typescript
// config.ts - SAFE version
export const config = {
  apiKey: process.env.ANTHROPIC_API_KEY,
  supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL,
  supabaseKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
};
```

### Step 5: Agent Re-scans

**Command:**
```bash
python plugins/security/skills/security-validation/scripts/scan-secrets.py config-fixed.ts
```

**Output:**
```json
{
  "blocked": false,
  "violations": [],
  "entropy_scores": [],
  "total_violations": 0,
  "critical_violations": 0,
  "high_entropy_detected": 0
}
```

**Exit code:** 0 (safe)

### Step 6: Agent Writes File

Since `blocked` is false, the agent can proceed:
1. ✅ Write the file
2. 📝 Log successful operation
3. ℹ️ Inform user

## Best Practices

### For Agents

**Before EVERY file write:**
```markdown
Phase 3: File Write Validation

Before writing file:
1. Bash: python plugins/security/skills/security-validation/scripts/scan-secrets.py <file-path>
2. Check exit code and JSON output
3. If blocked=true:
   - STOP operation
   - DISPLAY violation details
   - REQUEST user to fix
4. If blocked=false:
   - Proceed with file write
   - Log operation in audit trail
```

### For Users

**Always use placeholders:**
- ✅ `your_anthropic_key_here`
- ✅ `your_supabase_url_here`
- ✅ `process.env.API_KEY`
- ❌ Never hardcode real credentials

**Create .env.example:**
```bash
# .env.example (safe to commit)
ANTHROPIC_API_KEY=your_anthropic_key_here
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

**Protect .env with .gitignore:**
```gitignore
# .gitignore
.env
.env.local
.env.development
.env.production
!.env.example
```

## High-Entropy Detection

The scanner also detects high-entropy strings (likely secrets even without known patterns):

### Example:

```env
# Suspicious - high entropy
CUSTOM_KEY=aB3dEf7Gh9IjK2lMnO4pQr6StU8vWxY1zAbC5dEfG
```

**Scanner detects:**
```json
{
  "entropy_scores": [
    {
      "key": "CUSTOM_KEY",
      "entropy": 4.7,
      "line": 2,
      "length": 40
    }
  ],
  "violations": [
    {
      "type": "high_entropy_secret",
      "line": 2,
      "key": "CUSTOM_KEY",
      "entropy": 4.7,
      "severity": "high"
    }
  ]
}
```

## Integration with Audit Logging

When a secret is blocked, log the security event:

```bash
python plugins/security/skills/security-validation/scripts/audit-logger.py log \
  --agent="code-generator" \
  --action="file_write" \
  --path="config.ts" \
  --result="blocked" \
  --security-events='[{"type":"secret_detected","severity":"critical","pattern":"anthropic_api_key","blocked":true}]' \
  --risk-level="critical"
```

This creates an audit trail for compliance and incident investigation.

## Testing the Scanner

Test with sample content:

```bash
# Test with real secret (will block)
echo 'API_KEY=sk-ant-api03-abc123...' | python scripts/scan-secrets.py
# Exit code: 1

# Test with placeholder (will pass)
echo 'API_KEY=your_key_here' | python scripts/scan-secrets.py
# Exit code: 0
```

## Summary

✅ **DO:**
- Run secret scanner before every file write
- Use environment variables for credentials
- Create .env.example with placeholders
- Protect .env files with .gitignore
- Log blocked attempts for audit

❌ **DON'T:**
- Write files without scanning
- Hardcode real API keys
- Commit secrets to git
- Bypass security checks
- Ignore high-entropy warnings

# Deprecation Notice: [FEATURE_NAME]

**Status:** ⚠️ DEPRECATED
**Deprecated In:** v[VERSION]
**Removal Planned:** v[FUTURE_VERSION]
**Deprecation Date:** [DATE]
**End of Life Date:** [DATE]

---

## Summary

[FEATURE_NAME] has been deprecated and will be removed in version [FUTURE_VERSION]. Users should migrate to [ALTERNATIVE_FEATURE] as soon as possible.

---

## What's Being Deprecated

| Component | Type | Status | Removal Version |
|-----------|------|--------|-----------------|
| [Feature/API/Method] | [Type] | ⚠️ Deprecated | v[VERSION] |
| [Feature/API/Method] | [Type] | ⚠️ Deprecated | v[VERSION] |

---

## Timeline

```
[CURRENT_DATE]          [FUTURE_DATE]              [EOL_DATE]
     |                        |                         |
     v                        v                         v
Deprecation              Migration Period           Removal
Announced                   Ends                    Complete
     |________________________|_________________________|
              [MIGRATION_WINDOW]
```

### Key Dates

- **[DATE]**: Deprecation announced
- **[DATE]**: Warning messages added to deprecated features
- **[DATE]**: Documentation updated with migration guide
- **[DATE]**: Migration support period ends
- **[DATE]**: Feature removed from codebase
- **[DATE]**: Old version no longer supported

---

## Reason for Deprecation

[Detailed explanation of why this feature is being deprecated]

**Key Reasons:**
1. [Reason 1]
2. [Reason 2]
3. [Reason 3]

---

## Migration Path

### Recommended Alternative

Use **[NEW_FEATURE]** instead of [DEPRECATED_FEATURE].

#### Before (Deprecated)

```[language]
// Old way - DEPRECATED
[deprecated code example]
```

#### After (Recommended)

```[language]
// New way - RECOMMENDED
[new code example]
```

---

## Detailed Migration Guide

### Step 1: Identify Usage

Find all usages of the deprecated feature in your codebase:

```bash
# Search for deprecated API calls
grep -r "[DEPRECATED_PATTERN]" .

# Or use language-specific tools
# JavaScript/TypeScript
eslint . --rule "no-deprecated-api: error"

# Python
pylint --disable=all --enable=deprecated-method .
```

### Step 2: Update Code

Replace deprecated calls with recommended alternatives:

#### Example 1: [Use Case]

**Before:**
```[language]
[old implementation]
```

**After:**
```[language]
[new implementation]
```

**Changes Required:**
- [Change 1]
- [Change 2]
- [Change 3]

#### Example 2: [Use Case]

**Before:**
```[language]
[old implementation]
```

**After:**
```[language]
[new implementation]
```

### Step 3: Test Migration

```bash
# Run your test suite
[test command]

# Verify no deprecation warnings
[check warnings command]
```

### Step 4: Deploy

Once testing is complete:
1. Deploy to staging environment
2. Monitor for deprecation warnings
3. Deploy to production
4. Remove deprecated feature usage completely

---

## API Changes

### Deprecated Endpoints

#### `[HTTP_METHOD] /api/v1/[deprecated-endpoint]`

**Status:** ⚠️ DEPRECATED
**Replacement:** `[HTTP_METHOD] /api/v2/[new-endpoint]`

**Old Request:**
```http
GET /api/v1/users HTTP/1.1
Authorization: ApiKey {key}
```

**Old Response:**
```json
{
  "users": [...]
}
```

**New Request:**
```http
GET /api/v2/users HTTP/1.1
Authorization: Bearer {token}
```

**New Response:**
```json
{
  "data": [...],
  "meta": {...}
}
```

---

## Configuration Changes

### Deprecated Configuration Options

#### `[old_config_key]`

**Status:** ⚠️ DEPRECATED
**Replacement:** `[new_config_key]`

**Before:**
```yaml
# config.yaml
[old_config_key]: value
```

**After:**
```yaml
# config.yaml
[new_config_key]: value
```

---

## Environment Variables

### Deprecated Environment Variables

| Old Variable | New Variable | Notes |
|-------------|--------------|-------|
| `OLD_VAR` | `NEW_VAR` | [Migration notes] |

**Migration:**
```bash
# Before
export OLD_VAR=value

# After
export NEW_VAR=value
```

---

## Database Schema Changes

### Deprecated Tables/Columns

#### Table: `[deprecated_table]`

**Status:** ⚠️ DEPRECATED
**Replacement:** `[new_table]`

**Migration:**
```sql
-- Read from old table (still works)
SELECT * FROM [deprecated_table];

-- Migrate to new table
INSERT INTO [new_table] (...)
SELECT ... FROM [deprecated_table];

-- After migration, use new table
SELECT * FROM [new_table];
```

---

## SDK/Library Changes

### Deprecated Methods

#### `[Class].[deprecated_method]()`

**Status:** ⚠️ DEPRECATED
**Replacement:** `[Class].[new_method]()`

**Before:**
```[language]
const result = client.[deprecated_method]({
  param: value
});
```

**After:**
```[language]
const result = client.[new_method]({
  param: value,
  newParam: newValue  // Additional required parameter
});
```

---

## Impact Assessment

### Low Impact (Easy Migration)

- [Feature 1]: Simple parameter rename
- [Feature 2]: Direct replacement available

### Medium Impact (Code Changes Required)

- [Feature 3]: Requires updating function signatures
- [Feature 4]: Requires data transformation

### High Impact (Significant Refactoring)

- [Feature 5]: Complete architecture change
- [Feature 6]: Affects multiple systems

---

## Backward Compatibility

### During Deprecation Period

Both old and new features will work simultaneously:

```[language]
// Both of these work during deprecation period
result1 = deprecatedFunction();  // Works with warning
result2 = newFunction();         // Recommended approach
```

### After Removal

Only new feature will work:

```[language]
result1 = deprecatedFunction();  // ERROR: Function not found
result2 = newFunction();         // ✅ Works
```

---

## Deprecation Warnings

### How to Detect Usage

During the deprecation period, warnings will be logged:

**Console/Logs:**
```
[WARN] Deprecated feature 'oldFunction' used at file.js:42
       This feature will be removed in v[VERSION]
       Use 'newFunction' instead
       See: [MIGRATION_GUIDE_URL]
```

**HTTP Headers:**
```http
X-Deprecation-Warning: true
X-Deprecation-Details: Feature will be removed in v[VERSION]
X-Deprecation-Alternative: Use /api/v2/endpoint instead
X-Deprecation-Info: [MIGRATION_GUIDE_URL]
```

---

## Support During Migration

### Documentation

- **Migration Guide:** [URL]
- **API Documentation:** [URL]
- **FAQ:** [URL]

### Community Support

- **Forum:** [URL]
- **Slack Channel:** [CHANNEL]
- **GitHub Discussions:** [URL]

### Professional Support

- **Email:** [support-email]
- **Support Tickets:** [URL]
- **Office Hours:** [SCHEDULE]

---

## FAQ

### Q: Can I continue using the deprecated feature?

A: Yes, until v[FUTURE_VERSION]. After that, it will be completely removed.

### Q: Will my application break immediately?

A: No, deprecation is just a warning. Your code will continue to work until the removal date.

### Q: How much time do I have to migrate?

A: You have [DURATION] (until [DATE]) to complete migration.

### Q: What if I can't migrate in time?

A: Contact our support team at [EMAIL] to discuss your options. We may be able to provide an extended support period.

### Q: Is there an automated migration tool?

A: [YES/NO]. [If yes, provide details and link]

### Q: Can I opt-out of deprecation warnings?

A: [Provide instructions if applicable]

---

## Checklist for Migration

Use this checklist to track your migration progress:

- [ ] Read deprecation notice and migration guide
- [ ] Identify all usages of deprecated features
- [ ] Create migration plan with timeline
- [ ] Update development environment
- [ ] Write tests for new implementation
- [ ] Migrate code to use new features
- [ ] Update configuration files
- [ ] Update environment variables
- [ ] Test in development environment
- [ ] Deploy to staging environment
- [ ] Perform integration testing
- [ ] Monitor for deprecation warnings
- [ ] Deploy to production
- [ ] Verify no warnings in production logs
- [ ] Remove all deprecated code references
- [ ] Update internal documentation

---

## Contact Information

For questions or concerns about this deprecation:

- **Technical Questions:** [EMAIL/FORUM]
- **Migration Support:** [EMAIL/SLACK]
- **Partnership/Enterprise:** [EMAIL/PHONE]

---

## Updates to This Notice

| Date | Change | Author |
|------|--------|--------|
| [DATE] | Initial deprecation notice | [NAME] |
| [DATE] | Updated timeline | [NAME] |
| [DATE] | Added FAQ section | [NAME] |

---

**Last Updated:** [TIMESTAMP]
**Notice Version:** [VERSION]
**Status:** [ACTIVE/SUPERSEDED]

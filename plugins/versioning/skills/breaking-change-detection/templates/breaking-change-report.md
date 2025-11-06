# Breaking Change Report

**Generated:** [TIMESTAMP]
**Version:** [OLD_VERSION] → [NEW_VERSION]
**Severity:** [CRITICAL/HIGH/MEDIUM/LOW]

---

## Executive Summary

This report documents breaking changes detected between version [OLD_VERSION] and [NEW_VERSION]. A total of [COUNT] breaking changes were identified that require immediate attention.

**Recommended Action:** [MAJOR/MINOR/PATCH] version bump

---

## Breaking Changes

### 1. [Change Type] - [Component Name]

**Severity:** [CRITICAL/HIGH/MEDIUM/LOW]
**Component:** [API/Database/Schema/Contract]
**Impact Level:** [All Users/Specific Features/Edge Cases]

#### Description

[Detailed description of what changed]

#### Before

```[language]
[code example showing old behavior]
```

#### After

```[language]
[code example showing new behavior]
```

#### Impact

- **Affected Users:** [Who is impacted]
- **Failure Mode:** [How it will break]
- **Data Loss Risk:** [Yes/No + explanation]

#### Migration Required

- [ ] Update client code
- [ ] Update database schema
- [ ] Update documentation
- [ ] Update tests
- [ ] Communicate to users

---

### 2. [Change Type] - [Component Name]

[Repeat structure for each breaking change]

---

## Non-Breaking Changes

List of changes that are backward compatible:

1. **Added [Feature]** - New optional feature with defaults
2. **Enhanced [Feature]** - Improved existing feature without changing interface
3. **Deprecated [Feature]** - Marked for future removal but still functional

---

## Severity Classification

### Critical (Immediate Action Required)

Breaking changes in this category will cause immediate failures:

- Removed API endpoints
- Dropped database tables
- Deleted required fields
- Changed authentication mechanisms

**Count:** [NUMBER]

### High (Code Changes Required)

Breaking changes requiring code updates but not causing immediate failures:

- Renamed fields/properties
- Changed data types
- Added required parameters
- Modified validation rules

**Count:** [NUMBER]

### Medium (Behavior Changes)

Breaking changes that modify behavior without errors:

- Changed default values
- Modified sorting/ordering
- Updated error messages
- Changed rate limits

**Count:** [NUMBER]

### Low (Documentation Updates)

Breaking changes requiring only documentation updates:

- Deprecated features still functional
- Changed response formats with backward compat
- Updated terminology

**Count:** [NUMBER]

---

## Migration Timeline

| Phase | Date | Action |
|-------|------|--------|
| Announcement | [DATE] | Public announcement of breaking changes |
| Deprecation Start | [DATE] | Old version marked as deprecated |
| Migration Period | [DATE RANGE] | Users migrate to new version |
| Old Version Sunset | [DATE] | Old version no longer supported |
| Hard Cutoff | [DATE] | Old version completely removed |

**Recommended Migration Window:** [DURATION]

---

## Risk Assessment

### High Risk Areas

1. **[Feature/Component]**
   - **Risk:** [Description]
   - **Mitigation:** [Strategy]

2. **[Feature/Component]**
   - **Risk:** [Description]
   - **Mitigation:** [Strategy]

### Rollback Plan

In case of critical issues:

1. Revert to version [OLD_VERSION]
2. Restore database from backup taken at [TIMESTAMP]
3. Roll back deployments using [STRATEGY]
4. Notify affected users via [CHANNEL]

---

## Testing Requirements

Before deployment, ensure:

- [ ] Unit tests pass for all affected components
- [ ] Integration tests validate backward compatibility
- [ ] Performance tests show no degradation
- [ ] Security audit completed for changed authentication
- [ ] Load tests validate production scale
- [ ] Canary deployment successful in staging

---

## Communication Plan

### Internal Communication

- **Engineering Team:** [DATE] via [CHANNEL]
- **QA Team:** [DATE] via [CHANNEL]
- **DevOps Team:** [DATE] via [CHANNEL]
- **Product Team:** [DATE] via [CHANNEL]

### External Communication

- **Documentation Update:** [DATE]
- **Blog Post:** [DATE]
- **Email Announcement:** [DATE]
- **In-App Notification:** [DATE]
- **API Status Page:** [DATE]

### Support Resources

- **Migration Guide:** [URL]
- **API Documentation:** [URL]
- **Support Channel:** [EMAIL/SLACK]
- **FAQ:** [URL]

---

## Technical Details

### API Changes

[Detailed technical breakdown of API changes]

### Database Schema Changes

[Detailed technical breakdown of schema changes]

### Contract Changes

[Detailed technical breakdown of contract/interface changes]

---

## Appendix

### Automated Detection

This report was generated using:

```bash
bash scripts/analyze-breaking.sh \
  --old-api [OLD_SPEC] \
  --new-api [NEW_SPEC] \
  --old-schema [OLD_SCHEMA] \
  --new-schema [NEW_SCHEMA] \
  --output breaking-changes-report.md
```

### Manual Review Required

The following areas require manual review:

- [ ] Business logic changes
- [ ] Third-party integrations
- [ ] Custom authentication flows
- [ ] Data migration scripts

---

**Document Owner:** [NAME]
**Last Updated:** [TIMESTAMP]
**Status:** [DRAFT/UNDER REVIEW/APPROVED/IMPLEMENTED]

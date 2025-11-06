# Migration Guide: [OLD_VERSION] → [NEW_VERSION]

**Published:** [DATE]
**Migration Deadline:** [DATE]
**Estimated Migration Time:** [DURATION]

---

## Overview

Version [NEW_VERSION] introduces breaking changes that require action from API consumers. This guide provides step-by-step instructions for migrating from version [OLD_VERSION] to [NEW_VERSION].

### What's Changing

- **Breaking Changes:** [COUNT]
- **Deprecated Features:** [COUNT]
- **New Features:** [COUNT]

### Who Is Affected

- ✅ Users of [FEATURE/API]
- ✅ Applications using [COMPONENT]
- ⚠️ Custom integrations with [SYSTEM]

---

## Timeline

| Date | Milestone |
|------|-----------|
| [DATE] | **Announcement** - Breaking changes announced |
| [DATE] | **New Version Available** - v[NEW_VERSION] released |
| [DATE] | **Deprecation Warning** - Old version marked deprecated |
| [DATE] | **Migration Period Ends** - Final date to migrate |
| [DATE] | **Old Version Sunset** - v[OLD_VERSION] no longer supported |

**⚠️ IMPORTANT:** You must complete migration by [DEADLINE DATE]

---

## Quick Start

For experienced users who want to migrate quickly:

```bash
# 1. Update dependencies
[PACKAGE_MANAGER] install [PACKAGE]@[NEW_VERSION]

# 2. Update configuration
[CONFIGURATION_UPDATE_COMMAND]

# 3. Update code (see breaking changes section)

# 4. Run tests
[TEST_COMMAND]

# 5. Deploy
[DEPLOY_COMMAND]
```

---

## Breaking Changes

### 1. [Breaking Change Title]

**Severity:** 🔴 CRITICAL / 🟠 HIGH / 🟡 MEDIUM / 🟢 LOW

#### What Changed

[Detailed explanation of the change]

#### Why This Changed

[Rationale behind the breaking change]

#### Migration Steps

**Step 1: [Action]**

Before:
```[language]
[old code example]
```

After:
```[language]
[new code example]
```

**Step 2: [Action]**

[Additional migration steps]

**Step 3: Verify**

```bash
[verification command]
```

Expected output:
```
[expected output]
```

#### Common Pitfalls

⚠️ **Pitfall 1:** [Description]
- **Solution:** [How to avoid/fix]

⚠️ **Pitfall 2:** [Description]
- **Solution:** [How to avoid/fix]

---

### 2. [Breaking Change Title]

[Repeat structure for each breaking change]

---

## Deprecated Features

These features still work but will be removed in [FUTURE_VERSION]:

### [Deprecated Feature 1]

**Deprecated In:** v[NEW_VERSION]
**Removal Planned:** v[FUTURE_VERSION]
**Alternative:** Use [NEW_FEATURE] instead

#### Migration from Deprecated Feature

Before (Deprecated):
```[language]
[old deprecated code]
```

After (Recommended):
```[language]
[new recommended code]
```

---

## Step-by-Step Migration

### Prerequisites

Before starting migration:

- [ ] Backup your data
- [ ] Review breaking changes section
- [ ] Update development environment
- [ ] Inform team members
- [ ] Schedule maintenance window if needed

### Phase 1: Preparation

**Estimated Time:** [DURATION]

1. **Create a backup**
   ```bash
   [backup command]
   ```

2. **Update dependencies**
   ```bash
   [update command]
   ```

3. **Review migration guide** (you're here!)

### Phase 2: Update Configuration

**Estimated Time:** [DURATION]

1. **Update environment variables**
   ```bash
   # Old
   OLD_CONFIG_VAR=value

   # New
   NEW_CONFIG_VAR=value
   ```

2. **Update configuration files**
   ```[language]
   # config file changes
   ```

### Phase 3: Update Code

**Estimated Time:** [DURATION]

1. **Update imports/dependencies**
   ```[language]
   [import changes]
   ```

2. **Update API calls**
   ```[language]
   [API call changes]
   ```

3. **Update data models**
   ```[language]
   [model changes]
   ```

### Phase 4: Update Database

**Estimated Time:** [DURATION]

⚠️ **CRITICAL:** Backup database before proceeding!

1. **Run migration scripts**
   ```bash
   [migration command]
   ```

2. **Verify data integrity**
   ```bash
   [verification command]
   ```

### Phase 5: Testing

**Estimated Time:** [DURATION]

1. **Run unit tests**
   ```bash
   [unit test command]
   ```

2. **Run integration tests**
   ```bash
   [integration test command]
   ```

3. **Manual testing checklist**
   - [ ] Test [CRITICAL_FEATURE_1]
   - [ ] Test [CRITICAL_FEATURE_2]
   - [ ] Test [CRITICAL_FEATURE_3]

### Phase 6: Deployment

**Estimated Time:** [DURATION]

1. **Deploy to staging**
   ```bash
   [staging deploy command]
   ```

2. **Smoke test staging**
   - [ ] Verify [ENDPOINT_1]
   - [ ] Verify [ENDPOINT_2]

3. **Deploy to production**
   ```bash
   [production deploy command]
   ```

4. **Monitor for errors**
   ```bash
   [monitoring command]
   ```

---

## Code Migration Examples

### Example 1: [Use Case]

#### Scenario
[Description of scenario]

#### Old Implementation
```[language]
[complete old code example]
```

#### New Implementation
```[language]
[complete new code example]
```

#### Key Changes
1. [Change 1]
2. [Change 2]
3. [Change 3]

---

### Example 2: [Use Case]

[Repeat structure]

---

## Database Migration

### Schema Changes

```sql
-- Migration script for [DATABASE_TYPE]

-- Step 1: [Description]
[SQL commands]

-- Step 2: [Description]
[SQL commands]

-- Step 3: Verify
[SQL verification query]
```

### Data Migration

```sql
-- Data migration script

-- Backup existing data
[backup script]

-- Transform data
[transformation script]

-- Verify migration
[verification script]
```

---

## Rollback Plan

If you encounter critical issues during migration:

### Immediate Rollback

```bash
# 1. Revert application to old version
[rollback command]

# 2. Restore database from backup
[restore command]

# 3. Restart services
[restart command]
```

### Recovery Checklist

- [ ] Stop new deployments
- [ ] Restore from backup
- [ ] Verify data integrity
- [ ] Test critical paths
- [ ] Notify stakeholders

---

## Troubleshooting

### Common Errors

#### Error 1: [Error Message]

**Cause:** [Explanation]

**Solution:**
```bash
[solution steps]
```

#### Error 2: [Error Message]

**Cause:** [Explanation]

**Solution:**
```bash
[solution steps]
```

### Getting Help

If you encounter issues not covered in this guide:

1. **Check documentation:** [URL]
2. **Search issues:** [GITHUB_URL/issues]
3. **Contact support:**
   - Email: [EMAIL]
   - Slack: [SLACK_CHANNEL]
   - Office Hours: [SCHEDULE]

---

## FAQ

### Q: Do I need to migrate all at once?

A: [Answer]

### Q: Can I run both versions simultaneously?

A: [Answer]

### Q: What happens if I don't migrate by the deadline?

A: [Answer]

### Q: How do I test my migration before production?

A: [Answer]

---

## Additional Resources

- **API Documentation:** [URL]
- **Video Tutorial:** [URL]
- **Sample Code:** [GITHUB_URL]
- **Community Forum:** [URL]
- **Support:** [EMAIL/SLACK]

---

## Feedback

Help us improve this migration guide:

- **Report Issues:** [URL]
- **Suggest Improvements:** [URL]
- **Share Success Stories:** [EMAIL]

---

**Document Version:** [VERSION]
**Last Updated:** [TIMESTAMP]
**Maintained By:** [TEAM/PERSON]

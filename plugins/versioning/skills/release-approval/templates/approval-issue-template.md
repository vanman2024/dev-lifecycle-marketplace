# Release Approval: v{VERSION}

## 📋 Approval Status

### Development Team
- [ ] @tech-lead
- [ ] @senior-dev
- **Required**: 2 approvals
- **Status**: ⏳ Pending

### QA Team
- [ ] @qa-lead
- **Required**: 1 approval
- **Depends on**: Development approval
- **Status**: ⏳ Pending

### Security Team
- [ ] @security-team-lead
- **Required**: 1 approval
- **Veto Power**: Yes
- **Status**: ⏳ Pending

### Release Management
- [ ] @release-manager
- [ ] @product-owner
- **Required**: 2 approvals
- **Depends on**: All previous stages
- **Status**: ⏳ Pending

## 📦 Version Information

**Version**: v{VERSION}
**Tag**: v{VERSION}
**Branch**: {BRANCH}
**Commit**: {COMMIT_SHA}
**Date**: {DATE}

## 📝 Changes Summary

### Features
{FEATURE_LIST}

### Bug Fixes
{BUGFIX_LIST}

### Breaking Changes
{BREAKING_CHANGES}

### Documentation
{DOCS_CHANGES}

## ✅ Validation Status

- [x] Version tag created
- [x] Changelog generated
- [ ] All tests passing
- [ ] Build successful
- [ ] Security scans passed
- [ ] Documentation updated

## 🚀 Instructions

**For Approvers**: Comment with:
- `/approve` - Approve this stage
- `/approve-with-conditions <conditions>` - Approve with noted conditions
- `/reject <reason>` - Reject with justification

**For Release Manager**: After all approvals:
```bash
# Push tags to trigger deployment
git push --tags

# Monitor deployment
gh run list --workflow=release.yml
```

## 📝 Timeline

- **Requested**: {REQUESTED_DATE}
- **Target Completion**: {TARGET_DATE}
- **Timeout**: 48 hours
- **Escalation**: After 24 hours to @engineering-manager

## 🔗 Links

- **Changelog**: [CHANGELOG.md](./CHANGELOG.md)
- **CI/CD Runs**: [GitHub Actions]({GITHUB_ACTIONS_URL})
- **Approval Configuration**: [approval-gates.yml](.github/releases/approval-gates.yml)

---

{APPROVERS} - Your review is requested.

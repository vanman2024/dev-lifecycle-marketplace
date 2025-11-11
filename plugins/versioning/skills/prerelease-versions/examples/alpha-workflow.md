# Alpha Release Workflow Example

Complete alpha release workflow from creation to promotion.

## Scenario

Developing a new feature that requires multiple iterations before it's ready for wider testing.

**Project**: my-api-server
**Target Version**: 2.0.0
**Current Status**: Starting alpha phase

---

## Step 1: Create Alpha Branch

```bash
# Create alpha branch from main
git checkout main
git pull origin main
git checkout -b alpha/v2.0.0

# Push branch to remote
git push -u origin alpha/v2.0.0
```

**Result**: Alpha branch created for iterative development.

---

## Step 2: Create First Alpha Release

```bash
# Make initial feature commits
git add .
git commit -m "feat: add new authentication system"
git commit -m "feat: implement JWT token handling"

# Create first alpha release
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh alpha 2.0.0

# Output: 2.0.0-alpha.1
```

**Files Updated**:
- `VERSION`: `2.0.0-alpha.1`
- `package.json`: `"version": "2.0.0-alpha.1"`
- Git tag: `v2.0.0-alpha.1`

**Commit and Push**:
```bash
git add .
git commit -m "chore: bump version to 2.0.0-alpha.1"
git push origin alpha/v2.0.0
git push origin v2.0.0-alpha.1
```

---

## Step 3: Internal Testing

```bash
# Deploy to internal testing environment
npm run deploy:alpha

# Or for Docker
docker build -t my-api-server:2.0.0-alpha.1 .
docker run -p 3000:3000 my-api-server:2.0.0-alpha.1
```

**Testing Checklist**:
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Internal team feedback collected

---

## Step 4: Bug Fixes and Iteration

```bash
# Fix issues found during testing
git add .
git commit -m "fix: correct JWT expiration handling"
git commit -m "fix: resolve authentication race condition"

# Create second alpha release
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh alpha 2.0.0

# Output: 2.0.0-alpha.2
```

**Iteration Pattern**:
- Fix bugs
- Add missing functionality
- Refactor as needed
- Create new alpha release
- Repeat

---

## Step 5: Third Alpha Release

```bash
# Continue development
git add .
git commit -m "feat: add password reset functionality"
git commit -m "refactor: improve token storage"

# Create third alpha release
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh alpha 2.0.0

# Output: 2.0.0-alpha.3
```

---

## Step 6: Validate Alpha Release

```bash
# Run validation before promoting to beta
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/test-prerelease.sh 2.0.0-alpha.3
```

**Validation Results**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pre-release Version Validation: 2.0.0-alpha.3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ PASS: Version format is valid
✓ PASS: Pre-release type is valid: alpha
✓ PASS: Pre-release number is valid: 3
✓ PASS: VERSION file matches: 2.0.0-alpha.3
✓ PASS: package.json matches: 2.0.0-alpha.3
✓ PASS: Git tag exists: v2.0.0-alpha.3
✓ PASS: CHANGELOG.md contains entry for 2.0.0-alpha.3

Total Checks Passed: 7
Total Checks Failed: 0

✓ PASS: All validation checks passed!
```

---

## Step 7: Feature Complete - Ready for Beta

```bash
# All alpha testing complete, features implemented
# Promote to beta for wider testing
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/promote-prerelease.sh 2.0.0-alpha.3
```

**Promotion Output**:
```
PROMOTION: Promoting 2.0.0-alpha.3 → 2.0.0-beta.1
INFO: Promotion path: Alpha → Beta

✓ SUCCESS: VERSION file updated to 2.0.0-beta.1
✓ SUCCESS: package.json updated to 2.0.0-beta.1
✓ SUCCESS: Changelog updated with promotion details
✓ SUCCESS: Git tag v2.0.0-beta.1 created

✓ SUCCESS: Promotion to 2.0.0-beta.1 completed successfully

Next steps:
  1. Commit version changes: git add . && git commit -m 'chore: promote to 2.0.0-beta.1'
  2. Push changes: git push origin HEAD
  3. Push tag: git push origin v2.0.0-beta.1
  4. Create GitHub pre-release: gh release create v2.0.0-beta.1 --prerelease
```

---

## Step 8: Create GitHub Pre-release

```bash
# Commit promotion changes
git add .
git commit -m "chore: promote to 2.0.0-beta.1"
git push origin alpha/v2.0.0
git push origin v2.0.0-beta.1

# Create GitHub pre-release
gh release create v2.0.0-beta.1 \
  --prerelease \
  --title "Beta Release v2.0.0-beta.1" \
  --notes "Promoted from alpha testing. Ready for wider beta testing."
```

---

## Complete Alpha Timeline

| Release | Date | Purpose | Commits | Outcome |
|---------|------|---------|---------|---------|
| 2.0.0-alpha.1 | Day 1 | Initial feature implementation | 5 | Found authentication issues |
| 2.0.0-alpha.2 | Day 3 | Fix auth issues | 3 | Found token expiration bug |
| 2.0.0-alpha.3 | Day 5 | Complete authentication system | 4 | Ready for beta |
| 2.0.0-beta.1 | Day 7 | Promote to beta | 1 | Begin wider testing |

**Total Alpha Phase Duration**: 7 days
**Total Alpha Releases**: 3
**Major Issues Fixed**: 5 critical bugs
**Features Completed**: Authentication system v2

---

## Key Learnings

1. **Rapid Iteration**: Alpha releases enabled quick bug fixes
2. **Internal Testing**: Caught critical issues before external release
3. **Version Automation**: Scripts handled version management reliably
4. **Clear Progression**: Alpha → Beta promotion marked feature completion

---

## Next Steps

Continue with [beta-workflow.md](beta-workflow.md) for the beta release phase.

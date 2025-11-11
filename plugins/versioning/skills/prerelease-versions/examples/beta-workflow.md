# Beta Release Workflow Example

Complete beta release workflow including feedback integration.

## Scenario

Continuing from alpha phase, now ready for external early adopters to test the new authentication system.

**Project**: my-api-server
**Target Version**: 2.0.0
**Current Status**: Promoted to beta (2.0.0-beta.1)

---

## Step 1: Create Beta Branch

```bash
# Create beta branch from alpha branch
git checkout alpha/v2.0.0
git pull origin alpha/v2.0.0
git checkout -b beta/v2.0.0

# Push beta branch
git push -u origin beta/v2.0.0
```

**Status**: Feature freeze is now in effect - no new features, only bug fixes.

---

## Step 2: Deploy Beta Release

```bash
# Deploy to beta testing environment
npm run deploy:beta

# Or using Docker
docker build -t my-api-server:2.0.0-beta.1 .
docker push registry.example.com/my-api-server:2.0.0-beta.1

# Deploy to beta environment
kubectl set image deployment/my-api-server \
  my-api-server=registry.example.com/my-api-server:2.0.0-beta.1 \
  -n beta
```

---

## Step 3: Announce Beta Release

```bash
# Create GitHub pre-release with detailed notes
gh release create v2.0.0-beta.1 \
  --prerelease \
  --title "Beta Release v2.0.0-beta.1 - New Authentication System" \
  --notes-file RELEASE_NOTES.md
```

**RELEASE_NOTES.md**:
```markdown
# Beta Release v2.0.0-beta.1

## What's New

- Complete authentication system rewrite
- JWT token-based authentication
- Password reset functionality
- Improved session management

## Installation

npm install my-api-server@2.0.0-beta.1

## Documentation

Full beta documentation: https://docs.example.com/v2.0.0-beta

## Feedback

Please test and provide feedback:
- GitHub Issues: https://github.com/org/repo/issues
- Beta Feedback Form: https://forms.example.com/beta-feedback
- Slack Channel: #beta-testers

## Known Issues

- Session timeout may be longer than configured (#123)
- Password reset emails may be delayed (#124)

⚠️ This is a beta release. Use with caution in production.
```

---

## Step 4: Collect User Feedback

**Week 1 Feedback** (Days 1-7):

| Issue | Severity | Reporter | Description |
|-------|----------|----------|-------------|
| #125 | Critical | User A | Token refresh fails after 30 minutes |
| #126 | High | User B | Password reset link expires too quickly |
| #127 | Medium | User C | Login form doesn't show error messages |
| #128 | Low | User D | Documentation missing examples |

---

## Step 5: Fix Critical Issues - Beta 2

```bash
# Fix critical token refresh issue
git add .
git commit -m "fix: correct token refresh mechanism"
git commit -m "fix: extend password reset link validity to 1 hour"
git commit -m "fix: add error message display to login form"

# Create second beta release
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh beta 2.0.0

# Output: 2.0.0-beta.2
```

**Update and Deploy**:
```bash
git add .
git commit -m "chore: bump version to 2.0.0-beta.2"
git push origin beta/v2.0.0
git push origin v2.0.0-beta.2

# Deploy beta.2
npm run deploy:beta
```

---

## Step 6: Performance Testing

```bash
# Run performance benchmarks
npm run test:performance

# Load testing with artillery
artillery run load-test.yml

# Results
echo "Performance Metrics:"
echo "  Avg Response Time: 45ms (target: <100ms) ✓"
echo "  P95 Response Time: 120ms (target: <200ms) ✓"
echo "  Requests/sec: 1500 (target: >1000) ✓"
echo "  Error Rate: 0.01% (target: <1%) ✓"
```

---

## Step 7: Documentation Review

```bash
# Generate updated documentation
npm run docs:generate

# Review checklist
- [x] API endpoints documented
- [x] Authentication flow diagrams
- [x] Migration guide from v1.x
- [x] Configuration examples
- [x] Troubleshooting guide
- [x] Security best practices
```

---

## Step 8: Week 2 Feedback (Days 8-14)

**Feedback Summary**:

| Metric | Value | Status |
|--------|-------|--------|
| Total Beta Testers | 50 | Good coverage |
| Issues Reported | 8 | Manageable |
| Critical Issues | 0 | Excellent |
| High Priority Issues | 1 | Address in beta.3 |
| Positive Feedback | 45/50 (90%) | Ready for RC |

---

## Step 9: Final Beta Release - Beta 3

```bash
# Fix remaining high-priority issue
git add .
git commit -m "fix: improve error handling for network timeouts"
git commit -m "docs: add troubleshooting section for timeout errors"

# Create final beta release
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh beta 2.0.0

# Output: 2.0.0-beta.3
```

---

## Step 10: Validate Beta Readiness for RC

```bash
# Run comprehensive validation
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/test-prerelease.sh 2.0.0-beta.3
```

**Validation Results**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pre-release Version Validation: 2.0.0-beta.3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ PASS: Version format is valid
✓ PASS: Pre-release type is valid: beta
✓ PASS: All version files consistent
✓ PASS: Git tag exists
✓ PASS: Changelog complete
✓ PASS: Documentation reviewed
✓ PASS: All tests passing
✓ PASS: Performance benchmarks met

Beta Release Checklist:
  ☑ Feature freeze in place
  ☑ External testing ready
  ☑ Documentation reviewed
  ☑ Known bugs tracked
  ☑ Performance tested

Total Checks Passed: 8
Total Checks Failed: 0

✓ PASS: Ready for promotion to Release Candidate
```

---

## Step 11: Promote to Release Candidate

```bash
# All beta testing complete, stable and ready for production testing
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/promote-prerelease.sh 2.0.0-beta.3
```

**Promotion Output**:
```
PROMOTION: Promoting 2.0.0-beta.3 → 2.0.0-rc.1
INFO: Promotion path: Beta → Release Candidate

✓ SUCCESS: VERSION file updated to 2.0.0-rc.1
✓ SUCCESS: package.json updated to 2.0.0-rc.1
✓ SUCCESS: Changelog updated with promotion details
✓ SUCCESS: Git tag v2.0.0-rc.1 created

✓ SUCCESS: Promotion to 2.0.0-rc.1 completed successfully
```

---

## Complete Beta Timeline

| Release | Date | Purpose | Testers | Issues Fixed | Outcome |
|---------|------|---------|---------|--------------|---------|
| 2.0.0-beta.1 | Day 7 | Initial beta | 30 | - | Found critical issues |
| 2.0.0-beta.2 | Day 10 | Critical fixes | 40 | 3 critical | More feedback needed |
| 2.0.0-beta.3 | Day 14 | Final fixes | 50 | 1 high priority | Ready for RC |
| 2.0.0-rc.1 | Day 16 | Promote to RC | - | - | Begin production testing |

**Total Beta Phase Duration**: 9 days
**Total Beta Releases**: 3
**Total Beta Testers**: 50
**Issues Fixed**: 8
**Positive Feedback**: 90%

---

## Beta Success Metrics

**Quality Metrics**:
- 0 critical bugs in final beta
- 1 high-priority issue resolved
- 90% positive feedback from testers
- All performance benchmarks met

**Testing Coverage**:
- Unit tests: 95% coverage
- Integration tests: 100% of endpoints
- E2E tests: All user flows
- Performance tests: Passed all benchmarks

**Documentation**:
- API documentation: Complete
- Migration guide: Reviewed
- Troubleshooting guide: Added
- Security guide: Complete

---

## Key Learnings

1. **Feature Freeze Works**: No new features prevented scope creep
2. **Early Adopters Valuable**: Caught issues internal team missed
3. **Rapid Response**: Quick bug fix releases kept testers engaged
4. **Performance Testing**: Validated scalability before production

---

## Next Steps

Continue with [rc-workflow.md](rc-workflow.md) for the release candidate phase.

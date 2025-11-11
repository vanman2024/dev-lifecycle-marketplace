# Release Candidate Workflow Example

Complete release candidate workflow to stable release.

## Scenario

Continuing from beta phase, now ready for final production validation and stakeholder approval.

**Project**: my-api-server
**Target Version**: 2.0.0
**Current Status**: Promoted to RC (2.0.0-rc.1)

---

## Step 1: Create Release Branch

```bash
# Create release branch from beta branch
git checkout beta/v2.0.0
git pull origin beta/v2.0.0
git checkout -b release/v2.0.0

# Push release branch
git push -u origin release/v2.0.0
```

**Status**: Code freeze is now in effect - only critical bug fixes allowed.

---

## Step 2: Production Environment Testing

```bash
# Deploy to staging (production-like) environment
npm run deploy:staging

# Or using Kubernetes
kubectl set image deployment/my-api-server \
  my-api-server=registry.example.com/my-api-server:2.0.0-rc.1 \
  -n staging

# Verify deployment
kubectl rollout status deployment/my-api-server -n staging
```

**Staging Environment Checklist**:
- [x] Production database (read replica)
- [x] Production-level traffic simulation
- [x] Production SSL certificates
- [x] Production monitoring/logging
- [x] Production-scale infrastructure

---

## Step 3: Comprehensive Testing Suite

```bash
# Run full test suite
npm run test:all

# Results
echo "Test Results:"
echo "  Unit Tests: 245/245 passed ✓"
echo "  Integration Tests: 89/89 passed ✓"
echo "  E2E Tests: 34/34 passed ✓"
echo "  Performance Tests: All benchmarks met ✓"
echo ""
echo "Code Coverage: 96% ✓"
```

---

## Step 4: Security Audit

```bash
# Run security scans
npm audit --production
npm run security:scan

# Results
echo "Security Audit Results:"
echo "  Vulnerabilities: 0 critical, 0 high, 2 moderate ✓"
echo "  Dependencies: All up to date ✓"
echo "  OWASP Top 10: Compliant ✓"
echo "  SSL/TLS: A+ rating ✓"

# Update moderate vulnerabilities
npm update lodash minimist
git add package-lock.json
git commit -m "chore: update dependencies for security patches"
```

---

## Step 5: Performance Validation

```bash
# Load testing with production-like traffic
artillery run load-test-production.yml

# Results
echo "Performance Validation:"
echo "  Concurrent Users: 5000 ✓"
echo "  Avg Response Time: 42ms (target: <100ms) ✓"
echo "  P95 Response Time: 115ms (target: <200ms) ✓"
echo "  P99 Response Time: 180ms (target: <500ms) ✓"
echo "  Requests/sec: 2500 (target: >1000) ✓"
echo "  Error Rate: 0.005% (target: <1%) ✓"
echo "  CPU Usage: 45% (target: <70%) ✓"
echo "  Memory Usage: 2.1GB (target: <4GB) ✓"
```

---

## Step 6: Critical Bug Found - RC 2

**Day 3**: Production testing discovers a critical bug in authentication under high load.

```bash
# Fix critical bug
git add .
git commit -m "fix: resolve authentication deadlock under high concurrency"

# Add regression test
git add tests/
git commit -m "test: add concurrency regression test for authentication"

# Create second RC
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh rc 2.0.0

# Output: 2.0.0-rc.2
```

**Update and Redeploy**:
```bash
git add .
git commit -m "chore: bump version to 2.0.0-rc.2"
git push origin release/v2.0.0
git push origin v2.0.0-rc.2

# Redeploy to staging
npm run deploy:staging

# Rerun high-load tests
artillery run load-test-high-concurrency.yml
# Result: All tests pass ✓
```

---

## Step 7: Stakeholder Approval Process

**Stakeholder Review Checklist**:

### Technical Stakeholders
- [x] **Engineering Lead**: Code quality approved
- [x] **QA Lead**: All test suites passing
- [x] **Security Lead**: Security audit cleared
- [x] **DevOps Lead**: Deployment strategy approved

### Business Stakeholders
- [x] **Product Manager**: Feature set complete
- [x] **Customer Success**: Documentation adequate
- [x] **Executive Sponsor**: Business objectives met

**Approval Meeting** (Day 5):
```
Attendees: All stakeholders
Decision: Approved for production release
Conditions: None
Expected Stable Release Date: Day 7 (2 days from now)
```

---

## Step 8: Final Validation

```bash
# Run comprehensive validation one final time
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/test-prerelease.sh 2.0.0-rc.2
```

**Validation Results**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pre-release Version Validation: 2.0.0-rc.2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ PASS: Version format is valid
✓ PASS: Pre-release type is valid: rc
✓ PASS: All version files consistent
✓ PASS: Git tag exists: v2.0.0-rc.2
✓ PASS: Changelog complete
✓ PASS: README.md exists
✓ PASS: LICENSE file exists
✓ PASS: Tests directory exists
✓ PASS: CI/CD configuration exists

Release Candidate Checklist:
  ☑ All tests passing
  ☑ No known critical bugs
  ☑ Documentation complete
  ☑ Production environment tested
  ☑ Stakeholder approval obtained

Total Checks Passed: 9
Total Checks Failed: 0

✓ PASS: Ready for stable release promotion!
```

---

## Step 9: Prepare Release Documentation

**Create RELEASE_NOTES.md**:
```markdown
# Version 2.0.0 Release Notes

## 🎉 Major Release: New Authentication System

### Highlights

- Complete authentication system rewrite with JWT tokens
- Enhanced security with bcrypt password hashing
- Password reset functionality via email
- Improved session management and token refresh
- 40% faster authentication response times

### Breaking Changes

⚠️ **Action Required**: Migration from v1.x to v2.0.0

1. Update authentication endpoints:
   - `/auth/login` → `/v2/auth/login`
   - `/auth/refresh` → `/v2/auth/refresh`

2. Update JWT token handling:
   - Token format has changed
   - Refresh token rotation implemented

See [MIGRATION.md](MIGRATION.md) for complete guide.

### New Features

- JWT-based authentication (#125)
- Password reset flow (#126)
- Token refresh mechanism (#127)
- Session timeout configuration (#128)

### Improvements

- 40% faster authentication
- Better error messages
- Enhanced logging
- Improved documentation

### Bug Fixes

- Fixed authentication deadlock under high load (#145)
- Fixed token refresh race condition (#142)
- Fixed session timeout edge cases (#139)

### Security

- Updated all dependencies
- Passed security audit
- OWASP Top 10 compliant
- SSL/TLS A+ rating

### Performance

- Avg response time: 42ms
- P95 response time: 115ms
- Handles 2500 req/sec
- 0.005% error rate

### Migration Guide

See [MIGRATION.md](MIGRATION.md) for step-by-step instructions.

### Documentation

- API Documentation: https://docs.example.com/v2.0.0
- Migration Guide: https://docs.example.com/v2.0.0/migration
- Troubleshooting: https://docs.example.com/v2.0.0/troubleshooting
```

---

## Step 10: Promote to Stable Release

```bash
# All approvals obtained, testing complete
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/promote-prerelease.sh 2.0.0-rc.2
```

**Promotion Output**:
```
PROMOTION: Promoting 2.0.0-rc.2 → 2.0.0
INFO: Promotion path: Release Candidate → Stable

✓ SUCCESS: VERSION file updated to 2.0.0
✓ SUCCESS: package.json updated to 2.0.0
✓ SUCCESS: Changelog updated with promotion details
✓ SUCCESS: Git tag v2.0.0 created

🎉 PRODUCTION RELEASE (promoted from 2.0.0-rc.2)

This stable release has been promoted from release candidate.
Production ready and fully tested.

✓ SUCCESS: Promotion to 2.0.0 completed successfully
```

---

## Step 11: Create GitHub Stable Release

```bash
# Commit promotion changes
git add .
git commit -m "chore: release version 2.0.0"
git push origin release/v2.0.0
git push origin v2.0.0

# Create GitHub stable release (NOT pre-release)
gh release create v2.0.0 \
  --title "Version 2.0.0 - New Authentication System" \
  --notes-file RELEASE_NOTES.md \
  --latest
```

---

## Step 12: Production Deployment

```bash
# Deploy to production
npm run deploy:production

# Or using Kubernetes with canary deployment
kubectl set image deployment/my-api-server \
  my-api-server=registry.example.com/my-api-server:2.0.0 \
  -n production

# Monitor rollout
kubectl rollout status deployment/my-api-server -n production

# Verify health
curl https://api.example.com/health
# Output: {"status": "healthy", "version": "2.0.0"}
```

**Deployment Strategy**:
- Canary deployment: 10% → 25% → 50% → 100%
- Monitoring: Real-time error tracking
- Rollback plan: Ready with v1.9.5
- Duration: 2 hours

---

## Step 13: Post-Release Monitoring

```bash
# Monitor for first 24 hours
npm run monitor:production

# Key metrics (first hour)
echo "Production Metrics (1 hour post-release):"
echo "  Requests: 150,000 ✓"
echo "  Error Rate: 0.003% ✓"
echo "  Avg Response Time: 38ms ✓"
echo "  P95 Response Time: 105ms ✓"
echo "  Active Users: 5,000+ ✓"
echo "  Rollback Triggered: No ✓"
```

---

## Complete RC Timeline

| Release | Date | Purpose | Testing | Issues | Outcome |
|---------|------|---------|---------|--------|---------|
| 2.0.0-rc.1 | Day 16 | Initial RC | Staging | 1 critical found | Create RC.2 |
| 2.0.0-rc.2 | Day 18 | Critical fix | Full retest | None | Stakeholder review |
| Approval | Day 20 | Stakeholder meeting | - | - | Approved |
| 2.0.0 | Day 22 | Stable release | Production | None | Success |

**Total RC Phase Duration**: 6 days
**Total RC Releases**: 2
**Critical Issues Fixed**: 1
**Stakeholder Approval**: Unanimous
**Production Deployment**: Successful

---

## Release Success Metrics

**Quality**:
- 0 critical bugs in production
- 96% code coverage
- Security audit passed
- Performance benchmarks exceeded

**Process**:
- RC phase completed on schedule
- All stakeholders approved
- Documentation complete
- Smooth production deployment

**Business**:
- Zero downtime deployment
- No customer complaints
- Performance improved by 40%
- Positive user feedback

---

## Key Learnings

1. **Production Testing Critical**: High-load testing caught critical bug
2. **Stakeholder Alignment**: Clear approval process prevented delays
3. **Documentation Matters**: Comprehensive migration guide reduced support burden
4. **Monitoring Essential**: Real-time metrics enabled confident rollout

---

## Post-Release Actions

1. **Close Release Branch**:
   ```bash
   git checkout main
   git merge release/v2.0.0
   git push origin main
   git branch -d release/v2.0.0
   ```

2. **Update Documentation**:
   - Mark v2.0.0 as latest in docs
   - Update examples to v2.0.0
   - Archive v1.x documentation

3. **Communication**:
   - Send release announcement email
   - Post on social media
   - Update status page
   - Notify customer success team

4. **Retrospective**:
   - Review release process
   - Document lessons learned
   - Update runbooks
   - Celebrate success! 🎉

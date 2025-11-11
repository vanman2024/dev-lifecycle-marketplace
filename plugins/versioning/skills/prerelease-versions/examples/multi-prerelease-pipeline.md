# Multi Pre-release Pipeline Example

Managing multiple concurrent pre-release tracks for complex projects.

## Scenario

Large project with multiple teams working on different features simultaneously, each requiring independent pre-release tracks.

**Project**: enterprise-platform
**Teams**: 3 teams working in parallel
**Goal**: Release version 3.0.0 with three major features

---

## Team Structure

### Team A: Authentication
- Feature: OAuth2 integration
- Version Track: 3.0.0-alpha (auth)

### Team B: Analytics
- Feature: Real-time dashboard
- Version Track: 3.0.0-alpha (analytics)

### Team C: API Gateway
- Feature: Rate limiting v2
- Version Track: 3.0.0-alpha (gateway)

---

## Week 1: Parallel Alpha Development

### Team A - Authentication Track

```bash
# Create feature branch
git checkout -b alpha/v3.0.0-auth
git push -u origin alpha/v3.0.0-auth

# Create alpha release
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh alpha 3.0.0
# Output: 3.0.0-alpha.1

# Tag with team identifier
git tag v3.0.0-alpha.1-auth
git push origin v3.0.0-alpha.1-auth
```

### Team B - Analytics Track

```bash
# Create separate feature branch
git checkout -b alpha/v3.0.0-analytics
git push -u origin alpha/v3.0.0-analytics

# Create alpha release
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh alpha 3.0.0
# Output: 3.0.0-alpha.1

# Tag with team identifier
git tag v3.0.0-alpha.1-analytics
git push origin v3.0.0-alpha.1-analytics
```

### Team C - Gateway Track

```bash
# Create separate feature branch
git checkout -b alpha/v3.0.0-gateway
git push -u origin alpha/v3.0.0-gateway

# Create alpha release
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh alpha 3.0.0
# Output: 3.0.0-alpha.1

# Tag with team identifier
git tag v3.0.0-alpha.1-gateway
git push origin v3.0.0-alpha.1-gateway
```

---

## Week 2: Independent Iteration

### Team A Progress
```bash
# Alpha iterations
3.0.0-alpha.1-auth → OAuth2 basic implementation
3.0.0-alpha.2-auth → Token refresh added
3.0.0-alpha.3-auth → SSO integration complete
```

### Team B Progress
```bash
# Alpha iterations
3.0.0-alpha.1-analytics → Dashboard foundation
3.0.0-alpha.2-analytics → Real-time data pipeline
3.0.0-alpha.3-analytics → Visualization widgets
3.0.0-alpha.4-analytics → Performance optimization
```

### Team C Progress
```bash
# Alpha iterations
3.0.0-alpha.1-gateway → Rate limiter prototype
3.0.0-alpha.2-gateway → Redis integration
```

**Status**: Teams progressing at different rates independently.

---

## Week 3: Integration Branch

### Create Integration Branch

```bash
# Create integration branch from main
git checkout main
git checkout -b integration/v3.0.0

# Merge Team A (auth)
git merge alpha/v3.0.0-auth --no-ff -m "Merge auth feature"

# Merge Team B (analytics)
git merge alpha/v3.0.0-analytics --no-ff -m "Merge analytics feature"

# Merge Team C (gateway)
git merge alpha/v3.0.0-gateway --no-ff -m "Merge gateway feature"

# Resolve conflicts
git status
# Resolve any merge conflicts
git add .
git commit -m "Resolve integration conflicts"

# Push integration branch
git push -u origin integration/v3.0.0
```

---

## Week 3: First Unified Alpha

```bash
# Create unified alpha from integration branch
git checkout integration/v3.0.0

# Create alpha release with all features
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh alpha 3.0.0
# Output: 3.0.0-alpha.1

# Tag as unified release
git tag v3.0.0-alpha.1-unified
git push origin v3.0.0-alpha.1-unified
```

**Testing**: First time all three features tested together.

**Results**:
- Auth + Analytics: Works ✓
- Auth + Gateway: Works ✓
- Analytics + Gateway: **Conflict found** ✗
- All three: **Gateway rate limiter blocks analytics** ✗

---

## Week 4: Fix Integration Issues

### Team B & C Collaboration

```bash
# Fix analytics/gateway conflict
git checkout integration/v3.0.0
git pull

# Team C fixes gateway to allow analytics traffic
git add .
git commit -m "fix: whitelist analytics endpoints in rate limiter"

# Team B adjusts analytics to respect rate limits
git add .
git commit -m "fix: add rate limit backoff to analytics data fetcher"

# Create second unified alpha
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/create-prerelease.sh alpha 3.0.0
# Output: 3.0.0-alpha.2

git tag v3.0.0-alpha.2-unified
git push origin v3.0.0-alpha.2-unified
```

**Retest**: All features work together ✓

---

## Week 5: Promote to Beta

```bash
# All teams' features complete and integrated
git checkout integration/v3.0.0

# Promote unified alpha to beta
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/promote-prerelease.sh 3.0.0-alpha.2
# Output: 3.0.0-beta.1

# Create beta branch
git checkout -b beta/v3.0.0
git push -u origin beta/v3.0.0

# Tag beta
git tag v3.0.0-beta.1
git push origin v3.0.0-beta.1
```

**Status**: Feature freeze - all teams now work on bug fixes only.

---

## Week 6: Beta Feedback

### Issues from External Testing

| Issue | Team | Severity | Status |
|-------|------|----------|--------|
| #201 | Auth | High | Fixed in beta.2 |
| #202 | Analytics | Medium | Fixed in beta.2 |
| #203 | Gateway | High | Fixed in beta.2 |
| #204 | Integration | Critical | Fixed in beta.3 |

### Beta Iterations

```bash
# Beta.2 - Team fixes
3.0.0-beta.2 (Week 6, Day 3) - Individual team fixes

# Beta.3 - Integration fix
3.0.0-beta.3 (Week 6, Day 6) - Critical integration bug
```

---

## Week 7: Promote to RC

```bash
# Beta testing complete
git checkout beta/v3.0.0

# Promote to release candidate
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/promote-prerelease.sh 3.0.0-beta.3
# Output: 3.0.0-rc.1

# Create release branch
git checkout -b release/v3.0.0
git push -u origin release/v3.0.0

# Tag RC
git tag v3.0.0-rc.1
git push origin v3.0.0-rc.1
```

---

## Week 8: Production Validation & Release

```bash
# RC testing in staging
# All teams validate their features
# Stakeholder approval obtained

# Promote to stable
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/prerelease-versions/scripts/promote-prerelease.sh 3.0.0-rc.1
# Output: 3.0.0

# Tag stable release
git tag v3.0.0
git push origin v3.0.0

# Merge to main
git checkout main
git merge release/v3.0.0
git push origin main
```

---

## Complete Multi-Team Timeline

```
Week 1: Parallel Alpha Development
├── Team A: 3.0.0-alpha.1-auth
├── Team B: 3.0.0-alpha.1-analytics
└── Team C: 3.0.0-alpha.1-gateway

Week 2: Independent Iteration
├── Team A: alpha.1-3 (auth)
├── Team B: alpha.1-4 (analytics)
└── Team C: alpha.1-2 (gateway)

Week 3: Integration
├── Create integration branch
├── Merge all teams
├── 3.0.0-alpha.1-unified
└── Find integration issues

Week 4: Fix Integration
├── Teams collaborate
├── 3.0.0-alpha.2-unified
└── All features working together

Week 5: Beta Release
├── Promote to 3.0.0-beta.1
├── Feature freeze
└── External testing begins

Week 6: Beta Iteration
├── 3.0.0-beta.2 (team fixes)
└── 3.0.0-beta.3 (integration fix)

Week 7: Release Candidate
├── Promote to 3.0.0-rc.1
└── Production testing

Week 8: Stable Release
├── Promote to 3.0.0
└── Deploy to production
```

---

## Version Conflict Resolution

### Scenario: Two Teams Create Same Version

**Problem**:
```bash
# Team A creates alpha.5
git tag v3.0.0-alpha.5-auth

# Team B also creates alpha.5 (conflict!)
git tag v3.0.0-alpha.5-analytics
```

**Solution**: Use team suffixes consistently

```bash
# Each team maintains their own version sequence
Team A: v3.0.0-alpha.1-auth, v3.0.0-alpha.2-auth, ...
Team B: v3.0.0-alpha.1-analytics, v3.0.0-alpha.2-analytics, ...

# Unified releases use different naming
Unified: v3.0.0-alpha.1-unified, v3.0.0-alpha.2-unified, ...
```

---

## Backport Strategy

### Scenario: Critical Bug in Production During Alpha

**Current State**:
- Production: v2.5.0
- In Development: v3.0.0-alpha.* (multiple tracks)

**Critical Bug Found**: Security vulnerability in v2.5.0

**Backport Process**:

```bash
# Create hotfix branch from production tag
git checkout v2.5.0
git checkout -b hotfix/v2.5.1

# Apply fix
git cherry-pick <security-fix-commit>

# Release hotfix
git tag v2.5.1
git push origin v2.5.1
git push origin hotfix/v2.5.1

# Deploy to production immediately
npm run deploy:production

# Backport to all alpha branches
# Team A
git checkout alpha/v3.0.0-auth
git cherry-pick <security-fix-commit>

# Team B
git checkout alpha/v3.0.0-analytics
git cherry-pick <security-fix-commit>

# Team C
git checkout alpha/v3.0.0-gateway
git cherry-pick <security-fix-commit>

# Backport to integration
git checkout integration/v3.0.0
git cherry-pick <security-fix-commit>
```

---

## Communication Strategy

### Daily Standups (Per Team)
- Progress on feature-specific alphas
- Blockers or dependencies on other teams
- Next release plans

### Weekly Integration Meeting (All Teams)
- Review integration branch status
- Resolve conflicts
- Plan unified alpha releases
- Coordinate timelines

### Release Announcements
```markdown
# Internal: Slack Notifications

## Alpha Releases (Team Channels)
#team-a: "🚧 Auth alpha.3 ready for testing"
#team-b: "🚧 Analytics alpha.4 deployed to dev"
#team-c: "🚧 Gateway alpha.2 has breaking changes"

## Unified Releases (All Teams Channel)
#platform-releases: "🧪 Unified alpha.1 - First integration test"

## Beta/RC Releases (Company-wide)
#announcements: "🧪 Beta.1 ready for external testing"
```

---

## Key Learnings

1. **Parallel Development Works**: Teams can progress independently
2. **Integration Testing Critical**: Found issues only when features combined
3. **Team Suffixes Essential**: Prevented version conflicts
4. **Regular Integration**: Weekly unified alphas caught issues early
5. **Clear Communication**: Coordinated releases across teams

---

## Best Practices for Multi-Team Pre-releases

1. **Use branch naming conventions**:
   - `alpha/<feature>`: Feature-specific development
   - `integration/v*`: Unified integration testing
   - `beta/v*`: External testing
   - `release/v*`: Production candidate

2. **Tag naming conventions**:
   - `v*.*.*-alpha.N-<team>`: Team-specific alphas
   - `v*.*.*-alpha.N-unified`: Integrated alphas
   - `v*.*.*-beta.N`: External beta testing
   - `v*.*.*-rc.N`: Release candidates

3. **Integration frequency**: At least weekly unified alphas

4. **Communication protocols**: Clear channels for each release type

5. **Conflict resolution**: Integration team or lead architect

6. **Testing strategy**: Individual features + integrated testing

---

## Summary

Multi-team pre-release pipelines enable parallel development while ensuring successful integration through:
- Independent alpha tracks per team
- Regular unified integration testing
- Clear version and branch naming
- Coordinated promotion to beta/RC
- Comprehensive communication strategy

Total Timeline: 8 weeks from parallel alphas to stable release
Total Releases: 15+ (across all tracks)
Teams: 3 parallel teams
Result: Successful v3.0.0 with three major features integrated

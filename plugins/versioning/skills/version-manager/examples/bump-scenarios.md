# Version Bump Scenarios

## Scenario 1: Patch Bump (Bug Fixes)

**Current Version:** 1.2.3

**Commits:**
- fix: resolve memory leak
- fix(api): correct validation logic

**Command:**
```bash
/versioning:bump patch
```

**Result:** 1.2.3 → 1.2.4

## Scenario 2: Minor Bump (New Features)

**Current Version:** 1.2.4

**Commits:**
- feat: add OAuth authentication
- feat(api): implement rate limiting
- fix: resolve CORS issue

**Command:**
```bash
/versioning:bump minor
```

**Result:** 1.2.4 → 1.3.0

## Scenario 3: Major Bump (Breaking Changes)

**Current Version:** 1.3.0

**Commits:**
- feat!: redesign API endpoints
- BREAKING CHANGE: Remove v1 API

**Command:**
```bash
/versioning:bump major
```

**Result:** 1.3.0 → 2.0.0

## Scenario 4: Dry Run (Preview Only)

**Current Version:** 2.0.0

**Command:**
```bash
/versioning:bump minor --dry-run
```

**Result:** Shows what would change, but doesn't modify files

## Scenario 5: Automatic Bump with Force Push

**Current Version:** 2.1.0

**Command:**
```bash
/versioning:bump patch --force
```

**Result:** 2.1.0 → 2.1.1, automatically pushes to remote

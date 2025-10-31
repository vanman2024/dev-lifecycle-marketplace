# Conventional Commits Examples

## Feature Commits (Minor Version Bump)

```bash
git commit -m "feat: add user authentication system"
git commit -m "feat(api): implement rate limiting"
git commit -m "feat(ui): add dark mode toggle"
```

## Bug Fix Commits (Patch Version Bump)

```bash
git commit -m "fix: resolve memory leak in WebSocket connections"
git commit -m "fix(auth): correct token expiration logic"
git commit -m "fix(ui): resolve button alignment on mobile"
```

## Breaking Change Commits (Major Version Bump)

```bash
git commit -m "feat!: redesign API structure

BREAKING CHANGE: All endpoints now use /api/v2/ prefix.
Previous v1 endpoints are removed."

git commit -m "refactor(database)!: change primary keys to UUID

BREAKING CHANGE: Database migration required.
Run: npm run migrate:uuid"
```

## Performance Commits (Patch Version Bump)

```bash
git commit -m "perf: optimize database query performance"
git commit -m "perf(api): implement request caching"
```

## Documentation Commits (No Version Bump)

```bash
git commit -m "docs: update installation guide"
git commit -m "docs(api): add authentication examples"
```

## Chore Commits (No Version Bump)

```bash
git commit -m "chore: update dependencies"
git commit -m "chore(ci): configure GitHub Actions"
git commit -m "chore(deps): upgrade TypeScript to 5.0"
```

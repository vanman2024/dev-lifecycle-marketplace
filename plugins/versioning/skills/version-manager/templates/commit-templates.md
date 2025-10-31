# Conventional Commit Templates

## Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Types

### feat: New feature (minor version bump)
```
feat: add user authentication
feat(auth): add OAuth support with Google and GitHub providers
```

### fix: Bug fix (patch version bump)
```
fix: resolve memory leak in connection pool
fix(api): correct token expiration validation logic
```

### BREAKING CHANGE: Breaking change (major version bump)
```
feat!: redesign API endpoints

BREAKING CHANGE: All endpoints now use /api/v2/ prefix.
Previous /api/v1/ endpoints are removed.
```

### perf: Performance improvement (patch version bump)
```
perf: optimize database queries with connection pooling
perf(db): reduce query time by 60% with indexing
```

### docs: Documentation only
```
docs: update installation guide
docs(api): add examples for authentication endpoints
```

### chore: Maintenance tasks
```
chore: update dependencies
chore(deps): upgrade TypeScript to 5.0
```

## Examples with Scope

```
feat(auth): add JWT token refresh mechanism
fix(ui): resolve button alignment in mobile view
perf(api): implement request caching layer
docs(readme): add contribution guidelines
chore(ci): update GitHub Actions workflow
```

## Examples with Breaking Changes

```
feat!: remove deprecated API v1 endpoints

BREAKING CHANGE: API v1 is no longer supported.
All clients must migrate to v2.
```

```
refactor(database)!: change primary key from int to UUID

BREAKING CHANGE: Database schema migration required.
All existing IDs will be converted to UUIDs.
Migration script: scripts/migrate-to-uuid.sql
```

## Examples with Issue References

```
fix: resolve CORS configuration (#456)
feat: implement rate limiting (closes #123)
docs: update API documentation (ref #789)
```

## Multi-line Commits

```
feat: add advanced search functionality

Implemented full-text search with:
- Fuzzy matching
- Filter by category
- Sort by relevance

Closes #234
```

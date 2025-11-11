# Example: Database Migration Detection

This example demonstrates detecting breaking changes in database schemas during migrations.

## Scenario

An application database is being updated to support new features. We need to detect schema changes that could break existing application code or data integrity.

## Input Files

### Old Schema (v1)

**File:** `schema-v1.sql`

```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts table
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Comments table
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Tags table
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Post-Tag relationship
CREATE TABLE post_tags (
    post_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (tag_id) REFERENCES tags(id)
);

-- Indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE UNIQUE INDEX idx_users_email ON users(email);
```

### New Schema (v2)

**File:** `schema-v2.sql`

```sql
-- Users table - Modified
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- BREAKING: Changed from SERIAL to UUID
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),  -- Non-breaking: Added nullable column
    bio TEXT,  -- Non-breaking: Added nullable column
    status VARCHAR(20) DEFAULT 'active' NOT NULL,  -- Non-breaking: Added with default
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts table - Modified
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- BREAKING: Changed from SERIAL to UUID
    user_id UUID NOT NULL,  -- BREAKING: Changed type to match users.id
    title VARCHAR(255) NOT NULL,
    content TEXT,
    published BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0 NOT NULL,  -- Non-breaking: Added with default
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Comments table - Modified
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- BREAKING: Changed from SERIAL to UUID
    post_id UUID NOT NULL,  -- BREAKING: Changed type to match posts.id
    user_id UUID NOT NULL,  -- BREAKING: Changed type to match users.id
    content TEXT NOT NULL,
    is_edited BOOLEAN DEFAULT FALSE,  -- Non-breaking: Added with default
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tags table - No changes
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT  -- Non-breaking: Added nullable column
);

-- Post-Tag relationship - Modified
CREATE TABLE post_tags (
    post_id UUID NOT NULL,  -- BREAKING: Changed from INTEGER to UUID
    tag_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Non-breaking: Added
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Likes table - New table (non-breaking)
CREATE TABLE likes (
    user_id UUID NOT NULL,
    post_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at);  -- New index
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);  -- New index
CREATE UNIQUE INDEX idx_users_email ON users(email);

-- Followers table - BREAKING: Was removed from old schema
-- CREATE TABLE followers (...) -- REMOVED
```

## Running the Analysis

```bash
# Run schema comparison script
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/breaking-change-detection/scripts/schema-compare.sh \
  schema-v1.sql \
  schema-v2.sql \
  --output schema-breaking-changes.md
```

## Expected Output

```
🔍 Analyzing database schemas...
   Old: schema-v1.sql
   New: schema-v2.sql

📊 Checking for dropped tables...
✅ No dropped tables

📊 Checking for column modifications...
❌ BREAKING: Field type reused in message 'users'
   - id: SERIAL → UUID

❌ BREAKING: Field type reused in message 'posts'
   - id: SERIAL → UUID
   - user_id: INTEGER → UUID

❌ BREAKING: Field type reused in message 'comments'
   - id: SERIAL → UUID
   - post_id: INTEGER → UUID
   - user_id: INTEGER → UUID

✅ Added nullable column in 'users': full_name
✅ Added nullable column in 'users': bio
✅ Added NOT NULL column with DEFAULT in 'users': status

📊 Checking for constraint modifications...
✅ No foreign key constraints removed

================================
📋 Summary
================================
Breaking changes: 8
Non-breaking changes: 6

❌ Breaking changes detected - MAJOR version bump required
```

## Generated Report

**File:** `schema-breaking-changes.md`

```markdown
# Database Schema Breaking Change Report

**Generated:** 2024-11-05 18:00:00 UTC
**Old Schema:** schema-v1.sql
**New Schema:** schema-v2.sql

## Summary

- **Breaking Changes:** 8
- **Non-Breaking Changes:** 6

⚠️ **RECOMMENDATION:** This schema change requires a **MAJOR version bump** (e.g., v2.0.0)

**CRITICAL:** Ensure data migration scripts are prepared before deployment.

## Detected Changes

### ❌ BREAKING: Column Type Changed
**Table:** `users`
**Column:** `id`
**Old Type:** `SERIAL` (INTEGER)
**New Type:** `UUID`
**Impact:** All foreign keys referencing this column will break

### ❌ BREAKING: Column Type Changed
**Table:** `posts`
**Column:** `id`
**Old Type:** `SERIAL` (INTEGER)
**New Type:** `UUID`
**Impact:** All foreign keys referencing this column will break

### ❌ BREAKING: Column Type Changed
**Table:** `posts`
**Column:** `user_id`
**Old Type:** `INTEGER`
**New Type:** `UUID`
**Impact:** Foreign key relationship broken, queries will fail

[Additional breaking changes listed...]

## Non-Breaking Changes

✅ Added nullable column: `users.full_name`
✅ Added nullable column: `users.bio`
✅ Added column with default: `users.status`
✅ Added nullable column: `tags.description`
✅ Added new table: `likes`
✅ Added index: `idx_posts_created_at`
```

## Data Migration Script

### Phase 1: Preparation (Zero Downtime)

```sql
-- Step 1: Add UUID columns alongside existing INTEGER columns
ALTER TABLE users ADD COLUMN id_uuid UUID DEFAULT gen_random_uuid();
ALTER TABLE posts ADD COLUMN id_uuid UUID DEFAULT gen_random_uuid();
ALTER TABLE posts ADD COLUMN user_id_uuid UUID;
ALTER TABLE comments ADD COLUMN id_uuid UUID DEFAULT gen_random_uuid();
ALTER TABLE comments ADD COLUMN post_id_uuid UUID;
ALTER TABLE comments ADD COLUMN user_id_uuid UUID;
ALTER TABLE post_tags ADD COLUMN post_id_uuid UUID;

-- Step 2: Create mapping table for ID conversion
CREATE TABLE id_mapping_users (
    old_id INTEGER PRIMARY KEY,
    new_id UUID NOT NULL
);

CREATE TABLE id_mapping_posts (
    old_id INTEGER PRIMARY KEY,
    new_id UUID NOT NULL
);

CREATE TABLE id_mapping_comments (
    old_id INTEGER PRIMARY KEY,
    new_id UUID NOT NULL
);

-- Step 3: Populate mapping tables
INSERT INTO id_mapping_users (old_id, new_id)
SELECT id, id_uuid FROM users;

INSERT INTO id_mapping_posts (old_id, new_id)
SELECT id, id_uuid FROM posts;

INSERT INTO id_mapping_comments (old_id, new_id)
SELECT id, id_uuid FROM comments;

-- Step 4: Backfill UUID foreign keys
UPDATE posts p
SET user_id_uuid = m.new_id
FROM id_mapping_users m
WHERE p.user_id = m.old_id;

UPDATE comments c
SET post_id_uuid = m.new_id
FROM id_mapping_posts m
WHERE c.post_id = m.old_id;

UPDATE comments c
SET user_id_uuid = m.new_id
FROM id_mapping_users m
WHERE c.user_id = m.old_id;

UPDATE post_tags pt
SET post_id_uuid = m.new_id
FROM id_mapping_posts m
WHERE pt.post_id = m.old_id;

-- Verify all UUIDs populated
SELECT 'users' AS table_name, COUNT(*) AS null_uuids
FROM users WHERE id_uuid IS NULL
UNION ALL
SELECT 'posts', COUNT(*)
FROM posts WHERE id_uuid IS NULL OR user_id_uuid IS NULL
UNION ALL
SELECT 'comments', COUNT(*)
FROM comments WHERE id_uuid IS NULL OR post_id_uuid IS NULL OR user_id_uuid IS NULL;
```

### Phase 2: Application Update (Dual Write)

Update application to write both INTEGER and UUID values:

```python
# Before (v1)
def create_user(username, email, password):
    cursor.execute(
        "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s) RETURNING id",
        (username, email, hash_password(password))
    )
    return cursor.fetchone()[0]

# During Migration (v1.5 - Dual Write)
def create_user(username, email, password):
    cursor.execute(
        """
        INSERT INTO users (username, email, password_hash, id_uuid)
        VALUES (%s, %s, %s, gen_random_uuid())
        RETURNING id, id_uuid
        """,
        (username, email, hash_password(password))
    )
    row = cursor.fetchone()
    return {'id': row[0], 'id_uuid': row[1]}
```

### Phase 3: Cutover (Short Downtime Required)

```sql
BEGIN;

-- Drop old foreign key constraints
ALTER TABLE posts DROP CONSTRAINT posts_user_id_fkey;
ALTER TABLE comments DROP CONSTRAINT comments_post_id_fkey;
ALTER TABLE comments DROP CONSTRAINT comments_user_id_fkey;
ALTER TABLE post_tags DROP CONSTRAINT post_tags_post_id_fkey;

-- Drop old primary keys
ALTER TABLE users DROP CONSTRAINT users_pkey;
ALTER TABLE posts DROP CONSTRAINT posts_pkey;
ALTER TABLE comments DROP CONSTRAINT comments_pkey;

-- Drop old columns
ALTER TABLE users DROP COLUMN id;
ALTER TABLE posts DROP COLUMN id;
ALTER TABLE posts DROP COLUMN user_id;
ALTER TABLE comments DROP COLUMN id;
ALTER TABLE comments DROP COLUMN post_id;
ALTER TABLE comments DROP COLUMN user_id;
ALTER TABLE post_tags DROP COLUMN post_id;

-- Rename UUID columns to replace old columns
ALTER TABLE users RENAME COLUMN id_uuid TO id;
ALTER TABLE posts RENAME COLUMN id_uuid TO id;
ALTER TABLE posts RENAME COLUMN user_id_uuid TO user_id;
ALTER TABLE comments RENAME COLUMN id_uuid TO id;
ALTER TABLE comments RENAME COLUMN post_id_uuid TO post_id;
ALTER TABLE comments RENAME COLUMN user_id_uuid TO user_id;
ALTER TABLE post_tags RENAME COLUMN post_id_uuid TO post_id;

-- Add new primary keys
ALTER TABLE users ADD PRIMARY KEY (id);
ALTER TABLE posts ADD PRIMARY KEY (id);
ALTER TABLE comments ADD PRIMARY KEY (id);

-- Add new foreign key constraints
ALTER TABLE posts
    ADD CONSTRAINT posts_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE comments
    ADD CONSTRAINT comments_post_id_fkey
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;

ALTER TABLE comments
    ADD CONSTRAINT comments_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE post_tags
    ADD CONSTRAINT post_tags_post_id_fkey
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE;

-- Add new columns
ALTER TABLE users ADD COLUMN full_name VARCHAR(255);
ALTER TABLE users ADD COLUMN bio TEXT;
ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active' NOT NULL;
ALTER TABLE posts ADD COLUMN view_count INTEGER DEFAULT 0 NOT NULL;
ALTER TABLE comments ADD COLUMN is_edited BOOLEAN DEFAULT FALSE;

-- Create new table
CREATE TABLE likes (
    user_id UUID NOT NULL,
    post_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

-- Update schema version
INSERT INTO schema_migrations (version) VALUES ('2.0.0');

COMMIT;

-- Post-migration: Analyze tables
ANALYZE users;
ANALYZE posts;
ANALYZE comments;
ANALYZE post_tags;
```

### Phase 4: Application Update (v2)

Update application to use UUID exclusively:

```python
# After (v2)
def create_user(username, email, password):
    cursor.execute(
        """
        INSERT INTO users (username, email, password_hash)
        VALUES (%s, %s, %s)
        RETURNING id
        """,
        (username, email, hash_password(password))
    )
    return cursor.fetchone()[0]  # Returns UUID

def get_user_posts(user_id):
    # user_id is now UUID
    cursor.execute(
        "SELECT id, title, content FROM posts WHERE user_id = %s",
        (user_id,)
    )
    return cursor.fetchall()
```

## Rollback Plan

```sql
-- Create backup before migration
CREATE TABLE users_backup AS SELECT * FROM users;
CREATE TABLE posts_backup AS SELECT * FROM posts;
CREATE TABLE comments_backup AS SELECT * FROM comments;

-- If rollback needed:
BEGIN;

-- Restore from backup
TRUNCATE users, posts, comments CASCADE;

INSERT INTO users SELECT * FROM users_backup;
INSERT INTO posts SELECT * FROM posts_backup;
INSERT INTO comments SELECT * FROM comments_backup;

-- Remove new schema version
DELETE FROM schema_migrations WHERE version = '2.0.0';

COMMIT;
```

## Testing Validation

```python
# Test script to verify migration
import psycopg2
import uuid

conn = psycopg2.connect("dbname=mydb user=myuser")
cur = conn.cursor()

# Test 1: Verify UUID format
cur.execute("SELECT id FROM users LIMIT 1")
user_id = cur.fetchone()[0]
assert isinstance(user_id, uuid.UUID), "User ID should be UUID"

# Test 2: Verify foreign key relationships
cur.execute("""
    SELECT COUNT(*)
    FROM posts p
    LEFT JOIN users u ON p.user_id = u.id
    WHERE u.id IS NULL
""")
orphaned = cur.fetchone()[0]
assert orphaned == 0, f"Found {orphaned} orphaned posts"

# Test 3: Verify new columns exist
cur.execute("""
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_name = 'users'
    AND column_name IN ('full_name', 'bio', 'status')
""")
new_columns = cur.fetchall()
assert len(new_columns) == 3, "Missing new columns in users table"

print("✅ All migration tests passed")
```

## Key Takeaways

1. **Type Changes:** INTEGER → UUID requires careful migration with mapping tables
2. **Zero Downtime:** Use dual-write period for gradual migration
3. **Foreign Keys:** Must be dropped and recreated after type changes
4. **Backups:** Always create backups before destructive operations
5. **Testing:** Verify data integrity at every step
6. **Rollback:** Have a tested rollback plan ready

## Best Practices

1. **Run in staging first:** Test complete migration process
2. **Monitor performance:** Check query performance with new types
3. **Batch operations:** Process large tables in chunks
4. **Communication:** Coordinate with all teams before downtime
5. **Verification:** Run extensive tests post-migration

## Related Resources

- Migration Guide Template: `templates/migration-guide-database.md`
- Breaking Change Report: `templates/breaking-change-report.md`
- Schema Comparison Script: `scripts/schema-compare.sh`

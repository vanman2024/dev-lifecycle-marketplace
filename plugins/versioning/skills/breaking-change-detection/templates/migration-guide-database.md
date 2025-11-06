# Database Migration Guide: Schema [OLD_VERSION] → [NEW_VERSION]

**Schema Version:** [NEW_VERSION]
**Database:** [PostgreSQL/MySQL/MongoDB/etc]
**Migration Date:** [DATE]
**Downtime Required:** [YES/NO] ([DURATION])

---

## Migration Overview

### Changes Summary

| Change Type | Count | Reversible |
|-------------|-------|------------|
| Tables Dropped | [NUM] | ❌ No |
| Columns Removed | [NUM] | ❌ No |
| Type Changes | [NUM] | ⚠️ Partial |
| Constraints Added | [NUM] | ✅ Yes |
| Indexes Added | [NUM] | ✅ Yes |

### Impact Assessment

- **Data Loss Risk:** [HIGH/MEDIUM/LOW]
- **Downtime Required:** [YES/NO]
- **Rollback Complexity:** [HIGH/MEDIUM/LOW]
- **Migration Duration:** [ESTIMATED_TIME]

---

## Pre-Migration Checklist

Before running migration:

- [ ] **Backup database**
  ```bash
  pg_dump -U postgres -d database_name > backup_$(date +%Y%m%d_%H%M%S).sql
  ```

- [ ] **Verify disk space** (need [SIZE]GB free)
  ```bash
  df -h /var/lib/postgresql/data
  ```

- [ ] **Test migration in staging environment**

- [ ] **Schedule maintenance window** ([DURATION])

- [ ] **Notify stakeholders** about downtime

- [ ] **Prepare rollback plan**

---

## Schema Changes

### 1. Dropped Tables

#### Table: `[table_name]`

**Status:** ❌ REMOVED
**Reason:** [Explanation]
**Data Migration:** Required before dropping

##### Backup Data

```sql
-- Export data to backup table
CREATE TABLE [table_name]_backup AS
SELECT * FROM [table_name];

-- Or export to CSV
COPY [table_name] TO '/tmp/[table_name]_backup.csv' CSV HEADER;
```

##### Update Application Code

Remove all references to this table:

```python
# Before - Remove these queries
db.query("SELECT * FROM [table_name]")
db.execute("INSERT INTO [table_name] ...")

# After - Use new table structure
db.query("SELECT * FROM [new_table_name]")
```

---

### 2. Removed Columns

#### Table: `[table_name]`, Column: `[column_name]`

**Status:** ❌ REMOVED
**Reason:** [Explanation]
**Alternative:** [New column/table]

##### Migration Steps

**Step 1: Backup column data**
```sql
-- Create backup of column data
CREATE TABLE [table_name]_[column_name]_backup AS
SELECT id, [column_name]
FROM [table_name];
```

**Step 2: Update application to stop using column**
```python
# Before
user = db.query("SELECT id, name, [column_name] FROM users").first()
value = user.[column_name]

# After
user = db.query("SELECT id, name FROM users").first()
# Remove references to [column_name]
```

**Step 3: Run migration**
```sql
-- Remove column
ALTER TABLE [table_name]
DROP COLUMN [column_name];
```

---

### 3. Column Type Changes

#### Table: `[table_name]`, Column: `[column_name]`

**Old Type:** `[old_type]`
**New Type:** `[new_type]`
**Reason:** [Explanation]

##### Migration Strategy

**⚠️ WARNING:** Type changes may cause data loss or truncation!

**Step 1: Verify data compatibility**
```sql
-- Check for values that won't fit in new type
SELECT [column_name], LENGTH([column_name])
FROM [table_name]
WHERE LENGTH([column_name]) > [new_max_length];

-- Check for invalid values
SELECT [column_name]
FROM [table_name]
WHERE [column_name] NOT SIMILAR TO '[validation_pattern]';
```

**Step 2: Create temporary column**
```sql
-- Add new column with new type
ALTER TABLE [table_name]
ADD COLUMN [column_name]_new [new_type];

-- Copy and transform data
UPDATE [table_name]
SET [column_name]_new = CAST([column_name] AS [new_type]);
-- Or with transformation:
-- SET [column_name]_new = [transformation_function]([column_name]);
```

**Step 3: Verify data integrity**
```sql
-- Compare old and new values
SELECT
  id,
  [column_name] AS old_value,
  [column_name]_new AS new_value
FROM [table_name]
WHERE [column_name] IS DISTINCT FROM CAST([column_name]_new AS [old_type])
LIMIT 100;
```

**Step 4: Swap columns (during downtime)**
```sql
BEGIN;

-- Drop old column
ALTER TABLE [table_name]
DROP COLUMN [column_name];

-- Rename new column
ALTER TABLE [table_name]
RENAME COLUMN [column_name]_new TO [column_name];

COMMIT;
```

---

### 4. Added NOT NULL Constraints

#### Table: `[table_name]`, Column: `[column_name]`

**Change:** Column now requires NOT NULL constraint
**Reason:** [Explanation]

##### Migration Steps

**Step 1: Set default values for NULL rows**
```sql
-- Identify NULL values
SELECT COUNT(*)
FROM [table_name]
WHERE [column_name] IS NULL;

-- Update NULL values with defaults
UPDATE [table_name]
SET [column_name] = [default_value]
WHERE [column_name] IS NULL;
```

**Step 2: Add NOT NULL constraint**
```sql
-- Add constraint
ALTER TABLE [table_name]
ALTER COLUMN [column_name] SET NOT NULL;

-- Add default for future inserts
ALTER TABLE [table_name]
ALTER COLUMN [column_name] SET DEFAULT [default_value];
```

**Step 3: Update application code**
```python
# Before - NULL was acceptable
db.execute("INSERT INTO [table_name] (name) VALUES (?)", (name,))

# After - Must provide value
db.execute(
    "INSERT INTO [table_name] (name, [column_name]) VALUES (?, ?)",
    (name, default_value)
)
```

---

### 5. Foreign Key Changes

#### Table: `[table_name]`

**Change:** Foreign key constraint modified
**Old FK:** `[old_fk_definition]`
**New FK:** `[new_fk_definition]`

##### Migration Steps

**Step 1: Identify orphaned records**
```sql
-- Find records that violate new FK
SELECT t1.id, t1.[fk_column]
FROM [table_name] t1
LEFT JOIN [referenced_table] t2 ON t1.[fk_column] = t2.id
WHERE t2.id IS NULL;
```

**Step 2: Handle orphaned records**
```sql
-- Option A: Delete orphaned records
DELETE FROM [table_name]
WHERE [fk_column] NOT IN (SELECT id FROM [referenced_table]);

-- Option B: Set to NULL (if column is nullable)
UPDATE [table_name]
SET [fk_column] = NULL
WHERE [fk_column] NOT IN (SELECT id FROM [referenced_table]);

-- Option C: Create placeholder records
INSERT INTO [referenced_table] (id, [required_fields])
SELECT DISTINCT [fk_column], [default_values]
FROM [table_name]
WHERE [fk_column] NOT IN (SELECT id FROM [referenced_table]);
```

**Step 3: Drop old FK and create new**
```sql
-- Drop old constraint
ALTER TABLE [table_name]
DROP CONSTRAINT [old_constraint_name];

-- Add new constraint
ALTER TABLE [table_name]
ADD CONSTRAINT [new_constraint_name]
FOREIGN KEY ([fk_column])
REFERENCES [referenced_table](id)
ON DELETE [CASCADE/SET NULL/RESTRICT];
```

---

## Migration Scripts

### Complete Migration Script

```sql
-- ============================================
-- Database Migration: [OLD_VERSION] → [NEW_VERSION]
-- Date: [DATE]
-- ============================================

BEGIN;

-- Set constraints to deferred for this transaction
SET CONSTRAINTS ALL DEFERRED;

-- ============================================
-- Step 1: Pre-migration validation
-- ============================================

DO $$
BEGIN
    -- Check database version
    IF current_setting('server_version_num')::int < 120000 THEN
        RAISE EXCEPTION 'PostgreSQL 12+ required';
    END IF;

    -- Check for required extensions
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp') THEN
        CREATE EXTENSION "uuid-ossp";
    END IF;
END $$;

-- ============================================
-- Step 2: Backup critical data
-- ============================================

CREATE TABLE IF NOT EXISTS migration_backup_[NEW_VERSION] AS
SELECT * FROM [critical_table] WHERE 1=0;

INSERT INTO migration_backup_[NEW_VERSION]
SELECT * FROM [critical_table];

-- ============================================
-- Step 3: Schema changes
-- ============================================

-- Add new columns
ALTER TABLE [table_name]
ADD COLUMN [new_column] [type] [constraints];

-- Modify existing columns
ALTER TABLE [table_name]
ALTER COLUMN [column_name] TYPE [new_type] USING [column_name]::[new_type];

-- Drop old columns
ALTER TABLE [table_name]
DROP COLUMN IF EXISTS [old_column];

-- ============================================
-- Step 4: Data migrations
-- ============================================

-- Migrate data to new structure
UPDATE [table_name]
SET [new_column] = [transformation_expression]
WHERE [conditions];

-- ============================================
-- Step 5: Add constraints
-- ============================================

-- Add foreign keys
ALTER TABLE [table_name]
ADD CONSTRAINT [constraint_name]
FOREIGN KEY ([column]) REFERENCES [other_table](id);

-- Add indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS [index_name]
ON [table_name] ([column]);

-- Add NOT NULL constraints
ALTER TABLE [table_name]
ALTER COLUMN [column_name] SET NOT NULL;

-- ============================================
-- Step 6: Update schema version
-- ============================================

CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(50) PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO schema_migrations (version)
VALUES ('[NEW_VERSION]');

-- ============================================
-- Step 7: Validation
-- ============================================

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Verify data integrity
    SELECT COUNT(*) INTO v_count
    FROM [table_name]
    WHERE [validation_condition];

    IF v_count > 0 THEN
        RAISE EXCEPTION 'Data validation failed: % invalid records', v_count;
    END IF;

    RAISE NOTICE 'Migration validation passed';
END $$;

COMMIT;

-- ============================================
-- Post-migration tasks (run after commit)
-- ============================================

-- Analyze tables for query planner
ANALYZE [table_name];

-- Vacuum to reclaim space
VACUUM ANALYZE [table_name];
```

---

### Rollback Script

```sql
-- ============================================
-- Rollback Migration: [NEW_VERSION] → [OLD_VERSION]
-- ============================================

BEGIN;

-- Restore from backup
TRUNCATE [table_name];

INSERT INTO [table_name]
SELECT * FROM migration_backup_[NEW_VERSION];

-- Revert schema changes
ALTER TABLE [table_name]
ADD COLUMN [old_column] [old_type];

ALTER TABLE [table_name]
DROP COLUMN [new_column];

-- Remove migration record
DELETE FROM schema_migrations
WHERE version = '[NEW_VERSION]';

COMMIT;
```

---

## Zero-Downtime Migration

For production systems requiring zero downtime:

### Phase 1: Additive Changes (No Downtime)

```sql
-- Add new columns (nullable)
ALTER TABLE [table_name]
ADD COLUMN [new_column] [type];

-- Create new indexes (concurrently)
CREATE INDEX CONCURRENTLY [index_name]
ON [table_name] ([column]);

-- Add new tables
CREATE TABLE [new_table] (...);
```

### Phase 2: Dual-Write Period

Update application to write to both old and new structures:

```python
# Write to both old and new columns
def save_user(data):
    db.execute(
        "UPDATE users SET old_column = ?, new_column = ? WHERE id = ?",
        (data['value'], transform(data['value']), data['id'])
    )
```

### Phase 3: Backfill Data

```sql
-- Backfill in batches to avoid locks
DO $$
DECLARE
    batch_size INT := 1000;
    offset_val INT := 0;
    rows_updated INT;
BEGIN
    LOOP
        UPDATE [table_name]
        SET [new_column] = transform([old_column])
        WHERE id IN (
            SELECT id FROM [table_name]
            WHERE [new_column] IS NULL
            ORDER BY id
            LIMIT batch_size
        );

        GET DIAGNOSTICS rows_updated = ROW_COUNT;
        offset_val := offset_val + batch_size;

        RAISE NOTICE 'Backfilled % rows', offset_val;

        EXIT WHEN rows_updated = 0;

        -- Small delay between batches
        PERFORM pg_sleep(0.1);
    END LOOP;
END $$;
```

### Phase 4: Switch to New Structure

```python
# Update application to use new column only
def save_user(data):
    db.execute(
        "UPDATE users SET new_column = ? WHERE id = ?",
        (transform(data['value']), data['id'])
    )
```

### Phase 5: Cleanup (Short Downtime)

```sql
-- Drop old columns
ALTER TABLE [table_name]
DROP COLUMN [old_column];
```

---

## Monitoring & Verification

### During Migration

```sql
-- Monitor long-running queries
SELECT
    pid,
    now() - query_start AS duration,
    state,
    query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;

-- Check table bloat
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Post-Migration Validation

```sql
-- Verify record counts
SELECT
    '[table_name]' AS table_name,
    COUNT(*) AS record_count
FROM [table_name]
UNION ALL
SELECT
    'migration_backup' AS table_name,
    COUNT(*) AS record_count
FROM migration_backup_[NEW_VERSION];

-- Check for NULL values in NOT NULL columns
SELECT column_name, COUNT(*)
FROM information_schema.columns
WHERE table_name = '[table_name]'
  AND is_nullable = 'NO'
GROUP BY column_name;

-- Verify foreign key integrity
SELECT conname, conrelid::regclass, confrelid::regclass
FROM pg_constraint
WHERE contype = 'f'
  AND conrelid::regclass::text = '[table_name]';
```

---

## Troubleshooting

### Common Issues

#### Issue: Migration timeout

```sql
-- Increase statement timeout
SET statement_timeout = '1h';
```

#### Issue: Lock contention

```sql
-- Find blocking queries
SELECT
    blocked.pid AS blocked_pid,
    blocking.pid AS blocking_pid,
    blocked.query AS blocked_query,
    blocking.query AS blocking_query
FROM pg_stat_activity AS blocked
JOIN pg_stat_activity AS blocking
    ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));

-- Kill blocking query (use with caution!)
SELECT pg_terminate_backend([pid]);
```

#### Issue: Out of disk space

```bash
# Clean up old WAL files
pg_archivecleanup /var/lib/postgresql/archive $(pg_controldata | grep "Latest checkpoint's REDO WAL file" | awk '{print $5}')

# Vacuum to reclaim space
VACUUM FULL [table_name];
```

---

## Support

- **Database Admin:** [NAME/EMAIL]
- **On-Call:** [PHONE/PAGER]
- **Migration Logs:** [LOG_PATH]
- **Rollback Procedure:** [RUNBOOK_URL]

---

**Last Updated:** [TIMESTAMP]
**Migration Script Version:** [VERSION]

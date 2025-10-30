# Database Analysis - Detecting Databases and ORMs

This example demonstrates comprehensive database and ORM detection across multiple languages and frameworks.

## Scenario 1: Next.js + Supabase + Prisma

### Project Structure

```
nextjs-supabase-app/
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── supabase/
│   └── config.toml
├── .env
└── package.json
```

### Detection

```bash
bash scripts/detect-database.sh .
```

### Result

```json
{
  "project_path": ".",
  "databases": [
    {
      "name": "Supabase",
      "type": "database-service",
      "version": "^2.38.0",
      "evidence": "package.json"
    },
    {
      "name": "Supabase (Local Dev)",
      "type": "database-service",
      "version": "unknown",
      "evidence": "supabase/config.toml"
    },
    {
      "name": "Supabase",
      "type": "database-service",
      "version": "unknown",
      "evidence": ".env"
    },
    {
      "name": "Prisma",
      "type": "orm",
      "version": "^5.7.0",
      "evidence": "prisma/schema.prisma"
    },
    {
      "name": "PostgreSQL (node-postgres)",
      "type": "database",
      "version": "^8.11.0",
      "evidence": "package.json"
    }
  ],
  "count": 5,
  "timestamp": "2025-10-28T21:00:00Z"
}
```

### Analysis

```bash
# Get database type
cat .claude/project.json | jq '.databases[] | select(.type == "database")'

# Get ORM
cat .claude/project.json | jq '.databases[] | select(.type == "orm")'

# Get database services
cat .claude/project.json | jq '.databases[] | select(.type == "database-service")'
```

**Conclusion**: This is a **Supabase + Prisma** stack with PostgreSQL as the underlying database.

## Scenario 2: Python FastAPI + SQLAlchemy + PostgreSQL

### Project Structure

```
fastapi-app/
├── alembic/
│   └── versions/
├── alembic.ini
├── requirements.txt
└── .env
```

### Detection Result

```json
{
  "databases": [
    {
      "name": "PostgreSQL (psycopg2)",
      "type": "database",
      "version": "2.9.9",
      "evidence": "requirements.txt"
    },
    {
      "name": "SQLAlchemy",
      "type": "orm",
      "version": "2.0.23",
      "evidence": "requirements.txt"
    },
    {
      "name": "Alembic",
      "type": "migration-tool",
      "version": "1.12.0",
      "evidence": "requirements.txt"
    },
    {
      "name": "Redis (Python)",
      "type": "cache",
      "version": "5.0.1",
      "evidence": "requirements.txt"
    }
  ]
}
```

### Stack Summary

```bash
#!/bin/bash
# summarize-db-stack.sh

echo "=== Database Stack Summary ==="
echo ""

# Primary database
PRIMARY_DB=$(cat .claude/project.json | jq -r '.databases[] | select(.type == "database") | .name' | head -1)
echo "Primary Database: $PRIMARY_DB"

# ORM
ORM=$(cat .claude/project.json | jq -r '.databases[] | select(.type == "orm") | .name' | head -1)
echo "ORM: ${ORM:-None}"

# Cache
CACHE=$(cat .claude/project.json | jq -r '.databases[] | select(.type == "cache") | .name' | head -1)
echo "Cache: ${CACHE:-None}"

# Migration tool
MIGRATION=$(cat .claude/project.json | jq -r '.databases[] | select(.type == "migration-tool") | .name' | head -1)
echo "Migration Tool: ${MIGRATION:-None}"
```

## Scenario 3: Multi-Database Application

### Polyglot Persistence

```
multi-db-app/
├── package.json (MongoDB, Redis, PostgreSQL)
├── prisma/schema.prisma
└── .env
```

### Detection

```json
{
  "databases": [
    {
      "name": "PostgreSQL (node-postgres)",
      "type": "database",
      "version": "^8.11.0",
      "evidence": "package.json"
    },
    {
      "name": "MongoDB",
      "type": "database",
      "version": "^6.3.0",
      "evidence": "package.json"
    },
    {
      "name": "Mongoose (MongoDB ODM)",
      "type": "orm",
      "version": "^8.0.0",
      "evidence": "package.json"
    },
    {
      "name": "Redis",
      "type": "cache",
      "version": "unknown",
      "evidence": "package.json"
    },
    {
      "name": "Prisma",
      "type": "orm",
      "version": "^5.7.0",
      "evidence": "prisma/schema.prisma"
    }
  ]
}
```

### Use Case Analysis

```bash
#!/bin/bash
# analyze-db-usage.sh

echo "=== Database Usage Analysis ==="
echo ""

DB_COUNT=$(cat .claude/project.json | jq '[.databases[] | select(.type == "database")] | length')
echo "Number of databases: $DB_COUNT"

if [ $DB_COUNT -gt 1 ]; then
    echo ""
    echo "⚠ Multiple databases detected - Polyglot Persistence"
    echo ""
    echo "Databases in use:"
    cat .claude/project.json | jq -r '.databases[] | select(.type == "database") | "  - \(.name)"'
    echo ""
    echo "Typical use cases:"
    echo "  - PostgreSQL: Relational data, transactions"
    echo "  - MongoDB: Document storage, flexible schema"
    echo "  - Redis: Caching, sessions, real-time data"
fi
```

## Scenario 4: Go + GORM + PostgreSQL

### Detection

```bash
cd go-app
bash scripts/detect-database.sh .
```

### Result

```json
{
  "databases": [
    {
      "name": "PostgreSQL (lib/pq)",
      "type": "database",
      "version": "unknown",
      "evidence": "go.mod"
    },
    {
      "name": "GORM",
      "type": "orm",
      "version": "v1.25.5",
      "evidence": "go.mod"
    }
  ]
}
```

### Go Database Stack Check

```bash
#!/bin/bash
# check-go-db.sh

if [ ! -f "go.mod" ]; then
    echo "Not a Go project"
    exit 1
fi

echo "=== Go Database Stack ==="
echo ""

# Check for database drivers
echo "Database Drivers:"
grep -E "github.com/lib/pq|github.com/jackc/pgx|github.com/go-sql-driver/mysql" go.mod | sed 's/^/  /'

echo ""
echo "ORMs:"
grep -E "gorm.io/gorm" go.mod | sed 's/^/  /'

echo ""
echo "Migration Tools:"
grep -E "github.com/golang-migrate/migrate" go.mod | sed 's/^/  /'
```

## Scenario 5: Rust + Diesel + PostgreSQL

### Detection

```json
{
  "databases": [
    {
      "name": "Diesel",
      "type": "orm",
      "version": "unknown",
      "evidence": "Cargo.toml"
    },
    {
      "name": "Diesel",
      "type": "orm",
      "version": "unknown",
      "evidence": "diesel.toml"
    }
  ]
}
```

### Rust Database Check

```bash
#!/bin/bash
# check-rust-db.sh

if [ ! -f "Cargo.toml" ]; then
    echo "Not a Rust project"
    exit 1
fi

echo "=== Rust Database Stack ==="
echo ""

echo "ORMs:"
grep -E "diesel|sqlx|sea-orm" Cargo.toml | sed 's/^/  /'

echo ""
echo "Database Drivers:"
grep -E "tokio-postgres|mysql_async|mongodb" Cargo.toml | sed 's/^/  /'
```

## Scenario 6: Database Migration Detection

### Check Migration Status

```bash
#!/bin/bash
# check-migrations.sh

echo "=== Migration Detection ==="
echo ""

# Prisma migrations
if [ -d "prisma/migrations" ]; then
    MIGRATION_COUNT=$(find prisma/migrations -type d -mindepth 1 | wc -l)
    echo "✓ Prisma migrations: $MIGRATION_COUNT"
fi

# Alembic migrations
if [ -d "alembic/versions" ]; then
    MIGRATION_COUNT=$(find alembic/versions -name "*.py" | wc -l)
    echo "✓ Alembic migrations: $MIGRATION_COUNT"
fi

# Sequelize migrations
if [ -d "migrations" ]; then
    MIGRATION_COUNT=$(find migrations -name "*.js" | wc -l)
    echo "✓ Sequelize migrations: $MIGRATION_COUNT"
fi

# Django migrations
if find . -path "*/migrations/*.py" -not -name "__init__.py" 2>/dev/null | grep -q .; then
    MIGRATION_COUNT=$(find . -path "*/migrations/*.py" -not -name "__init__.py" | wc -l)
    echo "✓ Django migrations: $MIGRATION_COUNT"
fi

# TypeORM migrations
if [ -d "src/migration" ]; then
    MIGRATION_COUNT=$(find src/migration -name "*.ts" | wc -l)
    echo "✓ TypeORM migrations: $MIGRATION_COUNT"
fi

# Diesel migrations
if [ -d "migrations" ] && [ -f "diesel.toml" ]; then
    MIGRATION_COUNT=$(find migrations -name "up.sql" | wc -l)
    echo "✓ Diesel migrations: $MIGRATION_COUNT"
fi
```

## Scenario 7: Database Configuration Analysis

### Extract Connection Strings

```bash
#!/bin/bash
# extract-db-config.sh

echo "=== Database Configuration ==="
echo ""

if [ ! -f ".env" ]; then
    echo "⚠ No .env file found"
    exit 1
fi

# PostgreSQL
if grep -q "DATABASE_URL\|POSTGRES_URL\|PG_CONNECTION" .env; then
    echo "✓ PostgreSQL configured"
    DB_URL=$(grep "DATABASE_URL" .env | cut -d'=' -f2 | sed 's/postgresql:\/\/[^@]*@/postgresql:\/\/***:***@/')
    echo "  Connection: $DB_URL"
fi

# MongoDB
if grep -q "MONGODB_URI\|MONGO_URL" .env; then
    echo "✓ MongoDB configured"
fi

# Redis
if grep -q "REDIS_URL\|REDIS_HOST" .env; then
    echo "✓ Redis configured"
fi

# Supabase
if grep -q "SUPABASE_URL" .env; then
    echo "✓ Supabase configured"
    SUPABASE_URL=$(grep "SUPABASE_URL" .env | cut -d'=' -f2)
    echo "  URL: $SUPABASE_URL"
fi

echo ""
echo "⚠ Never commit .env files with credentials!"
```

## Scenario 8: ORM Feature Detection

### Check ORM Capabilities

```bash
#!/bin/bash
# check-orm-features.sh

ORM=$(cat .claude/project.json | jq -r '.databases[] | select(.type == "orm") | .name' | head -1)

echo "=== ORM: $ORM ==="
echo ""

case "$ORM" in
    "Prisma")
        echo "Features:"
        echo "  ✓ Type-safe queries"
        echo "  ✓ Auto-generated migrations"
        echo "  ✓ Database introspection"
        echo "  ✓ Multiple database support"
        echo ""
        echo "Check schema:"
        echo "  cat prisma/schema.prisma"
        ;;
    "TypeORM")
        echo "Features:"
        echo "  ✓ Entity decorators"
        echo "  ✓ Query builder"
        echo "  ✓ Migration generation"
        echo "  ✓ Active Record / Data Mapper"
        ;;
    "SQLAlchemy")
        echo "Features:"
        echo "  ✓ ORM and Core"
        echo "  ✓ Multiple dialects"
        echo "  ✓ Connection pooling"
        echo "  ✓ Declarative base"
        ;;
    "GORM")
        echo "Features:"
        echo "  ✓ Auto migrations"
        echo "  ✓ Associations"
        echo "  ✓ Hooks"
        echo "  ✓ Preloading"
        ;;
    "Diesel")
        echo "Features:"
        echo "  ✓ Compile-time safety"
        echo "  ✓ Composable queries"
        echo "  ✓ Migration system"
        echo "  ✓ Type-safe SQL"
        ;;
esac
```

## Database Health Check

### Comprehensive Database Audit

```bash
#!/bin/bash
# db-health-check.sh

echo "=== Database Health Check ==="
echo ""

# Detection
bash scripts/detect-database.sh . > /tmp/db-detection.json 2>/dev/null

# Summary
DB_COUNT=$(jq '.count' /tmp/db-detection.json)
echo "Total database components: $DB_COUNT"

echo ""
echo "=== Components ==="

# Databases
echo ""
echo "Databases:"
jq -r '.databases[] | select(.type == "database") | "  - \(.name) v\(.version)"' /tmp/db-detection.json

# ORMs
echo ""
echo "ORMs:"
jq -r '.databases[] | select(.type == "orm") | "  - \(.name) v\(.version)"' /tmp/db-detection.json

# Caches
echo ""
echo "Caches:"
jq -r '.databases[] | select(.type == "cache") | "  - \(.name)"' /tmp/db-detection.json

echo ""
echo "=== Recommendations ==="

# Check for ORM
HAS_ORM=$(jq '[.databases[] | select(.type == "orm")] | length > 0' /tmp/db-detection.json)
if [ "$HAS_ORM" == "false" ]; then
    echo "⚠ No ORM detected - consider adding Prisma or TypeORM"
fi

# Check for cache
HAS_CACHE=$(jq '[.databases[] | select(.type == "cache")] | length > 0' /tmp/db-detection.json)
if [ "$HAS_CACHE" == "false" ]; then
    echo "⚠ No cache detected - consider adding Redis for performance"
fi

# Check for migrations
if [ ! -d "prisma/migrations" ] && [ ! -d "alembic/versions" ] && [ ! -d "migrations" ]; then
    echo "⚠ No migration system detected - implement database versioning"
fi

echo ""
echo "=== Security Check ==="

# Check for exposed credentials
if [ -f ".env" ]; then
    if git ls-files --error-unmatch .env 2>/dev/null; then
        echo "⚠ CRITICAL: .env file is tracked in git!"
        echo "  Run: git rm --cached .env"
        echo "  Add to .gitignore"
    else
        echo "✓ .env not tracked in git"
    fi
fi
```

## Best Practices

1. **Connection Pooling**: Ensure connection pooling is configured
2. **Migration Strategy**: Use migration tools for schema changes
3. **Environment Variables**: Store credentials in .env (not in git)
4. **ORM Selection**: Choose ORM based on project needs
5. **Caching Layer**: Add Redis for frequently accessed data
6. **Backup Strategy**: Document backup procedures

## Common Database Patterns

### Pattern 1: Simple CRUD
- Single database (PostgreSQL/MongoDB)
- ORM (Prisma/Mongoose)
- Migration tool

### Pattern 2: High Performance
- Primary database (PostgreSQL)
- Cache layer (Redis)
- Connection pooling
- Read replicas

### Pattern 3: Polyglot Persistence
- PostgreSQL (relational data)
- MongoDB (documents)
- Redis (cache)
- Different ORMs for each

### Pattern 4: Serverless
- Serverless database (Supabase/PlanetScale)
- Edge-compatible ORM (Prisma/Drizzle)
- Connection pooling (PgBouncer)

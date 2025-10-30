#!/bin/bash
# detect-database.sh - Database and ORM detection
# Usage: ./detect-database.sh <project-path>

set -euo pipefail

PROJECT_PATH="${1:-.}"
RESULTS=()

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper function
add_detection() {
    local name="$1"
    local type="$2"
    local version="$3"
    local evidence="$4"

    RESULTS+=("{\"name\":\"$name\",\"type\":\"$type\",\"version\":\"$version\",\"evidence\":\"$evidence\"}")
}

# Detect Supabase
detect_supabase() {
    # JavaScript/TypeScript
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"@supabase/supabase-js"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"@supabase/supabase-js"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Supabase" "database-service" "$version" "package.json"
        fi
    fi

    # Python
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "supabase" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "supabase" "$PROJECT_PATH/requirements.txt" | sed 's/supabase==\(.*\)/\1/' || echo "unknown")
            add_detection "Supabase (Python)" "database-service" "$version" "requirements.txt"
        fi
    fi

    # Check for Supabase config
    if [[ -f "$PROJECT_PATH/supabase/config.toml" ]]; then
        add_detection "Supabase (Local Dev)" "database-service" "unknown" "supabase/config.toml"
    fi

    # Check for .env
    if [[ -f "$PROJECT_PATH/.env" ]] && grep -q "SUPABASE_URL" "$PROJECT_PATH/.env"; then
        add_detection "Supabase" "database-service" "unknown" ".env"
    fi
}

# Detect PostgreSQL
detect_postgresql() {
    # Node.js - pg library
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"pg"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"pg"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "PostgreSQL (node-postgres)" "database" "$version" "package.json"
        fi
    fi

    # Python - psycopg2
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "psycopg2" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "psycopg2" "$PROJECT_PATH/requirements.txt" | sed 's/psycopg2.*==\(.*\)/\1/' || echo "unknown")
            add_detection "PostgreSQL (psycopg2)" "database" "$version" "requirements.txt"
        fi
    fi

    # Go
    if [[ -f "$PROJECT_PATH/go.mod" ]] && grep -q "github.com/lib/pq" "$PROJECT_PATH/go.mod"; then
        add_detection "PostgreSQL (lib/pq)" "database" "unknown" "go.mod"
    fi
}

# Detect MongoDB
detect_mongodb() {
    # Node.js
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"mongodb"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"mongodb"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "MongoDB" "database" "$version" "package.json"
        fi

        if grep -q '"mongoose"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"mongoose"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Mongoose (MongoDB ODM)" "orm" "$version" "package.json"
        fi
    fi

    # Python
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "pymongo" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "pymongo" "$PROJECT_PATH/requirements.txt" | sed 's/pymongo==\(.*\)/\1/' || echo "unknown")
            add_detection "MongoDB (PyMongo)" "database" "$version" "requirements.txt"
        fi
    fi
}

# Detect Redis
detect_redis() {
    # Node.js
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"redis"' "$PROJECT_PATH/package.json" || grep -q '"ioredis"' "$PROJECT_PATH/package.json"; then
            add_detection "Redis" "cache" "unknown" "package.json"
        fi
    fi

    # Python
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "redis" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "^redis" "$PROJECT_PATH/requirements.txt" | sed 's/redis==\(.*\)/\1/' || echo "unknown")
            add_detection "Redis (Python)" "cache" "$version" "requirements.txt"
        fi
    fi

    # Go
    if [[ -f "$PROJECT_PATH/go.mod" ]] && grep -q "github.com/redis/go-redis" "$PROJECT_PATH/go.mod"; then
        add_detection "Redis (go-redis)" "cache" "unknown" "go.mod"
    fi
}

# Detect MySQL/MariaDB
detect_mysql() {
    # Node.js
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"mysql2"' "$PROJECT_PATH/package.json" || grep -q '"mysql"' "$PROJECT_PATH/package.json"; then
            add_detection "MySQL" "database" "unknown" "package.json"
        fi
    fi

    # Python
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "pymysql\|mysqlclient" "$PROJECT_PATH/requirements.txt"; then
            add_detection "MySQL (Python)" "database" "unknown" "requirements.txt"
        fi
    fi
}

# Detect SQLite
detect_sqlite() {
    # Check for .db or .sqlite files
    if find "$PROJECT_PATH" -maxdepth 2 -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" 2>/dev/null | head -1 | grep -q .; then
        add_detection "SQLite" "database" "unknown" "database files"
    fi

    # Python - sqlite3 is built-in but check for usage
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "sqlite" "$PROJECT_PATH/requirements.txt"; then
            add_detection "SQLite (Python)" "database" "unknown" "requirements.txt"
        fi
    fi
}

# Detect Prisma ORM
detect_prisma() {
    if [[ -f "$PROJECT_PATH/prisma/schema.prisma" ]]; then
        local version="unknown"
        if [[ -f "$PROJECT_PATH/package.json" ]]; then
            version=$(grep -o '"@prisma/client"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
        fi
        add_detection "Prisma" "orm" "$version" "prisma/schema.prisma"
    fi
}

# Detect TypeORM
detect_typeorm() {
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"typeorm"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"typeorm"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "TypeORM" "orm" "$version" "package.json"
        fi
    fi

    if [[ -f "$PROJECT_PATH/ormconfig.json" ]] || [[ -f "$PROJECT_PATH/ormconfig.js" ]]; then
        add_detection "TypeORM" "orm" "unknown" "ormconfig"
    fi
}

# Detect Sequelize
detect_sequelize() {
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"sequelize"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"sequelize"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Sequelize" "orm" "$version" "package.json"
        fi
    fi

    if [[ -f "$PROJECT_PATH/.sequelizerc" ]]; then
        add_detection "Sequelize" "orm" "unknown" ".sequelizerc"
    fi
}

# Detect SQLAlchemy
detect_sqlalchemy() {
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "sqlalchemy" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "sqlalchemy" "$PROJECT_PATH/requirements.txt" | head -1 | sed 's/[sS][qQ][lL][aA]lchemy==\(.*\)/\1/' || echo "unknown")
            add_detection "SQLAlchemy" "orm" "$version" "requirements.txt"
        fi
    fi
}

# Detect Django ORM
detect_django_orm() {
    if [[ -f "$PROJECT_PATH/manage.py" ]]; then
        # Django ORM is built-in
        add_detection "Django ORM" "orm" "unknown" "manage.py"
    fi
}

# Detect GORM (Go)
detect_gorm() {
    if [[ -f "$PROJECT_PATH/go.mod" ]] && grep -q "gorm.io/gorm" "$PROJECT_PATH/go.mod"; then
        local version=$(grep "gorm.io/gorm" "$PROJECT_PATH/go.mod" | awk '{print $2}' || echo "unknown")
        add_detection "GORM" "orm" "$version" "go.mod"
    fi
}

# Detect Diesel (Rust)
detect_diesel() {
    if [[ -f "$PROJECT_PATH/Cargo.toml" ]] && grep -q "diesel" "$PROJECT_PATH/Cargo.toml"; then
        add_detection "Diesel" "orm" "unknown" "Cargo.toml"
    fi

    if [[ -f "$PROJECT_PATH/diesel.toml" ]]; then
        add_detection "Diesel" "orm" "unknown" "diesel.toml"
    fi
}

# Detect Drizzle ORM
detect_drizzle() {
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"drizzle-orm"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"drizzle-orm"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Drizzle ORM" "orm" "$version" "package.json"
        fi
    fi

    if [[ -f "$PROJECT_PATH/drizzle.config.ts" ]] || [[ -f "$PROJECT_PATH/drizzle.config.js" ]]; then
        add_detection "Drizzle ORM" "orm" "unknown" "drizzle.config"
    fi
}

# Main detection
echo -e "${GREEN}Starting database detection...${NC}" >&2
echo -e "${YELLOW}Scanning: $PROJECT_PATH${NC}" >&2

# Run all detectors
detect_supabase
detect_postgresql
detect_mongodb
detect_redis
detect_mysql
detect_sqlite
detect_prisma
detect_typeorm
detect_sequelize
detect_sqlalchemy
detect_django_orm
detect_gorm
detect_diesel
detect_drizzle

# Output JSON
echo "{"
echo "  \"project_path\": \"$PROJECT_PATH\","
echo "  \"databases\": ["

# Print results
first=true
for result in "${RESULTS[@]}"; do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    echo "    $result"
done

echo ""
echo "  ],"
echo "  \"count\": ${#RESULTS[@]},"
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

echo -e "${GREEN}Detection complete! Found ${#RESULTS[@]} database components.${NC}" >&2

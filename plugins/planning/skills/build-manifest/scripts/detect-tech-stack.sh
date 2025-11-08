#!/usr/bin/env bash
# Detect tech stack from architecture documentation

set -e

ARCH_DIR="${1:-docs/architecture}"

if [ ! -d "$ARCH_DIR" ]; then
    echo "❌ Architecture directory not found: $ARCH_DIR"
    exit 1
fi

echo "🔍 Detecting tech stack from: $ARCH_DIR"
echo ""

# Search for technology keywords
declare -A TECH_PATTERNS=(
    ["Next.js"]="nextjs-frontend"
    ["FastAPI"]="fastapi-backend"
    ["Supabase"]="supabase"
    ["Vercel AI SDK"]="vercel-ai-sdk"
    ["OpenRouter"]="openrouter"
    ["Mem0"]="mem0"
    ["Redis"]="redis"
    ["PostgreSQL"]="postgresql"
)

DETECTED=()

for tech in "${!TECH_PATTERNS[@]}"; do
    if grep -r -q "$tech" "$ARCH_DIR" 2>/dev/null; then
        DETECTED+=("${TECH_PATTERNS[$tech]}")
        echo "   ✓ Detected: $tech"
    fi
done

echo ""
echo "📊 Detected ${#DETECTED[@]} technologies"
echo ""

# Output as JSON array
echo "["
for ((i=0; i<${#DETECTED[@]}; i++)); do
    if [ $i -eq $((${#DETECTED[@]}-1)) ]; then
        echo "  \"${DETECTED[$i]}\""
    else
        echo "  \"${DETECTED[$i]}\","
    fi
done
echo "]"

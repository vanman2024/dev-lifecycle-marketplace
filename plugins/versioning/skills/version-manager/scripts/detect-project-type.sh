#!/bin/bash
# Detect project type (Python, TypeScript, JavaScript)

set -e

PROJECT_DIR="${1:-.}"
OUTPUT_FILE="${2:-/dev/stdout}"

cd "$PROJECT_DIR"

# Initialize detection variables
PROJECT_TYPE=""
MANIFEST_FILE=""
HAS_TYPESCRIPT=false

# Check for Python indicators
if [ -f "pyproject.toml" ]; then
    PROJECT_TYPE="python"
    MANIFEST_FILE="pyproject.toml"
elif [ -f "setup.py" ]; then
    PROJECT_TYPE="python"
    MANIFEST_FILE="setup.py"
elif [ -f "requirements.txt" ] && [ ! -f "package.json" ]; then
    PROJECT_TYPE="python"
    MANIFEST_FILE="requirements.txt"
# Check for TypeScript/JavaScript indicators
elif [ -f "package.json" ]; then
    if [ -f "tsconfig.json" ] || grep -q "\"typescript\"" package.json 2>/dev/null; then
        PROJECT_TYPE="typescript"
        HAS_TYPESCRIPT=true
    else
        PROJECT_TYPE="javascript"
    fi
    MANIFEST_FILE="package.json"
fi

# Output JSON result
if [ -z "$PROJECT_TYPE" ]; then
    echo "{ \"error\": \"Could not detect project type\" }" > "$OUTPUT_FILE"
    exit 1
fi

cat > "$OUTPUT_FILE" << EOF
{
  "project_type": "$PROJECT_TYPE",
  "manifest_file": "$MANIFEST_FILE",
  "has_typescript": $HAS_TYPESCRIPT
}
EOF

echo "Detected project type: $PROJECT_TYPE" >&2

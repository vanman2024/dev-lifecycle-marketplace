#!/usr/bin/env bash
# detect-test-frameworks.sh - Main orchestrator for test framework detection
# Usage: bash detect-test-frameworks.sh [project-path]
# Runs all language-specific detectors and aggregates results

set -euo pipefail

PROJECT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULT_FILE="${PROJECT_DIR}/.claude/test-detection-result.json"

echo "=== Test Framework Detection ==="
echo "Project: $(cd "$PROJECT_DIR" && pwd)"
echo ""

# Initialize result
mkdir -p "$(dirname "$RESULT_FILE")"
cat > "$RESULT_FILE" <<'EOF'
{
  "unit": { "framework": null, "config": null, "command": null },
  "api_contract": { "framework": null, "collections": [], "auth_strategy": "none" },
  "e2e": { "framework": null, "config": null },
  "smoke": { "health_endpoint": null, "critical_paths": [] },
  "coverage": { "tool": null, "threshold": 80 },
  "ci_workflows": [],
  "ai_detected": false,
  "llm_evals_plugin": "llm-evals"
}
EOF

# Detect project language(s)
LANGUAGES=()

if [ -f "$PROJECT_DIR/package.json" ]; then
  LANGUAGES+=("node")
  echo "[+] Detected: Node.js project (package.json)"
fi

if [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/setup.py" ] || [ -f "$PROJECT_DIR/Pipfile" ]; then
  LANGUAGES+=("python")
  echo "[+] Detected: Python project"
fi

if [ -f "$PROJECT_DIR/go.mod" ]; then
  LANGUAGES+=("go")
  echo "[+] Detected: Go project (go.mod)"
fi

if [ -f "$PROJECT_DIR/Cargo.toml" ]; then
  LANGUAGES+=("rust")
  echo "[+] Detected: Rust project (Cargo.toml)"
fi

if [ ${#LANGUAGES[@]} -eq 0 ]; then
  echo "[!] No recognized project files found"
  exit 0
fi

echo ""

# Run language-specific detectors
for lang in "${LANGUAGES[@]}"; do
  detector="$SCRIPT_DIR/detect-${lang}-testing.sh"
  if [ -f "$detector" ]; then
    echo "--- Running $lang detector ---"
    bash "$detector" "$PROJECT_DIR" "$RESULT_FILE"
    echo ""
  fi
done

# Run CI detector
if [ -f "$SCRIPT_DIR/detect-ci-workflows.sh" ]; then
  echo "--- Running CI workflow detector ---"
  bash "$SCRIPT_DIR/detect-ci-workflows.sh" "$PROJECT_DIR" "$RESULT_FILE"
  echo ""
fi

# Check for AI frameworks
AI_DETECTED=false
if [ -f "$PROJECT_DIR/package.json" ]; then
  if grep -qE '"@ai-sdk/|"langchain|"openai"|"@anthropic-ai/sdk"|"@google/generative-ai"' "$PROJECT_DIR/package.json" 2>/dev/null; then
    AI_DETECTED=true
    echo "[+] AI framework detected in package.json"
  fi
fi
if [ -f "$PROJECT_DIR/requirements.txt" ]; then
  if grep -qiE 'langchain|openai|anthropic|transformers' "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
    AI_DETECTED=true
    echo "[+] AI framework detected in requirements.txt"
  fi
fi
if [ -f "$PROJECT_DIR/pyproject.toml" ]; then
  if grep -qiE 'langchain|openai|anthropic|transformers' "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
    AI_DETECTED=true
    echo "[+] AI framework detected in pyproject.toml"
  fi
fi

# Update ai_detected in result
if command -v jq &>/dev/null; then
  tmp=$(mktemp)
  jq --argjson ai "$AI_DETECTED" '.ai_detected = $ai' "$RESULT_FILE" > "$tmp" && mv "$tmp" "$RESULT_FILE"
fi

# Check for Newman/Postman collections
COLLECTIONS=$(find "$PROJECT_DIR" -maxdepth 3 -name "*.postman_collection.json" 2>/dev/null || true)
if [ -n "$COLLECTIONS" ]; then
  echo "[+] Found Postman collections:"
  echo "$COLLECTIONS" | while read -r c; do echo "    $c"; done
  if command -v jq &>/dev/null; then
    COLL_JSON=$(echo "$COLLECTIONS" | jq -R -s 'split("\n") | map(select(. != ""))')
    tmp=$(mktemp)
    jq --argjson colls "$COLL_JSON" '.api_contract.framework = "newman" | .api_contract.collections = $colls' "$RESULT_FILE" > "$tmp" && mv "$tmp" "$RESULT_FILE"
  fi
fi

# Check for health endpoint (smoke testing)
if [ -f "$PROJECT_DIR/package.json" ]; then
  if grep -rql "health" "$PROJECT_DIR/src/app/api/" "$PROJECT_DIR/pages/api/" "$PROJECT_DIR/app/api/" 2>/dev/null; then
    echo "[+] Health endpoint detected"
    if command -v jq &>/dev/null; then
      tmp=$(mktemp)
      jq '.smoke.health_endpoint = "/api/health"' "$RESULT_FILE" > "$tmp" && mv "$tmp" "$RESULT_FILE"
    fi
  fi
fi

echo ""
echo "=== Detection Complete ==="
echo "Results saved to: $RESULT_FILE"

if command -v jq &>/dev/null; then
  echo ""
  jq '.' "$RESULT_FILE"
fi

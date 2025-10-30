#!/bin/bash
# detect-ai-stack.sh - AI/ML stack component identification
# Usage: ./detect-ai-stack.sh <project-path>

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

# Detect Vercel AI SDK
detect_vercel_ai_sdk() {
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"ai"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"ai"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Vercel AI SDK" "sdk" "$version" "package.json"
        fi

        # Check for specific packages
        if grep -q '"@ai-sdk/' "$PROJECT_PATH/package.json"; then
            add_detection "Vercel AI SDK (scoped packages)" "sdk" "unknown" "package.json"
        fi
    fi
}

# Detect Claude SDKs
detect_claude_sdks() {
    # Claude Agent SDK
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"@anthropic-ai/agent-sdk"' "$PROJECT_PATH/package.json" || grep -q '"claude-agent-sdk"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"@anthropic-ai/agent-sdk"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "Claude Agent SDK" "sdk" "$version" "package.json"
        fi
    fi

    # Claude SDK (Python)
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "anthropic" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "anthropic" "$PROJECT_PATH/requirements.txt" | sed 's/anthropic==\(.*\)/\1/' || echo "unknown")
            add_detection "Anthropic SDK (Python)" "sdk" "$version" "requirements.txt"
        fi
    fi

    # Check TypeScript files for Claude SDK usage
    if find "$PROJECT_PATH" -name "*.ts" -o -name "*.tsx" 2>/dev/null | head -1 | xargs grep -l "from '@anthropic-ai/sdk'" 2>/dev/null | head -1; then
        add_detection "Anthropic SDK (TypeScript)" "sdk" "unknown" "source files"
    fi
}

# Detect OpenAI SDK
detect_openai() {
    # Node.js
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"openai"' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"openai"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "OpenAI SDK" "sdk" "$version" "package.json"
        fi
    fi

    # Python
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "openai" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "^openai" "$PROJECT_PATH/requirements.txt" | sed 's/openai==\(.*\)/\1/' || echo "unknown")
            add_detection "OpenAI SDK (Python)" "sdk" "$version" "requirements.txt"
        fi
    fi
}

# Detect LangChain
detect_langchain() {
    # Python
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "langchain" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "langchain" "$PROJECT_PATH/requirements.txt" | head -1 | sed 's/langchain==\(.*\)/\1/' || echo "unknown")
            add_detection "LangChain (Python)" "framework" "$version" "requirements.txt"
        fi
    fi

    # JavaScript/TypeScript
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"langchain"' "$PROJECT_PATH/package.json" || grep -q '"@langchain/' "$PROJECT_PATH/package.json"; then
            local version=$(grep -o '"langchain"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_PATH/package.json" | sed 's/.*"\([^"]*\)".*/\1/' || echo "unknown")
            add_detection "LangChain (JS)" "framework" "$version" "package.json"
        fi
    fi
}

# Detect Mem0
detect_mem0() {
    # Python
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "mem0" "$PROJECT_PATH/requirements.txt" || grep -qi "mem0ai" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "mem0" "$PROJECT_PATH/requirements.txt" | head -1 | sed 's/mem0.*==\(.*\)/\1/' || echo "unknown")
            add_detection "Mem0" "memory" "$version" "requirements.txt"
        fi
    fi

    # Check for Mem0 config
    if [[ -f "$PROJECT_PATH/mem0-config.yaml" ]] || [[ -f "$PROJECT_PATH/.mem0/config.yaml" ]]; then
        add_detection "Mem0" "memory" "unknown" "config file"
    fi
}

# Detect vector databases
detect_vector_dbs() {
    # Pinecone
    if [[ -f "$PROJECT_PATH/package.json" ]] && grep -q '"@pinecone-database/' "$PROJECT_PATH/package.json"; then
        add_detection "Pinecone" "vector-db" "unknown" "package.json"
    fi

    if [[ -f "$PROJECT_PATH/requirements.txt" ]] && grep -qi "pinecone" "$PROJECT_PATH/requirements.txt"; then
        add_detection "Pinecone (Python)" "vector-db" "unknown" "requirements.txt"
    fi

    # Weaviate
    if [[ -f "$PROJECT_PATH/requirements.txt" ]] && grep -qi "weaviate" "$PROJECT_PATH/requirements.txt"; then
        add_detection "Weaviate" "vector-db" "unknown" "requirements.txt"
    fi

    # Chroma
    if [[ -f "$PROJECT_PATH/requirements.txt" ]] && grep -qi "chromadb" "$PROJECT_PATH/requirements.txt"; then
        add_detection "ChromaDB" "vector-db" "unknown" "requirements.txt"
    fi

    # Qdrant
    if [[ -f "$PROJECT_PATH/requirements.txt" ]] && grep -qi "qdrant" "$PROJECT_PATH/requirements.txt"; then
        add_detection "Qdrant" "vector-db" "unknown" "requirements.txt"
    fi

    # pgvector (check for Supabase or direct usage)
    if [[ -f "$PROJECT_PATH/package.json" ]] && grep -q '"pgvector"' "$PROJECT_PATH/package.json"; then
        add_detection "pgvector" "vector-db" "unknown" "package.json"
    fi
}

# Detect LlamaIndex
detect_llamaindex() {
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "llama-index" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "llama-index" "$PROJECT_PATH/requirements.txt" | head -1 | sed 's/llama-index==\(.*\)/\1/' || echo "unknown")
            add_detection "LlamaIndex" "framework" "$version" "requirements.txt"
        fi
    fi
}

# Detect Hugging Face
detect_huggingface() {
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "transformers" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "transformers" "$PROJECT_PATH/requirements.txt" | sed 's/transformers==\(.*\)/\1/' || echo "unknown")
            add_detection "Hugging Face Transformers" "ml-library" "$version" "requirements.txt"
        fi
    fi
}

# Detect TensorFlow
detect_tensorflow() {
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "tensorflow" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "tensorflow" "$PROJECT_PATH/requirements.txt" | head -1 | sed 's/tensorflow==\(.*\)/\1/' || echo "unknown")
            add_detection "TensorFlow" "ml-library" "$version" "requirements.txt"
        fi
    fi
}

# Detect PyTorch
detect_pytorch() {
    if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
        if grep -qi "torch" "$PROJECT_PATH/requirements.txt"; then
            local version=$(grep -i "^torch" "$PROJECT_PATH/requirements.txt" | sed 's/torch==\(.*\)/\1/' || echo "unknown")
            add_detection "PyTorch" "ml-library" "$version" "requirements.txt"
        fi
    fi
}

# Detect embedding providers
detect_embeddings() {
    # Check for environment variables or config files
    if [[ -f "$PROJECT_PATH/.env" ]]; then
        if grep -q "OPENAI_API_KEY" "$PROJECT_PATH/.env"; then
            add_detection "OpenAI Embeddings" "embeddings" "unknown" ".env"
        fi

        if grep -q "COHERE_API_KEY" "$PROJECT_PATH/.env"; then
            add_detection "Cohere Embeddings" "embeddings" "unknown" ".env"
        fi
    fi
}

# Main detection
echo -e "${GREEN}Starting AI stack detection...${NC}" >&2
echo -e "${YELLOW}Scanning: $PROJECT_PATH${NC}" >&2

# Run all detectors
detect_vercel_ai_sdk
detect_claude_sdks
detect_openai
detect_langchain
detect_mem0
detect_vector_dbs
detect_llamaindex
detect_huggingface
detect_tensorflow
detect_pytorch
detect_embeddings

# Output JSON
echo "{"
echo "  \"project_path\": \"$PROJECT_PATH\","
echo "  \"ai_stack\": ["

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

echo -e "${GREEN}Detection complete! Found ${#RESULTS[@]} AI stack components.${NC}" >&2

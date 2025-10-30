# AI Stack Discovery - Detecting AI/ML Components

This example focuses on comprehensive AI stack detection including SDKs, vector databases, embeddings, and RAG systems.

## Scenario 1: Vercel AI SDK Project

### Detection

```bash
cd /path/to/ai-project
bash scripts/detect-ai-stack.sh .
```

### Example Output

```json
{
  "project_path": "/path/to/ai-project",
  "ai_stack": [
    {
      "name": "Vercel AI SDK",
      "type": "sdk",
      "version": "^3.0.0",
      "evidence": "package.json"
    },
    {
      "name": "OpenAI SDK",
      "type": "sdk",
      "version": "^4.20.0",
      "evidence": "package.json"
    },
    {
      "name": "Anthropic SDK (TypeScript)",
      "type": "sdk",
      "version": "unknown",
      "evidence": "source files"
    }
  ],
  "count": 3,
  "timestamp": "2025-10-28T21:00:00Z"
}
```

### Analysis

This project uses:
- **Vercel AI SDK** for unified LLM interface
- **OpenAI SDK** for GPT models
- **Anthropic SDK** for Claude models

## Scenario 2: RAG System Detection

### Project Structure

```
rag-app/
├── embeddings/
│   └── generate.py
├── vectorstore/
│   └── pinecone-setup.js
├── retrieval/
│   └── search.ts
└── requirements.txt
```

### Detection Command

```bash
bash scripts/detect-ai-stack.sh .
```

### Expected Detection

```json
{
  "ai_stack": [
    {
      "name": "LangChain (Python)",
      "type": "framework",
      "version": "0.1.0",
      "evidence": "requirements.txt"
    },
    {
      "name": "OpenAI SDK (Python)",
      "type": "sdk",
      "version": "1.3.0",
      "evidence": "requirements.txt"
    },
    {
      "name": "Pinecone",
      "type": "vector-db",
      "version": "unknown",
      "evidence": "requirements.txt"
    },
    {
      "name": "OpenAI Embeddings",
      "type": "embeddings",
      "version": "unknown",
      "evidence": ".env"
    }
  ]
}
```

### RAG Stack Indicators

The detection script identifies RAG systems by finding:
1. **Embedding providers** (OpenAI, Cohere, etc.)
2. **Vector databases** (Pinecone, Weaviate, ChromaDB)
3. **Chunking libraries** (LangChain, LlamaIndex)
4. **Retrieval patterns** in code

## Scenario 3: Multi-Model AI Application

### Detection Result

```json
{
  "ai_stack": [
    {
      "name": "OpenAI SDK",
      "type": "sdk",
      "version": "4.20.0",
      "evidence": "package.json"
    },
    {
      "name": "Anthropic SDK (TypeScript)",
      "type": "sdk",
      "version": "unknown",
      "evidence": "source files"
    },
    {
      "name": "Hugging Face Transformers",
      "type": "ml-library",
      "version": "4.35.0",
      "evidence": "requirements.txt"
    },
    {
      "name": "PyTorch",
      "type": "ml-library",
      "version": "2.1.0",
      "evidence": "requirements.txt"
    }
  ]
}
```

### Analysis Commands

```bash
# Count AI SDKs
cat .claude/project.json | jq '[.ai_stack[] | select(.type == "sdk")] | length'

# List all model providers
cat .claude/project.json | jq -r '.ai_stack[] | select(.type == "sdk") | .name'

# Check for ML frameworks
cat .claude/project.json | jq -r '.ai_stack[] | select(.type == "ml-library") | .name'
```

## Scenario 4: Memory-Enabled Agent

### Project with Mem0

```
agent-app/
├── memory/
│   └── mem0-config.yaml
├── requirements.txt
└── .env
```

### Detection

```bash
bash scripts/detect-ai-stack.sh .
```

### Result

```json
{
  "ai_stack": [
    {
      "name": "Claude Agent SDK",
      "type": "sdk",
      "version": "1.0.0",
      "evidence": "package.json"
    },
    {
      "name": "Mem0",
      "type": "memory",
      "version": "0.1.5",
      "evidence": "requirements.txt"
    },
    {
      "name": "Mem0",
      "type": "memory",
      "version": "unknown",
      "evidence": "config file"
    },
    {
      "name": "Supabase (Python)",
      "type": "database-service",
      "version": "2.0.0",
      "evidence": "requirements.txt"
    },
    {
      "name": "pgvector",
      "type": "vector-db",
      "version": "unknown",
      "evidence": "package.json"
    }
  ]
}
```

### Memory Stack Analysis

```bash
# Check for memory components
cat .claude/project.json | jq '.ai_stack[] | select(.type == "memory")'

# Check for memory backend (vector DB)
cat .claude/project.json | jq '.ai_stack[] | select(.type == "vector-db")'
```

## Scenario 5: Custom AI Stack Detection

### Extend AI Detection

Create custom detection rules:

```bash
#!/bin/bash
# custom-ai-detect.sh

# Source the original script functions
source scripts/detect-ai-stack.sh

# Add custom detection
detect_custom_ai_framework() {
    # Check for custom LLM wrapper
    if [[ -f "$PROJECT_PATH/package.json" ]]; then
        if grep -q '"@company/llm-sdk"' "$PROJECT_PATH/package.json"; then
            add_detection "Company LLM SDK" "sdk" "unknown" "package.json"
        fi
    fi

    # Check for custom embeddings
    if [[ -f "$PROJECT_PATH/.env" ]]; then
        if grep -q "CUSTOM_EMBEDDINGS_API" "$PROJECT_PATH/.env"; then
            add_detection "Custom Embeddings" "embeddings" "unknown" ".env"
        fi
    fi
}

# Run custom detection
detect_custom_ai_framework
```

## Scenario 6: AI Stack Audit

### Comprehensive AI Analysis

```bash
#!/bin/bash
# ai-stack-audit.sh

PROJECT_PATH="${1:-.}"

echo "=== AI Stack Audit ==="
echo ""

# Run detection
AI_JSON=$(bash scripts/detect-ai-stack.sh "$PROJECT_PATH" 2>/dev/null)

# Parse results
echo "AI Components Found:"
echo "$AI_JSON" | jq -r '.ai_stack[] | "\(.type): \(.name) (\(.version))"' | sort

echo ""
echo "=== By Category ==="

# SDKs
echo ""
echo "AI SDKs:"
echo "$AI_JSON" | jq -r '.ai_stack[] | select(.type == "sdk") | "  - \(.name) v\(.version)"'

# Vector DBs
echo ""
echo "Vector Databases:"
echo "$AI_JSON" | jq -r '.ai_stack[] | select(.type == "vector-db") | "  - \(.name)"'

# ML Libraries
echo ""
echo "ML Libraries:"
echo "$AI_JSON" | jq -r '.ai_stack[] | select(.type == "ml-library") | "  - \(.name) v\(.version)"'

# Embeddings
echo ""
echo "Embedding Providers:"
echo "$AI_JSON" | jq -r '.ai_stack[] | select(.type == "embeddings") | "  - \(.name)"'

echo ""
echo "=== AI Capabilities Analysis ==="

# Check for RAG
HAS_VECTOR_DB=$(echo "$AI_JSON" | jq '[.ai_stack[] | select(.type == "vector-db")] | length > 0')
HAS_EMBEDDINGS=$(echo "$AI_JSON" | jq '[.ai_stack[] | select(.type == "embeddings")] | length > 0')
HAS_LLM=$(echo "$AI_JSON" | jq '[.ai_stack[] | select(.type == "sdk")] | length > 0')

if [ "$HAS_VECTOR_DB" == "true" ] && [ "$HAS_EMBEDDINGS" == "true" ] && [ "$HAS_LLM" == "true" ]; then
    echo "✓ RAG System Detected"
else
    echo "✗ No complete RAG system"
fi

# Check for agent framework
HAS_AGENT=$(echo "$AI_JSON" | jq '[.ai_stack[] | select(.name | contains("Agent"))] | length > 0')
if [ "$HAS_AGENT" == "true" ]; then
    echo "✓ Agent Framework Detected"
else
    echo "✗ No agent framework"
fi

# Check for memory
HAS_MEMORY=$(echo "$AI_JSON" | jq '[.ai_stack[] | select(.type == "memory")] | length > 0')
if [ "$HAS_MEMORY" == "true" ]; then
    echo "✓ Memory System Detected"
else
    echo "✗ No memory system"
fi

echo ""
echo "=== Recommendations ==="

# Suggest improvements
if [ "$HAS_VECTOR_DB" == "false" ] && [ "$HAS_LLM" == "true" ]; then
    echo "⚠ Consider adding a vector database for RAG capabilities"
fi

if [ "$HAS_MEMORY" == "false" ] && [ "$HAS_AGENT" == "true" ]; then
    echo "⚠ Consider adding Mem0 for persistent agent memory"
fi

if [ "$HAS_EMBEDDINGS" == "false" ] && [ "$HAS_VECTOR_DB" == "true" ]; then
    echo "⚠ Vector DB detected but no embedding provider configured"
fi
```

### Run Audit

```bash
bash ai-stack-audit.sh /path/to/project
```

### Example Output

```
=== AI Stack Audit ===

AI Components Found:
embeddings: OpenAI Embeddings (unknown)
framework: LangChain (Python) (0.1.0)
sdk: Anthropic SDK (TypeScript) (unknown)
sdk: OpenAI SDK (Python) (1.3.0)
vector-db: Pinecone (unknown)

=== By Category ===

AI SDKs:
  - OpenAI SDK (Python) v1.3.0
  - Anthropic SDK (TypeScript) vunknown

Vector Databases:
  - Pinecone

ML Libraries:
  (none)

Embedding Providers:
  - OpenAI Embeddings

=== AI Capabilities Analysis ===
✓ RAG System Detected
✗ No agent framework
✗ No memory system

=== Recommendations ===
⚠ Consider adding Claude Agent SDK for agent capabilities
⚠ Consider adding Mem0 for persistent agent memory
```

## Environment Variable Detection

### Check for AI API Keys

```bash
#!/bin/bash
# detect-ai-keys.sh

if [ ! -f ".env" ]; then
    echo "No .env file found"
    exit 1
fi

echo "=== AI API Keys Detected ==="
echo ""

# Check for various providers
grep -q "OPENAI_API_KEY" .env && echo "✓ OpenAI API Key"
grep -q "ANTHROPIC_API_KEY" .env && echo "✓ Anthropic API Key"
grep -q "COHERE_API_KEY" .env && echo "✓ Cohere API Key"
grep -q "HUGGINGFACE_API_KEY" .env && echo "✓ Hugging Face API Key"
grep -q "PINECONE_API_KEY" .env && echo "✓ Pinecone API Key"
grep -q "WEAVIATE" .env && echo "✓ Weaviate Configuration"
grep -q "SUPABASE" .env && echo "✓ Supabase Configuration"

echo ""
echo "⚠ Remember to never commit .env to version control!"
```

## AI Stack Version Analysis

### Check for Outdated AI Packages

```bash
#!/bin/bash
# check-ai-versions.sh

echo "=== AI Package Versions ==="
echo ""

# Check package.json
if [ -f "package.json" ]; then
    echo "JavaScript AI Packages:"
    cat package.json | jq -r '.dependencies | to_entries[] | select(.key | test("ai|anthropic|openai|langchain")) | "  \(.key): \(.value)"'
fi

# Check requirements.txt
if [ -f "requirements.txt" ]; then
    echo ""
    echo "Python AI Packages:"
    grep -E "anthropic|openai|langchain|transformers|torch|tensorflow" requirements.txt | sed 's/^/  /'
fi

echo ""
echo "Run 'npm outdated' or 'pip list --outdated' to check for updates"
```

## Best Practices

1. **Regular Audits**: Run AI stack detection weekly
2. **API Key Security**: Never commit API keys
3. **Version Pinning**: Use exact versions for AI SDKs
4. **Cost Monitoring**: Track usage of paid AI services
5. **Model Selection**: Document which models are used where
6. **Fallback Providers**: Detect multiple providers for redundancy

## Common AI Stack Patterns

### Pattern 1: Simple LLM Integration
- One AI SDK (OpenAI or Anthropic)
- Direct API calls
- No vector storage

### Pattern 2: RAG System
- LLM SDK
- Embedding provider
- Vector database
- Document chunking library

### Pattern 3: Multi-Agent System
- Agent framework (Claude Agent SDK)
- Memory system (Mem0)
- Multiple LLM providers
- Tool integrations

### Pattern 4: ML Pipeline
- ML framework (PyTorch/TensorFlow)
- Model registry
- Training infrastructure
- Inference serving

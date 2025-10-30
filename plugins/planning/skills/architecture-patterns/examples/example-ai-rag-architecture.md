# Example: RAG System Architecture

> **Example Architecture**: Production RAG (Retrieval Augmented Generation) system with vector database
> **Last Updated**: 2025-01-01

## Overview

This example demonstrates a complete RAG system architecture using pgvector for embeddings, LangChain for orchestration, and Claude/OpenAI for generation.

---

## Technology Stack

### AI/ML Components
- **LLM**: Anthropic Claude 3.5 Sonnet / OpenAI GPT-4
- **Embeddings**: OpenAI text-embedding-3-large / Voyage AI
- **Framework**: LangChain / LlamaIndex
- **Vector DB**: Supabase (pgvector) / Pinecone
- **Document Processing**: Unstructured.io / LangChain Document Loaders

### Backend
- **API**: FastAPI (Python 3.12+)
- **Database**: PostgreSQL 16 with pgvector extension
- **Cache**: Redis for response caching
- **Queue**: Celery for async document processing

### Infrastructure
- **Hosting**: Vercel (API) + Supabase (Database)
- **File Storage**: S3 / Vercel Blob
- **Monitoring**: LangSmith / Weights & Biases

---

## High-Level Architecture

```mermaid
graph TB
    subgraph "User Layer"
        USER[User Query]
        UI[Chat Interface]
    end

    subgraph "API Layer"
        API[FastAPI Server]
        CACHE[(Response Cache)]
    end

    subgraph "RAG Pipeline"
        EMBED[Embedding Service]
        RETRIEVAL[Vector Search]
        RERANK[Reranking]
        AUGMENT[Context Augmentation]
        GENERATE[LLM Generation]
    end

    subgraph "Data Layer"
        VECTOR_DB[(Vector Database - pgvector)]
        DOC_STORE[(Document Store)]
        METADATA_DB[(Metadata DB)]
    end

    subgraph "Document Processing"
        INGEST[Document Ingestion]
        CHUNK[Chunking]
        EMBED_DOCS[Generate Embeddings]
        INDEX[Index to Vector DB]
    end

    USER --> UI
    UI --> API
    API --> CACHE
    CACHE --> EMBED

    EMBED --> RETRIEVAL
    RETRIEVAL --> VECTOR_DB
    VECTOR_DB --> RERANK
    RERANK --> AUGMENT
    AUGMENT --> GENERATE
    GENERATE --> API

    INGEST --> CHUNK
    CHUNK --> EMBED_DOCS
    EMBED_DOCS --> INDEX
    INDEX --> VECTOR_DB
    INDEX --> DOC_STORE
    INDEX --> METADATA_DB

    style USER fill:#e1f5ff
    style EMBED fill:#fff9e1
    style RETRIEVAL fill:#e1ffe1
    style VECTOR_DB fill:#ffe1e1
```

---

## RAG Pipeline Flow

### Query Processing

```mermaid
sequenceDiagram
    participant User
    participant API
    participant EmbedService
    participant VectorDB
    participant Reranker
    participant LLM

    User->>API: User Query
    API->>EmbedService: Generate Query Embedding
    EmbedService-->>API: Query Vector

    API->>VectorDB: Vector Similarity Search
    VectorDB-->>API: Top K Documents (k=20)

    API->>Reranker: Rerank Documents
    Reranker-->>API: Top N Relevant (n=5)

    API->>API: Build Context from Docs
    API->>LLM: Generate Response (Query + Context)
    LLM-->>API: Generated Answer
    API-->>User: Response with Sources
```

---

## Document Ingestion Pipeline

### Processing Flow

```mermaid
graph TB
    UPLOAD[Upload Document] --> DETECT[Detect File Type]
    DETECT --> EXTRACT[Extract Text]

    EXTRACT --> PDF[PDF Extraction]
    EXTRACT --> DOCX[DOCX Extraction]
    EXTRACT --> HTML[HTML Extraction]
    EXTRACT --> TXT[Plain Text]

    PDF --> CLEAN[Clean & Normalize]
    DOCX --> CLEAN
    HTML --> CLEAN
    TXT --> CLEAN

    CLEAN --> CHUNK[Chunk Documents]
    CHUNK --> RECURSIVE[Recursive Text Splitter]
    CHUNK --> SEMANTIC[Semantic Chunking]

    RECURSIVE --> EMBED[Generate Embeddings]
    SEMANTIC --> EMBED

    EMBED --> BATCH[Batch Process]
    BATCH --> STORE_VECTOR[Store in Vector DB]
    BATCH --> STORE_META[Store Metadata]
    BATCH --> STORE_DOC[Store Original Doc]

    STORE_VECTOR --> INDEX[Update Search Index]

    style UPLOAD fill:#e1f5ff
    style CHUNK fill:#fff9e1
    style EMBED fill:#e1ffe1
    style STORE_VECTOR fill:#ffe1e1
```

---

## Vector Database Schema

### Supabase with pgvector

```sql
-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Documents table
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    upload_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID NOT NULL,
    metadata JSONB,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Document chunks with embeddings
CREATE TABLE document_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL,
    chunk_index INTEGER NOT NULL,
    content TEXT NOT NULL,
    embedding vector(1536), -- OpenAI embedding dimension
    token_count INTEGER,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_document FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
);

-- Create HNSW index for fast similarity search
CREATE INDEX ON document_chunks USING hnsw (embedding vector_cosine_ops);

-- Create index on document_id for filtering
CREATE INDEX idx_chunks_document ON document_chunks(document_id);
```

### Vector Search Query

```sql
-- Similarity search with metadata filtering
SELECT
    dc.id,
    dc.content,
    dc.metadata,
    d.filename,
    1 - (dc.embedding <=> $1::vector) as similarity
FROM document_chunks dc
JOIN documents d ON dc.document_id = d.id
WHERE
    d.user_id = $2
    AND (dc.embedding <=> $1::vector) < 0.5  -- Similarity threshold
ORDER BY dc.embedding <=> $1::vector
LIMIT 20;
```

---

## Chunking Strategies

### Chunking Approaches

```mermaid
graph TB
    DOCUMENT[Source Document] --> STRATEGY{Chunking Strategy}

    STRATEGY -->|Fixed Size| FIXED[Fixed Size Chunks]
    STRATEGY -->|Recursive| RECURSIVE[Recursive Text Splitter]
    STRATEGY -->|Semantic| SEMANTIC[Semantic Chunking]

    FIXED --> OVERLAP1[Overlap: 50 tokens]
    RECURSIVE --> OVERLAP2[Overlap: 100 tokens]
    SEMANTIC --> NO_OVERLAP[No Overlap]

    OVERLAP1 --> CHUNKS1[Chunks: 500 tokens each]
    OVERLAP2 --> CHUNKS2[Chunks: Variable size]
    NO_OVERLAP --> CHUNKS3[Chunks: Semantic boundaries]

    style DOCUMENT fill:#e1f5ff
    style STRATEGY fill:#fff9e1
    style SEMANTIC fill:#e1ffe1
```

### Code Example

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter

# Recursive chunking with overlap
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,  # characters
    chunk_overlap=200,
    length_function=len,
    separators=["\n\n", "\n", " ", ""]
)

chunks = text_splitter.split_text(document_text)

# Semantic chunking (alternative)
from langchain_experimental.text_splitter import SemanticChunker
from langchain_openai import OpenAIEmbeddings

semantic_chunker = SemanticChunker(
    OpenAIEmbeddings(),
    breakpoint_threshold_type="percentile"
)

semantic_chunks = semantic_chunker.split_text(document_text)
```

---

## Retrieval Strategies

### Hybrid Search

```mermaid
graph TB
    QUERY[User Query] --> VECTOR[Vector Search]
    QUERY --> KEYWORD[Keyword Search]

    VECTOR --> VECTOR_RESULTS[Vector Results - 20 docs]
    KEYWORD --> KEYWORD_RESULTS[Keyword Results - 20 docs]

    VECTOR_RESULTS --> MERGE[Reciprocal Rank Fusion]
    KEYWORD_RESULTS --> MERGE

    MERGE --> RERANK[Rerank with Cross-Encoder]
    RERANK --> TOP_N[Top 5 Documents]

    style QUERY fill:#e1f5ff
    style MERGE fill:#fff9e1
    style RERANK fill:#e1ffe1
    style TOP_N fill:#d4edda
```

### Multi-Query Retrieval

```python
# Generate multiple query variations
async def multi_query_retrieval(original_query: str):
    # Generate query variations
    variations = await generate_query_variations(original_query)

    # Parallel retrieval for all variations
    all_results = await asyncio.gather(*[
        vector_search(query) for query in variations
    ])

    # Deduplicate and rank
    unique_docs = deduplicate_documents(all_results)
    reranked = rerank_documents(unique_docs, original_query)

    return reranked[:5]
```

---

## Context Augmentation

### Prompt Construction

```python
SYSTEM_PROMPT = """
You are a helpful AI assistant. Answer questions based on the provided context.

If the context doesn't contain enough information to answer the question,
say "I don't have enough information to answer that question accurately."

Always cite your sources using [Source: filename] notation.
"""

def build_rag_prompt(query: str, retrieved_docs: List[Document]) -> str:
    # Build context from retrieved documents
    context_parts = []
    for i, doc in enumerate(retrieved_docs, 1):
        context_parts.append(
            f"[Source {i}: {doc.metadata['filename']}]\n{doc.content}\n"
        )

    context = "\n---\n".join(context_parts)

    # Construct final prompt
    prompt = f"""
{SYSTEM_PROMPT}

Context:
{context}

Question: {query}

Answer:
"""
    return prompt
```

---

## Response Generation

### LLM Integration

```mermaid
sequenceDiagram
    participant API
    participant PromptBuilder
    participant LLM
    participant ResponseParser

    API->>PromptBuilder: Build Prompt (Query + Context)
    PromptBuilder-->>API: Constructed Prompt

    API->>LLM: Generate Response
    Note over LLM: Claude 3.5 Sonnet<br/>Max Tokens: 2000<br/>Temperature: 0.3

    LLM-->>API: Generated Text

    API->>ResponseParser: Parse Response
    ResponseParser->>ResponseParser: Extract Citations
    ResponseParser->>ResponseParser: Format Answer
    ResponseParser-->>API: Structured Response

    API-->>API: Store in Cache
```

---

## Caching Strategy

### Multi-Level Caching

```mermaid
graph TB
    QUERY[User Query] --> EXACT_CACHE{Exact Match Cache}

    EXACT_CACHE -->|Hit| RETURN_CACHED[Return Cached Response]
    EXACT_CACHE -->|Miss| SEMANTIC_CACHE{Semantic Cache}

    SEMANTIC_CACHE -->|Similar Query| RETURN_SIMILAR[Return Similar Response]
    SEMANTIC_CACHE -->|Miss| EMBEDDING_CACHE{Embedding Cache}

    EMBEDDING_CACHE -->|Hit| SKIP_EMBED[Use Cached Embedding]
    EMBEDDING_CACHE -->|Miss| GENERATE_EMBED[Generate New Embedding]

    SKIP_EMBED --> RAG_PIPELINE[RAG Pipeline]
    GENERATE_EMBED --> STORE_EMBED[Store Embedding]
    STORE_EMBED --> RAG_PIPELINE

    RAG_PIPELINE --> RESPONSE[Generated Response]
    RESPONSE --> STORE_RESPONSE[Store in All Caches]

    style QUERY fill:#e1f5ff
    style EXACT_CACHE fill:#fff9e1
    style RAG_PIPELINE fill:#e1ffe1
    style RESPONSE fill:#d4edda
```

---

## Evaluation Metrics

### RAG Performance Metrics

```mermaid
graph TB
    subgraph "Retrieval Metrics"
        RECALL[Recall@K]
        PRECISION[Precision@K]
        MRR[Mean Reciprocal Rank]
    end

    subgraph "Generation Metrics"
        FAITHFULNESS[Faithfulness]
        RELEVANCE[Answer Relevance]
        COMPLETENESS[Completeness]
    end

    subgraph "End-to-End Metrics"
        LATENCY[Response Latency]
        COST[Cost per Query]
        USER_SAT[User Satisfaction]
    end

    EVAL[Evaluation Pipeline] --> RECALL
    EVAL --> PRECISION
    EVAL --> FAITHFULNESS
    EVAL --> RELEVANCE
    EVAL --> LATENCY
    EVAL --> COST

    style EVAL fill:#e1f5ff
    style FAITHFULNESS fill:#fff9e1
    style LATENCY fill:#e1ffe1
```

---

## Cost Optimization

### Strategies

1. **Caching**: Cache embeddings and responses
2. **Batch Processing**: Generate embeddings in batches
3. **Model Selection**: Use cheaper models for retrieval, expensive for generation
4. **Prompt Optimization**: Minimize context size while maintaining quality
5. **Async Processing**: Document ingestion in background jobs

### Cost Breakdown

```mermaid
pie title Cost Distribution
    "Embedding Generation" : 40
    "Vector Storage" : 10
    "LLM Generation" : 45
    "Infrastructure" : 5
```

---

## Security & Privacy

### Data Protection

```mermaid
graph TB
    USER_DATA[User Documents] --> ENCRYPT[Encryption at Rest]
    ENCRYPT --> VECTOR_DB[(Encrypted Vector DB)]

    QUERY[User Query] --> TLS[TLS 1.3 Encryption]
    TLS --> API[API Server]
    API --> RBAC[Role-Based Access Control]
    RBAC --> FILTERED_SEARCH[Filtered Vector Search]

    FILTERED_SEARCH --> VECTOR_DB
    VECTOR_DB --> USER_DOCS[Only User's Documents]

    style USER_DATA fill:#ffe1e1
    style ENCRYPT fill:#fff9e1
    style RBAC fill:#e1ffe1
    style USER_DOCS fill:#d4edda
```

---

## Key Takeaways

1. **Hybrid Search**: Combine vector and keyword search for better recall
2. **Chunking Strategy**: Choose chunking approach based on document type
3. **Reranking**: Always rerank retrieval results before generation
4. **Caching**: Implement multi-level caching for cost and latency
5. **Evaluation**: Continuously monitor retrieval and generation quality
6. **Security**: Filter vector search by user permissions
7. **Cost Management**: Optimize embedding and generation costs

---

## References

- [LangChain Documentation](https://python.langchain.com/)
- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [Anthropic Claude API](https://docs.anthropic.com/)
- [OpenAI Embeddings](https://platform.openai.com/docs/guides/embeddings)

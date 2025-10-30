#!/usr/bin/env bash
#
# create-architecture.sh - Scaffold complete architecture documentation
#
# Usage: ./create-architecture.sh <project-path> <architecture-type>
#
# Architecture types: nextjs, fastapi, fullstack, microservices, rag, generic
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$SKILL_DIR/templates"

# Parse arguments
PROJECT_PATH="${1:-}"
ARCH_TYPE="${2:-generic}"

if [[ -z "$PROJECT_PATH" ]]; then
    echo -e "${RED}Error: Project path is required${NC}"
    echo "Usage: $0 <project-path> <architecture-type>"
    echo "Architecture types: nextjs, fastapi, fullstack, microservices, rag, generic"
    exit 1
fi

# Validate architecture type
VALID_TYPES=("nextjs" "fastapi" "fullstack" "microservices" "rag" "generic")
if [[ ! " ${VALID_TYPES[@]} " =~ " ${ARCH_TYPE} " ]]; then
    echo -e "${YELLOW}Warning: Unknown architecture type '$ARCH_TYPE', using 'generic'${NC}"
    ARCH_TYPE="generic"
fi

# Create architecture directory
ARCH_DIR="$PROJECT_PATH/docs/architecture"
mkdir -p "$ARCH_DIR"

echo -e "${GREEN}Creating architecture documentation in: $ARCH_DIR${NC}"
echo -e "${GREEN}Architecture type: $ARCH_TYPE${NC}"

# Copy base templates
echo "Copying architecture templates..."

if [[ -f "$TEMPLATES_DIR/architecture-overview.md" ]]; then
    cp "$TEMPLATES_DIR/architecture-overview.md" "$ARCH_DIR/overview.md"
    echo "  - Created overview.md"
fi

if [[ -f "$TEMPLATES_DIR/component-diagram.md" ]]; then
    cp "$TEMPLATES_DIR/component-diagram.md" "$ARCH_DIR/components.md"
    echo "  - Created components.md"
fi

if [[ -f "$TEMPLATES_DIR/data-flow-diagram.md" ]]; then
    cp "$TEMPLATES_DIR/data-flow-diagram.md" "$ARCH_DIR/data-flow.md"
    echo "  - Created data-flow.md"
fi

if [[ -f "$TEMPLATES_DIR/deployment-diagram.md" ]]; then
    cp "$TEMPLATES_DIR/deployment-diagram.md" "$ARCH_DIR/deployment.md"
    echo "  - Created deployment.md"
fi

if [[ -f "$TEMPLATES_DIR/api-architecture.md" ]]; then
    cp "$TEMPLATES_DIR/api-architecture.md" "$ARCH_DIR/api.md"
    echo "  - Created api.md"
fi

if [[ -f "$TEMPLATES_DIR/security-architecture.md" ]]; then
    cp "$TEMPLATES_DIR/security-architecture.md" "$ARCH_DIR/security.md"
    echo "  - Created security.md"
fi

# Create README with table of contents
cat > "$ARCH_DIR/README.md" <<EOF
# Architecture Documentation

This directory contains comprehensive architecture documentation for the project.

## Architecture Type: ${ARCH_TYPE^^}

## Table of Contents

1. [Overview](./overview.md) - High-level system architecture and design principles
2. [Components](./components.md) - Component architecture and relationships
3. [Data Flow](./data-flow.md) - Data flow and processing pipelines
4. [Deployment](./deployment.md) - Infrastructure and deployment architecture
5. [API Design](./api.md) - API architecture, endpoints, and authentication
6. [Security](./security.md) - Security patterns and threat mitigation

## Quick Start

Start with the [Overview](./overview.md) to understand the system architecture at a high level.

## Diagrams

All diagrams are created using Mermaid syntax for easy rendering in GitHub and documentation tools.

To validate diagrams, run:
\`\`\`bash
bash scripts/validate-mermaid.sh docs/architecture/overview.md
\`\`\`

To export diagrams to individual files:
\`\`\`bash
bash scripts/export-diagrams.sh docs/architecture/overview.md diagrams/
\`\`\`

## Updating Documentation

To add new sections to existing architecture docs:
\`\`\`bash
bash scripts/update-architecture.sh docs/architecture/overview.md component
\`\`\`

## Architecture Type Notes

EOF

# Add architecture-specific notes
case "$ARCH_TYPE" in
    nextjs)
        cat >> "$ARCH_DIR/README.md" <<EOF
### Next.js Architecture

- Next.js 15 with App Router
- React Server Components (RSC)
- Server Actions for mutations
- API Routes for external integrations
- Edge runtime for performance-critical paths
EOF
        ;;
    fastapi)
        cat >> "$ARCH_DIR/README.md" <<EOF
### FastAPI Architecture

- FastAPI with async/await patterns
- Pydantic models for validation
- SQLAlchemy for database ORM
- Alembic for migrations
- Dependency injection for services
EOF
        ;;
    fullstack)
        cat >> "$ARCH_DIR/README.md" <<EOF
### Full Stack Architecture

- Frontend: Next.js 15 with App Router
- Backend: FastAPI with async patterns
- Database: PostgreSQL with connection pooling
- Authentication: JWT with refresh tokens
- Real-time: WebSockets or Server-Sent Events
EOF
        ;;
    microservices)
        cat >> "$ARCH_DIR/README.md" <<EOF
### Microservices Architecture

- API Gateway for routing and load balancing
- Service-to-service communication via REST or gRPC
- Event-driven patterns with message queues
- Distributed tracing and logging
- Service mesh for observability
EOF
        ;;
    rag)
        cat >> "$ARCH_DIR/README.md" <<EOF
### RAG System Architecture

- Vector database for embeddings (pgvector, Pinecone, etc.)
- Embedding generation service
- Document chunking and preprocessing
- Retrieval and ranking pipeline
- LLM integration for generation
EOF
        ;;
    generic)
        cat >> "$ARCH_DIR/README.md" <<EOF
### Generic Architecture

This is a template architecture. Customize it based on your specific:
- Technology stack
- Deployment environment
- Scalability requirements
- Security constraints
EOF
        ;;
esac

echo ""
echo -e "${GREEN}Architecture documentation created successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review and customize: $ARCH_DIR/overview.md"
echo "  2. Add project-specific components to: $ARCH_DIR/components.md"
echo "  3. Document data flows in: $ARCH_DIR/data-flow.md"
echo "  4. Validate diagrams: bash scripts/validate-mermaid.sh $ARCH_DIR/overview.md"
echo ""

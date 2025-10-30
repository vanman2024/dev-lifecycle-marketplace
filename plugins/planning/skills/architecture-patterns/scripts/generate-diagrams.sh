#!/usr/bin/env bash
#
# generate-diagrams.sh - Generate mermaid diagram template placeholders
#
# Usage: ./generate-diagrams.sh <output-dir> <diagram-types>
#
# Diagram types: component, data-flow, deployment, api, security, all
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

OUTPUT_DIR="${1:-}"
DIAGRAM_TYPES="${2:-all}"

if [[ -z "$OUTPUT_DIR" ]]; then
    echo -e "${RED}Error: Output directory is required${NC}"
    echo "Usage: $0 <output-dir> <diagram-types>"
    echo "Diagram types: component, data-flow, deployment, api, security, all"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}Generating diagram templates in: $OUTPUT_DIR${NC}"
echo ""

# Function to create component diagram
create_component_diagram() {
    cat > "$OUTPUT_DIR/component-diagram.md" <<'EOF'
# Component Architecture Diagram

## System Components

```mermaid
graph TB
    subgraph "Frontend Layer"
        UI[User Interface]
        STATE[State Management]
    end

    subgraph "Backend Layer"
        API[API Server]
        AUTH[Auth Service]
        BL[Business Logic]
    end

    subgraph "Data Layer"
        DB[(Database)]
        CACHE[(Cache)]
    end

    UI --> STATE
    STATE --> API
    API --> AUTH
    API --> BL
    BL --> DB
    BL --> CACHE
    AUTH --> DB

    style UI fill:#e1f5ff
    style API fill:#fff9e1
    style DB fill:#ffe1e1
```

## Component Descriptions

- **User Interface**: Frontend components and pages
- **State Management**: Application state and data flow
- **API Server**: REST/GraphQL endpoints
- **Auth Service**: Authentication and authorization
- **Business Logic**: Core application logic
- **Database**: Persistent data storage
- **Cache**: In-memory data cache

## Component Relationships

[Describe how components interact and depend on each other]
EOF
    echo "  - Created component-diagram.md"
}

# Function to create data flow diagram
create_dataflow_diagram() {
    cat > "$OUTPUT_DIR/data-flow-diagram.md" <<'EOF'
# Data Flow Diagram

## Request/Response Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant Service
    participant Database

    Client->>API: HTTP Request
    API->>API: Validate Request
    API->>Service: Process Data
    Service->>Database: Query Data
    Database-->>Service: Return Results
    Service->>Service: Transform Data
    Service-->>API: Processed Data
    API-->>Client: HTTP Response
```

## Data Processing Pipeline

```mermaid
graph LR
    INPUT[Input Data] --> VALIDATE[Validation]
    VALIDATE --> TRANSFORM[Transformation]
    TRANSFORM --> PROCESS[Processing]
    PROCESS --> STORE[Storage]
    STORE --> OUTPUT[Output]

    style INPUT fill:#e1f5ff
    style VALIDATE fill:#fff9e1
    style PROCESS fill:#e1ffe1
    style STORE fill:#ffe1e1
    style OUTPUT fill:#f5e1ff
```

## Data Flow Description

[Describe how data flows through the system, transformations applied, and validation rules]

## Data Formats

- **Input**: [Describe input format]
- **Processing**: [Describe intermediate format]
- **Output**: [Describe output format]
EOF
    echo "  - Created data-flow-diagram.md"
}

# Function to create deployment diagram
create_deployment_diagram() {
    cat > "$OUTPUT_DIR/deployment-diagram.md" <<'EOF'
# Deployment Architecture Diagram

## Infrastructure Overview

```mermaid
graph TB
    subgraph "Cloud Provider"
        subgraph "Production Environment"
            LB[Load Balancer]
            APP1[App Server 1]
            APP2[App Server 2]
            DB[(Primary DB)]
            REPLICA[(Read Replica)]
            CACHE[(Redis Cache)]
        end

        subgraph "Staging Environment"
            STG_APP[Staging Server]
            STG_DB[(Staging DB)]
        end
    end

    USERS[Users] --> LB
    LB --> APP1
    LB --> APP2
    APP1 --> DB
    APP2 --> DB
    APP1 --> REPLICA
    APP2 --> REPLICA
    APP1 --> CACHE
    APP2 --> CACHE

    style USERS fill:#e1f5ff
    style LB fill:#fff9e1
    style DB fill:#ffe1e1
```

## Deployment Specifications

### Production Environment
- **Load Balancer**: [Provider/Configuration]
- **Application Servers**: [Instance type, count, scaling rules]
- **Database**: [Type, version, replication setup]
- **Cache**: [Type, size, eviction policy]

### Scaling Strategy
[Describe horizontal and vertical scaling approaches]

### Backup and Recovery
[Describe backup frequency, retention, and recovery procedures]
EOF
    echo "  - Created deployment-diagram.md"
}

# Function to create API architecture diagram
create_api_diagram() {
    cat > "$OUTPUT_DIR/api-architecture.md" <<'EOF'
# API Architecture Diagram

## API Structure

```mermaid
graph TB
    subgraph "API Gateway"
        GATEWAY[API Gateway]
        RATELIMIT[Rate Limiting]
        AUTH[Authentication]
    end

    subgraph "API Endpoints"
        USERS[/api/users]
        POSTS[/api/posts]
        COMMENTS[/api/comments]
        AUTH_EP[/api/auth]
    end

    subgraph "Services"
        USER_SVC[User Service]
        POST_SVC[Post Service]
        COMMENT_SVC[Comment Service]
        AUTH_SVC[Auth Service]
    end

    CLIENT[Client] --> GATEWAY
    GATEWAY --> RATELIMIT
    RATELIMIT --> AUTH
    AUTH --> USERS
    AUTH --> POSTS
    AUTH --> COMMENTS
    AUTH --> AUTH_EP

    USERS --> USER_SVC
    POSTS --> POST_SVC
    COMMENTS --> COMMENT_SVC
    AUTH_EP --> AUTH_SVC

    style CLIENT fill:#e1f5ff
    style GATEWAY fill:#fff9e1
    style USER_SVC fill:#e1ffe1
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/refresh` - Refresh token
- `POST /api/auth/logout` - User logout

### Users
- `GET /api/users` - List users
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

[Add more endpoints as needed]

## Authentication Flow

```mermaid
sequenceDiagram
    participant Client
    participant Gateway
    participant Auth
    participant API

    Client->>Gateway: Request + Token
    Gateway->>Auth: Validate Token
    Auth-->>Gateway: Token Valid
    Gateway->>API: Forward Request
    API-->>Gateway: Response
    Gateway-->>Client: Response
```

## Rate Limiting

- **Authenticated Users**: [Rate limit]
- **Anonymous Users**: [Rate limit]
- **Premium Users**: [Rate limit]
EOF
    echo "  - Created api-architecture.md"
}

# Function to create security diagram
create_security_diagram() {
    cat > "$OUTPUT_DIR/security-architecture.md" <<'EOF'
# Security Architecture Diagram

## Security Layers

```mermaid
graph TB
    subgraph "Security Perimeter"
        WAF[Web Application Firewall]
        DDoS[DDoS Protection]
    end

    subgraph "Application Security"
        AUTH[Authentication]
        AUTHZ[Authorization]
        INPUT_VAL[Input Validation]
        ENCRYPTION[Data Encryption]
    end

    subgraph "Data Security"
        DB_ENCRYPT[(Encrypted Database)]
        BACKUP[(Encrypted Backups)]
        SECRETS[Secrets Management]
    end

    INTERNET[Internet] --> WAF
    WAF --> DDoS
    DDoS --> AUTH
    AUTH --> AUTHZ
    AUTHZ --> INPUT_VAL
    INPUT_VAL --> ENCRYPTION
    ENCRYPTION --> DB_ENCRYPT
    DB_ENCRYPT --> BACKUP
    SECRETS -.-> DB_ENCRYPT

    style INTERNET fill:#ffe1e1
    style AUTH fill:#fff9e1
    style DB_ENCRYPT fill:#e1ffe1
```

## Authentication Flow

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant Auth Service
    participant Database

    User->>Frontend: Enter Credentials
    Frontend->>Auth Service: Login Request (HTTPS)
    Auth Service->>Auth Service: Hash Password
    Auth Service->>Database: Verify Credentials
    Database-->>Auth Service: User Data
    Auth Service->>Auth Service: Generate JWT
    Auth Service-->>Frontend: JWT + Refresh Token
    Frontend->>Frontend: Store Tokens (HttpOnly Cookie)
    Frontend-->>User: Login Success
```

## Security Measures

### Network Security
- WAF rules and policies
- DDoS mitigation strategies
- IP allowlisting/blocklisting
- VPN for internal services

### Application Security
- JWT-based authentication
- Role-based access control (RBAC)
- Input validation and sanitization
- SQL injection prevention
- XSS protection
- CSRF tokens

### Data Security
- Encryption at rest (AES-256)
- Encryption in transit (TLS 1.3)
- Database encryption
- Backup encryption
- Secrets management (vault)

### Threat Model

[Describe potential threats and mitigations]

### Compliance

[List compliance requirements: GDPR, HIPAA, SOC2, etc.]
EOF
    echo "  - Created security-architecture.md"
}

# Generate diagrams based on type
case "$DIAGRAM_TYPES" in
    component)
        create_component_diagram
        ;;
    data-flow)
        create_dataflow_diagram
        ;;
    deployment)
        create_deployment_diagram
        ;;
    api)
        create_api_diagram
        ;;
    security)
        create_security_diagram
        ;;
    all)
        create_component_diagram
        create_dataflow_diagram
        create_deployment_diagram
        create_api_diagram
        create_security_diagram
        ;;
    *)
        echo -e "${RED}Error: Unknown diagram type: $DIAGRAM_TYPES${NC}"
        echo "Valid types: component, data-flow, deployment, api, security, all"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Diagram templates generated successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Customize the generated diagrams for your project"
echo "  2. Validate diagrams: bash scripts/validate-mermaid.sh $OUTPUT_DIR/*.md"
echo "  3. Add project-specific components and relationships"
echo ""

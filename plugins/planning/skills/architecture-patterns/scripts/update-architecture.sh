#!/usr/bin/env bash
#
# update-architecture.sh - Add new sections to existing architecture documentation
#
# Usage: ./update-architecture.sh <architecture-file> <section>
#
# Sections: component, api, security, deployment, data-flow, custom
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ARCH_FILE="${1:-}"
SECTION="${2:-custom}"

if [[ -z "$ARCH_FILE" ]]; then
    echo -e "${RED}Error: Architecture file is required${NC}"
    echo "Usage: $0 <architecture-file> <section>"
    echo "Sections: component, api, security, deployment, data-flow, custom"
    exit 1
fi

if [[ ! -f "$ARCH_FILE" ]]; then
    echo -e "${RED}Error: File not found: $ARCH_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}Adding '$SECTION' section to: $ARCH_FILE${NC}"
echo ""

# Function to add component section
add_component_section() {
    cat >> "$ARCH_FILE" <<'EOF'

## Component Architecture

### Component Overview

```mermaid
graph TB
    COMP1[Component 1]
    COMP2[Component 2]
    COMP3[Component 3]

    COMP1 --> COMP2
    COMP2 --> COMP3

    style COMP1 fill:#e1f5ff
    style COMP2 fill:#fff9e1
    style COMP3 fill:#e1ffe1
```

### Component Descriptions

- **Component 1**: [Description]
- **Component 2**: [Description]
- **Component 3**: [Description]

### Component Responsibilities

[Describe what each component is responsible for]

### Component Dependencies

[Describe how components depend on each other]
EOF
    echo "  - Added component architecture section"
}

# Function to add API section
add_api_section() {
    cat >> "$ARCH_FILE" <<'EOF'

## API Architecture

### API Endpoints

```mermaid
graph LR
    CLIENT[Client] --> GATEWAY[API Gateway]
    GATEWAY --> EP1[Endpoint 1]
    GATEWAY --> EP2[Endpoint 2]
    GATEWAY --> EP3[Endpoint 3]

    EP1 --> SVC1[Service 1]
    EP2 --> SVC2[Service 2]
    EP3 --> SVC3[Service 3]

    style CLIENT fill:#e1f5ff
    style GATEWAY fill:#fff9e1
```

### Endpoint List

#### Endpoint 1
- **Path**: `/api/resource`
- **Method**: GET, POST, PUT, DELETE
- **Authentication**: Required
- **Rate Limit**: [Specify]

#### Endpoint 2
- **Path**: `/api/resource/:id`
- **Method**: GET, PUT, DELETE
- **Authentication**: Required
- **Rate Limit**: [Specify]

### Authentication

[Describe authentication mechanism: JWT, OAuth, API Keys, etc.]

### Request/Response Flow

```mermaid
sequenceDiagram
    Client->>Gateway: HTTP Request
    Gateway->>Service: Process Request
    Service->>Database: Query Data
    Database-->>Service: Results
    Service-->>Gateway: Response Data
    Gateway-->>Client: HTTP Response
```
EOF
    echo "  - Added API architecture section"
}

# Function to add security section
add_security_section() {
    cat >> "$ARCH_FILE" <<'EOF'

## Security Architecture

### Security Layers

```mermaid
graph TB
    INTERNET[Internet Traffic]
    WAF[Web Application Firewall]
    AUTH[Authentication Layer]
    AUTHZ[Authorization Layer]
    APP[Application Layer]
    DATA[Data Layer]

    INTERNET --> WAF
    WAF --> AUTH
    AUTH --> AUTHZ
    AUTHZ --> APP
    APP --> DATA

    style INTERNET fill:#ffe1e1
    style AUTH fill:#fff9e1
    style DATA fill:#e1ffe1
```

### Security Measures

#### Network Security
- Firewall rules
- DDoS protection
- IP filtering
- VPN access for internal services

#### Application Security
- Authentication and authorization
- Input validation
- SQL injection prevention
- XSS protection
- CSRF tokens

#### Data Security
- Encryption at rest
- Encryption in transit
- Secure key management
- Regular backups

### Authentication Flow

```mermaid
sequenceDiagram
    User->>App: Login Request
    App->>Auth: Validate Credentials
    Auth->>Database: Check User
    Database-->>Auth: User Data
    Auth->>Auth: Generate Token
    Auth-->>App: JWT Token
    App-->>User: Authenticated
```

### Threat Model

[Describe potential security threats and mitigations]
EOF
    echo "  - Added security architecture section"
}

# Function to add deployment section
add_deployment_section() {
    cat >> "$ARCH_FILE" <<'EOF'

## Deployment Architecture

### Infrastructure Overview

```mermaid
graph TB
    subgraph "Cloud Environment"
        LB[Load Balancer]
        APP1[App Instance 1]
        APP2[App Instance 2]
        DB[(Database)]
        CACHE[(Cache)]
    end

    USERS[Users] --> LB
    LB --> APP1
    LB --> APP2
    APP1 --> DB
    APP2 --> DB
    APP1 --> CACHE
    APP2 --> CACHE

    style USERS fill:#e1f5ff
    style LB fill:#fff9e1
    style DB fill:#ffe1e1
```

### Environment Specifications

#### Production
- **Instances**: [Count and type]
- **Database**: [Configuration]
- **Cache**: [Configuration]
- **Load Balancer**: [Configuration]

#### Staging
- **Instances**: [Count and type]
- **Database**: [Configuration]

### Deployment Process

1. Build application
2. Run tests
3. Deploy to staging
4. Run integration tests
5. Deploy to production (blue-green)
6. Monitor and rollback if needed

### Monitoring and Logging

- Application metrics
- System metrics
- Log aggregation
- Alert configuration
EOF
    echo "  - Added deployment architecture section"
}

# Function to add data flow section
add_dataflow_section() {
    cat >> "$ARCH_FILE" <<'EOF'

## Data Flow Architecture

### Data Processing Pipeline

```mermaid
graph LR
    INPUT[Input] --> VALIDATE[Validate]
    VALIDATE --> TRANSFORM[Transform]
    TRANSFORM --> PROCESS[Process]
    PROCESS --> STORE[Store]
    STORE --> OUTPUT[Output]

    style INPUT fill:#e1f5ff
    style PROCESS fill:#e1ffe1
    style OUTPUT fill:#f5e1ff
```

### Data Flow Description

[Describe how data flows through the system]

### Data Transformations

1. **Input Validation**: [Describe validation rules]
2. **Data Transformation**: [Describe transformations]
3. **Processing Logic**: [Describe processing steps]
4. **Storage Strategy**: [Describe storage approach]

### Sequence Flow

```mermaid
sequenceDiagram
    participant Source
    participant Processor
    participant Storage

    Source->>Processor: Raw Data
    Processor->>Processor: Validate
    Processor->>Processor: Transform
    Processor->>Storage: Processed Data
    Storage-->>Processor: Confirmation
    Processor-->>Source: Success
```

### Data Formats

- **Input Format**: [Describe]
- **Processing Format**: [Describe]
- **Output Format**: [Describe]
EOF
    echo "  - Added data flow architecture section"
}

# Function to add custom section
add_custom_section() {
    cat >> "$ARCH_FILE" <<'EOF'

## Custom Architecture Section

### Overview

[Add your custom section description here]

### Diagram

```mermaid
graph TB
    A[Component A]
    B[Component B]
    C[Component C]

    A --> B
    B --> C

    style A fill:#e1f5ff
    style B fill:#fff9e1
    style C fill:#e1ffe1
```

### Details

[Add detailed information about this section]
EOF
    echo "  - Added custom architecture section"
}

# Add section based on type
case "$SECTION" in
    component)
        add_component_section
        ;;
    api)
        add_api_section
        ;;
    security)
        add_security_section
        ;;
    deployment)
        add_deployment_section
        ;;
    data-flow)
        add_dataflow_section
        ;;
    custom)
        add_custom_section
        ;;
    *)
        echo -e "${RED}Error: Unknown section type: $SECTION${NC}"
        echo "Valid sections: component, api, security, deployment, data-flow, custom"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Section added successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review and customize the new section in: $ARCH_FILE"
echo "  2. Validate diagrams: bash scripts/validate-mermaid.sh $ARCH_FILE"
echo ""

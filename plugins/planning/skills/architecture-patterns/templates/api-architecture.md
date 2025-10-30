# API Architecture

> **Document**: API Architecture Diagram
> **Last Updated**: [Date]

## Overview

This document describes the API architecture, including API design, endpoint structure, authentication, rate limiting, and API gateway patterns.

---

## API Gateway Architecture

### Gateway Components

```mermaid
graph TB
    subgraph "API Gateway Layer"
        GATEWAY[API Gateway]
        RATE_LIMIT[Rate Limiter]
        AUTH_MIDDLEWARE[Auth Middleware]
        CACHE_MIDDLEWARE[Cache Middleware]
        LOGGER[Request Logger]
    end

    subgraph "API Routing"
        ROUTER[API Router]
        V1[API v1]
        V2[API v2]
    end

    subgraph "Backend Services"
        AUTH_SVC[Auth Service]
        USER_SVC[User Service]
        PRODUCT_SVC[Product Service]
        ORDER_SVC[Order Service]
    end

    CLIENT[Client] --> GATEWAY
    GATEWAY --> RATE_LIMIT
    RATE_LIMIT --> AUTH_MIDDLEWARE
    AUTH_MIDDLEWARE --> CACHE_MIDDLEWARE
    CACHE_MIDDLEWARE --> LOGGER
    LOGGER --> ROUTER

    ROUTER --> V1
    ROUTER --> V2

    V1 --> AUTH_SVC
    V1 --> USER_SVC
    V1 --> PRODUCT_SVC
    V1 --> ORDER_SVC

    V2 --> USER_SVC
    V2 --> PRODUCT_SVC
    V2 --> ORDER_SVC

    style CLIENT fill:#e1f5ff
    style GATEWAY fill:#fff9e1
    style ROUTER fill:#e1ffe1
    style USER_SVC fill:#ffe1e1
```

---

## API Endpoints Structure

### Resource-Based API

```mermaid
graph TB
    API[API Root /api/v1]

    API --> USERS[/users]
    API --> PRODUCTS[/products]
    API --> ORDERS[/orders]
    API --> AUTH[/auth]

    USERS --> USER_LIST[GET /users]
    USERS --> USER_CREATE[POST /users]
    USERS --> USER_DETAIL[GET /users/:id]
    USERS --> USER_UPDATE[PUT /users/:id]
    USERS --> USER_DELETE[DELETE /users/:id]

    PRODUCTS --> PRODUCT_LIST[GET /products]
    PRODUCTS --> PRODUCT_CREATE[POST /products]
    PRODUCTS --> PRODUCT_DETAIL[GET /products/:id]
    PRODUCTS --> PRODUCT_UPDATE[PUT /products/:id]

    ORDERS --> ORDER_LIST[GET /orders]
    ORDERS --> ORDER_CREATE[POST /orders]
    ORDERS --> ORDER_DETAIL[GET /orders/:id]
    ORDERS --> ORDER_CANCEL[POST /orders/:id/cancel]

    AUTH --> LOGIN[POST /auth/login]
    AUTH --> LOGOUT[POST /auth/logout]
    AUTH --> REFRESH[POST /auth/refresh]

    style API fill:#e1f5ff
    style USERS fill:#fff9e1
    style PRODUCTS fill:#e1ffe1
    style ORDERS fill:#ffe1e1
```

---

## API Request Flow

### Standard Request Processing

```mermaid
sequenceDiagram
    participant Client
    participant Gateway
    participant RateLimit
    participant Auth
    participant Cache
    participant API
    participant Service
    participant Database

    Client->>Gateway: HTTP Request
    Gateway->>RateLimit: Check Rate Limit
    RateLimit-->>Gateway: Limit OK

    Gateway->>Auth: Validate Token
    Auth-->>Gateway: Token Valid

    Gateway->>Cache: Check Cache
    alt Cache Hit
        Cache-->>Gateway: Cached Response
        Gateway-->>Client: 200 OK (Cached)
    else Cache Miss
        Gateway->>API: Forward Request
        API->>Service: Process Business Logic
        Service->>Database: Query Data
        Database-->>Service: Results
        Service-->>API: Response Data
        API-->>Gateway: Response
        Gateway->>Cache: Update Cache
        Gateway-->>Client: 200 OK
    end
```

### Error Handling Flow

```mermaid
sequenceDiagram
    participant Client
    participant Gateway
    participant Auth
    participant API

    Client->>Gateway: HTTP Request
    Gateway->>Auth: Validate Token

    alt Invalid Token
        Auth-->>Gateway: Invalid
        Gateway-->>Client: 401 Unauthorized
    else Rate Limit Exceeded
        Gateway-->>Client: 429 Too Many Requests
    else Validation Error
        Gateway->>API: Forward Request
        API-->>Gateway: Validation Failed
        Gateway-->>Client: 400 Bad Request
    else Server Error
        Gateway->>API: Forward Request
        API-->>Gateway: Internal Error
        Gateway-->>Client: 500 Internal Server Error
    end
```

---

## Authentication & Authorization

### JWT Authentication Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant AuthService
    participant Database

    Client->>API: POST /auth/login (credentials)
    API->>AuthService: Validate Credentials
    AuthService->>Database: Query User
    Database-->>AuthService: User Data

    alt Valid Credentials
        AuthService->>AuthService: Generate JWT
        AuthService->>AuthService: Generate Refresh Token
        AuthService-->>API: Tokens
        API-->>Client: 200 OK (JWT + Refresh Token)
    else Invalid Credentials
        AuthService-->>API: Invalid
        API-->>Client: 401 Unauthorized
    end

    Note over Client: Store JWT in HttpOnly Cookie

    Client->>API: GET /users (with JWT)
    API->>AuthService: Verify JWT
    AuthService-->>API: JWT Valid
    API-->>Client: 200 OK (User Data)
```

### OAuth 2.0 Flow

```mermaid
sequenceDiagram
    participant User
    participant Client
    participant AuthServer
    participant API

    User->>Client: Click "Login with OAuth"
    Client->>AuthServer: Authorization Request
    AuthServer-->>User: Login Page
    User->>AuthServer: Enter Credentials
    AuthServer-->>Client: Authorization Code

    Client->>AuthServer: Exchange Code for Token
    AuthServer-->>Client: Access Token + Refresh Token

    Client->>API: Request with Access Token
    API->>AuthServer: Validate Token
    AuthServer-->>API: Token Valid
    API-->>Client: Protected Resource
```

### RBAC Authorization

```mermaid
graph TB
    REQUEST[API Request] --> AUTH_CHECK{Authenticated?}
    AUTH_CHECK -->|No| REJECT_401[401 Unauthorized]
    AUTH_CHECK -->|Yes| EXTRACT_ROLE[Extract User Role]

    EXTRACT_ROLE --> ROLE_CHECK{Role Check}
    ROLE_CHECK -->|Admin| ALLOW_ALL[Allow All Operations]
    ROLE_CHECK -->|User| CHECK_PERMISSION{Check Permission}
    ROLE_CHECK -->|Guest| ALLOW_READ[Allow Read Only]

    CHECK_PERMISSION -->|Has Permission| ALLOW[Allow Operation]
    CHECK_PERMISSION -->|No Permission| REJECT_403[403 Forbidden]

    ALLOW_ALL --> PROCESS[Process Request]
    ALLOW --> PROCESS
    ALLOW_READ --> PROCESS

    style REQUEST fill:#e1f5ff
    style AUTH_CHECK fill:#fff9e1
    style PROCESS fill:#e1ffe1
    style REJECT_401 fill:#ffe1e1
    style REJECT_403 fill:#ffe1e1
```

---

## Rate Limiting

### Rate Limit Strategy

```mermaid
graph TB
    REQUEST[Incoming Request] --> IDENTIFY[Identify Client]
    IDENTIFY --> CHECK_LIMIT{Within Limit?}

    CHECK_LIMIT -->|Yes| ALLOW[Process Request]
    CHECK_LIMIT -->|No| REJECT[429 Too Many Requests]

    ALLOW --> INCREMENT[Increment Counter]
    INCREMENT --> RESET{Window Expired?}
    RESET -->|Yes| CLEAR[Clear Counter]
    RESET -->|No| CONTINUE[Continue]

    REJECT --> RETRY_AFTER[Add Retry-After Header]

    style REQUEST fill:#e1f5ff
    style CHECK_LIMIT fill:#fff9e1
    style ALLOW fill:#e1ffe1
    style REJECT fill:#ffe1e1
```

### Rate Limit Tiers

| User Type | Requests/Minute | Requests/Hour | Requests/Day |
|-----------|----------------|---------------|--------------|
| Anonymous | 10 | 100 | 1,000 |
| Authenticated | 100 | 1,000 | 10,000 |
| Premium | 500 | 5,000 | 50,000 |
| Enterprise | Unlimited | Unlimited | Unlimited |

---

## API Versioning

### Version Strategy

```mermaid
graph LR
    CLIENT[Client] --> GATEWAY[API Gateway]

    GATEWAY --> V1[API v1 - Stable]
    GATEWAY --> V2[API v2 - Current]
    GATEWAY --> V3[API v3 - Beta]

    V1 --> DEPRECATED[Deprecated in 6 months]
    V2 --> ACTIVE[Active Support]
    V3 --> TESTING[Testing Phase]

    style CLIENT fill:#e1f5ff
    style GATEWAY fill:#fff9e1
    style V2 fill:#e1ffe1
    style V1 fill:#ffe1e1
```

### Version Migration Path

1. **v1 (Legacy)**: Deprecated, maintenance only
2. **v2 (Current)**: Active development, full support
3. **v3 (Beta)**: Testing, breaking changes allowed

---

## API Documentation

### OpenAPI/Swagger Structure

```mermaid
graph TB
    SPEC[OpenAPI Spec]

    SPEC --> INFO[API Info]
    SPEC --> SERVERS[Server URLs]
    SPEC --> PATHS[API Paths]
    SPEC --> COMPONENTS[Components]
    SPEC --> SECURITY[Security Schemes]

    PATHS --> ENDPOINT1[/users]
    PATHS --> ENDPOINT2[/products]
    PATHS --> ENDPOINT3[/orders]

    COMPONENTS --> SCHEMAS[Data Schemas]
    COMPONENTS --> RESPONSES[Response Templates]
    COMPONENTS --> PARAMS[Parameters]

    SECURITY --> JWT[JWT Auth]
    SECURITY --> OAUTH[OAuth 2.0]
    SECURITY --> API_KEY[API Keys]

    style SPEC fill:#e1f5ff
    style PATHS fill:#fff9e1
    style COMPONENTS fill:#e1ffe1
```

---

## API Endpoints Reference

### Authentication Endpoints

#### POST /api/v1/auth/login
**Description**: Authenticate user and obtain tokens

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

#### POST /api/v1/auth/refresh
**Description**: Refresh access token using refresh token

#### POST /api/v1/auth/logout
**Description**: Invalidate tokens and logout user

---

### User Endpoints

#### GET /api/v1/users
**Description**: List all users (paginated)

**Query Parameters**:
- `page` (integer): Page number (default: 1)
- `limit` (integer): Items per page (default: 20)
- `sort` (string): Sort field (default: created_at)
- `order` (string): Sort order - asc/desc (default: desc)

**Response** (200 OK):
```json
{
  "data": [
    {
      "id": "user-123",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "user",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}
```

#### GET /api/v1/users/:id
**Description**: Get user by ID

#### POST /api/v1/users
**Description**: Create new user

#### PUT /api/v1/users/:id
**Description**: Update user

#### DELETE /api/v1/users/:id
**Description**: Delete user

---

### Product Endpoints

#### GET /api/v1/products
**Description**: List all products

#### POST /api/v1/products
**Description**: Create new product

#### GET /api/v1/products/:id
**Description**: Get product details

#### PUT /api/v1/products/:id
**Description**: Update product

---

### Order Endpoints

#### GET /api/v1/orders
**Description**: List user's orders

#### POST /api/v1/orders
**Description**: Create new order

#### GET /api/v1/orders/:id
**Description**: Get order details

#### POST /api/v1/orders/:id/cancel
**Description**: Cancel order

---

## Error Responses

### Standard Error Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ],
    "request_id": "req-123456",
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

### HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST (resource created) |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input data |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource conflict (duplicate) |
| 422 | Unprocessable Entity | Validation failed |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily unavailable |

---

## Caching Strategy

### Cache Layers

```mermaid
graph TB
    REQUEST[API Request] --> CDN{CDN Cache}
    CDN -->|Hit| RETURN_CDN[Return from CDN]
    CDN -->|Miss| GATEWAY[API Gateway Cache]

    GATEWAY -->|Hit| RETURN_GATEWAY[Return from Gateway]
    GATEWAY -->|Miss| APP[Application Cache]

    APP -->|Hit| RETURN_APP[Return from App Cache]
    APP -->|Miss| DATABASE[Query Database]

    DATABASE --> UPDATE_APP[Update App Cache]
    UPDATE_APP --> UPDATE_GATEWAY[Update Gateway Cache]
    UPDATE_GATEWAY --> UPDATE_CDN[Update CDN]
    UPDATE_CDN --> RETURN_DB[Return Data]

    style REQUEST fill:#e1f5ff
    style CDN fill:#fff9e1
    style GATEWAY fill:#e1ffe1
    style DATABASE fill:#ffe1e1
```

### Cache Control Headers

```http
Cache-Control: public, max-age=3600
Cache-Control: private, max-age=300
Cache-Control: no-cache
Cache-Control: no-store
```

---

## API Performance Optimization

### Response Compression

```mermaid
graph LR
    API[API Server] --> COMPRESS{Response Size > 1KB?}
    COMPRESS -->|Yes| GZIP[GZIP Compression]
    COMPRESS -->|No| SEND[Send Uncompressed]

    GZIP --> ADD_HEADER[Add Content-Encoding: gzip]
    ADD_HEADER --> SEND_COMPRESSED[Send Compressed]

    style API fill:#e1f5ff
    style GZIP fill:#e1ffe1
```

### Field Selection

```http
GET /api/v1/users?fields=id,name,email
```

Response includes only requested fields, reducing payload size.

---

## WebSocket API

### WebSocket Connection Flow

```mermaid
sequenceDiagram
    participant Client
    participant WSGateway
    participant Auth
    participant EventBus

    Client->>WSGateway: WS Connect (with token)
    WSGateway->>Auth: Validate Token
    Auth-->>WSGateway: Token Valid
    WSGateway-->>Client: Connection Established

    Client->>WSGateway: Subscribe to Channel
    WSGateway->>EventBus: Register Subscription
    EventBus-->>WSGateway: Subscription Confirmed

    EventBus->>WSGateway: New Event
    WSGateway->>Client: Push Event

    Client->>WSGateway: Unsubscribe
    WSGateway->>EventBus: Remove Subscription

    Client->>WSGateway: Close Connection
    WSGateway-->>Client: Connection Closed
```

---

## API Monitoring

### Metrics Collection

```mermaid
graph TB
    API[API Requests] --> METRICS[Metrics Collector]
    METRICS --> RATE[Request Rate]
    METRICS --> LATENCY[Response Latency]
    METRICS --> ERRORS[Error Rate]
    METRICS --> STATUS[Status Codes]

    RATE --> DASHBOARD[Monitoring Dashboard]
    LATENCY --> DASHBOARD
    ERRORS --> DASHBOARD
    STATUS --> DASHBOARD

    DASHBOARD --> ALERTS[Alert System]

    style API fill:#e1f5ff
    style METRICS fill:#fff9e1
    style DASHBOARD fill:#e1ffe1
    style ALERTS fill:#ffe1e1
```

### Key API Metrics

- **Request Rate**: Requests per second
- **Response Time**: P50, P95, P99 latency
- **Error Rate**: Percentage of 4xx and 5xx responses
- **Throughput**: Bytes per second
- **Active Connections**: Current WebSocket connections

---

## References

- [Architecture Overview](./overview.md)
- [Component Architecture](./components.md)
- [Security Architecture](./security.md)

---

**Document Version**: 1.0.0
**Last Review**: [Date]

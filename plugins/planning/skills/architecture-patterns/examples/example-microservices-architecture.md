# Example: Microservices Architecture

> **Example Architecture**: Event-driven microservices with API gateway
> **Last Updated**: 2025-01-01

## Overview

This example demonstrates a production microservices architecture with API gateway, service mesh, event-driven communication, and centralized monitoring.

---

## Technology Stack

### Core Services
- **API Gateway**: Kong / AWS API Gateway
- **Service Mesh**: Istio / Linkerd
- **Service Registry**: Consul / Eureka
- **Event Bus**: Kafka / RabbitMQ

### Services Stack
- **User Service**: Node.js (Express)
- **Order Service**: Python (FastAPI)
- **Product Service**: Go
- **Payment Service**: Node.js (Express)
- **Notification Service**: Python (FastAPI)

### Infrastructure
- **Orchestration**: Kubernetes
- **Service Discovery**: Consul
- **Config Management**: Consul KV / etcd
- **Monitoring**: Prometheus + Grafana
- **Tracing**: Jaeger / Zipkin
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)

---

## High-Level Architecture

```mermaid
graph TB
    subgraph "External Layer"
        CLIENT[Clients]
        CDN[CDN]
    end

    subgraph "Gateway Layer"
        API_GW[API Gateway]
        AUTH[Auth Service]
        RATE_LIMIT[Rate Limiter]
    end

    subgraph "Service Layer"
        USER_SVC[User Service]
        ORDER_SVC[Order Service]
        PRODUCT_SVC[Product Service]
        PAYMENT_SVC[Payment Service]
        NOTIFY_SVC[Notification Service]
    end

    subgraph "Communication Layer"
        KAFKA[Kafka Event Bus]
        SERVICE_MESH[Service Mesh - Istio]
    end

    subgraph "Data Layer"
        USER_DB[(Users DB)]
        ORDER_DB[(Orders DB)]
        PRODUCT_DB[(Products DB)]
    end

    subgraph "Infrastructure"
        SERVICE_REGISTRY[Service Registry]
        CONFIG[Config Service]
        MONITORING[Monitoring Stack]
    end

    CLIENT --> CDN
    CDN --> API_GW
    API_GW --> RATE_LIMIT
    RATE_LIMIT --> AUTH

    AUTH --> USER_SVC
    AUTH --> ORDER_SVC
    AUTH --> PRODUCT_SVC
    AUTH --> PAYMENT_SVC

    ORDER_SVC --> KAFKA
    PAYMENT_SVC --> KAFKA
    KAFKA --> NOTIFY_SVC

    USER_SVC --> SERVICE_MESH
    ORDER_SVC --> SERVICE_MESH
    PRODUCT_SVC --> SERVICE_MESH
    PAYMENT_SVC --> SERVICE_MESH
    NOTIFY_SVC --> SERVICE_MESH

    USER_SVC --> USER_DB
    ORDER_SVC --> ORDER_DB
    PRODUCT_SVC --> PRODUCT_DB

    SERVICE_MESH --> SERVICE_REGISTRY
    SERVICE_MESH --> CONFIG
    SERVICE_MESH --> MONITORING

    style CLIENT fill:#e1f5ff
    style API_GW fill:#fff9e1
    style KAFKA fill:#e1ffe1
    style USER_DB fill:#ffe1e1
```

---

## Service Communication Patterns

### Synchronous Communication (REST)

```mermaid
sequenceDiagram
    participant Client
    participant Gateway
    participant OrderSvc
    participant ProductSvc
    participant UserSvc

    Client->>Gateway: POST /orders
    Gateway->>OrderSvc: Create Order
    OrderSvc->>ProductSvc: GET /products/:id (Check Stock)
    ProductSvc-->>OrderSvc: Product Details
    OrderSvc->>UserSvc: GET /users/:id (Validate User)
    UserSvc-->>OrderSvc: User Details
    OrderSvc->>OrderSvc: Create Order Record
    OrderSvc-->>Gateway: Order Created
    Gateway-->>Client: 201 Created
```

### Asynchronous Communication (Events)

```mermaid
sequenceDiagram
    participant OrderSvc
    participant Kafka
    participant PaymentSvc
    participant NotifySvc
    participant EmailSvc

    OrderSvc->>Kafka: Publish OrderCreated Event
    Kafka-->>OrderSvc: Event Published

    Kafka->>PaymentSvc: Deliver Event
    PaymentSvc->>PaymentSvc: Process Payment
    PaymentSvc->>Kafka: Publish PaymentProcessed Event

    Kafka->>NotifySvc: Deliver PaymentProcessed
    NotifySvc->>EmailSvc: Send Email
    NotifySvc->>NotifySvc: Create Notification

    Kafka->>OrderSvc: Deliver PaymentProcessed
    OrderSvc->>OrderSvc: Update Order Status
```

---

## API Gateway Pattern

### Gateway Responsibilities

```mermaid
graph TB
    REQUEST[Incoming Request] --> GATEWAY[API Gateway]

    GATEWAY --> ROUTE[Routing]
    GATEWAY --> AUTH[Authentication]
    GATEWAY --> RATE_LIMIT[Rate Limiting]
    GATEWAY --> TRANSFORM[Request/Response Transform]
    GATEWAY --> CACHE[Response Caching]
    GATEWAY --> METRICS[Metrics Collection]

    ROUTE --> SERVICE_A[Service A]
    ROUTE --> SERVICE_B[Service B]
    ROUTE --> SERVICE_C[Service C]

    SERVICE_A --> AGGREGATE[Response Aggregation]
    SERVICE_B --> AGGREGATE
    SERVICE_C --> AGGREGATE

    AGGREGATE --> RESPONSE[Final Response]

    style REQUEST fill:#e1f5ff
    style GATEWAY fill:#fff9e1
    style AGGREGATE fill:#e1ffe1
    style RESPONSE fill:#d4edda
```

---

## Service Mesh Architecture

### Istio Service Mesh

```mermaid
graph TB
    subgraph "Service A Pod"
        APP_A[Application Container]
        PROXY_A[Envoy Sidecar Proxy]
    end

    subgraph "Service B Pod"
        APP_B[Application Container]
        PROXY_B[Envoy Sidecar Proxy]
    end

    subgraph "Control Plane"
        PILOT[Pilot - Traffic Management]
        CITADEL[Citadel - Security]
        GALLEY[Galley - Configuration]
        TELEMETRY[Telemetry]
    end

    APP_A --> PROXY_A
    PROXY_A --> PROXY_B
    PROXY_B --> APP_B

    PILOT -.->|Config| PROXY_A
    PILOT -.->|Config| PROXY_B

    CITADEL -.->|Certs| PROXY_A
    CITADEL -.->|Certs| PROXY_B

    PROXY_A -.->|Metrics| TELEMETRY
    PROXY_B -.->|Metrics| TELEMETRY

    style APP_A fill:#e1f5ff
    style PROXY_A fill:#fff9e1
    style PILOT fill:#e1ffe1
```

---

## Event-Driven Architecture

### Kafka Event Bus

```mermaid
graph LR
    subgraph "Producers"
        ORDER[Order Service]
        PAYMENT[Payment Service]
        USER[User Service]
    end

    subgraph "Kafka Cluster"
        TOPIC_ORDER[orders Topic]
        TOPIC_PAYMENT[payments Topic]
        TOPIC_USER[users Topic]
    end

    subgraph "Consumers"
        NOTIFY[Notification Service]
        ANALYTICS[Analytics Service]
        AUDIT[Audit Service]
    end

    ORDER --> TOPIC_ORDER
    PAYMENT --> TOPIC_PAYMENT
    USER --> TOPIC_USER

    TOPIC_ORDER --> NOTIFY
    TOPIC_ORDER --> ANALYTICS
    TOPIC_ORDER --> AUDIT

    TOPIC_PAYMENT --> NOTIFY
    TOPIC_PAYMENT --> ANALYTICS
    TOPIC_PAYMENT --> AUDIT

    style ORDER fill:#e1f5ff
    style TOPIC_ORDER fill:#fff9e1
    style NOTIFY fill:#e1ffe1
```

### Event Schema

```json
{
  "event_id": "uuid-v4",
  "event_type": "order.created",
  "event_version": "1.0",
  "timestamp": "2025-01-01T00:00:00Z",
  "source": "order-service",
  "data": {
    "order_id": "ord-123",
    "user_id": "usr-456",
    "total_amount": 99.99,
    "items": [
      {
        "product_id": "prd-789",
        "quantity": 2,
        "price": 49.99
      }
    ]
  },
  "metadata": {
    "correlation_id": "req-abc",
    "trace_id": "trace-xyz"
  }
}
```

---

## Database Per Service Pattern

### Service-Specific Databases

```mermaid
graph TB
    subgraph "User Service"
        USER_API[User API]
        USER_DB[(PostgreSQL)]
    end

    subgraph "Order Service"
        ORDER_API[Order API]
        ORDER_DB[(MongoDB)]
    end

    subgraph "Product Service"
        PRODUCT_API[Product API]
        PRODUCT_DB[(PostgreSQL)]
    end

    subgraph "Payment Service"
        PAYMENT_API[Payment API]
        PAYMENT_DB[(MySQL)]
    end

    USER_API --> USER_DB
    ORDER_API --> ORDER_DB
    PRODUCT_API --> PRODUCT_DB
    PAYMENT_API --> PAYMENT_DB

    style USER_DB fill:#ffe1e1
    style ORDER_DB fill:#fff9e1
    style PRODUCT_DB fill:#e1ffe1
    style PAYMENT_DB fill:#f5e1ff
```

---

## Saga Pattern for Distributed Transactions

### Choreography-Based Saga

```mermaid
sequenceDiagram
    participant OrderSvc
    participant Kafka
    participant PaymentSvc
    participant InventorySvc
    participant ShippingSvc

    OrderSvc->>Kafka: OrderCreated
    Kafka->>PaymentSvc: Process Payment
    PaymentSvc->>Kafka: PaymentCompleted

    Kafka->>InventorySvc: Reserve Inventory
    InventorySvc->>Kafka: InventoryReserved

    Kafka->>ShippingSvc: Schedule Shipping
    ShippingSvc->>Kafka: ShippingScheduled

    Kafka->>OrderSvc: Update Order Status

    Note over OrderSvc,ShippingSvc: Compensation Flow (if failure)

    alt Payment Failed
        PaymentSvc->>Kafka: PaymentFailed
        Kafka->>OrderSvc: Cancel Order
    end
```

---

## Service Discovery

### Consul Service Registry

```mermaid
graph TB
    subgraph "Services"
        USER_SVC_1[User Service - Instance 1]
        USER_SVC_2[User Service - Instance 2]
        ORDER_SVC[Order Service]
    end

    subgraph "Service Registry (Consul)"
        REGISTRY[Service Registry]
        HEALTH[Health Checks]
    end

    USER_SVC_1 -->|Register| REGISTRY
    USER_SVC_2 -->|Register| REGISTRY
    ORDER_SVC -->|Register| REGISTRY

    HEALTH -.->|Health Check| USER_SVC_1
    HEALTH -.->|Health Check| USER_SVC_2
    HEALTH -.->|Health Check| ORDER_SVC

    ORDER_SVC -->|Discover| REGISTRY
    REGISTRY -->|Service Locations| ORDER_SVC

    style REGISTRY fill:#e1f5ff
    style HEALTH fill:#fff9e1
    style ORDER_SVC fill:#e1ffe1
```

---

## Circuit Breaker Pattern

### Resilience Pattern

```mermaid
stateDiagram-v2
    [*] --> Closed: Initial State
    Closed --> Open: Failure Threshold Exceeded
    Open --> HalfOpen: Timeout Elapsed
    HalfOpen --> Closed: Success
    HalfOpen --> Open: Failure

    note right of Closed
        Requests flow normally
        Track failures
    end note

    note right of Open
        Requests fail immediately
        Wait for timeout
    end note

    note right of HalfOpen
        Allow limited requests
        Test if service recovered
    end note
```

---

## Distributed Tracing

### Request Tracing with Jaeger

```mermaid
sequenceDiagram
    participant Client
    participant Gateway
    participant OrderSvc
    participant ProductSvc
    participant PaymentSvc
    participant Jaeger

    Note over Client,Jaeger: Trace ID: trace-xyz

    Client->>Gateway: Request [trace-xyz]
    Gateway->>Jaeger: Span: gateway-ingress
    Gateway->>OrderSvc: Request [trace-xyz, span-1]
    OrderSvc->>Jaeger: Span: order-create

    OrderSvc->>ProductSvc: Request [trace-xyz, span-2]
    ProductSvc->>Jaeger: Span: product-get

    OrderSvc->>PaymentSvc: Request [trace-xyz, span-3]
    PaymentSvc->>Jaeger: Span: payment-process

    Note over Jaeger: Trace Complete<br/>Latency: 250ms
```

---

## Monitoring & Observability

### Observability Stack

```mermaid
graph TB
    subgraph "Services"
        SERVICES[Microservices]
    end

    subgraph "Metrics"
        PROMETHEUS[Prometheus]
        GRAFANA[Grafana Dashboards]
    end

    subgraph "Logging"
        FLUENTD[Fluentd]
        ELASTICSEARCH[Elasticsearch]
        KIBANA[Kibana]
    end

    subgraph "Tracing"
        JAEGER[Jaeger]
    end

    subgraph "Alerting"
        ALERTMANAGER[Alert Manager]
        PAGERDUTY[PagerDuty]
    end

    SERVICES --> PROMETHEUS
    SERVICES --> FLUENTD
    SERVICES --> JAEGER

    PROMETHEUS --> GRAFANA
    PROMETHEUS --> ALERTMANAGER

    FLUENTD --> ELASTICSEARCH
    ELASTICSEARCH --> KIBANA

    ALERTMANAGER --> PAGERDUTY

    style SERVICES fill:#e1f5ff
    style PROMETHEUS fill:#fff9e1
    style GRAFANA fill:#e1ffe1
    style JAEGER fill:#ffe1e1
```

---

## Deployment Architecture

### Kubernetes Deployment

```mermaid
graph TB
    subgraph "Kubernetes Cluster"
        subgraph "Namespace: Production"
            INGRESS[Ingress Controller]

            subgraph "User Service Deployment"
                USER_POD1[Pod 1]
                USER_POD2[Pod 2]
                USER_SVC_K8S[Service]
            end

            subgraph "Order Service Deployment"
                ORDER_POD1[Pod 1]
                ORDER_POD2[Pod 2]
                ORDER_SVC_K8S[Service]
            end

            subgraph "Product Service Deployment"
                PRODUCT_POD1[Pod 1]
                PRODUCT_POD2[Pod 2]
                PRODUCT_SVC_K8S[Service]
            end
        end

        subgraph "Shared Services"
            KAFKA_CLUSTER[Kafka Cluster]
            MONITORING[Monitoring Stack]
        end
    end

    USERS[External Users] --> INGRESS
    INGRESS --> USER_SVC_K8S
    INGRESS --> ORDER_SVC_K8S
    INGRESS --> PRODUCT_SVC_K8S

    USER_SVC_K8S --> USER_POD1
    USER_SVC_K8S --> USER_POD2

    ORDER_SVC_K8S --> ORDER_POD1
    ORDER_SVC_K8S --> ORDER_POD2

    PRODUCT_SVC_K8S --> PRODUCT_POD1
    PRODUCT_SVC_K8S --> PRODUCT_POD2

    ORDER_POD1 --> KAFKA_CLUSTER
    ORDER_POD2 --> KAFKA_CLUSTER

    USER_POD1 -.->|Metrics| MONITORING
    ORDER_POD1 -.->|Metrics| MONITORING
    PRODUCT_POD1 -.->|Metrics| MONITORING

    style USERS fill:#e1f5ff
    style INGRESS fill:#fff9e1
    style KAFKA_CLUSTER fill:#e1ffe1
    style MONITORING fill:#ffe1e1
```

---

## Security Architecture

### Service-to-Service Authentication

```mermaid
graph TB
    SERVICE_A[Service A] --> MTLS[Mutual TLS]
    MTLS --> SERVICE_B[Service B]

    SERVICE_A -.->|Request Certificate| CERT_AUTHORITY[Certificate Authority]
    SERVICE_B -.->|Request Certificate| CERT_AUTHORITY

    CERT_AUTHORITY -.->|Issue Cert| SERVICE_A
    CERT_AUTHORITY -.->|Issue Cert| SERVICE_B

    style SERVICE_A fill:#e1f5ff
    style MTLS fill:#fff9e1
    style SERVICE_B fill:#e1ffe1
    style CERT_AUTHORITY fill:#ffe1e1
```

---

## Key Takeaways

1. **API Gateway**: Centralize cross-cutting concerns
2. **Service Mesh**: Handle service-to-service communication
3. **Event-Driven**: Use asynchronous communication for loose coupling
4. **Database Per Service**: Each service owns its data
5. **Circuit Breaker**: Implement resilience patterns
6. **Distributed Tracing**: Track requests across services
7. **Service Discovery**: Dynamic service location
8. **Saga Pattern**: Handle distributed transactions

---

## Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Distributed Transactions | Saga pattern (choreography/orchestration) |
| Service Discovery | Consul / Kubernetes DNS |
| Data Consistency | Event sourcing + CQRS |
| Network Latency | Caching, async communication |
| Debugging | Distributed tracing (Jaeger) |
| Monitoring | Centralized logging + metrics |
| Security | mTLS + API Gateway auth |

---

## References

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Istio Service Mesh](https://istio.io/latest/docs/)
- [Apache Kafka](https://kafka.apache.org/documentation/)
- [Microservices Patterns](https://microservices.io/patterns/)

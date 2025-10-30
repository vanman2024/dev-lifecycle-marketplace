# Example: Full Stack Architecture (Next.js + FastAPI)

> **Example Architecture**: Complete full-stack application with Next.js frontend and FastAPI backend
> **Last Updated**: 2025-01-01

## Overview

This example demonstrates a production-ready full-stack architecture combining Next.js 15 (frontend) with FastAPI (backend), PostgreSQL database, Redis caching, and modern deployment practices.

---

## Technology Stack

### Frontend
- Next.js 15 (App Router)
- React 19 (Server Components)
- Tailwind CSS + shadcn/ui
- TanStack Query (React Query)

### Backend
- FastAPI (Python 3.12+)
- SQLAlchemy 2.0 (async)
- Pydantic v2

### Infrastructure
- PostgreSQL 16
- Redis 7
- Docker + Docker Compose
- Nginx (reverse proxy)

---

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client Browser"
        BROWSER[Web Browser]
    end

    subgraph "Frontend - Next.js"
        SSR[Server Components]
        CLIENT[Client Components]
        API_CLIENT[API Client Layer]
    end

    subgraph "API Gateway"
        NGINX[Nginx Reverse Proxy]
    end

    subgraph "Backend - FastAPI"
        API[FastAPI Routes]
        SERVICES[Service Layer]
        REPOS[Repositories]
    end

    subgraph "Data Layer"
        POSTGRES[(PostgreSQL)]
        REDIS[(Redis Cache)]
    end

    BROWSER --> SSR
    BROWSER --> CLIENT
    CLIENT --> API_CLIENT
    SSR --> API_CLIENT
    API_CLIENT --> NGINX
    NGINX --> API
    API --> SERVICES
    SERVICES --> REPOS
    REPOS --> POSTGRES
    SERVICES --> REDIS

    style BROWSER fill:#e1f5ff
    style NGINX fill:#fff9e1
    style API fill:#e1ffe1
    style POSTGRES fill:#ffe1e1
```

---

## Authentication Flow

### JWT Authentication with Refresh Tokens

```mermaid
sequenceDiagram
    participant User
    participant NextJS
    participant FastAPI
    participant Database

    User->>NextJS: Submit Login Form
    NextJS->>FastAPI: POST /api/auth/login
    FastAPI->>Database: Verify Credentials
    Database-->>FastAPI: User Valid
    FastAPI->>FastAPI: Generate JWT + Refresh Token
    FastAPI-->>NextJS: Access Token + Refresh Token
    NextJS->>NextJS: Store in HttpOnly Cookies
    NextJS-->>User: Redirect to Dashboard

    Note over NextJS,FastAPI: Protected Request Flow

    User->>NextJS: Access Protected Page
    NextJS->>FastAPI: GET /api/users/me (+ JWT Cookie)
    FastAPI->>FastAPI: Verify JWT
    FastAPI-->>NextJS: User Data
    NextJS-->>User: Render Page with Data
```

---

## API Communication

### Frontend API Client

```typescript
// lib/api-client.ts
class APIClient {
  private baseURL = process.env.NEXT_PUBLIC_API_URL;

  async request<T>(
    endpoint: string,
    options?: RequestInit
  ): Promise<T> {
    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      credentials: 'include', // Send cookies
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
    });

    if (!response.ok) {
      throw new Error(`API Error: ${response.statusText}`);
    }

    return response.json();
  }

  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  async post<T>(endpoint: string, data: unknown): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }
}

export const apiClient = new APIClient();
```

---

## Data Flow

### Server-Side Rendering with API Data

```mermaid
sequenceDiagram
    participant Browser
    participant NextServer
    participant RSC
    participant FastAPI
    participant Database

    Browser->>NextServer: Request /dashboard
    NextServer->>RSC: Render Server Component
    RSC->>FastAPI: GET /api/posts (server-side)
    FastAPI->>Database: Query Posts
    Database-->>FastAPI: Results
    FastAPI-->>RSC: Posts JSON
    RSC->>RSC: Render with Data
    RSC-->>NextServer: HTML + RSC Payload
    NextServer-->>Browser: Streamed Response
```

### Client-Side Data Fetching with React Query

```typescript
// app/hooks/use-posts.ts
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';

export function usePosts() {
  return useQuery({
    queryKey: ['posts'],
    queryFn: () => apiClient.get('/api/posts'),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

// app/components/posts-list.tsx
'use client';

export function PostsList() {
  const { data: posts, isLoading } = usePosts();

  if (isLoading) return <Skeleton />;

  return (
    <div>
      {posts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  );
}
```

---

## Caching Strategy

### Multi-Layer Caching

```mermaid
graph TB
    REQUEST[Request] --> NEXT_CACHE{Next.js Cache}
    NEXT_CACHE -->|Hit| SERVE_NEXT[Serve from Next.js]
    NEXT_CACHE -->|Miss| API_REQUEST[API Request]

    API_REQUEST --> REDIS_CACHE{Redis Cache}
    REDIS_CACHE -->|Hit| SERVE_REDIS[Return Cached]
    REDIS_CACHE -->|Miss| DATABASE[Query PostgreSQL]

    DATABASE --> STORE_REDIS[Store in Redis]
    STORE_REDIS --> STORE_NEXT[Cache in Next.js]
    STORE_NEXT --> RETURN[Return Data]

    SERVE_REDIS --> STORE_NEXT

    style REQUEST fill:#e1f5ff
    style NEXT_CACHE fill:#fff9e1
    style REDIS_CACHE fill:#e1ffe1
    style DATABASE fill:#ffe1e1
```

---

## Docker Deployment

### Docker Compose Architecture

```yaml
version: '3.8'

services:
  # Frontend - Next.js
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://nginx/api
    depends_on:
      - nginx

  # Backend - FastAPI
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/db
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis

  # Reverse Proxy - Nginx
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - frontend
      - backend

  # Database - PostgreSQL
  postgres:
    image: postgres:16
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=db
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # Cache - Redis
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Deployment Diagram

```mermaid
graph TB
    subgraph "Docker Network"
        subgraph "Frontend Container"
            NEXTJS[Next.js Server - Port 3000]
        end

        subgraph "Backend Container"
            FASTAPI[FastAPI Server - Port 8000]
        end

        subgraph "Nginx Container"
            NGINX[Nginx - Port 80]
        end

        subgraph "Database Container"
            POSTGRES[(PostgreSQL - Port 5432)]
        end

        subgraph "Cache Container"
            REDIS[(Redis - Port 6379)]
        end
    end

    USERS[External Users] --> NGINX
    NGINX -->|/| NEXTJS
    NGINX -->|/api| FASTAPI
    NEXTJS -.->|SSR API Calls| NGINX
    FASTAPI --> POSTGRES
    FASTAPI --> REDIS

    style USERS fill:#e1f5ff
    style NGINX fill:#fff9e1
    style FASTAPI fill:#e1ffe1
    style POSTGRES fill:#ffe1e1
```

---

## API Contract

### RESTful API Design

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| /api/auth/login | POST | User login | No |
| /api/auth/register | POST | User registration | No |
| /api/auth/refresh | POST | Refresh access token | Yes (Refresh Token) |
| /api/users/me | GET | Get current user | Yes |
| /api/users/:id | GET | Get user by ID | Yes |
| /api/posts | GET | List posts | No |
| /api/posts | POST | Create post | Yes |
| /api/posts/:id | GET | Get post by ID | No |
| /api/posts/:id | PUT | Update post | Yes (Owner) |
| /api/posts/:id | DELETE | Delete post | Yes (Owner) |

---

## Error Handling

### Centralized Error Handling

```typescript
// Frontend - Error Handler
export function handleAPIError(error: unknown) {
  if (error instanceof Response) {
    if (error.status === 401) {
      // Redirect to login
      window.location.href = '/login';
    } else if (error.status === 403) {
      // Show permission error
      toast.error('You do not have permission to perform this action');
    } else if (error.status >= 500) {
      // Server error
      toast.error('Server error. Please try again later.');
    }
  }
}

// Backend - Error Response
from fastapi import HTTPException

raise HTTPException(
    status_code=400,
    detail={
        "error": "VALIDATION_ERROR",
        "message": "Invalid input data",
        "fields": {
            "email": "Invalid email format"
        }
    }
)
```

---

## Real-Time Features

### WebSocket Integration

```mermaid
sequenceDiagram
    participant Client
    participant NextJS
    participant FastAPI
    participant Redis

    Client->>NextJS: Open WebSocket
    NextJS->>FastAPI: WS Connect /ws
    FastAPI-->>NextJS: Connection Established
    NextJS-->>Client: Connected

    FastAPI->>Redis: Subscribe to Channel
    Redis->>FastAPI: New Message
    FastAPI->>NextJS: Push Update
    NextJS->>Client: Update UI
```

---

## Performance Optimizations

### Frontend Optimizations
1. Server Components for zero JS
2. Image optimization with next/image
3. Code splitting with dynamic imports
4. Streaming with Suspense

### Backend Optimizations
1. Database connection pooling
2. Redis caching layer
3. Query optimization with indexes
4. Async/await for I/O operations

### Network Optimizations
1. HTTP/2 enabled in Nginx
2. Gzip compression
3. CDN for static assets
4. API response compression

---

## Monitoring

### Observability Stack

```mermaid
graph TB
    subgraph "Application"
        NEXTJS[Next.js]
        FASTAPI[FastAPI]
    end

    subgraph "Monitoring"
        PROMETHEUS[Prometheus]
        GRAFANA[Grafana]
        LOKI[Loki - Logs]
    end

    subgraph "Alerts"
        ALERTMANAGER[Alert Manager]
        PAGERDUTY[PagerDuty]
    end

    NEXTJS --> PROMETHEUS
    FASTAPI --> PROMETHEUS
    NEXTJS --> LOKI
    FASTAPI --> LOKI

    PROMETHEUS --> GRAFANA
    LOKI --> GRAFANA

    PROMETHEUS --> ALERTMANAGER
    ALERTMANAGER --> PAGERDUTY

    style NEXTJS fill:#e1f5ff
    style PROMETHEUS fill:#fff9e1
    style GRAFANA fill:#e1ffe1
```

---

## Key Takeaways

1. **Separate Concerns**: Keep frontend and backend codebases separate
2. **API Gateway**: Use Nginx for routing and load balancing
3. **Consistent Auth**: Use HttpOnly cookies for secure authentication
4. **Caching Layers**: Implement caching at multiple levels
5. **Docker**: Containerize all services for easy deployment
6. **Type Safety**: Use TypeScript + Pydantic for end-to-end type safety
7. **Monitoring**: Implement comprehensive observability from day one

---

## References

- [Next.js Documentation](https://nextjs.org/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

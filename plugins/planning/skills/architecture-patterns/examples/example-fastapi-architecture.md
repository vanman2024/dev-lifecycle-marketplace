# Example: FastAPI Backend Architecture

> **Example Architecture**: Production-ready FastAPI backend with PostgreSQL
> **Last Updated**: 2025-01-01

## Overview

This example demonstrates a complete architecture for a FastAPI application following clean architecture principles, with async/await patterns, dependency injection, and modern best practices.

---

## Technology Stack

### Backend Framework
- **Framework**: FastAPI 0.110+
- **Python**: Python 3.12+
- **ASGI Server**: Uvicorn with Gunicorn
- **Async**: asyncio with async/await

### Database & ORM
- **Database**: PostgreSQL 16
- **ORM**: SQLAlchemy 2.0 (async)
- **Migrations**: Alembic
- **Connection Pooling**: asyncpg

### Authentication & Security
- **Authentication**: JWT with refresh tokens
- **Password Hashing**: bcrypt via passlib
- **Authorization**: Role-based access control (RBAC)
- **CORS**: FastAPI CORS middleware

### Additional Tools
- **Validation**: Pydantic v2
- **Task Queue**: Celery + Redis
- **Caching**: Redis
- **Monitoring**: Prometheus + Grafana
- **Testing**: pytest + pytest-asyncio

---

## High-Level Architecture

```mermaid
graph TB
    subgraph "API Layer"
        ROUTES[API Routes]
        MIDDLEWARE[Middleware Stack]
        DEPENDENCIES[Dependency Injection]
    end

    subgraph "Business Logic Layer"
        SERVICES[Service Layer]
        VALIDATORS[Validators]
        BUSINESS[Business Rules]
    end

    subgraph "Data Access Layer"
        REPOSITORIES[Repository Pattern]
        ORM[SQLAlchemy ORM]
        MODELS[Database Models]
    end

    subgraph "Infrastructure"
        DB[(PostgreSQL)]
        CACHE[(Redis Cache)]
        QUEUE[Celery Queue]
        WORKER[Background Workers]
    end

    CLIENT[API Client] --> MIDDLEWARE
    MIDDLEWARE --> ROUTES
    ROUTES --> DEPENDENCIES
    DEPENDENCIES --> SERVICES

    SERVICES --> VALIDATORS
    SERVICES --> BUSINESS
    SERVICES --> REPOSITORIES

    REPOSITORIES --> ORM
    ORM --> MODELS
    MODELS --> DB

    SERVICES --> CACHE
    SERVICES --> QUEUE
    QUEUE --> WORKER
    WORKER --> DB

    style CLIENT fill:#e1f5ff
    style ROUTES fill:#fff9e1
    style SERVICES fill:#e1ffe1
    style DB fill:#ffe1e1
```

---

## Project Structure

```
app/
├── api/                      # API layer
│   ├── __init__.py
│   ├── deps.py              # Dependencies
│   ├── v1/                  # API v1
│   │   ├── __init__.py
│   │   ├── routes/
│   │   │   ├── auth.py
│   │   │   ├── users.py
│   │   │   ├── posts.py
│   │   │   └── health.py
│   │   └── router.py
│   └── middleware/
│       ├── auth.py
│       ├── cors.py
│       └── logging.py
├── core/                    # Core configuration
│   ├── __init__.py
│   ├── config.py           # Settings
│   ├── security.py         # Auth utils
│   └── database.py         # DB connection
├── models/                  # SQLAlchemy models
│   ├── __init__.py
│   ├── user.py
│   ├── post.py
│   └── base.py
├── schemas/                 # Pydantic schemas
│   ├── __init__.py
│   ├── user.py
│   ├── post.py
│   └── token.py
├── services/               # Business logic
│   ├── __init__.py
│   ├── user_service.py
│   ├── post_service.py
│   └── auth_service.py
├── repositories/           # Data access
│   ├── __init__.py
│   ├── base.py
│   ├── user_repository.py
│   └── post_repository.py
├── tasks/                  # Celery tasks
│   ├── __init__.py
│   ├── email.py
│   └── notifications.py
├── utils/                  # Utilities
│   ├── __init__.py
│   ├── cache.py
│   └── validators.py
├── tests/
│   ├── conftest.py
│   ├── test_auth.py
│   └── test_users.py
├── alembic/               # Database migrations
│   └── versions/
├── main.py                # Application entry
└── worker.py              # Celery worker
```

---

## Layered Architecture

### Clean Architecture Layers

```mermaid
graph TB
    subgraph "Presentation Layer"
        API[FastAPI Routes]
        DEPS[Dependencies]
        MIDDLEWARE[Middleware]
    end

    subgraph "Application Layer"
        SERVICES[Services]
        USE_CASES[Use Cases]
        DTOs[DTOs/Schemas]
    end

    subgraph "Domain Layer"
        ENTITIES[Domain Entities]
        BUSINESS_RULES[Business Rules]
        INTERFACES[Repository Interfaces]
    end

    subgraph "Infrastructure Layer"
        REPOS[Repository Implementations]
        ORM_LAYER[SQLAlchemy ORM]
        EXTERNAL[External Services]
    end

    API --> DEPS
    DEPS --> SERVICES
    SERVICES --> USE_CASES
    USE_CASES --> ENTITIES
    USE_CASES --> BUSINESS_RULES
    USE_CASES --> INTERFACES

    INTERFACES -.->|Implemented by| REPOS
    REPOS --> ORM_LAYER
    SERVICES --> EXTERNAL

    style API fill:#e1f5ff
    style SERVICES fill:#fff9e1
    style ENTITIES fill:#e1ffe1
    style REPOS fill:#ffe1e1
```

---

## Request Flow

### Standard API Request

```mermaid
sequenceDiagram
    participant Client
    participant Middleware
    participant Route
    participant Dependency
    participant Service
    participant Repository
    participant Database

    Client->>Middleware: HTTP Request
    Middleware->>Middleware: CORS Check
    Middleware->>Middleware: Auth Verification
    Middleware->>Route: Forward Request

    Route->>Dependency: Get Dependencies
    Dependency->>Dependency: Get DB Session
    Dependency->>Dependency: Get Current User

    Route->>Service: Call Service Method
    Service->>Service: Validate Business Rules
    Service->>Repository: Query/Update Data
    Repository->>Database: Execute SQL
    Database-->>Repository: Results
    Repository-->>Service: Entity Objects
    Service-->>Route: Response Data
    Route-->>Client: HTTP Response
```

---

## Dependency Injection

### FastAPI Dependencies

```python
# app/api/deps.py
from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.security import verify_token
from app.models.user import User
from app.repositories.user_repository import UserRepository

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    """Get current authenticated user."""
    payload = verify_token(token)
    user_id = payload.get("sub")

    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )

    repo = UserRepository(db)
    user = await repo.get_by_id(user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return user

def get_user_repository(
    db: AsyncSession = Depends(get_db)
) -> UserRepository:
    """Get user repository instance."""
    return UserRepository(db)
```

### Using Dependencies in Routes

```python
# app/api/v1/routes/users.py
from fastapi import APIRouter, Depends
from app.api.deps import get_current_user, get_user_repository
from app.schemas.user import User, UserUpdate
from app.services.user_service import UserService

router = APIRouter()

@router.get("/me", response_model=User)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user)
):
    """Get current user profile."""
    return current_user

@router.put("/me", response_model=User)
async def update_current_user(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    repo: UserRepository = Depends(get_user_repository)
):
    """Update current user profile."""
    service = UserService(repo)
    return await service.update_user(current_user.id, user_update)
```

---

## Repository Pattern

### Base Repository

```python
# app/repositories/base.py
from typing import Generic, TypeVar, Type, Optional, List
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

ModelType = TypeVar("ModelType")

class BaseRepository(Generic[ModelType]):
    def __init__(self, model: Type[ModelType], db: AsyncSession):
        self.model = model
        self.db = db

    async def get_by_id(self, id: int) -> Optional[ModelType]:
        result = await self.db.execute(
            select(self.model).where(self.model.id == id)
        )
        return result.scalar_one_or_none()

    async def get_all(self, skip: int = 0, limit: int = 100) -> List[ModelType]:
        result = await self.db.execute(
            select(self.model).offset(skip).limit(limit)
        )
        return result.scalars().all()

    async def create(self, obj_in: dict) -> ModelType:
        db_obj = self.model(**obj_in)
        self.db.add(db_obj)
        await self.db.commit()
        await self.db.refresh(db_obj)
        return db_obj

    async def update(self, id: int, obj_in: dict) -> Optional[ModelType]:
        db_obj = await self.get_by_id(id)
        if not db_obj:
            return None

        for field, value in obj_in.items():
            setattr(db_obj, field, value)

        await self.db.commit()
        await self.db.refresh(db_obj)
        return db_obj

    async def delete(self, id: int) -> bool:
        db_obj = await self.get_by_id(id)
        if not db_obj:
            return False

        await self.db.delete(db_obj)
        await self.db.commit()
        return True
```

---

## Service Layer

### Service Pattern

```python
# app/services/user_service.py
from typing import Optional, List
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserCreate, UserUpdate
from app.models.user import User
from app.core.security import get_password_hash

class UserService:
    def __init__(self, repository: UserRepository):
        self.repository = repository

    async def create_user(self, user_in: UserCreate) -> User:
        """Create new user with hashed password."""
        # Business logic
        existing_user = await self.repository.get_by_email(user_in.email)
        if existing_user:
            raise ValueError("Email already registered")

        # Hash password
        hashed_password = get_password_hash(user_in.password)

        # Create user
        user_data = user_in.dict(exclude={"password"})
        user_data["hashed_password"] = hashed_password

        return await self.repository.create(user_data)

    async def get_user(self, user_id: int) -> Optional[User]:
        """Get user by ID."""
        return await self.repository.get_by_id(user_id)

    async def list_users(self, skip: int = 0, limit: int = 100) -> List[User]:
        """List users with pagination."""
        return await self.repository.get_all(skip=skip, limit=limit)

    async def update_user(self, user_id: int, user_in: UserUpdate) -> User:
        """Update user."""
        user = await self.repository.get_by_id(user_id)
        if not user:
            raise ValueError("User not found")

        update_data = user_in.dict(exclude_unset=True)
        return await self.repository.update(user_id, update_data)
```

---

## Authentication Flow

### JWT Authentication

```mermaid
sequenceDiagram
    participant Client
    participant AuthRoute
    participant AuthService
    participant UserRepo
    participant Database
    participant Redis

    Client->>AuthRoute: POST /auth/login
    AuthRoute->>AuthService: authenticate(credentials)
    AuthService->>UserRepo: get_by_email(email)
    UserRepo->>Database: SELECT user
    Database-->>UserRepo: User record
    UserRepo-->>AuthService: User object

    AuthService->>AuthService: verify_password()

    alt Valid Password
        AuthService->>AuthService: create_access_token()
        AuthService->>AuthService: create_refresh_token()
        AuthService->>Redis: Store refresh token
        AuthService-->>AuthRoute: Tokens
        AuthRoute-->>Client: 200 OK (Access + Refresh)
    else Invalid Password
        AuthService-->>AuthRoute: Invalid credentials
        AuthRoute-->>Client: 401 Unauthorized
    end
```

### Token Refresh Flow

```mermaid
sequenceDiagram
    participant Client
    participant AuthRoute
    participant AuthService
    participant Redis

    Client->>AuthRoute: POST /auth/refresh (refresh_token)
    AuthRoute->>AuthService: refresh_access_token()
    AuthService->>Redis: Verify refresh token
    Redis-->>AuthService: Token valid

    alt Token Valid
        AuthService->>AuthService: create_access_token()
        AuthService-->>AuthRoute: New access token
        AuthRoute-->>Client: 200 OK (New access token)
    else Token Invalid/Expired
        AuthService-->>AuthRoute: Invalid token
        AuthRoute-->>Client: 401 Unauthorized
    end
```

---

## Database Architecture

### SQLAlchemy Async Models

```python
# app/models/base.py
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy import DateTime, func
from datetime import datetime

class Base(DeclarativeBase):
    pass

class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now()
    )
```

```python
# app/models/user.py
from sqlalchemy import String, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base, TimestampMixin

class User(Base, TimestampMixin):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_superuser: Mapped[bool] = mapped_column(Boolean, default=False)

    # Relationships
    posts: Mapped[List["Post"]] = relationship(back_populates="author")
```

### Connection Pool Configuration

```mermaid
graph TB
    APP[FastAPI App] --> POOL[Connection Pool]

    POOL --> CONN1[Connection 1]
    POOL --> CONN2[Connection 2]
    POOL --> CONN3[Connection 3]
    POOL --> CONN_N[Connection N]

    CONN1 --> DB[(PostgreSQL)]
    CONN2 --> DB
    CONN3 --> DB
    CONN_N --> DB

    POOL -.->|pool_size=20| CONFIG[Pool Config]
    POOL -.->|max_overflow=10| CONFIG
    POOL -.->|pool_timeout=30| CONFIG

    style APP fill:#e1f5ff
    style POOL fill:#fff9e1
    style DB fill:#ffe1e1
```

---

## Caching Strategy

### Redis Caching

```mermaid
graph TB
    REQUEST[API Request] --> CHECK_CACHE{Check Cache}

    CHECK_CACHE -->|Hit| RETURN_CACHED[Return Cached Data]
    CHECK_CACHE -->|Miss| DATABASE[Query Database]

    DATABASE --> STORE_CACHE[Store in Cache]
    STORE_CACHE --> RETURN_DATA[Return Data]

    MUTATION[Data Mutation] --> INVALIDATE[Invalidate Cache]

    style REQUEST fill:#e1f5ff
    style CHECK_CACHE fill:#fff9e1
    style DATABASE fill:#ffe1e1
    style RETURN_CACHED fill:#d4edda
```

```python
# app/utils/cache.py
import json
from typing import Optional, Any
import redis.asyncio as redis
from app.core.config import settings

class CacheService:
    def __init__(self):
        self.redis = redis.from_url(settings.REDIS_URL)

    async def get(self, key: str) -> Optional[Any]:
        """Get value from cache."""
        value = await self.redis.get(key)
        if value:
            return json.loads(value)
        return None

    async def set(self, key: str, value: Any, expire: int = 3600):
        """Set value in cache with expiration."""
        await self.redis.set(key, json.dumps(value), ex=expire)

    async def delete(self, key: str):
        """Delete key from cache."""
        await self.redis.delete(key)

    async def invalidate_pattern(self, pattern: str):
        """Invalidate all keys matching pattern."""
        async for key in self.redis.scan_iter(match=pattern):
            await self.redis.delete(key)
```

---

## Background Tasks

### Celery Architecture

```mermaid
graph LR
    API[FastAPI API] --> REDIS_BROKER[(Redis Broker)]
    REDIS_BROKER --> WORKER1[Worker 1]
    REDIS_BROKER --> WORKER2[Worker 2]
    REDIS_BROKER --> WORKER3[Worker 3]

    WORKER1 --> TASK[Execute Task]
    WORKER2 --> TASK
    WORKER3 --> TASK

    TASK --> DB[(Database)]
    TASK --> EMAIL[Email Service]
    TASK --> EXTERNAL[External API]

    TASK --> REDIS_RESULT[(Redis Result Backend)]
    API --> REDIS_RESULT

    style API fill:#e1f5ff
    style REDIS_BROKER fill:#fff9e1
    style WORKER1 fill:#e1ffe1
    style TASK fill:#d4edda
```

```python
# app/tasks/email.py
from celery import Celery
from app.core.config import settings

celery_app = Celery(
    "worker",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND
)

@celery_app.task
def send_welcome_email(user_email: str, user_name: str):
    """Send welcome email to new user."""
    # Email sending logic
    pass

@celery_app.task
def send_password_reset(user_email: str, reset_token: str):
    """Send password reset email."""
    # Email sending logic
    pass
```

---

## API Documentation

### Auto-Generated OpenAPI Docs

```mermaid
graph TB
    FASTAPI[FastAPI App] --> OPENAPI[OpenAPI Schema]
    OPENAPI --> SWAGGER[Swagger UI - /docs]
    OPENAPI --> REDOC[ReDoc - /redoc]
    OPENAPI --> SCHEMA_JSON[JSON Schema - /openapi.json]

    style FASTAPI fill:#e1f5ff
    style SWAGGER fill:#e1ffe1
    style REDOC fill:#fff9e1
```

---

## Deployment Architecture

### Production Deployment

```mermaid
graph TB
    subgraph "Load Balancer"
        NGINX[Nginx]
    end

    subgraph "Application Servers"
        GUNICORN1[Gunicorn + Uvicorn 1]
        GUNICORN2[Gunicorn + Uvicorn 2]
        GUNICORN3[Gunicorn + Uvicorn 3]
    end

    subgraph "Worker Pool"
        CELERY1[Celery Worker 1]
        CELERY2[Celery Worker 2]
    end

    subgraph "Data Layer"
        POSTGRES[(PostgreSQL)]
        REDIS[(Redis)]
    end

    USERS[Users] --> NGINX
    NGINX --> GUNICORN1
    NGINX --> GUNICORN2
    NGINX --> GUNICORN3

    GUNICORN1 --> POSTGRES
    GUNICORN2 --> POSTGRES
    GUNICORN3 --> POSTGRES

    GUNICORN1 --> REDIS
    GUNICORN2 --> REDIS
    GUNICORN3 --> REDIS

    REDIS --> CELERY1
    REDIS --> CELERY2

    CELERY1 --> POSTGRES
    CELERY2 --> POSTGRES

    style USERS fill:#e1f5ff
    style NGINX fill:#fff9e1
    style POSTGRES fill:#ffe1e1
```

---

## Key Takeaways

1. **Use async/await**: Leverage Python's async features for I/O operations
2. **Dependency Injection**: Use FastAPI's DI system for clean, testable code
3. **Repository Pattern**: Abstract data access for flexibility
4. **Service Layer**: Encapsulate business logic separate from routes
5. **Caching**: Use Redis for frequently accessed data
6. **Background Tasks**: Offload heavy operations to Celery
7. **Connection Pooling**: Configure proper database connection pools
8. **API Documentation**: Leverage FastAPI's auto-generated docs

---

## References

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/)
- [Celery Documentation](https://docs.celeryq.dev/)

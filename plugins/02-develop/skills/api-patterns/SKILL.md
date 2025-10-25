---
name: api-patterns
description: REST/GraphQL/tRPC API pattern library with validation, error handling, and documentation. Use when creating backend APIs.
---

# API Patterns Skill

## Instructions

1. **Identify API Type**:
   - REST - Traditional HTTP endpoints
   - GraphQL - Schema-based queries
   - tRPC - Type-safe RPC
   - WebSocket - Real-time connections

2. **Detect Backend Framework**:
   - Node.js: Express, Fastify, NestJS, tRPC
   - Python: Django, Flask, FastAPI
   - Go: Gin, Echo, Chi
   - Rust: Actix, Rocket, Axum

3. **Generate API Structure**:
   - Routes/endpoints
   - Controllers/handlers
   - Request validation
   - Response formatting
   - Error handling
   - Authentication/authorization

4. **Add Best Practices**:
   - Input sanitization
   - Rate limiting
   - CORS configuration
   - API versioning
   - Documentation (OpenAPI/Swagger)

## API Patterns

### REST Patterns

**CRUD Operations**:
- GET /resources - List all
- GET /resources/:id - Get single
- POST /resources - Create
- PUT/PATCH /resources/:id - Update
- DELETE /resources/:id - Delete

**Filtering & Pagination**:
- GET /resources?page=1&limit=20
- GET /resources?filter[status]=active
- GET /resources?sort=-createdAt

**Nested Resources**:
- GET /users/:userId/posts
- POST /users/:userId/posts
- GET /posts/:postId/comments

### GraphQL Patterns

**Queries**:
```graphql
query GetUser($id: ID!) {
  user(id: $id) {
    id
    name
    posts {
      title
    }
  }
}
```

**Mutations**:
```graphql
mutation CreatePost($input: CreatePostInput!) {
  createPost(input: $input) {
    id
    title
  }
}
```

### tRPC Patterns

```typescript
export const appRouter = router({
  getUser: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input }) => {
      return await db.user.findUnique({ where: { id: input.id } })
    }),
})
```

## Request Validation

### Node.js (Zod, Joi, Yup)
```typescript
const createUserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().min(2),
})
```

### Python (Pydantic)
```python
class CreateUser(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    name: str = Field(min_length=2)
```

### Go (validator)
```go
type CreateUserRequest struct {
    Email    string `json:"email" validate:"required,email"`
    Password string `json:"password" validate:"required,min=8"`
    Name     string `json:"name" validate:"required,min=2"`
}
```

## Error Handling

**Standardized Error Responses**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

**HTTP Status Codes**:
- 200 OK - Success
- 201 Created - Resource created
- 400 Bad Request - Validation error
- 401 Unauthorized - Auth required
- 403 Forbidden - No permission
- 404 Not Found - Resource not found
- 500 Internal Server Error - Server error

## Authentication Patterns

- JWT tokens
- OAuth2 / OpenID Connect
- API keys
- Session cookies
- Refresh tokens

## Best Practices

- **Input validation** - Validate all inputs
- **Error handling** - Consistent error format
- **Rate limiting** - Prevent abuse
- **Logging** - Request/response logging
- **Documentation** - OpenAPI/Swagger specs
- **Versioning** - /v1/, /v2/ API versions
- **Security** - CORS, HTTPS, sanitization

---

**Purpose**: Backend API pattern library
**Used by**: backend-generator agent, /api command

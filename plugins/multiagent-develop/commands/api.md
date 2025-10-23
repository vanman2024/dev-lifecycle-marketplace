---
allowed-tools: Task(*), Read(*), Write(*), Bash(*), Glob(*), Grep(*), AskUserQuestion(*)
description: Create API endpoint for detected backend framework
argument-hint: <endpoint-name> [--method=GET,POST,PUT,DELETE]
---

**Arguments**: $ARGUMENTS

## Step 1: Detect Project State

Check if project is initialized:

!{bash test -f .claude/project.json && echo "✅ Project initialized" || echo "⚠️ No project.json - run /core:init first"}

## Step 2: Load Project Context

Read project configuration to understand backend framework:

@.claude/project.json

## Step 3: Find API Directory

Locate existing API routes:

!{bash find . -type d -name "routes" -o -name "api" -o -name "controllers" 2>/dev/null | grep -v node_modules | head -5}

## Step 4: Delegate to Backend Generator Agent

Task(
  description="Generate API endpoint",
  subagent_type="backend-generator",
  prompt="Create an API endpoint for the detected backend framework.

**Endpoint Name**: $ARGUMENTS

**Instructions**:

1. **Detect Backend Framework**:
   - Read .claude/project.json to identify backend stack
   - Frameworks: Express, FastAPI, Django, Go (Gin/Echo), Rust (Actix), etc.
   - Determine routing patterns and file structure
   - Identify database/ORM in use (Prisma, SQLAlchemy, GORM, etc.)

2. **Analyze Existing APIs**:
   - Look at existing endpoints to match patterns
   - Use same routing structure and conventions
   - Match error handling and response formats
   - Follow existing authentication/middleware patterns

3. **Generate API Endpoint**:
   - Create route handler in appropriate location
   - Add HTTP methods (GET, POST, PUT, DELETE, PATCH)
   - Include request validation and sanitization
   - Add response formatting (JSON, XML, etc.)
   - Include error handling and status codes
   - Add authentication/authorization if needed

4. **Database Integration**:
   - Add database models/schemas if needed
   - Create database queries using detected ORM
   - Include migrations if applicable
   - Add proper indexes and constraints

5. **Generate Tests**:
   - Create API tests using detected framework (Supertest, Pytest, Go testing)
   - Test all HTTP methods
   - Test validation and error cases
   - Test authentication if applicable

6. **Add Documentation**:
   - Add OpenAPI/Swagger documentation if project uses it
   - Include JSDoc/docstrings
   - Document request/response schemas
   - Add usage examples

**Method Support**:
If $ARGUMENTS contains --method flag:
- Generate handlers for specified methods
- Add appropriate validation for each method
- Include examples for each endpoint

**Project-Agnostic Design**:
- ❌ NEVER hardcode Express/Django/Go - DETECT framework
- ❌ NEVER assume API structure - ANALYZE existing patterns
- ✅ DO adapt to detected backend framework
- ✅ DO match existing API conventions
- ✅ DO support ANY backend stack

**Deliverables**:
- API endpoint with proper framework syntax
- Database models/migrations (if needed)
- Tests for all methods
- API documentation
- Summary of files created
"
)

## Step 5: Review Results

Display API creation summary and usage instructions.

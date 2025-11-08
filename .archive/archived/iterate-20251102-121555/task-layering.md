# Task Layering Principles - Infrastructure First & Use Before Build

**Created**: 2025-10-03
**Purpose**: Guide `/iterate:tasks` command to create proper layered-tasks.md with correct ordering
**Applies To**: All specs using MultiAgent framework

---

## Core Principles

### 1. Infrastructure First - Always Start with Foundation

**Rule**: Infrastructure and models MUST complete before anything that depends on them

**Why**: Can't build adapters without HTTP client, can't create tools without models, can't write tests without schemas

**Examples from Orbit spec**:
```
✅ CORRECT ORDER:
  Layer 1: Models (T031-T038) - RunRecord, Configuration, OperationResult
  Layer 2: Infrastructure (T039-T042) - HTTP client, retry logic, rate limiter
  Layer 3: Adapters (T051-T054) - CATS, Dayforce, Email, SMS
  Layer 4: MCP/CLI/API (T056+) - Wrappers that use adapters

❌ WRONG ORDER:
  Layer 1: MCP tools (T057-T065)
  Layer 2: Models (T031-T038)  ← TOO LATE! Tools need models
```

### 2. Use Before Build - Prefer Existing Libraries Over Custom Code

**Rule**: Before implementing infrastructure from scratch, check if battle-tested libraries exist

**Why**: Production-ready libraries have solved edge cases you haven't thought of yet

**Decision Framework**:
```
1. Does a mature library exist? (httpx, tenacity, sqlalchemy, fastmcp)
   YES → Use it (import + configure)
   NO  → Proceed to step 2

2. Is this core domain logic unique to your project?
   YES → Build it (your secret sauce)
   NO  → Proceed to step 3

3. Is this a common pattern? (retry, rate limit, auth)
   YES → Search harder for libraries (likely exists)
   NO  → Build minimal version, extract later if needed
```

**Examples from Orbit spec**:

| Component | Decision | Rationale |
|-----------|----------|-----------|
| HTTP client | **USE**: httpx | Battle-tested async, connection pooling, retry support |
| Retry logic | **USE**: tenacity | Exponential backoff, jitter, conditional retries solved |
| Database | **USE**: SQLAlchemy + Alembic | ORM + migrations standard in Python |
| MCP server | **USE**: FastMCP | Official MCP framework, handles protocol details |
| CLI framework | **USE**: Click | Industry standard, completion support built-in |
| API framework | **USE**: FastAPI | Async, validation, OpenAPI docs automatic |
| Cache | **USE**: cachetools | TTL, LRU eviction patterns solved |
| Auth providers | **BUILD**: Custom | Domain-specific (CATS API key, Dayforce OAuth2) |
| ATS adapters | **BUILD**: Custom | Core business logic unique to Orbit |
| Workflow engine | **DEFER**: Agent orchestration | Claude Agent SDK handles this better |

### 3. Critical Path Blocking - Identify What Blocks Everything Else

**Rule**: Some tasks block entire layers - prioritize these ruthlessly

**From Orbit spec blocking relationships**:
```
CRITICAL BLOCKERS:
- T031-T038 (Models) → Blocks ALL infrastructure
- T039 (HTTP client) → Blocks ALL adapters
- T043 (AuthProvider) → Blocks ALL auth implementations
- T047 (State manager) → Blocks workflow, CLI state commands
- T056 (MCP server init) → Blocks ALL MCP tools
- T069 (CLI entry) → Blocks ALL CLI commands
- T087 (FastAPI app) → Blocks ALL API endpoints
```

**Layering Strategy**:
```
Layer 1 (Foundation - HIGHEST PRIORITY):
  - Models that everything depends on
  - HTTP client base
  - AuthProvider protocol

Layer 2 (Infrastructure):
  - Retry logic
  - Rate limiting
  - State manager
  - Cache

Layer 3 (Adapters):
  - Auth implementations (API Key, OAuth2, Basic)
  - ATS adapters (CATS, Dayforce)
  - Communication adapters (Email, SMS)

Layer 4 (Wrappers):
  - MCP server + tools
  - CLI commands
  - FastAPI endpoints

Layer 5 (Integration):
  - Workflows
  - End-to-end tests
  - Performance tests
```

---

## Layering Algorithm for `/iterate:tasks`

### Phase 1: Dependency Analysis

```python
def analyze_dependencies(tasks):
    """Extract blocking relationships from tasks.md"""

    # 1. Parse "Depends on: T039 (HTTP client)" from task descriptions
    dependencies = extract_depends_on_clauses(tasks)

    # 2. Identify infrastructure tasks (models, base classes, protocols)
    infrastructure = [
        t for t in tasks
        if any(keyword in t.description.lower() for keyword in
               ['model', 'protocol', 'base', 'config', 'http client', 'auth provider'])
    ]

    # 3. Build dependency graph
    graph = build_dependency_graph(tasks, dependencies)

    # 4. Find critical path (longest chain of dependencies)
    critical_path = find_critical_path(graph)

    return {
        'infrastructure': infrastructure,
        'graph': graph,
        'critical_path': critical_path
    }
```

### Phase 2: Layer Assignment

```python
def assign_layers(tasks, dependency_analysis):
    """Assign tasks to layers based on dependencies"""

    layers = {
        1: [],  # Foundation (models, protocols, base infra)
        2: [],  # Infrastructure (retry, cache, state)
        3: [],  # Adapters (vendor-specific logic)
        4: [],  # Wrappers (MCP, CLI, API)
        5: [],  # Integration (workflows, e2e tests)
    }

    # Layer 1: No dependencies OR only depends on external libraries
    for task in tasks:
        deps = dependency_analysis['graph'][task.id]
        if not deps or all(is_external_library(d) for d in deps):
            if is_infrastructure(task):
                layers[1].append(task)

    # Layer 2: Depends only on Layer 1
    for task in tasks:
        deps = dependency_analysis['graph'][task.id]
        if all(d in layers[1] for d in deps if not is_external_library(d)):
            if is_infrastructure(task) and task not in layers[1]:
                layers[2].append(task)

    # Layer 3: Depends on Layer 1-2, is adapter/business logic
    for task in tasks:
        deps = dependency_analysis['graph'][task.id]
        satisfied = all(d in layers[1] + layers[2] for d in deps if not is_external_library(d))
        if satisfied and is_adapter(task):
            layers[3].append(task)

    # Layer 4: Wrappers that depend on adapters
    for task in tasks:
        deps = dependency_analysis['graph'][task.id]
        satisfied = all(d in layers[1] + layers[2] + layers[3] for d in deps if not is_external_library(d))
        if satisfied and is_wrapper(task):
            layers[4].append(task)

    # Layer 5: Everything else (integration, polish)
    for task in tasks:
        if task not in flatten(layers.values()):
            layers[5].append(task)

    return layers
```

### Phase 3: Agent Assignment with Workload Distribution

```python
def assign_agents_to_layers(layers, agents):
    """Distribute tasks across agents per layer"""

    layered_tasks = []

    for layer_num, layer_tasks in layers.items():
        # Calculate workload per agent
        tasks_per_agent = len(layer_tasks) // len(agents)
        remainder = len(layer_tasks) % len(agents)

        # Distribute tasks
        agent_assignments = {}
        task_idx = 0

        for i, agent in enumerate(agents):
            # Some agents get +1 task if there's remainder
            count = tasks_per_agent + (1 if i < remainder else 0)
            agent_assignments[agent] = layer_tasks[task_idx:task_idx + count]
            task_idx += count

        # Add to layered structure
        layered_tasks.append({
            'layer': layer_num,
            'description': get_layer_description(layer_num),
            'blocking_note': get_blocking_note(layer_num, layers),
            'agents': agent_assignments
        })

    return layered_tasks
```

---

## Layer Descriptions & Blocking Notes

### Layer 1: Foundation
**Description**: Core models, protocols, and base infrastructure that everything depends on

**Blocking Note**:
```
⚠️ CRITICAL: Layer 1 MUST complete before Layer 2 can start
These are foundational types and interfaces that all other code imports

Example blockers:
- RunRecord model → Used by state manager, MCP tools, CLI commands
- OperationResult envelope → Used by ALL adapters, tools, endpoints
- AuthProvider protocol → Used by all auth implementations
```

### Layer 2: Infrastructure
**Description**: Shared infrastructure services (HTTP, retry, cache, state)

**Blocking Note**:
```
⚠️ CRITICAL: Layer 2 MUST complete before Layer 3 can start
These provide core services that adapters consume

Example blockers:
- HTTP client → ALL adapters need this to call vendor APIs
- State manager → Workflow engine needs this to log runs
- Retry logic → ALL adapters wrap calls with retries
```

### Layer 3: Adapters
**Description**: Business logic adapters for external systems (ATS, comms, scheduling)

**Blocking Note**:
```
⚠️ Layer 3 MUST complete before Layer 4 can start
Wrappers (MCP/CLI/API) delegate to these adapters

Example dependencies:
- CATS adapter → MCP search_candidates tool calls this
- Email adapter → CLI 'orbit mail send' calls this
- SMS adapter → API POST /operations/send_sms calls this
```

### Layer 4: Wrappers
**Description**: Thin wrappers exposing SDK via MCP tools, CLI commands, API endpoints

**Blocking Note**:
```
Layer 4 can start once Layer 3 adapters are ready
These are presentation layers with NO business logic

Parallel streams (can work simultaneously):
- MCP stream: T056-T068 (MCP server + tools)
- CLI stream: T069-T086 (CLI entry + commands)
- API stream: T087-T095 (FastAPI app + endpoints)
```

### Layer 5: Integration & Polish
**Description**: Workflows, end-to-end tests, performance tests, documentation

**Blocking Note**:
```
Layer 5 requires most/all of Layer 4 complete
These test the system as a whole

Can work in parallel:
- Different test files (unit, integration, performance)
- Different documentation files
- Independent polish tasks
```

---

## Use Before Build - Checklist

Before implementing ANY infrastructure component, ask:

### 1. HTTP Client
- [ ] Is httpx sufficient? (async, connection pooling, timeouts)
- [ ] Do we need custom transport logic?
- [ ] **Decision**: Use httpx unless custom transport needed

### 2. Retry Logic
- [ ] Is tenacity sufficient? (exponential backoff, jitter, conditional)
- [ ] Do we need vendor-specific retry rules?
- [ ] **Decision**: Use tenacity with custom predicate functions

### 3. Rate Limiting
- [ ] Is aiolimiter sufficient? (token bucket, sliding window)
- [ ] Do we need circuit breaker pattern too?
- [ ] **Decision**: Use aiolimiter + simple circuit breaker wrapper

### 4. Database ORM
- [ ] Is SQLAlchemy sufficient? (async, migrations via Alembic)
- [ ] Do we need NoSQL or graph database?
- [ ] **Decision**: Use SQLAlchemy (SQLite local, Postgres remote)

### 5. Cache
- [ ] Is cachetools sufficient? (TTL, LRU, size limits)
- [ ] Do we need distributed cache (Redis)?
- [ ] **Decision**: Use cachetools for local, defer Redis to Phase 2

### 6. MCP Server
- [ ] Is FastMCP sufficient? (stdio, HTTP/SSE, tool/resource/prompt decorators)
- [ ] Do we need custom MCP protocol handling?
- [ ] **Decision**: Use FastMCP (official framework)

### 7. CLI Framework
- [ ] Is Click sufficient? (commands, groups, options, completion)
- [ ] Do we need rich terminal UI (progress bars, tables)?
- [ ] **Decision**: Use Click + rich for formatting

### 8. API Framework
- [ ] Is FastAPI sufficient? (async, validation, OpenAPI, webhooks)
- [ ] Do we need GraphQL or gRPC?
- [ ] **Decision**: Use FastAPI (REST + webhooks only for now)

### 9. Validation
- [ ] Is Pydantic sufficient? (v2 models, JSON schema, validation)
- [ ] Do we need custom validators?
- [ ] **Decision**: Use Pydantic v2 (built into FastAPI)

### 10. Auth
- [ ] Are there libraries for API Key / Basic / OAuth2?
- [ ] Is this domain-specific (vendor APIs have unique auth)?
- [ ] **Decision**: Build thin AuthProvider wrappers (vendor-specific)

---

## Example: Layered Tasks Output

```markdown
# Layered Tasks - Orbit Framework

## Layer 1: Foundation (MUST complete before Layer 2)

⚠️ **CRITICAL BLOCKING LAYER**: These models and protocols are imported by ALL other code

### @claude (Architecture & Models) - 8 tasks
- [ ] T031 RunRecord model in orbit/sdk/state/models.py
- [ ] T032 StepRecord model in orbit/sdk/state/models.py
- [ ] T033 Configuration model in orbit/sdk/core/config.py
- [ ] T034 OperationResult envelope in orbit/sdk/core/result.py
- [ ] T035 WorkflowRecipe model in orbit/sdk/workflows/recipe.py
- [ ] T036 IdempotencyKey model in orbit/sdk/state/models.py
- [ ] T037 AuthProviderConfig model in orbit/sdk/auth/config.py
- [ ] T038 ErrorContext model in orbit/sdk/core/errors.py

**Why Layer 1**: These models are imported by infrastructure (Layer 2), adapters (Layer 3), and wrappers (Layer 4). Nothing can progress without these types defined.

**Use Before Build Decisions**:
- ✅ USED: Pydantic v2 for all models (validation, JSON schema, FastAPI integration)
- ✅ USED: platformdirs for OS-native config directories (T033)
- ❌ BUILD: Custom models for domain entities (RunRecord, WorkflowRecipe unique to Orbit)

---

## Layer 2: Infrastructure (MUST complete before Layer 3)

⚠️ **CRITICAL BLOCKING LAYER**: HTTP client, retry logic, auth provider needed by ALL adapters

### @claude (Infrastructure & Auth) - 8 tasks
- [ ] T039 HTTP client with telemetry in orbit/sdk/core/http.py
- [ ] T040 Retry logic with exponential jitter in orbit/sdk/core/retry.py
- [ ] T041 Rate limiter in orbit/sdk/core/rate_limit.py
- [ ] T042 Idempotency middleware in orbit/sdk/core/idempotency.py
- [ ] T043 AuthProvider protocol in orbit/sdk/auth/provider.py
- [ ] T047 State manager for RunRecord/StepRecord in orbit/sdk/state/manager.py
- [ ] T048 Cache manager in orbit/sdk/state/cache.py
- [ ] T049 PII redaction utilities in orbit/sdk/core/privacy.py

### @copilot (Auth Implementations) - 3 tasks
- [ ] T044 API Key auth provider in orbit/sdk/auth/providers/api_key.py
- [ ] T045 Basic auth provider in orbit/sdk/auth/providers/basic.py
- [ ] T046 OAuth2 Client Credentials provider in orbit/sdk/auth/providers/oauth2.py

**Why Layer 2**: Adapters (Layer 3) cannot call vendor APIs without HTTP client, auth, and retry logic. State manager needed for workflow logging.

**Use Before Build Decisions**:
- ✅ USED: httpx for HTTP client (async, pooling, timeouts) - wrap with telemetry
- ✅ USED: tenacity for retry logic (exponential backoff, jitter, predicates)
- ✅ USED: SQLAlchemy + Alembic for state manager (ORM + migrations)
- ✅ USED: cachetools for cache manager (TTL, LRU built-in)
- ❌ BUILD: AuthProvider protocol (vendor auth varies: CATS uses API key, Dayforce uses OAuth2)

---

## Layer 3: Adapters (Can start once Layer 2 complete)

Adapters implement business logic for external systems. MCP/CLI/API (Layer 4) delegate to these.

### @copilot (ATS Adapters) - 2 tasks
- [ ] T051 CATS adapter base in orbit/sdk/ats/cats.py
- [ ] T052 Dayforce adapter base in orbit/sdk/ats/dayforce.py

### @gemini (Communication Adapters) - 2 tasks
- [ ] T053 Email adapter in orbit/sdk/comms/email.py
- [ ] T054 SMS adapter in orbit/sdk/comms/sms.py

### @claude (Workflow Engine) - 2 tasks
- [ ] T050 Retention policy enforcer in orbit/sdk/state/retention.py
- [ ] T055 Workflow executor in orbit/sdk/workflows/executor.py

**Why Layer 3**: These consume Layer 2 infrastructure (HTTP, auth, retry) and implement domain logic. Layer 4 wrappers just expose these via different interfaces.

**Use Before Build Decisions**:
- ❌ BUILD: All adapters are custom (CATS API, Dayforce API, email/SMS integrations unique to Orbit)
- ✅ USED: Adapters consume httpx, tenacity, AuthProvider from Layer 2
- ✅ USED: Workflow executor uses SQLAlchemy state manager from Layer 2

---

## Layer 4: Wrappers (Can start once Layer 3 adapters ready)

Thin presentation layers exposing SDK via MCP tools, CLI commands, API endpoints. NO business logic here.

### Stream A: MCP Server (@qwen) - 13 tasks
- [ ] T056 FastMCP server initialization in orbit/mcp/server.py
- [ ] T057-T065 MCP tools (search_candidates, get_ats_entity, etc.)
- [ ] T066 MCP resources in orbit/mcp/resources.py
- [ ] T067 MCP prompts in orbit/mcp/prompts.py
- [ ] T068 MCP server entry point in orbit/mcp/__main__.py

### Stream B: CLI Commands (@copilot) - 18 tasks
- [ ] T069 CLI entry point with --via flag in orbit/cli/__main__.py
- [ ] T070 CLI config module in orbit/cli/config.py
- [ ] T071 CLI formatting utilities in orbit/cli/formatting.py
- [ ] T072-T086 CLI commands (setup, auth, ats, workflow, state, etc.)

### Stream C: FastAPI (@gemini) - 9 tasks
- [ ] T087 FastAPI app initialization in orbit/api/app.py
- [ ] T088-T094 API endpoints (health, webhooks, operations, workflows, runs)
- [ ] T095 FastAPI entry point in orbit/api/__main__.py

**Why Layer 4**: These are just different interfaces to the same SDK adapters (Layer 3). Can work in parallel since they don't depend on each other.

**Use Before Build Decisions**:
- ✅ USED: FastMCP for MCP server (official framework, handles protocol)
- ✅ USED: Click for CLI (standard, completion support)
- ✅ USED: FastAPI for API (async, validation, OpenAPI docs)
- ❌ BUILD: All delegate to SDK adapters - no business logic in wrappers

---

## Layer 5: Integration & Polish (Can start once most of Layer 4 complete)

End-to-end tests, performance tests, documentation, packaging.

### @gemini (Testing & Docs) - 10 tasks
- [ ] T096 Database migrations with Alembic
- [ ] T097 Environment-based config loading
- [ ] T098 Observability: structured logging
- [ ] T099-T104 Unit and performance tests
- [ ] T105 Newman/Postman API test suite
- [ ] T106-T107 Documentation updates

### @copilot (Packaging) - 3 tasks
- [ ] T108 Code cleanup: remove duplication
- [ ] T109 Run manual testing from quickstart.md
- [ ] T110 Package for distribution

**Why Layer 5**: These test the integrated system. Must wait for Layer 4 wrappers to expose functionality.

**Use Before Build Decisions**:
- ✅ USED: Alembic for migrations (standard with SQLAlchemy)
- ✅ USED: pytest for all testing (unit, integration, performance)
- ✅ USED: Newman for API testing (Postman collection runner)
- ✅ USED: python -m build for packaging (PEP 517 standard)
```

---

## Implementation Checklist for `/iterate:tasks` Command

When generating `layered-tasks.md`, the command MUST:

### 1. Dependency Analysis
- [ ] Parse all "Depends on: T###" clauses from tasks.md
- [ ] Build dependency graph (task → [dependencies])
- [ ] Identify critical path (longest chain)
- [ ] Find blocking tasks (tasks many others depend on)

### 2. Infrastructure Identification
- [ ] Flag tasks with keywords: model, protocol, base, config, http, auth, state, cache
- [ ] Separate infrastructure from business logic
- [ ] Separate infrastructure from wrappers (MCP/CLI/API)

### 3. Use Before Build Analysis
- [ ] For each infrastructure task, check if libraries exist
- [ ] Add "Use Before Build Decisions" section per layer
- [ ] Document: ✅ USED library vs ❌ BUILD custom

### 4. Layer Assignment
- [ ] Layer 1: Models, protocols, base infrastructure (0 dependencies)
- [ ] Layer 2: Infrastructure services (depends only on Layer 1)
- [ ] Layer 3: Business logic adapters (depends on Layer 1-2)
- [ ] Layer 4: Wrappers (depends on Layer 1-3)
- [ ] Layer 5: Integration & polish (depends on Layer 1-4)

### 5. Blocking Notes
- [ ] Add "⚠️ CRITICAL BLOCKING LAYER" to Layer 1 and 2
- [ ] Explain why each layer blocks the next
- [ ] List specific tasks that are blockers with examples

### 6. Agent Distribution
- [ ] Count tasks per layer
- [ ] Distribute evenly across agents
- [ ] Balance by complexity (not just count)
- [ ] Allow parallel streams in Layer 4 (MCP, CLI, API independent)

### 7. Output Format
- [ ] Use markdown with clear layer headers
- [ ] Include agent assignments per layer
- [ ] Include blocking notes per layer
- [ ] Include "Use Before Build Decisions" per layer
- [ ] Include task counts and workload distribution

---

## Success Criteria

A well-layered tasks file MUST:

1. ✅ **No circular dependencies**: If task A depends on B, B cannot depend on A
2. ✅ **Clear blocking layers**: Layer N+1 cannot start until Layer N complete
3. ✅ **Infrastructure first**: Models and base services before business logic
4. ✅ **Use before build**: Document library decisions per layer
5. ✅ **Balanced workload**: Agents have roughly equal task counts per layer
6. ✅ **Parallel opportunities**: Mark independent tasks that can run simultaneously
7. ✅ **Blocking notes**: Explain WHY each layer blocks the next with examples

---

## Anti-Patterns to Avoid

### ❌ Wrong: Adapters Before Infrastructure
```
Layer 1: CATS adapter, Dayforce adapter
Layer 2: HTTP client, AuthProvider
```
**Problem**: Adapters need HTTP client and auth to work!

### ❌ Wrong: Wrappers Before Adapters
```
Layer 1: MCP search_candidates tool
Layer 2: CATS adapter
```
**Problem**: MCP tool delegates to adapter - adapter must exist first!

### ❌ Wrong: Mixed Layers
```
Layer 1:
  - RunRecord model (foundation)
  - CATS adapter (business logic)  ← WRONG!
  - MCP server init (wrapper)      ← WRONG!
```
**Problem**: Mixing concerns makes dependencies unclear

### ❌ Wrong: No Blocking Notes
```
Layer 1: Foundation
  - T031 RunRecord model
  - T032 StepRecord model
```
**Problem**: Doesn't explain WHY Layer 2 must wait or WHAT it's blocking

### ✅ Correct: Infrastructure Layers with Clear Blocking
```
Layer 1: Foundation (MUST complete before Layer 2)
⚠️ CRITICAL: RunRecord used by state manager (T047), MCP tools (T057+), CLI (T083)
  - T031 RunRecord model
  - T032 StepRecord model

Layer 2: Infrastructure (MUST complete before Layer 3)
⚠️ CRITICAL: HTTP client (T039) needed by ALL adapters (T051-T054)
  - T039 HTTP client with telemetry
  - T043 AuthProvider protocol
```

---

## Final Note

**The goal of layering is to maximize parallel work while respecting dependencies.**

- Layer 1 (Foundation): Usually 1 agent, sequential (models depend on each other)
- Layer 2 (Infrastructure): 2-3 agents, some parallelism (retry ≠ cache)
- Layer 3 (Adapters): 3-4 agents, high parallelism (different vendor APIs)
- Layer 4 (Wrappers): 3-4 agents, maximum parallelism (MCP/CLI/API independent)
- Layer 5 (Polish): 2-3 agents, high parallelism (different test/doc files)

This structure lets 3-4 agents work simultaneously most of the time, only bottlenecking at critical foundation tasks (Layer 1-2).

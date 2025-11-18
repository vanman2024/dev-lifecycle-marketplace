---
description: Preview task-to-command mapping without execution (dry-run)
argument-hint: <task-description>
allowed-tools: Read, Bash(*)
---

**Arguments**: $ARGUMENTS

Goal: Preview how task description maps to tech-specific command without execution. Useful for testing and debugging mapping logic.

Core Principles:
- Detect project tech stack from project.json
- Map task keywords to appropriate commands
- Show mapping confidence and alternatives
- Never execute, only preview

Phase 1: Load Context
Goal: Read tech stack for intelligent mapping

Actions:
- Read project.json: @.claude/project.json
- Extract tech stack components:
  * Frontend framework (Next.js, React, Vue, etc.)
  * Backend framework (FastAPI, Express, Django, etc.)
  * Database (Supabase, PostgreSQL, MongoDB, etc.)
  * AI SDKs (Vercel AI SDK, LangChain, etc.)
  * Other dependencies (Mem0, Clerk, etc.)

Phase 2: Analyze Task
Goal: Determine task type and target from description

Actions:
- Parse $ARGUMENTS for task description
- Identify task type by keywords:
  * "component", "button", "card", "page", "layout" → Frontend
  * "endpoint", "API", "route", "handler" → Backend
  * "schema", "table", "migration", "RLS" → Database
  * "streaming", "AI", "provider", "chat" → AI/SDK
  * "auth", "login", "signup", "OAuth" → Authentication
  * "memory", "history", "conversation" → Memory layer
- Determine complexity: Simple, Moderate, Complex
- Extract specific entity names (e.g., "Button" from "Create Button component")

Phase 3: Map to Command
Goal: Generate appropriate command based on task and tech stack

Actions:
- Based on task type and detected tech stack, map to command:

  **Frontend (Next.js detected):**
  - Component → /nextjs-frontend:add-component <name>
  - Page → /nextjs-frontend:add-page <name>
  - Layout → /nextjs-frontend:add-layout <name>

  **Backend (FastAPI detected):**
  - Endpoint → /fastapi-backend:add-endpoint <method> <path>
  - Service → /fastapi-backend:add-service <name>
  - Model → /fastapi-backend:add-model <name>

  **Database (Supabase detected):**
  - Schema → /supabase:create-schema <name>
  - Migration → /supabase:deploy-migration
  - RLS → /supabase:add-rls <table>

  **AI (Vercel AI SDK detected):**
  - Streaming → /vercel-ai-sdk:add-streaming
  - Provider → /vercel-ai-sdk:add-provider <name>
  - Chat → /vercel-ai-sdk:add-chat

  **Memory (Mem0 detected):**
  - Conversation → /mem0:add-conversation-memory
  - User → /mem0:add-user-memory

  **Auth (Clerk detected):**
  - Setup → /clerk:setup
  - Middleware → /clerk:add-middleware

- If no clear mapping: Return "Unknown - needs manual command selection"
- If multiple mappings possible: List alternatives

Phase 4: Display Mapping
Goal: Show comprehensive mapping result

Actions:
- Display formatted result with these fields:
  * Task: "$ARGUMENTS"
  * Detected Type: <Task Type>
  * Tech Stack: <Relevant Framework/SDK>
  * Command: <Generated Command>
  * Complexity: <Simple/Moderate/Complex>
  * Confidence: <High/Medium/Low>
  * Alternative Options (if applicable)
  * To Execute: Copy and run the command above

Phase 5: Summary
Goal: Provide usage guidance and next steps

Actions:
- If mapping successful (Confidence: High):
  * Confirm command is ready to use
  * Suggest running directly or adding to layered-tasks.md
- If mapping ambiguous (Confidence: Medium):
  * Show multiple alternatives
  * Recommend user selects best match
- If mapping failed (Confidence: Low):
  * List available commands for manual selection
  * Suggest using /implementation:list-commands
  * Recommend consulting tech-specific plugin docs

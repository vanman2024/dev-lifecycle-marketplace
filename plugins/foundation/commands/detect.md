---
description: Detect project tech stack and populate .claude/project.json
argument-hint: [project-path]
allowed-tools: Task(*), Read(*), Write(*), Bash(*), Glob(*), Grep(*), AskUserQuestion(*)
---

**Arguments**: $ARGUMENTS

Goal: Analyze project structure and dependencies to detect the complete tech stack, then populate .claude/project.json with framework, languages, AI SDKs, and architecture information

Core Principles:
- Detect don't assume - never hardcode frameworks
- Analyze thoroughly - check package.json, requirements.txt, go.mod, Cargo.toml, etc.
- Support all stacks - frontend, backend, monorepo, AI applications
- AI-aware - detect Vercel AI SDK, Claude Agent SDK, Mem0, FastMCP, etc.

## Phase 1: Discovery

Goal: Understand the project structure and locate key files

Actions:
- Parse $ARGUMENTS for project path (default: current directory)
- Check if .claude directory exists, create if needed
- Find all package manifest files:
  - !{bash find . -maxdepth 3 -name "package.json" -o -name "requirements.txt" -o -name "pyproject.toml" -o -name "go.mod" -o -name "Cargo.toml" -o -name "composer.json" 2>/dev/null}
- Identify project type indicators:
  - Frontend: node_modules, src/, public/, components/
  - Backend: api/, server/, app/, main.py, main.go
  - Monorepo: packages/, apps/, workspaces in package.json

## Phase 2: Analysis

Goal: Load and analyze project files

Actions:
- Load primary manifest files for inspection:
  - @package.json (if exists)
  - @requirements.txt (if exists)
  - @pyproject.toml (if exists)
  - @go.mod (if exists)
- Check for configuration files:
  - @next.config.js or @next.config.ts (Next.js)
  - @vite.config.js or @vite.config.ts (Vite)
  - @tsconfig.json (TypeScript)
  - @.python-version (Python version)
- Look for AI-specific indicators:
  - Dependencies: @vercel/ai, anthropic, openai, langchain
  - MCP servers: @.mcp.json
  - Memory: mem0, supabase (with pgvector)

## Phase 3: Planning

Goal: Prepare detection strategy

Actions:
- Outline what needs to be detected:
  - Primary framework (Next.js, FastAPI, Django, Go, Rust, etc.)
  - Languages and versions (TypeScript, Python, Go, Rust)
  - AI SDKs (Vercel AI SDK, Claude Agent SDK, OpenAI SDK)
  - Database (Supabase, PostgreSQL, MongoDB, etc.)
  - MCP servers configured
  - Testing frameworks (Jest, Pytest, Go test)
  - Build tools (Vite, Webpack, esbuild, etc.)
- Identify any ambiguities that need clarification

## Phase 4: Implementation

Goal: Execute detection with agent

Actions:

Launch the stack-detector agent to analyze the project and detect the complete tech stack.

Provide the agent with:
- Context: Project files loaded from manifest analysis
- Target: $ARGUMENTS (project path)
- Requirements:
  - Detect primary framework (Next.js, React, Vue, FastAPI, Django, Go, Rust, etc.)
  - Identify all languages and their versions
  - Find AI SDKs and providers (Vercel AI SDK, Anthropic, OpenAI, Google AI)
  - Detect database and storage (Supabase, PostgreSQL, Redis, etc.)
  - Identify MCP servers from .mcp.json
  - Detect AI-specific features:
    - Memory systems (Mem0, custom)
    - Vector databases (pgvector, Pinecone, etc.)
    - Agent frameworks (Claude Agent SDK, LangChain, CrewAI)
  - Find testing framework
  - Detect deployment targets (Vercel, Railway, DigitalOcean, AWS, etc.)
- Expected output: Complete tech stack information formatted for .claude/project.json

## Phase 5: Review

Goal: Verify detection results

Actions:
- Check agent's output for completeness
- Verify all major components detected:
  - Framework ✓
  - Languages ✓
  - AI stack ✓
  - Database ✓
  - Testing ✓
- Validate .claude/project.json structure
- Example: @.claude/project.json

## Phase 6: Summary

Goal: Report what was detected

Actions:
- Display comprehensive tech stack summary:
  - **Framework**: {detected framework and version}
  - **Languages**: {languages with versions}
  - **AI Stack**: {AI SDKs and providers}
  - **Database**: {database type and version}
  - **MCP Servers**: {count and names}
  - **Testing**: {test framework}
  - **Deployment**: {target platforms}
- Show .claude/project.json location
- Suggest next steps:
  - "Use detected stack with lifecycle commands"
  - "AI Tech Stack detected: {stack-number}" (if applicable)
  - "Run /foundation:env-check to verify required tools"

---
description: Manage environment variables for project configuration
argument-hint: <action> [key] [value]
allowed-tools: Read(*), Write(*), Edit(*), Bash(*), Grep(*), AskUserQuestion(*)
---

**Arguments**: $ARGUMENTS

Goal: Scan codebase to detect ALL environment variables used, generate .env file, and manage environment configuration

Core Principles:
- **Scan actual codebase** to detect environment variable usage (no .claude/project.json)
- Secure handling - never log sensitive values
- Support .env files and system environment
- **Launch agents for large codebases** to comprehensively search code
- Generate complete .env template from detected variables

## Phase 1: Discovery - Multi-Source Detection

Goal: Detect required environment variables from ALL available sources (priority order)

Actions:
- Parse $ARGUMENTS for action (scan, generate, add, remove, list, check)
- Load .env file if exists: @.env
- **Launch env-detector agent with multi-source analysis:**

  **Priority 1: Check specs/ directory (HIGHEST PRIORITY)**
  - Look for specs/*.md files
  - Analyze specs for mentioned services, APIs, databases
  - Extract service requirements from spec documents
  - Example: Spec mentions "Supabase for database" → detect SUPABASE_* vars needed

  **Priority 2: Check manifest files (MEDIUM PRIORITY)**
  - Read package.json dependencies (Node.js/TypeScript)
  - Read pyproject.toml/requirements.txt (Python)
  - Detect installed SDKs: @anthropic-ai/sdk, @supabase/supabase-js, openai, etc.

  **Priority 3: Scan codebase (FALLBACK)**
  - Search code for environment variable usage patterns
  - JavaScript: process.env.VAR_NAME, import.meta.env.VAR_NAME
  - Python: os.getenv("VAR_NAME"), os.environ["VAR_NAME"]
  - Find actual variable references in code

- Merge results from all sources (deduplicate)
- Map detected services/variables to required environment variables

## Phase 2: Validation

Goal: Verify action and gather information if needed

Actions:
- If action unclear, use AskUserQuestion to ask:
  - What would you like to do? (add, remove, list, check, template)
  - For add: Which key and value?
  - For remove: Which key to remove?
- For 'add' action:
  - Validate key format (UPPERCASE_SNAKE_CASE)
  - Check if key already exists
  - Warn if overwriting

## Phase 3: Execution

Goal: Perform environment variable management

Actions based on action:

**For 'scan' or 'generate' action (PRIMARY USE CASE):**
- Use detected services from Phase 1 agent analysis
- Generate .env file based on detected services with placeholder values:

  **Example Template Format:**
  ```
  # ============================================
  # Anthropic Claude API (detected: @anthropic-ai/sdk)
  # ============================================
  ANTHROPIC_API_KEY=your_anthropic_api_key_here

  # ============================================
  # Supabase (detected: @supabase/supabase-js)
  # ============================================
  SUPABASE_URL=https://your-project.supabase.co
  SUPABASE_ANON_KEY=your_supabase_anon_key_here

  # ============================================
  # OpenAI (detected: openai package)
  # ============================================
  OPENAI_API_KEY=your_openai_api_key_here

  # ============================================
  # Application Configuration
  # ============================================
  NODE_ENV=development
  PORT=3000
  ```

- Also generate .env.example (safe to commit with same structure)
- Report: "Created .env with {count} required variables for {services}"
- List all services detected and their required keys

**For 'add' action:**
- Add/update variable in .env file
- Example: Edit .env to add KEY=value
- Never log the value
- Report: "Added {key} to .env"

**For 'remove' action:**
- Remove variable from .env
- Example: Edit .env to remove line
- Report: "Removed {key} from .env"

**For 'list' action:**
- Display all variables (mask sensitive values)
- Example: @.env
- Format: KEY=masked_value (show *** for sensitive keys)

**For 'check' action:**
- Compare .env against detected variables from codebase scan
- Report missing variables that code expects
- Report unused variables in .env (cleanup candidates)
- Example: "Missing: SUPABASE_URL (used in src/lib/supabase.ts:12)"

## Phase 4: Summary

Goal: Report results

Actions:
- Display summary:
  - For add: "Environment variable added: {key}"
  - For remove: "Environment variable removed: {key}"
  - For list: "{count} environment variables configured"
  - For check: "✓ All required variables present" or "Missing: {list}"
  - For template: "Created .env.example template"
- Show next steps:
  - "Restart development server to apply changes"
  - "Add .env to .gitignore if not already present"
  - "For check: Fill in missing variables"

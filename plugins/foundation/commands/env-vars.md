---
description: Manage environment variables for project configuration
argument-hint: <action> [key] [value]
allowed-tools: Read(*), Write(*), Edit(*), Bash(*), Grep(*), AskUserQuestion(*)
---

**Arguments**: $ARGUMENTS

Goal: Manage environment variables for development - add, remove, list, and validate required variables for detected tech stack

Core Principles:
- Secure handling - never log sensitive values
- Support .env files and system environment
- Detect required variables from tech stack
- Validate values before setting

## Phase 1: Discovery

Goal: Understand requested action and current environment

Actions:
- Parse $ARGUMENTS for action (add, remove, list, check, template)
- Load .env file if exists: @.env
- Load project configuration: @.claude/project.json
- Determine required environment variables based on stack:
  - AI providers: ANTHROPIC_API_KEY, OPENAI_API_KEY
  - Databases: DATABASE_URL, SUPABASE_URL, SUPABASE_ANON_KEY
  - Deployment: VERCEL_TOKEN, RAILWAY_TOKEN

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
- Validate all required variables are set
- Check against detected stack requirements
- Report missing variables
- Example: "Missing: SUPABASE_URL, SUPABASE_ANON_KEY"

**For 'template' action:**
- Generate .env.example from detected stack
- Include all required variables with placeholders
- Example: Write .env.example with template

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

---
description: Single entry point that guides you through complete project initialization from planning to implementation
argument-hint: [project-name]
allowed-tools: Read, Write, Bash, SlashCommand, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Provide a single entry point for new projects that orchestrates the complete initialization workflow in the correct order, ensuring users know exactly what to do and when.

Core Principles:
- Single entry point for all new projects
- Step-by-step guided workflow
- Correct layering: Planning → Foundation → Implementation
- Clear progress tracking
- No confusion about what to run next

Phase 1: Parse Project Name
Goal: Extract clean project name from arguments

Actions:
- Parse $ARGUMENTS to extract project name (remove comments after #)
- Example: "my-project # comment" → "my-project"
- Store: PROJECT_NAME=$(echo "$ARGUMENTS" | sed 's/#.*//' | xargs)

Phase 2: Create Directory Structure
Goal: Create standardized project directory structure

Actions:
- Display: "🚀 Creating project structure..."
- If PROJECT_NAME provided: !{bash mkdir -p "$PROJECT_NAME" && cd "$PROJECT_NAME"}
- If no PROJECT_NAME: Use current directory
- Create base structure: !{bash mkdir -p .claude docs specs}
- Create stub files: !{bash touch .claude/project.json README.md .gitignore}
- Display: "✅ Directory structure created"

Phase 3: Initialize Planning
Goal: Run planning wizard and create initial specs

Actions:
- Display: "📋 Running planning wizard to gather requirements..."
- Execute: !{SlashCommand /planning:wizard}
- Display: "✅ Planning wizard completed"

Phase 4: Summary and Next Steps
Goal: Show what was created and what to do next

Actions:
- Display: ""
- Display: "✅ Project initialized successfully!"
- Display: ""
- Display: "Created:"
- Display: "  .claude/          # Claude configuration"
- Display: "  docs/             # Documentation"
- Display: "  specs/            # Feature specifications (from wizard)"
- Display: "  README.md         # Project readme"
- Display: "  .gitignore        # Git ignore rules"
- Display: ""
- Display: "Next steps:"
- Display: "  1. /foundation:select-stack      # Choose tech stack"
- Display: "  2. /foundation:init-structure    # Create monorepo structure"
- Display: "  3. /foundation:generate-workflow # Generate workflow checklist"
- Display: ""
- Display: "Or manually:"
- Display: "  /foundation:detect               # Detect tech stack from files"
- Display: "  /planning:architecture           # Design architecture"

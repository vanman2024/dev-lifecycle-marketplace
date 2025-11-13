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

Phase 3: Summary and Next Steps
Goal: Show what was created and what to do next

Actions:
- Display: "✅ Project structure created!"
- Display: ""
- Display: "Created:"
- Display: "  .claude/          # Claude configuration"
- Display: "  docs/             # Documentation"
- Display: "  specs/            # Feature specifications"
- Display: "  README.md         # Project readme"
- Display: "  .gitignore        # Git ignore rules"
- Display: ""
- Display: "Next steps:"
- Display: "  1. /planning:wizard              # Gather requirements"
- Display: "  2. /foundation:select-stack      # Choose tech stack"
- Display: "  3. cat AI-SDK-CHECKLIST.md       # See full workflow"
- Display: ""
- Display: "Or see the checklist now:"
- Display: "  cat ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/AI-SDK-CHECKLIST.md"

---
allowed-tools: Task, Read, Write, Bash, Glob, Grep, AskUserQuestion
description: Generate UI component for detected frontend framework
argument-hint: <component-name> [--variant=style]
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

---


**Arguments**: $ARGUMENTS

## Step 1: Detect Project State

Check if project is initialized:

!{bash test -f .claude/project.json && echo "✅ Project initialized" || echo "⚠️ No project.json - run /core:init first"}

## Step 2: Load Project Context

Read project configuration to understand frontend framework:

@.claude/project.json

## Step 3: Find Components Directory

Locate existing components:

!{bash find . -type d -name "components" -o -name "Components" 2>/dev/null | grep -v node_modules | head -5}

## Step 4: Delegate to Frontend Generator Agent

Task(
  description="Generate UI component",
  subagent_type="frontend-generator",
  prompt="Generate a UI component for the detected frontend framework.

**Component Name**: $ARGUMENTS

**Instructions**:

1. **Detect Frontend Framework**:
   - Read .claude/project.json to identify framework (React, Vue, Svelte, Angular, etc.)
   - Determine if using TypeScript or JavaScript
   - Identify component directory from project structure
   - Check for existing component patterns and naming conventions

2. **Analyze Existing Components**:
   - Look at existing components to match style and structure
   - Use same import patterns and conventions
   - Match file naming (PascalCase, kebab-case, etc.)
   - Follow existing prop patterns and type definitions

3. **Generate Component**:
   - Create component file in appropriate directory
   - Use detected framework syntax (JSX, Vue template, Svelte, etc.)
   - Add TypeScript types if project uses TypeScript
   - Include proper imports and exports
   - Add props/properties with type definitions
   - Include basic styling (CSS modules, styled-components, Tailwind, etc.)

4. **Component Features**:
   - Props/properties for customization
   - Accessibility attributes (ARIA labels, roles)
   - Responsive design considerations
   - Error boundaries (if applicable)
   - Loading states (if applicable)

5. **Generate Tests**:
   - Create test file using detected test framework (Jest, Vitest, Testing Library)
   - Add basic component rendering tests
   - Test props and interactions
   - Follow existing test patterns

6. **Generate Storybook/Documentation** (if applicable):
   - Create Storybook story if project uses Storybook
   - Add JSDoc comments
   - Include usage examples

**Project-Agnostic Design**:
- ❌ NEVER hardcode React/Vue/Svelte - DETECT from project.json
- ❌ NEVER assume component structure - ANALYZE existing patterns
- ✅ DO adapt to detected framework and conventions
- ✅ DO match existing component styles
- ✅ DO support ANY frontend framework

**Variant Support**:
If $ARGUMENTS contains --variant flag:
- Generate multiple style variants
- Add variant prop to component
- Include examples of each variant

**Deliverables**:
- Component file with proper framework syntax
- Test file with basic coverage
- Storybook story (if applicable)
- Summary of files created
- Usage instructions
"
)

## Step 5: Review Results

Display component creation summary and usage instructions.

---
description: Create, list, and validate specifications in specs/ directory
argument-hint: <action> [spec-name]
allowed-tools: Task(*), Read(*), Write(*), Bash(*), Glob(*), Grep(*), AskUserQuestion(*)
---

**Arguments**: $ARGUMENTS

Goal: Manage feature specifications in the specs/ directory - create new specs, list existing ones, and validate spec completeness

Core Principles:
- Framework-agnostic - works with any tech stack
- Structured format - consistent spec template
- Validate completeness - ensure all required sections present
- Support iteration - specs guide task layering in iterate plugin

## Phase 1: Discovery

Goal: Understand the requested action and current spec state

Actions:
- Parse $ARGUMENTS for action (create, list, validate, show)
- Check if specs/ directory exists
- Example: !{bash test -d specs && echo "exists" || echo "missing"}
- If missing and creating, will create it
- Load existing specs if listing or validating
- Example: !{bash find specs -name "*.md" -type f 2>/dev/null | head -20}

## Phase 2: Analysis

Goal: Determine what needs to be done

Actions:
- For 'create' action:
  - If spec name not provided, use AskUserQuestion to ask:
    - What feature are you specifying?
    - Brief description?
    - Any specific requirements?
  - Determine next spec number (001, 002, etc.)
  - Example: !{bash ls -d specs/[0-9][0-9][0-9] 2>/dev/null | tail -1}

- For 'list' action:
  - Read all spec directories
  - Load spec metadata (name, status, date)

- For 'validate' action:
  - Load spec to validate
  - Check for required sections

- For 'show' action:
  - Display specific spec content

## Phase 3: Planning

Goal: Prepare for spec operation

Actions:
- For create: Outline spec structure sections
- For validate: Define validation criteria
- For list: Format output structure
- Review spec-management skill templates
- Confirm approach if significant

## Phase 4: Implementation

Goal: Execute spec operation with agent

Actions:

Launch the spec-writer agent to handle the specification operation.

Provide the agent with:
- Context: Current specs/ directory state
- Action: $ARGUMENTS (create, list, validate, show)
- Requirements:
  - For create: Generate complete specification with:
    - Overview and goals
    - Requirements (functional, non-functional)
    - Technical approach
    - Tasks breakdown
    - Success criteria
    - Dependencies
  - For list: Show all specs with status
  - For validate: Check completeness of spec sections
  - For show: Display spec in readable format
- Template: Use spec-management skill templates
- Expected output: Created/updated spec file or validation report

## Phase 5: Review

Goal: Verify spec operation results

Actions:
- Check agent's output
- Verify spec file created/updated (for create)
- Validate spec structure (for validate)
- Example: @specs/XXX/README.md (to verify content)
- Ensure all required sections present

## Phase 6: Summary

Goal: Report what was accomplished

Actions:
- Display summary based on action:
  - For create: "Created specification: specs/{number}/{name}"
  - For list: "{count} specifications found"
  - For validate: "Validation result: {status}"
  - For show: "Displaying spec: {name}"
- Show spec location and structure
- Suggest next steps:
  - After create: "Run /iterate:tasks {spec-number} to create layered tasks"
  - After validate: "Address missing sections if any"
  - General: "Use /planning:architecture to design technical approach"

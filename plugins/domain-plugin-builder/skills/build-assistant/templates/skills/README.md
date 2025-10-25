# Skills Templates

This directory contains templates for creating Agent Skills.

## Files

- `SKILL.md.template` - Standard skill template with placeholders
- `skill-example/` - Complete working example skill

## Template Variables

| Variable | Purpose | Example |
|:---------|:--------|:--------|
| `{{SKILL_NAME}}` | Display name | `PDF Processor` |
| `{{DESCRIPTION}}` | What skill does | `Extract text from PDF files` |
| `{{TRIGGER_CONTEXT}}` | When to use | `working with PDF files` |
| `{{ALLOWED_TOOLS}}` | Optional tool restrictions | `allowed-tools: Read, Grep, Glob` |
| `{{STEP_BY_STEP_INSTRUCTIONS}}` | How to use skill | Step 1, Step 2, Step 3... |
| `{{CONCRETE_EXAMPLES}}` | Usage examples | Code snippets, commands |
| `{{REQUIREMENTS}}` | Dependencies needed | `Requires pypdf package` |

## Usage

### Creating from Template

```bash
# Copy template
cp SKILL.md.template ../../../../../../.claude/skills/my-skill/SKILL.md

# Fill in variables
# Replace {{SKILL_NAME}} with actual name
# Replace {{DESCRIPTION}} with actual description
# etc.
```

### Using Build Command

```bash
# Let build system create it for you
/build:skill my-skill "Description of skill. Use when trigger context."
```

## Example Structure

```
.claude/skills/my-skill/
├── SKILL.md              # Main skill file (required)
├── reference.md          # Detailed reference (optional)
├── examples.md           # More examples (optional)
└── scripts/              # Utility scripts (optional)
    └── helper.py
```

## Best Practices

1. **Description is CRITICAL**:
   - Include what skill does
   - Include when to use it
   - Include trigger keywords users would mention

2. **Progressive Disclosure**:
   - Put core instructions in SKILL.md
   - Reference additional files as needed
   - Claude loads only what's necessary

3. **Concrete Examples**:
   - Show real code snippets
   - Demonstrate common use cases
   - Include error handling

4. **List Dependencies**:
   - Note required packages in description
   - Claude will install when needed

---

**Purpose**: Templates for creating Agent Skills
**Used by**: skill-builder agent

# Feature Workflow Generation

## Purpose

Generate feature-by-feature implementation workflows that map features from `features.json` to tech-specific commands from the project's tech stack.

## When to Use

- After creating features with `/planning:add-feature`
- When you need a structured workflow for implementing features
- To generate execution roadmaps from specifications

## How It Works

### Data Sources

1. **features.json** - List of features with metadata
2. **specs/{feature-id}/spec.md** - Detailed feature specifications
3. **.claude/project.json** - Tech stack configuration
4. **Airtable** - Available commands for the tech stack

### Workflow

```
features.json → Read features
      ↓
specs/ → Read specifications
      ↓
.claude/project.json → Get tech stack
      ↓
Airtable → Query available commands
      ↓
generate-feature-workflow.py → Combine data
      ↓
FEATURE-IMPLEMENTATION-WORKFLOW.md
```

## Script Usage

### Basic Usage

```bash
cd /path/to/project
python3 scripts/generate-feature-workflow.py
```

### Output Format

```json
{
  "tech_stack": "AI Tech Stack 1",
  "features": [
    {
      "id": "F001",
      "title": "AI chat interface",
      "status": "in-progress",
      "priority": "P0",
      "spec_content": "..."
    }
  ],
  "available_commands": [
    {
      "name": "add-component",
      "description": "Add Next.js component",
      "plugin": "nextjs-frontend",
      "phase": "Implementation"
    }
  ]
}
```

## Feature-to-Command Mapping

### Mapping Strategies

#### 1. Keyword Matching
- "Create chat component" → `/nextjs-frontend:add-component ChatWindow`
- "Add streaming" → `/vercel-ai-sdk:add-streaming`
- "Setup auth" → `/supabase:add-auth`

#### 2. Phase-Based Grouping
- **Foundation** - Infrastructure setup
- **Planning** - Architecture and specs
- **Implementation** - Feature building
- **Quality** - Validation
- **Testing** - Test execution
- **Deployment** - Production deployment

#### 3. Dependency Analysis
- Database commands before backend
- Backend before frontend
- Core components before features
- Integration after all components

## Workflow Document Structure

### Template

```markdown
# Feature Implementation Workflow

Generated from features.json and {TECH_STACK}

## Feature: {FEATURE_ID} - {FEATURE_TITLE}
**Status**: {STATUS}
**Priority**: {PRIORITY}

### Prerequisites
- [ ] Spec complete: specs/{FEATURE_ID}/spec.md
- [ ] Tasks layered: /iterate:tasks {FEATURE_ID}

### Implementation Steps

#### Layer 0: Infrastructure
- [ ] {COMMAND_1}
- [ ] {COMMAND_2}

#### Layer 1: Core Components
- [ ] {COMMAND_3}
- [ ] {COMMAND_4}

#### Layer 2: Feature Components
- [ ] {COMMAND_5}
- [ ] {COMMAND_6}

#### Layer 3: Integration
- [ ] {COMMAND_7}
- [ ] {COMMAND_8}

### Validation
- [ ] /quality:validate-code {FEATURE_ID}
- [ ] /testing:test {FEATURE_ID}

---

## Feature: {NEXT_FEATURE_ID} - {NEXT_FEATURE_TITLE}
...
```

## Filtering Options

### By Feature ID
```bash
--feature F001
```
Only generate workflow for F001

### By Priority
```bash
--priority P0
```
Only generate for P0 features

### By Status
```bash
--status in-progress
```
Only generate for in-progress features

### Split by Feature
```bash
--split
```
Generate separate files:
- `F001-WORKFLOW.md`
- `F002-WORKFLOW.md`
- etc.

## Integration with Other Commands

### Typical Flow

```bash
# 1. Create features
/planning:add-feature "AI chat interface"
/planning:add-feature "User dashboard"

# 2. Generate feature workflow
/planning:generate-feature-workflow

# 3. Execute workflows
/iterate:tasks F001
/implementation:execute F001

/iterate:tasks F002
/implementation:execute F002

# 4. Validate
/quality:validate-code F001
/testing:test F001
```

## Error Handling

### Missing features.json
**Error**: "No features found in features.json"
**Solution**: Run `/planning:add-feature` first

### Missing project.json
**Error**: "Tech stack not found in .claude/project.json"
**Solution**: Run `/foundation:detect` first

### Airtable Access Failure
**Error**: "AIRTABLE_TOKEN environment variable not set"
**Solution**: Export token:
```bash
export MCP_AIRTABLE_TOKEN=your_token_here
```

### Fallback Mode
If Airtable access fails, fall back to filesystem-based command discovery:
```bash
# Read commands from .claude/plugins/**/commands/*.md
ls .claude/plugins/*/commands/*.md
```

## Best Practices

1. **Update features.json regularly** - Keep status current
2. **Maintain spec files** - Complete specs improve matching
3. **Use priority levels** - P0 for critical features
4. **Generate before implementation** - Plan before executing
5. **Re-generate after spec changes** - Keep workflow current

## Differences from Foundation Workflow

| Aspect | Foundation Workflow | Feature Workflow |
|--------|-------------------|------------------|
| **Purpose** | Infrastructure setup | Feature implementation |
| **When** | One-time | Ongoing |
| **Source** | Tech stack only | features.json + specs |
| **Scope** | Foundation → Database | Implementation → Testing |
| **Output** | {PROJECT}-INFRASTRUCTURE-WORKFLOW.md | FEATURE-IMPLEMENTATION-WORKFLOW.md |
| **Commands** | Setup commands | Build commands |

## Examples

### Example 1: AI Chat Application

**features.json**:
```json
{
  "features": [
    {
      "id": "F001",
      "title": "AI chat interface",
      "priority": "P0",
      "status": "in-progress"
    }
  ]
}
```

**Generated Workflow**:
```markdown
## Feature: F001 - AI chat interface
**Status**: in-progress
**Priority**: P0

### Implementation Steps
- [ ] /iterate:tasks F001
- [ ] /nextjs-frontend:add-component ChatWindow
- [ ] /vercel-ai-sdk:add-streaming
- [ ] /fastapi-backend:add-endpoint "POST /api/chat"
- [ ] /supabase:add-auth
- [ ] /mem0:add-conversation-memory
- [ ] /quality:validate-code F001
- [ ] /testing:test F001
```

### Example 2: Multiple Features with Filtering

```bash
# Generate only P0 features
/planning:generate-feature-workflow --priority P0

# Generate only in-progress features
/planning:generate-feature-workflow --status in-progress

# Generate specific feature
/planning:generate-feature-workflow --feature F001

# Generate separate files per feature
/planning:generate-feature-workflow --split
```

## Maintenance

### Keeping Workflow Current

```bash
# After adding new features
/planning:add-feature "New feature"
/planning:generate-feature-workflow

# After updating specs
vim specs/F001/spec.md
/planning:generate-feature-workflow --feature F001

# After changing priority
# Edit features.json
/planning:generate-feature-workflow
```

### Validation

The workflow includes validation warnings:
- Features without specs
- Specs without implementation tasks
- Commands not available in tech stack
- Missing dependencies

## Technical Details

### Script: `generate-feature-workflow.py`

**Dependencies**:
- `requests` - HTTP requests to Airtable
- `json` - JSON parsing
- `os` - File system operations

**Environment Variables**:
- `AIRTABLE_TOKEN` or `MCP_AIRTABLE_TOKEN` - Required for Airtable access

**Exit Codes**:
- `0` - Success
- `1` - Error (missing data, API failure)

### Airtable Schema

**Tables Used**:
- `Tech Stacks` (tblG07GusbRMJ9h1I)
- `Plugins` (tblVEI2x2xArVx9ID)
- `Commands` (tblWKaSceuRJrBFC1)

**Relationships**:
```
Tech Stack → Plugins → Commands
```

## Related Skills

- `workflow-generation` (foundation) - Infrastructure workflows
- `spec-management` (planning) - Spec creation and management
- `task-management` (iterate) - Task layering and execution
- `execution-tracking` (implementation) - Progress tracking

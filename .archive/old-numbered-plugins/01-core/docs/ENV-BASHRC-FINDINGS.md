# Environment & Bashrc Management Findings

## Summary

Analyzed `multiagent-core` to understand environment file creation and bashrc management patterns for integration into `01-core` plugin.

---

## Key Findings

### 1. Two-Tier Key Management Pattern

**Critical Insight**: Separation between global and project-specific keys

```
Global MCP Keys (in ~/.bashrc)
├── MCP server authentication
├── Shared development tools
├── Platform CLI tokens
└── Set once, used across all projects

Project-Specific Keys (in .env)
├── Database credentials
├── Runtime API keys
├── Service integrations
└── NEVER use MCP_* prefix
```

**Example ~/.bashrc**:
```bash
# MCP Server Authentication (Global)
export MCP_GITHUB_TOKEN="ghp_xxxxx"
export MCP_POSTMAN_KEY="PMAK-xxxxx"
export MCP_FIGMA_TOKEN="figd_xxxxx"
```

**Example .env**:
```bash
# Project-specific (DO NOT use MCP_* prefix)
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
DATABASE_URL=postgresql://localhost:5432/mydb
STRIPE_SECRET_KEY=
```

---

### 2. Bashrc Management Status

**From `multiagent-core/cli.py:462-464`**:
```python
# TODO: Re-enable after fixing bashrc_organizer.py issues
#     ... bashrc organization code ...
```

**Conclusion**: **DO NOT automate bashrc management**
- Was previously automated but had issues
- Now disabled in multiagent-core
- Too fragile, varies by user setup
- **Recommendation**: Provide clear manual instructions instead

---

### 3. .env.template Structure

**Location**: `src/multiagent_core/templates/.env.template`

**Key Features**:
- Clear comments explaining global vs project separation
- Well-organized categories (Databases, APIs, Auth, URLs, Feature Flags)
- Helpful notes section at the end
- Empty values for secrets, defaults for config
- Reference to ~/.bashrc for MCP_* keys

**See**: Full template in `ENV-GENERATION-INTEGRATION-PLAN.md`

---

### 4. Intelligent Environment Generator

**Location**: `.agent-backup-20251020-140104/multiagent-security-env-generator.md`

**Purpose**: Analyzes project to generate comprehensive .env files

**Process**:
1. Reads project files (specs, docs, dependencies, .mcp.json)
2. Categorizes services by type:
   - AI/LLM (anthropic, openai, cohere, etc.)
   - Memory Systems (mem0, pinecone, weaviate, etc.)
   - Communication (sendgrid, twilio, slack, etc.)
   - Data & Storage (airtable, supabase, redis, postgresql, etc.)
   - Business Services (stripe, calendly, salesforce, etc.)
   - Infrastructure (vercel, aws, digitalocean, etc.)
   - MCP Servers (production only - dev uses ~/.bashrc)
3. Generates .env with:
   - Detected services
   - Dashboard URLs for obtaining keys
   - Source annotations (# Found in: file1.md, file2.py)
   - Empty values for secrets
   - Defaults for config

**Recommendation**: **Opt-in only** - too expensive for tokens to auto-invoke

---

### 5. Current multiagent-core Init Process

**From `cli.py:1570-1590`**:

```python
# Copy .env.template for project-specific API keys
console.print("Setting up .env.template...")
try:
    resource = templates_root.joinpath('.env.template')
    with importlib_resources.as_file(resource) as env_template_src:
        env_template_src = Path(env_template_src)
        dest_env_template = cwd / '.env.template'
        if not dest_env_template.exists():
            shutil.copy(env_template_src, dest_env_template)
            console.print("[green]Created .env.template (copy to .env and fill in your keys)[/green]")
        else:
            console.print("[dim]Skipped existing .env.template[/dim]")
except FileNotFoundError:
    console.print("[yellow]Warning: .env.template not found in package resources[/yellow]")
except Exception as e:
    console.print(f"[yellow]Warning: Could not copy .env.template: {e}[/yellow]")
```

**Displays guidance** (cli.py:1679-1701):
```python
[cyan]1. Global MCP Keys[/cyan] (in ~/.bashrc)
   - MCP server authentication
   - Shared development tools
   - Add to ~/.bashrc once, available everywhere

[cyan]2. Project Keys[/cyan] (in .env - THIS PROJECT ONLY)
   - Database credentials
   - Project-specific API keys
   - Copy .env.template to .env and add project-specific keys

  3. For MCP servers: Add MCP_* keys to ~/.bashrc once
```

---

## Recommended Integration into 01-core:init

### What to Include

#### 1. Mechanical Scripts (Auto-run during init)

✅ **copy-env-template.sh**
- Copy .env.template to project directory
- Check if already exists (skip if present)

✅ **update-gitignore.sh**
- Ensure .env is gitignored
- Add .env.local as well

✅ **create-toml-config.sh**
- IF Python project detected (setup.py, requirements.txt, or src/ directory)
- Create basic pyproject.toml scaffold
- Skip if already exists

✅ **create-json-config.sh**
- IF Node.js project detected (package.json exists)
- Ensure package.json has basic structure
- Skip if already exists

#### 2. Display Guidance (Output text)

✅ **key-management-guide.txt**
- Explain two-tier key management
- Show example ~/.bashrc entries
- Provide manual instructions for adding MCP_* keys
- Link to .env.template for project-specific keys

#### 3. Optional Slash Command (Opt-in, token-expensive)

⚠️ **/ core:env-generate**
- Invokes env-generator agent
- Analyzes project for service dependencies
- Generates comprehensive .env with categorized keys
- **Do NOT auto-invoke** - user must explicitly request

---

## What NOT to Include

❌ **Automated bashrc management**
- Too fragile, varies by user setup
- Was disabled in multiagent-core due to issues
- Provide manual instructions instead

❌ **Auto-invoke env-generator**
- Too expensive for tokens
- Not every project needs intelligent analysis
- Make it opt-in via slash command

❌ **Overwrite existing files**
- Always check if files exist first
- Skip with message if already present
- Never overwrite user customizations

---

## File Locations in multiagent-core

### Templates
```
src/multiagent_core/templates/
└── .env.template  # Copy this to 01-core
```

### Agents
```
.agent-backup-20251020-140104/
└── multiagent-security-env-generator.md  # Copy this to 01-core
```

### Enhancement Docs
```
docs/enhancements/04-completed/2025-10-12/
└── security-testing-env-patterns.md  # Reference for context
```

---

## Next Steps for 01-core

### Phase 1: Basic Environment Setup (Mechanical)

1. Create directory structure:
   ```
   plugins/01-core/skills/environment-setup/
   ├── scripts/
   │   ├── copy-env-template.sh
   │   ├── update-gitignore.sh
   │   ├── create-toml-config.sh
   │   └── create-json-config.sh
   ├── templates/
   │   ├── .env.template (copy from multiagent-core)
   │   ├── key-management-guide.txt
   │   └── pyproject.toml.template
   └── agent/
       └── env-generator.md (copy from multiagent-core)
   ```

2. Write mechanical scripts (see examples in ENV-GENERATION-INTEGRATION-PLAN.md)

3. Update `plugins/01-core/commands/init.md` to include env setup steps

4. Test the workflow

### Phase 2: Optional Intelligent Generation

1. Create `/core:env-generate` slash command
2. Copy env-generator.md agent from multiagent-core
3. Add permission to settings.local.json
4. Document usage in README

---

## Key Takeaways

1. **Two-tier separation is critical**: Global MCP keys in ~/.bashrc, project keys in .env
2. **Do NOT automate bashrc**: Provide manual instructions instead
3. **Mechanical > Intelligent**: Use scripts for deterministic work, agents for analysis
4. **Opt-in intelligence**: Make env-generator a separate command, not auto-invoked
5. **Never overwrite**: Always check if files exist first
6. **Clear guidance**: Display helpful instructions showing user what to do next

---

## Questions for Clarification

1. Should we copy env-generator.md to 01-core now, or wait until Phase 2?
2. Do you want pyproject.toml generation, or just .env focus for now?
3. Should key-management-guide.txt be inline in init.md output, or separate file?
4. Any specific categories to add to .env.template beyond what multiagent-core has?

---

**Status**: Research complete, integration plan ready
**Next**: Implement Phase 1 (mechanical scripts + templates)

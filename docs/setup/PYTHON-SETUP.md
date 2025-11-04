# Python Development Setup

## Virtual Environment

This project uses a Python virtual environment to manage dependencies for Python scripts across plugins.

### Quick Start

```bash
# Activate the virtual environment
source .venv/bin/activate

# Install dependencies (if needed)
pip install -r plugins/planning/skills/doc-sync/requirements.txt

# Deactivate when done
deactivate
```

### VS Code Configuration

The `.vscode/settings.json` file is configured to use the local virtual environment:

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python"
}
```

**After setup, reload VS Code**: Press `Ctrl+Shift+P` → "Developer: Reload Window"

### Installed Packages

The virtual environment includes:

- **mem0ai** - Memory layer for AI applications (OSS version)
- **chromadb** - Vector database for embeddings
- **openai** - OpenAI API for embeddings and LLM

### Running Scripts

All scripts can be run directly (they use `#!/usr/bin/env python3`):

```bash
# Run doc-sync scripts
./plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py

# Or with explicit python
.venv/bin/python plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py
```

### Troubleshooting

#### Red Squiggly Lines in VS Code

If you see import errors:

1. **Reload VS Code Window**: `Ctrl+Shift+P` → "Developer: Reload Window"
2. **Select Interpreter**: Click Python version in bottom-right → Select `.venv/bin/python`
3. **Check settings**: Verify `.vscode/settings.json` has correct interpreter path

#### Missing Packages

```bash
source .venv/bin/activate
pip install mem0ai chromadb openai
```

#### Externally Managed Environment Error

If you see "externally-managed-environment" error:

✅ **Use the virtual environment** (already created):
```bash
.venv/bin/pip install <package>
```

❌ **Never use** `--break-system-packages`

### Adding New Dependencies

1. Activate virtual environment: `source .venv/bin/activate`
2. Install package: `pip install <package-name>`
3. Update requirements: `pip freeze > requirements.txt` (or add manually)
4. Commit requirements file

### Environment Variables

Python scripts that use APIs require environment variables:

```bash
# Required for Mem0 OSS with OpenAI embeddings
export OPENAI_API_KEY=your_api_key_here

# Required for some scripts
export ANTHROPIC_API_KEY=your_api_key_here
```

**Never hardcode API keys!** Always use environment variables.

---

**Version**: Updated Nov 2025
**Python**: 3.12.3
**Virtual Environment**: `.venv/`

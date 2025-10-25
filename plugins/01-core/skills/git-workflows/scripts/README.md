# {{SKILL_NAME}} Scripts

Helper scripts for the {{SKILL_NAME}} skill.

## Available Scripts

### template-script.sh
**Purpose:** Generic bash script template
**Usage:** `./template-script.sh <input> [output]`

### template-helper.py
**Purpose:** Generic Python helper template
**Usage:** `./template-helper.py <input>`

## Adding New Scripts

1. Create script file in this directory
2. Make it executable: `chmod +x script-name.sh`
3. Follow naming conventions:
   - detect-* (detection/analysis)
   - validate-* (validation)
   - find-* (search/discovery)
   - setup-* (initialization)
   - check-* (verification)
   - scan-* (scanning)
   - analyze-* (analysis)

## Script Guidelines

**Bash scripts:**
- Use `set -euo pipefail` for error handling
- Add header comments with Purpose, Usage, Output
- Validate inputs before processing
- Provide clear error messages

**Python scripts:**
- Use type hints
- Add docstrings to functions/classes
- Use logging instead of print for status
- Return appropriate exit codes

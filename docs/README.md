# Documentation Directory

Organized documentation for the dev-lifecycle-marketplace plugin system.

## Directory Structure

```
docs/
├── README.md                    # This file
├── fixes/                       # Bug fixes and issue resolutions
├── setup/                       # Setup and configuration guides
├── reports/                     # Integration and analysis reports
├── verification/                # Verification and testing documentation
└── security/                    # Security rules and guidelines
```

## Contents

### 📋 Setup Documentation

**Location**: `setup/`

- **PYTHON-SETUP.md** - Python virtual environment setup for the project
  - Virtual environment configuration
  - Package dependencies
  - Environment variables
  - Troubleshooting guide

### 🔧 Fixes & Solutions

**Location**: `fixes/`

- **PYLANCE-FIXES-2025-11-03.md** - Resolved Pylance type annotation errors
  - Fixed `str | None` type hints
  - Fixed `str | Path` parameter types
  - Updated all doc-sync scripts

- **FIXES-2025-11-02-skill-tool-access.md** - Skill tool access improvements
  - Tool availability in skills
  - Skill framework updates

- **FIXES-2025-11-02-spec-sizing.md** - Specification sizing optimizations
  - Spec file size management
  - Best practices for spec writing

### 📊 Reports & Analysis

**Location**: `reports/`

- **ai-tech-stack-1-lifecycle-integration-report.md** - AI tech stack integration
  - Phase-by-phase integration analysis
  - Lifecycle plugin coordination
  - Full-stack AI application development

### ✅ Verification & Testing

**Location**: `verification/`

- **VERIFICATION-skill-instructions.md** - Skill instruction validation
  - Skill loading verification
  - Instruction format validation
  - Testing methodology

### 🔐 Security

**Location**: `security/`

- **SECURITY-RULES.md** - Critical security guidelines
  - API key handling (NO hardcoding!)
  - Environment variable best practices
  - Security validation checklist

## Quick Links

### For Contributors

- **Start here**: [`setup/PYTHON-SETUP.md`](setup/PYTHON-SETUP.md)
- **Security rules**: [`security/SECURITY-RULES.md`](security/SECURITY-RULES.md)
- **Recent fixes**: [`fixes/`](fixes/)

### For Users

- **Setup guide**: [`setup/PYTHON-SETUP.md`](setup/PYTHON-SETUP.md)
- **Integration examples**: [`reports/`](reports/)

## Document Types

### 1. Setup Guides
Setup and configuration documentation for getting started.
- Format: Step-by-step instructions
- Location: `setup/`

### 2. Fix Documentation
Records of bugs fixed and solutions implemented.
- Format: Problem → Solution → Verification
- Location: `fixes/`
- Naming: `FIXES-YYYY-MM-DD-description.md`

### 3. Integration Reports
Analysis of how components work together.
- Format: Technical analysis with examples
- Location: `reports/`
- Naming: `component-name-report.md`

### 4. Verification Documentation
Testing and validation procedures.
- Format: Test methodology and results
- Location: `verification/`
- Naming: `VERIFICATION-component.md`

### 5. Security Documentation
Security rules and compliance guidelines.
- Format: Rules → Best Practices → Validation
- Location: `security/`

## Contributing Documentation

When adding new documentation:

1. **Choose the right directory**:
   - Setup guides → `setup/`
   - Bug fixes → `fixes/`
   - Integration analysis → `reports/`
   - Testing procedures → `verification/`
   - Security rules → `security/`

2. **Use clear naming**:
   - Fixes: `FIXES-YYYY-MM-DD-description.md`
   - Verification: `VERIFICATION-component.md`
   - Reports: `component-name-report.md`
   - Setup: `COMPONENT-SETUP.md`

3. **Include standard sections**:
   - **Summary**: Quick overview
   - **Context**: Why this matters
   - **Details**: Implementation/solution
   - **Verification**: How to confirm it works

4. **Link to related docs**:
   - Reference other documentation
   - Cross-link setup guides and fixes

## Maintenance

### Archiving Old Documentation

When documentation becomes outdated:

1. Create `archive/` subdirectory in the relevant section
2. Move old docs to archive with date prefix
3. Update README to reflect archived status

Example:
```bash
mv fixes/OLD-FIX.md fixes/archive/2024-OLD-FIX.md
```

### Documentation Review

Quarterly review checklist:
- [ ] Verify all setup guides still work
- [ ] Check if fixes are still relevant
- [ ] Update security rules if needed
- [ ] Archive outdated reports

## Version History

- **2025-11-03**: Organized docs into subdirectories, added Pylance fixes
- **2025-11-02**: Added skill verification and spec sizing fixes
- **2024**: Initial documentation structure

---

**Last Updated**: November 3, 2025
**Maintainer**: dev-lifecycle-marketplace team

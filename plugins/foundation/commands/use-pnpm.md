---
allowed-tools: Bash, Read, Write
description: Convert Node.js project from npm to pnpm for faster worktree dependency installs
argument-hint: none
---

## Goal

Convert a Node.js project from npm to pnpm, enabling 80-90% faster dependency installs when creating multiple worktrees.

**Benefits:**
- ⚡ **5-10s installs** instead of 30-60s per worktree
- 💾 **75% less disk** - 600MB instead of 2GB for 4 worktrees
- 🔒 **Still isolated** - Each worktree gets correct versions
- 🤖 **Auto-detected** - Worktree system uses pnpm automatically

## Phase 1: Pre-flight Checks

Actions:
- Verify this is a Node.js project (package.json exists)
- Check if pnpm is already installed: `pnpm --version`
- Check current package manager (npm/yarn)
- Warn user about changes that will be made

Display:
```
📦 Project Analysis:
  • Package manager: npm (package-lock.json detected)
  • Dependencies: 150 packages
  • Disk usage: node_modules/ = 500MB

🎯 After conversion to pnpm:
  • First install: ~30-60s (downloads to ~/.pnpm-store/)
  • Future worktrees: ~5-10s (hardlinks from cache)
  • Disk per worktree: ~50MB (vs 500MB)
```

Ask user for confirmation to proceed.

## Phase 2: Install pnpm Globally

Actions:
- Check if pnpm is installed: `which pnpm`
- If not installed:
  ```bash
  npm install -g pnpm
  ```
- Verify installation: `pnpm --version`
- Display pnpm version installed

## Phase 3: Backup Current State

**IMPORTANT**: Create backup before making changes.

Actions:
- Create backup of package-lock.json (if exists)
  ```bash
  cp package-lock.json package-lock.json.backup
  ```
- Create backup of yarn.lock (if exists)
  ```bash
  cp yarn.lock yarn.lock.backup
  ```

Display:
```
✅ Backups created:
  • package-lock.json.backup
  • yarn.lock.backup (if existed)

You can restore with:
  mv package-lock.json.backup package-lock.json
  rm -rf node_modules pnpm-lock.yaml
  npm install
```

## Phase 4: Convert to pnpm

Actions:
- Remove old lock files and node_modules:
  ```bash
  trash-put node_modules package-lock.json yarn.lock 2>/dev/null || true
  ```
- Run pnpm install to create pnpm-lock.yaml:
  ```bash
  pnpm install
  ```
- Verify pnpm-lock.yaml created
- Show installation summary

**Note**: Uses `trash-put` for safe deletion (recoverable from trash)

## Phase 5: Verify Conversion

Actions:
- Check that pnpm-lock.yaml exists
- Verify node_modules created with pnpm structure
- Check package.json scripts still work:
  ```bash
  # Test common scripts
  pnpm run build --dry-run 2>/dev/null || echo "No build script"
  pnpm run dev --help 2>/dev/null || echo "No dev script"
  ```
- Confirm global cache created: `ls ~/.pnpm-store/ | head -5`

## Phase 6: Update Documentation

Actions:
- Check if README.md exists
- Add/update installation instructions in README.md:
  ```markdown
  ## Installation

  This project uses **pnpm** for faster dependency management:

  ```bash
  # Install pnpm globally (one time)
  npm install -g pnpm

  # Install dependencies
  pnpm install

  # Run dev server
  pnpm dev
  ```

  **Why pnpm?**
  - Faster installs (especially with multiple worktrees)
  - Less disk space (shared global cache)
  - Strict dependency resolution
  ```

- If .gitignore exists, ensure pnpm-lock.yaml is NOT ignored:
  ```bash
  # Remove pnpm-lock.yaml from .gitignore if present
  sed -i '/^pnpm-lock.yaml$/d' .gitignore
  ```

## Phase 7: Worktree Integration Verification

Actions:
- Verify worktree system will auto-detect pnpm
- Show how future worktrees will benefit:
  ```bash
  # Future worktree creation:
  git worktree add ../project-002 spec-002
  cd ../project-002
  pnpm install  # Uses cache, takes 5-10s instead of 60s
  ```

Display cache statistics:
```bash
du -sh ~/.pnpm-store/
```

## Phase 8: Summary & Next Steps

Display:
```
✅ Conversion Complete!

📦 Project now uses pnpm:
  • pnpm-lock.yaml created
  • Global cache: ~/.pnpm-store/
  • Backups: package-lock.json.backup

🚀 Usage:
  • Install: pnpm install
  • Add package: pnpm add <package>
  • Run script: pnpm dev

⚡ Worktree Performance:
  • First worktree: Downloads to cache (~30-60s)
  • Additional worktrees: Links from cache (~5-10s)
  • Automatic with /supervisor:init

📝 Next Steps:
  1. Test your scripts: pnpm run dev
  2. Commit changes: git add pnpm-lock.yaml package.json
  3. Update team: Share pnpm installation instructions
  4. Create worktrees: /supervisor:init <spec> (now 80% faster!)

💡 Tip: When creating 4+ worktrees, pnpm saves ~1.5GB disk and 2-3 minutes!
```

## Rollback Instructions

If conversion causes issues:

```bash
# Restore npm
trash-put node_modules pnpm-lock.yaml
mv package-lock.json.backup package-lock.json
npm install

# Remove pnpm global cache (optional)
trash-put ~/.pnpm-store/
```

## Error Handling

### pnpm Not Found After Install
```bash
# Reload shell
source ~/.bashrc  # or ~/.zshrc

# Or use full path
~/.npm-global/bin/pnpm install
```

### Peer Dependency Warnings
pnpm is stricter than npm. If you see peer dependency warnings:
```bash
# Auto-install peer dependencies
pnpm install --shamefully-hoist

# Or add to .npmrc:
echo "shamefully-hoist=true" >> .npmrc
pnpm install
```

### Script Compatibility
Some scripts may reference `npm` directly:
```json
// package.json - Update scripts if needed:
{
  "scripts": {
    // Before:
    "postinstall": "npm run build"
    // After:
    "postinstall": "pnpm run build"
  }
}
```

## Best Practices

✅ **DO**:
- Commit pnpm-lock.yaml to git
- Keep backups until team verifies conversion
- Update CI/CD pipelines to use pnpm
- Share pnpm installation with team

❌ **DON'T**:
- Mix npm and pnpm in same project
- Add pnpm-lock.yaml to .gitignore
- Delete backups immediately
- Force conversion without team buy-in

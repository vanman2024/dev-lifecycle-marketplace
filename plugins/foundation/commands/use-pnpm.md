---
description: Convert Node.js project from npm to pnpm for faster worktree dependency installs
argument-hint: none
---

**Arguments**: $ARGUMENTS

Goal: Convert Node.js project from npm to pnpm, optimized for worktree workflows with shared dependency cache.

Core Principles:
- Detect existing package manager
- Preserve all dependencies and versions
- Clean up npm artifacts safely with trash-put
- Validate conversion before finalizing

Phase 1: Discovery
Goal: Understand current project configuration

Actions:
- Detect current package manager:
  !{bash ls package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null || echo "none"}
- Read dependencies: @package.json
- Check pnpm installation: !{bash which pnpm || echo "not-installed"}
- Check for workspaces: !{bash grep -q "workspaces" package.json && echo "has-workspaces" || echo "no-workspaces"}

Phase 2: pnpm Installation
Goal: Ensure pnpm is available

Actions:
- If not installed, display: "Install pnpm: npm install -g pnpm"
- Or standalone: curl -fsSL https://get.pnpm.io/install.sh | sh -
- Verify: !{bash pnpm --version}

Phase 3: Backup and Clean
Goal: Safely remove npm artifacts

Actions:
- Backup existing lock files:
  !{bash test -f package-lock.json && cp package-lock.json package-lock.json.backup || true}
  !{bash test -f yarn.lock && cp yarn.lock yarn.lock.backup || true}
- Remove node_modules: !{bash trash-put node_modules 2>/dev/null || true}
- Move lock files to trash: !{bash trash-put package-lock.json yarn.lock 2>/dev/null || true}

Phase 4: pnpm Configuration
Goal: Configure pnpm for optimal performance

Actions:
- Create .npmrc with pnpm settings:
  shamefully-hoist=false, strict-peer-dependencies=false
  auto-install-peers=true, store-dir=~/.pnpm-store
- If workspaces exist, create pnpm-workspace.yaml
- Update .gitignore: node_modules/, .pnpm-store/

Phase 5: Dependency Installation
Goal: Install with pnpm and verify

Actions:
- Run pnpm install: !{bash pnpm install}
- Verify lock file: !{bash test -f pnpm-lock.yaml && echo "✓ Created" || echo "✗ Missing"}
- Check structure: !{bash ls -la node_modules/.pnpm 2>/dev/null | head -3}

Phase 6: Validation
Goal: Test conversion success

Actions:
- List dependencies: !{bash pnpm list --depth=0}
- Check outdated: !{bash pnpm outdated || true}
- Test build if exists: !{bash grep -q "\"build\":" package.json && pnpm build || echo "no-build"}

Phase 7: Documentation
Goal: Create migration documentation

Actions:
- Create PNPM_MIGRATION.md with:
  * Conversion details
  * Benefits (3x faster, shared cache, disk savings)
  * Usage commands
  * Worktree support explanation
- Remove backups: !{bash trash-put *.backup 2>/dev/null || true}

Phase 8: Summary
Goal: Report conversion results

Actions:
Display:
✅ pnpm Conversion Complete

Before: npm/yarn → After: pnpm

Files Created:
- pnpm-lock.yaml
- .npmrc
- PNPM_MIGRATION.md

Benefits:
✓ 3x faster installs
✓ Shared cache: ~/.pnpm-store
✓ Worktree optimized
✓ 70% disk savings

Next Steps:
1. Test: pnpm dev
2. Update CI/CD
3. Commit: git add pnpm-lock.yaml .npmrc
4. Team: Install pnpm, run 'pnpm install'

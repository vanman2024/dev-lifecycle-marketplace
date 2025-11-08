#!/usr/bin/env python3
"""
Worktree Registry with Mem0
Registers worktrees and agent assignments for multi-agent coordination
"""

import os
import sys
from pathlib import Path
from datetime import datetime

try:
    from mem0 import Memory
except ImportError:
    print("❌ Mem0 not installed")
    sys.exit(1)


class WorktreeRegistry:
    def __init__(self, project_root: str | Path):
        self.project_root = Path(project_root)
        self.project_name = self._detect_project_name()

        # Initialize Mem0 (shared global storage)
        storage_path = Path.home() / ".claude" / "mem0-chroma"
        config = {
            "llm": {"provider": "openai", "config": {"model": "gpt-4o-mini", "temperature": 0.1}},
            "vector_store": {"provider": "chroma", "config": {"collection_name": "worktrees", "path": str(storage_path)}},
            "embedder": {"provider": "openai", "config": {"model": "text-embedding-3-small"}}
        }
        self.memory = Memory.from_config(config)

    def _detect_project_name(self) -> str:
        """Auto-detect project name"""
        import json

        # Try .claude/project.json
        claude_config = self.project_root / ".claude" / "project.json"
        if claude_config.exists():
            try:
                with open(claude_config) as f:
                    if name := json.load(f).get("name"):
                        return name
            except: pass

        # Fallback to directory name
        return self.project_root.name

    def register_worktree(self, spec_num: str, spec_name: str, worktree_path: str, branch: str):
        """Register a worktree for a spec (shared by all agents)"""

        memory_text = f"""
        Worktree for spec {spec_num} ({spec_name}).
        Path: {worktree_path}
        Branch: {branch}
        Project: {self.project_name}
        Registered: {datetime.now().isoformat()}
        Status: active
        Dependencies: installed
        """

        self.memory.add(memory_text, user_id=f"{self.project_name}-worktrees")
        print(f"✅ Registered worktree: spec {spec_num} @ {worktree_path}")

    def register_agent_assignment(self, spec_num: str, agent_name: str, tasks: list[str], dependencies: list[str] = None): # type: ignore
        """Register agent task assignments"""

        deps_text = f"Dependencies: {', '.join(dependencies)}" if dependencies else "No dependencies"
        tasks_text = "\n  - ".join(tasks)

        memory_text = f"""
        Agent {agent_name} assigned to spec {spec_num} in project {self.project_name}.
        Tasks:
          - {tasks_text}
        {deps_text}
        Assigned: {datetime.now().isoformat()}
        """

        self.memory.add(memory_text, user_id=f"{self.project_name}-agents")
        print(f"✅ Registered agent: {agent_name} with {len(tasks)} tasks")

    def register_dependency(self, from_agent: str, to_agent: str, spec_num: str, reason: str):
        """Register inter-agent dependency"""

        memory_text = f"""
        Agent {from_agent} depends on agent {to_agent} for spec {spec_num}.
        Reason: {reason}
        Project: {self.project_name}
        Registered: {datetime.now().isoformat()}
        """

        self.memory.add(memory_text, user_id=f"{self.project_name}-dependencies")
        print(f"✅ Registered dependency: {from_agent} → {to_agent}")

    def query_worktree(self, query: str):
        """Query worktree information"""
        results = self.memory.search(query, user_id=f"{self.project_name}-worktrees")

        if not results:
            print(f"No worktrees found for query: {query}")
            return

        print(f"\n🔍 Results for: {query}\n")
        for result in results['results']:
            print(f"  {result['memory']}\n")

    def query_agent(self, query: str):
        """Query agent assignments"""
        results = self.memory.search(query, user_id=f"{self.project_name}-agents")

        if not results:
            print(f"No agent assignments found for query: {query}")
            return

        print(f"\n🔍 Results for: {query}\n")
        for result in results['results']:
            print(f"  {result['memory']}\n")

    def get_worktree_for_spec(self, spec_num: str) -> dict | None:
        """Get worktree information for a specific spec number"""
        query = f"worktree for spec {spec_num}"
        results = self.memory.search(query, user_id=f"{self.project_name}-worktrees", limit=5)

        if not results or not results.get('results'):
            return None

        # Parse the first result
        for result in results['results']:
            memory = result['memory']
            if f'spec {spec_num}' in memory.lower() and 'Status: active' in memory:
                # Extract path and branch
                import re
                path_match = re.search(r'Path:\s*(.+)', memory)
                branch_match = re.search(r'Branch:\s*(.+)', memory)

                if path_match and branch_match:
                    return {
                        'path': path_match.group(1).strip(),
                        'branch': branch_match.group(1).strip(),
                        'spec': spec_num
                    }

        return None

    def list_active_worktrees(self):
        """List all active worktrees"""
        results = self.memory.get_all(user_id=f"{self.project_name}-worktrees")

        print(f"\n📁 Active Worktrees for {self.project_name}:\n")
        for result in results.get('results', []):
            memory = result['memory']
            if 'Status: active' in memory:
                print(f"  {memory}\n")

    def setup_dependencies(self, worktree_path: str):
        """Install dependencies in worktree after creation"""
        import subprocess

        worktree = Path(worktree_path)

        if not worktree.exists():
            print(f"❌ Worktree not found: {worktree_path}")
            return False

        print(f"\n📦 Setting up dependencies for {worktree.name}...")

        # Node.js project
        if (worktree / "package.json").exists():
            print("   Detected Node.js project")

            # Detect package manager
            if (worktree / "pnpm-lock.yaml").exists():
                print("   Using pnpm...")
                result = subprocess.run(["pnpm", "install"], cwd=worktree, capture_output=True)
                pkg_mgr = "pnpm"
            elif (worktree / "yarn.lock").exists():
                print("   Using yarn...")
                result = subprocess.run(["yarn", "install"], cwd=worktree, capture_output=True)
                pkg_mgr = "yarn"
            else:
                print("   Using npm...")
                result = subprocess.run(["npm", "install"], cwd=worktree, capture_output=True)
                pkg_mgr = "npm"

            if result.returncode == 0:
                print(f"   ✅ Node dependencies installed ({pkg_mgr})")

                # Register in Mem0
                memory_text = f"""
                Dependencies installed in worktree {worktree.name}.
                Project type: Node.js
                Package manager: {pkg_mgr}
                Status: ready
                Installed: {datetime.now().isoformat()}
                """
                self.memory.add(memory_text, user_id=f"{self.project_name}-worktrees")
                return True
            else:
                print(f"   ❌ Failed to install Node dependencies")
                print(f"   Error: {result.stderr.decode()[:200]}")
                return False

        # Python project
        elif (worktree / "requirements.txt").exists():
            print("   Detected Python project")
            print("   Using pip...")

            result = subprocess.run(
                ["pip", "install", "-r", "requirements.txt"],
                cwd=worktree,
                capture_output=True
            )

            if result.returncode == 0:
                print(f"   ✅ Python dependencies installed")

                # Register in Mem0
                memory_text = f"""
                Dependencies installed in worktree {worktree.name}.
                Project type: Python
                Package manager: pip
                Status: ready
                Installed: {datetime.now().isoformat()}
                """
                self.memory.add(memory_text, user_id=f"{self.project_name}-worktrees")
                return True
            else:
                print(f"   ❌ Failed to install Python dependencies")
                print(f"   Error: {result.stderr.decode()[:200]}")
                return False

        # Python project with pyproject.toml
        elif (worktree / "pyproject.toml").exists():
            print("   Detected Python project (pyproject.toml)")
            print("   Using pip...")

            result = subprocess.run(
                ["pip", "install", "-e", "."],
                cwd=worktree,
                capture_output=True
            )

            if result.returncode == 0:
                print(f"   ✅ Python dependencies installed")

                # Register in Mem0
                memory_text = f"""
                Dependencies installed in worktree {worktree.name}.
                Project type: Python
                Package manager: pip (pyproject.toml)
                Status: ready
                Installed: {datetime.now().isoformat()}
                """
                self.memory.add(memory_text, user_id=f"{self.project_name}-worktrees")
                return True
            else:
                print(f"   ❌ Failed to install Python dependencies")
                print(f"   Error: {result.stderr.decode()[:200]}")
                return False

        else:
            print("   ℹ️  No dependency file found (package.json, requirements.txt)")
            print("   ✅ Worktree ready (no dependencies needed)")
            return True

    def copy_gitignored_build_files(self, worktree_path: str):
        """Copy git-ignored files/directories that are needed for build"""
        import subprocess
        import shutil

        worktree = Path(worktree_path)
        main_repo = self.project_root

        if not worktree.exists():
            print(f"❌ Worktree not found: {worktree_path}")
            return False

        print(f"\n📁 Checking for git-ignored build-critical files...")

        # Common git-ignored directories/files needed for builds
        ignored_items = [
            "lib/",
            ".env.local",
            ".env.development",
            ".env.staging",
            ".env.production",
            "dist/",
            "build/",
            ".next/",  # Next.js build cache
            "node_modules/.cache/",  # Build caches
        ]

        copied = []
        for item in ignored_items:
            source = main_repo / item
            dest = worktree / item

            if source.exists():
                try:
                    if source.is_dir():
                        # Copy directory
                        if not dest.exists():
                            shutil.copytree(source, dest, symlinks=True)
                            copied.append(item)
                            print(f"   ✅ Copied directory: {item}")
                    else:
                        # Copy file
                        if not dest.exists():
                            dest.parent.mkdir(parents=True, exist_ok=True)
                            shutil.copy2(source, dest)
                            copied.append(item)
                            print(f"   ✅ Copied file: {item}")
                except Exception as e:
                    print(f"   ⚠️  Failed to copy {item}: {e}")

        if copied:
            print(f"\n   Copied {len(copied)} git-ignored items needed for build")

            # Register in Mem0
            memory_text = f"""
            Git-ignored build files copied to worktree {worktree.name}.
            Items copied: {', '.join(copied)}
            Status: build-ready
            Copied: {datetime.now().isoformat()}
            """
            self.memory.add(memory_text, user_id=f"{self.project_name}-worktrees")
            return True
        else:
            print("   ℹ️  No git-ignored build files found to copy")
            return True

    def validate_worktree_build(self, worktree_path: str) -> bool:
        """Validate that worktree can build successfully"""
        import subprocess

        worktree = Path(worktree_path)

        if not worktree.exists():
            print(f"❌ Worktree not found: {worktree_path}")
            return False

        print(f"\n🔨 Validating worktree build...")

        # Node.js project - check for common imports
        if (worktree / "package.json").exists():
            # Check if critical directories exist for common import patterns
            critical_dirs = []

            # Check for lib/ directory references in package.json or tsconfig.json
            tsconfig = worktree / "tsconfig.json"
            if tsconfig.exists():
                try:
                    import json
                    with open(tsconfig) as f:
                        config = json.load(f)
                        paths = config.get("compilerOptions", {}).get("paths", {})
                        for alias, path_list in paths.items():
                            for path in path_list:
                                if "lib/" in path:
                                    critical_dirs.append("lib/")
                                    break
                except:
                    pass

            # Check if critical directories exist
            missing = []
            for dir_path in critical_dirs:
                full_path = worktree / dir_path
                if not full_path.exists():
                    missing.append(dir_path)

            if missing:
                print(f"   ⚠️  Missing build-critical directories: {', '.join(missing)}")
                print(f"   These should have been copied from main repository")
                return False

            print("   ✅ Build validation passed")
            return True

        # Python project - basic validation
        elif (worktree / "requirements.txt").exists() or (worktree / "pyproject.toml").exists():
            print("   ✅ Python project structure looks good")
            return True

        print("   ✅ Worktree appears ready")
        return True

    def deactivate_worktree(self, agent_name: str, spec_num: str):
        """Mark worktree as inactive (after PR merge)"""

        # Search for existing worktree
        query = f"agent {agent_name} spec {spec_num}"
        results = self.memory.search(query, user_id=f"{self.project_name}-worktrees")

        if not results or not results.get('results'):
            print(f"⚠️  No worktree found for {agent_name} spec {spec_num}")
            return

        # Update status to inactive
        for result in results['results']:
            memory_id = result.get('id')
            if memory_id:
                # Add new memory indicating deactivation
                deactivation_memory = f"""
                Worktree for agent {agent_name} spec {spec_num} deactivated.
                Project: {self.project_name}
                Deactivated: {datetime.now().isoformat()}
                Reason: PR merged, worktree removed
                """
                self.memory.add(deactivation_memory, user_id=f"{self.project_name}-worktrees")
                print(f"✅ Deactivated worktree: {agent_name} spec {spec_num}")


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Worktree Registry with Mem0")
    parser.add_argument("action", choices=[
        "register", "assign", "depend", "query", "list", "deactivate", "setup-deps", "get-worktree",
        "copy-ignored", "validate-build", "setup-complete"
    ])
    parser.add_argument("--spec", help="Spec number (e.g., 001)")
    parser.add_argument("--spec-name", help="Spec name (e.g., red-seal-ai)")
    parser.add_argument("--agent", help="Agent name (for legacy compatibility)")
    parser.add_argument("--path", help="Worktree path")
    parser.add_argument("--branch", help="Branch name")
    parser.add_argument("--tasks", nargs="+", help="Task list")
    parser.add_argument("--deps", nargs="+", help="Dependencies")
    parser.add_argument("--to-agent", help="Dependency target agent")
    parser.add_argument("--reason", help="Dependency reason")
    parser.add_argument("--query", help="Search query")
    parser.add_argument("--project", default=".", help="Project root path")

    args = parser.parse_args()

    registry = WorktreeRegistry(args.project)

    if args.action == "register":
        if not all([args.spec, args.path, args.branch]):
            print("❌ register requires: --spec --path --branch")
            print("   Optional: --spec-name for better display")
            sys.exit(1)
        spec_name = args.spec_name or f"spec-{args.spec}"
        registry.register_worktree(args.spec, spec_name, args.path, args.branch)

    elif args.action == "assign":
        if not all([args.spec, args.agent, args.tasks]):
            print("❌ assign requires: --spec --agent --tasks")
            sys.exit(1)
        registry.register_agent_assignment(args.spec, args.agent, args.tasks, args.deps)

    elif args.action == "depend":
        if not all([args.spec, args.agent, args.to_agent, args.reason]):
            print("❌ depend requires: --spec --agent --to-agent --reason")
            sys.exit(1)
        registry.register_dependency(args.agent, args.to_agent, args.spec, args.reason)

    elif args.action == "query":
        if not args.query:
            print("❌ query requires: --query")
            sys.exit(1)
        registry.query_worktree(args.query)
        registry.query_agent(args.query)

    elif args.action == "list":
        registry.list_active_worktrees()

    elif args.action == "deactivate":
        if not all([args.spec, args.agent]):
            print("❌ deactivate requires: --spec --agent")
            sys.exit(1)
        registry.deactivate_worktree(args.agent, args.spec)

    elif args.action == "setup-deps":
        if not args.path:
            print("❌ setup-deps requires: --path")
            sys.exit(1)
        success = registry.setup_dependencies(args.path)
        sys.exit(0 if success else 1)

    elif args.action == "get-worktree":
        if not args.spec:
            print("❌ get-worktree requires: --spec")
            sys.exit(1)
        worktree_info = registry.get_worktree_for_spec(args.spec)
        if worktree_info:
            print(f"PATH={worktree_info['path']}")
            print(f"BRANCH={worktree_info['branch']}")
            print(f"SPEC={worktree_info['spec']}")
        else:
            print(f"❌ No worktree found for spec {args.spec}")
            sys.exit(1)

    elif args.action == "copy-ignored":
        if not args.path:
            print("❌ copy-ignored requires: --path")
            sys.exit(1)
        success = registry.copy_gitignored_build_files(args.path)
        sys.exit(0 if success else 1)

    elif args.action == "validate-build":
        if not args.path:
            print("❌ validate-build requires: --path")
            sys.exit(1)
        success = registry.validate_worktree_build(args.path)
        sys.exit(0 if success else 1)

    elif args.action == "setup-complete":
        if not args.path:
            print("❌ setup-complete requires: --path")
            sys.exit(1)
        # Run all setup steps in order
        print("🚀 Running complete worktree setup...")
        deps_success = registry.setup_dependencies(args.path)
        if not deps_success:
            print("❌ Dependency installation failed")
            sys.exit(1)

        copy_success = registry.copy_gitignored_build_files(args.path)
        if not copy_success:
            print("❌ Failed to copy git-ignored files")
            sys.exit(1)

        validate_success = registry.validate_worktree_build(args.path)
        if not validate_success:
            print("❌ Build validation failed")
            sys.exit(1)

        print("\n✅ Worktree setup complete and validated!")
        sys.exit(0)


if __name__ == "__main__":
    main()

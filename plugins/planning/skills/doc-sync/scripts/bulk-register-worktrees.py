#!/usr/bin/env python3
"""
Bulk Worktree Registration
Creates and registers worktrees for ALL specs at once
"""

import os
import sys
import subprocess
from pathlib import Path
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

try:
    from mem0 import Memory
except ImportError:
    print("❌ Mem0 not installed")
    sys.exit(1)


class BulkWorktreeRegistry:
    def __init__(self, project_root: str | Path):
        self.project_root = Path(project_root)
        self.project_name = self._detect_project_name()

        # Initialize Mem0
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
        claude_config = self.project_root / ".claude" / "project.json"
        if claude_config.exists():
            try:
                with open(claude_config) as f:
                    if name := json.load(f).get("name"):
                        return name
            except: pass
        return self.project_root.name

    def find_all_specs(self) -> list[dict]:
        """Find all specs with layered-tasks.md"""
        specs_dir = self.project_root / "specs"
        if not specs_dir.exists():
            print("❌ No specs/ directory found")
            return []

        specs = []
        for spec_dir in sorted(specs_dir.iterdir()):
            if not spec_dir.is_dir():
                continue

            # Extract spec number (e.g., "001" from "001-user-auth")
            spec_name = spec_dir.name
            spec_num = spec_name.split("-")[0] if "-" in spec_name else spec_name

            # Check for layered-tasks.md
            layered_tasks = spec_dir / "agent-tasks" / "layered-tasks.md"
            if not layered_tasks.exists():
                print(f"⚠️  Skipping {spec_name} - no layered-tasks.md")
                continue

            # Parse agents from layered-tasks.md
            agents = self._extract_agents(layered_tasks)

            specs.append({
                "name": spec_name,
                "number": spec_num,
                "dir": spec_dir,
                "agents": agents,
                "layered_tasks": layered_tasks
            })

        return specs

    def _extract_agents(self, layered_tasks_path: Path) -> list[str]:
        """Extract agent names from layered-tasks.md"""
        agents = set()
        try:
            with open(layered_tasks_path) as f:
                for line in f:
                    # Look for @agent patterns
                    if "@" in line:
                        words = line.split()
                        for word in words:
                            if word.startswith("@"):
                                agent = word.strip("@").strip(":")
                                agents.add(agent)
        except Exception as e:
            print(f"⚠️  Error parsing {layered_tasks_path}: {e}")

        return sorted(list(agents))

    def create_worktree(self, spec_num: str, spec_name: str, agent: str) -> dict:
        """Create single worktree for agent"""
        branch = f"agent-{agent}-{spec_num}"
        worktree_path = f"../{self.project_name}-{spec_num}-{agent}"

        result = {
            "spec": spec_name,
            "agent": agent,
            "branch": branch,
            "path": worktree_path,
            "success": False,
            "error": None
        }

        try:
            # Check if worktree already exists
            check_cmd = ["git", "worktree", "list"]
            output = subprocess.check_output(check_cmd, cwd=self.project_root, text=True)
            if worktree_path in output:
                result["error"] = "Worktree already exists"
                return result

            # Create worktree
            cmd = ["git", "worktree", "add", worktree_path, "-b", branch]
            subprocess.run(cmd, cwd=self.project_root, check=True, capture_output=True)

            result["success"] = True
            return result

        except subprocess.CalledProcessError as e:
            result["error"] = e.stderr.decode() if e.stderr else str(e)
            return result

    def register_in_mem0(self, spec_num: str, spec_name: str, agent: str, worktree_path: str, branch: str):
        """Register worktree in Mem0"""
        memory_text = f"""
        Worktree for agent {agent} working on spec {spec_num} ({spec_name}).
        Path: {worktree_path}
        Branch: {branch}
        Project: {self.project_name}
        Registered: {datetime.now().isoformat()}
        Status: active
        """

        self.memory.add(memory_text, user_id=f"{self.project_name}-worktrees")

    def bulk_create(self, specs: list[dict], parallel: bool = True) -> dict:
        """Create worktrees for all specs"""
        total_worktrees = sum(len(spec["agents"]) for spec in specs)

        print(f"\n🚀 Bulk Worktree Creation")
        print(f"📊 Specs: {len(specs)}")
        print(f"🤖 Total Worktrees: {total_worktrees}")
        print(f"⚙️  Mode: {'Parallel' if parallel else 'Sequential'}\n")

        results = {
            "success": [],
            "failed": [],
            "skipped": []
        }

        if parallel:
            # Create worktrees in parallel
            with ThreadPoolExecutor(max_workers=10) as executor:
                futures = []
                for spec in specs:
                    for agent in spec["agents"]:
                        future = executor.submit(
                            self.create_worktree,
                            spec["number"],
                            spec["name"],
                            agent
                        )
                        futures.append((future, spec, agent))

                for future, spec, agent in futures:
                    result = future.result()
                    if result["success"]:
                        # Register in Mem0
                        self.register_in_mem0(
                            spec["number"],
                            spec["name"],
                            agent,
                            result["path"],
                            result["branch"]
                        )
                        results["success"].append(result)
                        print(f"✅ {spec['name']}/{agent} → {result['path']}")
                    elif "already exists" in result.get("error", ""):
                        results["skipped"].append(result)
                        print(f"⏭️  {spec['name']}/{agent} (already exists)")
                    else:
                        results["failed"].append(result)
                        print(f"❌ {spec['name']}/{agent}: {result['error']}")
        else:
            # Sequential creation
            for spec in specs:
                for agent in spec["agents"]:
                    result = self.create_worktree(spec["number"], spec["name"], agent)
                    if result["success"]:
                        self.register_in_mem0(
                            spec["number"],
                            spec["name"],
                            agent,
                            result["path"],
                            result["branch"]
                        )
                        results["success"].append(result)
                        print(f"✅ {spec['name']}/{agent} → {result['path']}")
                    elif "already exists" in result.get("error", ""):
                        results["skipped"].append(result)
                        print(f"⏭️  {spec['name']}/{agent} (already exists)")
                    else:
                        results["failed"].append(result)
                        print(f"❌ {spec['name']}/{agent}: {result['error']}")

        return results

    def print_summary(self, results: dict):
        """Print summary of bulk creation"""
        print(f"\n{'='*60}")
        print(f"📊 Bulk Creation Summary")
        print(f"{'='*60}")
        print(f"✅ Created:  {len(results['success'])}")
        print(f"⏭️  Skipped:  {len(results['skipped'])}")
        print(f"❌ Failed:   {len(results['failed'])}")
        print(f"{'='*60}\n")

        if results["failed"]:
            print("❌ Failed Worktrees:")
            for result in results["failed"]:
                print(f"  • {result['spec']}/{result['agent']}: {result['error']}")
            print()


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Bulk Worktree Creation with Mem0")
    parser.add_argument("--project", default=".", help="Project root path")
    parser.add_argument("--sequential", action="store_true", help="Create sequentially (default: parallel)")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be created without creating")

    args = parser.parse_args()

    registry = BulkWorktreeRegistry(args.project)

    # Find all specs
    print("🔍 Scanning for specs...")
    specs = registry.find_all_specs()

    if not specs:
        print("❌ No specs found with layered-tasks.md")
        sys.exit(1)

    print(f"✅ Found {len(specs)} specs\n")

    # Show what will be created
    print("📋 Specs to process:")
    for spec in specs:
        print(f"  • {spec['name']}: {', '.join(spec['agents'])}")
    print()

    if args.dry_run:
        print("🏃 Dry run - no worktrees will be created")
        total = sum(len(spec["agents"]) for spec in specs)
        print(f"Would create {total} worktrees")
        sys.exit(0)

    # Confirm
    response = input(f"Create worktrees for {len(specs)} specs? (y/N): ")
    if response.lower() != 'y':
        print("❌ Cancelled")
        sys.exit(0)

    # Create all worktrees
    results = registry.bulk_create(specs, parallel=not args.sequential)

    # Print summary
    registry.print_summary(results)


if __name__ == "__main__":
    main()

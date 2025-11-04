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

    def register_worktree(self, spec_num: str, agent_name: str, worktree_path: str, branch: str):
        """Register a worktree for an agent working on a spec"""

        memory_text = f"""
        Worktree for agent {agent_name} working on spec {spec_num}.
        Path: {worktree_path}
        Branch: {branch}
        Project: {self.project_name}
        Registered: {datetime.now().isoformat()}
        Status: active
        """

        self.memory.add(memory_text, user_id=f"{self.project_name}-worktrees")
        print(f"✅ Registered worktree: {agent_name} @ {worktree_path}")

    def register_agent_assignment(self, spec_num: str, agent_name: str, tasks: list[str], dependencies: list[str] = None):
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

    def list_active_worktrees(self):
        """List all active worktrees"""
        results = self.memory.get_all(user_id=f"{self.project_name}-worktrees")

        print(f"\n📁 Active Worktrees for {self.project_name}:\n")
        for result in results.get('results', []):
            memory = result['memory']
            if 'Status: active' in memory:
                print(f"  {memory}\n")

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
        "register", "assign", "depend", "query", "list", "deactivate"
    ])
    parser.add_argument("--spec", help="Spec number (e.g., 001)")
    parser.add_argument("--agent", help="Agent name (e.g., claude, copilot)")
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
        if not all([args.spec, args.agent, args.path, args.branch]):
            print("❌ register requires: --spec --agent --path --branch")
            sys.exit(1)
        registry.register_worktree(args.spec, args.agent, args.path, args.branch)

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


if __name__ == "__main__":
    main()

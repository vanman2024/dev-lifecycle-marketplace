#!/usr/bin/env python3
"""
Query Documentation Relationships
Natural language queries against synced documentation
"""

import sys
from pathlib import Path

try:
    from mem0 import Memory
except ImportError:
    print("❌ Mem0 not installed. Activate venv: source /tmp/mem0-env/bin/activate")
    sys.exit(1)


def _detect_project_name() -> str:
    """Auto-detect project name"""
    import json
    import subprocess

    # Try to find project root
    cwd = Path.cwd()

    # Priority 1: .claude/project.json
    claude_config = cwd / ".claude" / "project.json"
    if claude_config.exists():
        try:
            with open(claude_config) as f:
                data = json.load(f)
                if data.get("name"):
                    return data["name"]
        except:
            pass

    # Priority 2: package.json
    package_json = cwd / "package.json"
    if package_json.exists():
        try:
            with open(package_json) as f:
                data = json.load(f)
                if data.get("name"):
                    return data["name"]
        except:
            pass

    # Priority 3: Git repository
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode == 0:
            repo_path = Path(result.stdout.strip())
            return repo_path.name
    except:
        pass

    # Priority 4: Current directory
    return cwd.name


def query_docs(query: str, project_name: str | None = None):
    """Query documentation relationships"""

    # Auto-detect project if not specified
    if not project_name:
        project_name = _detect_project_name()
        print(f"📌 Project: {project_name}\n")

    # Initialize Mem0 with ChromaDB (same as sync)
    storage_path = Path.home() / ".claude" / "mem0-chroma"

    config = {
        "llm": {
            "provider": "openai",
            "config": {
                "model": "gpt-4o-mini",
                "temperature": 0.1
            }
        },
        "vector_store": {
            "provider": "chroma",
            "config": {
                "collection_name": "documentation",
                "path": str(storage_path),
            }
        },
        "embedder": {
            "provider": "openai",
            "config": {
                "model": "text-embedding-3-small"
            }
        }
    }
    memory = Memory.from_config(config)

    # Search
    print(f"🔍 Query: {query}")
    print()

    results = memory.search(query, user_id=project_name, limit=10)

    if not results.get("results"):
        print("❌ No results found")
        return

    print(f"📊 Found {len(results['results'])} results:")
    print("="*60)

    for i, result in enumerate(results["results"], 1):
        memory_text = result.get("memory", "")
        score = result.get("score", 0)

        print(f"\n{i}. [Score: {score:.3f}]")
        print(f"   {memory_text}")

    print("\n" + "="*60)


def main():
    if len(sys.argv) < 2:
        print("Usage: python query-docs.py \"your query here\"")
        print()
        print("Examples:")
        print("  python query-docs.py \"What specs reference security.md?\"")
        print("  python query-docs.py \"Why does spec 001 use OAuth?\"")
        print("  python query-docs.py \"What specs implement ADR-0005?\"")
        print("  python query-docs.py \"What depends on authentication?\"")
        sys.exit(1)

    query = " ".join(sys.argv[1:])
    query_docs(query)


if __name__ == "__main__":
    main()

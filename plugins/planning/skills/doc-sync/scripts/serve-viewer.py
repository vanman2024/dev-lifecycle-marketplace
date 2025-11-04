#!/usr/bin/env python3
"""
Documentation Viewer API Server
Serves Mem0 data to web viewer
"""

import json
import os
import re
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

try:
    from mem0 import Memory
except ImportError:
    print("❌ Mem0 not installed")
    exit(1)


# Global memory instance
_memory_instance = None

def get_memory():
    global _memory_instance
    if _memory_instance is None:
        storage_path = Path.home() / ".claude" / "mem0-chroma"
        config = {
            "llm": {"provider": "openai", "config": {"model": "gpt-4o-mini", "temperature": 0.1}},
            "vector_store": {"provider": "chroma", "config": {"collection_name": "documentation", "path": str(storage_path)}},
            "embedder": {"provider": "openai", "config": {"model": "text-embedding-3-small"}}
        }
        _memory_instance = Memory.from_config(config)
    return _memory_instance


class ViewerAPI(BaseHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        # CORS headers
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()

        # Route API calls
        if path == '/api/projects':
            self.serve_projects()
        elif path.startswith('/api/docs/'):
            project = path.split('/')[-1]
            self.serve_docs(project)
        elif path.startswith('/api/graph/'):
            project = path.split('/')[-1]
            self.serve_graph(project)
        else:
            self.wfile.write(json.dumps({"error": "Not found"}).encode())

    def serve_projects(self):
        """List all projects in registry"""
        # Scan ChromaDB to find all unique project user_ids
        import sqlite3

        storage_path = Path.home() / ".claude" / "mem0-chroma"
        db_path = storage_path / "chroma.sqlite3"

        projects = []

        if db_path.exists():
            try:
                # Query ChromaDB's metadata table for unique user_ids
                # This is a hack but ChromaDB doesn't expose this API easily
                # For now, use known projects
                projects = ["dev-lifecycle-marketplace"]

                # Try to detect from directory names in ~/Projects or current workspace
                for proj_dir in [Path.home() / "Projects", Path.cwd().parent]:
                    if proj_dir.exists():
                        for subdir in proj_dir.iterdir():
                            if subdir.is_dir() and (subdir / ".claude").exists():
                                projects.append(subdir.name)

                projects = list(set(projects))  # Remove duplicates
            except Exception as e:
                projects = ["dev-lifecycle-marketplace"]
        else:
            projects = ["dev-lifecycle-marketplace"]

        self.wfile.write(json.dumps({"projects": projects}).encode())

    def serve_docs(self, project):
        """Get all docs for a project, grouped by document"""
        memory = get_memory()
        results = memory.get_all(user_id=project)

        # Group memories by document
        doc_groups = {}

        for result in results.get("results", []):
            mem_text = result.get("memory", "")

            # Extract document identifier
            doc_id = None
            doc_type = None

            # Check for Specification
            spec_match = re.match(r'Specification (\d+)', mem_text)
            if spec_match:
                doc_id = f"spec-{spec_match.group(1)}"
                doc_type = "specs"
            # Check for spec references
            elif "specification" in mem_text.lower():
                ref_match = re.search(r'specification (\d+)', mem_text, re.IGNORECASE)
                if ref_match:
                    doc_id = f"spec-{ref_match.group(1)}"
                    doc_type = "specs"

            # Check for Architecture
            if not doc_id and ("Architecture" in mem_text or "architecture" in mem_text.lower()):
                # Extract filename
                arch_match = re.search(r'([a-z-]+\.md)', mem_text)
                if arch_match:
                    doc_id = f"arch-{arch_match.group(1)}"
                    doc_type = "architecture"
                else:
                    doc_id = "arch-general"
                    doc_type = "architecture"

            # Check for ADR
            if not doc_id and "ADR" in mem_text:
                adr_match = re.search(r'ADR-?(\d+|[a-z-]+)', mem_text, re.IGNORECASE)
                if adr_match:
                    doc_id = f"adr-{adr_match.group(1)}"
                    doc_type = "adrs"

            # Check for Roadmap
            if not doc_id and ("Phase" in mem_text or "roadmap" in mem_text.lower()):
                doc_id = "roadmap"
                doc_type = "roadmap"

            # Group memories
            if doc_id and doc_type:
                if doc_id not in doc_groups:
                    doc_groups[doc_id] = {
                        "type": doc_type,
                        "id": doc_id,
                        "memories": []
                    }
                doc_groups[doc_id]["memories"].append(mem_text)

        # Format for frontend
        docs = {
            "specs": [],
            "architecture": [],
            "adrs": [],
            "roadmap": []
        }

        for doc_id, group in doc_groups.items():
            doc_type = group["type"]
            docs[doc_type].append({
                "id": doc_id,
                "memories": group["memories"]
            })

        self.wfile.write(json.dumps(docs).encode())

    def serve_graph(self, project):
        """Generate graph data for visualization"""
        memory = get_memory()
        results = memory.get_all(user_id=project)

        nodes = []
        edges = []
        node_id = 0

        node_map = {}  # memory text -> node id

        for result in results.get("results", []):
            memory = result.get("memory", "")

            # Skip duplicates
            if memory in node_map:
                continue

            # Determine node type and label
            node_type = "other"
            label = memory[:50] + "..." if len(memory) > 50 else memory
            color = "#999"

            if "Specification" in memory:
                node_type = "spec"
                label = memory.split(".")[0]  # First sentence
                color = "#4CAF50"
            elif "Architecture" in memory:
                node_type = "architecture"
                color = "#2196F3"
            elif "ADR" in memory:
                node_type = "adr"
                color = "#FF9800"

            nodes.append({
                "id": node_id,
                "label": label,
                "title": memory,  # Hover tooltip
                "color": color,
                "group": node_type
            })

            node_map[memory] = node_id
            node_id += 1

        # Create edges from "references", "implements", "depends on" patterns
        for result in results.get("results", []):
            memory = result.get("memory", "")

            if memory not in node_map:
                continue

            from_id = node_map[memory]

            # Find references to other docs
            for other_memory, to_id in node_map.items():
                if other_memory == memory:
                    continue

                # Check for relationship keywords
                if any(word in memory.lower() for word in ["references", "implements", "depends on"]):
                    # Extract what it references
                    if any(part in other_memory for part in memory.split()):
                        edges.append({
                            "from": from_id,
                            "to": to_id,
                            "arrows": "to"
                        })

        graph_data = {
            "nodes": nodes,
            "edges": edges
        }

        self.wfile.write(json.dumps(graph_data).encode())

    def log_message(self, format, *args):
        pass  # Suppress logs


def main():
    port = 8766
    print(f"🌐 Documentation Viewer API")
    print(f"📡 Server running on http://localhost:{port}")
    print(f"🔗 Open viewer: file://{Path.home()}/.claude/doc-viewer.html")
    print(f"⏹️  Press Ctrl+C to stop")
    print()

    server = HTTPServer(('localhost', port), ViewerAPI)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 Server stopped")


if __name__ == "__main__":
    main()

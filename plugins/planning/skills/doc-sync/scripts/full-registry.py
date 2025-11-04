#!/usr/bin/env python3
"""
Full Documentation Registry
Scans ALL documentation: specs, architecture, ADRs, roadmap
Creates complete memory registry in Mem0
"""

import os
import re
import sys
import time
from pathlib import Path
from datetime import datetime

try:
    from mem0 import Memory
except ImportError:
    print("❌ Mem0 not installed. Activate venv: source /tmp/mem0-env/bin/activate")
    sys.exit(1)


class FullDocRegistry:
    def __init__(self, project_root: str | Path, project_name: str | None = None):
        self.project_root = Path(project_root)

        # Auto-detect project name if not provided
        if not project_name:
            project_name = self._detect_project_name()

        self.project_name = project_name
        print(f"📌 Project: {self.project_name}")
        print(f"📂 Root: {self.project_root}")
        print()

        # Initialize Mem0 with ChromaDB
        storage_path = Path.home() / ".claude" / "mem0-chroma"
        storage_path.mkdir(parents=True, exist_ok=True)

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
        self.memory = Memory.from_config(config)

        self.stats = {
            "specs": 0,
            "architecture_docs": 0,
            "adrs": 0,
            "roadmap": 0,
            "total_memories": 0
        }

    def _detect_project_name(self) -> str:
        """Auto-detect project name from multiple sources"""
        import json
        import subprocess

        # Priority 1: .claude/project.json
        claude_config = self.project_root / ".claude" / "project.json"
        if claude_config.exists():
            try:
                with open(claude_config) as f:
                    data = json.load(f)
                    if data.get("name"):
                        return data["name"]
            except:
                pass

        # Priority 2: package.json name
        package_json = self.project_root / "package.json"
        if package_json.exists():
            try:
                with open(package_json) as f:
                    data = json.load(f)
                    if data.get("name"):
                        return data["name"]
            except:
                pass

        # Priority 3: Git repository name
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--show-toplevel"],
                cwd=self.project_root,
                capture_output=True,
                text=True,
                timeout=2
            )
            if result.returncode == 0:
                repo_path = Path(result.stdout.strip())
                return repo_path.name
        except:
            pass

        # Priority 4: Directory name
        return self.project_root.name

    def scan_all(self):
        """Scan all documentation types"""
        print("🔍 Full Documentation Registry Scan")
        print("=" * 60)
        print()

        self.scan_specs()
        self.scan_architecture()
        self.scan_adrs()
        self.scan_roadmap()

        print("\n" + "=" * 60)
        print("📊 Registry Summary")
        print("=" * 60)
        print(f"Specs scanned: {self.stats['specs']}")
        print(f"Architecture docs: {self.stats['architecture_docs']}")
        print(f"ADRs documented: {self.stats['adrs']}")
        print(f"Roadmap parsed: {self.stats['roadmap']}")
        print(f"Total memories created: {self.stats['total_memories']}")
        print("=" * 60)

        # Give Mem0 time to persist
        print("\nPersisting to ChromaDB...")
        time.sleep(2)
        print("✅ Full registry complete")

    def scan_specs(self):
        """Scan specs directory"""
        specs_dir = self.project_root / "specs"
        if not specs_dir.exists():
            print("⚠️  No specs/ directory")
            return

        print("📄 Scanning specs/...")
        for spec_dir in sorted(specs_dir.iterdir()):
            if not spec_dir.is_dir():
                continue

            spec_file = spec_dir / "spec.md"
            if spec_file.exists():
                self._process_spec(spec_dir.name, spec_file)
                self.stats["specs"] += 1

        print(f"   ✅ {self.stats['specs']} specs registered\n")

    def _process_spec(self, spec_id: str, spec_file: Path):
        """Process a single spec with bidirectional linking"""
        content = spec_file.read_text()
        match = re.match(r'(\d+)-(.+)', spec_id)
        if not match:
            return

        number, name = match.groups()

        # Extract references
        arch_refs = re.findall(r'@docs/architecture/([^#\s]+\.md)(?:#([^\s]+))?', content)

        # Flexible ADR pattern matching (same as in _process_adr)
        # Matches: ADR-001, ADR-0001, adr-feature-name, decision-name
        adr_refs = re.findall(r'(?:ADR|adr)-(\d+):?\s*([^\n]*)|(?:ADR|adr)-([a-z-]+)', content, re.IGNORECASE)

        dep_match = re.search(r'dependencies:\s*\[([^\]]+)\]', content, re.IGNORECASE)
        dependencies = []
        if dep_match:
            dependencies = [d.strip() for d in dep_match.group(1).split(',')]

        # Create main spec memory
        memory_parts = [
            f"[SPEC] Specification {number} ({name})"
        ]

        if arch_refs:
            arch_list = ", ".join([f"{file}#{section}" if section else file for file, section in arch_refs])
            memory_parts.append(f"references architecture docs: {arch_list}")

        if adr_refs:
            # Normalize ADR references
            normalized_adrs = []
            for num, desc, name_ref in adr_refs:
                if num:  # ADR-001 pattern
                    adr_id = f"ADR-{num}"
                    if desc.strip():
                        normalized_adrs.append(f"{adr_id}: {desc.strip()}")
                    else:
                        normalized_adrs.append(adr_id)
                elif name_ref:  # adr-feature-name pattern
                    normalized_adrs.append(f"ADR-{name_ref}")

            if normalized_adrs:
                memory_parts.append(f"implements: {', '.join(normalized_adrs)}")

        if dependencies:
            memory_parts.append(f"depends on specs: {', '.join(dependencies)}")

        memory_parts.append(f"Last modified: {datetime.fromtimestamp(spec_file.stat().st_mtime).isoformat()}")

        memory_text = ". ".join(memory_parts)
        self.memory.add(memory_text, user_id=self.project_name)
        self.stats["total_memories"] += 1

        # Create BIDIRECTIONAL links - reverse memories

        # Spec → Architecture (reverse: Architecture → Spec)
        for arch_file, section in arch_refs:
            reverse_memory = (
                f"[ARCHITECTURE] {arch_file} "
                f"{'section #' + section if section else ''} "
                f"is referenced by specification {number} ({name})"
            ).replace('  ', ' ').strip()

            self.memory.add(reverse_memory, user_id=self.project_name)
            self.stats["total_memories"] += 1

        # Spec → ADR (reverse: ADR → Spec)
        for num, desc, name_ref in adr_refs:
            if num:
                adr_id = f"ADR-{num}"
            elif name_ref:
                adr_id = f"ADR-{name_ref}"
            else:
                continue

            reverse_memory = (
                f"[ADR] {adr_id} is implemented by specification {number} ({name})"
            )
            self.memory.add(reverse_memory, user_id=self.project_name)
            self.stats["total_memories"] += 1

        # Spec → Spec dependencies (reverse: Spec → dependents)
        for dep_spec in dependencies:
            reverse_memory = (
                f"[SPEC] Specification {dep_spec} has dependent specification {number} ({name})"
            )
            self.memory.add(reverse_memory, user_id=self.project_name)
            self.stats["total_memories"] += 1

    def scan_architecture(self):
        """Scan architecture documentation with hierarchy"""
        arch_dir = self.project_root / "docs" / "architecture"
        if not arch_dir.exists():
            print("⚠️  No docs/architecture/ directory")
            return

        print("🏗️  Scanning docs/architecture/...")

        # First pass: register all architecture docs
        arch_files = {}
        for arch_file in sorted(arch_dir.glob("*.md")):
            arch_files[arch_file.name] = arch_file
            self._process_architecture(arch_file)
            self.stats["architecture_docs"] += 1

        # Second pass: create cross-reference memories
        for filename, arch_file in arch_files.items():
            self._process_architecture_references(arch_file, arch_files)

        print(f"   ✅ {self.stats['architecture_docs']} architecture docs registered\n")

    def _process_architecture(self, arch_file: Path):
        """Process architecture document"""
        content = arch_file.read_text()
        filename = arch_file.name

        # Extract summary (first paragraph or ## Overview section)
        summary_match = re.search(r'##\s*(?:Overview|Summary)\s*\n+([^\n#]+)', content, re.IGNORECASE)
        if not summary_match:
            # Try first paragraph after title
            lines = [l.strip() for l in content.split('\n') if l.strip() and not l.startswith('#')]
            summary = lines[0] if lines else "Architecture documentation"
        else:
            summary = summary_match.group(1).strip()

        if len(summary) > 150:
            summary = summary[:147] + "..."

        memory_text = (
            f"[ARCHITECTURE] {filename}: {summary}. "
            f"Last modified: {datetime.fromtimestamp(arch_file.stat().st_mtime).isoformat()}"
        )

        self.memory.add(memory_text, user_id=self.project_name)
        self.stats["total_memories"] += 1

    def _process_architecture_references(self, arch_file: Path, all_arch_files: dict):
        """Process cross-references between architecture documents"""
        content = arch_file.read_text()
        filename = arch_file.name

        # Find references to other architecture docs
        # Pattern: @docs/architecture/filename.md or just filename.md
        refs = re.findall(r'@docs/architecture/([^\s\)]+\.md)|(?:See|Refer to|Details in)\s+([a-z-]+\.md)', content, re.IGNORECASE)

        referenced_docs = set()
        for ref1, ref2 in refs:
            ref = ref1 or ref2
            if ref in all_arch_files:
                referenced_docs.add(ref)

        # Create hierarchical relationship memories
        if referenced_docs:
            refs_list = ", ".join(referenced_docs)
            memory_text = (
                f"[ARCHITECTURE] {filename} references architecture documents: {refs_list}. "
                f"This creates a documentation hierarchy."
            )
            self.memory.add(memory_text, user_id=self.project_name)
            self.stats["total_memories"] += 1

            # Create reverse links (bidirectional)
            for ref_doc in referenced_docs:
                reverse_memory = (
                    f"[ARCHITECTURE] {ref_doc} is referenced by parent document {filename}"
                )
                self.memory.add(reverse_memory, user_id=self.project_name)
                self.stats["total_memories"] += 1

    def scan_adrs(self):
        """Scan Architecture Decision Records with flexible naming"""
        adr_dir = self.project_root / "docs" / "adr"
        if not adr_dir.exists():
            print("⚠️  No docs/adr/ directory")
            return

        print("📋 Scanning docs/adr/...")
        for adr_file in sorted(adr_dir.glob("*.md")):
            self._process_adr(adr_file)
            self.stats["adrs"] += 1

        print(f"   ✅ {self.stats['adrs']} ADRs registered\n")

    def _process_adr(self, adr_file: Path):
        """Process ADR document with flexible naming patterns"""
        content = adr_file.read_text()
        filename = adr_file.name

        # Try multiple ADR naming patterns:
        # 1. 0001-title.md
        # 2. ADR-001-title.md or adr-001-title.md
        # 3. decision-title.md
        # 4. adr-title.md

        adr_id = None
        title = None

        # Pattern 1: 0001-title.md
        match = re.match(r'(\d+)-(.+)\.md', filename)
        if match:
            adr_id = f"ADR-{match.group(1)}"
            title = match.group(2).replace('-', ' ').title()

        # Pattern 2: ADR-001-title.md
        if not match:
            match = re.match(r'(?:adr|ADR)-(\d+)-(.+)\.md', filename, re.IGNORECASE)
            if match:
                adr_id = f"ADR-{match.group(1)}"
                title = match.group(2).replace('-', ' ').title()

        # Pattern 3: decision-title.md or adr-title.md
        if not match:
            match = re.match(r'(?:decision|adr)-(.+)\.md', filename, re.IGNORECASE)
            if match:
                adr_id = f"ADR-{filename.replace('.md', '')}"
                title = match.group(1).replace('-', ' ').title()

        # Pattern 4: anything else in adr/ directory
        if not adr_id:
            adr_id = f"ADR-{filename.replace('.md', '')}"
            title = filename.replace('.md', '').replace('-', ' ').title()

        # Extract decision from ## Decision section
        decision_match = re.search(r'##\s*Decision\s*\n+([^\n#]+)', content, re.IGNORECASE)
        decision = decision_match.group(1).strip() if decision_match else "Decision documented"
        if len(decision) > 150:
            decision = decision[:147] + "..."

        # Extract status
        status_match = re.search(r'status:\s*(\w+)', content, re.IGNORECASE)
        status = status_match.group(1) if status_match else "accepted"

        # Extract related architecture docs
        arch_refs = re.findall(r'@docs/architecture/([^\s\)]+\.md)', content)

        memory_parts = [
            f"[ADR] {adr_id}: {title}",
            f"Decision: {decision}",
            f"Status: {status}"
        ]

        if arch_refs:
            memory_parts.append(f"Relates to architecture: {', '.join(set(arch_refs))}")

        memory_parts.append(f"Last modified: {datetime.fromtimestamp(adr_file.stat().st_mtime).isoformat()}")

        memory_text = ". ".join(memory_parts)
        self.memory.add(memory_text, user_id=self.project_name)
        self.stats["total_memories"] += 1

        # Create reverse links to architecture docs
        for arch_ref in set(arch_refs):
            reverse_memory = (
                f"[ARCHITECTURE] {arch_ref} has architectural decisions documented in {adr_id}"
            )
            self.memory.add(reverse_memory, user_id=self.project_name)
            self.stats["total_memories"] += 1

    def scan_roadmap(self):
        """Scan roadmap document"""
        roadmap_file = self.project_root / "docs" / "ROADMAP.md"
        if not roadmap_file.exists():
            print("⚠️  No docs/ROADMAP.md file")
            return

        print("🗺️  Scanning docs/ROADMAP.md...")

        content = roadmap_file.read_text()

        # Extract milestones/phases
        phases = re.findall(r'##\s*(Phase \d+[^#\n]+)\s*\n+([^\n]+)', content)

        for phase_title, phase_desc in phases:
            memory_text = (
                f"[ROADMAP] {phase_title.strip()}: {phase_desc.strip()}. "
                f"Last modified: {datetime.fromtimestamp(roadmap_file.stat().st_mtime).isoformat()}"
            )
            self.memory.add(memory_text, user_id=self.project_name)
            self.stats["total_memories"] += 1

        self.stats["roadmap"] = len(phases)
        print(f"   ✅ {self.stats['roadmap']} roadmap phases registered\n")


def main():
    # Detect project root (6 levels up from script)
    script_path = Path(__file__).resolve()
    project_root = script_path.parent.parent.parent.parent.parent.parent

    print(f"Project root: {project_root}\n")

    registry = FullDocRegistry(project_root)
    registry.scan_all()


if __name__ == "__main__":
    main()

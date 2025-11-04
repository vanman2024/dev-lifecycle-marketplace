#!/usr/bin/env python3
"""
Documentation Sync to Mem0
Scans specs, architecture, and ADRs to populate Mem0 with relationships
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
    print("❌ Mem0 not installed. Install with: pip install mem0ai")
    print("   Or activate the venv: source /tmp/mem0-env/bin/activate")
    sys.exit(1)


class DocSync:
    def __init__(self, project_root: str | Path, project_name: str | None = None, quiet: bool = False):
        self.project_root = Path(project_root)
        self.quiet = quiet

        # Auto-detect project name if not provided
        if not project_name:
            project_name = self._detect_project_name()

        self.project_name = project_name
        if not quiet:
            print(f"📌 Project: {self.project_name}")

        # Initialize Mem0 with ChromaDB for reliable local persistence
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
                    "path": str(storage_path),  # ChromaDB for reliable persistence
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
            "specs_scanned": 0,
            "arch_refs_found": 0,
            "adr_refs_found": 0,
            "dependencies_found": 0,
            "memories_created": 0
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

    def scan_specs(self):
        """Scan all spec files and extract relationships"""
        specs_dir = self.project_root / "specs"

        if not specs_dir.exists():
            if not self.quiet:
                print(f"⚠️  No specs directory found at {specs_dir}")
            return

        for spec_dir in sorted(specs_dir.iterdir()):
            if not spec_dir.is_dir():
                continue

            spec_file = spec_dir / "spec.md"
            if not spec_file.exists():
                continue

            self.stats["specs_scanned"] += 1
            self._process_spec(spec_dir.name, spec_file)

    def _process_spec(self, spec_id: str, spec_file: Path):
        """Process a single spec file"""
        content = spec_file.read_text()

        # Extract spec number and name
        match = re.match(r'(\d+)-(.+)', spec_id)
        if not match:
            return

        number, name = match.groups()

        # Extract rich context from spec
        context = self._extract_context(content)

        # Find architecture references: @docs/architecture/file.md#section
        arch_refs = re.findall(r'@docs/architecture/([^#\s]+\.md)(?:#([^\s]+))?', content)

        # Find ADR references: ADR-NNNN: Description
        adr_refs = re.findall(r'ADR-(\d+):?\s*([^\n]*)', content)

        # Find dependencies: dependencies: [001, 002]
        dep_match = re.search(r'dependencies:\s*\[([^\]]+)\]', content, re.IGNORECASE)
        dependencies = []
        if dep_match:
            dependencies = [d.strip() for d in dep_match.group(1).split(',')]

        # Get file metadata
        stat_info = spec_file.stat()
        created = datetime.fromtimestamp(stat_info.st_ctime).isoformat()
        modified = datetime.fromtimestamp(stat_info.st_mtime).isoformat()

        # Update stats
        self.stats["arch_refs_found"] += len(arch_refs)
        self.stats["adr_refs_found"] += len(adr_refs)
        self.stats["dependencies_found"] += len(dependencies)

        # Create RICH memory for this spec
        memory_parts = [
            f"Specification {number} ({name})"
        ]

        # Add objective/purpose if found
        if context.get("objective"):
            memory_parts.append(f"Objective: {context['objective']}")

        # Add rationale if found
        if context.get("rationale"):
            memory_parts.append(f"Rationale: {context['rationale']}")

        # Architecture references with WHY
        if arch_refs:
            for file, section in arch_refs:
                arch_desc = f"{file}" + (f"#{section}" if section else "")
                # Try to find WHY this is referenced
                why = self._extract_reference_reason(content, file)
                if why:
                    memory_parts.append(f"references {arch_desc} because: {why}")
                else:
                    memory_parts.append(f"references architecture: {arch_desc}")

        # ADR references with reasoning
        if adr_refs:
            for adr_num, adr_desc in adr_refs:
                if adr_desc.strip():
                    memory_parts.append(f"implements ADR-{adr_num}: {adr_desc.strip()}")
                else:
                    memory_parts.append(f"implements ADR-{adr_num}")

        # Dependencies with context
        if dependencies:
            dep_desc = ", ".join(dependencies)
            memory_parts.append(f"depends on specifications: {dep_desc}")

        # Add metadata
        memory_parts.append(f"Created: {created}")
        memory_parts.append(f"Last modified: {modified}")
        memory_parts.append(f"Synced: {datetime.now().isoformat()}")

        memory_text = ". ".join(memory_parts)

        # Add to Mem0
        if not self.quiet:
            print(f"   Adding memory ({len(memory_text)} chars)...")
        result = self.memory.add(memory_text, user_id=self.project_name)
        if not self.quiet:
            print(f"   Result: {result}")

        # Count actual memories created
        if result and 'results' in result:
            self.stats["memories_created"] += len(result['results'])
        else:
            if not self.quiet:
                print(f"   ⚠️  No result from memory.add()")

        if not self.quiet:
            print(f"✅ Synced spec {number}: {name}")

        # Create reverse memories (what specs depend on this architecture doc)
        for arch_file, section in arch_refs:
            why = self._extract_reference_reason(content, arch_file)
            reverse_memory = f"Architecture document {arch_file}"
            if section:
                reverse_memory += f" section #{section}"
            reverse_memory += f" is referenced by specification {number} ({name})"
            if why:
                reverse_memory += f" for: {why}"

            if not self.quiet:
                print(f"   Adding reverse memory for {arch_file}...")
            rev_result = self.memory.add(reverse_memory, user_id=self.project_name)
            if not self.quiet:
                print(f"   Reverse result: {rev_result}")

            if rev_result and 'results' in rev_result:
                self.stats["memories_created"] += len(rev_result['results'])

    def _extract_context(self, content: str) -> dict:
        """Extract contextual information from spec content"""
        context = {}

        # Extract objective/purpose
        objective_match = re.search(
            r'##\s*(?:Objective|Purpose|Goal)s?\s*\n+([^\n#]+)',
            content,
            re.IGNORECASE
        )
        if objective_match:
            context["objective"] = objective_match.group(1).strip()

        # Extract rationale/why
        rationale_match = re.search(
            r'##\s*(?:Rationale|Why|Reason)\s*\n+([^\n#]+)',
            content,
            re.IGNORECASE
        )
        if rationale_match:
            context["rationale"] = rationale_match.group(1).strip()

        return context

    def _extract_reference_reason(self, content: str, arch_file: str) -> str:
        """Extract reasoning for why an architecture doc is referenced"""
        # Look for context near the reference
        pattern = rf'@docs/architecture/{re.escape(arch_file)}[^\n]*\n+([^#\n]+)'
        match = re.search(pattern, content)
        if match:
            reason = match.group(1).strip()
            # Limit length
            if len(reason) > 150:
                reason = reason[:147] + "..."
            return reason
        return ""

    def create_derivation_chains(self):
        """Create memories for derivation chains (what needs updating)"""
        # Query all specs from memory
        results = self.memory.search(
            "list all specifications",
            user_id=self.project_name,
            limit=100
        )

        # Group by architecture document
        arch_to_specs = {}
        for result in results.get("results", []):
            memory = result.get("memory", "")

            # Extract architecture references
            arch_matches = re.findall(r'architecture documents?: ([^.]+)', memory)
            spec_match = re.search(r'Specification (\d+) \(([^)]+)\)', memory)

            if arch_matches and spec_match:
                spec_num, spec_name = spec_match.groups()
                for arch_refs in arch_matches:
                    for arch_file in arch_refs.split(", "):
                        arch_file = arch_file.strip()
                        if arch_file not in arch_to_specs:
                            arch_to_specs[arch_file] = []
                        arch_to_specs[arch_file].append(f"{spec_num} ({spec_name})")

        # Create derivation chain memories
        for arch_file, specs in arch_to_specs.items():
            chain_memory = (
                f"When architecture document {arch_file} changes, "
                f"these specifications need review: {', '.join(set(specs))}"
            )
            self.memory.add(chain_memory, user_id=self.project_name)
            self.stats["memories_created"] += 1

        if not self.quiet:
            print(f"✅ Created {len(arch_to_specs)} derivation chain memories") # type: ignore

    def print_summary(self):
        """Print sync summary"""
        print("\n" + "="*60)
        print("📊 Documentation Sync Summary")
        print("="*60)
        print(f"Project: {self.project_name}")
        print(f"Root: {self.project_root}")
        print()
        print(f"Specs scanned: {self.stats['specs_scanned']}")
        print(f"Architecture references: {self.stats['arch_refs_found']}")
        print(f"ADR references: {self.stats['adr_refs_found']}")
        print(f"Spec dependencies: {self.stats['dependencies_found']}")
        print(f"Total memories created: {self.stats['memories_created']}")
        print("="*60)
        print()
        print("✅ Documentation synced to Mem0")
        print()
        print("Next steps:")
        print("  - Query relationships: python scripts/query-relationships.py")
        print("  - Validate docs: python scripts/validate-docs.py")
        print("  - Check impact: python scripts/query-relationships.py \"What specs depend on security.md?\"")


def main():
    import sys

    # Check for --quiet flag
    quiet = "--quiet" in sys.argv

    # Detect project root
    # Script is at: plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py
    # Project root is 6 levels up: scripts -> doc-sync -> skills -> planning -> plugins -> ROOT
    script_path = Path(__file__).resolve()
    project_root = script_path.parent.parent.parent.parent.parent.parent

    if not quiet:
        print(f"🔍 Scanning documentation in: {project_root}")
        print()

    syncer = DocSync(project_root, quiet=quiet) # type: ignore
    syncer.scan_specs()
    syncer.create_derivation_chains()

    if not quiet:
        syncer.print_summary()
        # Give Mem0 time to persist memories to disk
        print("Persisting memories...")
        time.sleep(2)
        print("✅ Done")
    else:
        # Silent mode - just wait for persistence
        time.sleep(1)


if __name__ == "__main__":
    main()

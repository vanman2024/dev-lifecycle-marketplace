#!/usr/bin/env python3
"""
Intelligent Relationship Updater
Automatically updates documentation with proper cross-references
"""

import os
import re
import sys
from pathlib import Path
from datetime import datetime

try:
    from mem0 import Memory
except ImportError:
    print("❌ Mem0 not installed. Activate venv: source /tmp/mem0-env/bin/activate")
    sys.exit(1)


class RelationshipUpdater:
    def __init__(self, project_root: str | Path, project_name: str | None = None, dry_run: bool = True):
        self.project_root = Path(project_root)
        self.dry_run = dry_run

        # Auto-detect project
        if not project_name:
            project_name = self._detect_project_name()

        self.project_name = project_name

        # Initialize Mem0
        storage_path = Path.home() / ".claude" / "mem0-chroma"
        config = {
            "llm": {"provider": "openai", "config": {"model": "gpt-4o-mini", "temperature": 0.1}},
            "vector_store": {"provider": "chroma", "config": {"collection_name": "documentation", "path": str(storage_path)}},
            "embedder": {"provider": "openai", "config": {"model": "text-embedding-3-small"}}
        }
        self.memory = Memory.from_config(config)

        self.updates = []

    def _detect_project_name(self) -> str:
        """Auto-detect project name"""
        import json, subprocess

        claude_config = self.project_root / ".claude" / "project.json"
        if claude_config.exists():
            try:
                with open(claude_config) as f:
                    if name := json.load(f).get("name"):
                        return name
            except: pass

        try:
            result = subprocess.run(["git", "rev-parse", "--show-toplevel"], cwd=self.project_root, capture_output=True, text=True, timeout=2)
            if result.returncode == 0:
                return Path(result.stdout.strip()).name
        except: pass

        return self.project_root.name

    def analyze_and_update(self):
        """Main workflow: analyze relationships and update docs"""
        print(f"🔗 Intelligent Relationship Updater")
        print(f"📌 Project: {self.project_name}")
        print(f"{'🔍 DRY RUN MODE' if self.dry_run else '✍️  WRITE MODE'}")
        print("=" * 60)
        print()

        # Step 1: Find missing spec → architecture references
        self._find_missing_arch_refs()

        # Step 2: Find missing spec → ADR references
        self._find_missing_adr_refs()

        # Step 3: Find missing spec dependencies
        self._find_missing_dependencies()

        # Step 4: Apply updates
        if self.updates:
            print("\n" + "=" * 60)
            print(f"📝 Found {len(self.updates)} updates to apply")
            print("=" * 60)

            for i, update in enumerate(self.updates, 1):
                print(f"\n{i}. {update['file']}")
                print(f"   Action: {update['action']}")
                print(f"   Add: {update['content'][:100]}...")

            if not self.dry_run:
                print("\n✍️  Applying updates...")
                self._apply_updates()
                print("✅ Updates applied")
            else:
                print("\n💡 Tip: Run with --write to apply these updates")
        else:
            print("✅ All relationships are up to date!")

    def _find_missing_arch_refs(self):
        """Find specs that should reference architecture docs but don't"""
        print("🏗️  Checking spec → architecture references...")

        # Query Mem0 for all architecture docs
        arch_results = self.memory.search("list architecture documents", user_id=self.project_name, limit=20)

        # Query for all specs
        spec_results = self.memory.search("list specifications", user_id=self.project_name, limit=50)

        # For each spec, check if it should reference arch docs
        for spec_result in spec_results.get("results", []):
            spec_memory = spec_result.get("memory", "")

            # Extract spec number
            spec_match = re.search(r'Specification (\d+)', spec_memory)
            if not spec_match:
                continue

            spec_num = spec_match.group(1)

            # Check if spec mentions backend/frontend/database concepts
            keywords = self._extract_keywords_from_spec_memory(spec_memory)

            # Suggest relevant architecture docs
            for keyword in keywords:
                for arch_result in arch_results.get("results", []):
                    arch_memory = arch_result.get("memory", "")
                    arch_file_match = re.search(r'([a-z-]+\.md)', arch_memory)

                    if arch_file_match and keyword in arch_memory.lower():
                        arch_file = arch_file_match.group(1)

                        # Check if spec already references this
                        if arch_file not in spec_memory:
                            self.updates.append({
                                "file": f"specs/{spec_num}-*/spec.md",
                                "action": f"Add architecture reference",
                                "content": f"@docs/architecture/{arch_file}",
                                "reason": f"Spec mentions '{keyword}' which relates to {arch_file}"
                            })

    def _find_missing_adr_refs(self):
        """Find specs that should reference ADRs but don't"""
        print("📋 Checking spec → ADR references...")

        # Query for ADRs
        adr_results = self.memory.search("list ADRs", user_id=self.project_name, limit=20)

        # Query for specs
        spec_results = self.memory.search("list specifications", user_id=self.project_name, limit=50)

        # Match ADRs to specs based on keywords
        for adr_result in adr_results.get("results", []):
            adr_memory = adr_result.get("memory", "")
            adr_match = re.search(r'ADR-(\d+|[a-z-]+)', adr_memory)

            if not adr_match:
                continue

            adr_id = adr_match.group(0)
            adr_keywords = self._extract_keywords(adr_memory)

            # Find specs that should implement this ADR
            for spec_result in spec_results.get("results", []):
                spec_memory = spec_result.get("memory", "")
                spec_match = re.search(r'Specification (\d+)', spec_memory)

                if not spec_match:
                    continue

                spec_num = spec_match.group(1)

                # Check keyword overlap
                spec_keywords = self._extract_keywords(spec_memory)
                overlap = set(adr_keywords) & set(spec_keywords)

                if overlap and adr_id not in spec_memory:
                    self.updates.append({
                        "file": f"specs/{spec_num}-*/spec.md",
                        "action": f"Add ADR reference",
                        "content": f"{adr_id}",
                        "reason": f"Shared keywords: {', '.join(list(overlap)[:3])}"
                    })

    def _find_missing_dependencies(self):
        """Find missing spec → spec dependencies"""
        print("🔗 Checking spec → spec dependencies...")

        # Query for specs
        spec_results = self.memory.search("list all specifications", user_id=self.project_name, limit=50)

        # Build dependency graph from memories
        for spec_result in spec_results.get("results", []):
            spec_memory = spec_result.get("memory", "")

            # Look for "depends on" patterns
            depends_match = re.search(r'depends on.*?(\d+)', spec_memory)
            dependent_match = re.search(r'Specification (\d+).*has dependent', spec_memory)

            if depends_match or dependent_match:
                # Already has dependencies tracked
                continue

            # Check for implicit dependencies (shared architecture refs)
            spec_match = re.search(r'Specification (\d+)', spec_memory)
            if spec_match:
                spec_num = spec_match.group(1)
                # Could add logic here to detect implicit dependencies
                pass

    def _extract_keywords(self, text: str) -> list:
        """Extract meaningful keywords from text"""
        keywords = []

        # Technical terms
        patterns = [
            r'\b(authentication|auth|oauth|jwt|security|encryption)\b',
            r'\b(database|postgres|supabase|schema|migration)\b',
            r'\b(api|endpoint|rest|graphql|backend)\b',
            r'\b(frontend|ui|ux|component|page)\b',
            r'\b(deployment|docker|kubernetes|cloud)\b',
            r'\b(ai|ml|llm|agent|memory)\b'
        ]

        for pattern in patterns:
            matches = re.findall(pattern, text.lower())
            keywords.extend(matches)

        return list(set(keywords))

    def _extract_keywords_from_spec_memory(self, memory: str) -> list:
        """Extract domain keywords from spec memory"""
        return self._extract_keywords(memory)

    def _apply_updates(self):
        """Apply the suggested updates to files"""
        for update in self.updates:
            file_pattern = update['file']
            content_to_add = update['content']

            # Find actual file matching pattern
            if '*' in file_pattern:
                # Expand pattern
                parts = file_pattern.split('/')
                search_dir = self.project_root / parts[0]

                if search_dir.exists():
                    matching_dirs = list(search_dir.glob(parts[1].replace('*', '*')))
                    if matching_dirs:
                        actual_file = matching_dirs[0] / parts[2]
                        if actual_file.exists():
                            self._add_reference_to_file(actual_file, content_to_add, update['action'])


    def _add_reference_to_file(self, file_path: Path, reference: str, action: str):
        """Add reference to file in appropriate section"""
        content = file_path.read_text()

        if "architecture" in action.lower():
            # Add to Architecture References section
            if "## Architecture References" in content:
                content = content.replace(
                    "## Architecture References\n",
                    f"## Architecture References\n- {reference}\n"
                )
            else:
                # Add section
                content += f"\n\n## Architecture References\n- {reference}\n"

        elif "ADR" in action:
            # Add to ADR section
            if "## Architecture Decisions" in content:
                content = content.replace(
                    "## Architecture Decisions\n",
                    f"## Architecture Decisions\n- {reference}\n"
                )
            else:
                content += f"\n\n## Architecture Decisions\n- {reference}\n"

        file_path.write_text(content)
        print(f"   ✅ Updated {file_path}")


def main():
    import sys

    dry_run = "--write" not in sys.argv

    # Detect project root
    script_path = Path(__file__).resolve()
    project_root = script_path.parent.parent.parent.parent.parent.parent

    updater = RelationshipUpdater(project_root, dry_run=dry_run)
    updater.analyze_and_update()


if __name__ == "__main__":
    main()

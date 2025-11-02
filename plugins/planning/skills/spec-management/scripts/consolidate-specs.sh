#!/bin/bash
# Consolidate all specs into .planning/project-specs.json
# Usage: ./consolidate-specs.sh [specs-directory] [project-name]

set -e

SPECS_DIR="${1:-specs}"
PROJECT_NAME="${2:-Unknown Project}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$SPECS_DIR" ]; then
  echo "Error: Specs directory does not exist: $SPECS_DIR" >&2
  exit 1
fi

# Create .planning directory if it doesn't exist
mkdir -p .planning

# Start building JSON
echo "{" > .planning/project-specs.json
echo "  \"projectName\": \"$PROJECT_NAME\"," >> .planning/project-specs.json
echo "  \"description\": \"\"," >> .planning/project-specs.json
echo "  \"createdAt\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"," >> .planning/project-specs.json
echo "  \"specs\": [" >> .planning/project-specs.json

# Find all spec directories (numbered like 001-name, 002-name, etc.)
FIRST=true
for spec_dir in $(find "$SPECS_DIR" -maxdepth 1 -type d -name "[0-9][0-9][0-9]-*" | sort); do
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    echo "," >> .planning/project-specs.json
  fi

  # Generate JSON for this spec (without trailing newline)
  bash "$SCRIPT_DIR/generate-json-output.sh" "$spec_dir" | sed '1s/^/    /' | sed '2,$s/^/    /' | tr '\n' '\r' | sed 's/\r$//' | tr '\r' '\n' >> .planning/project-specs.json
done

echo "" >> .planning/project-specs.json
echo "  ]," >> .planning/project-specs.json

# Add shared context (empty for now, will be filled by init-project command)
echo "  \"sharedContext\": {" >> .planning/project-specs.json
echo "    \"techStack\": []," >> .planning/project-specs.json
echo "    \"userTypes\": []," >> .planning/project-specs.json
echo "    \"dataEntities\": []," >> .planning/project-specs.json
echo "    \"integrations\": []" >> .planning/project-specs.json
echo "  }," >> .planning/project-specs.json
echo "  \"readyForPhase0\": true" >> .planning/project-specs.json
echo "}" >> .planning/project-specs.json

echo "✓ Generated .planning/project-specs.json" >&2
cat .planning/project-specs.json

#!/usr/bin/env bash
#
# validate-versions.sh - Check tool versions against requirements
#
# Usage: ./validate-versions.sh [--json] [--requirements FILE]
#
# Validates installed tool versions against project requirements
# Supports package.json engines, .tool-versions, .nvmrc, and custom requirements

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

JSON_OUTPUT=false
REQUIREMENTS_FILE=""
PROJECT_DIR="${PWD}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    --requirements)
      REQUIREMENTS_FILE="$2"
      shift 2
      ;;
    --project-dir)
      PROJECT_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Function to check if command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to get installed version
get_installed_version() {
  local tool=$1
  local version=""

  case $tool in
    node)
      version=$(node --version 2>/dev/null | sed 's/v//')
      ;;
    npm)
      version=$(npm --version 2>/dev/null)
      ;;
    python|python3)
      version=$(python3 --version 2>/dev/null | awk '{print $2}')
      ;;
    go)
      version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
      ;;
    rust|rustc)
      version=$(rustc --version 2>/dev/null | awk '{print $2}')
      ;;
    ruby)
      version=$(ruby --version 2>/dev/null | awk '{print $2}')
      ;;
    java)
      version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
      ;;
    php)
      version=$(php --version 2>/dev/null | head -n 1 | awk '{print $2}')
      ;;
    *)
      version="unknown"
      ;;
  esac

  echo "$version"
}

# Function to compare versions (simplified semver comparison)
version_compare() {
  local version=$1
  local requirement=$2

  # Remove 'v' prefix if present
  version=${version#v}
  requirement=${requirement#v}

  # Handle >= operator
  if [[ "$requirement" =~ ^\>=(.+) ]]; then
    local min_version="${BASH_REMATCH[1]}"
    min_version=${min_version# } # trim leading space

    # Simple version comparison
    if [[ "$(printf '%s\n' "$min_version" "$version" | sort -V | head -n1)" == "$min_version" ]]; then
      echo "ok"
    else
      echo "too_old"
    fi
    return
  fi

  # Handle ^ operator (compatible with)
  if [[ "$requirement" =~ ^\^(.+) ]]; then
    local base_version="${BASH_REMATCH[1]}"
    base_version=${base_version# }

    # Extract major version
    local base_major=$(echo "$base_version" | cut -d. -f1)
    local current_major=$(echo "$version" | cut -d. -f1)

    if [[ "$base_major" == "$current_major" ]]; then
      if [[ "$(printf '%s\n' "$base_version" "$version" | sort -V | head -n1)" == "$base_version" ]]; then
        echo "ok"
      else
        echo "too_old"
      fi
    else
      echo "incompatible"
    fi
    return
  fi

  # Handle ~ operator (approximately equivalent to)
  if [[ "$requirement" =~ ^~(.+) ]]; then
    local base_version="${BASH_REMATCH[1]}"
    base_version=${base_version# }

    # Extract major.minor version
    local base_major_minor=$(echo "$base_version" | cut -d. -f1,2)
    local current_major_minor=$(echo "$version" | cut -d. -f1,2)

    if [[ "$base_major_minor" == "$current_major_minor" ]]; then
      if [[ "$(printf '%s\n' "$base_version" "$version" | sort -V | head -n1)" == "$base_version" ]]; then
        echo "ok"
      else
        echo "too_old"
      fi
    else
      echo "incompatible"
    fi
    return
  fi

  # Handle = operator (exact match)
  if [[ "$requirement" =~ ^=(.+) ]] || [[ ! "$requirement" =~ [><=~^] ]]; then
    local exact_version="${BASH_REMATCH[1]:-$requirement}"
    exact_version=${exact_version# }

    if [[ "$version" == "$exact_version" ]]; then
      echo "ok"
    else
      echo "mismatch"
    fi
    return
  fi

  # Default: assume ok if we can't parse
  echo "ok"
}

# Function to parse package.json engines
parse_package_json() {
  local package_file="$PROJECT_DIR/package.json"

  if [[ ! -f "$package_file" ]]; then
    return
  fi

  if ! command_exists jq; then
    [[ "$JSON_OUTPUT" == false ]] && echo -e "${YELLOW}Warning: jq not installed, cannot parse package.json${NC}"
    return
  fi

  # Parse engines section
  local node_version=$(jq -r '.engines.node // empty' "$package_file" 2>/dev/null)
  local npm_version=$(jq -r '.engines.npm // empty' "$package_file" 2>/dev/null)

  [[ -n "$node_version" ]] && echo "node:$node_version"
  [[ -n "$npm_version" ]] && echo "npm:$npm_version"
}

# Function to parse .tool-versions (asdf format)
parse_tool_versions() {
  local tool_versions_file="$PROJECT_DIR/.tool-versions"

  if [[ ! -f "$tool_versions_file" ]]; then
    return
  fi

  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue

    # Parse tool and version
    local tool=$(echo "$line" | awk '{print $1}')
    local version=$(echo "$line" | awk '{print $2}')

    echo "$tool:$version"
  done < "$tool_versions_file"
}

# Function to parse .nvmrc
parse_nvmrc() {
  local nvmrc_file="$PROJECT_DIR/.nvmrc"

  if [[ ! -f "$nvmrc_file" ]]; then
    return
  fi

  local node_version=$(cat "$nvmrc_file" | tr -d '[:space:]')
  echo "node:$node_version"
}

# Function to parse custom requirements file
parse_requirements_file() {
  if [[ -z "$REQUIREMENTS_FILE" ]] || [[ ! -f "$REQUIREMENTS_FILE" ]]; then
    return
  fi

  # Expect format: tool:version
  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue

    echo "$line"
  done < "$REQUIREMENTS_FILE"
}

# Collect all requirements from various sources
declare -A REQUIREMENTS
declare -a REQUIREMENT_SOURCES

[[ "$JSON_OUTPUT" == false ]] && echo -e "${BLUE}Collecting version requirements...${NC}\n"

# Parse package.json
if [[ -f "$PROJECT_DIR/package.json" ]]; then
  REQUIREMENT_SOURCES+=("package.json")
  while IFS= read -r req; do
    [[ -z "$req" ]] && continue
    IFS=':' read -r tool version <<< "$req"
    REQUIREMENTS["$tool"]="$version"
  done < <(parse_package_json)
fi

# Parse .tool-versions
if [[ -f "$PROJECT_DIR/.tool-versions" ]]; then
  REQUIREMENT_SOURCES+=(".tool-versions")
  while IFS= read -r req; do
    [[ -z "$req" ]] && continue
    IFS=':' read -r tool version <<< "$req"
    REQUIREMENTS["$tool"]="$version"
  done < <(parse_tool_versions)
fi

# Parse .nvmrc
if [[ -f "$PROJECT_DIR/.nvmrc" ]]; then
  REQUIREMENT_SOURCES+=(".nvmrc")
  while IFS= read -r req; do
    [[ -z "$req" ]] && continue
    IFS=':' read -r tool version <<< "$req"
    REQUIREMENTS["$tool"]="$version"
  done < <(parse_nvmrc)
fi

# Parse custom requirements file
if [[ -n "$REQUIREMENTS_FILE" ]] && [[ -f "$REQUIREMENTS_FILE" ]]; then
  REQUIREMENT_SOURCES+=("$REQUIREMENTS_FILE")
  while IFS= read -r req; do
    [[ -z "$req" ]] && continue
    IFS=':' read -r tool version <<< "$req"
    REQUIREMENTS["$tool"]="$version"
  done < <(parse_requirements_file)
fi

if [[ ${#REQUIREMENTS[@]} -eq 0 ]]; then
  [[ "$JSON_OUTPUT" == false ]] && echo -e "${YELLOW}No version requirements found${NC}"
  [[ "$JSON_OUTPUT" == false ]] && echo "Checked: package.json, .tool-versions, .nvmrc"
  exit 0
fi

[[ "$JSON_OUTPUT" == false ]] && echo "Found requirements in: ${REQUIREMENT_SOURCES[*]}"
[[ "$JSON_OUTPUT" == false ]] && echo ""

# Validate each requirement
declare -A VALIDATION_RESULTS
OVERALL_STATUS="success"

for tool in "${!REQUIREMENTS[@]}"; do
  required_version="${REQUIREMENTS[$tool]}"

  if ! command_exists "$tool"; then
    VALIDATION_RESULTS["$tool"]="missing:$required_version::error"
    OVERALL_STATUS="error"

    [[ "$JSON_OUTPUT" == false ]] && echo -e "${RED}✗${NC} $tool"
    [[ "$JSON_OUTPUT" == false ]] && echo "  Required: $required_version"
    [[ "$JSON_OUTPUT" == false ]] && echo "  Status: Not installed"
    [[ "$JSON_OUTPUT" == false ]] && echo ""
    continue
  fi

  installed_version=$(get_installed_version "$tool")
  comparison=$(version_compare "$installed_version" "$required_version")

  case $comparison in
    ok)
      VALIDATION_RESULTS["$tool"]="installed:$required_version:$installed_version:ok"
      [[ "$JSON_OUTPUT" == false ]] && echo -e "${GREEN}✓${NC} $tool"
      [[ "$JSON_OUTPUT" == false ]] && echo "  Required: $required_version"
      [[ "$JSON_OUTPUT" == false ]] && echo "  Installed: $installed_version"
      ;;
    too_old)
      VALIDATION_RESULTS["$tool"]="installed:$required_version:$installed_version:too_old"
      OVERALL_STATUS="error"
      [[ "$JSON_OUTPUT" == false ]] && echo -e "${RED}✗${NC} $tool"
      [[ "$JSON_OUTPUT" == false ]] && echo "  Required: $required_version"
      [[ "$JSON_OUTPUT" == false ]] && echo "  Installed: $installed_version (too old)"
      ;;
    incompatible|mismatch)
      VALIDATION_RESULTS["$tool"]="installed:$required_version:$installed_version:mismatch"
      OVERALL_STATUS="warning"
      [[ "$JSON_OUTPUT" == false ]] && echo -e "${YELLOW}!${NC} $tool"
      [[ "$JSON_OUTPUT" == false ]] && echo "  Required: $required_version"
      [[ "$JSON_OUTPUT" == false ]] && echo "  Installed: $installed_version (mismatch)"
      ;;
  esac

  [[ "$JSON_OUTPUT" == false ]] && echo ""
done

# JSON output
if [[ "$JSON_OUTPUT" == true ]]; then
  echo "{"
  echo "  \"status\": \"$OVERALL_STATUS\","
  echo "  \"sources\": ["
  first=true
  for source in "${REQUIREMENT_SOURCES[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "    \"$source\""
  done
  echo ""
  echo "  ],"
  echo "  \"validations\": {"

  first=true
  for tool in "${!VALIDATION_RESULTS[@]}"; do
    IFS=':' read -r installed required current status <<< "${VALIDATION_RESULTS[$tool]}"
    [[ "$first" == false ]] && echo ","
    first=false

    echo -n "    \"$tool\": {"
    echo -n "\"installed\": $([ "$installed" == "installed" ] && echo "true" || echo "false"), "
    echo -n "\"required\": \"$required\", "
    echo -n "\"current\": \"$current\", "
    echo -n "\"status\": \"$status\""
    echo -n "}"
  done

  echo ""
  echo "  }"
  echo "}"
fi

# Exit with error if any validation failed
[[ "$OVERALL_STATUS" == "error" ]] && exit 1 || exit 0

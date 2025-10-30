#!/usr/bin/env bash
#
# check-tools.sh - Verify specific tools are installed and accessible
#
# Usage: ./check-tools.sh [tool1] [tool2] ... [toolN]
#        ./check-tools.sh --all
#        ./check-tools.sh --json node python go
#
# Checks if specified tools are installed, accessible in PATH, and retrieves versions

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

JSON_OUTPUT=false
CHECK_ALL=false
TOOLS_TO_CHECK=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    --all)
      CHECK_ALL=true
      shift
      ;;
    *)
      TOOLS_TO_CHECK+=("$1")
      shift
      ;;
  esac
done

# Define all supported tools
ALL_TOOLS=(
  node npm yarn pnpm
  python python3 pip pip3
  go
  rustc cargo
  ruby gem
  java javac maven gradle
  php composer
  dotnet
  docker docker-compose
  git
  make cmake
  curl wget
  jq yq
  awk sed grep
)

# If --all is specified, check all tools
if [[ "$CHECK_ALL" == true ]]; then
  TOOLS_TO_CHECK=("${ALL_TOOLS[@]}")
fi

# If no tools specified, show usage
if [[ ${#TOOLS_TO_CHECK[@]} -eq 0 ]]; then
  echo "Usage: $0 [--json] [--all] [tool1] [tool2] ..."
  echo ""
  echo "Examples:"
  echo "  $0 node python go           # Check specific tools"
  echo "  $0 --all                    # Check all supported tools"
  echo "  $0 --json node python       # JSON output"
  echo ""
  echo "Supported tools:"
  printf '  %s\n' "${ALL_TOOLS[@]}" | column
  exit 1
fi

# Function to check if command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to get tool version
get_tool_version() {
  local tool=$1
  local version=""

  case $tool in
    node)
      version=$(node --version 2>/dev/null | sed 's/v//')
      ;;
    npm)
      version=$(npm --version 2>/dev/null)
      ;;
    yarn)
      version=$(yarn --version 2>/dev/null)
      ;;
    pnpm)
      version=$(pnpm --version 2>/dev/null)
      ;;
    python|python3)
      version=$(python3 --version 2>/dev/null | awk '{print $2}')
      ;;
    pip|pip3)
      version=$(pip3 --version 2>/dev/null | awk '{print $2}')
      ;;
    go)
      version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
      ;;
    rustc)
      version=$(rustc --version 2>/dev/null | awk '{print $2}')
      ;;
    cargo)
      version=$(cargo --version 2>/dev/null | awk '{print $2}')
      ;;
    ruby)
      version=$(ruby --version 2>/dev/null | awk '{print $2}')
      ;;
    gem)
      version=$(gem --version 2>/dev/null)
      ;;
    java)
      version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
      ;;
    javac)
      version=$(javac -version 2>&1 | awk '{print $2}')
      ;;
    maven)
      version=$(mvn --version 2>/dev/null | head -n 1 | awk '{print $3}')
      ;;
    gradle)
      version=$(gradle --version 2>/dev/null | grep "Gradle" | awk '{print $2}')
      ;;
    php)
      version=$(php --version 2>/dev/null | head -n 1 | awk '{print $2}')
      ;;
    composer)
      version=$(composer --version 2>/dev/null | awk '{print $3}')
      ;;
    dotnet)
      version=$(dotnet --version 2>/dev/null)
      ;;
    docker)
      version=$(docker --version 2>/dev/null | awk '{print $3}' | sed 's/,//')
      ;;
    docker-compose)
      version=$(docker-compose --version 2>/dev/null | awk '{print $3}' | sed 's/,//')
      ;;
    git)
      version=$(git --version 2>/dev/null | awk '{print $3}')
      ;;
    make)
      version=$(make --version 2>/dev/null | head -n 1 | awk '{print $3}')
      ;;
    cmake)
      version=$(cmake --version 2>/dev/null | head -n 1 | awk '{print $3}')
      ;;
    curl)
      version=$(curl --version 2>/dev/null | head -n 1 | awk '{print $2}')
      ;;
    wget)
      version=$(wget --version 2>/dev/null | head -n 1 | awk '{print $3}')
      ;;
    jq)
      version=$(jq --version 2>/dev/null | sed 's/jq-//')
      ;;
    yq)
      version=$(yq --version 2>/dev/null | awk '{print $3}')
      ;;
    awk)
      version=$(awk -W version 2>/dev/null | head -n 1 | awk '{print $3}' || echo "installed")
      ;;
    sed)
      version=$(sed --version 2>/dev/null | head -n 1 | awk '{print $4}' || echo "installed")
      ;;
    grep)
      version=$(grep --version 2>/dev/null | head -n 1 | awk '{print $4}' || echo "installed")
      ;;
    *)
      if command_exists "$tool"; then
        version="installed"
      else
        version=""
      fi
      ;;
  esac

  echo "$version"
}

# Function to get tool location
get_tool_location() {
  local tool=$1
  command -v "$tool" 2>/dev/null || echo ""
}

# Function to get installation instructions
get_install_instructions() {
  local tool=$1

  case $tool in
    node|npm)
      echo "Install via nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && nvm install --lts"
      ;;
    yarn)
      echo "npm install -g yarn"
      ;;
    pnpm)
      echo "npm install -g pnpm"
      ;;
    python|python3)
      echo "Install Python 3: https://www.python.org/downloads/ or use pyenv"
      ;;
    pip|pip3)
      echo "python3 -m ensurepip --upgrade"
      ;;
    go)
      echo "Install Go: https://golang.org/dl/ or use package manager"
      ;;
    rustc|cargo)
      echo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
      ;;
    ruby|gem)
      echo "Install Ruby: https://www.ruby-lang.org/en/downloads/ or use rbenv"
      ;;
    java|javac)
      echo "Install OpenJDK: https://adoptium.net/ or use jenv"
      ;;
    docker)
      echo "Install Docker: https://docs.docker.com/get-docker/"
      ;;
    git)
      echo "Install Git: https://git-scm.com/downloads or via package manager"
      ;;
    *)
      echo "Install via system package manager (apt, brew, etc.)"
      ;;
  esac
}

# Check each tool
declare -A RESULTS
OVERALL_STATUS="success"

for tool in "${TOOLS_TO_CHECK[@]}"; do
  if command_exists "$tool"; then
    version=$(get_tool_version "$tool")
    location=$(get_tool_location "$tool")
    RESULTS["$tool"]="installed:$version:$location:ok"

    if [[ "$JSON_OUTPUT" == false ]]; then
      echo -e "${GREEN}✓${NC} $tool"
      echo "  Version: $version"
      echo "  Location: $location"
    fi
  else
    RESULTS["$tool"]="missing:::missing"
    OVERALL_STATUS="error"

    if [[ "$JSON_OUTPUT" == false ]]; then
      echo -e "${RED}✗${NC} $tool"
      echo "  Status: Not found"
      echo "  Install: $(get_install_instructions "$tool")"
    fi
  fi

  [[ "$JSON_OUTPUT" == false ]] && echo ""
done

# JSON output
if [[ "$JSON_OUTPUT" == true ]]; then
  echo "{"
  echo "  \"status\": \"$OVERALL_STATUS\","
  echo "  \"tools\": {"

  first=true
  for tool in "${!RESULTS[@]}"; do
    IFS=':' read -r installed version location status <<< "${RESULTS[$tool]}"
    [[ "$first" == false ]] && echo ","
    first=false

    echo -n "    \"$tool\": {"
    echo -n "\"installed\": $([ "$installed" == "installed" ] && echo "true" || echo "false"), "
    echo -n "\"version\": \"$version\", "
    echo -n "\"location\": \"$location\", "
    echo -n "\"status\": \"$status\""

    if [[ "$installed" == "missing" ]]; then
      echo -n ", \"install_instructions\": \"$(get_install_instructions "$tool")\""
    fi

    echo -n "}"
  done

  echo ""
  echo "  }"
  echo "}"
fi

# Exit with error if any tool is missing
[[ "$OVERALL_STATUS" == "error" ]] && exit 1 || exit 0

#!/usr/bin/env bash
#
# check-environment.sh - Comprehensive environment verification
#
# Usage: ./check-environment.sh [--json] [--verbose]
#
# Verifies all development tools, versions, PATH configuration, and environment variables
# Returns structured output with status and recommendations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
JSON_OUTPUT=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Initialize result tracking
declare -A TOOLS
declare -a ISSUES
declare -a RECOMMENDATIONS
OVERALL_STATUS="success"

# Helper function to check if command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Helper function to get version
get_version() {
  local tool=$1
  local version=""

  case $tool in
    node)
      version=$(node --version 2>/dev/null | sed 's/v//')
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
    docker)
      version=$(docker --version 2>/dev/null | awk '{print $3}' | sed 's/,//')
      ;;
    git)
      version=$(git --version 2>/dev/null | awk '{print $3}')
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
    pip|pip3)
      version=$(pip3 --version 2>/dev/null | awk '{print $2}')
      ;;
    cargo)
      version=$(cargo --version 2>/dev/null | awk '{print $2}')
      ;;
    make)
      version=$(make --version 2>/dev/null | head -n 1 | awk '{print $3}')
      ;;
    *)
      version="unknown"
      ;;
  esac

  echo "$version"
}

# Check common development tools
COMMON_TOOLS=(
  "git:Git version control"
  "node:Node.js runtime"
  "python3:Python 3 interpreter"
  "go:Go language"
  "rustc:Rust compiler"
  "ruby:Ruby interpreter"
  "java:Java runtime"
  "php:PHP interpreter"
  "docker:Docker container runtime"
  "make:Make build tool"
)

[[ "$VERBOSE" == true ]] && echo -e "${BLUE}Checking development tools...${NC}"

for tool_info in "${COMMON_TOOLS[@]}"; do
  IFS=':' read -r tool description <<< "$tool_info"

  if command_exists "$tool"; then
    version=$(get_version "$tool")
    TOOLS["$tool"]="installed:$version:ok"
    [[ "$VERBOSE" == true ]] && echo -e "${GREEN}✓${NC} $description: $version"
  else
    TOOLS["$tool"]="missing::missing"
    ISSUES+=("$tool is not installed")
    RECOMMENDATIONS+=("Install $description")
    OVERALL_STATUS="error"
    [[ "$VERBOSE" == true ]] && echo -e "${RED}✗${NC} $description: not found"
  fi
done

# Check package managers
PACKAGE_MANAGERS=(
  "npm:npm package manager"
  "yarn:Yarn package manager"
  "pnpm:pnpm package manager"
  "pip3:Python pip"
  "cargo:Rust cargo"
  "gem:Ruby gems"
  "composer:PHP composer"
  "maven:Maven build tool"
)

[[ "$VERBOSE" == true ]] && echo -e "\n${BLUE}Checking package managers...${NC}"

for pm_info in "${PACKAGE_MANAGERS[@]}"; do
  IFS=':' read -r pm description <<< "$pm_info"

  if command_exists "$pm"; then
    version=$(get_version "$pm")
    TOOLS["$pm"]="installed:$version:ok"
    [[ "$VERBOSE" == true ]] && echo -e "${GREEN}✓${NC} $description: $version"
  else
    TOOLS["$pm"]="missing::optional"
    [[ "$VERBOSE" == true ]] && echo -e "${YELLOW}!${NC} $description: not found (optional)"
  fi
done

# Check version managers
[[ "$VERBOSE" == true ]] && echo -e "\n${BLUE}Checking version managers...${NC}"

VERSION_MANAGERS=(
  "nvm:Node Version Manager"
  "pyenv:Python version manager"
  "rbenv:Ruby version manager"
  "rustup:Rust toolchain manager"
)

for vm_info in "${VERSION_MANAGERS[@]}"; do
  IFS=':' read -r vm description <<< "$vm_info"

  # Special check for nvm (it's a shell function)
  if [[ "$vm" == "nvm" ]]; then
    if [[ -d "$HOME/.nvm" ]] || [[ -n "${NVM_DIR:-}" ]]; then
      TOOLS["$vm"]="installed:detected:ok"
      [[ "$VERBOSE" == true ]] && echo -e "${GREEN}✓${NC} $description: detected"
    else
      TOOLS["$vm"]="missing::optional"
      [[ "$VERBOSE" == true ]] && echo -e "${YELLOW}!${NC} $description: not found (optional)"
    fi
  elif command_exists "$vm"; then
    TOOLS["$vm"]="installed:detected:ok"
    [[ "$VERBOSE" == true ]] && echo -e "${GREEN}✓${NC} $description: detected"
  else
    TOOLS["$vm"]="missing::optional"
    [[ "$VERBOSE" == true ]] && echo -e "${YELLOW}!${NC} $description: not found (optional)"
  fi
done

# Check PATH configuration
[[ "$VERBOSE" == true ]] && echo -e "\n${BLUE}Checking PATH configuration...${NC}"

PATH_VALID=true
PATH_ISSUES=()

# Check for common bin directories
COMMON_PATHS=(
  "/usr/local/bin"
  "/usr/bin"
  "$HOME/.local/bin"
)

for path in "${COMMON_PATHS[@]}"; do
  if [[ ":$PATH:" != *":$path:"* ]]; then
    PATH_ISSUES+=("$path not in PATH")
    PATH_VALID=false
    OVERALL_STATUS="warning"
  fi
done

if [[ "$PATH_VALID" == true ]]; then
  [[ "$VERBOSE" == true ]] && echo -e "${GREEN}✓${NC} PATH configuration looks good"
else
  [[ "$VERBOSE" == true ]] && echo -e "${YELLOW}!${NC} PATH issues detected"
  for issue in "${PATH_ISSUES[@]}"; do
    [[ "$VERBOSE" == true ]] && echo -e "  ${YELLOW}-${NC} $issue"
  done
fi

# Generate output
if [[ "$JSON_OUTPUT" == true ]]; then
  # JSON output
  echo "{"
  echo "  \"status\": \"$OVERALL_STATUS\","
  echo "  \"tools\": {"

  first=true
  for tool in "${!TOOLS[@]}"; do
    IFS=':' read -r installed version status <<< "${TOOLS[$tool]}"
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "    \"$tool\": {\"installed\": $([ "$installed" == "installed" ] && echo "true" || echo "false"), \"version\": \"$version\", \"status\": \"$status\"}"
  done

  echo ""
  echo "  },"
  echo "  \"path\": {"
  echo "    \"valid\": $([ "$PATH_VALID" == true ] && echo "true" || echo "false"),"
  echo "    \"issues\": ["

  first=true
  for issue in "${PATH_ISSUES[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "      \"$issue\""
  done

  echo ""
  echo "    ]"
  echo "  },"
  echo "  \"issues\": ["

  first=true
  for issue in "${ISSUES[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "    \"$issue\""
  done

  echo ""
  echo "  ],"
  echo "  \"recommendations\": ["

  first=true
  for rec in "${RECOMMENDATIONS[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "    \"$rec\""
  done

  echo ""
  echo "  ]"
  echo "}"
else
  # Human-readable output
  echo ""
  echo "================================"
  echo "Environment Check Summary"
  echo "================================"
  echo ""
  echo "Overall Status: $OVERALL_STATUS"
  echo ""

  if [[ ${#ISSUES[@]} -gt 0 ]]; then
    echo "Issues Found:"
    for issue in "${ISSUES[@]}"; do
      echo "  - $issue"
    done
    echo ""
  fi

  if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
    echo "Recommendations:"
    for rec in "${RECOMMENDATIONS[@]}"; do
      echo "  - $rec"
    done
    echo ""
  fi

  if [[ ${#ISSUES[@]} -eq 0 ]]; then
    echo "No critical issues found!"
  fi
fi

# Exit with appropriate code
if [[ "$OVERALL_STATUS" == "error" ]]; then
  exit 1
elif [[ "$OVERALL_STATUS" == "warning" ]]; then
  exit 0
else
  exit 0
fi

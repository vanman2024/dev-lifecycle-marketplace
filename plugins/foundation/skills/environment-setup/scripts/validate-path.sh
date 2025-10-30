#!/usr/bin/env bash
#
# validate-path.sh - Verify PATH configuration and detect issues
#
# Usage: ./validate-path.sh [--json] [--verbose]
#
# Validates PATH environment variable, checks for common issues,
# and provides recommendations for PATH configuration

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

JSON_OUTPUT=false
VERBOSE=false

# Parse arguments
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

# Initialize tracking
declare -a PATH_ENTRIES
declare -a MISSING_PATHS
declare -a INVALID_PATHS
declare -a DUPLICATE_PATHS
declare -a RECOMMENDATIONS
OVERALL_STATUS="success"

# Parse PATH into array
IFS=':' read -ra PATH_ENTRIES <<< "$PATH"

[[ "$VERBOSE" == true ]] && echo -e "${BLUE}Analyzing PATH configuration...${NC}\n"
[[ "$VERBOSE" == true ]] && echo "Total PATH entries: ${#PATH_ENTRIES[@]}"
[[ "$VERBOSE" == true ]] && echo ""

# Check for duplicate entries
declare -A PATH_SEEN
for i in "${!PATH_ENTRIES[@]}"; do
  path="${PATH_ENTRIES[$i]}"

  if [[ -n "${PATH_SEEN[$path]:-}" ]]; then
    DUPLICATE_PATHS+=("$path")
    OVERALL_STATUS="warning"
  else
    PATH_SEEN["$path"]=1
  fi
done

# Check for non-existent directories
for path in "${PATH_ENTRIES[@]}"; do
  if [[ ! -d "$path" ]]; then
    INVALID_PATHS+=("$path")
    OVERALL_STATUS="warning"
  fi
done

# Check for common required paths
REQUIRED_PATHS=(
  "/usr/local/bin"
  "/usr/bin"
  "/bin"
)

RECOMMENDED_PATHS=(
  "$HOME/.local/bin"
  "/usr/local/sbin"
  "/usr/sbin"
  "/sbin"
)

# Check required paths
for required_path in "${REQUIRED_PATHS[@]}"; do
  if [[ ":$PATH:" != *":$required_path:"* ]]; then
    MISSING_PATHS+=("$required_path (required)")
    OVERALL_STATUS="error"
  fi
done

# Check recommended paths (only warn if they exist but not in PATH)
for recommended_path in "${RECOMMENDED_PATHS[@]}"; do
  if [[ -d "$recommended_path" ]] && [[ ":$PATH:" != *":$recommended_path:"* ]]; then
    MISSING_PATHS+=("$recommended_path (recommended)")
    [[ "$OVERALL_STATUS" != "error" ]] && OVERALL_STATUS="warning"
  fi
done

# Check for language-specific paths
LANGUAGE_PATHS=(
  "$HOME/.nvm"
  "$HOME/.pyenv/bin"
  "$HOME/.rbenv/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.local/share/pnpm"
  "$HOME/.yarn/bin"
)

for lang_path in "${LANGUAGE_PATHS[@]}"; do
  if [[ -d "$lang_path" ]] && [[ ":$PATH:" != *":$lang_path:"* ]]; then
    MISSING_PATHS+=("$lang_path (language tools)")
    [[ "$OVERALL_STATUS" != "error" ]] && OVERALL_STATUS="warning"
  fi
done

# Generate recommendations
if [[ ${#DUPLICATE_PATHS[@]} -gt 0 ]]; then
  RECOMMENDATIONS+=("Remove duplicate PATH entries to simplify configuration")
fi

if [[ ${#INVALID_PATHS[@]} -gt 0 ]]; then
  RECOMMENDATIONS+=("Remove non-existent directories from PATH")
fi

if [[ ${#MISSING_PATHS[@]} -gt 0 ]]; then
  RECOMMENDATIONS+=("Add missing directories to PATH in shell configuration")
fi

# Check PATH ordering (system paths should generally come before user paths)
USER_PATHS_FIRST=false
for path in "${PATH_ENTRIES[@]}"; do
  if [[ "$path" =~ ^/usr/(local/)?bin$ ]]; then
    break
  fi
  if [[ "$path" =~ ^$HOME ]]; then
    USER_PATHS_FIRST=true
    break
  fi
done

if [[ "$USER_PATHS_FIRST" == true ]]; then
  RECOMMENDATIONS+=("Consider moving system paths before user paths for security")
  [[ "$OVERALL_STATUS" != "error" ]] && OVERALL_STATUS="warning"
fi

# Detect shell and provide configuration guidance
SHELL_NAME=$(basename "$SHELL")
SHELL_RC=""

case $SHELL_NAME in
  bash)
    if [[ -f "$HOME/.bashrc" ]]; then
      SHELL_RC="$HOME/.bashrc"
    elif [[ -f "$HOME/.bash_profile" ]]; then
      SHELL_RC="$HOME/.bash_profile"
    fi
    ;;
  zsh)
    SHELL_RC="$HOME/.zshrc"
    ;;
  fish)
    SHELL_RC="$HOME/.config/fish/config.fish"
    ;;
esac

# Non-JSON output
if [[ "$JSON_OUTPUT" == false ]]; then
  echo -e "${BLUE}PATH Validation Results${NC}"
  echo "================================"
  echo ""

  # Show PATH entries if verbose
  if [[ "$VERBOSE" == true ]]; then
    echo "Current PATH entries:"
    for i in "${!PATH_ENTRIES[@]}"; do
      path="${PATH_ENTRIES[$i]}"
      if [[ -d "$path" ]]; then
        echo -e "  ${GREEN}[$((i+1))]${NC} $path"
      else
        echo -e "  ${RED}[$((i+1))]${NC} $path (does not exist)"
      fi
    done
    echo ""
  fi

  # Show issues
  if [[ ${#DUPLICATE_PATHS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Duplicate Paths:${NC}"
    for path in "${DUPLICATE_PATHS[@]}"; do
      echo "  - $path"
    done
    echo ""
  fi

  if [[ ${#INVALID_PATHS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Invalid Paths (do not exist):${NC}"
    for path in "${INVALID_PATHS[@]}"; do
      echo "  - $path"
    done
    echo ""
  fi

  if [[ ${#MISSING_PATHS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Missing Paths:${NC}"
    for path in "${MISSING_PATHS[@]}"; do
      echo "  - $path"
    done
    echo ""
  fi

  # Show recommendations
  if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
    echo -e "${BLUE}Recommendations:${NC}"
    for rec in "${RECOMMENDATIONS[@]}"; do
      echo "  - $rec"
    done
    echo ""
  fi

  # Show shell configuration file
  if [[ -n "$SHELL_RC" ]]; then
    echo "Shell configuration: $SHELL_RC"
    echo ""
  fi

  # Overall status
  case $OVERALL_STATUS in
    success)
      echo -e "${GREEN}✓ PATH configuration is valid${NC}"
      ;;
    warning)
      echo -e "${YELLOW}! PATH configuration has warnings${NC}"
      ;;
    error)
      echo -e "${RED}✗ PATH configuration has errors${NC}"
      ;;
  esac

else
  # JSON output
  echo "{"
  echo "  \"status\": \"$OVERALL_STATUS\","
  echo "  \"shell\": \"$SHELL_NAME\","
  echo "  \"shell_rc\": \"$SHELL_RC\","
  echo "  \"total_entries\": ${#PATH_ENTRIES[@]},"
  echo "  \"path_entries\": ["

  first=true
  for path in "${PATH_ENTRIES[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "    {\"path\": \"$path\", \"exists\": $([ -d "$path" ] && echo "true" || echo "false")}"
  done

  echo ""
  echo "  ],"
  echo "  \"issues\": {"
  echo "    \"duplicates\": ["

  first=true
  for path in "${DUPLICATE_PATHS[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "      \"$path\""
  done

  echo ""
  echo "    ],"
  echo "    \"invalid\": ["

  first=true
  for path in "${INVALID_PATHS[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "      \"$path\""
  done

  echo ""
  echo "    ],"
  echo "    \"missing\": ["

  first=true
  for path in "${MISSING_PATHS[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "      \"$path\""
  done

  echo ""
  echo "    ]"
  echo "  },"
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
fi

# Exit with appropriate code
case $OVERALL_STATUS in
  error)
    exit 1
    ;;
  warning)
    exit 0
    ;;
  success)
    exit 0
    ;;
esac

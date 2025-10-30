#!/usr/bin/env bash
#
# check-env-vars.sh - Validate environment variables and configuration
#
# Usage: ./check-env-vars.sh [--json] [--required VAR1,VAR2,...] [--check-file FILE]
#
# Validates required environment variables, checks for missing/empty values,
# and provides configuration recommendations

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

JSON_OUTPUT=false
REQUIRED_VARS=()
CHECK_FILE=""
PROJECT_DIR="${PWD}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    --required)
      IFS=',' read -ra REQUIRED_VARS <<< "$2"
      shift 2
      ;;
    --check-file)
      CHECK_FILE="$2"
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

# Initialize tracking
declare -A ENV_STATUS
declare -a MISSING_VARS
declare -a EMPTY_VARS
declare -a VALID_VARS
declare -a RECOMMENDATIONS
declare -a ENV_FILES_FOUND
OVERALL_STATUS="success"

# Common environment variable patterns to check
COMMON_PATTERNS=(
  "NODE_ENV:Node environment (development/production)"
  "PATH:System executable paths"
  "HOME:User home directory"
  "USER:Current username"
  "SHELL:User shell"
  "LANG:System locale"
)

# Development-specific common variables
DEV_PATTERNS=(
  "PORT:Application port"
  "DATABASE_URL:Database connection string"
  "API_KEY:API authentication key"
  "API_SECRET:API secret key"
  "JWT_SECRET:JWT signing secret"
  "SESSION_SECRET:Session encryption secret"
  "REDIS_URL:Redis connection string"
  "AWS_ACCESS_KEY_ID:AWS access key"
  "AWS_SECRET_ACCESS_KEY:AWS secret key"
  "GITHUB_TOKEN:GitHub API token"
  "OPENAI_API_KEY:OpenAI API key"
  "ANTHROPIC_API_KEY:Anthropic API key"
)

# Function to check if variable is set and non-empty
check_var() {
  local var_name=$1
  local var_value="${!var_name:-}"

  if [[ -z "${!var_name+x}" ]]; then
    # Variable is not set
    return 1
  elif [[ -z "$var_value" ]]; then
    # Variable is set but empty
    return 2
  else
    # Variable is set and non-empty
    return 0
  fi
}

# Function to safely check variable without exposing value
safe_check_var() {
  local var_name=$1

  if check_var "$var_name"; then
    echo "set"
  elif [[ $? -eq 2 ]]; then
    echo "empty"
  else
    echo "missing"
  fi
}

# Function to detect sensitive variables (don't log values)
is_sensitive() {
  local var_name=$1

  [[ "$var_name" =~ (KEY|SECRET|PASSWORD|TOKEN|CREDENTIAL|AUTH) ]]
}

# Function to find and parse .env files
find_env_files() {
  local search_dir="$1"

  # Common .env file patterns
  local env_patterns=(
    ".env"
    ".env.local"
    ".env.development"
    ".env.production"
    ".env.test"
    ".env.example"
  )

  for pattern in "${env_patterns[@]}"; do
    local env_file="$search_dir/$pattern"
    if [[ -f "$env_file" ]]; then
      ENV_FILES_FOUND+=("$pattern")

      # Don't parse .env.example as it contains placeholders
      [[ "$pattern" == ".env.example" ]] && continue

      # Parse the .env file
      while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue

        # Extract variable name (before =)
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)= ]]; then
          local var_name="${BASH_REMATCH[1]}"

          # Check if it's set in the environment
          if [[ -z "${REQUIRED_VARS[*]}" ]]; then
            REQUIRED_VARS+=("$var_name")
          fi
        fi
      done < "$env_file"
    fi
  done
}

# If no required vars specified, try to detect from .env files
if [[ ${#REQUIRED_VARS[@]} -eq 0 ]] && [[ -z "$CHECK_FILE" ]]; then
  find_env_files "$PROJECT_DIR"
fi

# If check-file specified, parse it for required variables
if [[ -n "$CHECK_FILE" ]] && [[ -f "$CHECK_FILE" ]]; then
  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue

    # Extract variable name
    local var_name=$(echo "$line" | awk '{print $1}')
    REQUIRED_VARS+=("$var_name")
  done < "$CHECK_FILE"
fi

[[ "$JSON_OUTPUT" == false ]] && echo -e "${BLUE}Validating environment variables...${NC}\n"

# If still no required vars, check common system variables
if [[ ${#REQUIRED_VARS[@]} -eq 0 ]]; then
  for pattern in "${COMMON_PATTERNS[@]}"; do
    IFS=':' read -r var_name description <<< "$pattern"
    REQUIRED_VARS+=("$var_name")
  done

  [[ "$JSON_OUTPUT" == false ]] && echo "No requirements found, checking common system variables"
  [[ "$JSON_OUTPUT" == false ]] && echo ""
fi

# Check each required variable
for var_name in "${REQUIRED_VARS[@]}"; do
  local status=$(safe_check_var "$var_name")

  case $status in
    set)
      ENV_STATUS["$var_name"]="set"
      VALID_VARS+=("$var_name")

      if [[ "$JSON_OUTPUT" == false ]]; then
        if is_sensitive "$var_name"; then
          echo -e "${GREEN}✓${NC} $var_name: set (value hidden)"
        else
          local value="${!var_name}"
          # Truncate long values
          if [[ ${#value} -gt 50 ]]; then
            echo -e "${GREEN}✓${NC} $var_name: ${value:0:47}..."
          else
            echo -e "${GREEN}✓${NC} $var_name: $value"
          fi
        fi
      fi
      ;;
    empty)
      ENV_STATUS["$var_name"]="empty"
      EMPTY_VARS+=("$var_name")
      OVERALL_STATUS="warning"

      [[ "$JSON_OUTPUT" == false ]] && echo -e "${YELLOW}!${NC} $var_name: set but empty"
      ;;
    missing)
      ENV_STATUS["$var_name"]="missing"
      MISSING_VARS+=("$var_name")
      OVERALL_STATUS="error"

      [[ "$JSON_OUTPUT" == false ]] && echo -e "${RED}✗${NC} $var_name: not set"
      ;;
  esac
done

# Generate recommendations
if [[ ${#MISSING_VARS[@]} -gt 0 ]] || [[ ${#EMPTY_VARS[@]} -gt 0 ]]; then
  RECOMMENDATIONS+=("Create or update .env file with missing variables")
fi

if [[ ${#ENV_FILES_FOUND[@]} -eq 0 ]]; then
  RECOMMENDATIONS+=("Consider creating .env file for environment configuration")
fi

# Check for .env.example
if [[ -f "$PROJECT_DIR/.env.example" ]] && [[ ! -f "$PROJECT_DIR/.env" ]]; then
  RECOMMENDATIONS+=("Copy .env.example to .env and configure values")
fi

# Check for sensitive variables in shell history
if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
  RECOMMENDATIONS+=("Set missing variables in shell configuration or .env file")
fi

# Non-JSON output
if [[ "$JSON_OUTPUT" == false ]]; then
  echo ""
  echo "================================"
  echo "Environment Variables Summary"
  echo "================================"
  echo ""

  if [[ ${#ENV_FILES_FOUND[@]} -gt 0 ]]; then
    echo "Environment files found: ${ENV_FILES_FOUND[*]}"
    echo ""
  fi

  echo "Valid: ${#VALID_VARS[@]}"
  echo "Empty: ${#EMPTY_VARS[@]}"
  echo "Missing: ${#MISSING_VARS[@]}"
  echo ""

  if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
    echo -e "${RED}Missing Variables:${NC}"
    for var in "${MISSING_VARS[@]}"; do
      echo "  - $var"
    done
    echo ""
  fi

  if [[ ${#EMPTY_VARS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Empty Variables:${NC}"
    for var in "${EMPTY_VARS[@]}"; do
      echo "  - $var"
    done
    echo ""
  fi

  if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
    echo -e "${BLUE}Recommendations:${NC}"
    for rec in "${RECOMMENDATIONS[@]}"; do
      echo "  - $rec"
    done
    echo ""
  fi

  # Overall status
  case $OVERALL_STATUS in
    success)
      echo -e "${GREEN}✓ All required environment variables are configured${NC}"
      ;;
    warning)
      echo -e "${YELLOW}! Some environment variables are empty${NC}"
      ;;
    error)
      echo -e "${RED}✗ Missing required environment variables${NC}"
      ;;
  esac

else
  # JSON output
  echo "{"
  echo "  \"status\": \"$OVERALL_STATUS\","
  echo "  \"env_files\": ["

  first=true
  for file in "${ENV_FILES_FOUND[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false
    echo -n "    \"$file\""
  done

  echo ""
  echo "  ],"
  echo "  \"variables\": {"

  first=true
  for var_name in "${!ENV_STATUS[@]}"; do
    [[ "$first" == false ]] && echo ","
    first=false

    local status="${ENV_STATUS[$var_name]}"
    echo -n "    \"$var_name\": {"
    echo -n "\"status\": \"$status\", "
    echo -n "\"sensitive\": $(is_sensitive "$var_name" && echo "true" || echo "false")"
    echo -n "}"
  done

  echo ""
  echo "  },"
  echo "  \"summary\": {"
  echo "    \"valid\": ${#VALID_VARS[@]},"
  echo "    \"empty\": ${#EMPTY_VARS[@]},"
  echo "    \"missing\": ${#MISSING_VARS[@]}"
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

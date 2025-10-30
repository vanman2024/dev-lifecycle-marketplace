#!/usr/bin/env bash
#
# validate-env.sh - Validate environment variables before deployment
#
# Usage: bash validate-env.sh <env-file> [required-vars-file]
#

set -euo pipefail

ENV_FILE="${1:-}"
REQUIRED_VARS_FILE="${2:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "ℹ $1"; }

# Check if env file is specified
if [[ -z "$ENV_FILE" ]]; then
    print_error "Environment file not specified"
    echo "Usage: $0 <env-file> [required-vars-file]"
    exit 1
fi

# Check if env file exists
if [[ ! -f "$ENV_FILE" ]]; then
    print_error "Environment file not found: $ENV_FILE"
    exit 1
fi

print_info "Validating environment file: $ENV_FILE"
echo ""

# Load environment variables from file
set -a
source "$ENV_FILE"
set +a

# Track validation status
ERRORS=0
WARNINGS=0

# Default required variables for common deployment scenarios
DEFAULT_REQUIRED_VARS=(
    "NODE_ENV"
    "DATABASE_URL"
)

# Function to check if variable is set and non-empty
check_var() {
    local var_name="$1"
    local var_value="${!var_name:-}"

    if [[ -z "$var_value" ]]; then
        print_error "$var_name is not set or empty"
        ((ERRORS++))
        return 1
    else
        # Mask sensitive values in output
        if [[ "$var_name" =~ (KEY|SECRET|PASSWORD|TOKEN|PRIVATE) ]]; then
            local masked_value="${var_value:0:4}****${var_value: -4}"
            print_success "$var_name is set (${masked_value})"
        else
            print_success "$var_name is set"
        fi
        return 0
    fi
}

# Function to validate URL format
validate_url() {
    local var_name="$1"
    local url="${!var_name:-}"

    if [[ -z "$url" ]]; then
        return 1
    fi

    # Basic URL validation
    if [[ "$url" =~ ^https?:// ]] || [[ "$url" =~ ^postgresql:// ]] || [[ "$url" =~ ^mongodb:// ]]; then
        print_success "$var_name has valid URL format"
        return 0
    else
        print_warning "$var_name may have invalid URL format: $url"
        ((WARNINGS++))
        return 1
    fi
}

# Function to check for common security issues
check_security() {
    local var_name="$1"
    local var_value="${!var_name:-}"

    if [[ -z "$var_value" ]]; then
        return 1
    fi

    # Check for common insecure values
    case "$var_value" in
        "password"|"secret"|"changeme"|"123456"|"admin")
            print_error "$var_name contains insecure value"
            ((ERRORS++))
            return 1
            ;;
        "test"|"development"|"dev")
            if [[ "$ENV_FILE" =~ (production|prod) ]]; then
                print_warning "$var_name contains development value in production config"
                ((WARNINGS++))
            fi
            ;;
    esac

    # Check minimum length for secrets
    if [[ "$var_name" =~ (SECRET|KEY|TOKEN) ]] && [[ ${#var_value} -lt 16 ]]; then
        print_warning "$var_name is too short (< 16 characters) for a secret"
        ((WARNINGS++))
    fi

    return 0
}

# Load required variables list
REQUIRED_VARS=()

if [[ -n "$REQUIRED_VARS_FILE" ]] && [[ -f "$REQUIRED_VARS_FILE" ]]; then
    print_info "Loading required variables from: $REQUIRED_VARS_FILE"
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        REQUIRED_VARS+=("$line")
    done < "$REQUIRED_VARS_FILE"
else
    print_info "Using default required variables"
    REQUIRED_VARS=("${DEFAULT_REQUIRED_VARS[@]}")
fi

echo ""
print_info "Checking required variables..."
echo ""

# Check all required variables
for var in "${REQUIRED_VARS[@]}"; do
    check_var "$var"

    # Additional validation for specific variable types
    if [[ "$var" =~ _URL$ ]]; then
        validate_url "$var"
    fi

    check_security "$var"
done

echo ""

# Check for NODE_ENV specific validations
if [[ -n "${NODE_ENV:-}" ]]; then
    print_info "Environment: $NODE_ENV"

    case "$NODE_ENV" in
        production|prod)
            print_info "Running production-specific validations..."

            # Ensure no development configs in production
            if [[ -n "${DEBUG:-}" ]] && [[ "$DEBUG" == "true" ]]; then
                print_warning "DEBUG is enabled in production"
                ((WARNINGS++))
            fi

            # Check for localhost URLs
            while IFS='=' read -r name value; do
                if [[ "$value" =~ localhost|127\.0\.0\.1 ]]; then
                    print_error "$name contains localhost in production: $value"
                    ((ERRORS++))
                fi
            done < <(grep -E '.*=' "$ENV_FILE" || true)
            ;;
        development|dev|test)
            print_info "Development environment - relaxed validation"
            ;;
        *)
            print_warning "Unknown NODE_ENV value: $NODE_ENV"
            ((WARNINGS++))
            ;;
    esac
fi

# Check for common database URL formats
if [[ -n "${DATABASE_URL:-}" ]]; then
    case "$DATABASE_URL" in
        postgres*|postgresql*)
            print_success "PostgreSQL database detected"
            ;;
        mongodb*|mongo*)
            print_success "MongoDB database detected"
            ;;
        mysql*)
            print_success "MySQL database detected"
            ;;
        sqlite*)
            print_success "SQLite database detected"
            if [[ "$ENV_FILE" =~ (production|prod) ]]; then
                print_warning "SQLite not recommended for production"
                ((WARNINGS++))
            fi
            ;;
        *)
            print_warning "Unknown database type in DATABASE_URL"
            ((WARNINGS++))
            ;;
    esac
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    print_success "All validations passed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    print_warning "Validation passed with $WARNINGS warning(s)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
else
    print_error "Validation failed with $ERRORS error(s) and $WARNINGS warning(s)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi

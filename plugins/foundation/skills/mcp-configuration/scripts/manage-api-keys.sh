#!/bin/bash
# manage-api-keys.sh - Securely manage API keys in .env files
# Usage: bash manage-api-keys.sh --action ACTION [OPTIONS]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
ACTION=""
KEY_NAME=""
KEY_VALUE=""
ENV_FILE=".env"
FORCE=false

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_usage() {
    echo "Usage: bash manage-api-keys.sh [OPTIONS]"
    echo ""
    echo "Actions:"
    echo "  --action add          Add or update API key"
    echo "  --action list         List all API keys (values hidden)"
    echo "  --action remove       Remove API key"
    echo "  --action validate     Validate .env file format"
    echo ""
    echo "Options:"
    echo "  --key-name NAME       API key name (for add/remove)"
    echo "  --key-value VALUE     API key value (for add, optional - will prompt)"
    echo "  --env-file PATH       Path to .env file (default: ./.env)"
    echo "  --force               Overwrite existing key without confirmation"
    echo ""
    echo "Examples:"
    echo "  # Add API key (will prompt for value)"
    echo "  bash manage-api-keys.sh --action add --key-name OPENAI_API_KEY"
    echo ""
    echo "  # Add API key with value"
    echo "  bash manage-api-keys.sh --action add --key-name OPENAI_API_KEY \\"
    echo "    --key-value 'sk-xxxxx'"
    echo ""
    echo "  # List all keys"
    echo "  bash manage-api-keys.sh --action list"
    echo ""
    echo "  # Remove key"
    echo "  bash manage-api-keys.sh --action remove --key-name OLD_KEY"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --action)
            ACTION="$2"
            shift 2
            ;;
        --key-name)
            KEY_NAME="$2"
            shift 2
            ;;
        --key-value)
            KEY_VALUE="$2"
            shift 2
            ;;
        --env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Validate action
if [ -z "$ACTION" ]; then
    print_error "Action is required (--action)"
    print_usage
    exit 1
fi

if [[ ! "$ACTION" =~ ^(add|list|remove|validate)$ ]]; then
    print_error "Invalid action: $ACTION (must be add, list, remove, or validate)"
    exit 1
fi

# ============================================================
# Initialize .env file if needed
# ============================================================
ensure_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        print_info "Creating .env file: $ENV_FILE"
        touch "$ENV_FILE"
        chmod 600 "$ENV_FILE"  # Secure permissions
    fi

    # Ensure .env is in .gitignore
    if [ -f ".gitignore" ]; then
        if ! grep -q "^\.env$" .gitignore; then
            print_info "Adding .env to .gitignore"
            echo ".env" >> .gitignore
        fi
    else
        print_warning ".gitignore not found"
        print_info "Creating .gitignore with .env entry"
        echo ".env" > .gitignore
    fi
}

# ============================================================
# Action: Add API Key
# ============================================================
action_add() {
    if [ -z "$KEY_NAME" ]; then
        print_error "Key name is required for add action (--key-name)"
        exit 1
    fi

    # Validate key name format
    if [[ ! "$KEY_NAME" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
        print_error "Invalid key name: $KEY_NAME"
        print_error "Key names should be UPPERCASE with underscores (e.g., API_KEY)"
        exit 1
    fi

    ensure_env_file

    # Check if key already exists
    if grep -q "^${KEY_NAME}=" "$ENV_FILE"; then
        print_warning "Key already exists: $KEY_NAME"
        if [ "$FORCE" = false ]; then
            read -p "Overwrite existing value? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Aborted"
                exit 0
            fi
        fi
        # Remove existing key
        sed -i "/^${KEY_NAME}=/d" "$ENV_FILE"
    fi

    # Get key value if not provided
    if [ -z "$KEY_VALUE" ]; then
        echo -n "Enter value for $KEY_NAME (input hidden): "
        read -s KEY_VALUE
        echo

        if [ -z "$KEY_VALUE" ]; then
            print_error "Key value cannot be empty"
            exit 1
        fi
    fi

    # Add key to .env file
    echo "${KEY_NAME}=${KEY_VALUE}" >> "$ENV_FILE"

    print_info "✓ API key added: $KEY_NAME"
    print_info "Location: $ENV_FILE"
    print_info ""
    print_info "To use in .mcp.json:"
    print_info "  \"env\": {"
    print_info "    \"${KEY_NAME}\": \"\${${KEY_NAME}}\""
    print_info "  }"
}

# ============================================================
# Action: List API Keys
# ============================================================
action_list() {
    if [ ! -f "$ENV_FILE" ]; then
        print_warning "No .env file found: $ENV_FILE"
        exit 0
    fi

    print_info "API keys in $ENV_FILE:"
    echo ""

    # Read and display keys (hide values)
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        if [[ "$line" =~ ^([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
            KEY="${BASH_REMATCH[1]}"
            VALUE="${BASH_REMATCH[2]}"
            VALUE_LEN=${#VALUE}

            # Show first 4 chars + ***
            if [ $VALUE_LEN -gt 4 ]; then
                PREVIEW="${VALUE:0:4}***"
            else
                PREVIEW="***"
            fi

            echo "  $KEY = $PREVIEW"
        fi
    done < "$ENV_FILE"
}

# ============================================================
# Action: Remove API Key
# ============================================================
action_remove() {
    if [ -z "$KEY_NAME" ]; then
        print_error "Key name is required for remove action (--key-name)"
        exit 1
    fi

    if [ ! -f "$ENV_FILE" ]; then
        print_error ".env file not found: $ENV_FILE"
        exit 1
    fi

    # Check if key exists
    if ! grep -q "^${KEY_NAME}=" "$ENV_FILE"; then
        print_warning "Key not found: $KEY_NAME"
        exit 0
    fi

    # Confirm removal
    if [ "$FORCE" = false ]; then
        read -p "Remove key $KEY_NAME? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Aborted"
            exit 0
        fi
    fi

    # Remove key
    sed -i "/^${KEY_NAME}=/d" "$ENV_FILE"

    print_info "✓ API key removed: $KEY_NAME"
}

# ============================================================
# Action: Validate .env file
# ============================================================
action_validate() {
    if [ ! -f "$ENV_FILE" ]; then
        print_warning "No .env file found: $ENV_FILE"
        exit 0
    fi

    print_info "Validating $ENV_FILE"

    ERRORS=0
    LINE_NUM=0

    while IFS= read -r line; do
        ((LINE_NUM++))

        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Check format
        if [[ ! "$line" =~ ^[A-Z_][A-Z0-9_]*=.+$ ]]; then
            print_error "Line $LINE_NUM: Invalid format: $line"
            ((ERRORS++))
        fi
    done < "$ENV_FILE"

    # Check file permissions
    PERMS=$(stat -c "%a" "$ENV_FILE")
    if [ "$PERMS" != "600" ]; then
        print_warning "File permissions should be 600 (current: $PERMS)"
        print_info "Run: chmod 600 $ENV_FILE"
    fi

    # Check .gitignore
    if [ -f ".gitignore" ]; then
        if ! grep -q "^\.env$" .gitignore; then
            print_warning ".env not in .gitignore"
            print_info "Add '.env' to .gitignore to avoid committing secrets"
            ((ERRORS++))
        fi
    else
        print_warning ".gitignore not found"
        ((ERRORS++))
    fi

    if [ $ERRORS -eq 0 ]; then
        print_info "✓ .env file is valid"
    else
        print_error "Found $ERRORS issue(s)"
        exit 1
    fi
}

# ============================================================
# Execute action
# ============================================================
case $ACTION in
    add)
        action_add
        ;;
    list)
        action_list
        ;;
    remove)
        action_remove
        ;;
    validate)
        action_validate
        ;;
esac

exit 0

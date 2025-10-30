#!/bin/bash
# detect-dependencies.sh - Comprehensive dependency analysis from all package managers
# Usage: ./detect-dependencies.sh <project-path>

set -euo pipefail

PROJECT_PATH="${1:-.}"
RESULTS=()

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper to parse package.json dependencies
parse_package_json() {
    local file="$1"
    local dep_type="$2"

    if [[ ! -f "$file" ]]; then
        return
    fi

    echo -e "${YELLOW}Parsing $dep_type from package.json...${NC}" >&2

    # Extract dependencies section
    local in_deps=false
    local brace_count=0

    while IFS= read -r line; do
        if [[ "$line" =~ \"$dep_type\" ]]; then
            in_deps=true
            continue
        fi

        if [[ "$in_deps" == true ]]; then
            # Count braces to know when section ends
            if [[ "$line" =~ \{ ]]; then
                ((brace_count++)) || true
            fi
            if [[ "$line" =~ \} ]]; then
                ((brace_count--)) || true
                if [[ $brace_count -lt 0 ]]; then
                    break
                fi
            fi

            # Extract package and version
            if [[ "$line" =~ \"([^\"]+)\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
                local pkg="${BASH_REMATCH[1]}"
                local ver="${BASH_REMATCH[2]}"
                RESULTS+=("{\"name\":\"$pkg\",\"version\":\"$ver\",\"type\":\"$dep_type\",\"source\":\"package.json\"}")
            fi
        fi
    done < "$file"
}

# Parse requirements.txt
parse_requirements() {
    local file="$PROJECT_PATH/requirements.txt"

    if [[ ! -f "$file" ]]; then
        return
    fi

    echo -e "${YELLOW}Parsing requirements.txt...${NC}" >&2

    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
            continue
        fi

        # Extract package and version
        if [[ "$line" =~ ^([^=<>~!]+)(==|>=|<=|>|<|~=|!=)?(.*)$ ]]; then
            local pkg="${BASH_REMATCH[1]}"
            local operator="${BASH_REMATCH[2]}"
            local ver="${BASH_REMATCH[3]}"

            # Clean package name
            pkg=$(echo "$pkg" | tr -d '[:space:]')
            ver=$(echo "$ver" | tr -d '[:space:]')

            if [[ -z "$ver" ]]; then
                ver="latest"
            fi

            RESULTS+=("{\"name\":\"$pkg\",\"version\":\"$ver\",\"type\":\"production\",\"source\":\"requirements.txt\"}")
        fi
    done < "$file"
}

# Parse go.mod
parse_go_mod() {
    local file="$PROJECT_PATH/go.mod"

    if [[ ! -f "$file" ]]; then
        return
    fi

    echo -e "${YELLOW}Parsing go.mod...${NC}" >&2

    local in_require=false

    while IFS= read -r line; do
        if [[ "$line" =~ ^require ]]; then
            in_require=true
            # Handle single-line require
            if [[ "$line" =~ require[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
                local pkg="${BASH_REMATCH[1]}"
                local ver="${BASH_REMATCH[2]}"
                RESULTS+=("{\"name\":\"$pkg\",\"version\":\"$ver\",\"type\":\"production\",\"source\":\"go.mod\"}")
            fi
            continue
        fi

        if [[ "$in_require" == true ]]; then
            if [[ "$line" =~ ^[[:space:]]*\) ]]; then
                in_require=false
                continue
            fi

            if [[ "$line" =~ [[:space:]]*([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
                local pkg="${BASH_REMATCH[1]}"
                local ver="${BASH_REMATCH[2]}"
                RESULTS+=("{\"name\":\"$pkg\",\"version\":\"$ver\",\"type\":\"production\",\"source\":\"go.mod\"}")
            fi
        fi
    done < "$file"
}

# Parse Cargo.toml
parse_cargo_toml() {
    local file="$PROJECT_PATH/Cargo.toml"

    if [[ ! -f "$file" ]]; then
        return
    fi

    echo -e "${YELLOW}Parsing Cargo.toml...${NC}" >&2

    local in_deps=false
    local in_dev_deps=false

    while IFS= read -r line; do
        # Check for section headers
        if [[ "$line" =~ ^\[dependencies\] ]]; then
            in_deps=true
            in_dev_deps=false
            continue
        elif [[ "$line" =~ ^\[dev-dependencies\] ]]; then
            in_dev_deps=true
            in_deps=false
            continue
        elif [[ "$line" =~ ^\[.*\] ]]; then
            in_deps=false
            in_dev_deps=false
            continue
        fi

        # Parse dependencies
        if [[ "$in_deps" == true ]] || [[ "$in_dev_deps" == true ]]; then
            local dep_type="production"
            if [[ "$in_dev_deps" == true ]]; then
                dep_type="development"
            fi

            # Simple version: package = "version"
            if [[ "$line" =~ ^([^[:space:]]+)[[:space:]]*=[[:space:]]*\"([^\"]+)\" ]]; then
                local pkg="${BASH_REMATCH[1]}"
                local ver="${BASH_REMATCH[2]}"
                RESULTS+=("{\"name\":\"$pkg\",\"version\":\"$ver\",\"type\":\"$dep_type\",\"source\":\"Cargo.toml\"}")
            # Complex version: package = { version = "version" }
            elif [[ "$line" =~ ^([^[:space:]]+)[[:space:]]*=[[:space:]]*\{.*version[[:space:]]*=[[:space:]]*\"([^\"]+)\" ]]; then
                local pkg="${BASH_REMATCH[1]}"
                local ver="${BASH_REMATCH[2]}"
                RESULTS+=("{\"name\":\"$pkg\",\"version\":\"$ver\",\"type\":\"$dep_type\",\"source\":\"Cargo.toml\"}")
            fi
        fi
    done < "$file"
}

# Parse Gemfile
parse_gemfile() {
    local file="$PROJECT_PATH/Gemfile"

    if [[ ! -f "$file" ]]; then
        return
    fi

    echo -e "${YELLOW}Parsing Gemfile...${NC}" >&2

    while IFS= read -r line; do
        # Skip comments
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
            continue
        fi

        # Parse gem declarations
        if [[ "$line" =~ gem[[:space:]]+[\'\"']([^\'\"']+)[\'\"'][[:space:]]*,[[:space:]]*[\'\"']([^\'\"']+)[\'\"'] ]]; then
            local pkg="${BASH_REMATCH[1]}"
            local ver="${BASH_REMATCH[2]}"
            RESULTS+=("{\"name\":\"$pkg\",\"version\":\"$ver\",\"type\":\"production\",\"source\":\"Gemfile\"}")
        elif [[ "$line" =~ gem[[:space:]]+[\'\"']([^\'\"']+)[\'\"'] ]]; then
            local pkg="${BASH_REMATCH[1]}"
            RESULTS+=("{\"name\":\"$pkg\",\"version\":\"latest\",\"type\":\"production\",\"source\":\"Gemfile\"}")
        fi
    done < "$file"
}

# Main detection
echo -e "${GREEN}Starting dependency analysis...${NC}" >&2
echo -e "${YELLOW}Scanning: $PROJECT_PATH${NC}" >&2

# Detect all dependency files
if [[ -f "$PROJECT_PATH/package.json" ]]; then
    parse_package_json "$PROJECT_PATH/package.json" "dependencies"
    parse_package_json "$PROJECT_PATH/package.json" "devDependencies"
    parse_package_json "$PROJECT_PATH/package.json" "peerDependencies"
fi

parse_requirements
parse_go_mod
parse_cargo_toml
parse_gemfile

# Output JSON
echo "{"
echo "  \"project_path\": \"$PROJECT_PATH\","
echo "  \"dependencies\": ["

# Print results
first=true
for result in "${RESULTS[@]}"; do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    echo "    $result"
done

echo ""
echo "  ],"
echo "  \"count\": ${#RESULTS[@]},"
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

echo -e "${GREEN}Analysis complete! Found ${#RESULTS[@]} dependencies.${NC}" >&2

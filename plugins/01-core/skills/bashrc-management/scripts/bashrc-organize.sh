#!/usr/bin/env bash
# Script: bashrc-organize.sh
# Purpose: Reorganize .bashrc into clean, deduplicated sections
# Plugin: 01-core
# Skill: bashrc-management

set -uo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BASHRC="${1:-$HOME/.bashrc}"
BACKUP_FILE="$BASHRC.backup-$(date +%Y%m%d_%H%M%S)"
ORGANIZED_FILE="/tmp/bashrc-organized-$(date +%Y%m%d_%H%M%S)"

if [[ ! -f "$BASHRC" ]]; then
    echo -e "${RED}❌ ERROR: .bashrc not found at $BASHRC${NC}"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔧 Bashrc Organizer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================
# 1. CREATE BACKUP
# ============================================
echo -e "${CYAN}📦 Creating backup...${NC}"
cp "$BASHRC" "$BACKUP_FILE"
echo -e "  ${GREEN}✓ Backup saved to: $BACKUP_FILE${NC}"
echo ""

# ============================================
# 2. PARSE SECTIONS
# ============================================
echo -e "${CYAN}📖 Parsing sections...${NC}"

# Arrays to store unique entries
declare -A PATH_ENTRIES
declare -A EXPORTS
declare -A ALIASES
declare -A FUNCTIONS_TEXT

# Extract system defaults (lines 1-117 - keep as-is)
SYSTEM_DEFAULTS=$(sed -n '1,117p' "$BASHRC")

# Track what we've seen
declare -A seen_paths
declare -A seen_exports
declare -A seen_aliases

# ============================================
# 3. EXTRACT UNIQUE ENTRIES
# ============================================

# Extract PATH modifications (deduplicated)
while IFS= read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    line_content=$(echo "$line" | cut -d: -f2-)

    # Skip commented lines
    [[ "$line_content" =~ ^[[:space:]]*# ]] && continue

    # Extract path components
    if [[ "$line_content" =~ \$HOME/([^:\"\']+) ]] || [[ "$line_content" =~ \$\{HOME\}/([^:\"\']+) ]]; then
        path_component="${BASH_REMATCH[1]}"

        if [[ -z "${seen_paths[$path_component]:-}" ]]; then
            PATH_ENTRIES[$line_num]="$line_content"
            seen_paths[$path_component]=1
        fi
    elif [[ "$line_content" =~ PATH.*= ]] && [[ ! "$line_content" =~ WPATH ]]; then
        # Other PATH modifications
        path_key=$(echo "$line_content" | sed 's/export //' | sed 's/PATH=//')
        if [[ -z "${seen_paths[$path_key]:-}" ]]; then
            PATH_ENTRIES[$line_num]="$line_content"
            seen_paths[$path_key]=1
        fi
    fi
done < <(grep -n 'PATH.*=' "$BASHRC")

# Extract exports (deduplicated, excluding PATH and moved lines)
while IFS= read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    line_content=$(echo "$line" | cut -d: -f2-)

    # Skip commented, moved, or PATH lines
    [[ "$line_content" =~ ^[[:space:]]*# ]] && continue
    [[ "$line_content" =~ moved\ to ]] && continue
    [[ "$line_content" =~ ^[[:space:]]*export[[:space:]]+PATH ]] && continue

    if [[ "$line_content" =~ ^[[:space:]]*export[[:space:]]+([A-Z_][A-Z0-9_]*)= ]]; then
        var_name="${BASH_REMATCH[1]}"

        if [[ -z "${seen_exports[$var_name]:-}" ]]; then
            EXPORTS[$line_num]="$line_content"
            seen_exports[$var_name]=1
        fi
    fi
done < <(grep -n '^[[:space:]]*export' "$BASHRC")

# Extract aliases (deduplicated, excluding rm override comments)
while IFS= read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    line_content=$(echo "$line" | cut -d: -f2-)

    # Skip commented lines
    [[ "$line_content" =~ ^[[:space:]]*# ]] && continue

    if [[ "$line_content" =~ ^[[:space:]]*alias[[:space:]]+([a-zA-Z0-9_-]+)= ]]; then
        alias_name="${BASH_REMATCH[1]}"

        if [[ -z "${seen_aliases[$alias_name]:-}" ]]; then
            ALIASES[$line_num]="$line_content"
            seen_aliases[$alias_name]=1
        fi
    fi
done < <(grep -n '^[[:space:]]*alias' "$BASHRC")

# Extract functions (cdk, cdcb, winpath, shot-*, trash-*)
FUNCTIONS_TEXT=$(sed -n '/^cdk()/,/^}/p; /^cdcb()/,/^}/p; /^winpath()/,/^}/p; /^shot-latest()/,/^}/p; /^shot-latest-win()/,/^}/p; /^shot-copy-win()/,/^}/p; /^shot-copy-wsl()/,/^}/p; /^shot-cd()/,/^}/p; /^trash-size()/,/^}/p; /^trash-view()/,/^}/p' "$BASHRC")

echo -e "  ${GREEN}✓ Extracted ${#PATH_ENTRIES[@]} unique PATH modifications${NC}"
echo -e "  ${GREEN}✓ Extracted ${#EXPORTS[@]} unique exports${NC}"
echo -e "  ${GREEN}✓ Extracted ${#ALIASES[@]} unique aliases${NC}"
echo ""

# ============================================
# 4. BUILD ORGANIZED FILE
# ============================================
echo -e "${CYAN}🏗️  Building organized .bashrc...${NC}"

cat > "$ORGANIZED_FILE" << 'HEADER'
# ~/.bashrc: executed by bash(1) for non-login shells.
# Organized and deduplicated by bashrc-organize.sh
#
# This file has been reorganized into logical sections:
#   1. System Defaults (Ubuntu/Debian defaults)
#   2. Environment Variables
#   3. PATH Configuration
#   4. Aliases
#   5. Functions
#   6. Tool Loaders (NVM, Google Cloud, etc.)
#   7. Application Secrets

# ============================================================
# SYSTEM DEFAULTS
# ============================================================
HEADER

# Add system defaults
echo "$SYSTEM_DEFAULTS" >> "$ORGANIZED_FILE"

cat >> "$ORGANIZED_FILE" << 'SECTION2'

# ============================================================
# ENVIRONMENT VARIABLES
# ============================================================
SECTION2

# Add exports (sorted)
for key in $(echo "${!EXPORTS[@]}" | tr ' ' '\n' | sort -n); do
    echo "${EXPORTS[$key]}" >> "$ORGANIZED_FILE"
done

cat >> "$ORGANIZED_FILE" << 'SECTION3'

# ============================================================
# PATH CONFIGURATION
# ============================================================
# Consolidated PATH modifications (deduplicated)
SECTION3

# Add PATH modifications (sorted)
for key in $(echo "${!PATH_ENTRIES[@]}" | tr ' ' '\n' | sort -n); do
    echo "${PATH_ENTRIES[$key]}" >> "$ORGANIZED_FILE"
done

cat >> "$ORGANIZED_FILE" << 'SECTION4'

# ============================================================
# ALIASES
# ============================================================
SECTION4

# Add aliases (sorted)
for key in $(echo "${!ALIASES[@]}" | tr ' ' '\n' | sort -n); do
    echo "${ALIASES[$key]}" >> "$ORGANIZED_FILE"
done

cat >> "$ORGANIZED_FILE" << 'SECTION5'

# ============================================================
# FUNCTIONS
# ============================================================

# --- WSL path helpers (Windows <-> WSL) ---
SECTION5

# Add functions
echo "$FUNCTIONS_TEXT" >> "$ORGANIZED_FILE"

cat >> "$ORGANIZED_FILE" << 'SECTION6'

# ============================================================
# TOOL LOADERS
# ============================================================

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then
    . "$HOME/google-cloud-sdk/path.bash.inc"
fi
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then
    . "$HOME/google-cloud-sdk/completion.bash.inc"
fi

# MCP Global Setup (if exists)
if [ -f /home/gotime2022/mcp-kernel-new/scripts/mcp-global-setup.sh ]; then
    # Check if any MCP server is running
    if ! lsof -i :8011 >/dev/null 2>&1; then
        echo "Starting MCP servers..."
        /home/gotime2022/mcp-kernel-new/scripts/mcp-global-setup.sh >/dev/null 2>&1
    fi
fi

SECTION6

cat >> "$ORGANIZED_FILE" << 'SECTION7'

# ============================================================
# APPLICATION SECRETS
# ============================================================
# Per-app .env files (managed separately, never committed)

if [ -f "$HOME/.config/anthropic/.env" ]; then
  set -a; . "$HOME/.config/anthropic/.env"; set +a
fi

if [ -f "$HOME/.config/openai/.env" ]; then
  set -a; . "$HOME/.config/openai/.env"; set +a
fi

SECTION7

echo -e "  ${GREEN}✓ Organized file created${NC}"
echo ""

# ============================================
# 5. SHOW PREVIEW
# ============================================
echo -e "${CYAN}📊 Statistics:${NC}"
original_lines=$(wc -l < "$BASHRC")
new_lines=$(wc -l < "$ORGANIZED_FILE")
removed_lines=$((original_lines - new_lines))

echo "  Original:  $original_lines lines"
echo "  Organized: $new_lines lines"
echo "  Removed:   $removed_lines lines (duplicates + dead code)"
echo ""

# ============================================
# 6. PROMPT FOR REPLACEMENT
# ============================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚠️  Ready to replace your .bashrc${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Backup:    $BACKUP_FILE"
echo "Organized: $ORGANIZED_FILE"
echo ""
echo -e "${CYAN}Preview organized file:${NC}"
echo "  cat $ORGANIZED_FILE"
echo ""
echo -e "${CYAN}Compare with original:${NC}"
echo "  diff $BASHRC $ORGANIZED_FILE"
echo ""
read -p "Replace $BASHRC with organized version? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp "$ORGANIZED_FILE" "$BASHRC"
    echo -e "${GREEN}✅ Replaced $BASHRC${NC}"
    echo -e "${GREEN}✅ Backup saved: $BACKUP_FILE${NC}"
    echo ""
    echo -e "${CYAN}To apply changes:${NC}"
    echo "  source ~/.bashrc"
    echo ""
else
    echo -e "${YELLOW}❌ Cancelled - no changes made${NC}"
    echo -e "${CYAN}Organized version available at:${NC}"
    echo "  $ORGANIZED_FILE"
    echo ""
fi

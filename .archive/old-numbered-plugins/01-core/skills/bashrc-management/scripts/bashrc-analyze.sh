#!/usr/bin/env bash
# Script: bashrc-analyze.sh
# Purpose: Analyze .bashrc for duplicates, conflicts, and organization issues
# Plugin: 01-core
# Skill: bashrc-management

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BASHRC="${1:-$HOME/.bashrc}"

if [[ ! -f "$BASHRC" ]]; then
    echo -e "${RED}❌ ERROR: .bashrc not found at $BASHRC${NC}"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 Bashrc Analysis: $BASHRC${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================
# 1. FILE STATS
# ============================================
echo -e "${CYAN}📈 File Statistics${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

total_lines=$(wc -l < "$BASHRC")
non_empty_lines=$(grep -c -v '^[[:space:]]*$' "$BASHRC")
comment_lines=$(grep -c '^[[:space:]]*#' "$BASHRC")
code_lines=$((non_empty_lines - comment_lines))

echo "  Total lines:        $total_lines"
echo "  Code lines:         $code_lines"
echo "  Comment lines:      $comment_lines"
echo "  Empty lines:        $((total_lines - non_empty_lines))"
echo ""

# ============================================
# 2. DUPLICATE EXPORTS
# ============================================
echo -e "${CYAN}🔍 Duplicate PATH Modifications${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Find PATH modifications
path_mods=$(grep -n 'PATH.*=' "$BASHRC" | grep -v '^[[:space:]]*#')
path_count=$(echo "$path_mods" | wc -l)

echo "  Total PATH modifications: $path_count"
echo ""

# Check for duplicate path additions
declare -A path_entries
duplicates_found=0

while IFS= read -r line; do
    if [[ "$line" =~ \$HOME/([^:\"\']+) ]] || [[ "$line" =~ \$\{HOME\}/([^:\"\']+) ]]; then
        path="${BASH_REMATCH[1]}"
        line_num=$(echo "$line" | cut -d: -f1)

        if [[ -n "${path_entries[$path]:-}" ]]; then
            echo -e "  ${YELLOW}⚠️  Duplicate: $path${NC}"
            echo "      First:  line ${path_entries[$path]}"
            echo "      Again:  line $line_num"
            ((duplicates_found++))
        else
            path_entries[$path]=$line_num
        fi
    fi
done <<< "$path_mods"

if [[ $duplicates_found -eq 0 ]]; then
    echo -e "  ${GREEN}✓ No duplicate PATH entries found${NC}"
fi
echo ""

# ============================================
# 3. DUPLICATE EXPORTS (NON-PATH)
# ============================================
echo -e "${CYAN}🔍 Duplicate Environment Variables${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

declare -A export_vars
export_duplicates=0

while IFS= read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    line_content=$(echo "$line" | cut -d: -f2-)

    if [[ "$line_content" =~ ^[[:space:]]*export[[:space:]]+([A-Z_][A-Z0-9_]*)= ]]; then
        var_name="${BASH_REMATCH[1]}"

        if [[ "$var_name" != "PATH" ]]; then
            if [[ -n "${export_vars[$var_name]:-}" ]]; then
                echo -e "  ${YELLOW}⚠️  Duplicate: $var_name${NC}"
                echo "      First:  line ${export_vars[$var_name]}"
                echo "      Again:  line $line_num"
                ((export_duplicates++))
            else
                export_vars[$var_name]=$line_num
            fi
        fi
    fi
done < <(grep -n '^[[:space:]]*export' "$BASHRC" | grep -v '^[[:space:]]*#')

if [[ $export_duplicates -eq 0 ]]; then
    echo -e "  ${GREEN}✓ No duplicate exports found${NC}"
fi
echo ""

# ============================================
# 4. DUPLICATE ALIASES
# ============================================
echo -e "${CYAN}🔍 Duplicate Aliases${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

declare -A alias_defs
alias_duplicates=0

while IFS= read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    line_content=$(echo "$line" | cut -d: -f2-)

    if [[ "$line_content" =~ ^[[:space:]]*alias[[:space:]]+([a-zA-Z0-9_-]+)= ]]; then
        alias_name="${BASH_REMATCH[1]}"

        if [[ -n "${alias_defs[$alias_name]:-}" ]]; then
            echo -e "  ${YELLOW}⚠️  Duplicate: $alias_name${NC}"
            echo "      First:  line ${alias_defs[$alias_name]}"
            echo "      Again:  line $line_num"
            ((alias_duplicates++))
        else
            alias_defs[$alias_name]=$line_num
        fi
    fi
done < <(grep -n '^[[:space:]]*alias' "$BASHRC" | grep -v '^[[:space:]]*#')

if [[ $alias_duplicates -eq 0 ]]; then
    echo -e "  ${GREEN}✓ No duplicate aliases found${NC}"
fi
echo ""

# ============================================
# 5. SOURCE/LOADING ISSUES
# ============================================
echo -e "${CYAN}🔍 Source/Loading Analysis${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Count NVM loads
nvm_loads=$(grep -c 'NVM_DIR.*nvm.sh' "$BASHRC" || echo 0)
echo "  NVM loaded:         $nvm_loads times"

if [[ $nvm_loads -gt 1 ]]; then
    echo -e "    ${YELLOW}⚠️  NVM is loaded multiple times!${NC}"
    grep -n 'NVM_DIR.*nvm.sh' "$BASHRC" | sed 's/^/      Line /'
fi

# Check for env file loads
env_loads=$(grep -c '\.env' "$BASHRC" || echo 0)
echo "  .env files loaded:  $env_loads"
if [[ $env_loads -gt 0 ]]; then
    grep -n '\.env' "$BASHRC" | grep -v '^[[:space:]]*#' | sed 's/^/      /'
fi

echo ""

# ============================================
# 6. COMMENTED OUT CODE
# ============================================
echo -e "${CYAN}🔍 Commented Code & Dead Lines${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

moved_lines=$(grep -n 'moved to' "$BASHRC" | wc -l)
disabled_lines=$(grep -n 'DISABLED\|REMOVED\|CLEANED' "$BASHRC" | wc -l)

echo "  'moved to' comments:     $moved_lines"
echo "  DISABLED/REMOVED lines:  $disabled_lines"

if [[ $moved_lines -gt 0 ]]; then
    echo ""
    echo -e "  ${YELLOW}Lines marked as 'moved':${NC}"
    grep -n 'moved to' "$BASHRC" | sed 's/^/      /'
fi

echo ""

# ============================================
# 7. ORGANIZATION ISSUES
# ============================================
echo -e "${CYAN}🔍 Organization Issues${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if exports are scattered
export_lines=$(grep -n '^[[:space:]]*export' "$BASHRC" | grep -v '^[[:space:]]*#' | cut -d: -f1)
export_ranges=$(echo "$export_lines" | awk '{if(NR==1){start=$1} if($1-prev>10 && NR>1){print start"-"prev; start=$1} prev=$1} END{print start"-"prev}')
export_blocks=$(echo "$export_ranges" | wc -l)

echo "  Export statement blocks:  $export_blocks"
if [[ $export_blocks -gt 3 ]]; then
    echo -e "    ${YELLOW}⚠️  Exports are scattered across multiple sections${NC}"
fi

# Check if aliases are scattered
alias_lines=$(grep -n '^[[:space:]]*alias' "$BASHRC" | grep -v '^[[:space:]]*#' | cut -d: -f1)
alias_ranges=$(echo "$alias_lines" | awk '{if(NR==1){start=$1} if($1-prev>10 && NR>1){print start"-"prev; start=$1} prev=$1} END{print start"-"prev}')
alias_blocks=$(echo "$alias_ranges" | wc -l)

echo "  Alias statement blocks:   $alias_blocks"
if [[ $alias_blocks -gt 3 ]]; then
    echo -e "    ${YELLOW}⚠️  Aliases are scattered across multiple sections${NC}"
fi

echo ""

# ============================================
# 8. SUMMARY & RECOMMENDATIONS
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📋 Summary & Recommendations${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

total_issues=$((duplicates_found + export_duplicates + alias_duplicates))

if [[ $total_issues -eq 0 ]]; then
    echo -e "${GREEN}✅ No critical issues found!${NC}"
else
    echo -e "${YELLOW}⚠️  Found $total_issues issues:${NC}"
    [[ $duplicates_found -gt 0 ]] && echo "  - $duplicates_found duplicate PATH entries"
    [[ $export_duplicates -gt 0 ]] && echo "  - $export_duplicates duplicate exports"
    [[ $alias_duplicates -gt 0 ]] && echo "  - $alias_duplicates duplicate aliases"
fi

echo ""
echo -e "${CYAN}Recommendations:${NC}"
echo ""

if [[ $total_issues -gt 0 ]]; then
    echo "  1. Remove duplicate definitions to improve load time"
fi

if [[ $moved_lines -gt 0 ]]; then
    echo "  2. Remove $moved_lines 'moved to' comment lines (configs already moved)"
fi

if [[ $export_blocks -gt 3 ]] || [[ $alias_blocks -gt 3 ]]; then
    echo "  3. Reorganize into logical sections (exports, aliases, functions, etc.)"
fi

if [[ $nvm_loads -gt 1 ]]; then
    echo "  4. Remove duplicate NVM loading (keep only one)"
fi

echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  Run: /01-core:bashrc-organize"
echo "  This will create an organized version with backup"
echo ""

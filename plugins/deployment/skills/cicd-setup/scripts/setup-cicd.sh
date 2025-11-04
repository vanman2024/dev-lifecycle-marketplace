#!/bin/bash
#
# Complete CI/CD Setup - One Command
#
# Usage: ./setup-cicd.sh <platform> [project-path]
#
# Platforms: vercel | digitalocean-app | digitalocean-droplet | railway | netlify | cloudflare | auto
#
# Environment Variables:
#   VERCEL_TOKEN - Vercel authentication token
#   DIGITALOCEAN_ACCESS_TOKEN - DigitalOcean API token
#   RAILWAY_TOKEN - Railway authentication token
#   DRY_RUN - Set to "true" for dry run mode
#
# Exit Codes:
#   0 - CI/CD setup successful
#   1 - Setup failed
#   2 - Missing prerequisites

set -e

PLATFORM="${1:-auto}"
PROJECT_PATH="${2:-.}"
DRY_RUN="${DRY_RUN:-false}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_step() {
    echo -e "${BLUE}→${NC} $1"
}

log_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""
}

# Validate project path
if [[ ! -d "$PROJECT_PATH" ]]; then
    log_error "Project path does not exist: $PROJECT_PATH"
    exit 1
fi

cd "$PROJECT_PATH"

log_section "CI/CD Auto-Setup"
echo "Platform: $PLATFORM"
echo "Project Path: $(pwd)"
echo "Dry Run: $DRY_RUN"
echo ""

# ============================================================
# Phase 1: Prerequisites Check
# ============================================================
log_section "Phase 1: Prerequisites Check"

# Check gh CLI
log_step "Checking GitHub CLI (gh)..."
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is not installed"
    echo "Install with: brew install gh (macOS) or see https://cli.github.com"
    exit 2
fi
log_info "GitHub CLI installed: $(gh --version | head -1)"

# Check gh authentication
log_step "Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    log_error "GitHub CLI is not authenticated"
    echo "Run: gh auth login"
    exit 2
fi
log_info "GitHub CLI authenticated"

# Check git repository
log_step "Checking git repository..."
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    log_error "Not a git repository"
    echo "Initialize with: git init"
    exit 2
fi
log_info "Git repository detected"

# Get repository info
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login' 2>/dev/null || echo "")
REPO_NAME=$(gh repo view --json name --jq '.name' 2>/dev/null || echo "")

if [[ -z "$REPO_OWNER" ]] || [[ -z "$REPO_NAME" ]]; then
    log_warn "Could not detect GitHub repository"
    log_step "Attempting to create GitHub repository..."

    # Get current directory name as repo name
    CURRENT_DIR=$(basename "$(pwd)")

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create repository: $CURRENT_DIR"
    else
        if gh repo create "$CURRENT_DIR" --source=. --private --confirm 2>/dev/null; then
            log_info "GitHub repository created: $CURRENT_DIR"
            REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
            REPO_NAME=$(gh repo view --json name --jq '.name')
        else
            log_error "Failed to create GitHub repository"
            exit 2
        fi
    fi
else
    log_info "GitHub repository: $REPO_OWNER/$REPO_NAME"
fi

# ============================================================
# Phase 2: Platform Detection (if auto)
# ============================================================
if [[ "$PLATFORM" == "auto" ]]; then
    log_section "Phase 2: Platform Detection"

    log_step "Detecting platform from project structure..."

    # Check for Vercel
    if [[ -f "vercel.json" ]] || [[ -d ".vercel" ]] || [[ -f "next.config.js" ]] || [[ -f "next.config.mjs" ]]; then
        PLATFORM="vercel"
        log_info "Detected platform: Vercel (Next.js/React/Frontend)"

    # Check for DigitalOcean App Platform
    elif [[ -f "app-spec.yml" ]] || [[ -f ".do/app.yaml" ]]; then
        PLATFORM="digitalocean-app"
        log_info "Detected platform: DigitalOcean App Platform"

    # Check for Railway
    elif [[ -f "railway.json" ]] || [[ -f "railway.toml" ]]; then
        PLATFORM="railway"
        log_info "Detected platform: Railway"

    # Check for Netlify
    elif [[ -f "netlify.toml" ]]; then
        PLATFORM="netlify"
        log_info "Detected platform: Netlify"

    # Default to Vercel for Node.js projects
    elif [[ -f "package.json" ]]; then
        PLATFORM="vercel"
        log_warn "Could not determine platform, defaulting to Vercel"

    else
        log_error "Could not auto-detect platform"
        echo "Specify platform explicitly: vercel | digitalocean-app | railway"
        exit 1
    fi
else
    log_section "Phase 2: Platform Configuration"
    log_info "Using specified platform: $PLATFORM"
fi

# ============================================================
# Phase 3: Platform CLI Check
# ============================================================
log_section "Phase 3: Platform CLI Verification"

case "$PLATFORM" in
    vercel)
        log_step "Checking Vercel CLI..."
        if ! command -v vercel &> /dev/null; then
            log_error "Vercel CLI not installed"
            echo "Install with: npm install -g vercel"
            exit 2
        fi
        log_info "Vercel CLI installed: $(vercel --version)"

        # Check authentication
        if [[ -z "$VERCEL_TOKEN" ]]; then
            log_warn "VERCEL_TOKEN not set, checking CLI authentication..."
            if ! vercel whoami &> /dev/null; then
                log_error "Vercel CLI not authenticated and VERCEL_TOKEN not set"
                echo "Either:"
                echo "  1. Run: vercel login"
                echo "  2. Set: export VERCEL_TOKEN='your_token'"
                exit 2
            fi
            log_info "Vercel CLI authenticated"
        else
            log_info "VERCEL_TOKEN is set"
        fi
        ;;

    digitalocean-app|digitalocean-droplet)
        log_step "Checking doctl CLI..."
        if ! command -v doctl &> /dev/null; then
            log_error "doctl CLI not installed"
            echo "Install: https://docs.digitalocean.com/reference/doctl/how-to/install/"
            exit 2
        fi
        log_info "doctl installed: $(doctl version)"

        if [[ -z "$DIGITALOCEAN_ACCESS_TOKEN" ]]; then
            log_error "DIGITALOCEAN_ACCESS_TOKEN not set"
            echo "Set with: export DIGITALOCEAN_ACCESS_TOKEN='your_token'"
            exit 2
        fi
        log_info "DIGITALOCEAN_ACCESS_TOKEN is set"
        ;;

    railway)
        log_step "Checking Railway CLI..."
        if ! command -v railway &> /dev/null; then
            log_error "Railway CLI not installed"
            echo "Install: npm install -g @railway/cli"
            exit 2
        fi
        log_info "Railway CLI installed"

        if [[ -z "$RAILWAY_TOKEN" ]]; then
            log_warn "RAILWAY_TOKEN not set, checking CLI authentication..."
            if ! railway whoami &> /dev/null; then
                log_error "Railway CLI not authenticated and RAILWAY_TOKEN not set"
                echo "Either:"
                echo "  1. Run: railway login"
                echo "  2. Set: export RAILWAY_TOKEN='your_token'"
                exit 2
            fi
            log_info "Railway CLI authenticated"
        else
            log_info "RAILWAY_TOKEN is set"
        fi
        ;;

    netlify)
        log_step "Checking Netlify CLI..."
        if ! command -v netlify &> /dev/null; then
            log_error "Netlify CLI not installed"
            echo "Install: npm install -g netlify-cli"
            exit 2
        fi
        log_info "Netlify CLI installed"
        ;;

    *)
        log_error "Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

# ============================================================
# Phase 4: Extract Platform IDs
# ============================================================
log_section "Phase 4: Extract Platform IDs"

log_step "Running platform ID extraction..."
if [[ -f "$SCRIPT_DIR/extract-platform-ids.sh" ]]; then
    IDS_JSON=$(bash "$SCRIPT_DIR/extract-platform-ids.sh" "$PLATFORM" ".")

    if [[ $? -eq 0 ]]; then
        log_info "Platform IDs extracted successfully"
        echo "$IDS_JSON" | jq '.' 2>/dev/null || echo "$IDS_JSON"
    else
        log_error "Failed to extract platform IDs"
        echo "$IDS_JSON"
        exit 1
    fi
else
    log_warn "extract-platform-ids.sh not found, will configure manually"
fi

# ============================================================
# Phase 5: Configure GitHub Secrets
# ============================================================
log_section "Phase 5: Configure GitHub Secrets"

log_step "Configuring repository secrets via GitHub CLI..."

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would configure secrets for: $REPO_OWNER/$REPO_NAME"
else
    if [[ -f "$SCRIPT_DIR/configure-github-secrets.sh" ]]; then
        if bash "$SCRIPT_DIR/configure-github-secrets.sh" "$PLATFORM" "."; then
            log_info "GitHub secrets configured successfully"
        else
            log_error "Failed to configure GitHub secrets"
            exit 1
        fi
    else
        log_warn "configure-github-secrets.sh not found, configuring manually..."

        case "$PLATFORM" in
            vercel)
                if [[ -n "$VERCEL_TOKEN" ]]; then
                    echo "$VERCEL_TOKEN" | gh secret set VERCEL_TOKEN
                    log_info "Set VERCEL_TOKEN"
                fi

                if [[ -n "$IDS_JSON" ]]; then
                    ORG_ID=$(echo "$IDS_JSON" | jq -r '.orgId // empty')
                    PROJECT_ID=$(echo "$IDS_JSON" | jq -r '.projectId // empty')

                    if [[ -n "$ORG_ID" ]]; then
                        echo "$ORG_ID" | gh secret set VERCEL_ORG_ID
                        log_info "Set VERCEL_ORG_ID"
                    fi

                    if [[ -n "$PROJECT_ID" ]]; then
                        echo "$PROJECT_ID" | gh secret set VERCEL_PROJECT_ID
                        log_info "Set VERCEL_PROJECT_ID"
                    fi
                fi
                ;;

            digitalocean-app|digitalocean-droplet)
                if [[ -n "$DIGITALOCEAN_ACCESS_TOKEN" ]]; then
                    echo "$DIGITALOCEAN_ACCESS_TOKEN" | gh secret set DIGITALOCEAN_ACCESS_TOKEN
                    log_info "Set DIGITALOCEAN_ACCESS_TOKEN"
                fi
                ;;

            railway)
                if [[ -n "$RAILWAY_TOKEN" ]]; then
                    echo "$RAILWAY_TOKEN" | gh secret set RAILWAY_TOKEN
                    log_info "Set RAILWAY_TOKEN"
                fi
                ;;
        esac
    fi
fi

# ============================================================
# Phase 6: Generate GitHub Actions Workflow
# ============================================================
log_section "Phase 6: Generate GitHub Actions Workflow"

mkdir -p .github/workflows

WORKFLOW_FILE=".github/workflows/deploy.yml"

log_step "Generating workflow file: $WORKFLOW_FILE"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would generate workflow for platform: $PLATFORM"
else
    if [[ -f "$SCRIPT_DIR/generate-workflow.sh" ]]; then
        if bash "$SCRIPT_DIR/generate-workflow.sh" "$PLATFORM" "$WORKFLOW_FILE"; then
            log_info "Workflow generated successfully"
        else
            log_error "Failed to generate workflow"
            exit 1
        fi
    else
        log_warn "generate-workflow.sh not found, using template directly..."

        TEMPLATE_FILE="$SCRIPT_DIR/../templates/${PLATFORM}-workflow.yml"
        if [[ -f "$TEMPLATE_FILE" ]]; then
            cp "$TEMPLATE_FILE" "$WORKFLOW_FILE"
            log_info "Copied template: $TEMPLATE_FILE"
        else
            log_error "Template not found: $TEMPLATE_FILE"
            exit 1
        fi
    fi
fi

# ============================================================
# Phase 7: Validate Setup
# ============================================================
log_section "Phase 7: Validate CI/CD Setup"

log_step "Validating workflow file syntax..."
if command -v yamllint &> /dev/null; then
    if yamllint "$WORKFLOW_FILE" &> /dev/null; then
        log_info "Workflow YAML is valid"
    else
        log_warn "Workflow YAML has warnings (non-fatal)"
    fi
else
    log_warn "yamllint not installed, skipping YAML validation"
fi

log_step "Listing configured secrets..."
if [[ "$DRY_RUN" != "true" ]]; then
    gh secret list || log_warn "Could not list secrets"
fi

# ============================================================
# Phase 8: Commit and Push (Optional)
# ============================================================
log_section "Phase 8: Commit Workflow"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would commit workflow file"
else
    if git diff --quiet "$WORKFLOW_FILE"; then
        log_info "Workflow file already committed"
    else
        log_step "Committing workflow file..."
        git add "$WORKFLOW_FILE"
        git commit -m "ci: Add automated deployment workflow for $PLATFORM

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
        log_info "Workflow committed"

        log_step "Pushing to remote..."
        if git push origin "$(git branch --show-current)"; then
            log_info "Workflow pushed to GitHub"
        else
            log_warn "Failed to push (you may need to push manually)"
        fi
    fi
fi

# ============================================================
# Phase 9: Success Summary
# ============================================================
log_section "CI/CD Setup Complete! 🎉"

echo "Platform: $PLATFORM"
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo "Workflow: $WORKFLOW_FILE"
echo ""

log_info "GitHub Secrets Configured:"
case "$PLATFORM" in
    vercel)
        echo "  - VERCEL_TOKEN"
        echo "  - VERCEL_ORG_ID"
        echo "  - VERCEL_PROJECT_ID"
        ;;
    digitalocean-app|digitalocean-droplet)
        echo "  - DIGITALOCEAN_ACCESS_TOKEN"
        ;;
    railway)
        echo "  - RAILWAY_TOKEN"
        ;;
esac

echo ""
log_info "Next Steps:"
echo "  1. Push code to trigger deployment:"
echo "     git push origin main"
echo ""
echo "  2. Monitor deployment:"
echo "     gh run watch"
echo ""
echo "  3. View deployment logs:"
echo "     gh run view"
echo ""
echo "  4. Create pull request for preview deployment:"
echo "     gh pr create --fill"
echo ""

log_info "Deployment will now happen automatically on every push!"

exit 0

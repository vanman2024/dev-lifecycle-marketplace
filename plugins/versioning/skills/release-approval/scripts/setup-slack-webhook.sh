#!/bin/bash
# Setup Slack webhook integration for approval notifications
# Usage: bash setup-slack-webhook.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Display welcome message
display_welcome() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "       Slack Webhook Setup for Release Approvals"
    echo "═══════════════════════════════════════════════════════"
    echo ""
}

# Check if running in GitHub Actions
check_environment() {
    if [ -n "${GITHUB_ACTIONS:-}" ]; then
        log_info "Running in GitHub Actions environment"
        return 0
    else
        log_info "Running in local environment"
        return 1
    fi
}

# Display instructions for getting Slack webhook
display_webhook_instructions() {
    echo ""
    log_step "Step 1: Create Slack Incoming Webhook"
    echo ""
    echo "  1. Go to: https://api.slack.com/apps"
    echo "  2. Click 'Create New App' > 'From scratch'"
    echo "  3. Name your app (e.g., 'Release Approvals')"
    echo "  4. Select your Slack workspace"
    echo "  5. Navigate to 'Incoming Webhooks'"
    echo "  6. Toggle 'Activate Incoming Webhooks' to ON"
    echo "  7. Click 'Add New Webhook to Workspace'"
    echo "  8. Select the channel for notifications"
    echo "  9. Copy the Webhook URL"
    echo ""
    echo "  Your webhook URL will look like:"
    echo "  https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX"
    echo ""
}

# Prompt for webhook URL
prompt_for_webhook() {
    local webhook_url=""

    echo ""
    log_step "Step 2: Enter Slack Webhook URL"
    echo ""
    read -p "Paste your Slack webhook URL: " webhook_url

    # Validate webhook URL
    if [ -z "$webhook_url" ]; then
        log_error "Webhook URL cannot be empty"
        return 1
    fi

    if [[ ! "$webhook_url" =~ ^https://hooks\.slack\.com/services/.+ ]]; then
        log_warn "This doesn't look like a valid Slack webhook URL"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi

    echo "$webhook_url"
}

# Test webhook connection
test_webhook() {
    local webhook_url="$1"

    log_info "Testing webhook connection..."

    local test_payload='{
  "text": "🔔 Test Notification",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "✅ *Slack webhook configured successfully!*\n\nYour release approval notifications will be sent to this channel."
      }
    }
  ]
}'

    local response=$(curl -s -w "\n%{http_code}" -X POST "$webhook_url" \
        -H 'Content-Type: application/json' \
        -d "$test_payload" 2>&1)

    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n-1)

    if [ "$http_code" = "200" ] && [ "$body" = "ok" ]; then
        log_info "✅ Webhook test successful! Check your Slack channel."
        return 0
    else
        log_error "❌ Webhook test failed"
        log_error "HTTP Code: $http_code"
        log_error "Response: $body"
        return 1
    fi
}

# Save webhook to local environment
save_to_local_env() {
    local webhook_url="$1"
    local env_file=".env"
    local env_example=".env.example"

    log_step "Step 3: Save webhook configuration"
    echo ""

    # Create or update .env file
    if [ -f "$env_file" ]; then
        # Check if SLACK_WEBHOOK_URL already exists
        if grep -q "^SLACK_WEBHOOK_URL=" "$env_file"; then
            # Update existing entry
            sed -i.bak "s|^SLACK_WEBHOOK_URL=.*|SLACK_WEBHOOK_URL=$webhook_url|" "$env_file"
            rm -f "$env_file.bak"
            log_info "Updated SLACK_WEBHOOK_URL in $env_file"
        else
            # Append new entry
            echo "SLACK_WEBHOOK_URL=$webhook_url" >> "$env_file"
            log_info "Added SLACK_WEBHOOK_URL to $env_file"
        fi
    else
        # Create new .env file
        echo "SLACK_WEBHOOK_URL=$webhook_url" > "$env_file"
        log_info "Created $env_file with SLACK_WEBHOOK_URL"
    fi

    # Create or update .env.example with placeholder
    if grep -q "^SLACK_WEBHOOK_URL=" "$env_example" 2>/dev/null; then
        sed -i.bak "s|^SLACK_WEBHOOK_URL=.*|SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/HERE|" "$env_example"
        rm -f "$env_example.bak"
    else
        echo "SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/HERE" >> "$env_example"
    fi
    log_info "Updated $env_example with placeholder"

    # Ensure .env is in .gitignore
    if [ -f ".gitignore" ]; then
        if ! grep -q "^\.env$" .gitignore; then
            echo ".env" >> .gitignore
            log_info "Added .env to .gitignore"
        fi
    fi
}

# Save webhook to GitHub Secrets
save_to_github_secrets() {
    local webhook_url="$1"

    log_step "Step 4: Save to GitHub Secrets"
    echo ""

    # Check if GitHub CLI is available
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI (gh) not found"
        log_info "Install from: https://cli.github.com/"
        log_info ""
        log_info "To save webhook to GitHub Secrets manually:"
        echo "  1. Go to your repository on GitHub"
        echo "  2. Navigate to Settings > Secrets and variables > Actions"
        echo "  3. Click 'New repository secret'"
        echo "  4. Name: SLACK_WEBHOOK_URL"
        echo "  5. Value: [paste your webhook URL]"
        echo "  6. Click 'Add secret'"
        return 1
    fi

    # Check if authenticated
    if ! gh auth status &> /dev/null 2>&1; then
        log_warn "GitHub CLI not authenticated"
        log_info "Run: gh auth login"
        return 1
    fi

    # Save secret
    log_info "Saving SLACK_WEBHOOK_URL to GitHub Secrets..."
    if echo "$webhook_url" | gh secret set SLACK_WEBHOOK_URL 2>&1; then
        log_info "✅ Secret saved successfully"
        return 0
    else
        log_error "Failed to save secret to GitHub"
        return 1
    fi
}

# Display next steps
display_next_steps() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "                    Setup Complete!"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    log_info "Your Slack webhook is configured and ready to use."
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Test notification:"
    echo "     bash scripts/notify-slack.sh approval-requested 1.2.3 \"Test message\""
    echo ""
    echo "  2. Request approval with Slack notification:"
    echo "     bash scripts/request-approval.sh 1.2.3 development slack"
    echo ""
    echo "  3. Use in approval workflow:"
    echo "     /versioning:approve-release 1.2.3"
    echo ""
    echo "Documentation:"
    echo "  • Skill: plugins/versioning/skills/release-approval/SKILL.md"
    echo "  • Examples: plugins/versioning/skills/release-approval/examples/"
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo ""
}

# Main execution
main() {
    display_welcome

    # Step 1: Show instructions
    display_webhook_instructions

    # Step 2: Get webhook URL
    local webhook_url
    webhook_url=$(prompt_for_webhook)
    if [ $? -ne 0 ] || [ -z "$webhook_url" ]; then
        log_error "Setup cancelled"
        exit 1
    fi

    # Step 2.5: Test webhook
    if ! test_webhook "$webhook_url"; then
        log_error "Webhook test failed. Please verify the URL and try again."
        exit 1
    fi

    # Step 3: Save to local environment
    save_to_local_env "$webhook_url"

    # Step 4: Save to GitHub Secrets (optional)
    if check_environment; then
        log_info "GitHub Actions detected - secret should be configured in repository settings"
    else
        echo ""
        read -p "Save webhook to GitHub Secrets? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            save_to_github_secrets "$webhook_url" || true
        fi
    fi

    # Display next steps
    display_next_steps
}

main

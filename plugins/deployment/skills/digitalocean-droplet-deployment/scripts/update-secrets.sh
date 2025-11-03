#!/usr/bin/env bash
#
# Update Secrets on DigitalOcean Droplet
# Updates environment variables without redeploying code
#
# This script can be run from anywhere
#
# Usage: update-secrets.sh <droplet-ip> <app-name>
#
# Environment Variables:
#   ENV_FILE - Path to .env file (optional, will prompt if not provided)
#   APP_DIR  - Application directory (default: /opt/<app-name>)
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Parse arguments
if [ $# -lt 2 ]; then
  echo "Usage: $0 <droplet-ip> <app-name>"
  echo ""
  echo "Example: $0 137.184.196.101 myapp"
  echo ""
  echo "You can provide environment variables via:"
  echo "  1. ENV_FILE environment variable pointing to a file"
  echo "  2. Interactive prompt (default)"
  exit 1
fi

DROPLET_IP="$1"
APP_NAME="$2"
APP_DIR="${APP_DIR:-/opt/${APP_NAME}}"
ENV_FILE="${ENV_FILE:-}"

log_info "🔒 Updating secrets for ${APP_NAME} on ${DROPLET_IP}"

# Step 1: Check doctl authentication
log_info "🔐 Checking doctl authentication..."

if ! command -v doctl &> /dev/null; then
  log_error "doctl is not installed"
  exit 1
fi

if ! doctl auth list &> /dev/null; then
  log_error "doctl is not authenticated. Run: doctl auth init"
  exit 1
fi

log_success "doctl authenticated"

# Step 2: Test droplet connectivity
log_info "🌐 Testing droplet connectivity..."

if ! doctl compute ssh "$DROPLET_IP" --ssh-command "echo 'Connection successful'" &> /dev/null; then
  log_error "Cannot connect to droplet at $DROPLET_IP"
  exit 1
fi

log_success "Droplet accessible"

# Step 3: Check if app exists
log_info "📁 Checking if application exists..."

if ! doctl compute ssh "$DROPLET_IP" --ssh-command "[ -d $APP_DIR ]"; then
  log_error "Application directory not found: $APP_DIR"
  log_info "Has the app been deployed yet?"
  exit 1
fi

log_success "Application found"

# Step 4: Get environment variables
log_info "📝 Preparing environment variables..."

# Resolve ENV_FILE to absolute path if it's relative
if [ -n "$ENV_FILE" ]; then
  if [ -f "$ENV_FILE" ]; then
    ENV_FILE="$(cd "$(dirname "$ENV_FILE")" && pwd)/$(basename "$ENV_FILE")"
    log_info "Using environment file: $ENV_FILE"
    ENV_CONTENT=$(cat "$ENV_FILE")
  else
    log_error "ENV_FILE specified but not found: $ENV_FILE"
    exit 1
  fi
else
  log_warning "No ENV_FILE specified"
  log_info "Please enter environment variables (one per line, KEY=VALUE format)"
  log_info "Press Ctrl+D when done"
  echo ""

  ENV_CONTENT=""
  while IFS= read -r line; do
    ENV_CONTENT="${ENV_CONTENT}${line}"$'\n'
  done
fi

if [ -z "$ENV_CONTENT" ]; then
  log_error "No environment variables provided"
  exit 1
fi

log_success "Environment variables prepared"

# Step 5: Backup current .env file
log_info "💾 Backing up current .env file..."

BACKUP_FILE=".env.backup.$(date +%Y%m%d_%H%M%S)"
doctl compute ssh "$DROPLET_IP" --ssh-command "
  if [ -f $APP_DIR/.env ]; then
    cp $APP_DIR/.env $APP_DIR/$BACKUP_FILE
  fi
"

log_success "Backup created: $BACKUP_FILE"

# Step 6: Update .env file
log_info "🔄 Updating .env file..."

doctl compute ssh "$DROPLET_IP" --ssh-command "cat > $APP_DIR/.env" <<< "$ENV_CONTENT"
doctl compute ssh "$DROPLET_IP" --ssh-command "chmod 600 $APP_DIR/.env"

log_success "Environment file updated"

# Step 7: Restart service
log_info "🔄 Restarting service..."

doctl compute ssh "$DROPLET_IP" --ssh-command "systemctl restart ${APP_NAME}"

# Wait for service to restart
sleep 3

# Step 8: Verify service is running
log_info "🔍 Verifying service..."

SERVICE_STATUS=$(doctl compute ssh "$DROPLET_IP" --ssh-command "systemctl is-active ${APP_NAME}" || echo "failed")

if [ "$SERVICE_STATUS" = "active" ]; then
  log_success "Service restarted successfully!"

  # Show recent logs
  log_info "📜 Recent logs:"
  doctl compute ssh "$DROPLET_IP" --ssh-command "journalctl -u ${APP_NAME} -n 10 --no-pager" || true

  echo ""
  log_success "✨ Secrets updated successfully!"
  echo ""
  log_info "Backup location: $APP_DIR/$BACKUP_FILE"
  log_info "To rollback: doctl compute ssh $DROPLET_IP --ssh-command 'cp $APP_DIR/$BACKUP_FILE $APP_DIR/.env && systemctl restart ${APP_NAME}'"
  echo ""
else
  log_error "Service failed to start after updating secrets!"
  log_warning "Rolling back to previous .env..."

  doctl compute ssh "$DROPLET_IP" --ssh-command "
    cp $APP_DIR/$BACKUP_FILE $APP_DIR/.env &&
    systemctl restart ${APP_NAME}
  "

  sleep 2
  ROLLBACK_STATUS=$(doctl compute ssh "$DROPLET_IP" --ssh-command "systemctl is-active ${APP_NAME}" || echo "failed")

  if [ "$ROLLBACK_STATUS" = "active" ]; then
    log_success "Rollback successful - service is running with old secrets"
  else
    log_error "Rollback failed - service is not running!"
  fi

  log_info "Checking logs for errors..."
  doctl compute ssh "$DROPLET_IP" --ssh-command "journalctl -u ${APP_NAME} -n 20 --no-pager"

  exit 1
fi

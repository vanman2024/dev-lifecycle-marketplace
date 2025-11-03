#!/usr/bin/env bash
#
# Generic DigitalOcean Droplet Deployment Script
# Deploys any Python or Node.js application to a droplet using doctl
#
# This script can be run from anywhere and works with relative or absolute paths
#
# Usage: deploy-to-droplet.sh <app-path> <droplet-ip> <app-name>
#
# Environment Variables:
#   APP_TYPE       - python|nodejs (auto-detected if not set)
#   PORT           - Port to run on (default: 8000)
#   PYTHON_VERSION - Python version (default: 3.11)
#   NODE_VERSION   - Node.js version (default: 20)
#   SERVICE_USER   - User to run service as (default: root)
#   APP_DIR        - Target directory (default: /opt/<app-name>)
#   ENV_FILE       - Path to .env file (optional)
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
if [ $# -lt 3 ]; then
  echo "Usage: $0 <app-path> <droplet-ip> <app-name>"
  echo ""
  echo "Example: $0 /path/to/app 137.184.196.101 myapp"
  exit 1
fi

# Convert to absolute path if relative
APP_PATH="$(cd "$1" && pwd)"
DROPLET_IP="$2"
APP_NAME="$3"

# Configuration with defaults
APP_TYPE="${APP_TYPE:-auto}"
PORT="${PORT:-8000}"
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"
NODE_VERSION="${NODE_VERSION:-20}"
SERVICE_USER="${SERVICE_USER:-root}"
APP_DIR="${APP_DIR:-/opt/${APP_NAME}}"
ENV_FILE="${ENV_FILE:-}"

log_info "🚀 Starting deployment of ${APP_NAME} to ${DROPLET_IP}"

# Step 1: Validate local application
log_info "📋 Validating application..."

if [ ! -d "$APP_PATH" ]; then
  log_error "Application path does not exist: $APP_PATH"
  exit 1
fi

cd "$APP_PATH"

# Auto-detect app type if not specified
if [ "$APP_TYPE" = "auto" ]; then
  if [ -f "requirements.txt" ] || [ -f "server.py" ] || [ -f "app.py" ]; then
    APP_TYPE="python"
    log_info "Detected Python application"
  elif [ -f "package.json" ]; then
    APP_TYPE="nodejs"
    log_info "Detected Node.js application"
  else
    log_error "Could not auto-detect application type. Set APP_TYPE=python or APP_TYPE=nodejs"
    exit 1
  fi
fi

# Detect entry point
if [ "$APP_TYPE" = "python" ]; then
  if [ -f "server.py" ]; then
    ENTRY_POINT="server.py"
  elif [ -f "app.py" ]; then
    ENTRY_POINT="app.py"
  elif [ -f "main.py" ]; then
    ENTRY_POINT="main.py"
  else
    log_error "Could not find Python entry point (server.py, app.py, or main.py)"
    exit 1
  fi

  if [ ! -f "requirements.txt" ]; then
    log_warning "No requirements.txt found - dependencies won't be installed"
  fi
elif [ "$APP_TYPE" = "nodejs" ]; then
  if [ -f "server.js" ]; then
    ENTRY_POINT="server.js"
  elif [ -f "index.js" ]; then
    ENTRY_POINT="index.js"
  elif [ -f "app.js" ]; then
    ENTRY_POINT="app.js"
  else
    log_error "Could not find Node.js entry point (server.js, index.js, or app.js)"
    exit 1
  fi

  if [ ! -f "package.json" ]; then
    log_error "No package.json found"
    exit 1
  fi
fi

log_success "Application validated: $APP_TYPE app with entry point $ENTRY_POINT"

# Step 2: Check doctl authentication
log_info "🔐 Checking doctl authentication..."

if ! command -v doctl &> /dev/null; then
  log_error "doctl is not installed. Install from: https://docs.digitalocean.com/reference/doctl/how-to/install/"
  exit 1
fi

if ! doctl auth list &> /dev/null; then
  log_error "doctl is not authenticated. Run: doctl auth init"
  exit 1
fi

log_success "doctl authenticated"

# Step 3: Test droplet connectivity
log_info "🌐 Testing droplet connectivity..."

if ! doctl compute ssh "$DROPLET_IP" --ssh-command "echo 'Connection successful'" &> /dev/null; then
  log_error "Cannot connect to droplet at $DROPLET_IP"
  log_info "Make sure your SSH key is added to the droplet"
  exit 1
fi

log_success "Droplet accessible"

# Step 4: Prepare environment variables
log_info "📝 Preparing environment variables..."

if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
  log_info "Using environment file: $ENV_FILE"
  ENV_CONTENT=$(cat "$ENV_FILE")
elif [ -f ".env" ]; then
  log_info "Using .env file from application directory"
  ENV_CONTENT=$(cat ".env")
elif [ -f ".env.example" ]; then
  log_warning "Found .env.example but no .env file"
  log_warning "You'll need to provide environment variables manually"
  ENV_CONTENT="# Add your environment variables here"
else
  log_warning "No .env or .env.example found - creating minimal config"
  ENV_CONTENT="PORT=$PORT"
fi

# Add PORT if not present
if ! echo "$ENV_CONTENT" | grep -q "^PORT="; then
  ENV_CONTENT="${ENV_CONTENT}"$'\n'"PORT=$PORT"
fi

log_success "Environment prepared"

# Step 5: Create application directory on droplet
log_info "📁 Creating application directory on droplet..."

doctl compute ssh "$DROPLET_IP" --ssh-command "mkdir -p $APP_DIR"
log_success "Directory created: $APP_DIR"

# Step 6: Transfer application code
log_info "📦 Transferring application code..."

# Create temp script for rsync via doctl
RSYNC_SCRIPT=$(mktemp)
cat > "$RSYNC_SCRIPT" << 'EOFRSYNC'
#!/bin/bash
rsync -avz --delete \
  --exclude='.git' \
  --exclude='__pycache__' \
  --exclude='node_modules' \
  --exclude='.env' \
  --exclude='*.pyc' \
  --exclude='.pytest_cache' \
  --exclude='venv' \
  -e "ssh $(doctl compute ssh $1 --ssh-command "echo" 2>&1 | grep -o '\-i [^ ]*')" \
  "$2/" "root@$1:$3/"
EOFRSYNC

chmod +x "$RSYNC_SCRIPT"
"$RSYNC_SCRIPT" "$DROPLET_IP" "$APP_PATH" "$APP_DIR"
rm "$RSYNC_SCRIPT"

log_success "Code transferred"

# Step 7: Create environment file on droplet
log_info "🔒 Creating secure environment file..."

doctl compute ssh "$DROPLET_IP" --ssh-command "cat > $APP_DIR/.env" <<< "$ENV_CONTENT"
doctl compute ssh "$DROPLET_IP" --ssh-command "chmod 600 $APP_DIR/.env"

log_success "Environment file created with secure permissions"

# Step 8: Install dependencies
log_info "📥 Installing dependencies..."

if [ "$APP_TYPE" = "python" ]; then
  doctl compute ssh "$DROPLET_IP" --ssh-command "
    cd $APP_DIR &&
    apt-get update -qq &&
    apt-get install -y -qq python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python3-pip &&
    python${PYTHON_VERSION} -m venv venv &&
    source venv/bin/activate &&
    pip install --upgrade pip &&
    pip install -r requirements.txt
  "
elif [ "$APP_TYPE" = "nodejs" ]; then
  doctl compute ssh "$DROPLET_IP" --ssh-command "
    cd $APP_DIR &&
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - &&
    apt-get install -y nodejs &&
    npm install --production
  "
fi

log_success "Dependencies installed"

# Step 9: Create systemd service
log_info "⚙️ Creating systemd service..."

if [ "$APP_TYPE" = "python" ]; then
  EXEC_START="$APP_DIR/venv/bin/python $APP_DIR/$ENTRY_POINT"
elif [ "$APP_TYPE" = "nodejs" ]; then
  EXEC_START="/usr/bin/node $APP_DIR/$ENTRY_POINT"
fi

SERVICE_FILE="/etc/systemd/system/${APP_NAME}.service"

doctl compute ssh "$DROPLET_IP" --ssh-command "cat > $SERVICE_FILE" << EOFSERVICE
[Unit]
Description=${APP_NAME} Application
After=network.target

[Service]
Type=simple
User=${SERVICE_USER}
WorkingDirectory=${APP_DIR}
Environment="PATH=/usr/local/bin:/usr/bin:/bin"
EnvironmentFile=${APP_DIR}/.env
ExecStart=${EXEC_START}
Restart=always
RestartSec=10
StandardOutput=append:/var/log/${APP_NAME}.log
StandardError=append:/var/log/${APP_NAME}-error.log

[Install]
WantedBy=multi-user.target
EOFSERVICE

log_success "Systemd service created"

# Step 10: Start and enable service
log_info "🎬 Starting service..."

doctl compute ssh "$DROPLET_IP" --ssh-command "
  systemctl daemon-reload &&
  systemctl enable ${APP_NAME} &&
  systemctl restart ${APP_NAME}
"

# Wait a moment for service to start
sleep 3

# Step 11: Verify service is running
log_info "🔍 Verifying deployment..."

SERVICE_STATUS=$(doctl compute ssh "$DROPLET_IP" --ssh-command "systemctl is-active ${APP_NAME}" || echo "failed")

if [ "$SERVICE_STATUS" = "active" ]; then
  log_success "Service is running!"

  # Show recent logs
  log_info "📜 Recent logs:"
  doctl compute ssh "$DROPLET_IP" --ssh-command "journalctl -u ${APP_NAME} -n 10 --no-pager" || true

  echo ""
  log_success "✨ Deployment successful!"
  echo ""
  log_info "Service Details:"
  echo "  Name:     $APP_NAME"
  echo "  Type:     $APP_TYPE"
  echo "  Droplet:  $DROPLET_IP"
  echo "  Port:     $PORT"
  echo "  Directory: $APP_DIR"
  echo ""
  log_info "Useful commands:"
  echo "  View logs:    doctl compute ssh $DROPLET_IP --ssh-command 'journalctl -u ${APP_NAME} -f'"
  echo "  Service status: doctl compute ssh $DROPLET_IP --ssh-command 'systemctl status ${APP_NAME}'"
  echo "  Restart:      doctl compute ssh $DROPLET_IP --ssh-command 'systemctl restart ${APP_NAME}'"
  echo ""
else
  log_error "Service failed to start!"
  log_info "Checking logs..."
  doctl compute ssh "$DROPLET_IP" --ssh-command "journalctl -u ${APP_NAME} -n 20 --no-pager"
  exit 1
fi

#!/bin/bash
# Setup Self-Hosted Sentry with Docker
# Free, unlimited error tracking on your own infrastructure

set -e

echo "🔧 Setting up Self-Hosted Sentry"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "❌ Docker not found"
  echo "Install Docker: https://docs.docker.com/get-docker/"
  exit 1
fi

if ! command -v docker-compose &> /dev/null; then
  echo "❌ docker-compose not found"
  echo "Install: https://docs.docker.com/compose/install/"
  exit 1
fi

echo "✅ Docker and docker-compose found"
echo ""

# Clone Sentry self-hosted repo
if [ ! -d "sentry-self-hosted" ]; then
  echo "📦 Cloning Sentry self-hosted repository..."
  git clone https://github.com/getsentry/self-hosted.git sentry-self-hosted
  cd sentry-self-hosted
else
  echo "📁 Sentry directory exists, updating..."
  cd sentry-self-hosted
  git pull
fi

echo "✅ Sentry repository ready"
echo ""

# Run installation script
echo "🚀 Running Sentry installation..."
echo "This will:"
echo "  - Download Docker images (~20GB)"
echo "  - Setup PostgreSQL, Redis, ClickHouse"
echo "  - Create admin user"
echo "  - Start Sentry on http://localhost:9000"
echo ""

./install.sh

echo ""
echo "✅ Sentry installation complete!"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Start Sentry:"
echo "   cd sentry-self-hosted && docker-compose up -d"
echo ""
echo "2. Access Sentry:"
echo "   http://localhost:9000"
echo ""
echo "3. Create organization and project"
echo ""
echo "4. Get DSN from project settings"
echo ""
echo "5. Add to Doppler:"
echo "   doppler secrets set SENTRY_DSN='http://public@localhost:9000/1' --config dev"
echo "   doppler secrets set SENTRY_URL='http://localhost:9000' --config dev"
echo ""
echo "6. Configure Sentry CLI for self-hosted:"
echo "   Create .sentryclirc:"
echo "   [auth]"
echo "   token=\${SENTRY_AUTH_TOKEN}"
echo ""
echo "   [defaults]"
echo "   url=http://localhost:9000"
echo "   org=your-org-slug"
echo "   project=your-project-slug"
echo ""
echo "💡 Self-Hosted Benefits:"
echo "  - ✓ 100% Free, unlimited events"
echo "  - ✓ Full control over data"
echo "  - ✓ No quotas or seat limits"
echo "  - ✓ Works with same CLI and SDK"
echo ""
echo "📊 Resource Requirements:"
echo "  - RAM: 4GB minimum (8GB recommended)"
echo "  - Disk: 20GB minimum for images"
echo "  - CPU: 2 cores minimum"
echo ""
echo "🔧 Management:"
echo "  - Stop: docker-compose down"
echo "  - Start: docker-compose up -d"
echo "  - Logs: docker-compose logs -f"
echo "  - Upgrade: ./install.sh (re-run periodically)"

#!/bin/bash
# Sentry CLI Release Tracking Script
# Creates Sentry release, uploads source maps, tracks deployment

set -e

VERSION="${1:-}"
ENVIRONMENT="${2:-production}"
DIST_DIR="${3:-./dist}"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version> [environment] [dist-dir]"
  echo "Example: $0 1.2.3 production ./dist"
  exit 1
fi

echo "🔍 Sentry Release Tracking for v$VERSION"
echo "Environment: $ENVIRONMENT"
echo "Dist Directory: $DIST_DIR"
echo ""

# Check if sentry-cli is installed
if ! command -v sentry-cli &> /dev/null; then
  echo "❌ sentry-cli not found"
  echo "Install: npm install -g @sentry/cli"
  exit 1
fi

# Check required environment variables
if [ -z "$SENTRY_AUTH_TOKEN" ]; then
  echo "❌ SENTRY_AUTH_TOKEN not set"
  echo "Set via Doppler: doppler secrets set SENTRY_AUTH_TOKEN=<token>"
  exit 1
fi

if [ -z "$SENTRY_ORG_SLUG" ]; then
  echo "❌ SENTRY_ORG_SLUG not set"
  exit 1
fi

if [ -z "$SENTRY_PROJECT_SLUG" ]; then
  echo "❌ SENTRY_PROJECT_SLUG not set"
  exit 1
fi

echo "✅ Environment variables validated"
echo ""

# Step 1: Create release
echo "📦 Creating Sentry release: $VERSION"
sentry-cli releases new "$VERSION"
echo "✅ Release created"
echo ""

# Step 2: Associate commits
echo "🔗 Associating commits with release"
sentry-cli releases set-commits "$VERSION" --auto || echo "⚠️  No git repository found, skipping commits"
echo ""

# Step 3: Upload source maps (if dist directory exists)
if [ -d "$DIST_DIR" ]; then
  echo "📤 Uploading source maps from $DIST_DIR"
  sentry-cli releases files "$VERSION" upload-sourcemaps "$DIST_DIR" \
    --url-prefix "~/" \
    --validate \
    --strip-common-prefix || echo "⚠️  No source maps found"
  echo "✅ Source maps uploaded"
else
  echo "⚠️  Dist directory not found: $DIST_DIR"
  echo "Skipping source map upload"
fi
echo ""

# Step 4: Finalize release
echo "✔️  Finalizing release"
sentry-cli releases finalize "$VERSION"
echo "✅ Release finalized"
echo ""

# Step 5: Create deployment marker
echo "🚀 Creating deployment marker for $ENVIRONMENT"
sentry-cli releases deploys "$VERSION" new -e "$ENVIRONMENT"
echo "✅ Deployment tracked"
echo ""

# Step 6: List releases to confirm
echo "📋 Recent releases:"
sentry-cli releases list --max 5
echo ""

echo "🎉 Sentry release tracking complete!"
echo ""
echo "View release: https://sentry.io/organizations/$SENTRY_ORG_SLUG/releases/$VERSION/"
echo "View in MCP: \"Show me issues introduced in version $VERSION\""

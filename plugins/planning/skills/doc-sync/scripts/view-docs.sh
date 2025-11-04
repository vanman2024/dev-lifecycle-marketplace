#!/bin/bash
# Launch Documentation Viewer

echo "🚀 Launching Documentation Viewer..."
echo ""

# Check if mem0 venv exists
if [ ! -d "/tmp/mem0-env" ]; then
    echo "❌ Mem0 environment not found at /tmp/mem0-env"
    echo "   Run: cd /tmp && python3 -m venv mem0-env && source mem0-env/bin/activate && pip install mem0ai chromadb"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start server in background
echo "📡 Starting API server on http://localhost:8765..."
source /tmp/mem0-env/bin/activate
python "$SCRIPT_DIR/serve-viewer.py" &
SERVER_PID=$!

# Wait for server to start
sleep 2

# Open viewer in browser
VIEWER_PATH="$HOME/.claude/doc-viewer.html"
echo "🌐 Opening viewer: file://$VIEWER_PATH"

if command -v xdg-open &> /dev/null; then
    xdg-open "file://$VIEWER_PATH"
elif command -v open &> /dev/null; then
    open "file://$VIEWER_PATH"
else
    echo "   Please open manually: file://$VIEWER_PATH"
fi

echo ""
echo "✅ Viewer launched!"
echo "   API Server: http://localhost:8765"
echo "   Viewer: file://$VIEWER_PATH"
echo ""
echo "Press Ctrl+C to stop the server..."

# Wait for interrupt
trap "kill $SERVER_PID 2>/dev/null; echo ''; echo '👋 Server stopped'; exit 0" INT
wait $SERVER_PID

#!/bin/bash
# start-nanoclaw.sh — Start NanoClaw without systemd
# To stop: kill \$(cat /PROJECT/0325120037_A/jyh/nanoclaw/nanoclaw.pid)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Stop existing instance if running
if [ -f "$SCRIPT_DIR/nanoclaw.pid" ]; then
  OLD_PID=$(cat "$SCRIPT_DIR/nanoclaw.pid" 2>/dev/null || echo "")
  if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
    echo "Stopping existing NanoClaw (PID $OLD_PID)..."
    kill "$OLD_PID" 2>/dev/null || true
    sleep 2
  fi
fi

echo "Starting NanoClaw..."
nohup "/usr/bin/node" "$SCRIPT_DIR/dist/index.js" \
  >> "$SCRIPT_DIR/logs/nanoclaw.log" \
  2>> "$SCRIPT_DIR/logs/nanoclaw.error.log" &

echo $! > "$SCRIPT_DIR/nanoclaw.pid"
echo "NanoClaw started (PID $!)"
echo "Logs: tail -f $SCRIPT_DIR/logs/nanoclaw.log"

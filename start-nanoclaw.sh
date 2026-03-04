#!/bin/bash
# start-nanoclaw.sh — Start NanoClaw without systemd
# To stop: kill \$(cat /PROJECT/0325120037_A/jyh/nanoclaw/nanoclaw.pid)

set -euo pipefail

cd "/PROJECT/0325120037_A/jyh/nanoclaw"

# Stop existing instance if running
if [ -f "/PROJECT/0325120037_A/jyh/nanoclaw/nanoclaw.pid" ]; then
  OLD_PID=$(cat "/PROJECT/0325120037_A/jyh/nanoclaw/nanoclaw.pid" 2>/dev/null || echo "")
  if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
    echo "Stopping existing NanoClaw (PID $OLD_PID)..."
    kill "$OLD_PID" 2>/dev/null || true
    sleep 2
  fi
fi

echo "Starting NanoClaw..."
nohup "/usr/bin/node" "/PROJECT/0325120037_A/jyh/nanoclaw/dist/index.js" \
  >> "/PROJECT/0325120037_A/jyh/nanoclaw/logs/nanoclaw.log" \
  2>> "/PROJECT/0325120037_A/jyh/nanoclaw/logs/nanoclaw.error.log" &

echo $! > "/PROJECT/0325120037_A/jyh/nanoclaw/nanoclaw.pid"
echo "NanoClaw started (PID $!)"
echo "Logs: tail -f /PROJECT/0325120037_A/jyh/nanoclaw/logs/nanoclaw.log"

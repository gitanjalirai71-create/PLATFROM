#!/bin/bash
# ============================================================
# PERMANENT DEV SERVER LAUNCHER (uses start-stop-daemon)
# ============================================================
# This script starts the Next.js dev server as a TRUE DAEMON
# using start-stop-daemon. The process survives shell exit
# because start-stop-daemon detaches it from the parent process.
#
# Usage: bash start-dev.sh
# To stop: kill $(cat /tmp/next-dev.pid)

cd /home/z/my-project

# Check if already running
if pgrep -f "next-server" > /dev/null 2>&1; then
  echo "Dev server already running (PID: $(pgrep -f 'next-server' | head -1))"
  exit 0
fi

# Kill any stale processes
pkill -9 -f "next-server" 2>/dev/null
pkill -9 -f "next dev" 2>/dev/null
sleep 2

# Start as a true daemon (survives shell exit)
start-stop-daemon --start --background --make-pidfile --pidfile /tmp/next-dev.pid \
  --chdir /home/z/my-project --chuid z:z \
  --exec /home/z/my-project/node_modules/.bin/next -- dev -p 3000

echo "Dev server started as daemon"
sleep 8

if pgrep -f "next-server" > /dev/null 2>&1; then
  echo "Server is running (PID: $(pgrep -f 'next-server' | head -1))"
else
  echo "ERROR: Server failed to start"
  tail -20 /home/z/my-project/dev.log
fi

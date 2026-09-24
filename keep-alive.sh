#!/bin/bash
# ============================================================
# SELF-HEALING KEEP-ALIVE (v3 — aggressive + .env restore)
# ============================================================
# Runs every 15 seconds. For each check:
# 1. Restore .env from backup if NEXTAUTH_SECRET is missing
# 2. Remove stale middleware.ts if it reappeared
# 3. Check if next-server process is running
# 4. Check if server responds to HTTP (5s timeout)
# 5. If either fails, restart the server
#
# Started by start.sh as a daemon (start-stop-daemon).

cd /home/z/my-project
LOG=/home/z/my-project/dev.log

restore_env() {
  if ! grep -q "NEXTAUTH_SECRET" .env 2>/dev/null; then
    echo "[$(date)] ALERT: .env wiped — restoring from backup" >> "$LOG"
    cp .env.backup .env
  fi
  # Remove stale middleware.ts
  rm -f src/middleware.ts 2>/dev/null
}

restart_server() {
  echo "[$(date)] RESTART: Starting dev server..." >> "$LOG"
  pkill -9 -f "next-server" 2>/dev/null
  pkill -9 -f "next dev" 2>/dev/null
  sleep 3
  start-stop-daemon --start --background --make-pidfile --pidfile /tmp/next-dev.pid \
    --chdir /home/z/my-project --chuid z:z \
    --exec /home/z/my-project/node_modules/.bin/next -- dev -p 3000
  echo "[$(date)] RESTART: Dev server started, waiting for ready..." >> "$LOG"
  sleep 10
  # Pre-warm
  curl -s -o /dev/null --max-time 10 http://localhost:3000/ 2>/dev/null
  curl -s -o /dev/null --max-time 10 http://localhost:3000/r/saffron-mumbai 2>/dev/null
  echo "[$(date)] RESTART: Done" >> "$LOG"
}

check_health() {
  # 1. Process running?
  if ! pgrep -f "next-server" > /dev/null 2>&1; then
    echo "[$(date)] CHECK: next-server process not running" >> "$LOG"
    return 1
  fi

  # 2. HTTP responds?
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:3000/ 2>/dev/null)
  if [ "$http_code" = "000" ] || [ -z "$http_code" ]; then
    echo "[$(date)] CHECK: server not responding (http=$http_code)" >> "$LOG"
    return 1
  fi

  return 0
}

# Main loop — check every 15 seconds
while true; do
  restore_env
  if ! check_health; then
    restart_server
  fi
  sleep 15
done

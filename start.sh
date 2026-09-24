#!/bin/bash
# ============================================================
# MASTER STARTUP SCRIPT — permanent server stability
# ============================================================
# This script:
# 1. Restores .env from backup if it was wiped
# 2. Kills stale processes
# 3. Starts the dev server (start-stop-daemon = survives shell exit)
# 4. Waits for server to be ready
# 5. Pre-warms the cache (hits all routes to compile them)
# 6. Starts the keep-alive daemon
#
# Usage: bash start.sh

cd /home/z/my-project

# ============================================================
# 1. RESTORE .env IF MISSING
# ============================================================
if ! grep -q "NEXTAUTH_SECRET" .env 2>/dev/null; then
  echo "[$(date)] .env missing NEXTAUTH_SECRET — restoring from backup"
  cp .env.backup .env
fi

# Also remove stale middleware.ts if it reappeared
rm -f src/middleware.ts 2>/dev/null

# ============================================================
# 2. KILL STALE PROCESSES
# ============================================================
pkill -9 -f "next-server" 2>/dev/null
pkill -9 -f "next dev" 2>/dev/null
pkill -9 -f "keep-alive" 2>/dev/null
sleep 3

# ============================================================
# 3. START DEV SERVER (start-stop-daemon = true daemon)
# ============================================================
echo "[$(date)] Starting dev server..."
start-stop-daemon --start --background --make-pidfile --pidfile /tmp/next-dev.pid \
  --chdir /home/z/my-project --chuid z:z \
  --exec /home/z/my-project/node_modules/.bin/next -- dev -p 3000

# ============================================================
# 4. WAIT FOR SERVER TO BE READY
# ============================================================
echo "[$(date)] Waiting for server to be ready..."
for i in $(seq 1 30); do
  if pgrep -f "next-server" > /dev/null 2>&1; then
    # Try a health check
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:3000/ 2>/dev/null)
    if [ "$http_code" = "200" ]; then
      echo "[$(date)] Server is ready (HTTP 200)"
      break
    fi
  fi
  sleep 2
done

# ============================================================
# 5. PRE-WARM CACHE (trigger compilation of all routes)
# ============================================================
echo "[$(date)] Pre-warming cache..."
for route in "/" "/setup" "/r/saffron-mumbai" "/r/saffron-mumbai/admin" "/api/tenants" "/api/settings" "/api/menu"; do
  curl -s -o /dev/null --max-time 15 "http://localhost:3000${route}" 2>/dev/null
  echo "  Warmed: $route"
done

# ============================================================
# 6. START KEEP-ALIVE DAEMON
# ============================================================
echo "[$(date)] Starting keep-alive daemon..."
start-stop-daemon --start --background --make-pidfile --pidfile /tmp/keep-alive.pid \
  --chdir /home/z/my-project --chuid z:z \
  --exec /bin/bash -- /home/z/my-project/keep-alive.sh

echo "[$(date)] All started. Server + keep-alive running."
echo "  Server PID: $(cat /tmp/next-dev.pid 2>/dev/null)"
echo "  Keep-alive PID: $(cat /tmp/keep-alive.pid 2>/dev/null)"

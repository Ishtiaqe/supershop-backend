#!/usr/bin/env bash
set -euo pipefail

# Wrapper script to run the sync-local-to-prod.ts
# It handles starting the Cloud SQL Proxy on a secondary port (5433)
# so it doesn't conflict with the local DB on 5432.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROXY_CMD="./cloud-sql-proxy shomaj-817b0:asia-southeast1:supershop --port 5433"

echo "=== Step 1: Starting Cloud SQL Proxy on port 5433 ==="
# Check if already running on 5433
if pgrep -f "cloud-sql-proxy.*5433" > /dev/null; then
  echo "Proxy already running on 5433."
else
  echo "Starting proxy..."
  pushd "$PROJECT_ROOT" > /dev/null
  $PROXY_CMD > "$PROJECT_ROOT/cloud-sql-proxy-sync.log" 2>&1 &
  PROXY_PID=$!
  popd > /dev/null
  echo "Waiting for proxy to initialize (PID: $PROXY_PID)..."
  sleep 5
fi

echo "=== Step 2: Running Sync Script ==="
# Run the typescript script using ts-node
# We need to ensure ts-node is available. It is in devDependencies.

cd "$PROJECT_ROOT"
if [ -f "node_modules/.bin/ts-node" ]; then
  ./node_modules/.bin/ts-node scripts/sync-local-to-prod.ts
else
  npx ts-node scripts/sync-local-to-prod.ts
fi

echo "=== Step 3: Cleanup ==="
if [ -n "${PROXY_PID:-}" ]; then
  echo "Stopping proxy (PID: $PROXY_PID)..."
  kill "$PROXY_PID" || true
fi

echo "Done."

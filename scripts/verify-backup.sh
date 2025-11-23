#!/usr/bin/env bash
set -euo pipefail

# Script to verify database backup and restore
# 1. Ensures Cloud SQL Proxy is running (for source DB)
# 2. Starts a local Docker Postgres instance (for target DB)
# 3. Runs backup-to-sql.sh (Backup)
# 4. Restores to local Docker instance
# 5. Verifies data consistency
# 6. Cleans up

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_SCRIPT="$SCRIPT_DIR/backup-to-sql.sh"
PROXY_DIR="/mnt/storage/Projects/supershop"
PROXY_CMD="./cloud-sql-proxy shomaj-817b0:asia-southeast1:supershop"
LOCAL_DB_PORT=5433
LOCAL_DB_NAME="supershop_test"
LOCAL_DB_USER="postgres"
LOCAL_DB_PASS="test"
LOCAL_CONTAINER_NAME="supershop_verify_db"

# Load DATABASE_URL from .env if not already set
if [ -z "${DATABASE_URL:-}" ] && [ -f "$PROJECT_ROOT/.env" ]; then
  DATABASE_URL=$(grep -E '^DATABASE_URL=' "$PROJECT_ROOT/.env" | sed -E 's/^DATABASE_URL=["'\'']?(.*)["'\'']?$/\1/')
fi

# Function to check DB connection
check_db_connection() {
  local url="$1"
  # Clean URL for psql
  local clean_url=$(echo "$url" | sed 's/?schema=[^&]*//' | sed 's/@123/%40123/g')
  psql "$clean_url" -c "SELECT 1" >/dev/null 2>&1
}

# Function to get row count
get_row_count() {
  local url="$1"
  local table="$2"
  local clean_url=$(echo "$url" | sed 's/?schema=[^&]*//' | sed 's/@123/%40123/g')
  psql "$clean_url" -t -c "SELECT count(*) FROM \"$table\";" | xargs
}

echo "=== Step 1: Checking Source Database Connection ==="

if check_db_connection "$DATABASE_URL"; then
  echo "Source database connection established."
else
  echo "Source database connection failed. Attempting to start Cloud SQL Proxy..."
  
  # Check if proxy is already running
  if pgrep -f "cloud-sql-proxy" > /dev/null; then
    echo "Proxy seems to be running but connection failed. Please check logs."
    # Kill it and restart? Or just fail?
    # Let's try to start it anyway if it's not responding
  fi

  echo "Starting Cloud SQL Proxy..."
  pushd "$PROXY_DIR" > /dev/null
  # Run in background
  $PROXY_CMD > "$PROJECT_ROOT/cloud-sql-proxy.log" 2>&1 &
  PROXY_PID=$!
  popd > /dev/null
  
  echo "Waiting for proxy to initialize (PID: $PROXY_PID)..."
  sleep 5
  
  # Wait loop
  MAX_RETRIES=10
  COUNT=0
  while ! check_db_connection "$DATABASE_URL"; do
    sleep 2
    COUNT=$((COUNT+1))
    if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
      echo "Error: Could not connect to source database via proxy after waiting."
      kill "$PROXY_PID" || true
      exit 1
    fi
    echo "Waiting for connection..."
  done
  echo "Proxy connected successfully."
fi

echo "=== Step 2: Setting up Local Test Database (Docker) ==="

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${LOCAL_CONTAINER_NAME}$"; then
  echo "Removing existing test container..."
  docker rm -f "$LOCAL_CONTAINER_NAME" > /dev/null
fi

echo "Starting local Postgres container on port $LOCAL_DB_PORT..."
docker run -d \
  --name "$LOCAL_CONTAINER_NAME" \
  -e POSTGRES_PASSWORD="$LOCAL_DB_PASS" \
  -e POSTGRES_DB="$LOCAL_DB_NAME" \
  -p "$LOCAL_DB_PORT":5432 \
  postgres:17-alpine > /dev/null

# Wait for local DB
echo "Waiting for local test database..."
TEST_DB_URL="postgresql://$LOCAL_DB_USER:$LOCAL_DB_PASS@localhost:$LOCAL_DB_PORT/$LOCAL_DB_NAME"
MAX_RETRIES=10
COUNT=0
while ! check_db_connection "$TEST_DB_URL"; do
  sleep 2
  COUNT=$((COUNT+1))
  if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
    echo "Error: Could not connect to local test database."
    docker logs "$LOCAL_CONTAINER_NAME"
    docker rm -f "$LOCAL_CONTAINER_NAME" > /dev/null
    exit 1
  fi
  echo "Waiting for local DB..."
done
echo "Local test database ready."

echo "=== Step 3: Running Backup ==="
"$BACKUP_SCRIPT"

# Find the latest backup file
BACKUP_FILE=$(ls -t "$PROJECT_ROOT/backups"/*.sql | head -n 1)
echo "Latest backup file: $BACKUP_FILE"

echo "=== Step 4: Restoring to Local Test Database ==="
RESTORE_LOG="$PROJECT_ROOT/backups/restore_log.txt"
echo "Restoring... (logging to $RESTORE_LOG)"

# Restore
# Note: The backup might contain 'CREATE SCHEMA' or extensions that require superuser.
# The docker postgres user is superuser, so it should be fine.
# However, if the backup has 'OWNER TO' statements for users that don't exist locally, it might warn/fail.
# The backup script uses --no-owner, which helps.

psql "$TEST_DB_URL" -f "$BACKUP_FILE" > "$RESTORE_LOG" 2>&1 || true

# Check for critical errors
# We ignore "role does not exist" if --no-owner didn't catch everything, or extension errors if not available
echo "Checking for errors..."
grep "ERROR" "$RESTORE_LOG" | grep -v "google_vacuum_mgmt" | head -n 10 || echo "No critical errors found."

echo "=== Step 5: Verifying Data ==="

TABLES=("users" "tenants" "products" "sales")
ALL_MATCH=true

for table in "${TABLES[@]}"; do
  echo "Checking table: $table"
  
  if ! count_orig=$(get_row_count "$DATABASE_URL" "$table" 2>/dev/null); then
     echo "  - Table $table not found in source DB (skipping)"
     continue
  fi
  
  if ! count_test=$(get_row_count "$TEST_DB_URL" "$table" 2>/dev/null); then
     echo "  - Table $table not found in test DB (Restore failed?)"
     ALL_MATCH=false
     continue
  fi
  
  echo "  - Original: $count_orig"
  echo "  - Restored: $count_test"
  
  if [ "$count_orig" == "$count_test" ]; then
    echo "  - [OK] Counts match"
  else
    echo "  - [FAIL] Counts do not match!"
    ALL_MATCH=false
  fi
done

echo "=== Step 6: Cleanup ==="
echo "Stopping local test container..."
docker rm -f "$LOCAL_CONTAINER_NAME" > /dev/null

# We do NOT stop the proxy if we started it, or maybe we should?
# If we started it, we have PROXY_PID.
if [ -n "${PROXY_PID:-}" ]; then
  echo "Stopping Cloud SQL Proxy..."
  kill "$PROXY_PID" || true
fi

if [ "$ALL_MATCH" == true ]; then
  echo "Verification Successful! Backup and Restore verified."
  exit 0
else
  echo "Verification Failed! Data mismatch detected."
  exit 1
fi

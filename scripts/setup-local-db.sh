#!/usr/bin/env bash
set -euo pipefail

# Script to create a local Docker Postgres instance and restore the backup
# Container Name: supershop_db_backup
# Database Name: supershop_db_backup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
CONTAINER_NAME="supershop_db_backup"
DB_NAME="supershop_db_backup"
DB_PORT=5432
DB_USER="postgres"
DB_PASS="postgres" # Simple password for local dev

# Check for existing container with the same name
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container '$CONTAINER_NAME'..."
    docker rm -f "$CONTAINER_NAME" >/dev/null
fi

# Check for other containers using the port (like the one I made previously)
if docker ps --format '{{.Names}} {{.Ports}}' | grep ":$DB_PORT->"; then
    CONFLICT_ID=$(docker ps --format '{{.ID}}' --filter "publish=$DB_PORT")
    CONFLICT_NAME=$(docker ps --format '{{.Names}}' --filter "publish=$DB_PORT")
    echo "Warning: Port $DB_PORT is in use by container '$CONFLICT_NAME' ($CONFLICT_ID)."
    echo "Stopping conflicting container..."
    docker rm -f "$CONFLICT_ID" >/dev/null
fi

# Check if cloud-sql-proxy is running
if pgrep -f "cloud-sql-proxy" > /dev/null; then
    echo "Stopping cloud-sql-proxy to free up port $DB_PORT..."
    pkill -f "cloud-sql-proxy" || true
fi

# Find latest backup
BACKUP_FILE=$(ls -t "$PROJECT_ROOT/backups"/*.sql 2>/dev/null | head -n 1)
if [ -z "$BACKUP_FILE" ]; then
    echo "Error: No backup file found in backups/ directory."
    exit 1
fi
echo "Using backup file: $BACKUP_FILE"

echo "Starting new Docker container '$CONTAINER_NAME'..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -e POSTGRES_PASSWORD="$DB_PASS" \
  -e POSTGRES_USER="$DB_USER" \
  -e POSTGRES_DB="$DB_NAME" \
  -p "$DB_PORT":5432 \
  postgres:17-alpine > /dev/null

echo "Waiting for database to initialize..."
sleep 5
# Wait loop
MAX_RETRIES=20
COUNT=0
DB_URL="postgresql://$DB_USER:$DB_PASS@localhost:$DB_PORT/$DB_NAME"

until psql "$DB_URL" -c "SELECT 1" >/dev/null 2>&1; do
  sleep 2
  COUNT=$((COUNT+1))
  if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
    echo "Error: Could not connect to local database."
    docker logs "$CONTAINER_NAME"
    exit 1
  fi
  echo "Waiting for connection..."
done

echo "Restoring backup to database '$DB_NAME'..."
RESTORE_LOG="$PROJECT_ROOT/backups/restore_local_log.txt"
# Using || true because some errors (like role ownership) are expected when restoring to a fresh local DB
psql "$DB_URL" -f "$BACKUP_FILE" > "$RESTORE_LOG" 2>&1 || true

echo "Checking for critical errors..."
grep "ERROR" "$RESTORE_LOG" | grep -v "google_vacuum_mgmt" | head -n 10 || echo "No critical errors found."

echo "----------------------------------------------------------------"
echo "✅ Local database setup complete!"
echo "Container: $CONTAINER_NAME"
echo "Database:  $DB_NAME"
echo "User:      $DB_USER"
echo "Password:  $DB_PASS"
echo "Port:      $DB_PORT"
echo ""
echo "To connect via psql:"
echo "psql \"$DB_URL\""
echo ""
echo "⚠️  UPDATE YOUR .env FILE:"
echo "DATABASE_URL=\"postgresql://$DB_USER:$DB_PASS@localhost:$DB_PORT/$DB_NAME?schema=public\""
echo "----------------------------------------------------------------"

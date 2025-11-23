#!/usr/bin/env bash
set -euo pipefail

# Script to set up a persistent local development database using Docker
# and restore the latest backup to it.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
CONTAINER_NAME="supershop-local-db"
DB_PORT=5432
DB_NAME="supershop"
DB_USER="supershop_user"
# Using the same password as in .env for convenience, so you can switch easily
DB_PASS="MUJAHIDrumel123@123" 

# Check if port 5432 is in use
if lsof -Pi :$DB_PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "Warning: Port $DB_PORT is already in use."
    echo "If you have 'cloud-sql-proxy' running, please stop it first."
    echo "If you have another Postgres instance running, please stop it."
    read -p "Do you want to try stopping the existing container '$CONTAINER_NAME' if it exists? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    else
        echo "Aborting."
        exit 1
    fi
fi

# Find latest backup
BACKUP_FILE=$(ls -t "$PROJECT_ROOT/backups"/*.sql 2>/dev/null | head -n 1)
if [ -z "$BACKUP_FILE" ]; then
    echo "Error: No backup file found in backups/ directory."
    echo "Run ./scripts/backup-to-sql.sh first."
    exit 1
fi
echo "Using latest backup: $BACKUP_FILE"

echo "Starting Docker container '$CONTAINER_NAME'..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -e POSTGRES_PASSWORD="$DB_PASS" \
  -e POSTGRES_USER="$DB_USER" \
  -e POSTGRES_DB="$DB_NAME" \
  -p "$DB_PORT":5432 \
  postgres:17-alpine

echo "Waiting for database to initialize..."
sleep 5
# Wait loop
MAX_RETRIES=20
COUNT=0
DB_URL="postgresql://$DB_USER:$DB_PASS@localhost:$DB_PORT/$DB_NAME"
# Fix URL for psql (encode password)
CLEAN_URL=$(echo "$DB_URL" | sed 's/@123/%40123/g')

until psql "$CLEAN_URL" -c "SELECT 1" >/dev/null 2>&1; do
  sleep 2
  COUNT=$((COUNT+1))
  if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
    echo "Error: Could not connect to local database."
    docker logs "$CONTAINER_NAME"
    exit 1
  fi
  echo "Waiting for connection..."
done

echo "Restoring backup..."
RESTORE_LOG="$PROJECT_ROOT/backups/local_restore_log.txt"
psql "$CLEAN_URL" -f "$BACKUP_FILE" > "$RESTORE_LOG" 2>&1 || true

echo "Checking for restore errors..."
grep "ERROR" "$RESTORE_LOG" | grep -v "google_vacuum_mgmt" | head -n 10 || echo "No critical errors found."

echo "----------------------------------------------------------------"
echo "Local database is ready!"
echo "Container Name: $CONTAINER_NAME"
echo "Port: $DB_PORT"
echo "User: $DB_USER"
echo "Database: $DB_NAME"
echo ""
echo "To connect using psql:"
echo "psql \"$CLEAN_URL\""
echo ""
echo "To use this with your backend, your .env is already compatible if you stop the proxy."
echo "DATABASE_URL=postgresql://$DB_USER:MUJAHIDrumel123@123@localhost:5432/$DB_NAME?schema=public"
echo "----------------------------------------------------------------"

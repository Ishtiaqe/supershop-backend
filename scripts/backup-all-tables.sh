#!/bin/bash

# Comprehensive Database Backup Script
# Creates a timestamped SQL backup of all tables before schema migrations
# Usage: ./scripts/backup-all-tables.sh

set -e

# Load environment variables - only single-line values
if [ -f .env ]; then
  export $(grep -v '#' .env | grep '=' | grep -v '\n' | head -c 10000 | xargs 2>/dev/null || true)
fi

# Extract DATABASE_URL directly from .env file
DATABASE_URL=$(grep '^DATABASE_URL=' .env | cut -d '=' -f 2- | tr -d "'" | tr -d '"')

if [ -z "$DATABASE_URL" ]; then
  DATABASE_URL="${DATABASE_URL}"
fi

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL environment variable not set"
  exit 1
fi

# Parse PostgreSQL connection string
if [[ $DATABASE_URL =~ postgresql://([^:]+):([^@]+)@([^:]+):([^/]+)/(.+) ]]; then
  DB_USER="${BASH_REMATCH[1]}"
  DB_PASSWORD="${BASH_REMATCH[2]}"
  DB_HOST="${BASH_REMATCH[3]}"
  DB_PORT="${BASH_REMATCH[4]}"
  DB_NAME="${BASH_REMATCH[5]}"
else
  echo "ERROR: Could not parse DATABASE_URL"
  exit 1
fi

# Create backups directory if it doesn't exist
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_${TIMESTAMP}.sql"

echo "=========================================="
echo "Database Backup Script"
echo "=========================================="
echo "Database: $DB_NAME"
echo "Host: $DB_HOST:$DB_PORT"
echo "Backup file: $BACKUP_FILE"
echo "Timestamp: $TIMESTAMP"
echo "=========================================="

# Create backup using pg_dump
PGPASSWORD="$DB_PASSWORD" pg_dump \
  --host="$DB_HOST" \
  --port="$DB_PORT" \
  --username="$DB_USER" \
  --database="$DB_NAME" \
  --format=plain \
  --verbose \
  --no-password \
  > "$BACKUP_FILE" 2>&1

if [ $? -eq 0 ]; then
  FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
  echo ""
  echo "✅ Backup completed successfully!"
  echo "📁 File: $BACKUP_FILE"
  echo "📊 Size: $FILE_SIZE"
  echo "⏰ Time: $TIMESTAMP"
  echo ""
  echo "To restore from this backup, run:"
  echo "  psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $BACKUP_FILE"
  echo ""
else
  echo ""
  echo "❌ Backup failed!"
  exit 1
fi

# Also create a schema-only backup
SCHEMA_BACKUP_FILE="$BACKUP_DIR/schema_${TIMESTAMP}.sql"

PGPASSWORD="$DB_PASSWORD" pg_dump \
  --host="$DB_HOST" \
  --port="$DB_PORT" \
  --username="$DB_USER" \
  --database="$DB_NAME" \
  --format=plain \
  --schema-only \
  --verbose \
  --no-password \
  > "$SCHEMA_BACKUP_FILE" 2>&1

if [ $? -eq 0 ]; then
  SCHEMA_SIZE=$(du -h "$SCHEMA_BACKUP_FILE" | cut -f1)
  echo "✅ Schema-only backup completed!"
  echo "📁 File: $SCHEMA_BACKUP_FILE"
  echo "📊 Size: $SCHEMA_SIZE"
  echo ""
else
  echo "⚠️  Schema-only backup failed (non-critical)"
fi

# List recent backups
echo "Recent backups:"
ls -lh "$BACKUP_DIR" | tail -5

exit 0

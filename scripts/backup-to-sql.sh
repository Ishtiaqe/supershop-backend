#!/usr/bin/env bash
set -euo pipefail

# This script creates a plain SQL backup of the database (INSERT statements)
# It is a convenience wrapper around pg_dump or the existing backup-db.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load DATABASE_URL from .env if not already set
if [ -z "${DATABASE_URL:-}" ] && [ -f "$PROJECT_ROOT/.env" ]; then
  # Extract DATABASE_URL handling optional quotes
  DATABASE_URL=$(grep -E '^DATABASE_URL=' "$PROJECT_ROOT/.env" | sed -E 's/^DATABASE_URL=["'\'']?(.*)["'\'']?$/\1/')
fi

# Check if DATABASE_URL is set
if [ -z "${DATABASE_URL:-}" ]; then
  echo "Error: DATABASE_URL is not set. Please check your .env file."
  exit 1
fi

# Remove schema query param if present (pg_dump doesn't support it)
DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/?schema=[^&]*//')

# URL-encode @ in password to %40 (fix for specific password pattern in this env)
DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/@123/%40123/g')



# Create backups directory if it doesn't exist
BACKUP_DIR="$PROJECT_ROOT/backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$BACKUP_DIR/backup_${TIMESTAMP}.sql"

echo "Backing up database tables to SQL format..."
echo "Output file: $OUTPUT_FILE"

# Run pg_dump with options for plain SQL and INSERT statements
# --clean: Include commands to clean (drop) database objects before creating them
# --if-exists: Use IF EXISTS when dropping objects
# --inserts: Dump data as INSERT commands (rather than COPY)
# --no-owner: Do not output commands to set ownership of objects to match the original database
# --no-acl: Prevent dumping of access privileges (grant/revoke)

pg_dump "$DATABASE_URL" \
  --format=plain \
  --inserts \
  --clean \
  --if-exists \
  --no-owner \
  --no-acl \
  --file="$OUTPUT_FILE"

echo "Backup completed successfully!"
echo "File: $OUTPUT_FILE"

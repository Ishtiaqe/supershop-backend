#!/bin/bash

# Restore SuperShop database to Supabase
# Usage: ./restore-to-supabase.sh <backup-file>

set -e

BACKUP_FILE="${1:-../backups/supabase-restore.sql}"
SUPABASE_URL="postgresql://postgres:tMJlNdBmxBtIp71V@db.ldxoajddytnbdecdihnv.supabase.co:5432/postgres"

echo "========================================="
echo "SuperShop Database Restore to Supabase"
echo "========================================="
echo ""
echo "Backup file: $BACKUP_FILE"
echo ""

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Check file size
FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "Backup file size: $FILE_SIZE"
echo ""

# Confirm before proceeding
read -p "This will restore the database to Supabase. Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

echo "Starting restore..."
echo ""

# Restore the database
psql "$SUPABASE_URL" < "$BACKUP_FILE"

echo ""
echo "✅ Database restored successfully!"
echo ""
echo "Next steps:"
echo "1. Update your .env file with:"
echo "   DATABASE_URL=$SUPABASE_URL"
echo "2. Run: npx prisma migrate deploy"
echo "3. Test your application"

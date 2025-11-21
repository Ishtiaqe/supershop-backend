# Database Backup and Restore Guide

This guide covers how to backup and restore the SuperShop PostgreSQL database using the provided scripts.

## Prerequisites

- **PostgreSQL client tools**: `pg_dump`, `pg_restore`, `psql` must be installed (comes with Postgres).
- **Database access**: `DATABASE_URL` must be set in environment or `.env` file (e.g., `postgresql://user:pass@host:port/db`).
- **Node.js and npm**: For Prisma-based scripts.
- **Permissions**: User must have read/write access to the database and file system.

## Backup Instructions

### Using npm Scripts (Recommended)

- **Full backup (custom format, compressed)**:
  ```bash
  npm run db:backup
  ```
  - Creates `backups/db-backup-YYYYMMDDTHHMMSSZ.dump.gz`

- **Full backup (plain SQL, compressed)**:
  ```bash
  npm run db:backup:plain
  ```
  - Creates `backups/db-backup-YYYYMMDDTHHMMSSZ.sql.gz`

- **Backup specific tables (plain SQL)**:
  ```bash
  npm run db:backup:tables -- --tables users,products
  ```
  - Creates `backups/db-backup-YYYYMMDDTHHMMSSZ.sql.gz`

- **Prisma JSON export**:
  ```bash
  npm run db:export
  ```
  - Creates `backups/prisma-json-YYYYMMDDTHHMMSSZ/` with JSON files per model.

- **Query result to INSERT SQL**:
  ```bash
  npm run db:query-export -- --query "SELECT id, name FROM users WHERE tenantId = 'shop1'" --table users --out backups/users-inserts.sql
  ```
  - Creates `backups/users-inserts.sql` with INSERT statements.

### Using Bash Scripts Directly

- **Custom format dump**:
  ```bash
  bash scripts/backup-db.sh --compress
  ```

- **Plain SQL dump with INSERT statements**:
  ```bash
  bash scripts/backup-db.sh --plain --inserts --compress
  ```

- **Schema-only dump**:
  ```bash
  bash scripts/backup-db.sh --schema-only --compress
  ```

- **Data-only dump**:
  ```bash
  bash scripts/backup-db.sh --data-only --compress
  ```

- **Specific tables**:
  ```bash
  bash scripts/backup-db.sh --plain --tables users,products --out /tmp/my-backup --compress
  ```

Options:
- `--out <dir>`: Change output directory (default: `backups/`)
- `--compress`: Gzip the output file
- `--plain`: Output plain SQL instead of custom format
- `--inserts`: Use INSERT statements instead of COPY (slower, larger files)
- `--tables <list>`: Comma-separated table names to dump

## Restore Instructions

### Restore from Custom Format Dump (`.dump` or `.dump.gz`)

1. **Decompress if needed**:
   ```bash
   gunzip backups/db-backup-YYYYMMDDTHHMMSSZ.dump.gz
   ```

2. **Create a new database (if restoring to a new DB)**:
   ```bash
   createdb new_database_name
   ```

3. **Restore the dump**:
   ```bash
   pg_restore -d new_database_name backups/db-backup-YYYYMMDDTHHMMSSZ.dump
   ```

   - Options:
     - `--clean`: Drop existing objects before recreating
     - `--create`: Create the database (requires superuser)
     - `--schema-only`: Restore only schema
     - `--data-only`: Restore only data

4. **Verify**:
   ```bash
   psql -d new_database_name -c "SELECT COUNT(*) FROM users;"
   ```

### Restore from Plain SQL Dump (`.sql` or `.sql.gz`)

1. **Decompress if needed**:
   ```bash
   gunzip backups/db-backup-YYYYMMDDTHHMMSSZ.sql.gz
   ```

2. **Create a new database (if needed)**:
   ```bash
   createdb new_database_name
   ```

3. **Run the SQL file**:
   ```bash
   psql -d new_database_name -f backups/db-backup-YYYYMMDDTHHMMSSZ.sql
   ```

4. **Verify**:
   ```bash
   psql -d new_database_name -c "SELECT COUNT(*) FROM products;"
   ```

### Restore from Prisma JSON Export

1. **Install dependencies and generate Prisma client**:
   ```bash
   npm install
   npm run prisma:generate
   ```

2. **Create a script to import JSON** (example):
   ```typescript
   // scripts/import-prisma.ts
   import { PrismaClient } from '@prisma/client';
   import fs from 'fs';
   import path from 'path';

   const prisma = new PrismaClient();

   async function main() {
     const dir = 'backups/prisma-json-YYYYMMDDTHHMMSSZ';
     const files = fs.readdirSync(dir).filter(f => f.endsWith('.json'));
     for (const file of files) {
       const model = file.replace('.json', '');
       const data = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'));
       // Assuming camelCase model names
       const client = (prisma as any)[model.charAt(0).toLowerCase() + model.slice(1)];
       if (client && client.createMany) {
         await client.createMany({ data });
       }
     }
     await prisma.$disconnect();
   }

   main();
   ```

3. **Run the import**:
   ```bash
   ts-node scripts/import-prisma.ts
   ```

### Restore from Query INSERT SQL

1. **Run the SQL file**:
   ```bash
   psql -d database_name -f backups/users-inserts.sql
   ```

## Examples

### Full Backup and Restore

1. **Backup**:
   ```bash
   npm run db:backup
   ```

2. **Restore to new DB**:
   ```bash
   createdb supershop_restore
   gunzip -c backups/db-backup-20251122T015100Z.dump.gz | pg_restore -d supershop_restore
   ```

### Selective Table Backup

1. **Backup users and products**:
   ```bash
   bash scripts/backup-db.sh --plain --tables users,products --compress
   ```

2. **Restore to existing DB**:
   ```bash
   psql -d supershop -f backups/db-backup-YYYYMMDDTHHMMSSZ.sql
   ```

## Warnings and Best Practices

- **Never run restores on production without backups**: Always backup before restore operations.
- **Test restores**: Restore to a test database first to verify integrity.
- **Security**: Store backups in encrypted, secure locations (S3, GCS). Do not commit to Git.
- **Retention**: Implement lifecycle policies to delete old backups.
- **Large databases**: Use custom format for speed; plain SQL for readability/portability.
- **Tenant isolation**: Ensure queries respect `tenantId` in multi-tenant setups.
- **Prisma exports**: JSON exports are for data migration; use SQL dumps for full fidelity.

## Troubleshooting

- **pg_dump fails**: Check `DATABASE_URL`, network access, and Postgres client version.
- **Restore fails**: Ensure target DB exists, user has permissions, and no conflicting objects.
- **Prisma issues**: Run `npm run prisma:generate` after schema changes.

For more details, see `scripts/README.md`.
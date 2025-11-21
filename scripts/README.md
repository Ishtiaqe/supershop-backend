# Database Backup Scripts

This folder contains scripts to backup the Supershop Postgres database and export data using Prisma.

## SQL Backup (pg_dump)

Script: `scripts/backup-db.sh`

Requirements:
- `pg_dump` (Postgres client)
- `DATABASE_URL` environment variable set (or in `.env` / `.env.production`)

Usage examples:

- Full backup, compressed:

```bash
npm run db:backup
```

- Schema-only backup:

```bash
bash scripts/backup-db.sh --schema-only
```

- Data-only backup into a custom directory:
- Plain SQL backup (OUTPUTS SQL script with INSERT statements if --inserts flag passed):

```bash
bash scripts/backup-db.sh --plain --inserts --compress
```

- Backup specific tables (comma-separated) — plain SQL:

```bash
bash scripts/backup-db.sh --plain --tables users,products
```

Notes about plain SQL: use `--plain` to generate a plain SQL script file with schema and INSERT or COPY statements (if `--inserts` is used you'll get INSERT statements for each row). This is useful if you want a human-editable SQL script that can be run with `psql -d mydb -f dump.sql`.

```bash
bash scripts/backup-db.sh --data-only --out /tmp/my-backups
```

### SQL (plain) format

To generate a plain SQL file that contains SQL statements (CREATE/INSERT) instead of a custom-format dump, use the `--plain` flag. This makes it easy to restore by running `psql -f` against a database.

```bash
bash scripts/backup-db.sh --plain --out /tmp/my-sql-backup
```

You can also dump only selected tables (comma-separated):

```bash
bash scripts/backup-db.sh --plain --tables products,users --out /tmp/my-sql-backup
```

This will produce a `.sql` file with SQL statements.

Notes:
- The script uses `pg_dump` with the `-Fc` (custom) format; files are created under `backups/` by default.
- Use `pg_restore` to restore dumps made by `pg_dump -Fc` (e.g., `pg_restore -d mydb <dumpfile>`).

## JSON Export (Prisma)

Script: `scripts/export-prisma.ts`

Requirements:
- `ts-node` (already in dev dependencies)
- `prisma` client generated (`npm run prisma:generate`)
- `DATABASE_URL` configured (Prisma client will use process environment)

Usage:

```bash
npm run db:export
```

This will create a folder under `backups/prisma-json-<timestamp>` with one JSON file per Prisma model.

## SQL Query to INSERT statements

Script: `scripts/query-to-inserts.ts`

This script runs a SQL `SELECT` query using the Prisma client and writes the results as `INSERT` SQL statements to a file.

Usage example:

```bash
ts-node scripts/query-to-inserts.ts --query "SELECT id, name, email FROM users WHERE tenantId = 'shomaj'" --table users --out backups/users-inserts.sql
```

This is useful if you want an `INSERT`-style SQL snippet for a specific query result set rather than a whole table dump.

## Recommendations

- Run the SQL dump periodically and store it in a secure backup location (S3, GCS, etc.).
- Keep both schema+data SQL dumps and JSON exports for different restore scenarios.
- For large databases, consider running jobs with compression and using incremental strategies (e.g., WAL archiving or scheduled logical replication).

For detailed backup and restore instructions, including examples and troubleshooting, see `../BACKUP_RESTORE_GUIDE.md`.


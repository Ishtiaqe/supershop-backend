# Local Database Setup with Cloud SQL Proxy

## Quick Start

### Step 1: Download Cloud SQL Proxy

```bash
# Download for Linux
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy

# Move to backend directory (if not already there)
mv cloud-sql-proxy /mnt/storage/Projects/supershop/backend/
```

### Step 2: Start Cloud SQL Proxy

```bash
cd /mnt/storage/Projects/supershop/backend

# Start proxy (connects to your Google Cloud SQL instance)
./cloud-sql-proxy shomaj-817b0:asia-southeast1:supershop

# Leave this terminal open - it creates a local connection to your Cloud SQL
# You'll see: "Listening on 127.0.0.1:5432"
```

### Step 3: Run Migrations (in NEW terminal)

```bash
# Open a NEW terminal
cd /mnt/storage/Projects/supershop/backend

# Run migrations
npm run prisma:migrate

# Or generate Prisma client
npm run prisma:generate

# Or open Prisma Studio
npm run prisma:studio
```

---

## What I Fixed

### ❌ Old DATABASE_URL (broken):
```
postgresql://supershop_user:MUJAHIDrumel123@123@/supershop?host=/cloudsql/shomaj-817b0:asia-southeast1:supershop?schema=public
```

**Problems:**
1. Double `@@` symbols (should be single `@`)
2. Cloud SQL socket path only works on Cloud Run (not locally)
3. Mixed `?` and `?` (should use `&` for multiple params)

### ✅ New DATABASE_URL (fixed):
```
postgresql://supershop_user:MUJAHIDrumel123@123@127.0.0.1:5432/supershop?schema=public
```

**This works because:**
1. Single `@` before host
2. Connects to `127.0.0.1:5432` (Cloud SQL Proxy local endpoint)
3. Proper query string format

---

## Commands Summary

### Start Cloud SQL Proxy (Terminal 1)
```bash
cd /mnt/storage/Projects/supershop/backend
./cloud-sql-proxy shomaj-817b0:asia-southeast1:supershop
```

### Run Database Commands (Terminal 2)
```bash
cd /mnt/storage/Projects/supershop/backend

# Run migrations
npm run prisma:migrate

# Generate Prisma Client
npm run prisma:generate

# Open Prisma Studio (DB GUI)
npm run prisma:studio

# Create new migration
npm run prisma:migrate dev --name add_new_feature

# Reset database (careful!)
npx prisma migrate reset
```

---

## Troubleshooting

### Error: "Cannot connect to database"

**Solution 1: Check Cloud SQL Proxy is running**
```bash
# In the proxy terminal, you should see:
# "Listening on 127.0.0.1:5432"
```

**Solution 2: Verify credentials**
```bash
# Test connection manually
psql "host=127.0.0.1 port=5432 dbname=supershop user=supershop_user password=MUJAHIDrumel123@123"
```

### Error: "The provided database string is invalid"

**Solution: Check .env file**
```bash
# Make sure DATABASE_URL has single @ symbol
cat backend/.env | grep DATABASE_URL
```

### Error: "Proxy not found"

**Solution: Download Cloud SQL Proxy**
```bash
cd /mnt/storage/Projects/supershop/backend
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy
```

---

## Alternative: Use Docker PostgreSQL Locally

If you don't want to use Cloud SQL Proxy during development:

```bash
# Start local PostgreSQL with Docker
docker run -d \
  --name supershop-local-db \
  -e POSTGRES_PASSWORD=MUJAHIDrumel123@123 \
  -e POSTGRES_USER=supershop_user \
  -e POSTGRES_DB=supershop \
  -p 5432:5432 \
  postgres:15-alpine

# Update .env to use local database
DATABASE_URL=postgresql://supershop_user:MUJAHIDrumel123@123@localhost:5432/supershop?schema=public

# Run migrations
npm run prisma:migrate
```

---

## Environment Files Reference

### `.env` (Development - Local with Cloud SQL Proxy)
```env
DATABASE_URL=postgresql://supershop_user:MUJAHIDrumel123@123@127.0.0.1:5432/supershop?schema=public
```

### `.env.production` (Production - Cloud Run)
```env
DATABASE_URL=postgresql://supershop_user:MUJAHIDrumel123@123@/supershop?host=/cloudsql/shomaj-817b0:asia-southeast1:supershop&schema=public
```

Note: Use `&` not `?` for the second parameter in the socket path version!

---

## Next Steps

1. ✅ Start Cloud SQL Proxy (Terminal 1)
2. ✅ Run `npm run prisma:migrate` (Terminal 2)
3. ✅ Generate Prisma Client
4. ✅ Start development server

You're all set! 🚀

---

## 🔄 Workflow: Clone Production Data to Local Docker

We have automated scripts to backup the production database and restore it to a local Docker container. This allows you to work with fresh real data without risking the production database.

### Scripts Overview

| Script | Description |
|--------|-------------|
| `./scripts/backup-to-sql.sh` | Dumps the database defined in `DATABASE_URL` to a SQL file in `backups/`. |
| `./scripts/setup-local-db.sh` | Spins up a Docker container (`supershop_db_backup`), restores the latest backup, and updates `.env`. |
| `./scripts/verify-backup.sh` | Verifies a backup by restoring it to a temporary container and checking row counts. |

### Step-by-Step Guide

#### 1. Backup Production
First, ensure you are connected to production. If you are using Cloud SQL Proxy:

1. **Start the proxy** (if not running):
   ```bash
   ./cloud-sql-proxy shomaj-817b0:asia-southeast1:supershop
   ```

2. **Run the backup script**:
   You need to target the production database. If your `.env` is currently pointing to local, you can pass the connection string explicitly:
   ```bash
   # Example targeting local proxy
   export DATABASE_URL="postgresql://supershop_user:MUJAHIDrumel123@123@127.0.0.1:5432/supershop?schema=public"
   ./scripts/backup-to-sql.sh
   ```

#### 2. Setup Local Database
Run the setup script to create the local container and restore the data:
```bash
./scripts/setup-local-db.sh
```
*   **Container Name:** `supershop_db_backup`
*   **User/Pass:** `postgres` / `postgres`
*   **Port:** `5432`

> **Note:** This script will automatically update your `.env` file to point to this new local database!

#### 3. Verify (Optional)
You can verify the integrity of the backup using:
```bash
./scripts/verify-backup.sh
```


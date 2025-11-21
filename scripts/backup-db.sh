#!/usr/bin/env bash
set -euo pipefail

# Backup Postgres DB using pg_dump. Reads DATABASE_URL from env or .env file.
# Usage: ./backup-db.sh [--schema-only] [--data-only] [--out <dir>] [--compress]

print_usage() {
  echo "Usage: $0 [--schema-only] [--data-only] [--out <dir>] [--compress]"
  echo "  --schema-only    Dump only schema (no data)"
  echo "  --data-only      Dump only data (no schema)"
  echo "  --out <dir>      Output directory (default: backups)"
  echo "  --compress       Compress the SQL dump with gzip"
  echo "  --plain          Use plain SQL format (INSERT SQL statements) rather than custom format"
  echo "  --tables <list>  Comma-separated list of tables to dump (default: all tables)"
}

# Find DATABASE_URL in environment or .env
get_database_url_from_env_file() {
  local env_files=(.env .env.production .env.local)
  for f in "${env_files[@]}"; do
    if [[ -f "$f" ]]; then
      # Use grep to find DATABASE_URL line and strip quotes
      local line
      line=$(grep -E '^DATABASE_URL\s*=' "$f" || true)
      if [[ -n "$line" ]]; then
        local val
        val=$(echo "$line" | sed -E 's/DATABASE_URL\s*=\s*"?([^\"]+)"?/\1/')
        echo "$val"
        return 0
      fi
    fi
  done
  return 1
}

# Parse args
SCHEMA_ONLY=false
DATA_ONLY=false
OUT_DIR="backups"
COMPRESS=false
# PLAIN flag: output plain SQL
PLAIN=false
INSERTS=false
TABLES=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --schema-only)
      SCHEMA_ONLY=true; shift
      ;;
    --data-only)
      DATA_ONLY=true; shift
      ;;
    --out)
      OUT_DIR="$2"; shift 2
      ;;
    --compress)
      COMPRESS=true; shift
      ;;
    --plain|--sql)
      PLAIN=true; shift
      ;;
    --inserts)
      INSERTS=true; shift
      ;;
    --tables)
      TABLES="$2"; shift 2
      ;;
    -h|--help)
      print_usage; exit 0
      ;;
    *)
      echo "Unknown arg: $1"; print_usage; exit 1
      ;;
  esac
done

if [[ "$SCHEMA_ONLY" == true && "$DATA_ONLY" == true ]]; then
  echo "Cannot use --schema-only and --data-only together"; exit 2
fi

# Determine DATABASE_URL
DATABASE_URL=${DATABASE_URL:-}
if [[ -z "$DATABASE_URL" ]]; then
  if DATABASE_URL=$(get_database_url_from_env_file); then
    echo "Found DATABASE_URL in .env file"
  else
    echo "DATABASE_URL not found in environment or .env files" >&2
    echo "Set DATABASE_URL environment variable or add to .env" >&2
    exit 3
  fi
fi
# Remove schema query param if present (pg_dump doesn't support it)
DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/?schema=[^&]*//')
# URL-encode @ in password to %40
DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/@123/%40123/g')

# Ensure pg_dump installed
if ! command -v pg_dump >/dev/null 2>&1; then
  echo "pg_dump is required but not found. Install Postgres client tools." >&2
  exit 4
fi

mkdir -p "$OUT_DIR"
TS=$(date +%Y%m%dT%H%M%SZ)
FILENAME_BASE="db-backup-$TS"
SUFFIX=""
if [[ "$SCHEMA_ONLY" == true ]]; then
  FLAGS=(--schema-only)
  SUFFIX="-schema"
  FILENAME="$OUT_DIR/$FILENAME_BASE$SUFFIX"
elif [[ "$DATA_ONLY" == true ]]; then
  FLAGS=(--data-only)
  SUFFIX="-data"
  FILENAME="$OUT_DIR/$FILENAME_BASE$SUFFIX"
else
  FLAGS=()
  if [[ "$PLAIN" == true ]]; then
    # plain-format SQL
    FORMAT_FLAG=(--format=plain)
    if [[ -z "$SUFFIX" ]]; then SUFFIX=""; fi
    FILENAME="$OUT_DIR/$FILENAME_BASE$SUFFIX.sql"
  else
    # default custom format
    FORMAT_FLAG=(--format=custom)
    if [[ -z "$SUFFIX" ]]; then SUFFIX=""; fi
    FILENAME="$OUT_DIR/$FILENAME_BASE$SUFFIX.dump"
  fi
fi

# Handle table selection: pass -t per table for pg_dump
if [[ -n "$TABLES" ]]; then
  IFS=',' read -ra TBL <<< "$TABLES"
  for t in "${TBL[@]}"; do
    FLAGS+=(--table="$t")
  done
fi

echo "Dumping database to $FILENAME ..."
# Use pg_dump with connection string via --dbname
if [[ "$PLAIN" == true ]]; then
  pg_dump --dbname="$DATABASE_URL" "${FORMAT_FLAG[@]}" "${FLAGS[@]}" "${TBL[@]}" $([[ "$INSERTS" == true ]] && echo "--inserts") -f "$FILENAME" || {
    echo "pg_dump failed" >&2
    exit 5
  }
else
  pg_dump --dbname="$DATABASE_URL" "${FORMAT_FLAG[@]}" "${FLAGS[@]}" "${TBL[@]}" $([[ "$INSERTS" == true ]] && echo "--inserts") -f "$FILENAME" || {
    echo "pg_dump failed" >&2
    exit 5
  }
fi
 

if [[ "$COMPRESS" == true ]]; then
  echo "Compressing $FILENAME.gz"
  gzip -f "$FILENAME"
  echo "Backup completed: $FILENAME.gz"
else
  echo "Backup completed: $FILENAME"
fi

echo "Done."
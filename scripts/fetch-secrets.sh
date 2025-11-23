#!/usr/bin/env bash
set -euo pipefail

# Fetch a list of secrets from Google Secret Manager and write them into a given env file
# WARNING: This script writes secret values into local files. Do not commit .env files.
# Usage: ./scripts/fetch-secrets.sh --env-file .env.production --project shomaj-817b0

PROJECT=""
ENV_FILE=".env"
DRY_RUN=false

SECRET_LIST=(
  JWT_SECRET
  JWT_REFRESH_SECRET
  JWT_EXPIRES_IN
  JWT_REFRESH_EXPIRES_IN
  DATABASE_URL
  GOOGLE_CLIENT_ID
  GOOGLE_CLIENT_SECRET
  GOOGLE_CALLBACK_URL
  CORS_ORIGIN
)

function usage() {
  cat <<EOF
Usage: $0 --env-file FILE --project PROJECT [--dry-run]

Fetch secrets from Secret Manager and upsert their values into FILE.
Examples:
  $0 --env-file .env --project shomaj-817b0
  $0 --env-file .env.production --project shomaj-817b0 --dry-run

EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT="$2"
      shift 2
      ;;
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$PROJECT" ]]; then
  echo "Missing --project argument" >&2
  usage
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Env file $ENV_FILE does not exist. Creating a new one at $ENV_FILE" >&2
  touch "$ENV_FILE"
fi

# Check gcloud availability
if ! command -v gcloud >/dev/null; then
  echo "gcloud CLI not found in PATH. Install gcloud and authenticate first." >&2
  exit 1
fi

# Function to fetch secret value
fetch_secret() {
  local secret_name="$1"
  if gcloud secrets describe "$secret_name" --project "$PROJECT" >/dev/null 2>&1; then
    # secrets versions access prints plaintext to stdout
    local secret_value
    secret_value=$(gcloud secrets versions access latest --secret="$secret_name" --project="$PROJECT" 2>/dev/null)
    echo "$secret_value"
    return 0
  else
    echo ""
    return 1
  fi
}

# Upsert key into env file (replace or append)
upsert_env() {
  local key="$1"
  local value="$2"
  local file="$3"

  if grep -qE "^${key}=" "${file}"; then
    # Use awk to replace line safely
    # For portability, create a temp file
    awk -v k="$key" -v v="$value" 'BEGIN{OFS=FS="=";} $1==k{$0=k"="v; found=1} {print} END{if(!found) print k"="v}' "${file}" >"${file}.tmp" && mv "${file}.tmp" "${file}"
  else
    printf "%s=%s\n" "$key" "$value" >>"${file}"
  fi
}

# Ask for confirmation
echo "Fetching secrets from project: $PROJECT"
echo "Target env file: $ENV_FILE"
if [ "$DRY_RUN" = true ]; then
  echo "DRY RUN: Values will NOT be written to the file"
fi

read -p "Proceed? (y/N) " CONF
CONF=${CONF:-N}
if [[ ! "$CONF" =~ ^[Yy]$ ]]; then
  echo "Aborted by user"
  exit 0
fi

for s in "${SECRET_LIST[@]}"; do
  echo "Checking secret: $s"
  if secret_val=$(fetch_secret "$s"); then
    if [ "$DRY_RUN" = true ]; then
      echo "[DRY-RUN] $s = \"$secret_val\""
    else
      echo "Upserting $s into $ENV_FILE"
      upsert_env "$s" "$secret_val" "$ENV_FILE"
    fi
  else
    echo "Secret $s not found in project $PROJECT" >&2
  fi
done

if [ "$DRY_RUN" = false ]; then
  echo "Done. Remember: DO NOT commit env files with secrets to your repo. Add them to .gitignore if necessary."
fi

exit 0

#!/usr/bin/env bash
set -euo pipefail

PROJECT=""

function usage(){
  cat <<EOF
Usage: $0 --project PROJECT

Check whether required secrets are present in Google Secret Manager.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT="$2"
      shift 2
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
  echo "Missing --project" >&2
  usage
  exit 1
fi

# Required secret list (same as in the deployment docs)
REQUIRED_SECRETS=(
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

if ! command -v gcloud >/dev/null; then
  echo "gcloud CLI not found in PATH. Install gcloud and authenticate." >&2
  exit 1
fi

# Check each secret exists
printf "Checking Google Secret Manager for project %s\n" "$PROJECT"
for s in "${REQUIRED_SECRETS[@]}"; do
  if gcloud secrets describe "$s" --project "$PROJECT" >/dev/null 2>&1; then
    printf "  ✅ %s\n" "$s"
  else
    printf "  ❌ %s (MISSING)\n" "$s"
  fi
done

exit 0

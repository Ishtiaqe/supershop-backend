#!/usr/bin/env bash
set -euo pipefail

PROJECT=""
REGION="asia-southeast1"
SERVICE="supershop-backend"

function usage(){
  cat <<EOF
Usage: $0 --project PROJECT [--region REGION] [--service SERVICE]

Check whether required environment variables are present on a Cloud Run service.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --service)
      SERVICE="$2"
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

# Required runtime env vars for backend auth and integrations.
REQUIRED_ENV_VARS=(
  JWT_SECRET
  JWT_REFRESH_SECRET
  JWT_EXPIRES_IN
  JWT_REFRESH_EXPIRES_IN
  DATABASE_URL
  GOOGLE_CLIENT_ID
  GOOGLE_CLIENT_SECRET
  GOOGLE_CALLBACK_URL
  CORS_ORIGIN
  FIREBASE_PRIVATE_KEY
  FIREBASE_CLIENT_EMAIL
)

if ! command -v gcloud >/dev/null; then
  echo "gcloud CLI not found in PATH. Install gcloud and authenticate." >&2
  exit 1
fi

# Read env var names from the Cloud Run service.
SERVICE_ENV_NAMES="$(gcloud run services describe "$SERVICE" \
  --project "$PROJECT" \
  --region "$REGION" \
  --format='value(spec.template.spec.containers[0].env[].name)' || true)"

if [[ -z "$SERVICE_ENV_NAMES" ]]; then
  echo "No environment variables found on service '${SERVICE}' in ${REGION}." >&2
fi

printf "Checking Cloud Run env vars for service %s (project=%s region=%s)\n" "$SERVICE" "$PROJECT" "$REGION"
for s in "${REQUIRED_ENV_VARS[@]}"; do
  if printf '%s' "$SERVICE_ENV_NAMES" | tr ';' '\n' | grep -qx "$s"; then
    printf "  ✅ %s\n" "$s"
  else
    printf "  ❌ %s (MISSING)\n" "$s"
  fi
done

exit 0

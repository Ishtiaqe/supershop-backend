#!/usr/bin/env bash
set -euo pipefail

# Simple deployment shortcuts for Supershop backend.
# Usage:
#   bash scripts/deploy-shortcuts.sh help
#   bash scripts/deploy-shortcuts.sh check
#   bash scripts/deploy-shortcuts.sh cloudbuild
#   bash scripts/deploy-shortcuts.sh manual
#   bash scripts/deploy-shortcuts.sh health

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PROJECT_ID="${PROJECT_ID:-shomaj-817b0}"
REGION="${REGION:-asia-southeast1}"
SERVICE="${SERVICE:-supershop-backend}"
REPOSITORY_PATH="${REPOSITORY_PATH:-cloud-run-source-deploy/supershop-backend/supershop-backend}"
TAG="${TAG:-manual-$(git rev-parse --short HEAD)}"
IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_PATH}:${TAG}"
ENV_VARS_FILE="${ENV_VARS_FILE:-}"

run_cmd() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    printf 'DRY_RUN: '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

print_help() {
  cat <<'EOF'
Supershop deployment shortcuts

Commands:
  check       Run local pre-deploy checks
  cloudbuild  Submit Cloud Build with COMMIT_SHA substitution
  manual      Build locally, push image, deploy to Cloud Run
  health      Check Cloud Run health endpoint
  help        Show this help

Optional env vars:
  PROJECT_ID  (default: shomaj-817b0)
  REGION      (default: asia-southeast1)
  SERVICE     (default: supershop-backend)
  TAG         (default: manual-<git-sha>)
  DRY_RUN     (set to 1 to print commands without executing them)
  ENV_VARS_FILE (optional path to a .env style file for Cloud Run --env-vars-file)

Examples:
  npm run deploy:check
  npm run deploy:cloudbuild
  TAG=release-20260316 npm run deploy:manual
  ENV_VARS_FILE=.cloudrun.env npm run deploy:manual
  npm run deploy:health
EOF
}

run_check() {
  npm run predeploy:local
}

run_cloudbuild() {
  local sha
  sha="$(git rev-parse --short HEAD)"
  run_cmd gcloud builds submit --config=cloudbuild.yaml . --substitutions="COMMIT_SHA=${sha}"
}

run_manual() {
  local deploy_args
  deploy_args=(
    run deploy "${SERVICE}"
    "--image=${IMAGE}"
    "--region=${REGION}"
    --platform=managed
    --cpu=0.5
    --memory=256Mi
    --min-instances=0
    --cpu-throttling
    --cpu-boost
  )

  if [[ -n "$ENV_VARS_FILE" ]]; then
    if [[ ! -f "$ENV_VARS_FILE" ]]; then
      echo "ENV_VARS_FILE not found: $ENV_VARS_FILE" >&2
      exit 1
    fi

    deploy_args+=("--env-vars-file=${ENV_VARS_FILE}")
  fi

  run_cmd gcloud auth configure-docker "${REGION}-docker.pkg.dev"
  run_cmd docker build -t "${IMAGE}" .
  run_cmd docker push "${IMAGE}"
  run_cmd gcloud "${deploy_args[@]}"
}

run_health() {
  local url
  url="$(gcloud run services describe "${SERVICE}" --region "${REGION}" --format='value(status.url)')"
  echo "Service URL: ${url}"
  curl -fsS "${url}/api/v1/health"
  echo
}

cmd="${1:-help}"
case "$cmd" in
  check)
    run_check
    ;;
  cloudbuild)
    run_cloudbuild
    ;;
  manual)
    run_manual
    ;;
  health)
    run_health
    ;;
  help|--help|-h)
    print_help
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    print_help
    exit 1
    ;;
esac

#!/usr/bin/env bash
set -euo pipefail

# Local preflight checks before push / Cloud Build trigger.
# Usage:
#   npm run predeploy:local
#   RUN_TESTS=1 npm run predeploy:local
#   RUN_TESTS=1 DOCKER_CHECK=1 npm run predeploy:local

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Installing dependencies (npm install)"
npm install

echo "==> Generating Prisma client"
npm run prisma:generate

echo "==> Building backend"
npm run build

if [[ "${RUN_TESTS:-0}" == "1" ]]; then
  echo "==> Running tests"
  npm test
else
  echo "==> Skipping tests (set RUN_TESTS=1 to enable)"
fi

if [[ "${DOCKER_CHECK:-0}" == "1" ]]; then
  echo "==> Building Docker image locally (same Dockerfile path as Cloud Build)"
  docker build -t supershop-backend:local .
else
  echo "==> Skipping Docker build (set DOCKER_CHECK=1 to enable)"
fi

echo "==> Predeploy local checks completed successfully"

#!/bin/bash

################################################################################
# Quick Cloud Run Environment Migration (One-Liner Alternative)
# For experienced users - minimal output, fast execution
################################################################################

set -e

PROJECT_ID="${GCP_PROJECT_ID:-shomaj-817b0}"
SERVICE_NAME="${CLOUD_RUN_SERVICE:-supershop-backend}"
REGION="${GCP_REGION:-asia-southeast1}"
ENV_FILE="${ENV_FILE:-.env}"

# Build env vars string from .env file
# Filters out comments and empty lines, escapes special chars
build_env_vars() {
  # Read all non-comment, non-empty lines
  grep -v '^#' "$ENV_FILE" | grep -v '^$' | \
  # Escape special characters for shell
  sed 's/[&/\]/\\&/g' | \
  # Join with commas
  paste -sd, - | \
  # Remove trailing comma
  sed 's/,$//'
}

echo "Building environment variables from $ENV_FILE..."
ENV_VARS=$(build_env_vars)

echo "Deploying to Cloud Run..."
gcloud run services update "$SERVICE_NAME" \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --set-env-vars="$ENV_VARS" \
  --quiet

echo "✓ Deployment complete"
echo "Service: https://console.cloud.google.com/run/detail/$REGION/$SERVICE_NAME"

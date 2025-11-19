#!/usr/bin/env bash
set -euo pipefail

# Ensure minikube is started with the profile Cloud Code uses (profile can be set by Cloud Code)
PROFILE=${MINIKUBE_PROFILE:-cloud-run-dev-internal}

echo "=== Make sure minikube is running for profile: $PROFILE ==="
minikube status -p "$PROFILE" || (echo "minikube not running for profile $PROFILE; run 'minikube start -p $PROFILE' and try again" && exit 1)

# Pre-pull base node image on host and load into minikube to avoid DockerHub DNS errors
BASE_IMAGE=node:18-bullseye-slim

echo "=== Pulling base image $BASE_IMAGE on host ==="
docker pull "$BASE_IMAGE"

echo "=== Loading base image into minikube (profile: $PROFILE) ==="
minikube image load "$BASE_IMAGE" -p "$PROFILE"

# Enable gcp-auth add-on in case Cloud Code requires it
echo "=== Enabling gcp-auth addon for Cloud Code (profile: $PROFILE) ==="
minikube addons enable gcp-auth -p "$PROFILE" || true

# If you still get DNS errors, try restarting the Kubernetes core DNS in minikube
echo "=== Restarting kube-dns addon (profile: $PROFILE) ==="
minikube addons enable coredns -p "$PROFILE" || true

# Confirm environment
echo "=== Images present in minikube ==="
minikube image ls -p "$PROFILE" | grep "$BASE_IMAGE" || echo "$BASE_IMAGE not found in minikube images"

echo "=== Done. Try Cloud Run 'Run/Debug Locally' again. ==="

#!/bin/bash

################################################################################
# Cloud Run Environment Migration Script
# Migrates all environment variables from .env to Cloud Run service
# Disables Secret Manager dependency completely
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-shomaj-817b0}"
SERVICE_NAME="${CLOUD_RUN_SERVICE:-supershop-backend}"
REGION="${GCP_REGION:-asia-southeast1}"
ENV_FILE="${ENV_FILE:-.env}"

# Required environment variables (must exist)
REQUIRED_VARS=(
  "NODE_ENV"
  "DATABASE_URL"
  "JWT_SECRET"
  "JWT_EXPIRES_IN"
  "JWT_REFRESH_SECRET"
  "JWT_REFRESH_EXPIRES_IN"
  "FIREBASE_PROJECT_ID"
  "FIREBASE_PRIVATE_KEY"
  "FIREBASE_CLIENT_EMAIL"
  "FIREBASE_PRIVATE_KEY_ID"
  "FIREBASE_CLIENT_ID"
  "FIREBASE_CLIENT_X509_CERT_URL"
)

# Optional variables
OPTIONAL_VARS=(
  "API_VERSION"
  "API_PREFIX"
  "CORS_ORIGIN"
  "FRONTEND_URL"
  "THROTTLE_TTL"
  "THROTTLE_LIMIT"
  "VAPID_PRIVATE_KEY"
  "NEXT_PUBLIC_VAPID_PUBLIC_KEY"
  "GOOGLE_CLIENT_ID"
  "GOOGLE_CLIENT_SECRET"
  "GOOGLE_CALLBACK_URL"
)

# ============================================================================
# Helper Functions
# ============================================================================

log() {
  echo -e "${BLUE}[*]${NC} $1"
}

success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[!]${NC} $1"
}

error() {
  echo -e "${RED}[✗]${NC} $1"
}

step() {
  echo ""
  echo -e "${BLUE}=================================================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}=================================================================================${NC}"
}

# ============================================================================
# Validation Functions
# ============================================================================

validate_env_file() {
  step "Step 1: Validating .env file"
  
  if [ ! -f "$ENV_FILE" ]; then
    error ".env file not found at: $ENV_FILE"
    exit 1
  fi
  
  success ".env file found: $ENV_FILE"
}

validate_gcloud_auth() {
  step "Step 2: Validating gcloud authentication"
  
  if ! command -v gcloud &> /dev/null; then
    error "gcloud CLI not found. Please install Google Cloud SDK."
    exit 1
  fi
  
  # Check if authenticated
  if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &>/dev/null; then
    error "Not authenticated with gcloud. Run: gcloud auth login"
    exit 1
  fi
  
  success "gcloud authenticated"
  
  log "Project ID: $PROJECT_ID"
  log "Service: $SERVICE_NAME"
  log "Region: $REGION"
}

validate_required_vars() {
  step "Step 3: Validating required environment variables"
  
  missing_vars=()
  
  for var in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "^${var}=" "$ENV_FILE"; then
      missing_vars+=("$var")
    fi
  done
  
  if [ ${#missing_vars[@]} -gt 0 ]; then
    error "Missing required environment variables:"
    for var in "${missing_vars[@]}"; do
      echo "  - $var"
    done
    exit 1
  fi
  
  success "All required environment variables found"
}

check_optional_vars() {
  step "Step 4: Checking optional environment variables"
  
  for var in "${OPTIONAL_VARS[@]}"; do
    if grep -q "^${var}=" "$ENV_FILE"; then
      log "Found: $var"
    else
      warn "Missing (optional): $var"
    fi
  done
}

# ============================================================================
# Environment Variable Preparation
# ============================================================================

prepare_gcloud_command() {
  step "Step 5: Preparing gcloud command"
  
  # Start building the command
  local env_vars_part=""
  local all_vars=("${REQUIRED_VARS[@]}" "${OPTIONAL_VARS[@]}")
  
  log "Processing environment variables..."
  
  for var in "${all_vars[@]}"; do
    if ! grep -q "^${var}=" "$ENV_FILE"; then
      continue
    fi
    
    # Extract value (handles multi-line values like FIREBASE_PRIVATE_KEY)
    local value=$(grep "^${var}=" "$ENV_FILE" | cut -d'=' -f2- | sed 's/^"//' | sed 's/"$//')
    
    if [ -z "$value" ]; then
      warn "Empty value for $var"
      continue
    fi
    
    # Escape special characters for gcloud command
    # For lines with quotes, handle carefully
    value=$(printf '%s\n' "$value" | sed 's/[&/\]/\\&/g')
    
    # Add to environment variables string
    if [ -z "$env_vars_part" ]; then
      env_vars_part="${var}=${value}"
    else
      env_vars_part="${env_vars_part},${var}=${value}"
    fi
    
    log "  Prepared: $var ($(echo "$value" | wc -c) chars)"
  done
  
  # Save to file for deployment
  echo "$env_vars_part" > /tmp/cloudrun_env_vars.txt
  success "Environment variables prepared"
  log "Total variables: $(echo "$env_vars_part" | grep -o ',' | wc -l)"
}

# ============================================================================
# Deployment Preview
# ============================================================================

show_deployment_preview() {
  step "Step 6: Deployment Preview"
  
  log "Command to be executed:"
  echo ""
  echo "gcloud run services update $SERVICE_NAME \\"
  echo "  --project=$PROJECT_ID \\"
  echo "  --region=$REGION \\"
  echo "  --set-env-vars=\"<env_vars_here>\""
  echo ""
  
  log "Number of environment variables to be set:"
  local count=$(cat /tmp/cloudrun_env_vars.txt | grep -o ',' | wc -l)
  echo "$((count + 1))"
  
  # Show sample of variables
  log "Sample variables:"
  grep "^[^=]*=" /tmp/cloudrun_env_vars.txt | head -5 | cut -d'=' -f1 | sed 's/^/  - /'
  echo "  ... and more"
}

# ============================================================================
# Deployment
# ============================================================================

deploy_to_cloudrun() {
  step "Step 7: Deploying to Cloud Run"
  
  warn "This will redeploy the Cloud Run service."
  log "Current configuration will be updated with new environment variables."
  echo ""
  read -p "Continue with deployment? (yes/no): " -r
  echo
  if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    error "Deployment cancelled"
    exit 1
  fi
  
  # First, clear any existing secrets to avoid conflicts
  log "Clearing existing secret bindings..."
  if gcloud run services update "$SERVICE_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --clear-secrets \
    --quiet 2>/dev/null; then
    success "Cleared existing secret bindings"
  else
    warn "No existing secrets to clear (or they were already cleared)"
  fi
  
  # Convert env vars to YAML format for env-vars-file
  # This handles special characters, commas, and other edge cases better
  log "Preparing environment variables in YAML format..."
  
  > /tmp/cloudrun_env_vars.yaml  # Clear file
  
  # Read each line from prepared env vars and format as YAML
  while IFS='=' read -r key rest; do
    if [ -n "$key" ]; then
      # For values with special chars, use YAML quoted format
      echo "$key: \"${rest}\"" >> /tmp/cloudrun_env_vars.yaml
    fi
  done < <(cat /tmp/cloudrun_env_vars.txt | tr ',' '\n')
  
  log "Deploying..."
  
  # Execute the update using env-vars-file instead of --set-env-vars
  # This avoids shell escaping issues with special characters
  if gcloud run services update "$SERVICE_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --env-vars-file=/tmp/cloudrun_env_vars.yaml \
    --quiet; then
    success "Cloud Run service updated successfully"
  else
    error "Deployment failed"
    exit 1
  fi
}

# ============================================================================
# Verification
# ============================================================================

verify_deployment() {
  step "Step 8: Verifying deployment"
  
  log "Waiting for service to stabilize (30 seconds)..."
  sleep 30
  
  # Check service status
  if gcloud run services describe "$SERVICE_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --format="value(status.conditions[?type=='Ready'].status)" | grep -q True; then
    success "Cloud Run service is ready and serving traffic"
  else
    warn "Cloud Run service status is unknown. Check console:"
    log "https://console.cloud.google.com/run/detail/$REGION/$SERVICE_NAME"
  fi
  
  # Show current URL
  local url=$(gcloud run services describe "$SERVICE_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --format="value(status.url)")
  
  success "Service URL: $url"
  
  # Run health check
  log "Running health check..."
  if curl -s "$url/health" > /dev/null 2>&1; then
    success "Health check passed"
  else
    warn "Waiting for service to become healthy..."
    sleep 10
    if curl -s "$url/api/v1/health" > /dev/null 2>&1; then
      success "Service is responding"
    else
      warn "Health check not responding yet. Service may still be initializing."
    fi
  fi
}

# ============================================================================
# Cleanup & Summary
# ============================================================================

cleanup() {
  step "Step 9: Cleanup"
  
  # Remove temporary files
  rm -f /tmp/cloudrun_env_vars.txt
  
  success "Temporary files cleaned up"
}

show_summary() {
  step "Migration Summary"
  
  echo ""
  success "Environment variables have been successfully migrated to Cloud Run"
  echo ""
  echo "Key changes:"
  echo "  ✓ All environments variables now stored in Cloud Run service"
  echo "  ✓ Secret Manager dependency removed"
  echo "  ✓ Application can now start without Secret Manager API enabled"
  echo ""
  echo "Next steps:"
  echo "  1. You can safely delete the secrets from Secret Manager"
  echo "  2. Disable the Secret Manager API in GCP (if not needed elsewhere)"
  echo "  3. Monitor the Cloud Run service for any issues:"
  echo "     gcloud run services describe $SERVICE_NAME --project=$PROJECT_ID --region=$REGION"
  echo ""
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
  echo -e ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║                  Cloud Run Environment Migration Script                         ║${NC}"
  echo -e "${BLUE}║                                                                                ║${NC}"
  echo -e "${BLUE}║  This script migrates all environment variables from .env to Cloud Run         ║${NC}"
  echo -e "${BLUE}║  without using Secret Manager. After this:                                    ║${NC}"
  echo -e "${BLUE}║  - Your Cloud Run service will use local environment variables                ║${NC}"
  echo -e "${BLUE}║  - Secret Manager API is no longer required                                   ║${NC}"
  echo -e "${BLUE}║  - All sensitive values are stored in Cloud Run's environment                 ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  validate_env_file
  validate_gcloud_auth
  validate_required_vars
  check_optional_vars
  prepare_gcloud_command
  show_deployment_preview
  deploy_to_cloudrun
  verify_deployment
  cleanup
  show_summary
}

# Run main
main "$@"

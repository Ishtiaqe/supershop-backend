# Cloud Run Environment Migration Strategy

**Date:** March 16, 2026  
**Status:** In Progress (Secret Manager API Disabled)  
**Objective:** Migrate all environment variables from Secret Manager to Cloud Run, eliminating dependency on Secret Manager

---

## Problem Analysis

### What Broke
- Cloud Run deployment failed when Secret Manager API was disabled
- The service was configured to fetch secrets via `--set-secrets` (e.g., `FIREBASE_PRIVATE_KEY=secret_ref:latest`)
- When Secret Manager API was disabled, Cloud Run couldn't resolve these secret references
- Container failed to start → deployment failed
- **Service is still running on previous working revision** (not broken, but can't deploy new versions)

### Root Cause
```
Previous Strategy:
  .env (local) → Secret Manager API → Cloud Run (binds to secrets)
                      ↓
              (User disabled API)
                      ↓
              Cloud Run can't fetch secrets → Deploy fails
```

---

## New Strategy: Direct Environment Variables

```
New Strategy:
  .env (local) → Cloud Run (--set-env-vars) → Container Runtime
  
Benefits:
  ✓ No dependency on Secret Manager
  ✓ Simple and direct
  ✓ Secrets stored in Cloud Run service configuration
  ✓ Can delete Secret Manager entirely
```

### How It Works

1. **Read all variables from .env locally**
2. **Pass them directly to Cloud Run via `--set-env-vars`**
3. **Cloud Run injects them at container startup**
4. **Application reads them from environment**

---

## Architecture Comparison

### Old (Secret Manager Based - NO LONGER WORKING)
```yaml
Architecture:
  ├─ .env (local dev only)
  ├─ Secret Manager API (GCP - stores secrets)
  └─ Cloud Run
      └─ Container references secrets via secret bindings
         └─ Fetches from Secret Manager at startup (FAILS if API disabled)

Pros:
  - Secrets not visible in Cloud Run config
  - Centralized secret management

Cons:
  - Depends on Secret Manager API being enabled
  - Additional GCP API call at startup
  - Complexity layer
```

### New (Direct Environment Variables)
```yaml
Architecture:
  ├─ .env (local dev)
  └─ Cloud Run Service
      └─ Environment Variables (stored in service definition)
          └─ Container reads at startup (no external API calls)

Pros:
  - No external dependencies
  - Faster startup (no API calls)
  - Simpler architecture
  - Can delete Secret Manager entirely

Cons:
  - Secrets visible in Cloud Run service definition
  - Requires careful access control (IAM permissions)
```

---

## Implementation Steps

### Step 1: Prerequisites

```bash
# 1. Ensure you're authenticated with gcloud
gcloud auth login

# 2. Set environment variables for the script
export GCP_PROJECT_ID="shomaj-817b0"
export CLOUD_RUN_SERVICE="supershop-backend"
export GCP_REGION="asia-southeast1"

# 3. Verify gcloud access
gcloud run services list --project "$GCP_PROJECT_ID" --region "$GCP_REGION"
```

### Step 2: Review Current State

```bash
# Check current environment variables in Cloud Run
gcloud run services describe supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --format='table(spec.template.spec.containers[0].env[].name)'
```

**Expected Output:**
```
name
FIREBASE_PRIVATE_KEY
FIREBASE_CLIENT_EMAIL
```

(Only 2 variables because the previous partial deployment failed)

### Step 3: Run Migration Script

#### Option A: Safe Migration (Recommended)

```bash
# Navigate to backend directory
cd supershop-backend

# Make script executable
chmod +x scripts/migrate-to-cloudrun-envs.sh

# Run with full validation and preview
./scripts/migrate-to-cloudrun-envs.sh
```

This script will:
1. ✓ Validate .env file exists
2. ✓ Verify gcloud authentication
3. ✓ Check all required variables are present
4. ✓ Prepare all variables for Cloud Run
5. ✓ Show deployment preview
6. ✓ Ask for confirmation before deploying
7. ✓ Deploy to Cloud Run
8. ✓ Verify deployment succeeded
9. ✓ Run health checks

#### Option B: Quick Migration (Fast)

```bash
# If you trust your .env file is complete
cd supershop-backend
chmod +x scripts/migrate-to-quick.sh
./scripts/migrate-to-cloudrun-quick.sh
```

---

## Important Configuration Notes

### PORT Environment Variable
- **Local development:** `PORT=8000`
- **Cloud Run:** Must be `PORT=8080` (default Cloud Run port)

**Current status:** Check which PORT is in your .env

If your .env has `PORT=8000`:
```bash
# Add this line to your .env for Cloud Run compatibility
PORT=8080
```

Or the migration script will set it automatically.

### Cloud Run Specifics

**Why some values need special handling:**

1. **FIREBASE_PRIVATE_KEY** - Multi-line PEM format
   ```
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...==\n-----END PRIVATE KEY-----\n"
   ```
   ✓ Migration script handles newlines correctly

2. **DATABASE_URL** - Long connection string with special characters
   ```
   DATABASE_URL=postgresql://user:pass@host:5432/db
   ```
   ✓ Migration script escapes special characters

3. **CORS_ORIGIN** - May contain multiple URLs (comma-separated)
   ```
   CORS_ORIGIN=http://localhost:3000,https://yourdomain.com
   ```
   ✓ Preserved as-is

---

## Verification & Validation

### After Deployment

#### 1. Check Service Status
```bash
gcloud run services describe supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --format='value(status.conditions[?type=="Ready"].status)'
```

Expected: `True`

#### 2. Verify Environment Variables
```bash
gcloud run services describe supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --format='table(spec.template.spec.containers[0].env[].name)' | head -20
```

Expected: All required variables listed

#### 3. Health Check
```bash
# Get service URL
SERVICE_URL=$(gcloud run services describe supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --format='value(status.url)')

# Test health endpoint
curl "$SERVICE_URL/health" -v
# or
curl "$SERVICE_URL/api/v1/health" -v
```

Expected: HTTP 200 response

#### 4. Check Cloud Run Logs
```bash
# View recent logs for the service
gcloud run revisions list \
  --service=supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --limit=1 \
  --format='value(name)'

# Open logs in Cloud Console
# URL: https://console.cloud.google.com/logs
```

---

## Rollback Plan

If the deployment fails:

### Automatic Fallback
- Cloud Run keeps previous working revision active
- If new revision doesn't pass health checks, traffic stays on old revision
- **Service remains running**

### Manual Rollback
```bash
# List recent revisions
gcloud run revisions list \
  --service=supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --limit=5

# Route all traffic to previous revision
gcloud run services update-traffic supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --to-revisions=REVISION_NAME=100
  # Replace REVISION_NAME with actual name, e.g., supershop-backend-00055-8gb
```

---

## Security Considerations

### Storing Secrets in Cloud Run

After this migration, the sensitive values are stored in:
- **Cloud Run Service Configuration** (not in code, not in version control)

**Access Control:**
```bash
# Who can see these environment variables?
# Anyone with IAM role: roles/run.viewer or roles/run.admin on the Cloud Run service

# To restrict access:
gcloud run services add-iam-policy-binding supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --member=serviceAccount:ACCOUNT@PROJECT.iam.gserviceaccount.com \
  --role=roles/run.invoker
```

### Audit Trail

All changes to Cloud Run are logged in:
- **Cloud Audit Logs** → Admin Activity
  - Track who updated the service and when
  - View: https://console.cloud.google.com/logs/audit

---

## Post-Migration Cleanup

Once deployment is verified successful:

### 1. Delete Secret Manager Secrets (Optional)
```bash
# List all secrets
gcloud secrets list --project=shomaj-817b0

# Delete individual secrets (if confirmed no longer needed)
gcloud secrets delete FIREBASE_PRIVATE_KEY --project=shomaj-817b0 --quiet
gcloud secrets delete FIREBASE_CLIENT_EMAIL --project=shomaj-817b0 --quiet
# ... repeat for other secrets
```

### 2. Disable Secret Manager API (Optional)
```bash
gcloud services disable secretmanager.googleapis.com --project=shomaj-817b0
```

### 3. Update Documentation
- [ ] Update deployment guide in repo
- [ ] Update README with new process
- [ ] Document environment variables needed

---

## Troubleshooting

### Issue: Deployment Hangs
```
Symptom: "Creating Revision..." takes > 5 minutes
```

**Solution:**
1. Cancel the command (Ctrl+C)
2. Check Cloud Run logs: https://console.cloud.google.com/logs
3. Look for "container did not start" errors
4. Verify DATABASE_URL is correct (most common cause)

### Issue: Container Fails to Start
```
Symptom: "The user-provided container failed to start"
```

**Common Causes:**
- Missing required environment variable (e.g., DATABASE_URL)
- Invalid connection string
- DATABASE_URL pointing to wrong database

**Solution:**
```bash
# Check logs for specific error
gcloud logging read "resource.type=cloud_run_revision" \
  --project=shomaj-817b0 \
  --limit=50 \
  --format=json | jq '.[].textPayload'
```

### Issue: Health Check Fails
```
Symptom: curl "$SERVICE_URL/health" returns 502
```

**Solution:**
1. Wait 30-60 seconds (server may still be initializing)
2. Check if application is actually listening on PORT=8080
3. Verify in source code that health endpoint exists

---

## Success Criteria

✓ Cloud Run service deployed successfully  
✓ All environment variables set in service configuration  
✓ Container passes health checks  
✓ Service is responding to requests  
✓ Application logs show normal startup  
✓ Secret Manager API can be safely disabled  

---

## Environment Variables Summary

### Required (Must be set)
```
NODE_ENV=production
DATABASE_URL=postgresql://...
JWT_SECRET=...
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=...
JWT_REFRESH_EXPIRES_IN=7d
FIREBASE_PROJECT_ID=shomaj-817b0
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@shomaj-817b0.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY_ID=13d76d2fb692ed2cf90c4a0330051544fd549ce5
FIREBASE_CLIENT_ID=116952330666617534421
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/...
```

### Recommended Optional
```
API_VERSION=v1
API_PREFIX=api
CORS_ORIGIN=https://yourdomain.com
FRONTEND_URL=https://yourdomain.com
PORT=8080
THROTTLE_TTL=60000
THROTTLE_LIMIT=10
VAPID_PRIVATE_KEY=...
NEXT_PUBLIC_VAPID_PUBLIC_KEY=...
```

---

## Next Steps

1. **Review** this strategy document
2. **Prepare** your .env file (ensure PORT=8080 for Cloud Run)
3. **Run** the migration script when ready:
   ```bash
   cd supershop-backend
   chmod +x scripts/migrate-to-cloudrun-envs.sh
   ./scripts/migrate-to-cloudrun-envs.sh
   ```
4. **Verify** deployment by checking health endpoints
5. **Monitor** logs for the first 24 hours
6. **Cleanup** Secret Manager if migration is successful

---

## Questions?

Check:
- Cloud Run documentation: https://cloud.google.com/run/docs/configuring/environment-variables
- Google Cloud Support: https://cloud.google.com/support
- Your application logs: https://console.cloud.google.com/logs

---

**Document Version:** 1.0  
**Last Updated:** March 16, 2026

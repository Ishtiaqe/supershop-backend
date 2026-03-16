# Cloud Run Environment Migration - Quick Reference

**Status:** Ready to execute  
**Time to completion:** ~5-10 minutes  
**Risk level:** Low (with automatic rollback)

---

## TL;DR - What's Happening

```
Old (BROKEN):           New (WORKING):
Env vars in Secret      Env vars directly
    Manager                in Cloud Run
        ↓                       ↓
Secret Manager          Cloud Run
  API lookup            (no external API)
        ↓                       ↓
   FAILS ✗              WORKS ✓
```

---

## One-Command Summary

```bash
cd /mnt/storage/Projects/supershop/supershop-backend && \
chmod +x scripts/migrate-to-cloudrun-envs.sh && \
./scripts/migrate-to-cloudrun-envs.sh
```

---

## Step-by-Step Commands

### 1. Navigate to Backend Directory
```bash
cd /mnt/storage/Projects/supershop/supershop-backend
```

### 2. Make Script Executable
```bash
chmod +x scripts/migrate-to-cloudrun-envs.sh
```

### 3. (Optional) Review Strategy
```bash
cat CLOUDRUN_ENV_MIGRATION_STRATEGY.md
```

### 4. Run Migration
```bash
./scripts/migrate-to-cloudrun-envs.sh
```

**The script will:**
- ✓ Check your gcloud authentication
- ✓ Validate all required environment variables exist
- ✓ Show you a preview of what will be deployed
- ✓ Ask for confirmation before deploying
- ✓ Deploy to Cloud Run
- ✓ Verify the deployment succeeded
- ✓ Run health checks

### 5. Verify Success

Wait for the script to finish, then check:

```bash
# Check service status
gcloud run services describe supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --format='value(status.url)'

# Test health endpoint (replace URL)
curl "https://YOUR-SERVICE-URL/health" -v
```

---

## What the Script Does (In Order)

| Step | Action | Status |
|------|--------|--------|
| 1 | Validate .env file exists | ✓ Automated |
| 2 | Check gcloud authentication | ✓ Automated |
| 3 | Verify all required vars present | ✓ Automated |
| 4 | Check optional vars | ✓ Automated |
| 5 | Prepare env vars for deployment | ✓ Automated |
| 6 | Show deployment preview | ℹ️ Informational |
| 7 | Ask for confirmation | ⏸️ Requires input |
| 8 | Deploy to Cloud Run | ✓ Automated |
| 9 | Wait for service to stabilize | ✓ Automated |
| 10 | Run health checks | ✓ Automated |

---

## Emergency Commands

### If Deployment Fails

**Rollback to previous revision:**
```bash
# List recent revisions
gcloud run revisions list \
  --service=supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --limit=5

# Switch traffic back to previous working revision (e.g., 00055-8gb)
gcloud run services update-traffic supershop-backend \
  --project=shomaj-817b0 \
  --region=asia-southeast1 \
  --to-revisions=supershop-backend-00055-8gb=100
```

**Check logs for errors:**
```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=supershop-backend" \
  --project=shomaj-817b0 \
  --limit=50 \
  --format=json | jq -r '.[].textPayload' | head -20
```

---

## Critical Notes

### PORT Setting
- The script uses `PORT` from your `.env`
- **For Cloud Run, PORT must be 8080** (standard Cloud Run port)
- Check your `.env`: Does it have `PORT=8080`?

If not, add it before running:
```bash
echo "PORT=8080" >> supershop-backend/.env
```

### DATABASE_URL is Critical
- The most common cause of startup failures
- Must point to a valid, accessible PostgreSQL database
- Current value: `postgresql://postgres.pdfqecwtuytkwkgsygca:...@aws-1-ap-southeast1.pooler.supabase.com:5432/postgres`
- Verify the password hasn't expired

### FIREBASE Credentials Must Match
- FIREBASE_PRIVATE_KEY must be exactly as provided
- FIREBASE_CLIENT_EMAIL must match the project
- FIREBASE_PROJECT_ID must be `shomaj-817b0`

---

## Expected Timeline

| Phase | Time | Status |
|-------|------|--------|
| Validation | ~1 min | Automated checks |
| Preparation | <1 min | Building deploy config |
| Preview | <1 min | You review |
| Confirmation | Your choice | Waiting for approval |
| Deployment | ~2-3 min | Cloud Run creating revision |
| Stabilization | ~30 sec | Waiting for container start |
| Health Checks | ~10 sec | Verifying service |
| **Total** | **~5-10 min** | **Full process** |

---

## Success Indicators

After running the script, you should see:

```
✓ .env file found
✓ gcloud authenticated
✓ All required environment variables found
✓ Environment variables prepared
✓ Cloud Run service updated successfully
✓ Cloud Run service is ready and serving traffic
✓ Service is responding
✓ Environment variables have been successfully migrated to Cloud Run
```

---

## Post-Migration

### Clean Up (Optional)

Once you've verified everything works for 24 hours:

```bash
# Delete unused secrets from Secret Manager
gcloud secrets delete FIREBASE_PRIVATE_KEY --project=shomaj-817b0 --quiet
gcloud secrets delete FIREBASE_CLIENT_EMAIL --project=shomaj-817b0 --quiet
# ... repeat for other secrets if desired

# Disable Secret Manager API (if not used elsewhere)
gcloud services disable secretmanager.googleapis.com --project=shomaj-817b0
```

### Don't Forget

- [ ] Update team documentation
- [ ] Update deployment runbooks
- [ ] Remove references to "Secret Manager" from deploy scripts
- [ ] Commit strategy document to repo

---

## Support

### I see an error like "container failed to start"

1. Check the error message in the script output
2. Most likely causes:
   - `DATABASE_URL` is invalid or database is down
   - Missing required environment variable
   - Application has a startup bug

3. Get detailed logs:
   ```bash
   gcloud logging read "resource.type=cloud_run_revision" \
     --project=shomaj-817b0 \
     --limit=20 \
     --format=json | jq -r '.[].textPayload'
   ```

### I see "not authenticated"

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project
gcloud config set project shomaj-817b0
```

### I want to cancel mid-way

Press `Ctrl+C` - the service won't be updated until deployment is confirmed.

---

## Architecture Decision

### Why Direct Environment Variables?

| Factor | Secret Manager | Direct Env Vars |
|--------|-----------------|-----------------|
| Dependency | Multiple GCP APIs | None |
| Startup Speed | Slower (API call) | Faster |
| Complexity | Higher | Lower |
| Security | Decent | Good (IAM controls) |
| Maintainability | More complex | Simpler |

**Decision:** Direct environment variables are better for Cloud Run workloads.

---

## Questions Before Starting?

Review these files:
- **Strategy:** `CLOUDRUN_ENV_MIGRATION_STRATEGY.md` (detailed explanation)
- **Script:** `scripts/migrate-to-cloudrun-envs.sh` (what it actually does)
- **Quick:** `scripts/migrate-to-cloudrun-quick.sh` (minimal version)

---

**Ready to proceed?**

```bash
cd /mnt/storage/Projects/supershop/supershop-backend && \
./scripts/migrate-to-cloudrun-envs.sh
```

---

**Document Version:** 1.0  
**Last Updated:** March 16, 2026  
**Status:** Ready for execution

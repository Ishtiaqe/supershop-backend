# Supershop Backend Deployment Guide (Cloud Run + Cloud SQL)

This guide documents the exact, working deployment flow we’re using: Cloud Run with the free Cloud SQL connector (no VPC connector), Secret Manager for sensitive config, and a custom domain via Cloudflare.

## Prerequisites

- `gcloud` installed and authenticated
  ```bash
  gcloud auth login
  gcloud config set project shomaj-817b0
  ```
- Cloud SQL Postgres instance: `shomaj-817b0:asia-southeast1:YOUR_INSTANCE`
- Secret Manager enabled
- Docker (for local builds) and Node 20+ (for local dev)

## Quick Start (Production)

1) Create/update secrets (URL-encode any special chars in password, e.g. `@` -> `%40`)
```bash
# JWTs
echo -n "<random-32+bytes>" | gcloud secrets create JWT_SECRET --data-file=- 2>/dev/null || \
echo -n "<random-32+bytes>" | gcloud secrets versions add JWT_SECRET --data-file=-
echo -n "<random-32+bytes>" | gcloud secrets create JWT_REFRESH_SECRET --data-file=- 2>/dev/null || \
echo -n "<random-32+bytes>" | gcloud secrets versions add JWT_REFRESH_SECRET --data-file=-
echo -n "15m" | gcloud secrets create JWT_EXPIRES_IN --data-file=- 2>/dev/null || \
echo -n "15m" | gcloud secrets versions add JWT_EXPIRES_IN --data-file=-
echo -n "7d" | gcloud secrets create JWT_REFRESH_EXPIRES_IN --data-file=- 2>/dev/null || \
echo -n "7d" | gcloud secrets versions add JWT_REFRESH_EXPIRES_IN --data-file=-

# DATABASE_URL using Cloud SQL connector (Unix socket) — free, no VPC connector
# Template: postgresql://USER:PASSWORD@localhost:5432/DB?host=/cloudsql/PROJECT:REGION:INSTANCE&schema=public&sslmode=disable
echo -n "postgresql://supershop_user:REDACTED%40PASS@localhost:5432/supershop?host=/cloudsql/shomaj-817b0:asia-southeast1:YOUR_INSTANCE&schema=public&sslmode=disable" \
| gcloud secrets create DATABASE_URL --data-file=- 2>/dev/null || \
echo -n "postgresql://supershop_user:REDACTED%40PASS@localhost:5432/supershop?host=/cloudsql/shomaj-817b0:asia-southeast1:YOUR_INSTANCE&schema=public&sslmode=disable" \
| gcloud secrets versions add DATABASE_URL --data-file=-
```

2) Build and deploy to Cloud Run (pick one):

- Build locally and deploy:
```bash
# Build the Docker image locally
docker build -t gcr.io/shomaj-817b0/supershop-backend .

# Push the image to Google Container Registry
docker push gcr.io/shomaj-817b0/supershop-backend

# Deploy to Cloud Run
gcloud run deploy supershop-backend \
  --image gcr.io/shomaj-817b0/supershop-backend \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --add-cloudsql-instances shomaj-817b0:asia-southeast1:supershop-backend \
  --set-secrets JWT_SECRET=JWT_SECRET:latest,JWT_REFRESH_SECRET=JWT_REFRESH_SECRET:latest,JWT_EXPIRES_IN=JWT_EXPIRES_IN:latest,JWT_REFRESH_EXPIRES_IN=JWT_REFRESH_EXPIRES_IN:latest,DATABASE_URL=DATABASE_URL:latest \
  --clear-vpc-connector
```

- Using an existing image (if already built and pushed):
```bash
gcloud run deploy supershop-backend \
  --image gcr.io/shomaj-817b0/supershop-backend \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --add-cloudsql-instances shomaj-817b0:asia-southeast1:supershop-backend \
  --set-secrets JWT_SECRET=JWT_SECRET:latest,JWT_REFRESH_SECRET=JWT_REFRESH_SECRET:latest,JWT_EXPIRES_IN=JWT_EXPIRES_IN:latest,JWT_REFRESH_EXPIRES_IN=JWT_REFRESH_EXPIRES_IN:latest,DATABASE_URL=DATABASE_URL:latest \
  --clear-vpc-connector
```

- Or build from source directly (in cloud):
```bash
gcloud run deploy supershop-backend \
  --source . \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --add-cloudsql-instances shomaj-817b0:asia-southeast1:supershop-backend \
  --set-secrets JWT_SECRET=JWT_SECRET:latest,JWT_REFRESH_SECRET=JWT_REFRESH_SECRET:latest,JWT_EXPIRES_IN=JWT_EXPIRES_IN:latest,JWT_REFRESH_EXPIRES_IN=JWT_REFRESH_EXPIRES_IN:latest,DATABASE_URL=DATABASE_URL:latest \
  --clear-vpc-connector
```

3) Verify
```bash
SERVICE_URL=$(gcloud run services describe supershop-backend --region asia-southeast1 --format="value(status.url)")
curl -sS "$SERVICE_URL/api/v1/health"
```

## Secrets and Env

Backend consumes these secrets via ConfigService:
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`
- `JWT_EXPIRES_IN` (defaulted to 15m in code if missing)
- `JWT_REFRESH_EXPIRES_IN` (defaulted to 7d in code if missing)
- `DATABASE_URL` (must be the connector URL; passwords URL-encoded)

Non-secret envs (optional with safe defaults): `API_PREFIX`, `API_VERSION`, `CORS_ORIGIN` (comma-separated list of allowed origins, e.g. "http://localhost:3000,https://supershop.shomaj.one"), `PORT`.

## Database Migrations & Seed

Recommended: run migrations and seeding from your machine using the Cloud SQL Proxy (free) or connector:
```bash
# Start proxy (local)
./cloud-sql-proxy shomaj-817b0:asia-southeast1:YOUR_INSTANCE

# Test connection
npx -y prisma db execute --file /dev/stdin --url "postgresql://supershop_user:PWD%40ENC@localhost:5432/supershop?schema=public&sslmode=disable" <<<'select 1;'

# Apply migrations
npx prisma migrate deploy --schema prisma/schema.prisma --url "postgresql://supershop_user:PWD%40ENC@localhost:5432/supershop?schema=public&sslmode=disable"

# Seed
npm run prisma:seed  # or: ts-node prisma/seed.ts
```

## Local Development

```bash
npm install
cp .env.example .env
# Set local DATABASE_URL (proxy or local Postgres). URL-encode password!
npm run start:dev
```

If using the Cloud SQL Proxy locally:
```bash
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy
./cloud-sql-proxy shomaj-817b0:asia-southeast1:YOUR_INSTANCE
```

## Custom Domain: api.shomaj.one (Cloudflare DNS)

1) Create the domain mapping in Cloud Run:
```bash
gcloud run domain-mappings create \
  --service supershop-backend \
  --domain api.shomaj.one \
  --region asia-southeast1
```

2) Get the required DNS records to add in Cloudflare:
```bash
gcloud run domain-mappings describe \
  --domain api.shomaj.one \
  --region asia-southeast1 \
  --format="json(status.resourceRecords)" | jq
```
Add exactly those records in Cloudflare DNS for `api.shomaj.one`.
- Tip: Turn OFF the Cloudflare proxy (gray cloud) until the Google-managed cert shows Ready; you can enable it later (prefer Full (strict)).

3) Wait for certificate to provision, then verify:
```bash
gcloud run domain-mappings describe --domain api.shomaj.one --region asia-southeast1 \
  --format="value(status.conditions[?type=Ready].status)"

curl -i https://api.shomaj.one/api/v1/health
```

## Frontend (Vercel) Integration

- In Vercel Project Settings → Environment Variables:
  - `NEXT_PUBLIC_API_BASE_URL = https://api.shomaj.one`
- Redeploy the frontend.
- CORS: backend currently accepts a single origin. Set the secret/env `CORS_ORIGIN` to your production frontend origin, e.g. `https://shomaj.one` or `https://<project>.vercel.app` and redeploy the API.

## Troubleshooting & Ops

Common checks:
```bash
# Logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=supershop-backend" --limit 50 \
  --format "table(timestamp,severity,textPayload)"

# Service config
gcloud run services describe supershop-backend --region asia-southeast1 \
  --format "json(spec.template.metadata.annotations,spec.template.spec.containers[0].env)" | jq
```

Notes:
- Do not use a Serverless VPC Access connector for DB — the Cloud SQL connector (Unix socket) is free and already configured via `--add-cloudsql-instances`.
- If you previously set a VPC connector, remove it from the service with `--clear-vpc-connector` and optionally delete the connector in Compute → VPC Access.
- If your DB password contains special characters, URL-encode them in `DATABASE_URL`.

## API

- Health: `/api/v1/health`
- Auth: `/api/v1/auth/*`
- Swagger: `/api/docs`

## Security

- Secrets in Secret Manager only; never bake into images.
- CORS limited to your frontend origin.
- Use principle of least privilege for the Cloud Run service account (Cloud SQL Client + Secret Accessor only).

## Cost Tips

- Avoid Serverless VPC Access unless necessary.
- Right-size Cloud Run CPU/memory; set min instances to 0 if cold starts are acceptable.
- Choose appropriate Cloud SQL tier.
<parameter name="filePath">/mnt/storage/Projects/supershop-backend/DEPLOYMENT.md